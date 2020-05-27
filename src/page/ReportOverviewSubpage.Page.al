page 50102 "Report Overview Subpage"
{
    PageType = ListPart;
    SourceTable = "Report Test";
    Caption = 'Report Overview';
    ShowFilter = true;
    // Editable = true;
    // ModifyAllowed = true;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Report ID"; "Report ID")
                {
                    ApplicationArea = All;
                }
                field("Report Caption"; "Report Caption")
                {
                    ApplicationArea = All;
                }
                field("List Page No."; "List Page No.")
                {
                    ApplicationArea = All;
                }
                field("Card Page No."; "Card Page No.")
                {
                    ApplicationArea = All;
                }
                field("Test Information"; "Test Information")
                {
                    ApplicationArea = All;
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
                    RunReportModal();
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
                    Page.Run("Card Page No.");
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
                    Page.Run("List Page No.");
                end;
            }
        }
    }

    local procedure RunReportModal()
    var
        NoNotSpecifiedErr: Label 'Please specify Run report with ID';
    begin
        if "Report ID" = 0 then
            Error(NoNotSpecifiedErr);

        Report.RunModal("Report ID");
    end;
}
