---
name: digits-coa-import
description: "Transform Chart of Accounts exports into Digits Category Entry CSV Import format. Use when: (1) migrating COA from another system to Digits, (2) creating bulk category imports, (3) converting Xero/QuickBooks COA exports, or when keywords like 'COA', 'chart of accounts', 'category import', 'account migration' appear."
---

# Digits COA Import CSV Generator

Transform Chart of Accounts (COA) exports from source systems into the Digits Category Entry CSV Import format.

---

## Output Format

The Digits Category Entry CSV requires these columns:

| Column | Required | Description |
|--------|----------|-------------|
| Category Name | **Yes** | Account name (no commas) |
| Category Number | No | Account code/number |
| Parent Name | No | Parent category name (must exist in Digits or this CSV) |
| Parent Category Number | No | Disambiguates when multiple parents share a name |
| Type | **Yes** | See [Type Mappings](#type-mappings) |
| Status | No | `Active`, `Deactivated`, `Inactive`, or `Archived` |
| Description | No | Account description |

---

## Type Mappings

Valid Digits category types:

| Digits Type | Use For |
|-------------|---------|
| **Bank** | Checking, savings, cash accounts |
| **Credit Card** | Credit card accounts |
| **Assets** | Current assets, fixed assets, other assets |
| **Liabilities** | Current liabilities, long-term liabilities |
| **Equity** | Owner's equity, retained earnings, capital |
| **Revenue** | Sales, service income, other income |
| **Cost of Revenue** | COGS, direct costs |
| **Operating Expenses** | General expenses, admin costs |
| **Other Income** | Interest income, miscellaneous income |
| **Other Expenses** | Interest expense, extraordinary costs |

> [!IMPORTANT]
> Parent and child categories **must** use the same type.

---

## Workflow

### Step 1: Gather Source Data

Ask the user for:
1. The source COA file (CSV, Excel, or copy-pasted data)
2. The source system (Xero, QuickBooks, FreshBooks, or other)

### Step 2: Analyze Source Format

Identify the source columns and their mapping to Digits fields:

**Common source column mappings:**

| Source Column | Maps To |
|---------------|---------|
| Name / Account Name | Category Name |
| Code / Account Number | Category Number |
| Type / Account Type | Type (requires conversion) |
| Description | Description |

### Step 3: Map Account Types

Use **both** the source account type AND any report codes/subcategory metadata to determine the correct Digits type.

See the [Xero-Specific Mappings](#xero-specific-mappings) section for Xero migrations.

### Step 4: Generate CSV

Create a CSV with the Digits format:

```csv
Category Name,Category Number,Parent Name,Parent Category Number,Type,Status,Description
Accounts Receivable,11000,,,Assets,Active,Unpaid customer invoices
US Bank,10100,,,Bank,Active,Primary operating account
```

### Step 5: Validate

Before providing the CSV:
- [ ] All required fields (Category Name, Type) are populated
- [ ] Types are valid Digits types
- [ ] No commas in Category Name field
- [ ] Parent categories exist if referenced

---

## Xero-Specific Mappings

* When converting from Xero, use the **Report Code** column as additional metadata to determine the correct Digits type. 
* If report code is "LIA.CUR.PAY.CRC" ensure the Digits Type is "Credit Card".
* If Xero Name contains "Credit Card" or "CC" ensure the Digits Type is "Credit Card".
* If account type is "Direct Costs" ensure the Digits Type is "Cost of Revenue"

### Xero Report Code Prefixes

| Report Code Prefix | Xero Meaning | Digits Type |
|--------------------|--------------|-------------|
| `ASS.CUR.CAS.BAN` | Bank accounts | **Bank** |
| `ASS.CUR.REC` | Receivables | **Assets** |
| `ASS.CUR` | Current assets | **Assets** |
| `ASS.FIX` | Fixed assets | **Assets** |
| `ASS` | Other assets | **Assets** |
| `LIA.CUR.PAY.CRC` | Credit cards | **Credit Card** |
| `LIA.CUR` | Current liabilities | **Liabilities** |
| `LIA` | Other liabilities | **Liabilities** |
| `EQU` | Equity accounts | **Equity** |
| `REV.TRA` | Trading revenue | **Revenue** |
| `REV` | Other revenue | **Revenue** |
| `COS` | Cost of sales | **Cost of Revenue** |
| `EXP.COS` | Cost of goods sold | **Cost of Revenue** |
| `EXP.ADM` | Admin expenses | **Operating Expenses** |
| `EXP.FIN` | Finance expenses | **Other Expenses** |
| `EXP` | Other expenses | **Operating Expenses** |

### Xero Type Overrides

Some Xero types map directly regardless of report code:

| Xero Type | Digits Type |
|-----------|-------------|
| Bank | Bank |
| Accounts Receivable | Assets |
| Accounts Payable | Liabilities |
| Sales Tax | Liabilities |
| Expense | Operating Expenses |
| Revenue | Revenue |
| Equity | Equity |
| Retained Earnings | Equity |
| Fixed Asset | Assets |
| Current Asset | Assets |
| Current Liability | Liabilities |

### Special Xero Account Types

These Xero system types should be mapped as shown:

| Xero Type | Digits Type | Notes |
|-----------|-------------|-------|
| Tracking | Liabilities | Internal tracking category |
| Historical Adjustment | Liabilities | Accountant adjustments |
| Rounding | Liabilities | Rounding adjustments |
| Unpaid Expense Claims | Liabilities | Employee reimbursements |

---

## Example Transformation

**Xero Source:**
```csv
*Code,Report Code,*Name,*Type,Description
10100,ASS.CUR.CAS.BAN,US Bank,Bank,Primary checking
11000,ASS.CUR.REC.ACR,Accounts Receivable,Accounts Receivable,Unpaid invoices
60200,EXP.ADM.MOT,Automobile Expense,Expense,Vehicle costs
```

**Digits Output:**
```csv
Category Name,Category Number,Parent Name,Parent Category Number,Type,Status,Description
US Bank,10100,,,Bank,Active,Primary checking
Accounts Receivable,11000,,,Assets,Active,Unpaid invoices
Automobile Expense,60200,,,Operating Expenses,Active,Vehicle costs
```

---

## Reference Files

| File | Purpose |
|------|---------|
| `references/template.csv` | Blank Digits import template with headers |
| `references/type-mappings.md` | Complete type mapping reference |
