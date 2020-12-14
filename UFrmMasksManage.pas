unit UFrmMasksManage;

interface

uses Vcl.Forms, Vcl.Controls, Vcl.StdCtrls, System.Classes, Vcl.Buttons,
 //
 UConfig, System.Types;

type
  TFrmMasksManage = class(TForm)
    L: TListBox;
    BtnAdd: TSpeedButton;
    BtnDel: TSpeedButton;
    BtnMod: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure BtnAddClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
    procedure LClick(Sender: TObject);
    procedure LDrawItem(Control: TWinControl; Index: Integer; Rect: TRect;
      State: TOwnerDrawState);
    procedure BtnModClick(Sender: TObject);
    procedure LDblClick(Sender: TObject);
  private
    procedure LoadTables;
    procedure UpdateButtons;

    function GetSelectedTable: TMasksTable;
  end;

var
  FrmMasksManage: TFrmMasksManage;

procedure DoMasksManage;

implementation

{$R *.dfm}

uses Vcl.Graphics, Winapi.Windows, UFrmMasksEdit, UFrmMain,
  Vcl.Dialogs, System.UITypes;

procedure DoMasksManage;
begin
  FrmMasksManage := TFrmMasksManage.Create(Application);
  FrmMasksManage.ShowModal;
  FrmMasksManage.Free;
end;

procedure TFrmMasksManage.FormCreate(Sender: TObject);
begin
  Width := Width+8; //fix theme behavior

  LoadTables;
  UpdateButtons;
end;

procedure TFrmMasksManage.LoadTables;
var
  M: TMasksTable;
begin
  for M in Config.MasksTables do
    L.Items.AddObject(M.Name, M);
end;

function TFrmMasksManage.GetSelectedTable: TMasksTable;
begin
  Result := TMasksTable(L.Items.Objects[L.ItemIndex]);
end;

procedure TFrmMasksManage.UpdateButtons;
var
  Sel: Boolean;
begin
  Sel := L.ItemIndex <> -1;

  BtnMod.Enabled := Sel;
  BtnDel.Enabled := Sel;
end;

procedure TFrmMasksManage.LClick(Sender: TObject);
begin
  UpdateButtons;
end;

procedure TFrmMasksManage.LDblClick(Sender: TObject);
begin
  if BtnMod.Enabled then
    BtnMod.Click;
end;

procedure TFrmMasksManage.LDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
begin
  if odSelected in State then L.Canvas.Brush.Color := $00984603;
  L.Canvas.FillRect(Rect);

  L.Canvas.Font.Color := clWhite;
  FrmMain.IL_Masks.Draw(L.Canvas, 3, Rect.Top+2, 0);
  L.Canvas.TextOut(22, Rect.Top+3, L.Items[Index]);
end;

procedure TFrmMasksManage.BtnAddClick(Sender: TObject);
var
  M: TMasksTable;
  Index: Integer;
begin
  if DoMasksEdit(False, M) then
  begin
    Index := L.Items.AddObject(M.Name, M);
    L.ItemIndex := Index;

    UpdateButtons;
  end;
end;

procedure TFrmMasksManage.BtnModClick(Sender: TObject);
var
  M: TMasksTable;
begin
  M := GetSelectedTable;
  if DoMasksEdit(True, M) then
  begin
    L.Items[L.ItemIndex] := M.Name;
  end;
end;

procedure TFrmMasksManage.BtnDelClick(Sender: TObject);
var
  M: TMasksTable;
begin
  M := GetSelectedTable;
  if MessageDlg('Do you want to remove masks table "'+M.Name+'"?',
    mtConfirmation, mbYesNo, 0) = mrYes then
  begin
    Config.MasksTables.Remove(M);
    L.DeleteSelected;

    UpdateButtons;
  end;
end;

end.
