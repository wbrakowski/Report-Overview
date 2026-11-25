namespace ReportOverview.Test;

report 50151 "Test Report With Request Page"
{
    ApplicationArea = All;
    Caption = 'Test Report With Request Page', Locked = true;
    ProcessingOnly = true;
    UsageCategory = None;

    trigger OnPreReport()
    var
        TestReportRunCounter: Codeunit "Test Report Run Counter";
    begin
        TestReportRunCounter.Increment();
    end;
}
