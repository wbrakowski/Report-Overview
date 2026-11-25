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
                }
                field("Report ID"; Rec."Report ID")
                {
                    Style = Attention;
                    StyleExpr = Rec."Is Favorite";
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
                    Style = Attention;
                    StyleExpr = Rec."Is Favorite";
                }
                field(Category; Rec.Category)
                {
                    ShowMandatory = false;
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
        }
    }

    var
        IsFavorite: Boolean;

    trigger OnAfterGetCurrRecord()
    begin
        IsFavorite := Rec."Is Favorite";
    end;

    procedure SetFilters(ShowFavoritesOnly: Boolean; CategoryFilter: Enum "Report Category")
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

        CurrPage.Update(false);
    end;

    local procedure SetFavorite(NewFavoriteState: Boolean)
    begin
        Rec."Is Favorite" := NewFavoriteState;
        Rec.Modify(true);
        IsFavorite := NewFavoriteState;
        CurrPage.Update(false);
    end;
}
