namespace ReportOverview;

page 50103 "Favorite Reports"
{
    ApplicationArea = All;
    Caption = 'Favorite Reports';
    PageType = ListPart;
    SourceTable = "Report Test";
    SourceTableView = where("Is Favorite" = const(true));
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(RunReportLink; '▶')
                {
                    Caption = 'Run Report';
                    ToolTip = 'Specifies the action to run the selected report. With stored test parameters the report runs without request page.';
                    Width = 1;
                    Style = Favorable;
                    StyleExpr = Rec."Report ID" <> 0;

                    trigger OnDrillDown()
                    begin
                        ReportOverviewMgt.RunReport(Rec);
                    end;
                }
                field("Report ID"; Rec."Report ID")
                {
                }
                field("Report Caption"; Rec."Report Caption")
                {
                }
                field(Category; Rec.Category)
                {
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(OpenReportOverview)
            {
                Caption = 'Report Overview';
                ToolTip = 'Opens the report overview to manage and test all custom reports.';
                Image = Report;
                RunObject = page "Report Overview";
            }
        }
    }

    var
        ReportOverviewMgt: Codeunit "Report Overview Mgt.";
}
