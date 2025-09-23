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
            }
        }
    }

}