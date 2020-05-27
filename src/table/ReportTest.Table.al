table 50100 "Report Test"
{
    DataClassification = ToBeClassified;

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
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Page));
        }
        field(21; "Card Page No."; Integer)
        {
            Caption = 'Card Page No.';
            DataClassification = ToBeClassified;
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Page));
        }

        field(30; "Test Information"; Text[250])
        {
            DataClassification = ToBeClassified;
            Caption = 'Test Information';
        }
    }

    keys
    {
        key(PK; "Report ID")
        {
            Clustered = true;
        }
    }
}