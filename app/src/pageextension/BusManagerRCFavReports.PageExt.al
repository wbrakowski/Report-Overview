namespace ReportOverview;

using Microsoft.Finance.RoleCenters;

pageextension 50100 "Bus. Manager RC Fav. Reports" extends "Business Manager Role Center"
{
    layout
    {
        addlast(rolecenter)
        {
            part(FavoriteReports; "Favorite Reports")
            {
                ApplicationArea = All;
            }
        }
    }
}
