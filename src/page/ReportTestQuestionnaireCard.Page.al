page 50103 "Report Test Questionnaire Card"
{
    AutoSplitKey = true;
    Caption = 'Test Questionnaire Card';
    DataCaptionExpression = CaptionExpr;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Print/Send,Line';
    SaveValues = true;
    SourceTable = "Report Test Questionnaire Line";

    layout
    {
        area(content)
        {
            field(TestQuestionnaireCodeName; CurrentQuestionsChecklistCode)
            {
                ApplicationArea = RelationshipMgmt;
                Caption = 'Test Questionnaire Code';
                ToolTip = 'Specifies the Test questionnaire.';

                trigger OnLookup(var Text: Text): Boolean
                begin
                    CurrPage.SaveRecord;
                    Commit();
                    if PAGE.RunModal(0, TestQuestnHeader) = ACTION::LookupOK then begin
                        TestQuestnHeader.Get(TestQuestnHeader.Code);
                        CurrentQuestionsChecklistCode := TestQuestnHeader.Code;
                        CurrPage.Update(false);
                    end;
                end;

                trigger OnValidate()
                begin
                    TestQuestnHeader.Get(CurrentQuestionsChecklistCode);
                end;
            }
            repeater(Control1)
            {
                IndentationControls = Description;
                ShowCaption = false;
                field(Type; Type)
                {
                    ApplicationArea = All;
                    Style = Strong;
                    Editable = false;
                    ToolTip = 'Specifies whether the entry is a question or an answer.';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    Style = Strong;
                    ToolTip = 'Specifies the Test question or answer.';
                }
                field(Priority; Priority)
                {
                    ApplicationArea = RelationshipMgmt;
                    ToolTip = 'Specifies the priority you give to the answer and where it should be displayed on the lines of the Test Card. There are five options:';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action("Move &Up")
                {
                    ApplicationArea = RelationshipMgmt;
                    Caption = 'Move &Up';
                    Image = MoveUp;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    Scope = Repeater;
                    ToolTip = 'Change the sorting order of the lines.';

                    trigger OnAction()
                    begin
                        MoveUp;
                    end;
                }
                action("Move &Down")
                {
                    ApplicationArea = RelationshipMgmt;
                    Caption = 'Move &Down';
                    Image = MoveDown;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    Scope = Repeater;
                    ToolTip = 'Change the sorting order of the lines.';

                    trigger OnAction()
                    begin
                        MoveDown
                    end;
                }
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        "Test Questionnaire Code" := CurrentQuestionsChecklistCode;
        Type := Type::Question;
    end;

    trigger OnOpenPage()
    var
        TestQuestionnaireHeader: Record "Report Test Questionnaire Hdr.";
    begin
        if GetFilter("Test Questionnaire Code") <> '' then begin
            TestQuestionnaireHeader.SetFilter(Code, GetFilter("Test Questionnaire Code"));
            if TestQuestionnaireHeader.Count = 1 then begin
                TestQuestionnaireHeader.FindFirst;
                CurrentQuestionsChecklistCode := TestQuestionnaireHeader.Code;
            end;
        end;

        CaptionExpr := "Test Questionnaire Code";
    end;

    var
        TestQuestnHeader: Record "Report Test Questionnaire Hdr.";
        CurrentQuestionsChecklistCode: Code[20];
        CaptionExpr: Text[100];

}

