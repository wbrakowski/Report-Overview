page 50104 "Report Test Questionnaires"
{
    ApplicationArea = RelationshipMgmt;
    Caption = 'Test Questionnaires Setup';
    PageType = List;
    SourceTable = "Report Test Questionnaire Hdr.";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code of the Test questionnaire.';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description of the Test questionnaire.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Edit Questionnaire Setup")
            {
                ApplicationArea = RelationshipMgmt;
                Caption = 'Edit Questionnaire Setup';
                Ellipsis = true;
                Image = Setup;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "Report Test Questionnaire Card";
                RunPageLink = "Test Questionnaire Code" = FIELD(Code);
                ShortCutKey = 'Return';
                ToolTip = 'Modify how the questionnaire is set up.';
            }
        }
    }
}
