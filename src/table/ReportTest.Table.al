table 50100 "Report Test"
{
    Caption = 'Report Test';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Report ID"; Integer)
        {
            Caption = 'Report ID';
            ToolTip = 'Specifies the ID of the report.';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Report));
        }
        field(10; "Report Caption"; Text[250])
        {
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object Type" = const(Report),
                                                                           "Object ID" = field("Report ID")));
            Caption = 'Report Caption';
            ToolTip = 'Specifies the caption of the report.';
            Editable = false;
            FieldClass = FlowField;
        }
        field(20; "List Page No."; Integer)
        {
            Caption = 'List Page No.';
            ToolTip = 'Specifies the page number of the associated list page.';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Page));
        }
        field(21; "Card Page No."; Integer)
        {
            Caption = 'Card Page No.';
            ToolTip = 'Specifies the page number of the associated card page.';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Page));
        }
        field(30; "Test Information"; Text[250])
        {
            Caption = 'Test Information';
            ToolTip = 'Specifies test information for the report.';
        }
        field(40; "Is Favorite"; Boolean)
        {
            Caption = 'Is Favorite';
            ToolTip = 'Specifies if the report is marked as a favorite.';
        }
        field(50; Category; Enum "Report Category")
        {
            Caption = 'Category';
            ToolTip = 'Specifies the category of the report.';
        }
        field(60; "Is Favorite Filter"; Boolean)
        {
            Caption = 'Is Favorite Filter';
            FieldClass = FlowFilter;
        }
        field(61; "Category Filter"; Enum "Report Category")
        {
            Caption = 'Category Filter';
            FieldClass = FlowFilter;
        }
    }

    keys
    {
        key(PK; "Report ID")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Report ID", "Report Caption")
        {
        }
        fieldgroup(Brick; "Report ID", "Report Caption")
        {
        }
    }
}