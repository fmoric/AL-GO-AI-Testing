# Due Amount Enhancement

## Overview
This enhancement adds FlowFields to Customer, Vendor, and Employee tables that calculate the total due amount for each entity, with support for date filtering.

## Implementation Details

### Files Added:
1. **CustomerExtension.TableExt.al** - Table extension for Customer table
2. **CustomerCardExtension.PageExt.al** - Page extension for Customer Card
3. **VendorExtension.TableExt.al** - Table extension for Vendor table
4. **VendorCardExtension.PageExt.al** - Page extension for Vendor Card
5. **EmployeeExtension.TableExt.al** - Table extension for Employee table
6. **EmployeeCardExtension.PageExt.al** - Page extension for Employee Card

### Features:
- **Due Amount FlowField**: Automatically calculates total outstanding amounts from customer/vendor/employee ledger entries
- **Date Filter Support**: Users can apply date filters to see due amounts for specific date ranges
- **Consistent Implementation**: Customer, Vendor, and Employee follow the same pattern and functionality

### Technical Specifications:
- **Object IDs**: 80550-80552 (within allocated range 80550-80559)
  - 80550: Customer extensions
  - 80551: Vendor extensions
  - 80552: Employee extensions
- **FlowField Formula**: Sum of amounts from respective detailed ledger entry tables where:
  - Entity No. matches (Customer/Vendor/Employee No.)
  - Initial Entry Due Date is within applied date filter
  - Employee uses "Remaining Amount" field, Customer/Vendor use "Amount" field
- **Performance**: Uses indexed fields and filters for optimal performance

### Usage:
1. Open any Customer Card, Vendor Card, or Employee Card
2. The "Due Amount" field will display the total outstanding amount
3. Apply a date filter to see due amounts for specific periods
4. The field automatically recalculates based on the applied filters

### Customer Implementation:
- **Table**: Extends Customer table
- **Source**: "Detailed Cust. Ledg. Entry" table
- **Filter Field**: "Customer No."

### Vendor Implementation:
- **Table**: Extends Vendor table
- **Source**: "Detailed Vendor Ledg. Entry" table
- **Filter Field**: "Vendor No."

### Employee Implementation:
- **Table**: Extends Employee table
- **Source**: "Detailed Employee Ledger Entry" table
- **Filter Field**: "Employee No."
- **Amount Field**: "Remaining Amount" (different from Customer/Vendor which use "Amount")