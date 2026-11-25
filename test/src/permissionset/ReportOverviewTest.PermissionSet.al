namespace ReportOverview.Test;

permissionset 50150 "Report Overview Test"
{
    Assignable = true;
    Caption = 'Report Overview Tests', Locked = true;

    Permissions =
        codeunit "Report Overview Mgt. Test" = X,
        codeunit "Report Overview Page Test" = X,
        codeunit "Report Overview Perm. Test" = X,
        codeunit "Test Report Run Counter" = X,
        report "Report Overview Test Report" = X,
        report "Test Report With Request Page" = X;
}
