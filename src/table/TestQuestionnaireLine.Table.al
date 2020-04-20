table 50102 "Test Questionnaire Line"
{
    Caption = 'Test Questionnaire Line';
    DataCaptionFields = "Test Questionnaire Code", Description;
    //LookupPageID = "Test Questn. Line List";

    fields
    {
        field(1; "Test Questionnaire Code"; Code[20])
        {
            Caption = 'Profile Questionnaire Code';
            TableRelation = "Test Questionnaire Header";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = 'Question,Answer';
            OptionMembers = Question,Answer;
        }
        field(4; Description; Text[250])
        {
            Caption = 'Description';
            NotBlank = true;
        }
        field(10; Priority; Option)
        {
            Caption = 'Priority';
            InitValue = Normal;
            OptionCaption = 'Very Low (Hidden),Low,Normal,High,Very High';
            OptionMembers = "Very Low (Hidden)",Low,Normal,High,"Very High";

            trigger OnValidate()
            var
                TestAnswer: Record "Test Answer";
            begin
                TestField(Type, Type::Answer);
                TestAnswer.SetCurrentKey("Test Questionnaire Code", "Line No.");
                TestAnswer.SetRange("Test Questionnaire Code", "Test Questionnaire Code");
                TestAnswer.SetRange("Line No.", "Line No.");
                TestAnswer.ModifyAll("Answer Priority", Priority);
                Modify;
            end;
        }
        field(20; "Answer Description"; Text[250])
        {
            Caption = 'Answer Description';
        }
    }

    keys
    {
        key(Key1; "Test Questionnaire Code", "Line No.")
        {
            Clustered = true;
        }
    }


    trigger OnDelete()
    var
        TestQuestionnaireLine: Record "Test Questionnaire Line";
        AnswersExistErr: Label 'You cannot delete this question while answers exists.';
    begin
        if Type = Type::Question then begin
            TestQuestionnaireLine.Get("Test Questionnaire Code", "Line No.");
            if (TestQuestionnaireLine.Next <> 0) and
               (TestQuestionnaireLine.Type = TestQuestionnaireLine.Type::Answer)
            then
                Error(AnswersExistErr);
        end;
    end;

    var
        TestQuestnLine: Record "Test Questionnaire Line";
        TempProfileQuestionnaireLine: Record "Profile Questionnaire Line" temporary;
        ZeroDateFormula: DateFormula;
        Text000: Label 'Do you want to delete the rating values?';
        Text001: Label '%1 cannot be changed until the rating value is deleted.';
        Text002: Label 'You cannot delete this line because one or more questions are depending on it.';
        Text003: Label 'You cannot delete this line because one or more rating values exists.';

        Text005: Label 'Please select for which questionnaire this rating should be created.';
        Text006: Label 'Please describe the rating.';
        Text007: Label 'Please create one or more different answers.';
        Text008: Label 'Please enter which range of points this answer should require.';
        Text009: Label 'High';
        Text010: Label 'Low';

    procedure MoveUp()
    var
        UpperTestQuestnLine: Record "Test Questionnaire Line";
        LineNo: Integer;
        UpperRecLineNo: Integer;
    begin
        TestField(Type, Type::Answer);
        UpperTestQuestnLine.SetRange("Test Questionnaire Code", "Test Questionnaire Code");
        LineNo := "Line No.";
        UpperTestQuestnLine.Get("Test Questionnaire Code", "Line No.");

        if UpperTestQuestnLine.Find('<') and
           (UpperTestQuestnLine.Type = UpperTestQuestnLine.Type::Answer)
        then begin
            UpperRecLineNo := UpperTestQuestnLine."Line No.";
            Rename("Test Questionnaire Code", -1);
            UpperTestQuestnLine.Rename("Test Questionnaire Code", LineNo);
            Rename("Test Questionnaire Code", UpperRecLineNo);
        end;
    end;

    procedure MoveDown()
    var
        LowerTestQuestnLine: Record "Test Questionnaire Line";
        LineNo: Integer;
        LowerRecLineNo: Integer;
    begin
        TestField(Type, Type::Answer);
        LowerTestQuestnLine.SetRange("Test Questionnaire Code", "Test Questionnaire Code");
        LineNo := "Line No.";
        LowerTestQuestnLine.Get("Test Questionnaire Code", "Line No.");

        if LowerTestQuestnLine.Find('>') and
           (LowerTestQuestnLine.Type = LowerTestQuestnLine.Type::Answer)
        then begin
            LowerRecLineNo := LowerTestQuestnLine."Line No.";
            Rename("Test Questionnaire Code", -1);
            LowerTestQuestnLine.Rename("Test Questionnaire Code", LineNo);
            Rename("Test Questionnaire Code", LowerRecLineNo);
        end;
    end;

    procedure Question(): Text[250]
    begin
        TestQuestnLine.Reset();
        TestQuestnLine.SetRange("Test Questionnaire Code", "Test Questionnaire Code");
        TestQuestnLine.SetFilter("Line No.", '<%1', "Line No.");
        TestQuestnLine.SetRange(Type, Type::Question);
        if TestQuestnLine.FindLast then
            exit(TestQuestnLine.Description);
    end;

    procedure FindQuestionLine(): Integer
    begin
        TestQuestnLine.Reset();
        TestQuestnLine.SetRange("Test Questionnaire Code", "Test Questionnaire Code");
        TestQuestnLine.SetFilter("Line No.", '<%1', "Line No.");
        TestQuestnLine.SetRange(Type, Type::Question);
        if TestQuestnLine.FindLast then
            exit(TestQuestnLine."Line No.");
    end;

    local procedure CreateAnswer(AnswerDescription: Text[250])
    begin
        TempProfileQuestionnaireLine.Init();
        TempProfileQuestionnaireLine."Line No." := (TempProfileQuestionnaireLine.Count + 1) * 10000;
        TempProfileQuestionnaireLine.Type := TempProfileQuestionnaireLine.Type::Answer;
        TempProfileQuestionnaireLine.Description := AnswerDescription;
        TempProfileQuestionnaireLine.Insert();
    end;

    procedure NoOfProfileAnswers(): Decimal
    begin
        exit(TempProfileQuestionnaireLine.Count);
    end;

    procedure GetProfileLineAnswerDesc(): Text[250]
    begin
        TempProfileQuestionnaireLine.SetFilter("Line No.", '%1..');
        TempProfileQuestionnaireLine.Find('-');
        exit(TempProfileQuestionnaireLine.Description);
    end;

    procedure GetAnswers(var ProfileQuestionnaireLine: Record "Profile Questionnaire Line")
    begin
        TempProfileQuestionnaireLine.Reset();
        ProfileQuestionnaireLine.Reset();
        ProfileQuestionnaireLine.DeleteAll();
        if TempProfileQuestionnaireLine.Find('-') then
            repeat
                ProfileQuestionnaireLine.Init();
                ProfileQuestionnaireLine := TempProfileQuestionnaireLine;
                ProfileQuestionnaireLine.Insert();
            until TempProfileQuestionnaireLine.Next = 0;
    end;
}
