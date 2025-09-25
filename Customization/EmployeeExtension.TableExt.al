tableextension 80552 "Employee Extension" extends Employee
{
    fields
    {
        field(80552; "Due Amount"; Decimal)
        {
            Caption = 'Due Amount';
            FieldClass = FlowField;
            CalcFormula = sum("Detailed Employee Ledger Entry"."Remaining Amount" where("Employee No." = field("No."),
                                                                          "Initial Entry Due Date" = field("Date Filter")));
            Editable = false;
            AutoFormatType = 1;
        }
    }
}