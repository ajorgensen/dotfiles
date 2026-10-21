#!/usr/bin/env python3
"""
Convert Xero General Ledger export to Digits Journal Entry CSV Import format.

Usage:
    python xero_to_digits.py <input_xero_file.txt> [output_file.csv] [--coa=coa_file.csv] [--max-rows=290]

Input: Tab-separated Xero GL export with columns:
    JournalNumber, JournalDate, AccountName, AccountCode, Name, NetAmount,
    GSTAmount, GrossAmount, TaxCode, Reference, Description, BankAccountCode

Output: Digits Journal Entry CSV with columns:
    Reference Number, Date, Category Name, Category Number, Department,
    Location, Party, Debit Amount, Credit Amount, Memo, Description

Large files are automatically split into multiple files (suffixed _1, _2, _3, etc.) to stay
under Digits' 300-row import limit. Journal entries are kept intact across splits.

After conversion, validates that all categories exist in a COA (Chart of Accounts)
import file if one is found in the same directory or specified via --coa flag.
"""

import csv
import sys
import os
import glob
from datetime import datetime
from collections import OrderedDict


def parse_xero_date(date_str):
    """Convert Xero date (DD-Mon-YYYY) to Digits format (MM/DD/YYYY)."""
    try:
        dt = datetime.strptime(date_str, "%d-%b-%Y")
        return dt.strftime("%m/%d/%Y")
    except ValueError:
        return date_str  # Return as-is if parsing fails


def gross_to_debit_credit(gross_amount):
    """
    Convert GrossAmount to Debit/Credit columns.

    Xero convention:
    - Positive GrossAmount = Debit
    - Negative GrossAmount = Credit (use absolute value)
    """
    try:
        amount = float(gross_amount)
        if amount >= 0:
            return (f"{amount:.2f}", "")  # Debit
        else:
            return ("", f"{abs(amount):.2f}")  # Credit
    except (ValueError, TypeError):
        return ("", "")


def find_coa_file(directory):
    """
    Find a COA (Chart of Accounts) import file in the given directory.

    Looks for files matching common COA naming patterns:
    - *COA*Digits*Import*.csv
    - *COA*.csv
    - *Chart*of*Accounts*.csv
    - *Category*Import*.csv

    Returns the path to the COA file or None if not found.
    """
    patterns = [
        '*COA*Digits*Import*.csv',
        '*COA*Import*.csv',
        '*COA*.csv',
        '*Chart*of*Accounts*.csv',
        '*Category*Import*.csv',
    ]

    for pattern in patterns:
        matches = glob.glob(os.path.join(directory, pattern))
        if matches:
            # Return the first match (most recent by modification time)
            matches.sort(key=os.path.getmtime, reverse=True)
            return matches[0]

    return None


