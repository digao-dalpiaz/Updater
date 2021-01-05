unit UEngine;

interface

uses System.Classes, UConfig, System.Generics.Collections, DzDirSeek;

type
  TFileOperation = (foAppend, foUpdate, foDelete);
  TFileInfo = class
    RelativePath: string;
    Operation: TFileOperation;
    IsDir: Boolean;

    Size: Int64;

    constructor Create(Item: TDSResultItem; xOperation: TFileOperation);
  end;
  TLstFileInfo = class(TObjectList<TFileInfo>);

  TEngine = class(TThread)
  protected
    procedure Execute; override;
  private
    Queue: record
      LastTick: Cardinal; //GPU update controller

      Log: TStringList;
      Status: string;
      TotalSize, CurrentSize: Int64;
    end;

    procedure Log(const Prefix: Char; const Text: string; ForceUpdate: Boolean = True);
    procedure Status(const Text: string; ForceUpdate: Boolean = True);

    procedure DoDefinition(Def: TDefinition);
    procedure CheckForQueueFlush(ForceUpdate: Boolean);
    procedure DoScan(Def: TDefinition; LCopy, LDel: TLstFileInfo);
    procedure CopyFile(Def: TDefinition; FI: TFileInfo);
    procedure DeleteFile(Def: TDefinition; FI: TFileInfo);
    procedure CopyStream(Source, Destination: TStream);
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

uses UFrmMain, System.SysUtils, System.IOUtils, UMasks,
  System.Diagnostics;

constructor TEngine.Create;
begin
  inherited Create(True);
  FreeOnTerminate := True;

  Queue.Log := TStringList.Create;
end;

destructor TEngine.Destroy;
begin
  Queue.Log.Free;

  inherited;

  Synchronize(
    procedure
    begin
      FrmMain.SetControlsState(True); //this will force definitions list invalidate
    end);
end;

procedure TEngine.Execute;
var
  D: TDefinition;
  SW: TStopWatch;
begin
  try
    for D in Config.Definitions do
    begin
      if D.Checked then
      begin
        SW := TStopwatch.StartNew;

        DoDefinition(D);
        if not Config.SecureMode then
          D.LastUpdate := Now; //update definition timestamp

        SW.Stop;
        Log(':', 'Elapsed time: '+SW.Elapsed.ToString);

        if Queue.TotalSize>0 then
          Log(':', 'Total copy size: '+BytesToMB(Queue.TotalSize));
      end;
    end;
  except
    on E: Exception do
      Log('#', 'ERROR: '+E.Message);
  end;

  CheckForQueueFlush(True); //remaining log
end;

procedure TEngine.Log(const Prefix: Char; const Text: string; ForceUpdate: Boolean);
begin
  Queue.Log.Add(Prefix+Text);

  CheckForQueueFlush(ForceUpdate);
end;

procedure TEngine.Status(const Text: string; ForceUpdate: Boolean);
begin
  Queue.Status := Text;

  CheckForQueueFlush(ForceUpdate);
end;

procedure TEngine.CheckForQueueFlush(ForceUpdate: Boolean);
var
  Percent: Byte;
begin
  if ForceUpdate or (GetTickCount > Queue.LastTick+1000) then
  begin
    Synchronize(
      procedure
      var
        A: string;
        AtEnd: Boolean;
      begin
        if Queue.Log.Count>0 then
        begin
          AtEnd := FrmMain.LLogs.ItemIndex = FrmMain.LLogs.Count-1;

          FrmMain.LLogs.Items.BeginUpdate;
          try
            for A in Queue.Log do
              FrmMain.LLogs.Items.Add(A);

            if AtEnd then FrmMain.LLogs.ItemIndex := FrmMain.LLogs.Count-1;
          finally
            FrmMain.LLogs.Items.EndUpdate;
          end;

          Queue.Log.Clear;
        end;

        FrmMain.LbStatus.Caption := Queue.Status;

        if Queue.TotalSize>0 then
        begin
          Percent := Trunc(Queue.CurrentSize / Queue.TotalSize * 100);

          FrmMain.ProgressBar.Position := Percent;
          FrmMain.LbSize.Caption := Format('%s/%s (%d%%)',
            [BytesToMB(Queue.CurrentSize), BytesToMB(Queue.TotalSize), Percent]);
        end else
        begin
          FrmMain.ProgressBar.Position := 0;
          FrmMain.LbSize.Caption := string.Empty;
        end;

        if not FrmMain.BtnStop.Enabled then
          raise Exception.Create('Process aborted by user');
      end);

    //
    Queue.LastTick := GetTickCount;
  end;
