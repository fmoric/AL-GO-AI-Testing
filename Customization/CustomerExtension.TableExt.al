tableextension 80550 "Customer Extension" extends Customer
{
    fields
    {
        field(80550; "Due Amount"; Decimal)
        {
            Caption = 'Due Amount';
            FieldClass = FlowField;
            CalcFormula = sum("Detailed Cust. Ledg. Entry".Amount where("Customer No." = field("No."),
                                                                          "Initial Entry Due Date" = field("Date Filter")));
            Editable = false;
            AutoFormatType = 1;
        }
    }
}