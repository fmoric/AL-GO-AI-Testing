page 80571 "LM Application Card"
{
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "LM Application";
    Caption = 'Application Card';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the application code.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the application name.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the application description.';
                }
                field(Version; Rec.Version)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the application version.';
                }
                field(Active; Rec.Active)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the application is active.';
                }
                field(Publisher; Rec.Publisher)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the application publisher.';
                }
            }
            group(Audit)
            {
                Caption = 'Audit Information';

                field("Created Date"; Rec."Created Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the application was created.';
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies who created the application.';
                }
                field("Modified Date"; Rec."Modified Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the application was last modified.';
                }
                field("Modified By"; Rec."Modified By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies who last modified the application.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Licenses)
            {
                ApplicationArea = All;
                Caption = 'View Licenses';
                ToolTip = 'View all licenses for this application.';
                Image = Certificate;
                RunObject = Page "LM License List";
                RunPageLink = "Application Code" = field(Code);
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(Licenses_Promoted; Licenses)
                {
                }
            }
        }
    }
}
