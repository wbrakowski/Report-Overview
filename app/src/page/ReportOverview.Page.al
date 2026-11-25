namespace ReportOverview;

using Microsoft.Foundation.Company;
using Microsoft.Purchases.Setup;
using Microsoft.Sales.Setup;
using System.Reflection;

page 50100 "Report Overview"
{
    ApplicationArea = All;
    Caption = 'Report Overview';
    PageType = Card;
    PromotedActionCategories = 'New, Process, Report, Attachment, Settings';
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(FilterGroup)
            {
                Caption = 'Filters';
                field(ShowFavoritesOnly; ShowFavoritesOnly)
                {
                    Caption = 'Show Favorites Only';
                    ToolTip = 'Specifies whether to show only reports marked as favorites.';

                    trigger OnValidate()
                    begin
                        ApplyFilters();
                    end;
                }
                field(CategoryFilter; CategoryFilter)
                {
                    Caption = 'Category Filter';
                    ToolTip = 'Specifies the category to filter reports by.';

                    trigger OnValidate()
                    begin
                        ApplyFilters();
                    end;
                }
                field(ShowUntestedOnly; ShowUntestedOnly)
                {
                    Caption = 'Show Untested Only';
                    ToolTip = 'Specifies whether to show only reports without a test status.';

                    trigger OnValidate()
                    begin
                        ApplyFilters();
                    end;
                }
            }
            group(QuickRunGroup)
            {
                Caption = 'Quick Run Report';
                field(CustomReportNo; CustomReportNo)
                {
                    Caption = 'Report ID';
                    ToolTip = 'Specifies the ID of the report to run.';
                    TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Report));
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        ReportOverviewMgt.CheckReportExists(CustomReportNo);
                        CustomReportCaption := ReportOverviewMgt.GetCustomReportCaption(CustomReportNo);
                    end;
                }
                field(CustomReportCaption; CustomReportCaption)
                {
                    Caption = 'Report Caption';
                    ToolTip = 'Specifies the caption of the selected report.';
                    Editable = false;
                }
                field(RunReportButton; RunReportButtonText)
                {
                    Caption = ' ', Locked = true;
                    Editable = false;
                    ShowCaption = false;
                    Style = Strong;
                    StyleExpr = true;

                    trigger OnDrillDown()
                    begin
                        RunCustomReport(CustomReportNo);
                    end;
                }
            }
            part(ReportOverviewSubpage; "Report Overview Subpage")
            {
                ApplicationArea = Basic, Suite;
                Editable = true;
                ShowFilter = true;
                UpdatePropagation = Both;
                SubPageView = sorting("Report ID");
            }

            part(ReportSelectionsSubpage; "Report Selections Subpage")
            {
                ApplicationArea = Basic, Suite;
                Editable = true;
                ShowFilter = true;
            }
        }
    }

    actions
    {
        area(Reporting)
        {
            action(ShowAllReports)
            {
                Caption = 'Show All Reports';
                ToolTip = 'Removes all filters and shows all reports.';
                Image = ClearFilter;
                Promoted = true;
                PromotedCategory = Report;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    ShowFavoritesOnly := false;
                    CategoryFilter := CategoryFilter::" ";
                    ShowUntestedOnly := false;
                    ApplyFilters();
                end;
            }
            action(ShowFavoritesAction)
            {
                Caption = 'Show Favorites';
                ToolTip = 'Shows only reports marked as favorites.';
                Image = AddWatch;
                Promoted = true;
                PromotedCategory = Report;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    ShowFavoritesOnly := true;
                    ApplyFilters();
                end;
            }
        }
        area(Navigation)
        {
            action(ReportSelectionSales)
            {
                Caption = 'Report Selection Sales';
                ToolTip = 'Opens the report selection page for sales documents.';
                Image = Table;
                Promoted = true;
                PromotedCategory = Category5;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = page "Report Selection - Sales";
            }
            action(ReportSelectionPurchase)
            {
                Caption = 'Report Selection Purchase';
                ToolTip = 'Opens the report selection page for purchase documents.';
                Image = Table;
                Promoted = true;
                PromotedCategory = Category5;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = page "Report Selection - Purchase";
            }
            action(CompanyInfo)
            {
                Caption = 'Company Information';
                ToolTip = 'Opens the company information page.';
                Image = Table;
                Promoted = true;
                PromotedCategory = Category5;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = page "Company Information";
            }
        }
    }

    var
        ReportOverviewMgt: Codeunit "Report Overview Mgt.";
        CustomReportNo: Integer;
        CustomReportCaption: Text[250];
        ShowFavoritesOnly: Boolean;
        ShowUntestedOnly: Boolean;
        CategoryFilter: Enum "Report Category";
        RunReportButtonText: Text;

    trigger OnOpenPage()
    begin
        ReportOverviewMgt.FillTestTable();
        RunReportButtonText := '▶ Run Report';
    end;

    trigger OnAfterGetCurrRecord()
    begin
        ApplyFilters();
    end;

    local procedure ApplyFilters()
    begin
        CurrPage.ReportOverviewSubpage.Page.SetFilters(ShowFavoritesOnly, CategoryFilter, ShowUntestedOnly);
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