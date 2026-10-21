# Type Mappings Reference

Complete mapping reference for converting source system account types to Digits category types.

---

## Valid Digits Types

| Type | Description |
|------|-------------|
| Bank | Bank and cash accounts |
| Credit Card | Credit card accounts |
| Assets | All asset accounts (current, fixed, other) |
| Liabilities | All liability accounts |
| Equity | Equity, capital, and retained earnings |
| Revenue | Sales and service income |
| Cost of Revenue | COGS and direct costs |
| Operating Expenses | General and admin expenses |
| Other Income | Interest and miscellaneous income |
| Other Expenses | Interest expense and extraordinary items |

---

## Xero Type Mappings

### By Account Type

| Xero Account Type | → Digits Type |
|-------------------|---------------|
| Bank | Bank |
| Accounts Receivable | Assets |
| Current Asset | Assets |
| Fixed Asset | Assets |
| Non-current Asset | Assets |
| Accounts Payable | Liabilities |
| Sales Tax | Liabilities |
| Current Liability | Liabilities |
| Non-current Liability | Liabilities |
| Tracking | Liabilities |
| Historical Adjustment | Liabilities |
| Rounding | Liabilities |
| Unpaid Expense Claims | Liabilities |
| Equity | Equity |
| Retained Earnings | Equity |
| Revenue | Revenue |
| Sales | Revenue |
| Other Income | Other Income |
| Direct Costs | Cost of Revenue |
| Expense | Operating Expenses |
| Overhead | Operating Expenses |
| Depreciation | Operating Expenses |

### By Report Code Prefix

Use when account type is ambiguous:

| Report Code | Meaning | → Digits Type |
|-------------|---------|---------------|
| `ASS.CUR.CAS.BAN` | Bank | Bank |
| `LIA.CUR.PAY.CRC` | Credit Card | Credit Card |
| `ASS.CUR.REC` | Receivables | Assets |
| `ASS.CUR` | Current Assets | Assets |
| `ASS.FIX` | Fixed Assets | Assets |
| `ASS` | Assets | Assets |
| `LIA.CUR.TAX` | Tax Liabilities | Liabilities |
| `LIA.CUR.PAY` | Payables | Liabilities |
| `LIA.CUR` | Current Liabilities | Liabilities |
| `LIA` | Liabilities | Liabilities |
| `EQU.RET` | Retained Earnings | Equity |
| `EQU.CAP` | Capital | Equity |
| `EQU.DIS` | Distributions | Equity |
| `EQU.OPE` | Opening Balance | Equity |
| `EQU` | Equity | Equity |
| `REV.TRA` | Trading Revenue | Revenue |
| `REV` | Revenue | Revenue |
| `COS` | Cost of Sales | Cost of Revenue |
| `EXP.COS` | COGS | Cost of Revenue |
| `EXP.ADM` | Admin Expenses | Operating Expenses |
| `EXP.FIN.INT` | Interest Expense | Other Expenses |
| `EXP.FIN.BAN` | Bank Fees | Operating Expenses |
| `EXP.FIN` | Finance Expenses | Other Expenses |
| `EXP` | Expenses | Operating Expenses |

---

## QuickBooks Type Mappings

| QuickBooks Account Type | → Digits Type |
|-------------------------|---------------|
| Bank | Bank |
| Credit Card | Credit Card |
| Accounts Receivable | Assets |
| Other Current Asset | Assets |
| Fixed Asset | Assets |
| Other Asset | Assets |
| Accounts Payable | Liabilities |
| Credit Card | Credit Card |
| Other Current Liability | Liabilities |
| Long Term Liability | Liabilities |
| Equity | Equity |
| Income | Revenue |
| Other Income | Other Income |
| Cost of Goods Sold | Cost of Revenue |
| Expense | Operating Expenses |
| Other Expense | Other Expenses |

---

## FreshBooks Type Mappings

| FreshBooks Category | → Digits Type |
|---------------------|---------------|
| Cash & Bank | Bank |
| Credit Cards | Credit Card |
| Money Owed To You | Assets |
| Assets | Assets |
| Credit Cards (liability) | Credit Card |
| Money You Owe | Liabilities |
| Liabilities | Liabilities |
| Equity | Equity |
| Income | Revenue |
| Cost of Goods Sold | Cost of Revenue |
| Expenses | Operating Expenses |
