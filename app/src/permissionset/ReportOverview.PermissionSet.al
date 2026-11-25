namespace ReportOverview;

permissionset 50100 "Report Overview"
{
    Assignable = true;
    Caption = 'Report Overview', Locked = true;

    Permissions =
        table "Report Test" = X,
        tabledata "Report Test" = RIMD,
        codeunit "Report Overview Mgt." = X,
        page "Report Overview" = X,
        page "Report Overview Subpage" = X,
        page "Report Selections Subpage" = X;
}