end;

constructor TFileInfo.Create(Item: TDSResultItem; xOperation: TFileOperation);
begin
  RelativePath := Item.RelativePath;
  Size := Item.Size;
  IsDir := Item.IsDir;

  Operation := xOperation;
end;

procedure TEngine.DoScan(Def: TDefinition; LCopy, LDel: TLstFileInfo);

  procedure PrepareDirSeek(DS: TDzDirSeek; const Dir: string; SubDir: Boolean;
    const Inclusions, Exclusions: string; HiddenFiles: Boolean);
  begin
    DS.Dir := Dir;
    DS.SubDir := SubDir;
    DS.Sorted := True;
    DS.UseMask := True;
    DS.Inclusions.Text := TMasks.GetMasks(Inclusions);
    DS.Exclusions.Text := TMasks.GetMasks(Exclusions);
    DS.SearchHiddenFiles := HiddenFiles;
    DS.SearchSystemFiles := False;
    DS.IncludeDirItem := True;
  end;

var
  DS_Src, DS_Dest: TDzDirSeek;
  Index: Integer;
  Item: TDSResultItem;
  A: string;
  xAdd, xMod, xDel: Integer;
begin
  xAdd := 0;
  xMod := 0;
  xDel := 0;

  DS_Src := TDzDirSeek.Create(nil);
  DS_Dest := TDzDirSeek.Create(nil);
  try
    PrepareDirSeek(DS_Src, Def.Source, Def.Recursive, Def.Inclusions, Def.Exclusions, Def.HiddenFiles);
    PrepareDirSeek(DS_Dest, Def.Destination, True, string.Empty, string.Empty, False);

    Status('Scanning source...');
    DS_Src.Seek;

    Status('Scanning destination...');
    DS_Dest.Seek;

    Status('Comparing...');

    for Item in DS_Src.ResultList do
    begin
      Index := DS_Dest.ResultList.IndexOfRelativePath(Item.RelativePath, True);
      if Index = -1 then
      begin
        //new file or folder
        if not Item.IsDir then
        begin
          LCopy.Add(TFileInfo.Create(Item, foAppend));
          Inc(xAdd);
        end;
      end else
      begin
        //existing file or folder
        if not Item.IsDir then
        begin
          if Item.Timestamp <> DS_Dest.ResultList[Index].Timestamp then
          begin
            LCopy.Add(TFileInfo.Create(Item, foUpdate));
            Inc(xMod);
          end;
        end;

        DS_Dest.ResultList.Delete(Index);
      end;
    end;

    if Def.Delete then
    begin
      //remaining files in destination list represents removed files
      for Item in DS_Dest.ResultList do
      begin
        //removed file or folder
        LDel.Insert(0, TFileInfo.Create(Item, foDelete)); //descending list
        Inc(xDel);
      end;
    end;
  finally
    DS_Src.Free;
    DS_Dest.Free;
  end;

  A := string.Empty;
  if xAdd>0 then A := A + Format(', New: %d', [xAdd]);
  if xMod>0 then A := A + Format(', Modified: %d', [xMod]);
  if xDel>0 then A := A + Format(', Deleted: %d', [xDel]);
  Delete(A, 1, 2);

  if A<>string.Empty then
    Log(':', A);

  //security check for deleting on first execution
  if (xDel>0) and (Def.LastUpdate=0) then
    raise Exception.Create(
    'For security reasons, synchronization has been canceled,'+
    ' as it is the first execution of this definition and files and/or folders'+
    ' to be removed at the destination have been detected.'+
    ' If you are sure of the definition settings, you will need to disable'+
    ' the exclusion files option in the definition to proceed with this operation.'
    );
end;

procedure TEngine.DoDefinition(Def: TDefinition);

  procedure LogAndStatusOperation(FI: TFileInfo; const LogFlag: Char; const StatusPrefix: string);
  begin
    Log(LogFlag, FI.RelativePath, False);

    if not Config.SecureMode then
      Status(StatusPrefix+' '+FI.RelativePath, False);
  end;

