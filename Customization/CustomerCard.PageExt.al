pageextension 80550 "Customer Card Extension" extends "Customer Card"
{
    layout
    {
        addafter("Last Date Modified")
        {
            field("Due Amount"; Rec."Due Amount")
            {
                ApplicationArea = All;
                Caption = 'Due Amount';
                ToolTip = 'Shows the total amount due for this customer based on the applied date filter.';
                
                trigger OnDrillDown()
                begin
                    Rec.CalcFields("Due Amount");
                    DrillDownDueAmount();
                end;
            }
        }
    }

    actions
    {
        addlast(navigation)
        {
            action("Due Amount Details")
            {
                ApplicationArea = All;
                Caption = 'Due Amount Details';
                Image = CustomerLedger;
                RunObject = Page "Customer Ledger Entries";
                RunPageLink = "Customer No." = field("No."),
                              "Due Date" = field("Date Filter"),
                              "Remaining Amount" = filter(<> 0);
                ToolTip = 'View detailed customer ledger entries that make up the due amount.';
            }
        }
    }

    local procedure DrillDownDueAmount()
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        CustomerLedgerEntriesPage: Page "Customer Ledger Entries";
    begin
        CustLedgerEntry.SetRange("Customer No.", Rec."No.");
        CustLedgerEntry.SetFilter("Due Date", Rec.GetFilter("Date Filter"));
        CustLedgerEntry.SetFilter("Remaining Amount", '<>0');
        
        CustomerLedgerEntriesPage.SetTableView(CustLedgerEntry);
        CustomerLedgerEntriesPage.Run();
    end;
}