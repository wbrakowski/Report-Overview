namespace ReportOverview.Test;

codeunit 50152 "Test Report Run Counter"
{
    SingleInstance = true;

    var
        RunCount: Integer;

    procedure Reset()
    begin
        RunCount := 0;
    end;

    procedure Increment()
    begin
        RunCount += 1;
    end;

    procedure GetRunCount(): Integer
    begin
        exit(RunCount);
    end;
}