var
  LCopy, LDel: TLstFileInfo;
  FI: TFileInfo;
begin
  Queue.TotalSize := 0;
  Queue.CurrentSize := 0;

  Log('@', Def.Name);
  Status(string.Empty);

  if Config.SecureMode then
    Log('@', '*** SECURE MODE - No changes will be made ***');

  if not TDirectory.Exists(Def.Source) then
    raise Exception.Create('Source not found');

  if not Config.SecureMode then
    if not TDirectory.Exists(Def.Destination) then
      if not ForceDirectories(Def.Destination) then
        raise Exception.Create('Cannot create root destination folder');

  LCopy := TLstFileInfo.Create;
  LDel := TLstFileInfo.Create;
  try
    DoScan(Def, LCopy, LDel);

    for FI in LCopy do
    begin
      Queue.TotalSize := Queue.TotalSize + FI.Size;
    end;

    for FI in LCopy do
    begin
      case FI.Operation of //Operation foAppend and foUpdate are always file
        foAppend:
        begin
          LogAndStatusOperation(FI, '+', 'Appending');
          CopyFile(Def, FI);
        end;

        foUpdate:
        begin
          LogAndStatusOperation(FI, '~', 'Updating');
          CopyFile(Def, FI);
        end;

        else raise Exception.Create('Invalid operation');
      end;
    end;

    for FI in LDel do
    begin
      case FI.Operation of
        foDelete:
        begin
          LogAndStatusOperation(FI, '-', 'Deleting');
          DeleteFile(Def, FI);
        end;

        else raise Exception.Create('Invalid operation');
      end;
    end;

    if (LCopy.Count=0) and (LDel.Count=0) then Log(':', 'Nothing changed');
    
  finally
    LCopy.Free;
    LDel.Free;
  end;
end;

procedure TEngine.CopyFile(Def: TDefinition; FI: TFileInfo);
var
  SourceFile, DestFile, DestDirectory: string;
  SourceStm, DestStm: TFileStream;
begin
  if Config.SecureMode then Exit;

  SourceFile := TPath.Combine(Def.Source, FI.RelativePath);
  DestFile := TPath.Combine(Def.Destination, FI.RelativePath);

  DestDirectory := ExtractFilePath(DestFile);
  if not TDirectory.Exists(DestDirectory) then
  begin
    if not ForceDirectories(DestDirectory) then
      raise Exception.Create('Cannot create destination folder');
  end;

  SourceStm := TFileStream.Create(SourceFile, fmOpenRead or fmShareDenyNone);
  try
    //if file size changed during process, adjust total size
    Queue.TotalSize := Queue.TotalSize + (SourceStm.Size - FI.Size);

    DestStm := TFileStream.Create(DestFile, fmCreate);
    try
      CopyStream(SourceStm, DestStm);
    finally
      DestStm.Free;
    end;
  finally
    SourceStm.Free;
  end;

  TFile.SetLastWriteTime(DestFile, TFile.GetLastWriteTime(SourceFile));
end;

procedure TEngine.CopyStream(Source, Destination: TStream);
const
  MaxBufSize = $F000;
var
  BufSize, N: Integer;
  Buffer: TBytes;
  Count: Int64;
begin
  Count := Source.Size;
  if Count > MaxBufSize then BufSize := MaxBufSize else BufSize := Count;
  SetLength(Buffer, BufSize);
  try
    while Count <> 0 do
    begin
      if Count > BufSize then N := BufSize else N := Count;
      Source.ReadBuffer(Buffer, N);
      Destination.WriteBuffer(Buffer, N);
      Dec(Count, N);

      Queue.CurrentSize := Queue.CurrentSize + N;
      CheckForQueueFlush(False);
    end;
  finally
    SetLength(Buffer, 0);
  end;
end;

procedure TEngine.DeleteFile(Def: TDefinition; FI: TFileInfo);
var
  Path: string;
begin
  if Config.SecureMode then Exit;

  Path := TPath.Combine(Def.Destination, FI.RelativePath);
  if FI.IsDir then
    TDirectory.Delete(Path)
  else
    TFile.Delete(Path);
end;

end.
