page 50104 "Test Questionnaires"
{
    ApplicationArea = RelationshipMgmt;
    Caption = 'Test Questionnaires Setup';
    PageType = List;
    SourceTable = "Test Questionnaire Header";
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
                RunObject = Page "Test Questionnaire Card";
                RunPageLink = "Test Questionnaire Code" = FIELD(Code);
                ShortCutKey = 'Return';
                ToolTip = 'Modify how the questionnaire is set up.';
            }
        }
    }
}
