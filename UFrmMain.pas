unit UFrmMain;

interface

uses Vcl.Forms, Vcl.ComCtrls, Vcl.Buttons, Vcl.StdCtrls, Vcl.Controls,
  Vcl.ExtCtrls, Vcl.CheckLst, System.ImageList, Vcl.ImgList, System.Classes,
  Vcl.ToolWin,
  //
  UConfig, System.Types;

type
  TFrmMain = class(TForm)
    IL: TImageList;
    LDefs: TCheckListBox;
    LLogs: TListBox;
    Splitter: TSplitter;
    BoxProgress: TPanel;
    LbStatus: TLabel;
    BtnStop: TSpeedButton;
    ProgressBar: TProgressBar;
    LbSize: TLabel;
    IL_Disabled: TImageList;
    IL_File: TImageList;
    BoxTop: TPanel;
    ToolBar: TToolBar;
    BtnNew: TToolButton;
    BtnEdit: TToolButton;
    BtnRemove: TToolButton;
    BtnSeparator1: TToolButton;
    BtnUp: TToolButton;
    BtnDown: TToolButton;
    BtnSeparator2: TToolButton;
    BtnMasks: TToolButton;
    BtnSeparator3: TToolButton;
    BtnExecute: TToolButton;
    BoxAbout: TPanel;
    LbDigao: TLinkLabel;
    LbVersion: TLabel;
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
    procedure LDefsDrawItem(Control: TWinControl; Index: Integer; Rect: TRect;
      State: TOwnerDrawState);
    procedure FormResize(Sender: TObject);
    procedure LbDigaoLinkClick(Sender: TObject; const Link: string;
      LinkType: TSysLinkType);
    procedure BtnMasksClick(Sender: TObject);
  private
    EngineRunning: Boolean;

    procedure FillDefinitions;
    procedure MoveDefinition(Flag: ShortInt);
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

uses Vcl.Dialogs, System.UITypes, Vcl.Graphics, System.SysUtils,
  Winapi.Windows, Winapi.ShellAPI,
  UFrmDefinition, UEngine, URegistry;

procedure TFrmMain.FormCreate(Sender: TObject);
begin
  ReportMemoryLeaksOnShutdown := True;

  TCustomization.LoadRegistry;

  Config := TConfig.Create;
  Config.LoadDefinitions;

  FillDefinitions;

  UpdateButtons;
end;

procedure TFrmMain.FormDestroy(Sender: TObject);
begin
  Config.SaveDefinitions;
  Config.Free;

  TCustomization.SaveRegistry;
end;

procedure TFrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if EngineRunning then
  begin
    CanClose := False;
    MessageDlg('There is a process running', mtError, [mbOK], 0);
  end;
end;

procedure TFrmMain.FormResize(Sender: TObject);
begin
  LDefs.Invalidate;
end;

procedure TFrmMain.LbDigaoLinkClick(Sender: TObject; const Link: string;
  LinkType: TSysLinkType);
begin
  ShellExecute(0, '', PChar(Link), '', '', SW_SHOWNORMAL);
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

procedure TFrmMain.LDefsDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  D: TDefinition;
begin
  if odSelected in State then LDefs.Canvas.Brush.Color := $00984603;
  LDefs.Canvas.FillRect(Rect);

  D := TDefinition(LDefs.Items.Objects[Index]);

  LDefs.Canvas.Font.Color := clWhite;
  LDefs.Canvas.TextOut(Rect.Left+2, Rect.Top+2, D.Name);
  if D.LastUpdate>0 then
  begin
    LDefs.Canvas.Font.Color := clGray;
    LDefs.Canvas.TextOut(Rect.Right-110, Rect.Top+2, DateTimeToStr(D.LastUpdate));
  end;
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

procedure TFrmMain.MoveDefinition(Flag: ShortInt);
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

procedure TFrmMain.BtnMasksClick(Sender: TObject);
begin
  raise Exception.Create('Not implemented yet');
end;

procedure TFrmMain.BtnExecuteClick(Sender: TObject);
var
  Eng: TEngine;
begin
  LLogs.Clear;

  LbStatus.Caption := string.Empty;
  LbSize.Caption := string.Empty;
  ProgressBar.Position := 0;

  BtnStop.Enabled := True;

  SetControlsState(False);

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
  IdxFile: Integer;
  Color: TColor;
begin
  if odSelected in State then LLogs.Canvas.Brush.Color := clBlack;
  LLogs.Canvas.FillRect(Rect);

  IdxFile := -1;

  A := LLogs.Items[Index];
  case A[1] of
    '@': Color := clWhite; //definition title
    ':': Color := clSilver; //general info
    '#': Color := $006C6CFF; //error
    '+': begin
           Color := $0000D900;
           IdxFile := 0;
         end;
    '~': begin
           Color := $00C7B96D;
           IdxFile := 1;
         end;
    '-': begin
           Color := $009A9A9A;
           IdxFile := 2;
         end;
    else raise Exception.Create('Invalid log prefix');
  end;

  Delete(A, 1, 1);

  LLogs.Canvas.Font.Color := Color;

  if IdxFile<>-1 then
  begin
    IL_File.Draw(LLogs.Canvas, 3, Rect.Top+1, IdxFile);
    LLogs.Canvas.TextOut(18, Rect.Top, A);
  end else
    LLogs.Canvas.TextOut(3, Rect.Top, A);
end;

end.
