namespace ReportOverview.Test;

using Microsoft.Foundation.Company;
using Microsoft.Foundation.PaymentTerms;
using Microsoft.Foundation.Reporting;
using Microsoft.Purchases.Setup;
using Microsoft.Sales.Document;
using Microsoft.Sales.Setup;
using ReportOverview;
using System.Reflection;
using System.TestLibraries.Utilities;

codeunit 50151 "Report Overview Page Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        ReportOverviewMgt: Codeunit "Report Overview Mgt.";
        TestReportRunCounter: Codeunit "Test Report Run Counter";
        OpenedPageCount: Integer;
        RequestPageCount: Integer;
        ReportSelectionSequenceTok: Label 'ROTEST', Locked = true;
        UsageNotShownTok: Label 'Usage %1 should be shown with its list and card page.', Locked = true;

    [Test]
    procedure OpeningOverviewListsCustomReports()
    var
        ReportOverview: TestPage "Report Overview";
    begin
        // [GIVEN] No entries exist yet
        Initialize();

        // [WHEN] The dashboard is opened
        ReportOverview.OpenEdit();

        // [THEN] The custom report of the test app was discovered and is listed
        Assert.IsTrue(FindReportLine(ReportOverview, Report::"Report Overview Test Report"), 'The custom report should be listed.');
    end;

    [Test]
    procedure ShowFavoritesOnlyHidesOtherReports()
    var
        ReportOverview: TestPage "Report Overview";
    begin
        // [GIVEN] A favorite and a non-favorite report
        Initialize();
        CreateReportTest(FirstReportId(), true, Enum::"Report Category"::" ");
        CreateReportTest(SecondReportId(), false, Enum::"Report Category"::" ");
        ReportOverview.OpenEdit();
        Assert.IsTrue(FindReportLine(ReportOverview, SecondReportId()), 'Precondition: the non-favorite report should be listed without a filter.');

        // [WHEN] Show Favorites Only is switched on
        ReportOverview.ShowFavoritesOnly.SetValue(true);

        // [THEN] Only the favorite is listed
        Assert.IsTrue(FindReportLine(ReportOverview, FirstReportId()), 'The favorite report should be listed.');
        Assert.IsFalse(FindReportLine(ReportOverview, SecondReportId()), 'The non-favorite report should be hidden.');
    end;

    [Test]
    procedure CategoryFilterHidesOtherCategories()
    var
        ReportOverview: TestPage "Report Overview";
    begin
        // [GIVEN] A sales report and a purchase report
        Initialize();
        CreateReportTest(FirstReportId(), false, Enum::"Report Category"::Sales);
        CreateReportTest(SecondReportId(), false, Enum::"Report Category"::Purchase);
        ReportOverview.OpenEdit();

        // [WHEN] The category filter is set to Sales
        ReportOverview.CategoryFilter.SetValue(Enum::"Report Category"::Sales);

        // [THEN] Only the sales report is listed
        Assert.IsTrue(FindReportLine(ReportOverview, FirstReportId()), 'The sales report should be listed.');
        Assert.IsFalse(FindReportLine(ReportOverview, SecondReportId()), 'The purchase report should be hidden.');
    end;

    [Test]
    procedure ShowAllReportsClearsBothFilters()
    var
        ReportOverview: TestPage "Report Overview";
    begin
        // [GIVEN] Both filters are set and hide the second report
        Initialize();
        CreateReportTest(FirstReportId(), true, Enum::"Report Category"::Sales);
        CreateReportTest(SecondReportId(), false, Enum::"Report Category"::Purchase);
        ReportOverview.OpenEdit();
        ReportOverview.ShowFavoritesOnly.SetValue(true);
        ReportOverview.CategoryFilter.SetValue(Enum::"Report Category"::Sales);
        Assert.IsFalse(FindReportLine(ReportOverview, SecondReportId()), 'Precondition: the second report should be hidden.');

        // [WHEN] Show All Reports is chosen
        ReportOverview.ShowAllReports.Invoke();

        // [THEN] Both filters are cleared and both reports are listed again
        Assert.IsFalse(ReportOverview.ShowFavoritesOnly.AsBoolean(), 'Show Favorites Only should be switched off.');
        Assert.AreEqual(Enum::"Report Category"::" ".AsInteger(), ReportOverview.CategoryFilter.AsInteger(), 'The category filter should be blank.');
        Assert.IsTrue(FindReportLine(ReportOverview, FirstReportId()), 'The first report should be listed.');
        Assert.IsTrue(FindReportLine(ReportOverview, SecondReportId()), 'The second report should be listed again.');
    end;

    [Test]
    procedure ShowFavoritesActionSwitchesFavoritesFilterOn()
    var
        ReportOverview: TestPage "Report Overview";
    begin
        // [GIVEN] A favorite and a non-favorite report
        Initialize();
        CreateReportTest(FirstReportId(), true, Enum::"Report Category"::" ");
        CreateReportTest(SecondReportId(), false, Enum::"Report Category"::" ");
        ReportOverview.OpenEdit();

        // [WHEN] Show Favorites is chosen
        ReportOverview.ShowFavoritesAction.Invoke();

        // [THEN] The favorites switch is on and only the favorite is listed
        Assert.IsTrue(ReportOverview.ShowFavoritesOnly.AsBoolean(), 'Show Favorites Only should be switched on.');
        Assert.IsTrue(FindReportLine(ReportOverview, FirstReportId()), 'The favorite report should be listed.');
        Assert.IsFalse(FindReportLine(ReportOverview, SecondReportId()), 'The non-favorite report should be hidden.');
    end;

    [Test]
    procedure BothFiltersShowOnlyReportsMatchingBoth()
    var
        ReportOverview: TestPage "Report Overview";
    begin
        // [GIVEN] A favorite sales report, a favorite purchase report and a sales report that is no favorite
        Initialize();
        CreateReportTest(FirstReportId(), true, Enum::"Report Category"::Sales);
        CreateReportTest(SecondReportId(), true, Enum::"Report Category"::Purchase);
        CreateReportTest(ThirdReportId(), false, Enum::"Report Category"::Sales);
        ReportOverview.OpenEdit();

        // [WHEN] Both filters are set
        ReportOverview.ShowFavoritesOnly.SetValue(true);
        ReportOverview.CategoryFilter.SetValue(Enum::"Report Category"::Sales);

        // [THEN] Only the favorite sales report is listed
        Assert.IsTrue(FindReportLine(ReportOverview, FirstReportId()), 'The favorite sales report should be listed.');
        Assert.IsFalse(FindReportLine(ReportOverview, SecondReportId()), 'The favorite purchase report should be hidden.');
        Assert.IsFalse(FindReportLine(ReportOverview, ThirdReportId()), 'The sales report that is no favorite should be hidden.');
    end;

    [Test]
    procedure ClearingCategoryFilterShowsAllCategories()
    var
        ReportOverview: TestPage "Report Overview";
    begin
        // [GIVEN] The category filter hides the purchase report
        Initialize();
        CreateReportTest(FirstReportId(), false, Enum::"Report Category"::Sales);
        CreateReportTest(SecondReportId(), false, Enum::"Report Category"::Purchase);
        ReportOverview.OpenEdit();
        ReportOverview.CategoryFilter.SetValue(Enum::"Report Category"::Sales);
        Assert.IsFalse(FindReportLine(ReportOverview, SecondReportId()), 'Precondition: the purchase report should be hidden.');

        // [WHEN] The category filter is set back to blank
        ReportOverview.CategoryFilter.SetValue(Enum::"Report Category"::" ");

        // [THEN] Both reports are listed
        Assert.IsTrue(FindReportLine(ReportOverview, FirstReportId()), 'The sales report should be listed.');
        Assert.IsTrue(FindReportLine(ReportOverview, SecondReportId()), 'The purchase report should be listed again.');
    end;

    [Test]
    procedure SwitchingFavoritesOffShowsAllReports()
    var
        ReportOverview: TestPage "Report Overview";
    begin
        // [GIVEN] Show Favorites Only hides the report that is no favorite
        Initialize();
        CreateReportTest(FirstReportId(), true, Enum::"Report Category"::" ");
        CreateReportTest(SecondReportId(), false, Enum::"Report Category"::" ");
        ReportOverview.OpenEdit();
        ReportOverview.ShowFavoritesOnly.SetValue(true);
        Assert.IsFalse(FindReportLine(ReportOverview, SecondReportId()), 'Precondition: the non-favorite report should be hidden.');

        // [WHEN] Show Favorites Only is switched off
        ReportOverview.ShowFavoritesOnly.SetValue(false);

        // [THEN] Both reports are listed
        Assert.IsTrue(FindReportLine(ReportOverview, FirstReportId()), 'The favorite report should be listed.');
        Assert.IsTrue(FindReportLine(ReportOverview, SecondReportId()), 'The non-favorite report should be listed again.');
    end;

    [Test]
    procedure ShowFavoritesActionKeepsCategoryFilter()
    var
        ReportOverview: TestPage "Report Overview";
    begin
        // [GIVEN] Two favorites of different categories and a category filter on Sales
        Initialize();
        CreateReportTest(FirstReportId(), true, Enum::"Report Category"::Sales);
        CreateReportTest(SecondReportId(), true, Enum::"Report Category"::Purchase);
        ReportOverview.OpenEdit();
        ReportOverview.CategoryFilter.SetValue(Enum::"Report Category"::Sales);

        // [WHEN] Show Favorites is chosen
        ReportOverview.ShowFavoritesAction.Invoke();

        // [THEN] The category filter still applies
        Assert.AreEqual(Enum::"Report Category"::Sales.AsInteger(), ReportOverview.CategoryFilter.AsInteger(), 'The category filter should be kept.');
        Assert.IsTrue(FindReportLine(ReportOverview, FirstReportId()), 'The favorite sales report should be listed.');
        Assert.IsFalse(FindReportLine(ReportOverview, SecondReportId()), 'The favorite purchase report should be hidden.');
    end;

    [Test]
    procedure QuickRunShowsCaptionOfEnteredReport()
    var
        ReportOverview: TestPage "Report Overview";
    begin
        Initialize();
        ReportOverview.OpenEdit();

        // [WHEN] A report ID is entered in Quick Run Report
        ReportOverview.CustomReportNo.SetValue(Report::"Report Overview Test Report");

        // [THEN] The caption of that report is shown
        Assert.AreEqual('Report Overview Test Report', ReportOverview.CustomReportCaption.Value(), 'Unexpected report caption.');
    end;

    [Test]
    procedure QuickRunRunsEnteredReport()
    var
        ReportOverview: TestPage "Report Overview";
    begin
        // [GIVEN] A report ID is entered in Quick Run Report
        Initialize();
        ReportOverview.OpenEdit();
        ReportOverview.CustomReportNo.SetValue(Report::"Report Overview Test Report");

        // [WHEN] The run button is chosen
        ReportOverview.RunReportButton.Drilldown();

        // [THEN] The report is run once
        Assert.AreEqual(1, TestReportRunCounter.GetRunCount(), 'The report should have been run once.');
    end;

    [Test]
    procedure QuickRunWithoutReportIdFails()
    var
        ReportOverview: TestPage "Report Overview";
    begin
        // [GIVEN] No report ID is entered
        Initialize();
        ReportOverview.OpenEdit();

        // [WHEN] The run button is chosen
        asserterror ReportOverview.RunReportButton.Drilldown();

        // [THEN] The user is asked for a report ID
        Assert.ExpectedError('Please specify Run report with ID');
    end;

    [Test]
    procedure QuickRunClearsCaptionWhenReportIdIsRemoved()
    var
        ReportOverview: TestPage "Report Overview";
    begin
        // [GIVEN] A report ID is entered and its caption is shown
        Initialize();
        ReportOverview.OpenEdit();
        ReportOverview.CustomReportNo.SetValue(Report::"Report Overview Test Report");
        Assert.AreNotEqual('', ReportOverview.CustomReportCaption.Value(), 'Precondition: the caption should be shown.');

        // [WHEN] The report ID is removed
        ReportOverview.CustomReportNo.SetValue(0);

        // [THEN] The caption is empty
        Assert.AreEqual('', ReportOverview.CustomReportCaption.Value(), 'The caption should be empty.');
    end;

    [Test]
    procedure QuickRunRejectsIdWithoutObject()
    var
        ReportOverview: TestPage "Report Overview";
    begin
        Initialize();
        ReportOverview.OpenEdit();

        // [WHEN] An ID that no object uses is entered in Quick Run Report
        asserterror ReportOverview.CustomReportNo.SetValue(GetUnusedObjectId());

        // [THEN] The value is rejected
        Assert.ExpectedErrorCode('TestValidation');
    end;

    [Test]
    procedure QuickRunCaptionIsReadOnly()
    var
        ReportOverview: TestPage "Report Overview";
    begin
        // [SCENARIO] The report ID can be entered, the caption is only shown
        Initialize();
        ReportOverview.OpenEdit();
        Assert.IsTrue(ReportOverview.CustomReportNo.Editable(), 'The report ID should be editable.');
        Assert.IsFalse(ReportOverview.CustomReportCaption.Editable(), 'The report caption should not be editable.');
    end;

    [Test]
    procedure QuickRunButtonShowsRunText()
    var
        ReportOverview: TestPage "Report Overview";
    begin
        // [SCENARIO] The run button is labeled when the dashboard opens
        Initialize();
        ReportOverview.OpenEdit();
        Assert.AreEqual('▶ Run Report', ReportOverview.RunReportButton.Value(), 'Unexpected text of the run button.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    [HandlerFunctions('RequestPageOkHandler')]
    procedure QuickRunRunsReportWithRequestPage()
    var
        ReportOverview: TestPage "Report Overview";
    begin
        // [GIVEN] A report with request page is entered in Quick Run Report
        Initialize();
        ReportOverview.OpenEdit();
        ReportOverview.CustomReportNo.SetValue(Report::"Test Report With Request Page");
        CommitPageTriggers();

        // [WHEN] The run button is chosen and the request page is confirmed
        ReportOverview.RunReportButton.Drilldown();

        // [THEN] The request page was shown and the report is run once
        Assert.AreEqual(1, RequestPageCount, 'The request page should have been shown once.');
        Assert.AreEqual(1, TestReportRunCounter.GetRunCount(), 'The report should have been run once.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    [HandlerFunctions('RequestPageCancelHandler')]
    procedure QuickRunDoesNotRunReportWhenRequestPageIsCancelled()
    var
        ReportOverview: TestPage "Report Overview";
    begin
        // [GIVEN] A report with request page is entered in Quick Run Report
        Initialize();
        ReportOverview.OpenEdit();
        ReportOverview.CustomReportNo.SetValue(Report::"Test Report With Request Page");
        CommitPageTriggers();

        // [WHEN] The run button is chosen and the request page is cancelled
        ReportOverview.RunReportButton.Drilldown();

        // [THEN] The request page was shown and the report is not run
        Assert.AreEqual(1, RequestPageCount, 'The request page should have been shown once.');
        Assert.AreEqual(0, TestReportRunCounter.GetRunCount(), 'The report should not have been run.');
    end;

    [Test]
    procedure RunReportLinkRunsReportOfLine()
    var
        ReportOverview: TestPage "Report Overview";
    begin
        // [GIVEN] The custom report is listed
        Initialize();
        ReportOverview.OpenEdit();
        Assert.IsTrue(FindReportLine(ReportOverview, Report::"Report Overview Test Report"), 'Precondition: the custom report should be listed.');

        // [WHEN] The inline run button of the line is chosen
        ReportOverview.ReportOverviewSubpage.RunReportLink.Drilldown();

        // [THEN] The report is run once
        Assert.AreEqual(1, TestReportRunCounter.GetRunCount(), 'The report should have been run once.');
    end;

    [Test]
    [HandlerFunctions('PaymentTermsPageHandler')]
    procedure OpenListPageLinkOpensListPageOfLine()
    var
        ReportOverview: TestPage "Report Overview";
    begin
        // [GIVEN] A report with a list page
        Initialize();
        CreateReportTestWithPages(FirstReportId(), Page::"Payment Terms", 0);
        ReportOverview.OpenEdit();
        Assert.IsTrue(FindReportLine(ReportOverview, FirstReportId()), 'Precondition: the report should be listed.');

        // [WHEN] The inline list page button is chosen
        ReportOverview.ReportOverviewSubpage.OpenListPageLink.Drilldown();

        // [THEN] The list page is opened once
        Assert.AreEqual(1, OpenedPageCount, 'The list page should have been opened once.');
    end;

    [Test]
    [HandlerFunctions('PaymentTermsPageHandler')]
    procedure OpenCardPageLinkOpensCardPageOfLine()
    var
        ReportOverview: TestPage "Report Overview";
    begin
        // [GIVEN] A report with a card page
        Initialize();
        CreateReportTestWithPages(FirstReportId(), 0, Page::"Payment Terms");
        ReportOverview.OpenEdit();
        Assert.IsTrue(FindReportLine(ReportOverview, FirstReportId()), 'Precondition: the report should be listed.');

        // [WHEN] The inline card page button is chosen
        ReportOverview.ReportOverviewSubpage.OpenCardPageLink.Drilldown();

        // [THEN] The card page is opened once
        Assert.AreEqual(1, OpenedPageCount, 'The card page should have been opened once.');
    end;

    [Test]
    procedure PageLinksDoNothingWithoutPage()
    var
        ReportOverview: TestPage "Report Overview";
    begin
        // [GIVEN] A report without list and card page
        Initialize();
        CreateReportTestWithPages(FirstReportId(), 0, 0);
        ReportOverview.OpenEdit();
        Assert.IsTrue(FindReportLine(ReportOverview, FirstReportId()), 'Precondition: the report should be listed.');

        // [WHEN] Both inline page buttons are chosen
        ReportOverview.ReportOverviewSubpage.OpenListPageLink.Drilldown();
        ReportOverview.ReportOverviewSubpage.OpenCardPageLink.Drilldown();

        // [THEN] No page is opened (an unhandled page would fail the test)
        Assert.AreEqual(0, OpenedPageCount, 'No page should have been opened.');
    end;

    [Test]
    procedure AddToFavoritesMarksReportAsFavorite()
    var
        ReportTest: Record "Report Test";
        ReportOverview: TestPage "Report Overview";
    begin
        // [GIVEN] A non-favorite report
        Initialize();
        CreateReportTest(FirstReportId(), false, Enum::"Report Category"::" ");
        ReportOverview.OpenEdit();
        Assert.IsTrue(FindReportLine(ReportOverview, FirstReportId()), 'Precondition: the report should be listed.');
        Assert.IsTrue(ReportOverview.ReportOverviewSubpage.AddToFavorites.Enabled(), 'Add to Favorites should be enabled for a non-favorite.');
        Assert.IsFalse(ReportOverview.ReportOverviewSubpage.RemoveFromFavorites.Enabled(), 'Remove from Favorites should be disabled for a non-favorite.');

        // [WHEN] Add to Favorites is chosen
        ReportOverview.ReportOverviewSubpage.AddToFavorites.Invoke();

        // [THEN] The report is a favorite
        Assert.IsTrue(ReportTest.Get(FirstReportId()), 'The report should still exist.');
        Assert.IsTrue(ReportTest."Is Favorite", 'The report should be a favorite.');
    end;

    [Test]
    procedure RemoveFromFavoritesClearsFavorite()
    var
        ReportTest: Record "Report Test";
        ReportOverview: TestPage "Report Overview";
    begin
        // [GIVEN] A favorite report
        Initialize();
        CreateReportTest(FirstReportId(), true, Enum::"Report Category"::" ");
        ReportOverview.OpenEdit();
        Assert.IsTrue(FindReportLine(ReportOverview, FirstReportId()), 'Precondition: the report should be listed.');
        Assert.IsTrue(ReportOverview.ReportOverviewSubpage.RemoveFromFavorites.Enabled(), 'Remove from Favorites should be enabled for a favorite.');
        Assert.IsFalse(ReportOverview.ReportOverviewSubpage.AddToFavorites.Enabled(), 'Add to Favorites should be disabled for a favorite.');

        // [WHEN] Remove from Favorites is chosen
        ReportOverview.ReportOverviewSubpage.RemoveFromFavorites.Invoke();

        // [THEN] The report is no longer a favorite
        Assert.IsTrue(ReportTest.Get(FirstReportId()), 'The report should still exist.');
        Assert.IsFalse(ReportTest."Is Favorite", 'The report should not be a favorite.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    [HandlerFunctions('RequestPageOkHandler')]
    procedure RunReportLinkRunsReportWithRequestPage()
    var
        ReportOverview: TestPage "Report Overview";
    begin
        // [GIVEN] The custom report with request page is listed
        Initialize();
        ReportOverview.OpenEdit();
        Assert.IsTrue(FindReportLine(ReportOverview, Report::"Test Report With Request Page"), 'Precondition: the custom report should be listed.');
        CommitPageTriggers();

        // [WHEN] The inline run button of the line is chosen and the request page is confirmed
        ReportOverview.ReportOverviewSubpage.RunReportLink.Drilldown();

        // [THEN] The request page was shown and the report is run once
        Assert.AreEqual(1, RequestPageCount, 'The request page should have been shown once.');
        Assert.AreEqual(1, TestReportRunCounter.GetRunCount(), 'The report should have been run once.');
    end;

    [Test]
    procedure RunReportLinkDoesNothingWithoutReportId()
    var
        ReportOverview: TestPage "Report Overview";
    begin
        // [GIVEN] A line without report ID
        Initialize();
        CreateReportTest(0, false, Enum::"Report Category"::" ");
        ReportOverview.OpenEdit();
        Assert.IsTrue(FindReportLine(ReportOverview, 0), 'Precondition: the line without report ID should be listed.');

        // [WHEN] The inline run button of the line is chosen
        ReportOverview.ReportOverviewSubpage.RunReportLink.Drilldown();

        // [THEN] No report is run
        Assert.AreEqual(0, TestReportRunCounter.GetRunCount(), 'No report should have been run.');
    end;

    [Test]
    procedure ReportLineShowsCaptionOfReport()
    var
        ReportOverview: TestPage "Report Overview";
    begin
        // [GIVEN] The custom report is listed
        Initialize();
        ReportOverview.OpenEdit();
        Assert.IsTrue(FindReportLine(ReportOverview, Report::"Report Overview Test Report"), 'Precondition: the custom report should be listed.');

        // [THEN] The line shows the caption of the report
        Assert.AreEqual('Report Overview Test Report', ReportOverview.ReportOverviewSubpage."Report Caption".Value(), 'Unexpected report caption.');
    end;

    [Test]
    procedure ReportLineStoresEditedValues()
    var
        ReportTest: Record "Report Test";
        ReportOverview: TestPage "Report Overview";
    begin
        // [GIVEN] The custom report is listed
        Initialize();
        ReportOverview.OpenEdit();
        Assert.IsTrue(FindReportLine(ReportOverview, Report::"Report Overview Test Report"), 'Precondition: the custom report should be listed.');

        // [WHEN] The fields of the line are edited and the dashboard is closed
        ReportOverview.ReportOverviewSubpage."Is Favorite".SetValue(true);
        ReportOverview.ReportOverviewSubpage.Category.SetValue(Enum::"Report Category"::Finance);
        ReportOverview.ReportOverviewSubpage."List Page No.".SetValue(Page::"Sales Order List");
        ReportOverview.ReportOverviewSubpage."Card Page No.".SetValue(Page::"Sales Order");
        ReportOverview.ReportOverviewSubpage."Test Information".SetValue('Checked');
        ReportOverview.Close();

        // [THEN] The values are stored
        Assert.IsTrue(ReportTest.Get(Report::"Report Overview Test Report"), 'The entry should exist.');
        Assert.IsTrue(ReportTest."Is Favorite", 'Is Favorite should be stored.');
        Assert.AreEqual(ReportTest.Category::Finance, ReportTest.Category, 'Category should be stored.');
        Assert.AreEqual(Page::"Sales Order List", ReportTest."List Page No.", 'List Page No. should be stored.');
        Assert.AreEqual(Page::"Sales Order", ReportTest."Card Page No.", 'Card Page No. should be stored.');
        Assert.AreEqual('Checked', ReportTest."Test Information", 'Test Information should be stored.');
    end;

    [Test]
    procedure ReportLineRejectsPageNoWithoutObject()
    var
        ReportOverview: TestPage "Report Overview";
    begin
        // [GIVEN] The custom report is listed
        Initialize();
        ReportOverview.OpenEdit();
        Assert.IsTrue(FindReportLine(ReportOverview, Report::"Report Overview Test Report"), 'Precondition: the custom report should be listed.');

        // [WHEN] An ID that no object uses is entered as list page
        asserterror ReportOverview.ReportOverviewSubpage."List Page No.".SetValue(GetUnusedObjectId());

        // [THEN] The value is rejected
        Assert.ExpectedErrorCode('TestValidation');
    end;

    [Test]
    procedure ReportLineRejectsReportIdAsPageNo()
    var
        ReportOverview: TestPage "Report Overview";
    begin
        // [GIVEN] The custom report is listed
        Initialize();
        ReportOverview.OpenEdit();
        Assert.IsTrue(FindReportLine(ReportOverview, Report::"Report Overview Test Report"), 'Precondition: the custom report should be listed.');

        // [WHEN] The ID of a report that is no page is entered as card page
        asserterror ReportOverview.ReportOverviewSubpage."Card Page No.".SetValue(Report::"Report Overview Test Report");

        // [THEN] The value is rejected
        Assert.ExpectedErrorCode('TestValidation');
    end;

    [Test]
    procedure NewLineCanBeAddedForStandardReport()
    var
        ReportTest: Record "Report Test";
        ReportOverview: TestPage "Report Overview";
        StandardReportId: Integer;
    begin
        // [GIVEN] A standard report, which the discovery does not list
        Initialize();
        StandardReportId := GetStandardReportId();
        ReportOverview.OpenEdit();
        Assert.IsFalse(ReportTest.Get(StandardReportId), 'Precondition: the standard report should not be listed.');

        // [WHEN] The user adds a line for it
        ReportOverview.ReportOverviewSubpage.New();
        ReportOverview.ReportOverviewSubpage."Report ID".SetValue(StandardReportId);
        ReportOverview.ReportOverviewSubpage."Test Information".SetValue('Added by hand');
        ReportOverview.Close();

        // [THEN] The line is stored
        Assert.IsTrue(ReportTest.Get(StandardReportId), 'The line should have been stored.');
        Assert.AreEqual('Added by hand', ReportTest."Test Information", 'Test Information should be stored.');
    end;

    [Test]
    procedure ReportSelectionsShowPagesOfUsage()
    var
        ReportSelections: Record "Report Selections";
        ReportSelectionsSubpage: TestPage "Report Selections Subpage";
    begin
        // [GIVEN] A report selection for sales orders
        Initialize();
        CreateReportSelection(ReportSelections, Enum::"Report Selection Usage"::"S.Order");

        // [WHEN] The report selections part shows that line
        ReportSelectionsSubpage.OpenView();
        ReportSelectionsSubpage.GoToRecord(ReportSelections);

        // [THEN] List and card page of sales orders are shown
        Assert.AreEqual(Page::"Sales Order List", ReportSelectionsSubpage.ListPageNo.AsInteger(), 'Unexpected list page.');
        Assert.AreEqual(Page::"Sales Order", ReportSelectionsSubpage.CardPageNo.AsInteger(), 'Unexpected card page.');
    end;

    [Test]
    procedure ReportSelectionsHideUnsupportedUsages()
    var
        ReportSelections: Record "Report Selections";
        ReportSelectionsSubpage: TestPage "Report Selections Subpage";
    begin
        // [GIVEN] A report selection for a usage without a mapped document page
        Initialize();
        CreateReportSelection(ReportSelections, Enum::"Report Selection Usage"::"B.Check");

        // [WHEN] The report selections part is opened
        ReportSelectionsSubpage.OpenView();

        // [THEN] The line is not shown
        Assert.IsFalse(ReportSelectionsSubpage.GoToRecord(ReportSelections), 'Report selections of other usages should be hidden.');
    end;

    [Test]
    procedure ReportSelectionsRunLinkRunsSelectedReport()
    var
        ReportSelections: Record "Report Selections";
        ReportSelectionsSubpage: TestPage "Report Selections Subpage";
    begin
        // [GIVEN] A report selection for sales orders that uses the test report
        Initialize();
        CreateReportSelection(ReportSelections, Enum::"Report Selection Usage"::"S.Order");
        ReportSelectionsSubpage.OpenView();
        ReportSelectionsSubpage.GoToRecord(ReportSelections);

        // [WHEN] The inline run button of the line is chosen
        ReportSelectionsSubpage.RunReportLink.Drilldown();

        // [THEN] The report is run once
        Assert.AreEqual(1, TestReportRunCounter.GetRunCount(), 'The report should have been run once.');
    end;

    [Test]
    procedure ReportSelectionsPartShowsEveryDocumentUsage()
    var
        ReportSelections: Record "Report Selections";
        ReportOverview: TestPage "Report Overview";
        Usages: List of [Enum "Report Selection Usage"];
        Usage: Enum "Report Selection Usage";
    begin
        // [GIVEN] A report selection for each supported document usage
        Initialize();
        GetDocumentUsages(Usages);
        foreach Usage in Usages do
            CreateReportSelection(ReportSelections, Usage);

        // [WHEN] The dashboard is opened
        ReportOverview.OpenEdit();

        // [THEN] Its report selections part shows each of them with its list and card page
        foreach Usage in Usages do begin
            Assert.IsTrue(ReportSelections.Get(Usage, ReportSelectionSequenceTok), 'Precondition: the report selection should exist.');
            Assert.IsTrue(ReportOverview.ReportSelectionsSubpage.GoToRecord(ReportSelections), StrSubstNo(UsageNotShownTok, Usage.AsInteger()));
            Assert.AreNotEqual(0, ReportOverview.ReportSelectionsSubpage.ListPageNo.AsInteger(), StrSubstNo(UsageNotShownTok, Usage.AsInteger()));
            Assert.AreEqual(ReportOverviewMgt.GetListPageNo(Usage), ReportOverview.ReportSelectionsSubpage.ListPageNo.AsInteger(), StrSubstNo(UsageNotShownTok, Usage.AsInteger()));
            Assert.AreEqual(ReportOverviewMgt.GetCardPageNo(Usage), ReportOverview.ReportSelectionsSubpage.CardPageNo.AsInteger(), StrSubstNo(UsageNotShownTok, Usage.AsInteger()));
        end;
    end;

    [Test]
    [HandlerFunctions('SalesOrderListPageHandler')]
    procedure ReportSelectionsListLinkOpensDocumentList()
    var
        ReportSelections: Record "Report Selections";
        ReportSelectionsSubpage: TestPage "Report Selections Subpage";
    begin
        // [GIVEN] A report selection for sales orders
        Initialize();
        CreateReportSelection(ReportSelections, Enum::"Report Selection Usage"::"S.Order");
        ReportSelectionsSubpage.OpenView();
        Assert.IsTrue(ReportSelectionsSubpage.GoToRecord(ReportSelections), 'Precondition: the report selection should be shown.');

        // [WHEN] The inline list page button is chosen
        ReportSelectionsSubpage.OpenListPageLink.Drilldown();

        // [THEN] The sales order list is opened once
        Assert.AreEqual(1, OpenedPageCount, 'The sales order list should have been opened once.');
    end;

    [Test]
    [HandlerFunctions('SalesOrderPageHandler')]
    procedure ReportSelectionsCardLinkOpensDocumentCard()
    var
        ReportSelections: Record "Report Selections";
        ReportSelectionsSubpage: TestPage "Report Selections Subpage";
    begin
        // [GIVEN] A report selection for sales orders
        Initialize();
        CreateReportSelection(ReportSelections, Enum::"Report Selection Usage"::"S.Order");
        ReportSelectionsSubpage.OpenView();
        Assert.IsTrue(ReportSelectionsSubpage.GoToRecord(ReportSelections), 'Precondition: the report selection should be shown.');

        // [WHEN] The inline card page button is chosen
        ReportSelectionsSubpage.OpenCardPageLink.Drilldown();

        // [THEN] The sales order card is opened once
        Assert.AreEqual(1, OpenedPageCount, 'The sales order card should have been opened once.');
    end;

    [Test]
    procedure ReportSelectionsRunLinkDoesNothingWithoutReport()
    var
        ReportSelections: Record "Report Selections";
        ReportSelectionsSubpage: TestPage "Report Selections Subpage";
    begin
        // [GIVEN] A report selection for sales orders without report
        Initialize();
        CreateReportSelection(ReportSelections, Enum::"Report Selection Usage"::"S.Order");
        ReportSelections."Report ID" := 0;
        ReportSelections.Modify(false);
        ReportSelectionsSubpage.OpenView();
        Assert.IsTrue(ReportSelectionsSubpage.GoToRecord(ReportSelections), 'Precondition: the report selection should be shown.');

        // [WHEN] The inline run button of the line is chosen
        ReportSelectionsSubpage.RunReportLink.Drilldown();

        // [THEN] No report is run
        Assert.AreEqual(0, TestReportRunCounter.GetRunCount(), 'No report should have been run.');
    end;

    [Test]
    procedure ReportSelectionsStoreEditedReport()
    var
        ReportSelections: Record "Report Selections";
        ReportSelectionsSubpage: TestPage "Report Selections Subpage";
    begin
        // [GIVEN] A report selection for sales orders
        Initialize();
        CreateReportSelection(ReportSelections, Enum::"Report Selection Usage"::"S.Order");
        ReportSelectionsSubpage.OpenEdit();
        Assert.IsTrue(ReportSelectionsSubpage.GoToRecord(ReportSelections), 'Precondition: the report selection should be shown.');

        // [WHEN] Another report is entered in the line and the part is closed
        ReportSelectionsSubpage."Report ID".SetValue(Report::"Test Report With Request Page");
        ReportSelectionsSubpage.Close();

        // [THEN] The report selection uses the new report
        Assert.IsTrue(ReportSelections.Get(Enum::"Report Selection Usage"::"S.Order", ReportSelectionSequenceTok), 'The report selection should exist.');
        Assert.AreEqual(Report::"Test Report With Request Page", ReportSelections."Report ID", 'The new report should be stored.');
    end;

    [Test]
    [HandlerFunctions('ReportSelectionSalesPageHandler')]
    procedure ReportSelectionSalesActionOpensSetupPage()
    var
        ReportOverview: TestPage "Report Overview";
    begin
        Initialize();
        ReportOverview.OpenEdit();

        // [WHEN] Report Selection Sales is chosen
        ReportOverview.ReportSelectionSales.Invoke();

        // [THEN] The report selection page for sales is opened once
        Assert.AreEqual(1, OpenedPageCount, 'The report selection page for sales should have been opened once.');
    end;

    [Test]
    [HandlerFunctions('ReportSelectionPurchasePageHandler')]
    procedure ReportSelectionPurchaseActionOpensSetupPage()
    var
        ReportOverview: TestPage "Report Overview";
    begin
        Initialize();
        ReportOverview.OpenEdit();

        // [WHEN] Report Selection Purchase is chosen
        ReportOverview.ReportSelectionPurchase.Invoke();

        // [THEN] The report selection page for purchase is opened once
        Assert.AreEqual(1, OpenedPageCount, 'The report selection page for purchase should have been opened once.');
    end;

    [Test]
    [HandlerFunctions('CompanyInformationPageHandler')]
    procedure CompanyInformationActionOpensSetupPage()
    var
        ReportOverview: TestPage "Report Overview";
    begin
        Initialize();
        ReportOverview.OpenEdit();

        // [WHEN] Company Information is chosen
        ReportOverview.CompanyInfo.Invoke();

        // [THEN] The company information page is opened once
        Assert.AreEqual(1, OpenedPageCount, 'The company information page should have been opened once.');
    end;

    [PageHandler]
    procedure PaymentTermsPageHandler(var PaymentTerms: TestPage "Payment Terms")
    begin
        OpenedPageCount += 1;
        PaymentTerms.Close();
    end;

    [PageHandler]
    procedure SalesOrderListPageHandler(var SalesOrderList: TestPage "Sales Order List")
    begin
        OpenedPageCount += 1;
        SalesOrderList.Close();
    end;

    [PageHandler]
    procedure SalesOrderPageHandler(var SalesOrder: TestPage "Sales Order")
    begin
        OpenedPageCount += 1;
        SalesOrder.Close();
    end;

    [PageHandler]
    procedure ReportSelectionSalesPageHandler(var ReportSelectionSales: TestPage "Report Selection - Sales")
    begin
        OpenedPageCount += 1;
        ReportSelectionSales.Close();
    end;

    [PageHandler]
    procedure ReportSelectionPurchasePageHandler(var ReportSelectionPurchase: TestPage "Report Selection - Purchase")
    begin
        OpenedPageCount += 1;
        ReportSelectionPurchase.Close();
    end;

    [PageHandler]
    procedure CompanyInformationPageHandler(var CompanyInformation: TestPage "Company Information")
    begin
        OpenedPageCount += 1;
        CompanyInformation.Close();
    end;

    [RequestPageHandler]
    procedure RequestPageOkHandler(var TestReportWithRequestPage: TestRequestPage "Test Report With Request Page")
    begin
        RequestPageCount += 1;
        TestReportWithRequestPage.OK().Invoke();
    end;

    [RequestPageHandler]
    procedure RequestPageCancelHandler(var TestReportWithRequestPage: TestRequestPage "Test Report With Request Page")
    begin
        RequestPageCount += 1;
        TestReportWithRequestPage.Cancel().Invoke();
    end;

    local procedure Initialize()
    var
        ReportSelections: Record "Report Selections";
        ReportTest: Record "Report Test";
    begin
        // Data is rolled back per test codeunit, not per test: remove what earlier tests left behind.
        ReportTest.DeleteAll(false);
        ReportSelections.SetRange(Sequence, ReportSelectionSequenceTok);
        ReportSelections.DeleteAll(false);
        OpenedPageCount := 0;
        RequestPageCount := 0;
        TestReportRunCounter.Reset();
    end;

    // A request page cannot open inside the write transaction of a test. In the client the page triggers have committed by now.
    local procedure CommitPageTriggers()
    begin
        Commit();
    end;

    // IDs from the test app range without a report object: only the entry matters for filter tests.
    local procedure FirstReportId(): Integer
    begin
        exit(50198);
    end;

    local procedure SecondReportId(): Integer
    begin
        exit(50199);
    end;

    local procedure ThirdReportId(): Integer
    begin
        exit(50197);
    end;

    // Returns an ID that no object of any type uses.
    local procedure GetUnusedObjectId(): Integer
    var
        AllObjWithCaption: Record AllObjWithCaption;
        ObjectId: Integer;
    begin
        ObjectId := 99999;
        AllObjWithCaption.SetRange("Object ID", ObjectId);
        while not AllObjWithCaption.IsEmpty() do begin
            ObjectId -= 1;
            AllObjWithCaption.SetRange("Object ID", ObjectId);
        end;
        exit(ObjectId);
    end;

    local procedure GetStandardReportId(): Integer
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Report);
        AllObjWithCaption.SetFilter("Object ID", '<%1', 50000);
        AllObjWithCaption.SetLoadFields("Object ID");
        Assert.IsTrue(AllObjWithCaption.FindFirst(), 'Precondition: a standard report below ID 50000 should exist.');
        exit(AllObjWithCaption."Object ID");
    end;

    local procedure GetDocumentUsages(var Usages: List of [Enum "Report Selection Usage"])
    begin
        Usages.Add(Enum::"Report Selection Usage"::"P.Quote");
        Usages.Add(Enum::"Report Selection Usage"::"P.Order");
        Usages.Add(Enum::"Report Selection Usage"::"P.Invoice");
        Usages.Add(Enum::"Report Selection Usage"::"P.Cr.Memo");
        Usages.Add(Enum::"Report Selection Usage"::"P.Receipt");
        Usages.Add(Enum::"Report Selection Usage"::"P.Ret.Shpt.");
        Usages.Add(Enum::"Report Selection Usage"::"S.Quote");
        Usages.Add(Enum::"Report Selection Usage"::"S.Order");
        Usages.Add(Enum::"Report Selection Usage"::"S.Shipment");
        Usages.Add(Enum::"Report Selection Usage"::"S.Invoice");
        Usages.Add(Enum::"Report Selection Usage"::"Pro Forma S. Invoice");
        Usages.Add(Enum::"Report Selection Usage"::"S.Cr.Memo");
        Usages.Add(Enum::"Report Selection Usage"::"SM.Quote");
        Usages.Add(Enum::"Report Selection Usage"::"SM.Order");
        Usages.Add(Enum::"Report Selection Usage"::"SM.Invoice");
        Usages.Add(Enum::"Report Selection Usage"::"SM.Credit Memo");
        Usages.Add(Enum::"Report Selection Usage"::"SM.Shipment");
        Usages.Add(Enum::"Report Selection Usage"::Reminder);
        Usages.Add(Enum::"Report Selection Usage"::"Fin.Charge");
    end;

    local procedure CreateReportTest(ReportId: Integer; IsFavorite: Boolean; Category: Enum "Report Category")
    var
        ReportTest: Record "Report Test";
    begin
        ReportTest.Init();
        ReportTest."Report ID" := ReportId;
        ReportTest."Is Favorite" := IsFavorite;
        ReportTest.Category := Category;
        ReportTest.Insert(false);
    end;

    local procedure CreateReportTestWithPages(ReportId: Integer; ListPageNo: Integer; CardPageNo: Integer)
    var
        ReportTest: Record "Report Test";
    begin
        ReportTest.Init();
        ReportTest."Report ID" := ReportId;
        ReportTest."List Page No." := ListPageNo;
        ReportTest."Card Page No." := CardPageNo;
        ReportTest.Insert(false);
    end;

    local procedure CreateReportSelection(var ReportSelections: Record "Report Selections"; Usage: Enum "Report Selection Usage")
    begin
        ReportSelections.Init();
        ReportSelections.Usage := Usage;
        ReportSelections.Sequence := ReportSelectionSequenceTok;
        ReportSelections."Report ID" := Report::"Report Overview Test Report";
        ReportSelections.Insert(false);
    end;

    // Positions the subpage on the line of the report, returns false if the line is not shown.
    local procedure FindReportLine(var ReportOverview: TestPage "Report Overview"; ReportId: Integer): Boolean
    begin
        if not ReportOverview.ReportOverviewSubpage.First() then
            exit(false);
        repeat
            if ReportOverview.ReportOverviewSubpage."Report ID".AsInteger() = ReportId then
                exit(true);
        until not ReportOverview.ReportOverviewSubpage.Next();
        exit(false);
    end;
}
