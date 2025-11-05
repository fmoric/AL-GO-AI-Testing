# Due Amount Enhancement

## Overview
This enhancement adds FlowFields to Customer and Vendor tables that calculate the total due amount for each entity, with support for date filtering.

## Implementation Details

### Files Added:
1. **CustomerExtension.TableExt.al** - Table extension for Customer table
2. **CustomerCardExtension.PageExt.al** - Page extension for Customer Card
3. **VendorExtension.TableExt.al** - Table extension for Vendor table
4. **VendorCardExtension.PageExt.al** - Page extension for Vendor Card

### Features:
- **Due Amount FlowField**: Automatically calculates total outstanding amounts from customer/vendor ledger entries
- **Date Filter Support**: Users can apply date filters to see due amounts for specific date ranges
- **Consistent Implementation**: Customer and Vendor follow the same pattern and functionality

### Technical Specifications:
- **Object IDs**: 80550-80551 (within allocated range 80550-80559)
  - 80550: Customer extensions
  - 80551: Vendor extensions
- **FlowField Formula**: Sum of amounts from respective detailed ledger entry tables where:
  - Entity No. matches (Customer/Vendor No.)
  - Initial Entry Due Date is within applied date filter
  - Both use "Amount" field for calculation
- **Performance**: Uses indexed fields and filters for optimal performance

### Usage:
1. Open any Customer Card or Vendor Card
2. The "Due Amount" field will display the total outstanding amount
3. Apply a date filter to see due amounts for specific periods
4. The field automatically recalculates based on the applied filters

### Customer Implementation:
- **Table**: Extends Customer table (ID 80550)
- **Source**: "Detailed Cust. Ledg. Entry" table
- **Filter Field**: "Customer No."
- **Display Location**: Customer Card, after "Balance (LCY)" field

### Vendor Implementation:
- **Table**: Extends Vendor table (ID 80551)
- **Source**: "Detailed Vendor Ledg. Entry" table
- **Filter Field**: "Vendor No."
- **Display Location**: Vendor Card, after "Balance (LCY)" field