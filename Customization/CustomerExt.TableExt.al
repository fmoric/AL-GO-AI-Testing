tableextension 80550 "Customer Extension" extends Customer
{
    fields
    {
        field(80550; "Due Amount"; Decimal)
        {
            Caption = 'Due Amount';
            FieldClass = FlowField;
            CalcFormula = sum("Cust. Ledger Entry"."Remaining Amount" where("Customer No." = field("No."),
                                                                          "Due Date" = field("Date Filter"),
                                                                          "Remaining Amount" = filter(<> 0)));
            Editable = false;
            AutoFormatType = 1;
        }
    }
}