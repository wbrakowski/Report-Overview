codeunit 50100 "Report Test Mgt."
{

    procedure OpenAttachment(AttachmentNo: Integer)
    var
        Attachment: Record Attachment;
        ResponseStream: InStream;
        TempFilename: Text;
        AttachmentErr: Label 'No file available.';
    begin
        with Attachment do begin
            if Get(AttachmentNo) then
                if "Attachment File".HasValue then begin
                    CalcFields("Attachment File");
                    "Attachment File".CreateInStream(ResponseStream);
                    TempFilename := CreateGuid() + '.' + "File Extension";
                    DownloadFromStream(ResponseStream, 'Export', '', 'All Files (*.*)|*.*', TempFilename);
                end else
                    Error(AttachmentErr);
        end;
    end;

    procedure UploadAttachment(): Integer;
    var
        Attachment: Record Attachment;
        FileOutStream: OutStream;
        FileInStream: InStream;
        TempFilename: Text;
        DialogTitle: Label 'Please select a File...';
    begin
        with Attachment do begin
            if UploadIntoStream(DialogTitle, '', 'All Files (*.*)|*.*', TempFilename, FileInStream) then begin
                Init();
                Insert(true);
                "Storage Type" := "Storage Type"::Embedded;
                "Storage Pointer" := '';
                "File Extension" := GetFileType(TempFilename);
                "Attachment File".CreateOutStream(FileOutStream);
                CopyStream(FileOutStream, FileInStream);
                Modify(true);
                exit("No.");
            end else
                exit(0);
        end;
    end;

    local procedure GetFileType(FileName: Text): Text;
    var
        FilenamePos: Integer;
    begin
        FilenamePos := StrLen(FileName);
        while (FileName[FilenamePos] <> '.') or (FilenamePos < 1) do
            FilenamePos -= 1;

        if FilenamePos = 0 then
            exit('');

        exit(CopyStr(FileName, FilenamePos + 1, StrLen(FileName)));
    end;

    procedure UploadAttachment(var ReportTest: Record "Report Test")
    var
        AttachmentNo: Integer;
    begin
        AttachmentNo := UploadAttachment();
        if AttachmentNo <> 0 then begin
            ReportTest."Attachment No." := AttachmentNo;
            ReportTest."Attachment Upload at" := CurrentDateTime();
            ReportTest.Modify();
        end;
    end;

    procedure OpenReportSettings(ReportID: Integer)
    var
        ObjectOptions: Record "Object Options";
    begin
        with ObjectOptions do begin
            SetRange("Object ID", ReportID);
            SetRange("Object Type", "Object Type"::Report);
            SetRange("Company Name", CompanyName);
            SetRange("User Name", UserId);
        end;
        Page.Run(Page::"Report Settings", ObjectOptions);
    end;

    procedure FillTestTable()
    var
        ReportTest: Record "Report Test";
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        with AllObjWithCaption do begin
            SetRange("Object Type", "Object Type"::Report);
            SetRange("Object ID", 50000, 100000);
            if FindSet() then
                repeat
                    if not ReportTest.Get("Object ID") then begin
                        ReportTest.Init();
                        ReportTest."Report ID" := "Object ID";
                        ReportTest."Company Name" := CompanyName;
                        ReportTest.Insert();
                    end;
                until Next() = 0;
        end;
    end;

    procedure GetListPageNo(Usage: Integer): Integer;
    var
        PurchaseHeader: Record "Purchase Header";
        ReportSelections: Record "Report Selections";
        PageNo: Integer;
    begin
        case Usage of
            ReportSelections.Usage::"P.Order":
                PageNo := Page::"Purchase Order List";
            ReportSelections.Usage::"S.Order":
                PageNo := Page::"Sales Order List";
            ReportSelections.Usage::"Pro Forma S. Invoice":
                PageNo := Page::"Sales Order List";
            ReportSelections.Usage::"S.Cr.Memo":
                PageNo := Page::"Sales Credit Memos";
            ReportSelections.Usage::"S.Invoice":
                PageNo := Page::"Sales Invoice List";
            ReportSelections.Usage::"S.Shipment":
                PageNo := Page::"Posted Sales Shipments";
            ReportSelections.Usage::"S.Quote":
                PageNo := Page::"Sales Quotes";
        end;
        exit(PageNo);
    end;

    procedure GetCardPageNo(Usage: Integer): Integer;
    var
        PurchaseHeader: Record "Purchase Header";
        ReportSelections: Record "Report Selections";
        PageNo: Integer;
    begin
        case Usage of
            ReportSelections.Usage::"P.Order":
                PageNo := Page::"Purchase Order";
            ReportSelections.Usage::"S.Order":
                PageNo := Page::"Sales Order";
            ReportSelections.Usage::"Pro Forma S. Invoice":
                PageNo := Page::"Sales Order";
            ReportSelections.Usage::"S.Cr.Memo":
                PageNo := Page::"Sales Credit Memo";
            ReportSelections.Usage::"S.Invoice":
                PageNo := Page::"Sales Invoice";
            ReportSelections.Usage::"S.Shipment":
                PageNo := Page::"Posted Sales Shipment";
            ReportSelections.Usage::"S.Quote":
                PageNo := Page::"Sales Quote";
        end;
        exit(PageNo);
    end;

    procedure GetCustomReportCaption(ReportNo: Integer): Text[249];
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        with AllObjWithCaption do begin
            if Get("Object Type"::Report, ReportNo) then
                exit("Object Caption")
            else
                exit('');
        end;
    end;


}