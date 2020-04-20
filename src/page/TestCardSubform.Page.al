page 50105 "Test Card Subform"
{
    Caption = 'Lines';
    Editable = false;
    LinksAllowed = false;
    PageType = ListPart;
    SourceTable = "Test Answer";
    SourceTableView = SORTING("Report ID", "Answer Priority", "Test Questionnaire Priority")
                      ORDER(Descending)
                      WHERE("Answer Priority" = FILTER(<> "Very Low (Hidden)"));

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Answer Priority"; "Answer Priority")
                {
                    ApplicationArea = RelationshipMgmt;
                    ToolTip = 'Specifies the priority of the Test answer. There are five options:';
                    Visible = false;
                }
                field("Test Questionnaire Priority"; "Test Questionnaire Priority")
                {
                    ApplicationArea = RelationshipMgmt;
                    ToolTip = 'Specifies the priority of the questionnaire that the Test answer is linked to. There are five options: Very Low, Low, Normal, High, and Very High.';
                    Visible = false;
                }
                field(Question; Question)
                {
                    ApplicationArea = RelationshipMgmt;
                    Caption = 'Question';
                    ToolTip = 'Specifies the question in the Test questionnaire.';
                }
                field(Answer; Answer)
                {
                    ApplicationArea = RelationshipMgmt;
                    DrillDown = false;
                    ToolTip = 'Specifies your contact''s answer to the question.';
                }
                field("Last Date Updated"; "Last Date Updated")
                {
                    ApplicationArea = RelationshipMgmt;
                    ToolTip = 'Specifies the date when the contact Test answer was last updated. This field shows the first date when the questions used to rate this contact has been given points.';
                }
            }
        }
    }

    actions
    {
    }

    var
        Text001: Label 'There are no answer values for this rating answer.';
        Text002: Label 'This answer reflects the state of the contact on %1 when the Update Contact Class. batch job was run.\To make the answer reflect the current state of the contact, run the batch job again.';
}

