namespace ReportOverview.Test;

using Microsoft.Finance.RoleCenters;
using Microsoft.Shared.Report;
using ReportOverview;
using System.Environment.Configuration;
using System.Reflection;
using System.TestLibraries.Utilities;

codeunit 50154 "Report Overview Tools Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        TestReportRunCounter: Codeunit "Test Report Run Counter";
        ConfirmReply: Boolean;
        ConfirmCount: Integer;
        MessageCount: Integer;
        OpenedPageCount: Integer;
        RequestPageCount: Integer;
        StrMenuChoice: Integer;
        StrMenuCount: Integer;
        OpenedPageFilter: Text;

    [Test]
    [HandlerFunctions('ReportSettingsPageHandler')]
    procedure SettingsLinkOpensSettingsOfReport()
    var
        ObjectOptions: Record "Object Options";
        ReportOverview: TestPage "Report Overview";
    begin
        // [GIVEN] The custom report is listed
        Initialize();
        ReportOverview.OpenEdit();
        Assert.IsTrue(FindReportLine(ReportOverview, Report::"Report Overview Test Report"), 'Precondition: the custom report should be listed.');

        // [WHEN] The inline settings button of the line is chosen
        ReportOverview.ReportOverviewSubpage.SettingsLink.Drilldown();

        // [THEN] The report settings are opened for that report
        ObjectOptions.SetRange("Object ID", Report::"Report Overview Test Report");
        Assert.AreEqual(1, OpenedPageCount, 'The report settings should have been opened once.');
        Assert.AreEqual(ObjectOptions.GetFilter("Object ID"), OpenedPageFilter, 'Unexpected Object ID filter.');
    end;

    [Test]
    procedure LineShowsCurrentLayoutOfReport()
    var
        ReportOverview: TestPage "Report Overview";
    begin
        // [GIVEN] The dashboard lists a report with a layout and a report that only processes data
        Initialize();
        ReportOverview.OpenEdit();

        // [THEN] The layout column shows the default layout, and nothing for the processing-only report
        Assert.IsTrue(FindReportLine(ReportOverview, Report::"Test Report With Layout"), 'Precondition: the report with layout should be listed.');
        Assert.AreEqual('TestLayout', ReportOverview.ReportOverviewSubpage.CurrentLayout.Value(), 'Unexpected layout.');
        Assert.IsTrue(FindReportLine(ReportOverview, Report::"Report Overview Test Report"), 'Precondition: the processing-only report should be listed.');
        Assert.AreEqual('', ReportOverview.ReportOverviewSubpage.CurrentLayout.Value(), 'A processing-only report should have no layout.');
    end;

    [Test]
    [HandlerFunctions('ReportLayoutsPageHandler')]
    procedure LayoutLinkOpensLayoutsOfReport()
    var
        ReportLayoutList: Record "Report Layout List";
        ReportOverview: TestPage "Report Overview";
    begin
        // [GIVEN] The report with layout is listed
        Initialize();
        ReportOverview.OpenEdit();
        Assert.IsTrue(FindReportLine(ReportOverview, Report::"Test Report With Layout"), 'Precondition: the report with layout should be listed.');

        // [WHEN] The layout of the line is chosen
        ReportOverview.ReportOverviewSubpage.CurrentLayout.Drilldown();

        // [THEN] The report layouts are opened for that report
        ReportLayoutList.SetRange("Report ID", Report::"Test Report With Layout");
        Assert.AreEqual(1, OpenedPageCount, 'The report layouts should have been opened once.');
        Assert.AreEqual(ReportLayoutList.GetFilter("Report ID"), OpenedPageFilter, 'Unexpected Report ID filter.');
    end;

    [Test]
    procedure SettingTestStatusStoresUserAndTime()
    var
        ReportTest: Record "Report Test";
        ReportOverview: TestPage "Report Overview";
    begin
        // [GIVEN] The custom report is listed without test status
        Initialize();
        ReportOverview.OpenEdit();
        Assert.IsTrue(FindReportLine(ReportOverview, Report::"Report Overview Test Report"), 'Precondition: the custom report should be listed.');

        // [WHEN] The test status of the line is set to Passed
        ReportOverview.ReportOverviewSubpage."Test Status".SetValue(Enum::"Report Test Status"::Passed);
        ReportOverview.Close();

        // [THEN] The status, the user and the time are stored
        Assert.IsTrue(ReportTest.Get(Report::"Report Overview Test Report"), 'The entry should exist.');
        Assert.AreEqual(ReportTest."Test Status"::Passed, ReportTest."Test Status", 'The test status should be stored.');
        Assert.AreEqual(UpperCase(UserId()), ReportTest."Last Tested By", 'The user of the test should be stored.');
        Assert.AreNotEqual(0DT, ReportTest."Last Tested At", 'The time of the test should be stored.');
    end;

    [Test]
    procedure ShowUntestedOnlyHidesTestedReports()
    var
        ReportOverview: TestPage "Report Overview";
    begin
        // [GIVEN] A tested and an untested report
        Initialize();
        CreateReportTest(FirstReportId(), Enum::"Report Test Status"::Passed);
        CreateReportTest(SecondReportId(), Enum::"Report Test Status"::" ");
        ReportOverview.OpenEdit();
        Assert.IsTrue(FindReportLine(ReportOverview, FirstReportId()), 'Precondition: the tested report should be listed without a filter.');

        // [WHEN] Show Untested Only is switched on
        ReportOverview.ShowUntestedOnly.SetValue(true);

        // [THEN] Only the untested report is listed
        Assert.IsFalse(FindReportLine(ReportOverview, FirstReportId()), 'The tested report should be hidden.');
        Assert.IsTrue(FindReportLine(ReportOverview, SecondReportId()), 'The untested report should be listed.');
    end;

    [Test]
    procedure ShowAllReportsClearsUntestedFilter()
    var
        ReportOverview: TestPage "Report Overview";
    begin
        // [GIVEN] Show Untested Only hides the tested report
        Initialize();
        CreateReportTest(FirstReportId(), Enum::"Report Test Status"::Failed);
        ReportOverview.OpenEdit();
        ReportOverview.ShowUntestedOnly.SetValue(true);
        Assert.IsFalse(FindReportLine(ReportOverview, FirstReportId()), 'Precondition: the tested report should be hidden.');

        // [WHEN] Show All Reports is chosen
        ReportOverview.ShowAllReports.Invoke();

        // [THEN] The switch is off and the tested report is listed again
        Assert.IsFalse(ReportOverview.ShowUntestedOnly.AsBoolean(), 'Show Untested Only should be switched off.');
        Assert.IsTrue(FindReportLine(ReportOverview, FirstReportId()), 'The tested report should be listed again.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    [HandlerFunctions('RequestPageOkHandler')]
    procedure TestParametersLinkStoresRequestPageValues()
    var
        ReportTest: Record "Report Test";
        ReportOverview: TestPage "Report Overview";
    begin
        // [GIVEN] The custom report with request page is listed
        Initialize();
        ReportOverview.OpenEdit();
        Assert.IsTrue(FindReportLine(ReportOverview, Report::"Test Report With Request Page"), 'Precondition: the custom report should be listed.');
        CommitPageTriggers();

        // [WHEN] The inline test parameters button is chosen and the request page is confirmed
        ReportOverview.ReportOverviewSubpage.TestParametersLink.Drilldown();

        // [THEN] The values of the request page are stored for the report
        Assert.AreEqual(1, RequestPageCount, 'The request page should have been shown once.');
        Assert.IsTrue(ReportTest.Get(Report::"Test Report With Request Page"), 'The entry should exist.');
        Assert.IsTrue(ReportTest."Has Test Parameters", 'Test parameters should be stored.');
        Assert.IsTrue(ReportTest.GetTestParameters().Contains('ReportParameters'), 'The stored test parameters should be the request page values.');
        Assert.AreEqual(0, TestReportRunCounter.GetRunCount(), 'Storing test parameters should not run the report.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    [HandlerFunctions('RequestPageCancelHandler')]
    procedure CancelledRequestPageStoresNoTestParameters()
    var
        ReportTest: Record "Report Test";
        ReportOverview: TestPage "Report Overview";
    begin
        // [GIVEN] The custom report with request page is listed
        Initialize();
        ReportOverview.OpenEdit();
        Assert.IsTrue(FindReportLine(ReportOverview, Report::"Test Report With Request Page"), 'Precondition: the custom report should be listed.');
        CommitPageTriggers();

        // [WHEN] The inline test parameters button is chosen and the request page is cancelled
        ReportOverview.ReportOverviewSubpage.TestParametersLink.Drilldown();

        // [THEN] Nothing is stored
        Assert.AreEqual(1, RequestPageCount, 'The request page should have been shown once.');
        Assert.IsTrue(ReportTest.Get(Report::"Test Report With Request Page"), 'The entry should exist.');
        Assert.IsFalse(ReportTest."Has Test Parameters", 'No test parameters should be stored.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    [HandlerFunctions('RequestPageOkHandler')]
    procedure RunLinkUsesStoredTestParameters()
    var
        ReportOverview: TestPage "Report Overview";
    begin
        // [GIVEN] Test parameters are stored for the custom report with request page
        Initialize();
        ReportOverview.OpenEdit();
        Assert.IsTrue(FindReportLine(ReportOverview, Report::"Test Report With Request Page"), 'Precondition: the custom report should be listed.');
        CommitPageTriggers();
        ReportOverview.ReportOverviewSubpage.TestParametersLink.Drilldown();
        Assert.IsTrue(FindReportLine(ReportOverview, Report::"Test Report With Request Page"), 'Precondition: the custom report should still be listed.');
        CommitPageTriggers();

        // [WHEN] The inline run button of the line is chosen
        ReportOverview.ReportOverviewSubpage.RunReportLink.Drilldown();

        // [THEN] The report is run without showing the request page again
        Assert.AreEqual(1, RequestPageCount, 'The request page should only have been shown to store the test parameters.');
        Assert.AreEqual(1, TestReportRunCounter.GetRunCount(), 'The report should have been run once.');
    end;

    [Test]
    procedure TestParametersLinkFailsWithoutRequestPage()
    var
        ReportOverview: TestPage "Report Overview";
    begin
        // [GIVEN] The custom report without request page is listed
        Initialize();
        ReportOverview.OpenEdit();
        Assert.IsTrue(FindReportLine(ReportOverview, Report::"Report Overview Test Report"), 'Precondition: the custom report should be listed.');

        // [WHEN] The inline test parameters button is chosen
        asserterror ReportOverview.ReportOverviewSubpage.TestParametersLink.Drilldown();

        // [THEN] The user learns that the report has no request page
        Assert.ExpectedError('has no request page');
    end;

    [Test]
    procedure ClearTestParametersRemovesStoredValues()
    var
        ReportTest: Record "Report Test";
        ReportOverview: TestPage "Report Overview";
    begin
        // [GIVEN] A report with stored test parameters and a report without
        Initialize();
        CreateReportTestWithParameters(Report::"Test Report With Request Page", '<ReportParameters />');
        ReportOverview.OpenEdit();
        Assert.IsTrue(FindReportLine(ReportOverview, Report::"Report Overview Test Report"), 'Precondition: the report without test parameters should be listed.');
        Assert.IsFalse(ReportOverview.ReportOverviewSubpage.ClearTestParameters.Enabled(), 'Clear Test Parameters should be disabled without test parameters.');
        Assert.IsTrue(FindReportLine(ReportOverview, Report::"Test Report With Request Page"), 'Precondition: the report with test parameters should be listed.');
        Assert.IsTrue(ReportOverview.ReportOverviewSubpage.ClearTestParameters.Enabled(), 'Clear Test Parameters should be enabled with test parameters.');

        // [WHEN] Clear Test Parameters is chosen
        ReportOverview.ReportOverviewSubpage.ClearTestParameters.Invoke();

        // [THEN] Nothing is stored any more
        Assert.IsTrue(ReportTest.Get(Report::"Test Report With Request Page"), 'The entry should exist.');
        Assert.IsFalse(ReportTest."Has Test Parameters", 'The test parameters should be removed.');
        Assert.AreEqual('', ReportTest.GetTestParameters(), 'The test parameters should be empty.');
    end;

    [Test]
    [HandlerFunctions('StrMenuHandler')]
    procedure DownloadLinkDoesNothingWhenFormatIsCancelled()
    var
        ReportOverview: TestPage "Report Overview";
    begin
        // [GIVEN] The report with layout is listed
        Initialize();
        ReportOverview.OpenEdit();
        Assert.IsTrue(FindReportLine(ReportOverview, Report::"Test Report With Layout"), 'Precondition: the report with layout should be listed.');
        StrMenuChoice := 0;

        // [WHEN] The inline download button is chosen and the format selection is cancelled
        ReportOverview.ReportOverviewSubpage.DownloadLink.Drilldown();

        // [THEN] The user was asked for the format, and the report is not run
        Assert.AreEqual(1, StrMenuCount, 'The format selection should have been shown once.');
        Assert.AreEqual(0, TestReportRunCounter.GetRunCount(), 'The report should not have been run.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    [HandlerFunctions('StrMenuHandler,LayoutRequestPageCancelHandler')]
    procedure DownloadLinkDoesNothingWhenRequestPageIsCancelled()
    var
        ReportOverview: TestPage "Report Overview";
    begin
        // [GIVEN] The report with layout is listed without test parameters
        Initialize();
        ReportOverview.OpenEdit();
        Assert.IsTrue(FindReportLine(ReportOverview, Report::"Test Report With Layout"), 'Precondition: the report with layout should be listed.');
        StrMenuChoice := 1;
        CommitPageTriggers();

        // [WHEN] The inline download button is chosen, PDF is selected and the request page is cancelled
        ReportOverview.ReportOverviewSubpage.DownloadLink.Drilldown();

        // [THEN] The request page was shown, and the report is not run
        Assert.AreEqual(1, RequestPageCount, 'The request page should have been shown once.');
        Assert.AreEqual(0, TestReportRunCounter.GetRunCount(), 'The report should not have been run.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    [HandlerFunctions('StrMenuHandler,LayoutRequestPageOkHandler')]
    procedure DownloadLinkUsesStoredTestParameters()
    var
        ReportOverview: TestPage "Report Overview";
    begin
        // [GIVEN] The report with layout has stored test parameters
        Initialize();
        CommitPageTriggers();
        CreateReportTestWithParameters(Report::"Test Report With Layout", Report.RunRequestPage(Report::"Test Report With Layout"));
        ReportOverview.OpenEdit();
        Assert.IsTrue(FindReportLine(ReportOverview, Report::"Test Report With Layout"), 'Precondition: the report with layout should be listed.');
        StrMenuChoice := 1;
        CommitPageTriggers();

        // [WHEN] The inline download button is chosen and PDF is selected
        ReportOverview.ReportOverviewSubpage.DownloadLink.Drilldown();

        // [THEN] The report is run once without showing the request page again
        Assert.AreEqual(1, RequestPageCount, 'The request page should only have been shown to store the test parameters.');
        Assert.AreEqual(1, TestReportRunCounter.GetRunCount(), 'The report should have been run once.');
    end;

    [Test]
    procedure DownloadLinkFailsForProcessingOnlyReport()
    var
        ReportOverview: TestPage "Report Overview";
    begin
        // [GIVEN] The processing-only report is listed
        Initialize();
        ReportOverview.OpenEdit();
        Assert.IsTrue(FindReportLine(ReportOverview, Report::"Report Overview Test Report"), 'Precondition: the custom report should be listed.');

        // [WHEN] The inline download button is chosen
        asserterror ReportOverview.ReportOverviewSubpage.DownloadLink.Drilldown();

        // [THEN] The user learns that the report has no output
        Assert.ExpectedError('has no output to download');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure RemoveMissingReportsDeletesEntriesWithoutReport()
    var
        ReportTest: Record "Report Test";
        ReportOverview: TestPage "Report Overview";
    begin
        // [GIVEN] An entry without report and the discovered custom report
        Initialize();
        CreateReportTest(FirstReportId(), Enum::"Report Test Status"::" ");
        ReportOverview.OpenEdit();
        Assert.IsTrue(FindReportLine(ReportOverview, FirstReportId()), 'Precondition: the entry without report should be listed.');
        ConfirmReply := true;

        // [WHEN] Remove Missing Reports is chosen and confirmed
        ReportOverview.ReportOverviewSubpage.RemoveMissingReports.Invoke();

        // [THEN] Only the entry without report is removed
        Assert.AreEqual(1, ConfirmCount, 'The user should have been asked once.');
        Assert.IsFalse(ReportTest.Get(FirstReportId()), 'The entry without report should be removed.');
        Assert.IsTrue(ReportTest.Get(Report::"Report Overview Test Report"), 'The entry of the existing report should be kept.');
        Assert.IsFalse(FindReportLine(ReportOverview, FirstReportId()), 'The removed entry should not be listed any more.');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure RemoveMissingReportsKeepsEntriesWhenDeclined()
    var
        ReportTest: Record "Report Test";
        ReportOverview: TestPage "Report Overview";
    begin
        // [GIVEN] An entry without report
        Initialize();
        CreateReportTest(FirstReportId(), Enum::"Report Test Status"::" ");
        ReportOverview.OpenEdit();
        ConfirmReply := false;

        // [WHEN] Remove Missing Reports is chosen and declined
        ReportOverview.ReportOverviewSubpage.RemoveMissingReports.Invoke();

        // [THEN] The entry is kept
        Assert.AreEqual(1, ConfirmCount, 'The user should have been asked once.');
        Assert.IsTrue(ReportTest.Get(FirstReportId()), 'The entry without report should be kept.');
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure RemoveMissingReportsTellsWhenNothingIsMissing()
    var
        ReportOverview: TestPage "Report Overview";
    begin
        // [GIVEN] Only entries of existing reports
        Initialize();
        ReportOverview.OpenEdit();

        // [WHEN] Remove Missing Reports is chosen
        ReportOverview.ReportOverviewSubpage.RemoveMissingReports.Invoke();

        // [THEN] The user is told that nothing is missing
        Assert.AreEqual(1, MessageCount, 'The user should have been told once.');
    end;

    [Test]
    procedure QuickRunRejectsIdOfAnotherObjectType()
    var
        ReportOverview: TestPage "Report Overview";
    begin
        Initialize();
        ReportOverview.OpenEdit();

        // [WHEN] The ID of a page that is not the ID of a report is entered in Quick Run Report
        asserterror ReportOverview.CustomReportNo.SetValue(GetPageIdWithoutReport());

        // [THEN] The value is rejected because no such report exists
        Assert.ExpectedError('does not exist');
    end;

    [Test]
    procedure FavoriteReportsPartListsOnlyFavorites()
    var
        ReportTest: Record "Report Test";
        FavoriteReports: TestPage "Favorite Reports";
    begin
        // [GIVEN] A favorite and a report that is no favorite
        Initialize();
        CreateFavorite(Report::"Report Overview Test Report");
        CreateReportTest(FirstReportId(), Enum::"Report Test Status"::" ");

        // [WHEN] The favorite reports part is opened
        FavoriteReports.OpenView();

        // [THEN] Only the favorite is listed
        Assert.IsTrue(ReportTest.Get(Report::"Report Overview Test Report"), 'Precondition: the favorite should exist.');
        Assert.IsTrue(FavoriteReports.GoToRecord(ReportTest), 'The favorite should be listed.');
        Assert.IsTrue(ReportTest.Get(FirstReportId()), 'Precondition: the other report should exist.');
        Assert.IsFalse(FavoriteReports.GoToRecord(ReportTest), 'A report that is no favorite should not be listed.');
    end;

    [Test]
    procedure FavoriteReportsRunLinkRunsReport()
    var
        ReportTest: Record "Report Test";
        FavoriteReports: TestPage "Favorite Reports";
    begin
        // [GIVEN] The custom report is a favorite
        Initialize();
        CreateFavorite(Report::"Report Overview Test Report");
        Assert.IsTrue(ReportTest.Get(Report::"Report Overview Test Report"), 'Precondition: the favorite should exist.');
        FavoriteReports.OpenView();
        Assert.IsTrue(FavoriteReports.GoToRecord(ReportTest), 'Precondition: the favorite should be listed.');

        // [WHEN] The inline run button of the line is chosen
        FavoriteReports.RunReportLink.Drilldown();

        // [THEN] The report is run once
        Assert.AreEqual(1, TestReportRunCounter.GetRunCount(), 'The report should have been run once.');
    end;

    [Test]
    procedure BusinessManagerRoleCenterShowsFavoriteReports()
    var
        BusinessManagerRoleCenter: TestPage "Business Manager Role Center";
    begin
        // [GIVEN] The custom report is a favorite
        Initialize();
        CreateFavorite(Report::"Report Overview Test Report");

        // [WHEN] The role center is opened
        BusinessManagerRoleCenter.OpenView();

        // [THEN] Its favorite reports part lists the favorite
        Assert.IsTrue(BusinessManagerRoleCenter.FavoriteReports.First(), 'The favorite reports part should list a report.');
        Assert.AreEqual(Report::"Report Overview Test Report", BusinessManagerRoleCenter.FavoriteReports."Report ID".AsInteger(), 'Unexpected favorite.');
    end;

    [PageHandler]
    procedure ReportSettingsPageHandler(var ReportSettings: TestPage "Report Settings")
    begin
        OpenedPageCount += 1;
        OpenedPageFilter := ReportSettings.Filter.GetFilter("Object ID");
        ReportSettings.Close();
    end;

    [PageHandler]
    procedure ReportLayoutsPageHandler(var ReportLayouts: TestPage "Report Layouts")
    begin
        OpenedPageCount += 1;
        OpenedPageFilter := ReportLayouts.Filter.GetFilter("Report ID");
        ReportLayouts.Close();
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

    [RequestPageHandler]
    procedure LayoutRequestPageCancelHandler(var TestReportWithLayout: TestRequestPage "Test Report With Layout")
    begin
        RequestPageCount += 1;
        TestReportWithLayout.Cancel().Invoke();
    end;

    [RequestPageHandler]
    procedure LayoutRequestPageOkHandler(var TestReportWithLayout: TestRequestPage "Test Report With Layout")
    begin
        RequestPageCount += 1;
        TestReportWithLayout.OK().Invoke();
    end;

    [StrMenuHandler]
    procedure StrMenuHandler(Options: Text[1024]; var Choice: Integer; Instruction: Text[1024])
    begin
        StrMenuCount += 1;
        Choice := StrMenuChoice;
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        ConfirmCount += 1;
        Reply := ConfirmReply;
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
        MessageCount += 1;
    end;

    local procedure Initialize()
    var
        ReportTest: Record "Report Test";
    begin
        // Data is rolled back per test codeunit, not per test: remove what earlier tests left behind.
        ReportTest.DeleteAll(false);
        ConfirmCount := 0;
        MessageCount := 0;
        OpenedPageCount := 0;
        RequestPageCount := 0;
        StrMenuCount := 0;
        StrMenuChoice := 0;
        ConfirmReply := false;
        OpenedPageFilter := '';
        TestReportRunCounter.Reset();
    end;

    // A request page cannot open inside the write transaction of a test. In the client the page triggers have committed by now.
    local procedure CommitPageTriggers()
    begin
        Commit();
    end;

    // IDs from the test app range without a report object.
    local procedure FirstReportId(): Integer
    begin
        exit(50198);
    end;

    local procedure SecondReportId(): Integer
    begin
        exit(50199);
    end;

    local procedure CreateReportTest(ReportId: Integer; TestStatus: Enum "Report Test Status")
    var
        ReportTest: Record "Report Test";
    begin
        ReportTest.Init();
        ReportTest."Report ID" := ReportId;
        ReportTest.Validate("Test Status", TestStatus);
        ReportTest.Insert(false);
    end;

    local procedure CreateFavorite(ReportId: Integer)
    var
        ReportTest: Record "Report Test";
    begin
        ReportTest.Init();
        ReportTest."Report ID" := ReportId;
        ReportTest."Is Favorite" := true;
        ReportTest.Insert(false);
    end;

    local procedure CreateReportTestWithParameters(ReportId: Integer; Parameters: Text)
    var
        ReportTest: Record "Report Test";
    begin
        ReportTest.Init();
        ReportTest."Report ID" := ReportId;
        ReportTest.SetTestParameters(Parameters);
        ReportTest.Insert(false);
    end;

    local procedure GetPageIdWithoutReport(): Integer
    var
        AllObjWithCaption: Record AllObjWithCaption;
        ReportOverviewMgt: Codeunit "Report Overview Mgt.";
    begin
        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Page);
        AllObjWithCaption.SetLoadFields("Object ID");
        if AllObjWithCaption.FindSet() then
            repeat
                if not ReportOverviewMgt.ReportExists(AllObjWithCaption."Object ID") then
                    exit(AllObjWithCaption."Object ID");
            until AllObjWithCaption.Next() = 0;
        Assert.Fail('Precondition: a page whose ID is not the ID of a report should exist.');
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
