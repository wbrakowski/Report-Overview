page 50102 "Report Test Card"
{

    PageType = Card;
    SourceTable = "Report Test";
    Caption = 'Report Test Card';

    layout
    {
        area(content)
        {
            group(General)
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
                field("Attachment No."; "Attachment No.")
                {
                    ApplicationArea = All;
                }
                field("Attachment Upload at"; "Attachment Upload at")
                {
                    ApplicationArea = All;
                }
                field("Company Name"; "Company Name")
                {
                    ApplicationArea = All;
                }

            }
            group(Test)
            {
                field("Test Questionnaire Code"; "Test Questionnaire Code")
                {
                    ApplicationArea = All;
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
                field("Test Information"; "Test Information")
                {
                    ApplicationArea = All;
                }
                field(Tested; Tested)
                {
                    ApplicationArea = All;
                }
                field("Test OK"; "Test OK")
                {
                    ApplicationArea = All;
                }
            }
            group(Checklist)
            {
            }
            part("Test Questionnaire"; "Report Test Card Subform")
            {
                ApplicationArea = RelationshipMgmt;
                Caption = 'Test Questionnaire';
                SubPageLink = "Report ID" = field("Report ID");
            }
        }
    }

    actions 
    {
        // action(ShowTestQuestionnaireCard)
        // {
        //     ApplicationArea = All;
            
        //     trigger OnAction()
        //     begin
        //       Show  
        //     end;
        // }
    }

    

}
