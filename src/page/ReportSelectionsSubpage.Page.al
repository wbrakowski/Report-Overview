page 50101 "Report Selections Subpage"
{
    PageType = ListPart;
    SourceTable = "Report Selections";
    Caption = 'Report Selections';
    SourceTableView = where(Usage = Filter("P.Quote" | "P.Order" | "P.Invoice" | "P.Cr.Memo" | "S.Quote" | "S.Order" | "S.Shipment" | "S.Invoice" | "Pro Forma S. Invoice" | "S.Cr.Memo"));
    ShowFilter = true;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Usage; Usage)
                {
                    ApplicationArea = All;
                }
                field("Report ID"; "Report ID")
                {
                    ApplicationArea = All;
                }
                field("Report Caption"; "Report Caption")
                {
                    ApplicationArea = All;
                }
                field(ListPageNo; ListPageNo)
                {
                    ApplicationArea = All;
                    Caption = 'List Page No.';
                }
                field(CardPageNo; CardPageNo)
                {
                    ApplicationArea = All;
                    Caption = 'Card Page No.';
                }

            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(RunReport)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Report;
                Caption = 'Run selected Report';
                trigger OnAction()
                begin
                    Report.RunModal("Report ID");
                end;
            }
            action(OpenCardPage)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Image = Table;
                Caption = 'Open Card Page';
                trigger OnAction()
                begin
                    Page.Run(CardPageNo);
                end;
            }
            action(OpenListPage)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Image = Table;
                Caption = 'Open List Page';
                trigger OnAction()
                begin
                    Page.Run(ListPageNo);
                end;
            }
        }
    }

    var
        ReportOverviewMgt: Codeunit "Report Overview Mgt.";
        CardPageNo: Integer;
        ListPageNo: Integer;


    trigger OnAfterGetRecord()
    begin
        CardPageNo := ReportOverviewMgt.GetCardPageNo(Usage);
        ListPageNo := ReportOverviewMgt.GetListPageNo(Usage);
    end;


}
