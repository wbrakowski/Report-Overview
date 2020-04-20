page 50101 "Report Selections Subpage"
{

    PageType = ListPart;
    SourceTable = "Report Selections";
    Caption = 'Report Selections';
    SourceTableView = where(Usage = Filter("P.Order" | "S.Order" | "Pro Forma S. Invoice" | "S.Cr.Memo" | "S.Invoice" | "S.Shipment" | "S.Quote"));
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
                field("Report Caption"; "Report Caption")
                {
                    ApplicationArea = All;
                }
                field("Report ID"; "Report ID")
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
        ReportTestMgt: Codeunit "Report Test Mgt.";
        ListPageNo: Integer;
        CardPageNo: Integer;


    trigger OnAfterGetRecord()
    begin
        CardPageNo := ReportTestMgt.GetCardPageNo(Usage);
        ListPageNo := ReportTestMgt.GetListPageNo(Usage);
    end;


}
