namespace ReportOverview;

using System.Reflection;
using System.Security.AccessControl;

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
        field(70; "Test Status"; Enum "Report Test Status")
        {
            Caption = 'Test Status';
            ToolTip = 'Specifies the result of the last test of the report. Changing it stores the date and the user of the test.';

            trigger OnValidate()
            begin
                UpdateLastTested();
            end;
        }
        field(71; "Last Tested At"; DateTime)
        {
            Caption = 'Last Tested At';
            ToolTip = 'Specifies when the test status was set.';
            Editable = false;
        }
        field(72; "Last Tested By"; Code[50])
        {
            Caption = 'Last Tested By';
            ToolTip = 'Specifies the user who set the test status.';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
            TableRelation = User."User Name";
            ValidateTableRelation = false;
        }
        field(80; "Test Parameters"; Blob)
        {
            Caption = 'Test Parameters';
            ToolTip = 'Specifies the request page values and filters that are used to run the report without request page.';
        }
        field(81; "Has Test Parameters"; Boolean)
        {
            Caption = 'Has Test Parameters';
            ToolTip = 'Specifies if request page values and filters are stored for the report.';
            AllowInCustomizations = AsReadOnly;
            Editable = false;
        }
        field(90; "Report Exists"; Boolean)
        {
            CalcFormula = exist(AllObjWithCaption where("Object Type" = const(Report),
                                                         "Object ID" = field("Report ID")));
            Caption = 'Report Exists';
            ToolTip = 'Specifies if a report with this ID exists in the environment.';
            AllowInCustomizations = AsReadOnly;
            Editable = false;
            FieldClass = FlowField;
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

    procedure SetTestParameters(Parameters: Text)
    var
        ParametersOutStream: OutStream;
    begin
        Clear(Rec."Test Parameters");
        Rec."Has Test Parameters" := Parameters <> '';
        if not Rec."Has Test Parameters" then
            exit;

        Rec."Test Parameters".CreateOutStream(ParametersOutStream, TextEncoding::UTF8);
        ParametersOutStream.WriteText(Parameters);
    end;

    procedure GetTestParameters(): Text
    var
        Parameters: Text;
    begin
        if not Rec."Has Test Parameters" then
            exit('');

        Parameters := ReadTestParameters();
        if Parameters <> '' then
            exit(Parameters);

        // A page record and a record read with Get() come without the Blob content.
        Rec.CalcFields("Test Parameters");
        exit(ReadTestParameters());
    end;

    local procedure ReadTestParameters(): Text
    var
        TypeHelper: Codeunit "Type Helper";
        ParametersInStream: InStream;
    begin
        Rec."Test Parameters".CreateInStream(ParametersInStream, TextEncoding::UTF8);
        exit(TypeHelper.ReadAsTextWithSeparator(ParametersInStream, TypeHelper.LFSeparator()));
    end;

    local procedure UpdateLastTested()
    begin
        if Rec."Test Status" = Rec."Test Status"::" " then begin
            Rec."Last Tested At" := 0DT;
            Rec."Last Tested By" := '';
            exit;
        end;

        Rec."Last Tested At" := CurrentDateTime();
        Rec."Last Tested By" := CopyStr(UserId(), 1, MaxStrLen(Rec."Last Tested By"));
    end;
}