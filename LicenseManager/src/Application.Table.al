table 80570 "LM Application"
{
    Caption = 'Application';
    DataClassification = CustomerContent;
    LookupPageId = "LM Application List";
    DrillDownPageId = "LM Application List";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; "Name"; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(3; "Description"; Text[250])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(4; "Version"; Text[50])
        {
            Caption = 'Version';
            DataClassification = CustomerContent;
        }
        field(5; "Active"; Boolean)
        {
            Caption = 'Active';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(6; "Publisher"; Text[100])
        {
            Caption = 'Publisher';
            DataClassification = CustomerContent;
        }
        field(10; "Created Date"; Date)
        {
            Caption = 'Created Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(11; "Created By"; Code[50])
        {
            Caption = 'Created By';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(12; "Modified Date"; Date)
        {
            Caption = 'Modified Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(13; "Modified By"; Code[50])
        {
            Caption = 'Modified By';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        "Created Date" := Today;
        "Created By" := CopyStr(UserId, 1, MaxStrLen("Created By"));
        "Modified Date" := Today;
        "Modified By" := CopyStr(UserId, 1, MaxStrLen("Modified By"));
    end;

    trigger OnModify()
    begin
        "Modified Date" := Today;
        "Modified By" := CopyStr(UserId, 1, MaxStrLen("Modified By"));
    end;
}
