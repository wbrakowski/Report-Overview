table 50100 "Report Test"
{
    DataClassification = ToBeClassified;
    LookupPageId = "Report Test Card";
    DrillDownPageId = "Report Test Card";

    fields
    {
        field(1; "Report ID"; Integer)
        {
            Caption = 'Report ID';
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Report));
        }
        field(10; "Report Caption"; Text[250])
        {
            CalcFormula = Lookup (AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Report),
                                                                           "Object ID" = FIELD("Report ID")));
            Caption = 'Report Caption';
            Editable = false;
            FieldClass = FlowField;
        }
        field(20; "List Page No."; Integer)
        {
            Caption = 'List Page No.';
            DataClassification = ToBeClassified;
        }
        field(21; "Card Page No."; Integer)
        {
            Caption = 'Card Page No.';
            DataClassification = ToBeClassified;
        }


        field(50; "Attachment No."; Integer)
        {
            Caption = 'Attachment No.';
            DataClassification = ToBeClassified;
        }
        field(51; "Attachment Upload at"; DateTime)
        {
            Caption = 'Attachment Upload at';
            DataClassification = ToBeClassified;
        }
        field(60; "Company Name"; Text[50])
        {
            Caption = 'Company Name';
            DataClassification = ToBeClassified;
        }

        field(70; "Test Filter 1"; Text[50])
        {
            Caption = 'Test Filter 1';
            TableRelation = "Object Options" where("Object Type" = filter(Report), "Object ID" = field("Report ID"), "Company Name" = field("Company Name"));
        }
        field(71; "Test Filter 2"; Text[50])
        {
            Caption = 'Test Filter 2';
            TableRelation = "Object Options" where("Object Type" = filter(Report), "Object ID" = field("Report ID"), "Company Name" = field("Company Name"));
        }
        field(72; "Test Filter 3"; Text[50])
        {
            Caption = 'Test Filter 3';
            TableRelation = "Object Options" where("Object Type" = filter(Report), "Object ID" = field("Report ID"), "Company Name" = field("Company Name"));
        }
        field(73; "Test Information"; Text[250])
        {
            DataClassification = ToBeClassified;
            Caption = 'Test Information';
        }
        field(74; Tested; Boolean)
        {
            Caption = 'Tested';
            DataClassification = ToBeClassified;
        }
        field(75; "Test OK"; Boolean)
        {
            Caption = 'Test OK';
            DataClassification = ToBeClassified;
        }
        field(80; "Test Questionnaire Code"; Code[20])
        {
            Caption = 'Test Questionnaire Code';
            NotBlank = true;
            TableRelation = "Report Test Questionnaire Hdr.";
            trigger OnValidate();
            begin
                ValidateTestQuestionnaireCode();
            end;
        }
    }

    keys
    {
        key(PK; "Report ID")
        {
            Clustered = true;
        }
    }

    procedure TestFileUploaded(): Boolean
    begin
        exit("Attachment No." <> 0);
    end;

    local procedure ValidateTestQuestionnaireCode()
    var
        QuestionLine: Record "Report Test Questionnaire Line";
        ReportTestAnswer: Record "Report Test Answer";
    begin
        QuestionLine.SetRange("Test Questionnaire Code", Rec."Test Questionnaire Code");
        QuestionLine.SetRange(Type, QuestionLine.Type::Question);
        if QuestionLine.FindSet() then
            repeat
                ReportTestAnswer.Init();
                ReportTestAnswer."Test Questionnaire Code" := QuestionLine."Test Questionnaire Code";
                ReportTestAnswer."Report ID" := Rec."Report ID";
                ReportTestAnswer."Line No." := QuestionLine."Line No.";
                ReportTestAnswer.Insert();
            until QuestionLine.Next() = 0;
    end;


}