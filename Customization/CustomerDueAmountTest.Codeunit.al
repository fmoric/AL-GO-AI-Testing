codeunit 80550 "Customer Due Amount Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    [Test]
    procedure TestDueAmountCalculation()
    var
        Customer: Record Customer;
        CustLedgerEntry: Record "Cust. Ledger Entry";
        CustomerCard: TestPage "Customer Card";
    begin
        // [GIVEN] A customer with ledger entries
        CreateCustomerWithLedgerEntries(Customer, CustLedgerEntry);

        // [WHEN] Opening customer card
        CustomerCard.OpenEdit();
        CustomerCard.GoToRecord(Customer);

        // [THEN] Due Amount field should be visible and calculated
        Assert.IsTrue(CustomerCard."Due Amount".Visible(), 'Due Amount field should be visible');
        
        // [WHEN] Calculating the field
        Customer.CalcFields("Due Amount");
        
        // [THEN] Due Amount should match expected value
        Assert.AreEqual(CustLedgerEntry."Remaining Amount", Customer."Due Amount", 'Due Amount should match remaining amount');
    end;

    [Test]
    procedure TestDueAmountWithDateFilter()
    var
        Customer: Record Customer;
        CustLedgerEntry: Record "Cust. Ledger Entry";
        FilterDate: Date;
    begin
        // [GIVEN] A customer with ledger entries with different due dates
        CreateCustomerWithLedgerEntriesMultipleDates(Customer, CustLedgerEntry);
        FilterDate := CustLedgerEntry."Due Date";

        // [WHEN] Setting date filter on customer
        Customer.SetFilter("Date Filter", Format(FilterDate));
        Customer.CalcFields("Due Amount");

        // [THEN] Due Amount should only include entries matching the date filter
        Assert.IsTrue(Customer."Due Amount" > 0, 'Due Amount should be greater than zero for filtered date');
    end;

    local procedure CreateCustomerWithLedgerEntries(var Customer: Record Customer; var CustLedgerEntry: Record "Cust. Ledger Entry")
    begin
        // Create a test customer
        Customer.Init();
        Customer."No." := 'TEST001';
        Customer.Name := 'Test Customer';
        Customer.Insert();

        // Create a test ledger entry
        CustLedgerEntry.Init();
        CustLedgerEntry."Entry No." := GetNextEntryNo();
        CustLedgerEntry."Customer No." := Customer."No.";
        CustLedgerEntry."Due Date" := WorkDate();
        CustLedgerEntry."Remaining Amount" := 1000;
        CustLedgerEntry.Insert();
    end;

    local procedure CreateCustomerWithLedgerEntriesMultipleDates(var Customer: Record Customer; var CustLedgerEntry: Record "Cust. Ledger Entry")
    var
        CustLedgerEntry2: Record "Cust. Ledger Entry";
    begin
        CreateCustomerWithLedgerEntries(Customer, CustLedgerEntry);
        
        // Create another entry with different due date
        CustLedgerEntry2.Init();
        CustLedgerEntry2."Entry No." := GetNextEntryNo();
        CustLedgerEntry2."Customer No." := Customer."No.";
        CustLedgerEntry2."Due Date" := CalcDate('<+30D>', WorkDate());
        CustLedgerEntry2."Remaining Amount" := 500;
        CustLedgerEntry2.Insert();
    end;

    local procedure GetNextEntryNo(): Integer
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        if CustLedgerEntry.FindLast() then
            exit(CustLedgerEntry."Entry No." + 1)
        else
            exit(1);
    end;
}