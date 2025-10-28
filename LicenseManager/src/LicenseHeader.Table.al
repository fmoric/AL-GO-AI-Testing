table 80571 "LM License Header"
{
    Caption = 'License Header';
    DataClassification = CustomerContent;
    LookupPageId = "LM License List";
    DrillDownPageId = "LM License List";

    fields
    {
        field(1; "License No."; Code[20])
        {
            Caption = 'License No.';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; "Application Code"; Code[20])
        {
            Caption = 'Application Code';
            DataClassification = CustomerContent;
            TableRelation = "LM Application".Code where(Active = const(true));

            trigger OnValidate()
            var
                Application: Record "LM Application";
            begin
                if "Application Code" <> '' then begin
                    Application.Get("Application Code");
                    "Application Name" := Application.Name;
                    "Application Version" := Application.Version;
                end else begin
                    "Application Name" := '';
                    "Application Version" := '';
                end;
            end;
        }
        field(3; "Application Name"; Text[100])
        {
            Caption = 'Application Name';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(4; "Application Version"; Text[50])
        {
            Caption = 'Application Version';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(10; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            DataClassification = CustomerContent;
        }
        field(11; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
        }
        field(20; "Valid From Date"; Date)
        {
            Caption = 'Valid From Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ValidateDates();
            end;
        }
        field(21; "Valid To Date"; Date)
        {
            Caption = 'Valid To Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ValidateDates();
            end;
        }
        field(22; "License Status"; Enum "LM License Status")
        {
            Caption = 'License Status';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(30; "Digital Signature"; Blob)
        {
            Caption = 'Digital Signature';
            DataClassification = CustomerContent;
        }
        field(31; "Signature Algorithm"; Text[50])
        {
            Caption = 'Signature Algorithm';
            DataClassification = CustomerContent;
            InitValue = 'RSA-2048-SHA256';
        }
        field(32; "Is Signed"; Boolean)
        {
            Caption = 'Is Signed';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(40; "Max Users"; Integer)
        {
            Caption = 'Max Users';
            DataClassification = CustomerContent;
            InitValue = -1;
        }
        field(50; "Created Date"; DateTime)
        {
            Caption = 'Created Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(51; "Created By"; Code[50])
        {
            Caption = 'Created By';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(52; "Notes"; Text[250])
        {
            Caption = 'Notes';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "License No.")
        {
            Clustered = true;
        }
        key(ApplicationDate; "Application Code", "Valid From Date", "Valid To Date")
        {
        }
    }

    trigger OnInsert()
    begin
        "Created Date" := CurrentDateTime;
        "Created By" := CopyStr(UserId, 1, MaxStrLen("Created By"));
        UpdateLicenseStatus();
    end;

    trigger OnModify()
    begin
        UpdateLicenseStatus();
    end;

    local procedure ValidateDates()
    begin
        if ("Valid From Date" <> 0D) and ("Valid To Date" <> 0D) then
            if "Valid From Date" > "Valid To Date" then
                Error('Valid From Date cannot be later than Valid To Date.');
    end;

    procedure UpdateLicenseStatus()
    var
        CurrentDate: Date;
    begin
        CurrentDate := Today;

        if ("Valid From Date" = 0D) or ("Valid To Date" = 0D) then begin
            "License Status" := "License Status"::Invalid;
            exit;
        end;

        if not "Is Signed" then begin
            "License Status" := "License Status"::Unsigned;
            exit;
        end;

        if CurrentDate < "Valid From Date" then begin
            "License Status" := "License Status"::Pending;
            exit;
        end;

        if CurrentDate > "Valid To Date" then begin
            "License Status" := "License Status"::Expired;
            exit;
        end;

        "License Status" := "License Status"::Active;
    end;

    procedure IsValid(): Boolean
    begin
        UpdateLicenseStatus();
        exit("License Status" = "License Status"::Active);
    end;
}
