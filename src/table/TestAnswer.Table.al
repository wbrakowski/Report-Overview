table 50103 "Test Answer"
{
    Caption = 'Test Answer';

    fields
    {
        field(1; "Report ID"; Integer)
        {
            Caption = 'Report ID';
            NotBlank = true;
            TableRelation = "Report Test";
        }
        field(2; "Test Questionnaire Code"; Code[20])
        {
            Caption = 'Test Questionnaire Code';
            NotBlank = true;
            TableRelation = "Test Questionnaire Header";
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
            TableRelation = "Test Questionnaire Line"."Line No." WHERE("Test Questionnaire Code" = FIELD("Test Questionnaire Code"),
                                                                           Type = CONST(Answer));

            trigger OnValidate()
            var
                TestQuestnLine: Record "Test Questionnaire Line";
            begin
                TestQuestnLine.Get("Test Questionnaire Code", "Line No.");
                "Answer Priority" := TestQuestnLine.Priority;
            end;
        }
        field(10; Answer; Text[250])
        {
            CalcFormula = Lookup ("Test Questionnaire Line".Description WHERE("Test Questionnaire Code" = FIELD("Test Questionnaire Code"),
                                                                                 "Line No." = FIELD("Line No.")));
            Caption = 'Answer';
            Editable = false;
            FieldClass = FlowField;
        }
        field(20; "Test Questionnaire Priority"; Option)
        {
            Caption = 'Test Questionnaire Priority';
            Editable = false;
            OptionCaption = 'Very Low,Low,Normal,High,Very High';
            OptionMembers = "Very Low",Low,Normal,High,"Very High";
        }
        field(21; "Answer Priority"; Option)
        {
            Caption = 'Answer Priority';
            OptionCaption = 'Very Low (Hidden),Low,Normal,High,Very High';
            OptionMembers = "Very Low (Hidden)",Low,Normal,High,"Very High";
        }
        field(30; "Last Date Updated"; Date)
        {
            Caption = 'Last Date Updated';
        }
        field(50; "Test Questionnaire Value"; Text[250])
        {
            Caption = 'Test Questionnaire Value';
        }
    }

    keys
    {
        key(Key1; "Report ID", "Test Questionnaire Code", "Line No.")
        {
            Clustered = true;
        }
        key(key2; "Test Questionnaire Priority", "Answer Priority")
        {

        }
    }

    trigger OnInsert()
    var
        Contact: Record Contact;
        TestAnswer: Record "Test Answer";
        TestQuestnLine: Record "Test Questionnaire Line";
        TestQuestnLine2: Record "Test Questionnaire Line";
        TestQuestnLine3: Record "Test Questionnaire Line";
    begin
        TestQuestnLine.Get("Test Questionnaire Code", "Line No.");
        TestQuestnLine.TestField(Type, TestQuestnLine.Type::Answer);

    end;

    var
        Text000: Label 'This Question does not allow %1.';

    procedure Question(): Text[250]
    var
        TestQuestnLine: Record "Test Questionnaire Line";
    begin
        if TestQuestnLine.Get("Test Questionnaire Code", QuestionLineNo) then
            exit(TestQuestnLine.Description)
    end;

    local procedure QuestionLineNo(): Integer
    var
        TestQuestnLine: Record "Test Questionnaire Line";
    begin
        with TestQuestnLine do begin
            Reset;
            SetRange("Test Questionnaire Code", Rec."Test Questionnaire Code");
            SetFilter("Line No.", '<%1', Rec."Line No.");
            SetRange(Type, Type::Question);
            if FindLast then
                exit("Line No.")
        end;
    end;
}
