pageextension 80551 "Vendor Card Extension" extends "Vendor Card"
{
    layout
    {
        addafter("Last Date Modified")
        {
            field("Due Amount"; Rec."Due Amount")
            {
                ApplicationArea = All;
                Caption = 'Due Amount';
                ToolTip = 'Shows the total amount due for this vendor based on the applied date filter.';
            }
        }
    }

}