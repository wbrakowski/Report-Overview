
page 50100 "CCO Report Test Page"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "CCO Report Test Table";
    Caption = 'Report Test Page';
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
                    CustomReportCaption := GetCustomReportCaption(CustomReportNo);
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
                field("Page No."; "Page No.")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleTxt;
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
                }

            }
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
            action(UploadAttachment)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Image = Import;
                Caption = 'Upload Attachment';
                trigger OnAction()

                begin
                    UploadAttachment;
                end;
            }
            action(OpenAttachment)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Image = Open;
                Caption = 'Open Attachment';
                trigger OnAction()

                begin
                    OpenAttachment;
                end;
            }
            action("Open Page")
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Image = Table;
                Caption = 'Open Page';
                trigger OnAction()
                begin
                    Page.Run("Page No.");
                end;
            }
        }
    }

    var
        CustomReportNo: Integer;
        CustomReportCaption: Text[250];
        StyleTxt: Text[30];


    trigger OnOpenPage()
    begin
        FillTable();
    end;

    trigger OnAfterGetRecord()
    begin
        UpdateRowStyle;
    end;


    local procedure GetCustomReportCaption(ReportNo: Integer): Text[249];
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        if AllObjWithCaption.Get(AllObjWithCaption."Object Type"::Report, CustomReportNo) then
            exit(AllObjWithCaption."Object Caption")
        else
            exit('');
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