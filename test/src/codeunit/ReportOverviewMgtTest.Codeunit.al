namespace ReportOverview.Test;

using Microsoft.Foundation.Reporting;
using Microsoft.Purchases.Document;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using ReportOverview;
using System.Environment.Configuration;
using System.Reflection;
using System.TestLibraries.Utilities;

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
        Assert.AreEqual(0, ReportOverviewMgt.GetListPageNo(Enum::"Report Selection Usage"::Reminder), 'Unsupported usage should not have a list page.');
        Assert.AreEqual(0, ReportOverviewMgt.GetCardPageNo(Enum::"Report Selection Usage"::Reminder), 'Unsupported usage should not have a card page.');
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
