page 80572 "LM License List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "LM License Header";
    Caption = 'Licenses';
    CardPageId = "LM License Card";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("License No."; Rec."License No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the license number.';
                }
                field("Application Code"; Rec."Application Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the application code.';
                }
                field("Application Name"; Rec."Application Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the application name.';
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer name.';
                }
                field("Valid From Date"; Rec."Valid From Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the license becomes valid.';
                }
                field("Valid To Date"; Rec."Valid To Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the license expires.';
                }
                field("License Status"; Rec."License Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the current license status.';
                    StyleExpr = StatusStyle;
                }
                field("Is Signed"; Rec."Is Signed")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the license has been digitally signed.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ValidateLicense)
            {
                ApplicationArea = All;
                Caption = 'Validate License';
                ToolTip = 'Validate the selected license.';
                Image = Approve;

                trigger OnAction()
                var
                    LicenseMgmt: Codeunit "LM License Management";
                begin
                    if LicenseMgmt.ValidateLicense(Rec."License No.") then
                        Message('License %1 is valid.', Rec."License No.")
                    else
                        Message('License %1 is not valid.', Rec."License No.");
                end;
            }
            action(ExportLicense)
            {
                ApplicationArea = All;
                Caption = 'Export License';
                ToolTip = 'Export the selected license to text format.';
                Image = Export;

                trigger OnAction()
                var
                    LicenseMgmt: Codeunit "LM License Management";
                    LicenseText: Text;
                begin
                    LicenseText := LicenseMgmt.ExportLicenseToText(Rec."License No.");
                    Message(LicenseText);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(ValidateLicense_Promoted; ValidateLicense)
                {
                }
                actionref(ExportLicense_Promoted; ExportLicense)
                {
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        UpdateStatusStyle();
    end;

    local procedure UpdateStatusStyle()
    begin
        case Rec."License Status" of
            Rec."License Status"::Active:
                StatusStyle := 'Favorable';
            Rec."License Status"::Expired:
                StatusStyle := 'Unfavorable';
            Rec."License Status"::Pending:
                StatusStyle := 'Ambiguous';
            else
                StatusStyle := 'Subordinate';
        end;
    end;

    var
        StatusStyle: Text;
}
