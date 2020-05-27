page 50100 "Report Overview"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Report Test";
    Caption = 'Report Overview';
    PromotedActionCategories = 'New, Process, Report, Attachment, Settings';

    layout
    {
        area(Content)
        {
            field(CustomReportNo; CustomReportNo)
            {
                ApplicationArea = All;
                Caption = 'Run Report with ID';
                TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Report));
                trigger OnValidate();
                begin
                    CustomReportCaption := ReportOverviewMgt.GetCustomReportCaption(CustomReportNo);
                end;
            }
            field(CustomReportCaption; CustomReportCaption)
            {
                ApplicationArea = All;
                Editable = false;
                Caption = 'Run Report with Caption';
            }
            part(ReportOverviewSubpage; "Report Overview Subpage")
            {
                ApplicationArea = Basic;
                Editable = true;
                ShowFilter = true;
            }

            part(ReportSelectionsSubpage; "Report Selections Subpage")
            {
                ApplicationArea = Basic;
                Editable = true;
                ShowFilter = true;
            }
        }
    }

    actions
    {
        area(Reporting)
        {
            Action(RunReportCustom)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Report;
                Caption = 'Run Report with ID';
                trigger OnAction()
                begin
                    RunCustomReport(CustomReportNo);
                end;
            }
        }
        area(Navigation)
        {
            Action(OpenReportSettings)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Category5;
                Image = Open;
                Caption = 'Open Report Settings';
                trigger OnAction()

                begin
                    ReportOverviewMgt.OpenReportSettings("Report ID");
                end;
            }
            Action(OpenReportSelectionSales)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Category5;
                RunObject = Page "Report Selection - Sales";
                Image = Table;
                Caption = 'Open Report Selection Sales';
            }
            Action(OpenReportSelectionPurchase)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Category5;
                RunObject = Page "Report Selection - Purchase";
                Image = Table;
                Caption = 'Open Report Selection Purchase';
            }
            Action(OpenCompanyInfo)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Category5;
                RunObject = Page "Company Information";
                Image = Table;
                Caption = 'Open Company Information';
            }

        }
    }

    var
        ReportOverviewMgt: Codeunit "Report Overview Mgt.";
        CustomReportNo: Integer;
        CustomReportCaption: Text[250];


    trigger OnOpenPage()
    begin
        ReportOverviewMgt.FillTestTable();
    end;

    local procedure RunCustomReport(ReportNo: Integer)
    var
        NoNotSpecifiedErr: Label 'Please specify Run report with ID';
    begin
        if ReportNo = 0 then
            Error(NoNotSpecifiedErr);

        Report.RunModal(ReportNo);
    end;
}