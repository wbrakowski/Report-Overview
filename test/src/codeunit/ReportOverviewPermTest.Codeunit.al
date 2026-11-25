namespace ReportOverview.Test;

using ReportOverview;
using System.TestLibraries.Security.AccessControl;
using System.TestLibraries.Utilities;

codeunit 50153 "Report Overview Perm. Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        PermissionsMock: Codeunit "Permissions Mock";
        BasicPermissionSetTok: Label 'D365 BASIC', Locked = true;
        ReportOverviewPermissionSetTok: Label 'REPORT OVERVIEW', Locked = true;

    [Test]
    procedure PermissionSetAllowsToUseTheDashboard()
    var
        ReportTest: Record "Report Test";
        ReportOverview: TestPage "Report Overview";
        CanRead: Boolean;
        CanWrite: Boolean;
        IsListed: Boolean;
    begin
        // [GIVEN] A user with the basic permissions and the permission set of the app
        ReportTest.DeleteAll(false);
        StartWithBasicPermissions();
        PermissionsMock.Assign(ReportOverviewPermissionSetTok);

        // [WHEN] The user opens the dashboard and marks the discovered test report as favorite
        CanRead := ReportTest.ReadPermission();
        CanWrite := ReportTest.WritePermission();
        ReportOverview.OpenEdit();
        IsListed := ReportTest.Get(Report::"Report Overview Test Report");
        if IsListed then begin
            ReportOverview.ReportOverviewSubpage.GoToRecord(ReportTest);
            ReportOverview.ReportOverviewSubpage.AddToFavorites.Invoke();
            IsListed := ReportTest.Get(Report::"Report Overview Test Report");
        end;
        ReportOverview.Close();
        PermissionsMock.Stop();

        // [THEN] Reading, discovering and changing the report list is allowed
        Assert.IsTrue(CanRead, 'The permission set should allow reading the report list.');
        Assert.IsTrue(CanWrite, 'The permission set should allow changing the report list.');
        Assert.IsTrue(IsListed, 'The custom report should have been discovered.');
        Assert.IsTrue(ReportTest."Is Favorite", 'The report should be a favorite.');
    end;

    [Test]
    procedure DashboardCannotBeOpenedWithoutPermissionSet()
    var
        ReportTest: Record "Report Test";
        ReportOverview: TestPage "Report Overview";
        CanRead: Boolean;
    begin
        // [GIVEN] A user with the basic permissions only
        StartWithBasicPermissions();

        // [WHEN] The user opens the dashboard
        CanRead := ReportTest.ReadPermission();
        asserterror ReportOverview.OpenEdit();
        PermissionsMock.Stop();

        // [THEN] The report list is not accessible
        Assert.IsFalse(CanRead, 'The report list should not be readable without the permission set.');
        Assert.ExpectedErrorCode('DB:ClientReadDenied');
    end;

    // A test that fails halfway leaves the mock running: every test stops it first.
    local procedure StartWithBasicPermissions()
    begin
        if PermissionsMock.IsStarted() then
            PermissionsMock.Stop();
        PermissionsMock.Start();
        PermissionsMock.Set(BasicPermissionSetTok);
    end;
}
