namespace ReportOverview;

page 50102 "Report Overview Subpage"
{
    ApplicationArea = All;
    Caption = 'Report Overview';
    PageType = ListPart;
    ShowFilter = true;
    SourceTable = "Report Test";
    Editable = true;
    ModifyAllowed = true;
    DeleteAllowed = true;
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Is Favorite"; Rec."Is Favorite")
                {
                    trigger OnValidate()
                    begin
                        UpdateLineValues();
                    end;
                }
                field("Report ID"; Rec."Report ID")
                {
                    StyleExpr = LineStyle;

                    trigger OnValidate()
                    begin
                        UpdateLineValues();
                    end;
                }
                field(RunReportLink; '▶')
                {
                    Caption = 'Run Report';
                    ToolTip = 'Specifies the action to run the selected report. With stored test parameters the report runs without request page.';
                    Editable = false;
                    Width = 1;
                    Style = Favorable;
                    StyleExpr = Rec."Report ID" <> 0;

                    trigger OnDrillDown()
                    begin
                        ReportOverviewMgt.RunReport(Rec);
                    end;
                }
                field(TestParametersLink; '✎')
                {
                    Caption = 'Test Parameters';
                    ToolTip = 'Specifies the action to enter and store the request page values and filters that are used to run and download the selected report.';
                    Editable = false;
                    Width = 1;
                    Style = Favorable;
                    StyleExpr = Rec."Has Test Parameters";

                    trigger OnDrillDown()
                    begin
                        ReportOverviewMgt.SetTestParameters(Rec);
                        CurrPage.Update(false);
                    end;
                }
                field(DownloadLink; '⬇')
                {
                    Caption = 'Download';
                    ToolTip = 'Specifies the action to download the output of the selected report as PDF, Word or Excel file.';
                    Editable = false;
                    Width = 1;
                    Style = Favorable;
                    StyleExpr = Rec."Report ID" <> 0;

                    trigger OnDrillDown()
                    begin
                        ReportOverviewMgt.DownloadReport(Rec);
                    end;
                }
                field(SettingsLink; '⚙')
                {
                    Caption = 'Report Settings';
                    ToolTip = 'Specifies the action to open the request page settings that you saved for the selected report.';
                    Editable = false;
                    Width = 1;
                    Style = Favorable;
                    StyleExpr = Rec."Report ID" <> 0;

                    trigger OnDrillDown()
                    begin
                        if Rec."Report ID" <> 0 then
                            ReportOverviewMgt.OpenReportSettings(Rec."Report ID");
                    end;
                }
                field("Report Caption"; Rec."Report Caption")
                {
                    StyleExpr = LineStyle;
                }
                field(Category; Rec.Category)
                {
                    ShowMandatory = false;
                }
                field("Test Status"; Rec."Test Status")
                {
                    StyleExpr = TestStatusStyle;

                    trigger OnValidate()
                    begin
                        UpdateLineValues();
                    end;
                }
                field("Last Tested At"; Rec."Last Tested At")
                {
                }
                field("Last Tested By"; Rec."Last Tested By")
                {
                }
                field(CurrentLayout; CurrentLayoutName)
                {
                    Caption = 'Layout';
                    ToolTip = 'Specifies the layout that is currently used for the report. Choose the value to open the layouts of the report.';
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        if Rec."Report ID" <> 0 then
                            ReportOverviewMgt.OpenReportLayouts(Rec."Report ID");
                    end;
                }
                field("List Page No."; Rec."List Page No.")
                {
                }
                field(OpenListPageLink; '🔗')
                {
                    Caption = 'Open List Page';
                    ToolTip = 'Specifies the action to open the associated list page.';
                    Editable = false;
                    Width = 1;
                    Style = Favorable;
                    StyleExpr = Rec."List Page No." <> 0;

                    trigger OnDrillDown()
                    begin
                        if Rec."List Page No." <> 0 then
                            Page.Run(Rec."List Page No.");
                    end;
                }
                field("Card Page No."; Rec."Card Page No.")
                {
                }
                field(OpenCardPageLink; '🔗')
                {
                    Caption = 'Open Card Page';
                    ToolTip = 'Specifies the action to open the associated card page.';
                    Editable = false;
                    Width = 1;
                    Style = Favorable;
                    StyleExpr = Rec."Card Page No." <> 0;

                    trigger OnDrillDown()
                    begin
                        if Rec."Card Page No." <> 0 then
                            Page.Run(Rec."Card Page No.");
                    end;
                }
                field("Test Information"; Rec."Test Information")
                {
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            group(FavoritesGroup)
            {
                Caption = 'Favorites';
                Image = AddWatch;

                action(AddToFavorites)
                {
                    Caption = 'Add to Favorites';
                    ToolTip = 'Marks the selected report as a favorite.';
                    Image = AddWatch;
                    Enabled = not IsFavorite;

                    trigger OnAction()
                    begin
                        SetFavorite(true);
                    end;
                }
                action(RemoveFromFavorites)
                {
                    Caption = 'Remove from Favorites';
                    ToolTip = 'Removes the favorite mark from the selected report.';
                    Image = RemoveFilterLines;
                    Enabled = IsFavorite;

                    trigger OnAction()
                    begin
                        SetFavorite(false);
                    end;
                }
            }
            group(TestGroup)
            {
                Caption = 'Test';
                Image = TestReport;

                action(ClearTestParameters)
                {
                    Caption = 'Clear Test Parameters';
                    ToolTip = 'Removes the stored request page values and filters of the selected report.';
                    Image = ClearFilter;
                    Enabled = Rec."Has Test Parameters";

                    trigger OnAction()
                    begin
                        ReportOverviewMgt.ClearTestParameters(Rec);
                        CurrPage.Update(false);
                    end;
                }
                action(RemoveMissingReports)
                {
                    Caption = 'Remove Missing Reports';
                    ToolTip = 'Removes the entries whose report no longer exists in the environment.';
                    Image = Delete;

                    trigger OnAction()
                    begin
                        ReportOverviewMgt.RemoveMissingReports();
                        CurrPage.Update(false);
                    end;
                }
            }
        }
    }

    var
        ReportOverviewMgt: Codeunit "Report Overview Mgt.";
        IsFavorite: Boolean;
        CurrentLayoutName: Text[250];
        LineStyle: Text;
        TestStatusStyle: Text;

    trigger OnAfterGetRecord()
    begin
        UpdateLineValues();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        UpdateLineValues();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        IsFavorite := Rec."Is Favorite";
    end;

    procedure SetFilters(ShowFavoritesOnly: Boolean; CategoryFilter: Enum "Report Category"; ShowUntestedOnly: Boolean)
    begin
        Rec.Reset();

        if ShowFavoritesOnly then
            Rec.SetRange("Is Favorite", true)
        else
            Rec.SetRange("Is Favorite");

        if CategoryFilter <> CategoryFilter::" " then
            Rec.SetRange(Category, CategoryFilter)
        else
            Rec.SetRange(Category);

        if ShowUntestedOnly then
            Rec.SetRange("Test Status", Rec."Test Status"::" ")
        else
            Rec.SetRange("Test Status");

        CurrPage.Update(false);
    end;

    local procedure UpdateLineValues()
    begin
        LineStyle := ReportOverviewMgt.GetLineStyle(Rec);
        TestStatusStyle := ReportOverviewMgt.GetTestStatusStyle(Rec."Test Status");
        CurrentLayoutName := ReportOverviewMgt.GetCurrentLayoutName(Rec."Report ID");
    end;

    local procedure SetFavorite(NewFavoriteState: Boolean)
    begin
        Rec."Is Favorite" := NewFavoriteState;
        Rec.Modify(true);
        IsFavorite := NewFavoriteState;
        UpdateLineValues();
        CurrPage.Update(false);
    end;
}
