page 80573 "LM License Card"
{
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "LM License Header";
    Caption = 'License Card';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

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
                field("Application Version"; Rec."Application Version")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the application version.';
                }
            }
            group(Customer)
            {
                Caption = 'Customer Information';

                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer name.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer number.';
                }
            }
            group(Validity)
            {
                Caption = 'Validity Period';

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
            }
            group(Limits)
            {
                Caption = 'License Limits';

                field("Max Users"; Rec."Max Users")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the maximum number of users (-1 for unlimited).';
                }
            }
            group(Security)
            {
                Caption = 'Security';

                field("Signature Algorithm"; Rec."Signature Algorithm")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the signature algorithm used.';
                }
                field("Is Signed"; Rec."Is Signed")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the license has been digitally signed.';
                }
            }
            group(Additional)
            {
                Caption = 'Additional Information';

                field(Notes; Rec.Notes)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies additional notes about the license.';
                    MultiLine = true;
                }
                field("Created Date"; Rec."Created Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the license was created.';
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies who created the license.';
                }
            }
            part(Details; "LM License Detail Subpage")
            {
                ApplicationArea = All;
                SubPageLink = "License No." = field("License No.");
                Caption = 'License Features';
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
                ToolTip = 'Validate this license.';
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
                ToolTip = 'Export this license to text format.';
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
            action(UpdateStatus)
            {
                ApplicationArea = All;
                Caption = 'Update Status';
                ToolTip = 'Update the license status based on current date.';
                Image = RefreshLines;

                trigger OnAction()
                begin
                    Rec.UpdateLicenseStatus();
                    Rec.Modify(true);
                    CurrPage.Update(false);
                    Message('License status updated to: %1', Rec."License Status");
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
                actionref(UpdateStatus_Promoted; UpdateStatus)
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
