---
name: xero-to-digits-journal
description: |
  Convert Xero General Ledger exports to Digits Journal Entry CSV Import format. Use when:
  (1) importing Xero GL data into Digits, (2) converting Xero journal exports, (3) migrating
  accounting data from Xero to Digits. Triggers on keywords: 'Xero', 'GL', 'General Ledger',
  'journal entry import', 'Digits import', 'XERO_GL', or file patterns like '*XERO*GL*.txt'.
---

# Xero to Digits Journal Entry Converter

Convert Xero General Ledger tab-separated exports into Digits Journal Entry CSV Import format.

Large exports are automatically split into multiple files to stay under Digits' 300-row import limit, while keeping complete journal entries intact.

## Quick Start

```bash
python scripts/xero_to_digits.py <input_xero_file.txt> [output_file.csv] [--coa=coa_file.csv] [--max-rows=290]
```

If output file not specified, creates `<input>_digits_import.csv`.

## Automatic File Splitting

Digits has a 300-row CSV import limit. The script automatically splits large exports into multiple files:

- **Default behavior**: Splits at ~290 rows per file (configurable with `--max-rows`)
- **Journal integrity**: Complete journal entries always stay together
- **Smart splitting**: If a journal entry would exceed the limit, the split happens before it
- **Numbered files**: Output files are numbered `_1`, `_2`, `_3`, etc. to indicate import order

### Example

```bash
python scripts/xero_to_digits.py large_export.txt
```

Output:
```
Converted 847 entries into 3 files:
  1. large_export_digits_import_1.csv (289 rows)
  2. large_export_digits_import_2.csv (290 rows)
  3. large_export_digits_import_3.csv (268 rows)

Import files in order: _1, _2, _3, etc.
```

### Custom Row Limit

Adjust the split threshold with `--max-rows`:

```bash
python scripts/xero_to_digits.py export.txt --max-rows=250
```

## Category Validation

After conversion, the script validates that all categories (Category Name and Category Number) in the converted file exist in a COA (Chart of Accounts) import file.

### Automatic COA Discovery

The script automatically searches for a COA file in the same directory as the input file, looking for files matching these patterns (in order):
- `*COA*Digits*Import*.csv`
- `*COA*Import*.csv`
- `*COA*.csv`
- `*Chart*of*Accounts*.csv`
- `*Category*Import*.csv`

### Explicit COA File

Specify a COA file explicitly with the `--coa` flag:
```bash
python scripts/xero_to_digits.py input.txt --coa=/path/to/coa_file.csv
```

### Validation Report

The validation report shows:
- **Missing Category Names**: Names in the journal that don't exist in the COA
- **Missing Category Numbers**: Numbers in the journal that don't exist in the COA
- **Mismatched Pairs**: Cases where both name and number exist but refer to different categories

If validation fails, the script exits with status code 2. Add missing categories to the COA import file before importing into Digits.

## Field Mapping

| Xero Field     | Digits Field      | Transformation                           |
|----------------|-------------------|------------------------------------------|
| JournalNumber  | Reference Number  | Direct copy                              |
| JournalDate    | Date              | DD-Mon-YYYY → MM/DD/YYYY                 |
| AccountName    | Category Name     | Direct copy                              |
| AccountCode    | Category Number   | Direct copy                              |
| GrossAmount    | Debit Amount      | Positive values only                     |
| GrossAmount    | Credit Amount     | Absolute value of negative amounts       |
| Description    | Party             | Direct copy                              |
| Reference      | Memo              | Direct copy                              |
| Description    | Description       | Direct copy                              |

## Debit/Credit Conversion

Xero uses a single GrossAmount column with sign convention:
- **Positive GrossAmount** → Debit Amount (credit column blank)
- **Negative GrossAmount** → Credit Amount as absolute value (debit column blank)

## Expected Input Format

Tab-separated Xero GL export with header:
```
JournalNumber	JournalDate	AccountName	AccountCode	Name	NetAmount	GSTAmount	GrossAmount	TaxCode	Reference	Description	BankAccountCode
```

## Output Format

Digits Journal Entry CSV:
```
Reference Number,Date,Category Name,Category Number,Department,Location,Party,Debit Amount,Credit Amount,Memo,Description
```

Department and Location columns are left blank (can be populated manually if needed).
