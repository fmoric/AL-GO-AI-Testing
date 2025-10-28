page 80574 "LM License Detail Subpage"
{
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "LM License Detail";
    Caption = 'License Features';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Feature Code"; Rec."Feature Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the feature code.';
                }
                field("Feature Name"; Rec."Feature Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the feature name.';
                }
                field("Feature Description"; Rec."Feature Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the feature description.';
                }
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the feature is enabled.';
                }
                field("Permission Level"; Rec."Permission Level")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the permission level for this feature.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the quantity limit for this feature (-1 for unlimited).';
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unit of measure for the quantity.';
                }
                field("Custom Metadata"; Rec."Custom Metadata")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies custom metadata for this feature.';
                }
            }
        }
    }
}
