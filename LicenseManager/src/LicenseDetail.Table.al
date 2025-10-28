table 80572 "LM License Detail"
{
    Caption = 'License Detail';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "License No."; Code[20])
        {
            Caption = 'License No.';
            DataClassification = CustomerContent;
            TableRelation = "LM License Header"."License No.";
            NotBlank = true;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }
        field(10; "Feature Code"; Code[50])
        {
            Caption = 'Feature Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(11; "Feature Name"; Text[100])
        {
            Caption = 'Feature Name';
            DataClassification = CustomerContent;
        }
        field(12; "Feature Description"; Text[250])
        {
            Caption = 'Feature Description';
            DataClassification = CustomerContent;
        }
        field(20; "Enabled"; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(21; "Permission Level"; Option)
        {
            Caption = 'Permission Level';
            DataClassification = CustomerContent;
            OptionMembers = "Read","Write","Execute","Full";
            OptionCaption = 'Read,Write,Execute,Full';
        }
        field(30; "Quantity"; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
            InitValue = -1;
        }
        field(31; "Unit of Measure"; Text[20])
        {
            Caption = 'Unit of Measure';
            DataClassification = CustomerContent;
        }
        field(40; "Custom Metadata"; Text[250])
        {
            Caption = 'Custom Metadata';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "License No.", "Line No.")
        {
            Clustered = true;
        }
        key(Feature; "License No.", "Feature Code")
        {
        }
    }
}
