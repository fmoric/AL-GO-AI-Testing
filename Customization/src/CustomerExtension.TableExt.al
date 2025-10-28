tableextension 80550 "Customer Extension" extends Customer
{
    fields
    {
        field(80550; "Due Amount"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = Sum("Detailed Cust. Ledg. Entry".Amount where("Customer No." = field("No."),
                                                                          "Initial Entry Due Date" = field("Date Filter")));
            Caption = 'Due Amount';
            Editable = false;
            ToolTip = 'Specifies the total due amount for the customer based on the applied date filter.';
        }
    }
}
