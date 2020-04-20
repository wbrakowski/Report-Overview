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

        field(30; Tested; Boolean)
        {
            Caption = 'Tested';
            DataClassification = ToBeClassified;
        }
        field(40; "Test OK"; Boolean)
        {
            Caption = 'Test OK';
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
        field(80; "Test Information"; Text[250])
        {
            DataClassification = ToBeClassified;
            Caption = 'Test Information';
        }
        field(90; "Test Questionnaire Code"; Code[20])
        {
            Caption = 'Test Questionnaire Code';
            NotBlank = true;
            TableRelation = "Test Questionnaire Header";
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
}