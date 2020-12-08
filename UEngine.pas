unit UEngine;

interface

uses System.Classes, UConfig, System.Generics.Collections;

type
  TFileOperation = (foAppend, foUpdate, foDelete);
  TFileInfo = class
    RelativePath: string;
    Operation: TFileOperation;

    Size: Int64;

    constructor Create(const Directory, RelativePath: string; Operation: TFileOperation);
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

    procedure Log(const Text: string; ForceUpdate: Boolean = True);
    procedure Status(const Text: string; ForceUpdate: Boolean = True);

    procedure DoDefinition(Def: TDefinition);
    procedure CheckForQueueFlush(ForceUpdate: Boolean);
    procedure CopyFile(Def: TDefinition; FI: TFileInfo);
    procedure DoScan(Def: TDefinition; L: TLstFileInfo);
    procedure CopyStream(Source, Destination: TStream);
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

uses UFrmMain, System.SysUtils, System.IOUtils, DzDirSeek;

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
      FrmMain.SetControlsState(True);
    end);
end;

procedure TEngine.Execute;
var
  D: TDefinition;
begin
  try
    for D in Config.LstDefinition do
      if D.Checked then DoDefinition(D);
  except
    on E: Exception do
      Log('#ERROR: '+E.Message);
  end;

  CheckForQueueFlush(True); //remaining log
end;

procedure TEngine.Log(const Text: string; ForceUpdate: Boolean);
begin
  Queue.Log.Add(Text);

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

constructor TFileInfo.Create(const Directory, RelativePath: string; Operation: TFileOperation);
begin
  Self.RelativePath := RelativePath;
  Self.Operation := Operation;
    
  Size := GetFileSize(TPath.Combine(Directory, RelativePath));
end;

procedure TEngine.DoScan(Def: TDefinition; L: TLstFileInfo);

  procedure PrepareDirSeek(DS: TDzDirSeek; const Dir: string; SubDir: Boolean;
    const Inclusions, Exclusions: string);
  begin
    DS.Dir := Dir;
    DS.SubDir := SubDir;
    DS.Sorted := True;
    DS.ResultKind := rkRelative;
    DS.UseMask := True;
    DS.Inclusions.Text := Inclusions;
    DS.Exclusions.Text := Exclusions;

    DS.List.CaseSensitive := False;
  end;

var
  DS_Src, DS_Dest: TDzDirSeek;
  A: string;
  xAdd, xMod, xDel: Integer;
begin
  xAdd := 0;
  xMod := 0;
  xDel := 0;

  DS_Src := TDzDirSeek.Create(nil);
  DS_Dest := TDzDirSeek.Create(nil);
  try
    PrepareDirSeek(DS_Src, Def.Source, Def.Recursive, Def.Inclusions, Def.Exclusions);
    PrepareDirSeek(DS_Dest, Def.Destination, True, string.Empty, string.Empty);

    Status('Scanning source...');
    DS_Src.Seek;

    Status('Scanning destination...');
    DS_Dest.Seek;

    Status('Comparing...');

    for A in DS_Src.List do
    begin
      if DS_Dest.List.IndexOf(A) = -1 then
      begin
        //new file
        L.Add(TFileInfo.Create(Def.Source, A, foAppend));
        Inc(xAdd);
      end else
      begin
        //existing file
        if TFile.GetLastWriteTime(TPath.Combine(Def.Source, A)) <>
           TFile.GetLastWriteTime(TPath.Combine(Def.Destination, A)) then
        begin
          L.Add(TFileInfo.Create(Def.Source, A, foUpdate));
          Inc(xMod);
        end;
      end;
    end;

    if Def.Delete then
    begin
      for A in DS_Dest.List do
      begin
        if DS_Src.List.IndexOf(A) = -1 then
        begin
          //removed file
          L.Add(TFileInfo.Create(Def.Destination, A, foDelete));
          Inc(xDel);
        end;
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
    Log(':'+A);
end;

procedure TEngine.DoDefinition(Def: TDefinition);
var
  L: TLstFileInfo;
  FI: TFileInfo;
  A: string;
begin
  Queue.TotalSize := 0;
  Queue.CurrentSize := 0;

  Log('@'+Def.Name);
  Status(string.Empty);

  if not TDirectory.Exists(Def.Source) then
    raise Exception.Create('Source not found');

  if not TDirectory.Exists(Def.Destination) then
  begin
    if not ForceDirectories(Def.Destination) then
      raise Exception.Create('Cannot create root destination folder');
  end;

  L := TLstFileInfo.Create;
  try
    DoScan(Def, L);

    for FI in L do
    begin
      if FI.Operation in [foAppend, foUpdate] then
        Queue.TotalSize := Queue.TotalSize + FI.Size;
    end;

    for FI in L do
    begin
      A := FI.RelativePath;

      case FI.Operation of
        foAppend:
        begin
          Log('+'+A, False);
          Status('Appending '+A, False);

          CopyFile(Def, FI);
        end;

        foUpdate:
        begin
          Log('~'+A, False);
          Status('Updating '+A, False);

          CopyFile(Def, FI);
        end;

        foDelete:
        begin
          Log('-'+A, False);
          Status('Deleting '+A, False);

          TFile.Delete(TPath.Combine(Def.Destination, A));
        end;

        else raise Exception.Create('Invalid operation');
      end;
    end;

    if L.Count=0 then Log(':Nothing changed');
    
  finally
    L.Free;
  end;

  //update definition timestamp
  Def.LastUpdate := Now;
end;

procedure TEngine.CopyFile(Def: TDefinition; FI: TFileInfo);
var
  SourceFile, DestFile, DestDirectory: string;
  SourceStm, DestStm: TFileStream;
begin
  SourceFile := TPath.Combine(Def.Source, FI.RelativePath);
  DestFile := TPath.Combine(Def.Destination, FI.RelativePath);

  DestDirectory := ExtractFilePath(DestFile);
  if not TDirectory.Exists(DestDirectory) then
  begin
    if not ForceDirectories(DestDirectory) then
      raise Exception.Create('Cannot create destination folder');
  end;

  SourceStm := TFileStream.Create(SourceFile, fmOpenRead);
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

end.
