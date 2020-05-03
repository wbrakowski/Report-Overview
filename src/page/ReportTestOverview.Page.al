
page 50100 "Report Test Overview"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Report Test";
    Caption = 'Report Test Overview';
    PromotedActionCategories = 'New, Process, Report, Attachment, Settings';

    layout
    {
        area(Content)
        {
            field(CustomReportNo; CustomReportNo)
            {
                ApplicationArea = All;
                Caption = 'Run Report with ID';
                TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Report));
                trigger OnValidate();
                begin
                    CustomReportCaption := ReportTestMgt.GetCustomReportCaption(CustomReportNo);
                end;
            }
            field(CustomReportCaption; CustomReportCaption)
            {
                ApplicationArea = All;
                Editable = false;
                Caption = 'Run Report with Caption';
            }

            repeater(GroupName)
            {
                field("Report ID"; "Report ID")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleTxt;
                }
                field("Report Caption"; "Report Caption")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = StyleTxt;
                }
                field("List Page No."; "List Page No.")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleTxt;
                }
                field("Card Page No."; "Card Page No.")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleTxt;
                }
                field("Test Information"; "Test Information")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleTxt;
                    MultiLine = true;
                }
                field(Tested; Tested)
                {
                    ApplicationArea = All;
                    StyleExpr = StyleTxt;
                    trigger OnValidate()
                    begin
                        UpdateRowStyle;
                        CurrPage.Update(true);
                    end;
                }
                field("Test OK"; "Test OK")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleTxt;
                    trigger OnValidate()
                    begin
                        UpdateRowStyle;
                        CurrPage.Update(true);
                    end;
                }
                field(TestFileUploaded; TestFileUploaded)
                {
                    ApplicationArea = All;
                    Caption = 'Test File Uploaded';
                }
                field("Attachment Upload at"; "Attachment Upload at")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Test Filter 1"; "Test Filter 1")
                {
                    ApplicationArea = All;
                }
                field("Test Filter 2"; "Test Filter 2")
                {
                    ApplicationArea = All;
                }
                field("Test Filter 3"; "Test Filter 3")
                {
                    ApplicationArea = All;
                }
            }
            part(ReportSelectionsSubpage; "Report Selections Subpage")
            {
                ApplicationArea = Basic;
                Editable = true;
                ShowFilter = true;
            }
            // TODO PART
        }
    }

    actions
    {
        area(Reporting)
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
            action(RunReportCustom)
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
            action(OpenReportSettings)
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
                    ReportTestMgt.OpenReportSettings("Report ID");
                end;
            }
            action(OpenReportSelectionSales)
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
            action(OpenReportSelectionPurchase)
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
            action(OpenTestCard)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Image = Card;
                Caption = 'Test Card';
                RunObject = Page "Report Test Card";
                RunPageLink = "Report ID" = field("Report ID");
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
            action(OpenCompanyInfo)
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
        area(Processing)
        {
            action(UploadAttachment)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Category4;
                Image = Import;
                Caption = 'Upload Attachment';
                trigger OnAction()

                begin
                    ReportTestMgt.UploadAttachment(Rec);
                end;
            }
            action(OpenAttachment)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Category4;
                Image = Open;
                Caption = 'Open Attachment';
                trigger OnAction()

                begin
                    ReportTestMgt.OpenAttachment("Attachment No.");
                end;
            }
        }
    }

    var
        ReportTestMgt: Codeunit "Report Test Mgt.";
        CustomReportNo: Integer;
        CustomReportCaption: Text[250];
        StyleTxt: Text[30];


    trigger OnOpenPage()
    begin
        ReportTestMgt.FillTestTable();
    end;

    trigger OnAfterGetRecord()
    begin
        UpdateRowStyle;
    end;




    local procedure RunCustomReport(ReportNo: Integer)
    var
        NoNotSpecifiedErr: Label 'Please specify Run report with ID';
    begin
        if ReportNo = 0 then
            Error(NoNotSpecifiedErr);

        Report.RunModal(ReportNo);
    end;

    local procedure UpdateRowStyle();
    begin
        // Green: Tested and OK
        // Red: Tested and not OK
        // Regular: Not Tested
        if Tested then begin
            if "Test OK" then
                StyleTxt := 'Favorable'
            else
                StyleTxt := 'Unfavorable';
        end else
            StyleTxt := 'Standard';
    end;
}