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
    LastTick: Cardinal; //GPU update controller
    TotalSize, CurrentSize: Int64;

    Queue: record
      Log: TStringList;
      Status: string;
      Percent: Byte;
    end;

    procedure Log(const Text: string; ForceUpdate: Boolean = True);
    procedure Status(const Text: string; ForceUpdate: Boolean = True);
    procedure Percent(Value: Byte);

    procedure DoDefinition(Def: TDefinition);
    procedure CheckForQueueFlush(ForceUpdate: Boolean);
    procedure CopyFile(SourceFile, DestinationFile: string);
    procedure DoScan(Def: TDefinition; L: TLstFileInfo);
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

  LastTick := GetTickCount;
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

procedure TEngine.Percent(Value: Byte);
begin
  Queue.Percent := Value;

  CheckForQueueFlush(False);
end;

procedure TEngine.CheckForQueueFlush(ForceUpdate: Boolean);
begin
  if ForceUpdate or (GetTickCount > LastTick+1000) then
  begin
    Synchronize(
      procedure
      var
        A: string;
      begin
        for A in Queue.Log do
          FrmMain.LLogs.Items.Add(A);

        FrmMain.LbStatus.Caption := Queue.Status;
        FrmMain.ProgressBar.Position := Queue.Percent;

        FrmMain.LbTotalSize.Caption := BytesToMB(TotalSize);
        FrmMain.LbCurrentSize.Caption := BytesToMB(CurrentSize);

        if not FrmMain.BtnStop.Enabled then
          raise Exception.Create('Process aborted by user');
      end);

    Queue.Log.Clear;

    //
    LastTick := GetTickCount;
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
begin
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
      end else
      begin
        //existing file
        if TFile.GetLastWriteTime(TPath.Combine(Def.Source, A)) <>
           TFile.GetLastWriteTime(TPath.Combine(Def.Destination, A)) then
        begin
          L.Add(TFileInfo.Create(Def.Source, A, foUpdate));
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
        end;
      end;
    end;
  finally
    DS_Src.Free;
    DS_Dest.Free;
  end;
end;

procedure TEngine.DoDefinition(Def: TDefinition);
var
  L: TLstFileInfo;
  FI: TFileInfo;
  A, SourceFile, DestFile, DestDirectory: string;
begin
  Log('@'+Def.Name);
  Status(string.Empty);

  if not TDirectory.Exists(Def.Source) then
    raise Exception.Create('Source not found');

  if not TDirectory.Exists(Def.Destination) then
    raise Exception.Create('Destination not found');

  L := TLstFileInfo.Create;
  try
    DoScan(Def, L);

    TotalSize := 0;
    CurrentSize := 0;

    for FI in L do
    begin
      if FI.Operation in [foAppend, foUpdate] then
        TotalSize := TotalSize + FI.Size;
    end;

    for FI in L do
    begin
      A := FI.RelativePath;

      SourceFile := TPath.Combine(Def.Source, A);
      DestFile := TPath.Combine(Def.Destination, A);

      case FI.Operation of
        foAppend:
        begin
          Log('+'+A, False);
          Status('Appending '+A, False);

          DestDirectory := ExtractFilePath(DestFile);
          if not TDirectory.Exists(DestDirectory) then
            ForceDirectories(DestDirectory);

          CopyFile(SourceFile, DestFile);
        end;

        foUpdate:
        begin
          Log('~'+A, False);
          Status('Updating '+A, False);

          CopyFile(SourceFile, DestFile);
        end;

        foDelete:
        begin
          Log('-'+A, False);
          Status('Deleting '+A, False);

          TFile.Delete(DestFile);
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

procedure TEngine.CopyFile(SourceFile, DestinationFile: string);
const
  MaxBufSize = $F000;
var
  SourceStm, DestStm: TFileStream;
  BufSize, N: Integer;
  Buffer: TBytes;
  Count: Int64;
begin
  SourceStm := TFileStream.Create(SourceFile, fmOpenRead);
  try
    DestStm := TFileStream.Create(DestinationFile, fmCreate);
    try
      Count := SourceStm.Size;
      if Count > MaxBufSize then BufSize := MaxBufSize else BufSize := Count;
      SetLength(Buffer, BufSize);
      try
        while Count <> 0 do
        begin
          if Count > BufSize then N := BufSize else N := Count;
          SourceStm.ReadBuffer(Buffer, N);
          DestStm.WriteBuffer(Buffer, N);
          Dec(Count, N);

          CurrentSize := CurrentSize + N;
          Percent(Trunc(CurrentSize / TotalSize * 100));
        end;
      finally
        SetLength(Buffer, 0);
      end;
    finally
      DestStm.Free;
    end;
  finally
    SourceStm.Free;
  end;

  TFile.SetLastWriteTime(DestinationFile, TFile.GetLastWriteTime(SourceFile));
end;

end.
