table 50101 "Report Test Questionnaire Hdr."
{
    Caption = 'Test Questionnaire Header';
    DataCaptionFields = "Code", Description;
    // DrillDownPageID = "Test Questionnaire List";
    // LookupPageID = "TestProfile Questionnaires";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(10; Description; Text[250])
        {
            Caption = 'Description';
        }
        field(11; "Report ID"; Integer)
        {
            Caption = 'Report ID';
            DataClassification = ToBeClassified;
        }

    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        ProfileQuestnLine.Reset();
        ProfileQuestnLine.SetRange("Profile Questionnaire Code", Code);
        ProfileQuestnLine.DeleteAll(true);
    end;

    var
        ProfileQuestnLine: Record "Profile Questionnaire Line";
}
