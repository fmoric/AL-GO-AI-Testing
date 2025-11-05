pageextension 80550 "Customer Card Extension" extends "Customer Card"
{
    layout
    {
        addafter("Balance (LCY)")
        {
            field("Due Amount"; Rec."Due Amount")
            {
                ApplicationArea = All;
                Caption = 'Due Amount';
                ToolTip = 'Specifies the total due amount for the customer based on the date filter.';
            }
        }
    }
}