def load_coa_categories(coa_file):
    """
    Load valid categories from a COA import file.

    Returns a dict with:
    - 'names': set of valid Category Names (lowercase for case-insensitive matching)
    - 'numbers': set of valid Category Numbers
    - 'name_to_number': dict mapping names to numbers
    - 'number_to_name': dict mapping numbers to names
    """
    categories = {
        'names': set(),
        'numbers': set(),
        'name_to_number': {},
        'number_to_name': {},
    }

    with open(coa_file, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            name = row.get('Category Name', '').strip()
            number = row.get('Category Number', '').strip()

            if name:
                categories['names'].add(name.lower())
                if number:
                    categories['name_to_number'][name.lower()] = number
            if number:
                categories['numbers'].add(number)
                if name:
                    categories['number_to_name'][number] = name

    return categories


def validate_categories(converted_rows, coa_categories):
    """
    Validate that all categories in converted rows exist in the COA.

    Returns a dict with:
    - 'valid': bool indicating if all categories are valid
    - 'missing_names': list of category names not found in COA
    - 'missing_numbers': list of category numbers not found in COA
    - 'mismatched': list of (name, number) pairs where both exist but don't match
    """
    missing_names = set()
    missing_numbers = set()
    mismatched = []

    for row in converted_rows:
        name = row.get('Category Name', '').strip()
        number = row.get('Category Number', '').strip()

        name_lower = name.lower() if name else ''

        # Check if name exists
        name_valid = not name or name_lower in coa_categories['names']
        # Check if number exists
        number_valid = not number or number in coa_categories['numbers']

        if name and not name_valid:
            missing_names.add(name)
        if number and not number_valid:
            missing_numbers.add(number)

        # Check if name and number match (both exist but refer to different categories)
        if name and number and name_valid and number_valid:
            expected_number = coa_categories['name_to_number'].get(name_lower)
            expected_name = coa_categories['number_to_name'].get(number)
            if expected_number and expected_number != number:
                mismatched.append((name, number, f"Name '{name}' maps to number '{expected_number}' in COA"))
            elif expected_name and expected_name.lower() != name_lower:
                mismatched.append((name, number, f"Number '{number}' maps to name '{expected_name}' in COA"))

    return {
        'valid': len(missing_names) == 0 and len(missing_numbers) == 0 and len(mismatched) == 0,
        'missing_names': sorted(missing_names),
        'missing_numbers': sorted(missing_numbers),
        'mismatched': mismatched,
    }


def print_validation_report(validation_result, coa_file):
    """Print a formatted validation report."""
    print(f"\n{'='*60}")
    print("CATEGORY VALIDATION REPORT")
    print(f"COA File: {coa_file}")
    print(f"{'='*60}")

    if validation_result['valid']:
        print("✓ All categories are valid and match the COA file.")
    else:
        if validation_result['missing_names']:
            print(f"\n⚠ Missing Category Names ({len(validation_result['missing_names'])}):")
            for name in validation_result['missing_names']:
                print(f"  - {name}")

        if validation_result['missing_numbers']:
            print(f"\n⚠ Missing Category Numbers ({len(validation_result['missing_numbers'])}):")
            for number in validation_result['missing_numbers']:
                print(f"  - {number}")

        if validation_result['mismatched']:
            print(f"\n⚠ Mismatched Name/Number Pairs ({len(validation_result['mismatched'])}):")
            for name, number, reason in validation_result['mismatched']:
                print(f"  - '{name}' / '{number}': {reason}")

        print("\n" + "-"*60)
        print("ACTION REQUIRED: Add missing categories to the COA import file")
        print("before importing the journal entries into Digits.")

    print(f"{'='*60}\n")
    return validation_result['valid']


def split_rows_by_journal_entries(rows, max_rows_per_file=290):
    """
    Split rows into multiple chunks while keeping journal entries intact.

    Each journal entry (group of rows with same Reference Number) must stay together.
    If adding a journal entry would exceed max_rows_per_file, start a new chunk.

    Args:
        rows: List of row dictionaries with 'Reference Number' field
        max_rows_per_file: Maximum rows per file (default 290, leaving room under 300 limit)

    Returns:
        List of row chunks, where each chunk is a list of rows
    """
    if not rows:
        return []

    # Group rows by journal number
    journal_groups = OrderedDict()
    for row in rows:
        ref_num = row['Reference Number']
        if ref_num not in journal_groups:
            journal_groups[ref_num] = []
        journal_groups[ref_num].append(row)

    # Split into chunks while keeping journal entries intact
    chunks = []
    current_chunk = []
    current_count = 0

    for journal_ref, journal_rows in journal_groups.items():
        journal_size = len(journal_rows)

        # If adding this journal would exceed limit, start a new chunk
        # (unless current chunk is empty, then we must include it even if it's large)
        if current_count > 0 and current_count + journal_size > max_rows_per_file:
            chunks.append(current_chunk)
            current_chunk = []
            current_count = 0

        # Add journal entry to current chunk
        current_chunk.extend(journal_rows)
        current_count += journal_size

    # Add final chunk if not empty
    if current_chunk:
        chunks.append(current_chunk)

    return chunks


def convert_xero_to_digits(input_file, output_file=None, coa_file=None, max_rows_per_file=290):
    """
    Convert Xero GL export to Digits Journal Entry format.

    Args:
        input_file: Path to Xero GL tab-separated export file
        output_file: Optional path for output CSV (default: <input>_digits_import.csv)
        coa_file: Optional path to COA import file for validation
        max_rows_per_file: Maximum rows per file before splitting (default 290)

    Returns:
        Tuple of (list of output file paths, validation_passed boolean)
    """

    if output_file is None:
        base = os.path.splitext(input_file)[0]
        output_file = f"{base}_digits_import.csv"

    # Read Xero file (tab-separated)
    rows = []
    with open(input_file, 'r', encoding='utf-8') as f:
        reader = csv.reader(f, delimiter='\t')
        header = next(reader)  # Skip header

        for row in reader:
            if len(row) < 8:  # Skip incomplete rows
                continue

            journal_number = row[0] if len(row) > 0 else ""
            journal_date = row[1] if len(row) > 1 else ""
            account_name = row[2] if len(row) > 2 else ""
            account_code = row[3] if len(row) > 3 else ""
            # row[4] is Name (account type) - not used
            # row[5] is NetAmount - not used
            # row[6] is GSTAmount - not used
            gross_amount = row[7] if len(row) > 7 else ""
            # row[8] is TaxCode - not used
            reference = row[9] if len(row) > 9 else ""
            description = row[10] if len(row) > 10 else ""
            # row[11] is BankAccountCode - not used

            # Convert date format
            digits_date = parse_xero_date(journal_date)

            # Convert GrossAmount to Debit/Credit
            debit, credit = gross_to_debit_credit(gross_amount)

            # Build Digits row
            digits_row = {
                'Reference Number': journal_number,
                'Date': digits_date,
                'Category Name': account_name,
                'Category Number': account_code,
                'Department': '',
                'Location': '',
                'Party': description.strip() if description else '',
                'Debit Amount': debit,
                'Credit Amount': credit,
                'Memo': reference.strip() if reference else '',
                'Description': description.strip() if description else ''
            }
            rows.append(digits_row)

    # Determine if we need to split into multiple files
    chunks = split_rows_by_journal_entries(rows, max_rows_per_file)

    # Write Digits CSV(s)
    fieldnames = [
        'Reference Number', 'Date', 'Category Name', 'Category Number',
        'Department', 'Location', 'Party', 'Debit Amount', 'Credit Amount',
        'Memo', 'Description'
    ]

    output_files = []

    if len(chunks) <= 1:
        # Single file output
        with open(output_file, 'w', newline='', encoding='utf-8') as f:
            writer = csv.DictWriter(f, fieldnames=fieldnames)
            writer.writeheader()
            writer.writerows(rows)
        print(f"Converted {len(rows)} entries to: {output_file}")
        output_files.append(output_file)
    else:
        # Multiple file output
        base = os.path.splitext(output_file)[0]
        ext = os.path.splitext(output_file)[1]

        for i, chunk in enumerate(chunks, start=1):
            chunk_file = f"{base}_{i}{ext}"
            with open(chunk_file, 'w', newline='', encoding='utf-8') as f:
                writer = csv.DictWriter(f, fieldnames=fieldnames)
                writer.writeheader()
                writer.writerows(chunk)
            output_files.append(chunk_file)

        print(f"\nConverted {len(rows)} entries into {len(chunks)} files:")
        for i, (chunk_file, chunk) in enumerate(zip(output_files, chunks), start=1):
            print(f"  {i}. {chunk_file} ({len(chunk)} rows)")
        print(f"\nImport files in order: _1, _2, _3, etc.")

    # Category validation
    input_dir = os.path.dirname(os.path.abspath(input_file))

    # Find COA file if not explicitly provided
    if coa_file is None:
        coa_file = find_coa_file(input_dir)

    validation_passed = True
    if coa_file and os.path.exists(coa_file):
        print(f"\nFound COA file: {coa_file}")
        coa_categories = load_coa_categories(coa_file)
        validation_result = validate_categories(rows, coa_categories)
        validation_passed = print_validation_report(validation_result, coa_file)
    else:
        print("\nNo COA file found for validation.")
        print(f"Searched in: {input_dir}")
        print("To validate categories, place a COA import CSV in the same")
        print("directory or specify with --coa=<path_to_coa_file.csv>")

    return output_files, validation_passed


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python xero_to_digits.py <input_xero_file.txt> [output_file.csv] [--coa=coa_file.csv] [--max-rows=290]")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = None
    coa_file = None
    max_rows = 290

    # Parse remaining arguments
    for arg in sys.argv[2:]:
        if arg.startswith('--coa='):
            coa_file = arg[6:]
        elif arg.startswith('--max-rows='):
            try:
                max_rows = int(arg[11:])
            except ValueError:
                print(f"Error: Invalid value for --max-rows: {arg[11:]}")
                sys.exit(1)
        elif output_file is None:
            output_file = arg

    output_paths, validation_passed = convert_xero_to_digits(input_file, output_file, coa_file, max_rows)

    # Exit with non-zero status if validation failed
    if not validation_passed:
        sys.exit(2)
