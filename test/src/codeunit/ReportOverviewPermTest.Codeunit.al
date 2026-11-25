namespace ReportOverview.Test;

using Microsoft.Finance.RoleCenters;
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
        BusinessPermissionSetTok: Label 'D365 BUS FULL ACCESS', Locked = true;
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

    [Test]
    procedure PermissionSetAllowsToUseFavoritesPartAndCleanup()
    var
        ReportTest: Record "Report Test";
        ReportOverviewMgt: Codeunit "Report Overview Mgt.";
        FavoriteReports: TestPage "Favorite Reports";
        DeletedCount: Integer;
        IsListed: Boolean;
    begin
        // [GIVEN] A favorite, an entry without report, and a user with the basic permissions and the permission set of the app
        ReportTest.DeleteAll(false);
        InsertReportTest(Report::"Report Overview Test Report", true);
        InsertReportTest(MissingReportId(), false);
        StartWithBasicPermissions();
        PermissionsMock.Assign(ReportOverviewPermissionSetTok);

        // [WHEN] The user opens the favorite reports part and removes the missing reports
        FavoriteReports.OpenView();
        IsListed := FavoriteReports.First();
        FavoriteReports.Close();
        DeletedCount := ReportOverviewMgt.DeleteMissingReports();
        PermissionsMock.Stop();

        // [THEN] Both are allowed
        Assert.IsTrue(IsListed, 'The favorite should be listed.');
        Assert.AreEqual(1, DeletedCount, 'The entry without report should have been removed.');
    end;

    [Test]
    procedure RoleCenterLeavesOutFavoritesPartWithoutPermissionSet()
    var
        ErrorCode: Text;
        IsOpened: Boolean;
        IsPartShown: Boolean;
    begin
        // [GIVEN] A business user without the permission set of the app
        if PermissionsMock.IsStarted() then
            PermissionsMock.Stop();
        PermissionsMock.Start();
        PermissionsMock.Set(BusinessPermissionSetTok);

        // [WHEN] The user opens the role center that contains the favorite reports part
        IsOpened := TryOpenRoleCenter(false);
        IsPartShown := TryOpenRoleCenter(true);
        ErrorCode := GetLastErrorCode();
        PermissionsMock.Stop();

        // [THEN] The role center opens and the part is left out instead of raising a permission error
        Assert.IsTrue(IsOpened, 'The role center should open without the permission set.');
        Assert.IsFalse(IsPartShown, 'The favorite reports part should not be on the role center.');
        Assert.AreEqual('TestPartNotFound', ErrorCode, 'The part should be missing, not fail with another error.');
    end;

    [TryFunction]
    local procedure TryOpenRoleCenter(ReadFavoritesPart: Boolean)
    var
        BusinessManagerRoleCenter: TestPage "Business Manager Role Center";
    begin
        BusinessManagerRoleCenter.OpenView();
        if ReadFavoritesPart then
            BusinessManagerRoleCenter.FavoriteReports.First();
        BusinessManagerRoleCenter.Close();
    end;

    // ID from the test app range without a report object.
    local procedure MissingReportId(): Integer
    begin
        exit(50198);
    end;

    local procedure InsertReportTest(ReportId: Integer; IsFavorite: Boolean)
    var
        ReportTest: Record "Report Test";
    begin
        ReportTest.Init();
        ReportTest."Report ID" := ReportId;
        ReportTest."Is Favorite" := IsFavorite;
        ReportTest.Insert(false);
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
