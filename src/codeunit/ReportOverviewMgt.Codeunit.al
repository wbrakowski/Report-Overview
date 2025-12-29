codeunit 50100 "Report Overview Mgt."
{
    Permissions = tabledata "Report Test" = ri;

    procedure OpenReportSettings(ReportID: Integer)
    var
        ObjectOptions: Record "Object Options";
    begin
        ObjectOptions.SetRange("Object ID", ReportID);
        ObjectOptions.SetRange("Object Type", ObjectOptions."Object Type"::Report);
        ObjectOptions.SetRange("Company Name", CompanyName());
        ObjectOptions.SetRange("User Name", UserId());
        Page.Run(Page::"Report Settings", ObjectOptions);
    end;

    procedure FillTestTable()
    var
        AllObjWithCaption: Record AllObjWithCaption;
        ReportTest: Record "Report Test";
    begin
        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Report);
        AllObjWithCaption.SetRange("Object ID", 50000, 100000);
        if AllObjWithCaption.FindSet() then
            repeat
                if not ReportTest.Get(AllObjWithCaption."Object ID") then begin
                    ReportTest.Init();
                    ReportTest."Report ID" := AllObjWithCaption."Object ID";
                    ReportTest.Insert(false);
                end;
            until AllObjWithCaption.Next() = 0;
    end;

    procedure GetListPageNo(Usage: Enum "Report Selection Usage"): Integer
    var
        PageNo: Integer;
    begin
        PageNo := GetPurchaseListPageNo(Usage);
        if PageNo <> 0 then
            exit(PageNo);

        PageNo := GetSalesListPageNo(Usage);
        exit(PageNo);
    end;

    local procedure GetPurchaseListPageNo(Usage: Enum "Report Selection Usage"): Integer
    var
        ReportSelections: Record "Report Selections";
    begin
        case Usage of
            ReportSelections.Usage::"P.Quote":
                exit(Page::"Purchase Quotes");
            ReportSelections.Usage::"P.Order":
                exit(Page::"Purchase Order List");
            ReportSelections.Usage::"P.Invoice":
                exit(Page::"Purchase Invoices");
            ReportSelections.Usage::"P.Cr.Memo":
                exit(Page::"Purchase Credit Memos");
        end;
        exit(0);
    end;

    local procedure GetSalesListPageNo(Usage: Enum "Report Selection Usage"): Integer
    var
        ReportSelections: Record "Report Selections";
    begin
        case Usage of
            ReportSelections.Usage::"S.Order":
                exit(Page::"Sales Order List");
            ReportSelections.Usage::"Pro Forma S. Invoice":
                exit(Page::"Sales Order List");
            ReportSelections.Usage::"S.Cr.Memo":
                exit(Page::"Sales Credit Memos");
            ReportSelections.Usage::"S.Invoice":
                exit(Page::"Sales Invoice List");
            ReportSelections.Usage::"S.Shipment":
                exit(Page::"Posted Sales Shipments");
            ReportSelections.Usage::"S.Quote":
                exit(Page::"Sales Quotes");
        end;
        exit(0);
    end;

    procedure GetCardPageNo(Usage: Enum "Report Selection Usage"): Integer
    var
        PageNo: Integer;
    begin
        PageNo := GetPurchaseCardPageNo(Usage);
        if PageNo <> 0 then
            exit(PageNo);

        PageNo := GetSalesCardPageNo(Usage);
        exit(PageNo);
    end;

    local procedure GetPurchaseCardPageNo(Usage: Enum "Report Selection Usage"): Integer
    var
        ReportSelections: Record "Report Selections";
    begin
        case Usage of
            ReportSelections.Usage::"P.Quote":
                exit(Page::"Purchase Quote");
            ReportSelections.Usage::"P.Order":
                exit(Page::"Purchase Order");
            ReportSelections.Usage::"P.Invoice":
                exit(Page::"Purchase Invoice");
            ReportSelections.Usage::"P.Cr.Memo":
                exit(Page::"Purchase Credit Memo");
        end;
        exit(0);
    end;

    local procedure GetSalesCardPageNo(Usage: Enum "Report Selection Usage"): Integer
    var
        ReportSelections: Record "Report Selections";
    begin
        case Usage of
            ReportSelections.Usage::"S.Quote":
                exit(Page::"Sales Quote");
            ReportSelections.Usage::"S.Order":
                exit(Page::"Sales Order");
            ReportSelections.Usage::"S.Shipment":
                exit(Page::"Posted Sales Shipment");
            ReportSelections.Usage::"Pro Forma S. Invoice":
                exit(Page::"Sales Order");
            ReportSelections.Usage::"S.Invoice":
                exit(Page::"Sales Invoice");
            ReportSelections.Usage::"S.Cr.Memo":
                exit(Page::"Sales Credit Memo");
        end;
        exit(0);
    end;

    procedure GetCustomReportCaption(ReportNo: Integer): Text[249]
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        if AllObjWithCaption.Get(AllObjWithCaption."Object Type"::Report, ReportNo) then
            exit(AllObjWithCaption."Object Caption")
        else
            exit('');
    end;
}