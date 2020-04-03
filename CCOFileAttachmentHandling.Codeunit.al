codeunit 50100 "CCO File Attachment Handling"
{

    procedure OpenAttachment(AttachmentNo: Integer)
    var
        Attachment: record Attachment;
        ResponseStream: InStream;
        TempFilename: text;
        AttachmentErr: Label 'No file available.';
    begin
        if Attachment.get(AttachmentNo) then
            if Attachment."Attachment File".HasValue then begin
                Attachment.CalcFields("Attachment File");
                Attachment."Attachment File".CreateInStream(ResponseStream);
                TempFilename := CreateGuid() + '.' + Attachment."File Extension";
                DownloadFromStream(ResponseStream, 'Export', '', 'All Files (*.*)|*.*', TempFilename);
            end else
                Error(AttachmentErr);
    end;

    procedure UploadAttachment(): Integer;
    var
        Attachment: Record Attachment;
        FileOutStream: OutStream;
        FileInStream: InStream;
        TempFilename: text;
        DialogTitle: Label 'Please select a File...';
    begin
        if UploadIntoStream(DialogTitle, '', 'All Files (*.*)|*.*', TempFilename, FileInStream) then begin

            Attachment.Init();
            Attachment.Insert(true);
            Attachment."Storage Type" := Attachment."Storage Type"::Embedded;
            Attachment."Storage Pointer" := '';
            Attachment."File Extension" := GetFileType(TempFilename);
            Attachment."Attachment File".CreateOutStream(FileOutStream);
            CopyStream(FileOutStream, FileInStream);
            Attachment.Modify(true);
            exit(Attachment."No.");
        end else
            exit(0);
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


}