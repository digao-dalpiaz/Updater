unit UFrmMain;

interface

uses Vcl.Forms, Vcl.ComCtrls, Vcl.Buttons, Vcl.StdCtrls, Vcl.Controls,
  Vcl.ExtCtrls, Vcl.CheckLst, System.ImageList, Vcl.ImgList, System.Classes,
  Vcl.ToolWin,
  //
  UConfig, System.Types;

type
  TFrmMain = class(TForm)
    ToolBar: TToolBar;
    BtnNew: TToolButton;
    BtnEdit: TToolButton;
    BtnRemove: TToolButton;
    ToolButton4: TToolButton;
    BtnUp: TToolButton;
    BtnDown: TToolButton;
    ToolButton7: TToolButton;
    BtnMasks: TToolButton;
    ToolButton9: TToolButton;
    BtnExecute: TToolButton;
    IL: TImageList;
    LDefs: TCheckListBox;
    LLogs: TListBox;
    Splitter1: TSplitter;
    BoxProgress: TPanel;
    LbStatus: TLabel;
    BtnStop: TSpeedButton;
    ProgressBar: TProgressBar;
    Label1: TLabel;
    LbTotalSize: TLabel;
    Label3: TLabel;
    LbCurrentSize: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BtnNewClick(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
    procedure BtnRemoveClick(Sender: TObject);
    procedure BtnUpClick(Sender: TObject);
    procedure BtnDownClick(Sender: TObject);
    procedure LDefsClick(Sender: TObject);
    procedure LDefsClickCheck(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BtnExecuteClick(Sender: TObject);
    procedure LLogsDrawItem(Control: TWinControl; Index: Integer; Rect: TRect;
      State: TOwnerDrawState);
    procedure BtnStopClick(Sender: TObject);
  private
    EngineRunning: Boolean;

    procedure FillDefinitions;
    procedure MoveDefinition(Flag: Integer);
    function AddDefinition(Def: TDefinition): Integer;
    function GetSelectedDefinition: TDefinition;
    procedure UpdateButtons;
  public
    procedure SetControlsState(Active: Boolean);
  end;

var
  FrmMain: TFrmMain;

implementation

{$R *.dfm}

uses Winapi.Windows, Vcl.Dialogs, System.UITypes, Vcl.Graphics,
  UFrmDefinition, UEngine;

procedure TFrmMain.FormCreate(Sender: TObject);
begin
  ReportMemoryLeaksOnShutdown := True;

  Config := TConfig.Create;
  Config.LoadDefinitions;

  FillDefinitions;

  UpdateButtons;
end;

procedure TFrmMain.FormDestroy(Sender: TObject);
begin
  Config.SaveDefinitions;
  Config.Free;
end;

procedure TFrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if EngineRunning then
  begin
    CanClose := False;
    MessageDlg('There is a process running', mtError, [mbOK], 0);
  end;
end;

procedure TFrmMain.UpdateButtons;
var
  Sel: Boolean;
begin
  Sel := LDefs.ItemIndex <> -1;

  BtnEdit.Enabled := Sel;
  BtnRemove.Enabled := Sel;

  BtnUp.Enabled := Sel and (LDefs.ItemIndex > 0);
  BtnDown.Enabled := Sel and (LDefs.ItemIndex < LDefs.Count-1);
end;

procedure TFrmMain.LDefsClick(Sender: TObject);
begin
  UpdateButtons;
end;

procedure TFrmMain.LDefsClickCheck(Sender: TObject);
var
  D: TDefinition;
begin
  D := GetSelectedDefinition;
  D.Checked := LDefs.Checked[LDefs.ItemIndex];
end;

function TFrmMain.GetSelectedDefinition: TDefinition;
begin
  Result := TDefinition(LDefs.Items.Objects[LDefs.ItemIndex]);
end;

function TFrmMain.AddDefinition(Def: TDefinition): Integer;
begin
  Result := LDefs.Items.AddObject(Def.Name, Def);
end;

procedure TFrmMain.FillDefinitions;
var
  D: TDefinition;
  Index: Integer;
begin
  for D in Config.LstDefinition do
  begin
    Index := AddDefinition(D);
    LDefs.Checked[Index] := D.Checked;
  end;
end;

procedure TFrmMain.BtnNewClick(Sender: TObject);
var
  D: TDefinition;
  Index: Integer;
begin
  if DoEditDefinition(False, D) then
  begin
    Index := AddDefinition(D);
    LDefs.ItemIndex := Index;

    UpdateButtons;
  end;
end;

procedure TFrmMain.BtnEditClick(Sender: TObject);
var
  D: TDefinition;
begin
  D := GetSelectedDefinition;
  if DoEditDefinition(True, D) then
  begin
    LDefs.Items[LDefs.ItemIndex] := D.Name;
  end;
end;

procedure TFrmMain.BtnRemoveClick(Sender: TObject);
var
  D: TDefinition;
begin
  D := GetSelectedDefinition;
  if MessageDlg('Do you want to remove definition "'+D.Name+'"?',
    mtConfirmation, mbYesNo, 0) = mrYes then
  begin
    Config.LstDefinition.Remove(D);
    LDefs.DeleteSelected;

    UpdateButtons;
  end;
end;

procedure TFrmMain.MoveDefinition(Flag: Integer);
var
  Index, NewIndex: Integer;
begin
  Index := LDefs.ItemIndex;
  NewIndex := Index + Flag;

  Config.LstDefinition.Exchange(Index, NewIndex);
  LDefs.Items.Exchange(Index, NewIndex);

  UpdateButtons;
end;

procedure TFrmMain.BtnUpClick(Sender: TObject);
begin
  MoveDefinition(-1);
end;

procedure TFrmMain.BtnDownClick(Sender: TObject);
begin
  MoveDefinition(+1);
end;

procedure TFrmMain.BtnExecuteClick(Sender: TObject);
var
  Eng: TEngine;
begin
  SetControlsState(False);
  LLogs.Clear;

  Eng := TEngine.Create;
  Eng.Start;
end;

procedure TFrmMain.SetControlsState(Active: Boolean);
begin
  EngineRunning := not Active;
  BoxProgress.Visible := not Active;

  ToolBar.Visible := Active;
  LDefs.Enabled := Active;
end;

procedure TFrmMain.BtnStopClick(Sender: TObject);
begin
  BtnStop.Enabled := False;
end;

procedure TFrmMain.LLogsDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  A: string;
begin
  if odSelected in State then LLogs.Canvas.Brush.Color := clBlack;
  LLogs.Canvas.FillRect(Rect);

  A := LLogs.Items[Index];
  case A[1] of
    '@': LLogs.Canvas.Font.Style := [fsBold];
    '#': LLogs.Canvas.Font.Color := $006C6CFF;
    '+': LLogs.Canvas.Font.Color := $0000D900;
    '~': LLogs.Canvas.Font.Color := $00C7B96D;
    '-': LLogs.Canvas.Font.Color := $009A9A9A;
  end;

  Delete(A, 1, 1);
  LLogs.Canvas.TextOut(Rect.Left+2, Rect.Top, A);
end;

end.
