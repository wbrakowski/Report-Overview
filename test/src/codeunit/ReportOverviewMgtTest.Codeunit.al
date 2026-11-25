namespace ReportOverview.Test;

using Microsoft.Foundation.Reporting;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Sales.Document;
using Microsoft.Sales.FinanceCharge;
using Microsoft.Sales.History;
using Microsoft.Sales.Reminder;
using Microsoft.Service.Document;
using Microsoft.Service.History;
using ReportOverview;
using System.Environment.Configuration;
using System.Reflection;
using System.TestLibraries.Utilities;
using System.Utilities;

codeunit 50150 "Report Overview Mgt. Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        ReportOverviewMgt: Codeunit "Report Overview Mgt.";
        ReportSettingsObjectIdFilter: Text;
        ReportSettingsObjectTypeFilter: Text;
        ReportSettingsCompanyFilter: Text;
        ReportSettingsUserFilter: Text;

    [Test]
    procedure GetListPageNoReturnsPurchaseListPages()
    begin
        // [SCENARIO] Purchase usages resolve to the purchase document list pages
        Assert.AreEqual(Page::"Purchase Quotes", ReportOverviewMgt.GetListPageNo(Enum::"Report Selection Usage"::"P.Quote"), 'Unexpected list page for P.Quote.');
        Assert.AreEqual(Page::"Purchase Order List", ReportOverviewMgt.GetListPageNo(Enum::"Report Selection Usage"::"P.Order"), 'Unexpected list page for P.Order.');
        Assert.AreEqual(Page::"Purchase Invoices", ReportOverviewMgt.GetListPageNo(Enum::"Report Selection Usage"::"P.Invoice"), 'Unexpected list page for P.Invoice.');
        Assert.AreEqual(Page::"Purchase Credit Memos", ReportOverviewMgt.GetListPageNo(Enum::"Report Selection Usage"::"P.Cr.Memo"), 'Unexpected list page for P.Cr.Memo.');
    end;

    [Test]
    procedure GetListPageNoReturnsSalesListPages()
    begin
        // [SCENARIO] Sales usages resolve to the sales document list pages, pro forma invoices to the order list
        Assert.AreEqual(Page::"Sales Quotes", ReportOverviewMgt.GetListPageNo(Enum::"Report Selection Usage"::"S.Quote"), 'Unexpected list page for S.Quote.');
        Assert.AreEqual(Page::"Sales Order List", ReportOverviewMgt.GetListPageNo(Enum::"Report Selection Usage"::"S.Order"), 'Unexpected list page for S.Order.');
        Assert.AreEqual(Page::"Sales Order List", ReportOverviewMgt.GetListPageNo(Enum::"Report Selection Usage"::"Pro Forma S. Invoice"), 'Unexpected list page for Pro Forma S. Invoice.');
        Assert.AreEqual(Page::"Posted Sales Shipments", ReportOverviewMgt.GetListPageNo(Enum::"Report Selection Usage"::"S.Shipment"), 'Unexpected list page for S.Shipment.');
        Assert.AreEqual(Page::"Sales Invoice List", ReportOverviewMgt.GetListPageNo(Enum::"Report Selection Usage"::"S.Invoice"), 'Unexpected list page for S.Invoice.');
        Assert.AreEqual(Page::"Sales Credit Memos", ReportOverviewMgt.GetListPageNo(Enum::"Report Selection Usage"::"S.Cr.Memo"), 'Unexpected list page for S.Cr.Memo.');
    end;

    [Test]
    procedure GetCardPageNoReturnsPurchaseCardPages()
    begin
        // [SCENARIO] Purchase usages resolve to the purchase document card pages
        Assert.AreEqual(Page::"Purchase Quote", ReportOverviewMgt.GetCardPageNo(Enum::"Report Selection Usage"::"P.Quote"), 'Unexpected card page for P.Quote.');
        Assert.AreEqual(Page::"Purchase Order", ReportOverviewMgt.GetCardPageNo(Enum::"Report Selection Usage"::"P.Order"), 'Unexpected card page for P.Order.');
        Assert.AreEqual(Page::"Purchase Invoice", ReportOverviewMgt.GetCardPageNo(Enum::"Report Selection Usage"::"P.Invoice"), 'Unexpected card page for P.Invoice.');
        Assert.AreEqual(Page::"Purchase Credit Memo", ReportOverviewMgt.GetCardPageNo(Enum::"Report Selection Usage"::"P.Cr.Memo"), 'Unexpected card page for P.Cr.Memo.');
    end;

    [Test]
    procedure GetCardPageNoReturnsSalesCardPages()
    begin
        // [SCENARIO] Sales usages resolve to the sales document card pages, pro forma invoices to the order card
        Assert.AreEqual(Page::"Sales Quote", ReportOverviewMgt.GetCardPageNo(Enum::"Report Selection Usage"::"S.Quote"), 'Unexpected card page for S.Quote.');
        Assert.AreEqual(Page::"Sales Order", ReportOverviewMgt.GetCardPageNo(Enum::"Report Selection Usage"::"S.Order"), 'Unexpected card page for S.Order.');
        Assert.AreEqual(Page::"Sales Order", ReportOverviewMgt.GetCardPageNo(Enum::"Report Selection Usage"::"Pro Forma S. Invoice"), 'Unexpected card page for Pro Forma S. Invoice.');
        Assert.AreEqual(Page::"Posted Sales Shipment", ReportOverviewMgt.GetCardPageNo(Enum::"Report Selection Usage"::"S.Shipment"), 'Unexpected card page for S.Shipment.');
        Assert.AreEqual(Page::"Sales Invoice", ReportOverviewMgt.GetCardPageNo(Enum::"Report Selection Usage"::"S.Invoice"), 'Unexpected card page for S.Invoice.');
        Assert.AreEqual(Page::"Sales Credit Memo", ReportOverviewMgt.GetCardPageNo(Enum::"Report Selection Usage"::"S.Cr.Memo"), 'Unexpected card page for S.Cr.Memo.');
    end;

    [Test]
    procedure PageNoIsZeroForUnsupportedUsage()
    begin
        // [SCENARIO] A usage without a mapped document page resolves to 0
        Assert.AreEqual(0, ReportOverviewMgt.GetListPageNo(Enum::"Report Selection Usage"::"B.Check"), 'Unsupported usage should not have a list page.');
        Assert.AreEqual(0, ReportOverviewMgt.GetCardPageNo(Enum::"Report Selection Usage"::"B.Check"), 'Unsupported usage should not have a card page.');
    end;

    [Test]
    procedure PostedPurchaseUsagesResolveToPostedDocumentPages()
    begin
        // [SCENARIO] Receipts and return shipments resolve to the posted purchase document pages
        Assert.AreEqual(Page::"Posted Purchase Receipts", ReportOverviewMgt.GetListPageNo(Enum::"Report Selection Usage"::"P.Receipt"), 'Unexpected list page for P.Receipt.');
        Assert.AreEqual(Page::"Posted Purchase Receipt", ReportOverviewMgt.GetCardPageNo(Enum::"Report Selection Usage"::"P.Receipt"), 'Unexpected card page for P.Receipt.');
        Assert.AreEqual(Page::"Posted Return Shipments", ReportOverviewMgt.GetListPageNo(Enum::"Report Selection Usage"::"P.Ret.Shpt."), 'Unexpected list page for P.Ret.Shpt.');
        Assert.AreEqual(Page::"Posted Return Shipment", ReportOverviewMgt.GetCardPageNo(Enum::"Report Selection Usage"::"P.Ret.Shpt."), 'Unexpected card page for P.Ret.Shpt.');
    end;

    [Test]
    procedure ServiceUsagesResolveToServiceListPages()
    begin
        // [SCENARIO] Service usages resolve to the service document list pages
        Assert.AreEqual(Page::"Service Quotes", ReportOverviewMgt.GetListPageNo(Enum::"Report Selection Usage"::"SM.Quote"), 'Unexpected list page for SM.Quote.');
        Assert.AreEqual(Page::"Service Orders", ReportOverviewMgt.GetListPageNo(Enum::"Report Selection Usage"::"SM.Order"), 'Unexpected list page for SM.Order.');
        Assert.AreEqual(Page::"Posted Service Invoices", ReportOverviewMgt.GetListPageNo(Enum::"Report Selection Usage"::"SM.Invoice"), 'Unexpected list page for SM.Invoice.');
        Assert.AreEqual(Page::"Posted Service Credit Memos", ReportOverviewMgt.GetListPageNo(Enum::"Report Selection Usage"::"SM.Credit Memo"), 'Unexpected list page for SM.Credit Memo.');
        Assert.AreEqual(Page::"Posted Service Shipments", ReportOverviewMgt.GetListPageNo(Enum::"Report Selection Usage"::"SM.Shipment"), 'Unexpected list page for SM.Shipment.');
    end;

    [Test]
    procedure ServiceUsagesResolveToServiceCardPages()
    begin
        // [SCENARIO] Service usages resolve to the service document card pages
        Assert.AreEqual(Page::"Service Quote", ReportOverviewMgt.GetCardPageNo(Enum::"Report Selection Usage"::"SM.Quote"), 'Unexpected card page for SM.Quote.');
        Assert.AreEqual(Page::"Service Order", ReportOverviewMgt.GetCardPageNo(Enum::"Report Selection Usage"::"SM.Order"), 'Unexpected card page for SM.Order.');
        Assert.AreEqual(Page::"Posted Service Invoice", ReportOverviewMgt.GetCardPageNo(Enum::"Report Selection Usage"::"SM.Invoice"), 'Unexpected card page for SM.Invoice.');
        Assert.AreEqual(Page::"Posted Service Credit Memo", ReportOverviewMgt.GetCardPageNo(Enum::"Report Selection Usage"::"SM.Credit Memo"), 'Unexpected card page for SM.Credit Memo.');
        Assert.AreEqual(Page::"Posted Service Shipment", ReportOverviewMgt.GetCardPageNo(Enum::"Report Selection Usage"::"SM.Shipment"), 'Unexpected card page for SM.Shipment.');
    end;

    [Test]
    procedure ReminderUsagesResolveToIssuedDocumentPages()
    begin
        // [SCENARIO] Reminders and finance charge memos resolve to the issued document pages
        Assert.AreEqual(Page::"Issued Reminder List", ReportOverviewMgt.GetListPageNo(Enum::"Report Selection Usage"::Reminder), 'Unexpected list page for Reminder.');
        Assert.AreEqual(Page::"Issued Reminder", ReportOverviewMgt.GetCardPageNo(Enum::"Report Selection Usage"::Reminder), 'Unexpected card page for Reminder.');
        Assert.AreEqual(Page::"Issued Fin. Charge Memo List", ReportOverviewMgt.GetListPageNo(Enum::"Report Selection Usage"::"Fin.Charge"), 'Unexpected list page for Fin.Charge.');
        Assert.AreEqual(Page::"Issued Finance Charge Memo", ReportOverviewMgt.GetCardPageNo(Enum::"Report Selection Usage"::"Fin.Charge"), 'Unexpected card page for Fin.Charge.');
    end;

    [Test]
    procedure ReportExistsOnlyForReports()
    begin
        // [SCENARIO] Only the ID of a report counts as existing report
        Assert.IsTrue(ReportOverviewMgt.ReportExists(Report::"Report Overview Test Report"), 'The test report should exist.');
        Assert.IsFalse(ReportOverviewMgt.ReportExists(GetUnusedReportId()), 'An unused ID should not exist as report.');
        Assert.IsFalse(ReportOverviewMgt.ReportExists(0), 'ID 0 should not exist as report.');
    end;

    [Test]
    procedure CheckReportExistsFailsForUnknownReport()
    begin
        // [SCENARIO] ID 0 and existing reports pass, an unknown report fails
        ReportOverviewMgt.CheckReportExists(0);
        ReportOverviewMgt.CheckReportExists(Report::"Report Overview Test Report");
        asserterror ReportOverviewMgt.CheckReportExists(GetUnusedReportId());
        Assert.ExpectedError('does not exist');
    end;

    [Test]
    procedure DeleteMissingReportsRemovesOnlyEntriesWithoutReport()
    var
        ReportTest: Record "Report Test";
        UnusedReportId: Integer;
    begin
        // [GIVEN] An entry for an existing report and an entry for an ID without report
        UnusedReportId := GetUnusedReportId();
        ReportTest.DeleteAll(false);
        InsertReportTest(Report::"Report Overview Test Report");
        InsertReportTest(UnusedReportId);

        // [WHEN] The missing reports are deleted
        // [THEN] One entry is removed: the one without report
        Assert.AreEqual(1, ReportOverviewMgt.DeleteMissingReports(), 'One entry should have been removed.');
        Assert.IsTrue(ReportTest.Get(Report::"Report Overview Test Report"), 'The entry of the existing report should be kept.');
        Assert.IsFalse(ReportTest.Get(UnusedReportId), 'The entry without report should be removed.');
    end;

    [Test]
    procedure TestStatusStoresAndClearsUserAndTime()
    var
        ReportTest: Record "Report Test";
    begin
        // [WHEN] A test status is set
        ReportTest.Validate("Test Status", ReportTest."Test Status"::Failed);

        // [THEN] The user and the time are stored
        Assert.AreEqual(UpperCase(UserId()), ReportTest."Last Tested By", 'The user of the test should be stored.');
        Assert.AreNotEqual(0DT, ReportTest."Last Tested At", 'The time of the test should be stored.');

        // [WHEN] The test status is cleared
        ReportTest.Validate("Test Status", ReportTest."Test Status"::" ");

        // [THEN] The user and the time are cleared
        Assert.AreEqual('', ReportTest."Last Tested By", 'The user of the test should be cleared.');
        Assert.AreEqual(0DT, ReportTest."Last Tested At", 'The time of the test should be cleared.');
    end;

    [Test]
    procedure ReportTestStatusValuesKeepTheirNumbers()
    begin
        // [SCENARIO] The test status is stored as number, so the numbers of the values must not change
        Assert.AreEqual(0, Enum::"Report Test Status"::" ".AsInteger(), 'Unexpected number of the blank status.');
        Assert.AreEqual(1, Enum::"Report Test Status"::Passed.AsInteger(), 'Unexpected number of Passed.');
        Assert.AreEqual(2, Enum::"Report Test Status"::Failed.AsInteger(), 'Unexpected number of Failed.');
    end;

    [Test]
    procedure TestParametersAreStoredUnchanged()
    var
        ReportTest: Record "Report Test";
        Parameters: Text;
    begin
        // [GIVEN] Test parameters that are longer than a text field and contain special characters
        Parameters := '<ReportParameters name="Größe &amp; Maße">' + PadStr('', 3000, 'x') + '</ReportParameters>';

        // [WHEN] They are stored and read again
        ReportTest.SetTestParameters(Parameters);

        // [THEN] They are unchanged
        Assert.IsTrue(ReportTest."Has Test Parameters", 'Test parameters should be marked as stored.');
        Assert.AreEqual(Parameters, ReportTest.GetTestParameters(), 'The test parameters should be unchanged.');

        // [WHEN] They are cleared
        ReportTest.SetTestParameters('');

        // [THEN] Nothing is stored
        Assert.IsFalse(ReportTest."Has Test Parameters", 'Test parameters should not be marked as stored.');
        Assert.AreEqual('', ReportTest.GetTestParameters(), 'The test parameters should be empty.');
    end;

    [Test]
    procedure LineStyleShowsMissingReportsAndFavorites()
    var
        ReportTest: Record "Report Test";
    begin
        // [SCENARIO] An entry without report is greyed out, a favorite is highlighted, other entries have no style
        ReportTest."Report ID" := GetUnusedReportId();
        ReportTest."Is Favorite" := true;
        Assert.AreEqual(Format(PageStyle::Subordinate), ReportOverviewMgt.GetLineStyle(ReportTest), 'Unexpected style of an entry without report.');

        ReportTest."Report ID" := Report::"Report Overview Test Report";
        Assert.AreEqual(Format(PageStyle::Attention), ReportOverviewMgt.GetLineStyle(ReportTest), 'Unexpected style of a favorite.');

        ReportTest."Is Favorite" := false;
        Assert.AreEqual(Format(PageStyle::None), ReportOverviewMgt.GetLineStyle(ReportTest), 'Unexpected style of an ordinary entry.');
    end;

    [Test]
    procedure TestStatusStyleShowsResult()
    begin
        // [SCENARIO] Passed is shown as favorable, Failed as unfavorable, no status without style
        Assert.AreEqual(Format(PageStyle::Favorable), ReportOverviewMgt.GetTestStatusStyle(Enum::"Report Test Status"::Passed), 'Unexpected style of Passed.');
        Assert.AreEqual(Format(PageStyle::Unfavorable), ReportOverviewMgt.GetTestStatusStyle(Enum::"Report Test Status"::Failed), 'Unexpected style of Failed.');
        Assert.AreEqual(Format(PageStyle::None), ReportOverviewMgt.GetTestStatusStyle(Enum::"Report Test Status"::" "), 'Unexpected style without status.');
    end;

    [Test]
    procedure CurrentLayoutIsDefaultLayoutOfReport()
    begin
        // [SCENARIO] Without a layout selection the default layout of the report is the current layout
        Assert.AreEqual('TestLayout', ReportOverviewMgt.GetCurrentLayoutName(Report::"Test Report With Layout"), 'Unexpected layout.');
        Assert.AreEqual('', ReportOverviewMgt.GetCurrentLayoutName(Report::"Report Overview Test Report"), 'A processing-only report should have no layout.');
        Assert.AreEqual('', ReportOverviewMgt.GetCurrentLayoutName(0), 'ID 0 should have no layout.');
    end;

    [Test]
    procedure CurrentLayoutIsSelectedLayoutOfCompany()
    var
        TenantReportLayoutSelection: Record "Tenant Report Layout Selection";
        EmptyGuid: Guid;
    begin
        // [GIVEN] A layout is selected for the report in the current company
        if TenantReportLayoutSelection.Get(Report::"Test Report With Layout", CompanyName(), EmptyGuid) then
            TenantReportLayoutSelection.Delete(false);
        TenantReportLayoutSelection.Init();
        TenantReportLayoutSelection."Report ID" := Report::"Test Report With Layout";
        TenantReportLayoutSelection."Company Name" := CopyStr(CompanyName(), 1, MaxStrLen(TenantReportLayoutSelection."Company Name"));
        TenantReportLayoutSelection."User ID" := EmptyGuid;
        TenantReportLayoutSelection."Layout Name" := 'Selected Layout';
        TenantReportLayoutSelection.Insert(false);

        // [THEN] The selected layout is the current layout
        Assert.AreEqual('Selected Layout', ReportOverviewMgt.GetCurrentLayoutName(Report::"Test Report With Layout"), 'Unexpected layout.');
    end;

    [Test]
    procedure SaveReportToBlobCreatesPdfWordAndExcel()
    var
        TempBlob: Codeunit "Temp Blob";
    begin
        // [SCENARIO] A report with layout can be saved in all three download formats
        ReportOverviewMgt.SaveReportToBlob(Report::"Test Report With Layout", '', ReportFormat::Pdf, TempBlob);
        Assert.IsTrue(TempBlob.HasValue(), 'The PDF output should not be empty.');

        Clear(TempBlob);
        ReportOverviewMgt.SaveReportToBlob(Report::"Test Report With Layout", '', ReportFormat::Word, TempBlob);
        Assert.IsTrue(TempBlob.HasValue(), 'The Word output should not be empty.');

        Clear(TempBlob);
        ReportOverviewMgt.SaveReportToBlob(Report::"Test Report With Layout", '', ReportFormat::Excel, TempBlob);
        Assert.IsTrue(TempBlob.HasValue(), 'The Excel output should not be empty.');
    end;

    [Test]
    procedure SaveReportToBlobFailsForProcessingOnlyReport()
    var
        TempBlob: Codeunit "Temp Blob";
    begin
        // [WHEN] A processing-only report is saved
        asserterror ReportOverviewMgt.SaveReportToBlob(Report::"Report Overview Test Report", '', ReportFormat::Pdf, TempBlob);

        // [THEN] The user learns that the report has no output
        Assert.ExpectedError('has no output to download');
    end;

    [Test]
    procedure DownloadFileNameHasCaptionIdAndExtension()
    begin
        // [SCENARIO] The file name consists of the report caption, the report ID and the extension of the format
        Assert.AreEqual('Test Report With Layout 50152.pdf', ReportOverviewMgt.GetDownloadFileName(Report::"Test Report With Layout", 1), 'Unexpected PDF file name.');
        Assert.AreEqual('Test Report With Layout 50152.docx', ReportOverviewMgt.GetDownloadFileName(Report::"Test Report With Layout", 2), 'Unexpected Word file name.');
        Assert.AreEqual('Test Report With Layout 50152.xlsx', ReportOverviewMgt.GetDownloadFileName(Report::"Test Report With Layout", 3), 'Unexpected Excel file name.');
    end;

    [Test]
    procedure GetCustomReportCaptionReturnsCaptionOfExistingReport()
    begin
        // [SCENARIO] The caption of an existing report is returned
        Assert.AreEqual('Report Overview Test Report', ReportOverviewMgt.GetCustomReportCaption(Report::"Report Overview Test Report"), 'Unexpected report caption.');
    end;

    [Test]
    procedure GetCustomReportCaptionIsEmptyForUnknownReport()
    begin
        // [SCENARIO] A report ID that does not exist yields an empty caption instead of an error
        Assert.AreEqual('', ReportOverviewMgt.GetCustomReportCaption(GetUnusedReportId()), 'Unknown report should have an empty caption.');
    end;

    [Test]
    procedure FillTestTableAddsCustomReport()
    var
        ReportTest: Record "Report Test";
    begin
        // [GIVEN] No entry exists yet
        ReportTest.DeleteAll(false);

        // [WHEN] The report list is filled
        ReportOverviewMgt.FillTestTable();

        // [THEN] The custom reports of the test app (IDs within 50000..100000) are listed
        Assert.IsTrue(ReportTest.Get(Report::"Report Overview Test Report"), 'The custom report should have been added.');
        Assert.IsTrue(ReportTest.Get(Report::"Test Report With Request Page"), 'The second custom report should have been added.');
    end;

    [Test]
    procedure FillTestTableKeepsExistingEntry()
    var
        ReportTest: Record "Report Test";
    begin
        // [GIVEN] An entry with user data exists for the custom report
        ReportTest.DeleteAll(false);
        ReportTest.Init();
        ReportTest."Report ID" := Report::"Report Overview Test Report";
        ReportTest."Is Favorite" := true;
        ReportTest.Category := ReportTest.Category::Finance;
        ReportTest."Test Information" := 'Keep me';
        ReportTest.Insert(false);

        // [WHEN] The report list is filled again
        ReportOverviewMgt.FillTestTable();

        // [THEN] The user data is untouched
        Assert.IsTrue(ReportTest.Get(Report::"Report Overview Test Report"), 'The entry should still exist.');
        Assert.IsTrue(ReportTest."Is Favorite", 'Is Favorite should be kept.');
        Assert.AreEqual(ReportTest.Category::Finance, ReportTest.Category, 'Category should be kept.');
        Assert.AreEqual('Keep me', ReportTest."Test Information", 'Test Information should be kept.');
    end;

    [Test]
    procedure FillTestTableIgnoresReportsOutsideCustomRange()
    var
        AllObjWithCaption: Record AllObjWithCaption;
        ReportTest: Record "Report Test";
    begin
        // [GIVEN] The environment has standard reports below ID 50000 and no entries yet
        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Report);
        AllObjWithCaption.SetFilter("Object ID", '<%1', 50000);
        Assert.IsFalse(AllObjWithCaption.IsEmpty(), 'Precondition: standard reports below ID 50000 should exist.');
        ReportTest.DeleteAll(false);

        // [WHEN] The report list is filled
        ReportOverviewMgt.FillTestTable();

        // [THEN] Only reports within 50000..100000 are listed
        ReportTest.SetFilter("Report ID", '<%1|>%2', 50000, 100000);
        Assert.IsTrue(ReportTest.IsEmpty(), 'Reports outside 50000..100000 should not be listed.');
    end;

    [Test]
    procedure ReportCaptionShowsCaptionOfReport()
    var
        ReportTest: Record "Report Test";
        UnusedReportId: Integer;
    begin
        // [GIVEN] An entry for an existing report and an entry for an ID without report
        UnusedReportId := GetUnusedReportId();
        ReportTest.DeleteAll(false);
        ReportTest.Init();
        ReportTest."Report ID" := Report::"Report Overview Test Report";
        ReportTest.Insert(false);
        ReportTest.Init();
        ReportTest."Report ID" := UnusedReportId;
        ReportTest.Insert(false);

        // [WHEN] The FlowField is calculated
        // [THEN] It shows the caption of the report, and nothing without a report
        Assert.IsTrue(ReportTest.Get(Report::"Report Overview Test Report"), 'The entry of the report should exist.');
        ReportTest.CalcFields("Report Caption");
        Assert.AreEqual('Report Overview Test Report', ReportTest."Report Caption", 'Unexpected report caption.');
        Assert.IsTrue(ReportTest.Get(UnusedReportId), 'The entry without report should exist.');
        ReportTest.CalcFields("Report Caption");
        Assert.AreEqual('', ReportTest."Report Caption", 'An entry without report should have no caption.');
    end;

    [Test]
    procedure ReportCategoryValuesKeepTheirNumbers()
    begin
        // [SCENARIO] The category is stored as number, so the numbers of the values must not change
        Assert.AreEqual(0, Enum::"Report Category"::" ".AsInteger(), 'Unexpected number of the blank category.');
        Assert.AreEqual(1, Enum::"Report Category"::Sales.AsInteger(), 'Unexpected number of Sales.');
        Assert.AreEqual(2, Enum::"Report Category"::Purchase.AsInteger(), 'Unexpected number of Purchase.');
        Assert.AreEqual(3, Enum::"Report Category"::Finance.AsInteger(), 'Unexpected number of Finance.');
        Assert.AreEqual(4, Enum::"Report Category"::Inventory.AsInteger(), 'Unexpected number of Inventory.');
        Assert.AreEqual(5, Enum::"Report Category"::Manufacturing.AsInteger(), 'Unexpected number of Manufacturing.');
        Assert.AreEqual(6, Enum::"Report Category"::Service.AsInteger(), 'Unexpected number of Service.');
        Assert.AreEqual(7, Enum::"Report Category"::"Human Resources".AsInteger(), 'Unexpected number of Human Resources.');
        Assert.AreEqual(8, Enum::"Report Category"::Administration.AsInteger(), 'Unexpected number of Administration.');
        Assert.AreEqual(9, Enum::"Report Category"::Other.AsInteger(), 'Unexpected number of Other.');
    end;

    [Test]
    [HandlerFunctions('ReportSettingsPageHandler')]
    procedure OpenReportSettingsFiltersToReportUserAndCompany()
    var
        ObjectOptions: Record "Object Options";
    begin
        // [WHEN] The report settings are opened for a report
        ReportOverviewMgt.OpenReportSettings(Report::"Report Overview Test Report");

        // [THEN] The Report Settings page shows the settings of that report for the current user and company
        ObjectOptions.SetRange("Object ID", Report::"Report Overview Test Report");
        ObjectOptions.SetRange("Company Name", CompanyName());
        ObjectOptions.SetRange("User Name", UserId());
        Assert.AreEqual(ObjectOptions.GetFilter("Object ID"), ReportSettingsObjectIdFilter, 'Unexpected Object ID filter.');
        // A test page returns option filters as ordinal value
        Assert.AreEqual(Format(ObjectOptions."Object Type"::Report, 0, 9), ReportSettingsObjectTypeFilter, 'Unexpected Object Type filter.');
        Assert.AreEqual(ObjectOptions.GetFilter("Company Name"), ReportSettingsCompanyFilter, 'Unexpected Company Name filter.');
        Assert.AreEqual(ObjectOptions.GetFilter("User Name"), ReportSettingsUserFilter, 'Unexpected User Name filter.');
    end;

    [PageHandler]
    procedure ReportSettingsPageHandler(var ReportSettings: TestPage "Report Settings")
    begin
        ReportSettingsObjectIdFilter := ReportSettings.Filter.GetFilter("Object ID");
        ReportSettingsObjectTypeFilter := ReportSettings.Filter.GetFilter("Object Type");
        ReportSettingsCompanyFilter := ReportSettings.Filter.GetFilter("Company Name");
        ReportSettingsUserFilter := ReportSettings.Filter.GetFilter("User Name");
        ReportSettings.Close();
    end;

    local procedure InsertReportTest(ReportId: Integer)
    var
        ReportTest: Record "Report Test";
    begin
        ReportTest.Init();
        ReportTest."Report ID" := ReportId;
        ReportTest.Insert(false);
    end;

    local procedure GetUnusedReportId(): Integer
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Report);
        AllObjWithCaption.SetLoadFields("Object ID");
        if AllObjWithCaption.FindLast() then
            exit(AllObjWithCaption."Object ID" + 1);
        exit(1);
    end;
}
