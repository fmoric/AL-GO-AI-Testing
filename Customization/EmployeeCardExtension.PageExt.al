pageextension 80552 "Employee Card Extension" extends "Employee Card"
{
    layout
    {
        addafter("Last Date Modified")
        {
            field("Due Amount"; Rec."Due Amount")
            {
                ApplicationArea = All;
                Caption = 'Due Amount';
                ToolTip = 'Shows the total amount due for this employee based on the applied date filter.';
            }
        }
    }

}