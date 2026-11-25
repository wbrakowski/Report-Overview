namespace ReportOverview;

using Microsoft.Foundation.Reporting;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Sales.Document;
using Microsoft.Sales.FinanceCharge;
using Microsoft.Sales.History;
using Microsoft.Sales.Reminder;
using Microsoft.Service.Document;
using Microsoft.Service.History;
using Microsoft.Shared.Report;
using System.Environment.Configuration;
using System.Reflection;
using System.Utilities;

codeunit 50100 "Report Overview Mgt."
{
    Permissions = tabledata "Report Test" = rimd;

    var
        ReportDoesNotExistErr: Label 'Report %1 does not exist.', Comment = '%1 = report ID';
        NoOutputErr: Label 'Report %1 only processes data and has no output to download.', Comment = '%1 = report ID';
        NoRequestPageErr: Label 'Report %1 has no request page, so there are no test parameters to store.', Comment = '%1 = report ID';
        RemoveMissingReportsQst: Label 'Do you want to remove %1 entries whose report no longer exists?', Comment = '%1 = number of entries';
        NoMissingReportsMsg: Label 'Every entry belongs to an existing report.';
        DownloadInstructionLbl: Label 'Download the report as';
        DownloadTitleLbl: Label 'Download Report';
        DownloadFormatsTok: Label 'PDF,Word,Excel', Locked = true;
        DownloadFileNameTok: Label '%1 %2.%3', Locked = true;

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

    procedure ReportExists(ReportID: Integer): Boolean
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Report);
        AllObjWithCaption.SetRange("Object ID", ReportID);
        exit(not AllObjWithCaption.IsEmpty());
    end;

    procedure CheckReportExists(ReportID: Integer)
    begin
        if ReportID = 0 then
            exit;

        if not ReportExists(ReportID) then
            Error(ReportDoesNotExistErr, ReportID);
    end;

    procedure RunReport(var ReportTest: Record "Report Test")
    var
        Parameters: Text;
    begin
        if ReportTest."Report ID" = 0 then
            exit;

        Parameters := ReportTest.GetTestParameters();
        if Parameters = '' then
            Report.RunModal(ReportTest."Report ID")
        else
            Report.Execute(ReportTest."Report ID", Parameters);
    end;

    procedure SetTestParameters(var ReportTest: Record "Report Test")
    var
        Parameters: Text;
    begin
        if ReportTest."Report ID" = 0 then
            exit;

        if not HasRequestPage(ReportTest."Report ID") then
            Error(NoRequestPageErr, ReportTest."Report ID");

        Parameters := Report.RunRequestPage(ReportTest."Report ID", ReportTest.GetTestParameters());
        if Parameters = '' then
            exit;

        ReportTest.SetTestParameters(Parameters);
        ReportTest.Modify(true);
    end;

    procedure ClearTestParameters(var ReportTest: Record "Report Test")
    begin
        if not ReportTest."Has Test Parameters" then
            exit;

        ReportTest.SetTestParameters('');
        ReportTest.Modify(true);
    end;

    procedure DownloadReport(var ReportTest: Record "Report Test")
    var
        TempBlob: Codeunit "Temp Blob";
        ReportInStream: InStream;
        FileName: Text;
        Parameters: Text;
        Selection: Integer;
    begin
        if ReportTest."Report ID" = 0 then
            exit;

        CheckHasOutput(ReportTest."Report ID");
        Selection := StrMenu(DownloadFormatsTok, 1, DownloadInstructionLbl);
        if Selection = 0 then
            exit;

        if not GetParametersForDownload(ReportTest, Parameters) then
            exit;

        SaveReportToBlob(ReportTest."Report ID", Parameters, GetReportFormat(Selection), TempBlob);
        TempBlob.CreateInStream(ReportInStream);
        FileName := GetDownloadFileName(ReportTest."Report ID", Selection);
        DownloadFromStream(ReportInStream, DownloadTitleLbl, '', '', FileName);
    end;

    procedure SaveReportToBlob(ReportID: Integer; Parameters: Text; OutputFormat: ReportFormat; var TempBlob: Codeunit "Temp Blob")
    var
        ReportOutStream: OutStream;
    begin
        CheckHasOutput(ReportID);
        TempBlob.CreateOutStream(ReportOutStream);
        Report.SaveAs(ReportID, Parameters, OutputFormat, ReportOutStream);
    end;

    procedure GetDownloadFileName(ReportID: Integer; Selection: Integer): Text
    var
        ReportName: Text;
    begin
        ReportName := DelChr(GetCustomReportCaption(ReportID), '=', '\/:*?"<>|');
        exit(StrSubstNo(DownloadFileNameTok, ReportName, ReportID, GetFileExtension(Selection)));
    end;

    local procedure GetParametersForDownload(var ReportTest: Record "Report Test"; var Parameters: Text): Boolean
    begin
        Parameters := ReportTest.GetTestParameters();
        if Parameters <> '' then
            exit(true);

        if not HasRequestPage(ReportTest."Report ID") then
            exit(true);

        Parameters := Report.RunRequestPage(ReportTest."Report ID");
        exit(Parameters <> '');
    end;

    local procedure GetReportFormat(Selection: Integer): ReportFormat
    begin
        case Selection of
            2:
                exit(ReportFormat::Word);
            3:
                exit(ReportFormat::Excel);
        end;
        exit(ReportFormat::Pdf);
    end;

    local procedure GetFileExtension(Selection: Integer): Text
    begin
        case Selection of
            2:
                exit('docx');
            3:
                exit('xlsx');
        end;
        exit('pdf');
    end;

    local procedure CheckHasOutput(ReportID: Integer)
    var
        ReportMetadata: Record "Report Metadata";
    begin
        if not ReportMetadata.Get(ReportID) then
            Error(ReportDoesNotExistErr, ReportID);

        if ReportMetadata.ProcessingOnly then
            Error(NoOutputErr, ReportID);
    end;

    local procedure HasRequestPage(ReportID: Integer): Boolean
    var
        ReportMetadata: Record "Report Metadata";
    begin
        if not ReportMetadata.Get(ReportID) then
            Error(ReportDoesNotExistErr, ReportID);

        exit(ReportMetadata.UseRequestPage);
    end;

    procedure OpenReportLayouts(ReportID: Integer)
    var
        ReportLayoutList: Record "Report Layout List";
    begin
        ReportLayoutList.SetRange("Report ID", ReportID);
        Page.Run(Page::"Report Layouts", ReportLayoutList);
    end;

    // Same rule as the Default column of the standard page Report Layouts: selection of the company, else the default of the report.
    procedure GetCurrentLayoutName(ReportID: Integer): Text[250]
    var
        ReportMetadata: Record "Report Metadata";
        TenantReportLayoutSelection: Record "Tenant Report Layout Selection";
        EmptyGuid: Guid;
    begin
        if ReportID = 0 then
            exit('');

        if TenantReportLayoutSelection.Get(ReportID, CompanyName(), EmptyGuid) then
            exit(TenantReportLayoutSelection."Layout Name");

        if ReportMetadata.Get(ReportID) then
            exit(ReportMetadata.DefaultLayoutName);

        exit('');
    end;

    procedure RemoveMissingReports()
    var
        ConfirmManagement: Codeunit "Confirm Management";
        MissingReportIds: List of [Integer];
    begin
        FindMissingReports(MissingReportIds);
        if MissingReportIds.Count() = 0 then begin
            Message(NoMissingReportsMsg);
            exit;
        end;

        if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(RemoveMissingReportsQst, MissingReportIds.Count()), false) then
            exit;

        DeleteMissingReports();
    end;

    procedure DeleteMissingReports(): Integer
    var
        ReportTest: Record "Report Test";
        MissingReportIds: List of [Integer];
        ReportID: Integer;
    begin
        FindMissingReports(MissingReportIds);
        foreach ReportID in MissingReportIds do
            if ReportTest.Get(ReportID) then
                ReportTest.Delete(false);

        exit(MissingReportIds.Count());
    end;

    local procedure FindMissingReports(var MissingReportIds: List of [Integer])
    var
        ReportTest: Record "Report Test";
    begin
        ReportTest.SetRange("Report Exists", false);
        ReportTest.SetLoadFields("Report ID");
        if ReportTest.FindSet() then
            repeat
                MissingReportIds.Add(ReportTest."Report ID");
            until ReportTest.Next() = 0;
    end;

    procedure GetLineStyle(ReportTest: Record "Report Test"): Text
    begin
        if not ReportExists(ReportTest."Report ID") then
            exit(Format(PageStyle::Subordinate));

        if ReportTest."Is Favorite" then
            exit(Format(PageStyle::Attention));

        exit(Format(PageStyle::None));
    end;

    procedure GetTestStatusStyle(TestStatus: Enum "Report Test Status"): Text
    begin
        case TestStatus of
            TestStatus::Passed:
                exit(Format(PageStyle::Favorable));
            TestStatus::Failed:
                exit(Format(PageStyle::Unfavorable));
        end;
        exit(Format(PageStyle::None));
    end;

    procedure GetListPageNo(Usage: Enum "Report Selection Usage"): Integer
    var
        PageNo: Integer;
    begin
        PageNo := GetPurchaseListPageNo(Usage);
        if PageNo <> 0 then
            exit(PageNo);

        PageNo := GetSalesListPageNo(Usage);
        if PageNo <> 0 then
            exit(PageNo);

        PageNo := GetServiceListPageNo(Usage);
        if PageNo <> 0 then
            exit(PageNo);

        exit(GetReminderListPageNo(Usage));
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
            ReportSelections.Usage::"P.Receipt":
                exit(Page::"Posted Purchase Receipts");
            ReportSelections.Usage::"P.Ret.Shpt.":
                exit(Page::"Posted Return Shipments");
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

    local procedure GetServiceListPageNo(Usage: Enum "Report Selection Usage"): Integer
    var
        ReportSelections: Record "Report Selections";
    begin
        case Usage of
            ReportSelections.Usage::"SM.Quote":
                exit(Page::"Service Quotes");
            ReportSelections.Usage::"SM.Order":
                exit(Page::"Service Orders");
            ReportSelections.Usage::"SM.Invoice":
                exit(Page::"Posted Service Invoices");
            ReportSelections.Usage::"SM.Credit Memo":
                exit(Page::"Posted Service Credit Memos");
            ReportSelections.Usage::"SM.Shipment":
                exit(Page::"Posted Service Shipments");
        end;
        exit(0);
    end;

    local procedure GetReminderListPageNo(Usage: Enum "Report Selection Usage"): Integer
    var
        ReportSelections: Record "Report Selections";
    begin
        case Usage of
            ReportSelections.Usage::Reminder:
                exit(Page::"Issued Reminder List");
            ReportSelections.Usage::"Fin.Charge":
                exit(Page::"Issued Fin. Charge Memo List");
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
        if PageNo <> 0 then
            exit(PageNo);

        PageNo := GetServiceCardPageNo(Usage);
        if PageNo <> 0 then
            exit(PageNo);

        exit(GetReminderCardPageNo(Usage));
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
            ReportSelections.Usage::"P.Receipt":
                exit(Page::"Posted Purchase Receipt");
            ReportSelections.Usage::"P.Ret.Shpt.":
                exit(Page::"Posted Return Shipment");
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

    local procedure GetServiceCardPageNo(Usage: Enum "Report Selection Usage"): Integer
    var
        ReportSelections: Record "Report Selections";
    begin
        case Usage of
            ReportSelections.Usage::"SM.Quote":
                exit(Page::"Service Quote");
            ReportSelections.Usage::"SM.Order":
                exit(Page::"Service Order");
            ReportSelections.Usage::"SM.Invoice":
                exit(Page::"Posted Service Invoice");
            ReportSelections.Usage::"SM.Credit Memo":
                exit(Page::"Posted Service Credit Memo");
            ReportSelections.Usage::"SM.Shipment":
                exit(Page::"Posted Service Shipment");
        end;
        exit(0);
    end;

    local procedure GetReminderCardPageNo(Usage: Enum "Report Selection Usage"): Integer
    var
        ReportSelections: Record "Report Selections";
    begin
        case Usage of
            ReportSelections.Usage::Reminder:
                exit(Page::"Issued Reminder");
            ReportSelections.Usage::"Fin.Charge":
                exit(Page::"Issued Finance Charge Memo");
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