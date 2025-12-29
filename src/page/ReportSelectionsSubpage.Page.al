page 50101 "Report Selections Subpage"
{
    ApplicationArea = All;
    Caption = 'Report Selections';
    PageType = ListPart;
    ShowFilter = true;
    SourceTable = "Report Selections";
    SourceTableView = where(Usage = filter("P.Quote" | "P.Order" | "P.Invoice" | "P.Cr.Memo" | "S.Quote" | "S.Order" | "S.Shipment" | "S.Invoice" | "Pro Forma S. Invoice" | "S.Cr.Memo"));
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Usage; Rec.Usage)
                {
                    ToolTip = 'Specifies the usage context for the report selection.';
                }
                field("Report ID"; Rec."Report ID")
                {
                }
                field(RunReportLink; '▶')
                {
                    Caption = 'Run Report';
                    ToolTip = 'Specifies the action to run the selected report.';
                    Editable = false;
                    Width = 1;
                    Style = Favorable;
                    StyleExpr = Rec."Report ID" <> 0;

                    trigger OnDrillDown()
                    begin
                        if Rec."Report ID" <> 0 then
                            Report.RunModal(Rec."Report ID");
                    end;
                }
                field("Report Caption"; Rec."Report Caption")
                {
                }
                field(ListPageNo; ListPageNo)
                {
                    Caption = 'List Page No.';
                    ToolTip = 'Specifies the page number of the associated list page.';
                    Editable = false;
                }
                field(OpenListPageLink; '🔗')
                {
                    Caption = 'Open List Page';
                    ToolTip = 'Specifies the action to open the associated list page.';
                    Editable = false;
                    Width = 1;
                    Style = Favorable;
                    StyleExpr = ListPageNo <> 0;

                    trigger OnDrillDown()
                    begin
                        if ListPageNo <> 0 then
                            Page.Run(ListPageNo);
                    end;
                }
                field(CardPageNo; CardPageNo)
                {
                    Caption = 'Card Page No.';
                    ToolTip = 'Specifies the page number of the associated card page.';
                    Editable = false;
                }
                field(OpenCardPageLink; '🔗')
                {
                    Caption = 'Open Card Page';
                    ToolTip = 'Specifies the action to open the associated card page.';
                    Editable = false;
                    Width = 1;
                    Style = Favorable;
                    StyleExpr = CardPageNo <> 0;

                    trigger OnDrillDown()
                    begin
                        if CardPageNo <> 0 then
                            Page.Run(CardPageNo);
                    end;
                }
            }
        }
    }

    var
        ReportOverviewMgt: Codeunit "Report Overview Mgt.";
        CardPageNo: Integer;
        ListPageNo: Integer;

    trigger OnAfterGetRecord()
    begin
        CardPageNo := ReportOverviewMgt.GetCardPageNo(Rec.Usage);
        ListPageNo := ReportOverviewMgt.GetListPageNo(Rec.Usage);
    end;
}
