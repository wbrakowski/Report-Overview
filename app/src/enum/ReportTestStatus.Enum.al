namespace ReportOverview;

enum 50101 "Report Test Status"
{
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ', Locked = true;
    }
    value(1; Passed)
    {
        Caption = 'Passed';
    }
    value(2; Failed)
    {
        Caption = 'Failed';
    }
}
