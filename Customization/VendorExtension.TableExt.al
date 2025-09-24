tableextension 80551 "Vendor Extension" extends Vendor
{
    fields
    {
        field(80551; "Due Amount"; Decimal)
        {
            Caption = 'Due Amount';
            FieldClass = FlowField;
            CalcFormula = sum("Detailed Vendor Ledg. Entry".Amount where("Vendor No." = field("No."),
                                                                          "Initial Entry Due Date" = field("Date Filter")));
            Editable = false;
            AutoFormatType = 1;
        }
    }
}