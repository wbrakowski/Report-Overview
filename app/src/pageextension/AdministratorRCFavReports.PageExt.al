namespace ReportOverview;

using Microsoft.RoleCenters;

pageextension 50101 "Administrator RC Fav. Reports" extends "Administrator Role Center"
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
