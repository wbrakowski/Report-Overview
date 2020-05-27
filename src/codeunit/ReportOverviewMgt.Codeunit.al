codeunit 50100 "Report Overview Mgt."
{
    procedure OpenReportSettings(ReportID: Integer)
    var
        ObjectOptions: Record "Object Options";
    begin
        with ObjectOptions do begin
            SetRange("Object ID", ReportID);
            SetRange("Object Type", "Object Type"::Report);
            SetRange("Company Name", CompanyName);
            SetRange("User Name", UserId);
        end;
        Page.Run(Page::"Report Settings", ObjectOptions);
    end;

    procedure FillTestTable()
    var
        ReportTest: Record "Report Test";
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        with AllObjWithCaption do begin
            SetRange("Object Type", "Object Type"::Report);
            SetRange("Object ID", 50000, 100000);
            if FindSet() then
                repeat
                    if not ReportTest.Get("Object ID") then begin
                        ReportTest.Init();
                        ReportTest."Report ID" := "Object ID";
                        ReportTest.Insert();
                    end;
                until Next() = 0;
        end;
    end;

    procedure GetListPageNo(Usage: Enum "Report Selection Usage"): Integer;
    var
        PurchaseHeader: Record "Purchase Header";
        ReportSelections: Record "Report Selections";
        PageNo: Integer;
    begin
        case Usage of
            ReportSelections.Usage::"P.Quote":
                PageNo := Page::"Purchase Quotes";
            ReportSelections.Usage::"P.Order":
                PageNo := Page::"Purchase Order List";
            ReportSelections.Usage::"P.Invoice":
                PageNo := Page::"Purchase Invoices";
            ReportSelections.Usage::"P.Cr.Memo":
                PageNo := Page::"Purchase Credit Memos";
            ReportSelections.Usage::"S.Order":
                PageNo := Page::"Sales Order List";
            ReportSelections.Usage::"Pro Forma S. Invoice":
                PageNo := Page::"Sales Order List";
            ReportSelections.Usage::"S.Cr.Memo":
                PageNo := Page::"Sales Credit Memos";
            ReportSelections.Usage::"S.Invoice":
                PageNo := Page::"Sales Invoice List";
            ReportSelections.Usage::"S.Shipment":
                PageNo := Page::"Posted Sales Shipments";
            ReportSelections.Usage::"S.Quote":
                PageNo := Page::"Sales Quotes";
        end;
        exit(PageNo);
    end;

    procedure GetCardPageNo(Usage: Enum "Report Selection Usage"): Integer;
    var
        PurchaseHeader: Record "Purchase Header";
        ReportSelections: Record "Report Selections";
        PageNo: Integer;
    begin
        case Usage of
            ReportSelections.Usage::"P.Quote":
                PageNo := Page::"Purchase Quote";
            ReportSelections.Usage::"P.Order":
                PageNo := Page::"Purchase Order";
            ReportSelections.Usage::"P.Invoice":
                PageNo := Page::"Purchase Invoice";
            ReportSelections.Usage::"P.Cr.Memo":
                PageNo := Page::"Purchase Credit Memo";
            ReportSelections.Usage::"S.Quote":
                PageNo := Page::"Sales Quote";
            ReportSelections.Usage::"S.Order":
                PageNo := Page::"Sales Order";
            ReportSelections.Usage::"S.Shipment":
                PageNo := Page::"Posted Sales Shipment";
            ReportSelections.Usage::"Pro Forma S. Invoice":
                PageNo := Page::"Sales Order";
            ReportSelections.Usage::"S.Invoice":
                PageNo := Page::"Sales Invoice";
            ReportSelections.Usage::"S.Cr.Memo":
                PageNo := Page::"Sales Credit Memo";
        end;
        exit(PageNo);
    end;

    procedure GetCustomReportCaption(ReportNo: Integer): Text[249];
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        with AllObjWithCaption do begin
            if Get("Object Type"::Report, ReportNo) then
                exit("Object Caption")
            else
                exit('');
        end;
    end;


}