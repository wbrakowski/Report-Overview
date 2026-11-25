namespace ReportOverview.Test;

report 50150 "Report Overview Test Report"
{
    ApplicationArea = All;
    Caption = 'Report Overview Test Report', Locked = true;
    ProcessingOnly = true;
    UsageCategory = None;
    // No request page: a modal request page cannot be run inside the open write transaction of a test.
    UseRequestPage = false;

    trigger OnPreReport()
    var
        TestReportRunCounter: Codeunit "Test Report Run Counter";
    begin
        TestReportRunCounter.Increment();
    end;
}
