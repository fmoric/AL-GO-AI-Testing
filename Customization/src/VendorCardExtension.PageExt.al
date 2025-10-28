pageextension 80551 "Vendor Card Extension" extends "Vendor Card"
{
    layout
    {
        addafter("Balance (LCY)")
        {
            field("Due Amount"; Rec."Due Amount")
            {
                ApplicationArea = All;
                Caption = 'Due Amount';
                ToolTip = 'Specifies the total due amount for the vendor based on the applied date filter.';
            }
        }
    }
}
