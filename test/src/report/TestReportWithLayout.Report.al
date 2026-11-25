namespace ReportOverview.Test;

using System.Utilities;

report 50152 "Test Report With Layout"
{
    ApplicationArea = All;
    Caption = 'Test Report With Layout', Locked = true;
    DefaultRenderingLayout = TestLayout;
    UsageCategory = None;

    dataset
    {
        dataitem(SingleRow; Integer)
        {
            DataItemTableView = sorting(Number) where(Number = const(1));

            column(RowNumber; Number)
            {
            }
        }
    }

    rendering
    {
        layout(TestLayout)
        {
            Type = RDLC;
            LayoutFile = './src/report/TestReportWithLayout.rdl';
        }
    }

    trigger OnPreReport()
    var
        TestReportRunCounter: Codeunit "Test Report Run Counter";
    begin
        TestReportRunCounter.Increment();
    end;
}
