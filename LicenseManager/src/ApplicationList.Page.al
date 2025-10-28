page 80570 "LM Application List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "LM Application";
    Caption = 'Applications';
    CardPageId = "LM Application Card";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
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
