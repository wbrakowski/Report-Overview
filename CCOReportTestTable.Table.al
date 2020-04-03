table 50100 "CCO Report Test Table"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Report ID"; Integer)
        {
            Caption = 'Report ID';
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Report));
        }
        field(10; Usage; Enum "Report Selection Usage")
        {
            Caption = 'Usage';
        }
        field(12; "Report Caption"; Text[250])
        {
            CalcFormula = Lookup (AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Report),
                                                                           "Object ID" = FIELD("Report ID")));
            Caption = 'Report Caption';
            Editable = false;
            FieldClass = FlowField;
        }
        field(20; "In Report Selection"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(30; "Page No."; Integer)
        {
            Caption = 'Page No.';
            DataClassification = ToBeClassified;
        }
        field(40; Tested; Boolean)
        {
            Caption = 'Tested';
            DataClassification = ToBeClassified;
        }
        field(41; "Test OK"; Boolean)
        {
            Caption = 'Test OK';
            DataClassification = ToBeClassified;
        }
        field(51; "Attachment No."; Integer)
        {
            Caption = 'Attachment No.';
            DataClassification = ToBeClassified;
        }
        field(52; "Attachment Upload at"; DateTime)
        {
            Caption = 'Attachment Upload at';
            DataClassification = ToBeClassified;
        }


    }

    keys
    {
        key(PK; "Report ID")
        {
            Clustered = true;
        }
    }

    procedure FillTable()
    var
        CCOReportTestTable: Record "CCO Report Test Table";
        ReportSelections: Record "Report Selections";
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        CCOReportTestTable.SetRange("In Report Selection", true);
        CCOReportTestTable.SetRange(Tested, false);
        CCOReportTestTable.DeleteAll();

        ReportSelections.SetFilter(Usage, '%1 | %2 | %3 | %4 | %5 | %6 | %7',
                            Usage::"P.Order",
                            Usage::"S.Order",
                            Usage::"Pro Forma S. Invoice",
                            Usage::"S.Cr.Memo",
                            Usage::"S.Invoice",
                            Usage::"S.Shipment",
                            Usage::"S.Quote");
        if ReportSelections.FindSet() then
            repeat
                if not CCOReportTestTable.Get(ReportSelections."Report ID") then begin
                    CCOReportTestTable.Init();
                    CCOReportTestTable.Usage := ReportSelections.Usage;
                    CCOReportTestTable."Report ID" := ReportSelections."Report ID";
                    CCOReportTestTable."Page No." := GetPageNo(ReportSelections.Usage);
                    CCOReportTestTable."In Report Selection" := true;
                    CCOReportTestTable.Insert();
                end;
            until ReportSelections.Next() = 0;

        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Report);
        AllObjWithCaption.SetRange("Object ID", 50000, 100000);
        if AllObjWithCaption.FindSet() then
            repeat
                if not CCOReportTestTable.Get(AllObjWithCaption."Object ID") then begin
                    CCOReportTestTable.Init();
                    CCOReportTestTable."Report ID" := AllObjWithCaption."Object ID";
                    CCOReportTestTable.Insert();
                end;
            until AllObjWithCaption.Next() = 0;

    end;

    procedure GetPageNo(Usage: Integer): Integer;
    var
        PurchaseHeader: Record "Purchase Header";
        PageNo: Integer;
    begin
        case Usage of
            Rec.Usage::"P.Order":
                PageNo := Page::"Purchase Order List";
            Rec.Usage::"S.Order":
                PageNo := Page::"Sales Order List";
            Rec.Usage::"Pro Forma S. Invoice":
                PageNo := Page::"Sales Order List";
            Rec.Usage::"S.Cr.Memo":
                PageNo := Page::"Sales Credit Memos";
            Rec.Usage::"S.Invoice":
                PageNo := Page::"Sales Invoice List";
            Rec.Usage::"S.Shipment":
                PageNo := Page::"Posted Sales Shipments";
            Rec.Usage::"S.Quote":
                PageNo := Page::"Sales Quotes";
        end;
        exit(PageNo);
    end;

    procedure TestFileUploaded(): Boolean
    begin
        exit("Attachment No." <> 0);
    end;

    procedure UploadAttachment()
    var
        CCOFileAttachmentHandling: Codeunit "CCO File Attachment Handling";
        AttachmentNo: Integer;
    begin
        AttachmentNo := CCOFileAttachmentHandling.UploadAttachment();
        if AttachmentNo <> 0 then begin
            "Attachment No." := AttachmentNo;
            "Attachment Upload at" := CurrentDateTime();
            Modify();
        end;
    end;

    procedure OpenAttachment()
    var
        CCOFileAttachmentHandling: Codeunit "CCO File Attachment Handling";
    begin
        if "Attachment No." <> 0 then
            CCOFileAttachmentHandling.OpenAttachment("Attachment No.");
    end;

}