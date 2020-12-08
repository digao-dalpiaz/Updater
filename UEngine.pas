unit UEngine;

interface

uses System.Classes, UConfig;

type
 TEngine = class(TThread)
  protected
    procedure Execute; override;
  private
    LogQueue: TStringList;
    StatusQueue: string;    
    LastTick: Cardinal;
    procedure Log(const Text: string; ForceUpdate: Boolean = True);
    procedure Status(const Text: string; ForceUpdate: Boolean = True);
    procedure PrintLogQueue;

    procedure DoDefinition(Def: TDefinition);
    procedure CheckForQueueFlush(ForceUpdate: Boolean);
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

  LogQueue := TStringList.Create;
  LastTick := GetTickCount;
end;

destructor TEngine.Destroy;
begin
  LogQueue.Free;

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

  PrintLogQueue; //remaining log
end;

procedure TEngine.Log(const Text: string; ForceUpdate: Boolean);
begin
  LogQueue.Add(Text);

  CheckForQueueFlush(ForceUpdate);
end;

procedure TEngine.Status(const Text: string; ForceUpdate: Boolean);
begin
  StatusQueue := Text;

  CheckForQueueFlush(ForceUpdate);
end;

procedure TEngine.CheckForQueueFlush(ForceUpdate: Boolean);
begin
  if ForceUpdate or (GetTickCount > LastTick+1000) then
  begin
    PrintLogQueue;    

    LastTick := GetTickCount;
  end;
end;

procedure TEngine.PrintLogQueue;
begin
  Synchronize(
    procedure
    var
      A: string;
    begin
      for A in LogQueue do
        FrmMain.LLogs.Items.Add(A);

      FrmMain.LbStatus.Caption := StatusQueue;
    end);

  LogQueue.Clear;
end;

procedure TEngine.DoDefinition(Def: TDefinition);

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
  Log('@'+Def.Name);
  Status(string.Empty);

  if not TDirectory.Exists(Def.Source) then
    raise Exception.Create('Source not found');

  if not TDirectory.Exists(Def.Destination) then
    raise Exception.Create('Destination not found');

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
        Log('+'+A, False);
      end else
      begin
        //existent file
        if TFile.GetLastWriteTime(TPath.Combine(DS_Src.Dir, A)) <>
           TFile.GetLastWriteTime(TPath.Combine(DS_Dest.Dir, A)) then
          Log('~'+A, False);
      end;
    end;  

    for A in DS_Dest.List do
    begin
      if DS_Src.List.IndexOf(A) = -1 then
      begin
        //removed file
        Log('-'+A, False);
      end;
    end;

  finally
    DS_Src.Free;
    DS_Dest.Free;
  end;
end;

end.
