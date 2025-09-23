# Customer Due Amount Enhancement

## Overview
This enhancement adds a FlowField to the Customer table that calculates the total due amount for each customer, with support for date filtering.

## Implementation Details

### Files Added:
1. **CustomerExt.TableExt.al** - Table extension for Customer table
2. **CustomerCard.PageExt.al** - Page extension for Customer Card
3. **CustomerDueAmountTest.Codeunit.al** - Test codeunit for validation

### Features:
- **Due Amount FlowField**: Automatically calculates total outstanding amounts from customer ledger entries
- **Date Filter Support**: Users can apply date filters to see due amounts for specific date ranges
- **Drill-down Functionality**: Click on the Due Amount field to view detailed ledger entries
- **Navigation Action**: Additional action button for viewing due amount details

### Technical Specifications:
- **Object IDs**: 80550 (within allocated range 80550-80559)
- **FlowField Formula**: Sum of "Remaining Amount" from "Cust. Ledger Entry" where:
  - Customer No. matches
  - Due Date is within applied date filter
  - Remaining Amount is not zero
- **Performance**: Uses indexed fields and filters for optimal performance

### Usage:
1. Open any Customer Card
2. The "Due Amount" field will display the total outstanding amount
3. Apply a date filter to see due amounts for specific periods
4. Click the field or use the "Due Amount Details" action to view underlying entries

### Testing:
The test codeunit validates:
- FlowField calculation accuracy
- Date filter functionality
- UI field visibility and behavior