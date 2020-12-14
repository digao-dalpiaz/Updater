unit UFrmMasksAutoComplete;

interface

uses Vcl.Forms, System.Classes, Vcl.Controls, Vcl.StdCtrls,
 //
 System.Types, Vcl.ExtCtrls;

type
  TFrmMasksAutoComplete = class(TForm)
    L: TListBox;
    Panel2: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure LKeyPress(Sender: TObject; var Key: Char);
    procedure LDblClick(Sender: TObject);
    procedure LDrawItem(Control: TWinControl; Index: Integer; Rect: TRect;
      State: TOwnerDrawState);
  private
    Memo: TMemo;

    procedure FillList;
    procedure Select;
  end;

var
  FrmMasksAutoComplete: TFrmMasksAutoComplete;

procedure DoMasksAutoComplete(Memo: TMemo);

implementation

{$R *.dfm}

uses UConfig, UCommon, Winapi.Windows, Winapi.Messages,
  UFrmMain, System.SysUtils;

function GetMemoCaretPos(Memo: TMemo): TPoint;
var
  _N: NativeInt;
begin
  _N := SendMessage(Memo.Handle, EM_POSFROMCHAR, Memo.SelStart-1, 0);
  Result := TPoint.Create(LoWord(_N), HiWord(_N));
  Result := Memo.ClientToScreen(Result);
end;

procedure DoMasksAutoComplete;
var
  P: TPoint;
begin
  if Config.MasksTables.Count=0 then
    raise Exception.Create('No masks table available');

  FrmMasksAutoComplete := TFrmMasksAutoComplete.Create(Application);
  FrmMasksAutoComplete.Memo := Memo;

  P := GetMemoCaretPos(Memo);
  FrmMasksAutoComplete.Left := P.X+4;
  FrmMasksAutoComplete.Top := P.Y+15;

  FrmMasksAutoComplete.Show;
end;

procedure TFrmMasksAutoComplete.FormCreate(Sender: TObject);
begin
  FillList;
  L.ItemIndex := 0;
end;

procedure TFrmMasksAutoComplete.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TFrmMasksAutoComplete.FormDeactivate(Sender: TObject);
begin
  Close;
end;

procedure TFrmMasksAutoComplete.FillList;
var
  M: TMasksTable;
begin
  for M in Config.MasksTables do
    L.Items.Add(M.Name);
end;

procedure TFrmMasksAutoComplete.LDblClick(Sender: TObject);
begin
  Select;
end;

procedure TFrmMasksAutoComplete.LDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
begin
  InitDrawItem(L.Canvas, Rect, State);

  FrmMain.IL_Masks.Draw(L.Canvas, 3, Rect.Top+2, 0);
  L.Canvas.TextOut(22, Rect.Top+3, L.Items[Index]);
end;

procedure TFrmMasksAutoComplete.LKeyPress(Sender: TObject; var Key: Char);
begin
  case Key of
    #13: Select;
    #27: Close;
  end;
end;

procedure TFrmMasksAutoComplete.Select;
begin
  if L.ItemIndex = -1 then Exit;

  Memo.SelText := L.Items[L.ItemIndex];
  Close;
end;

end.
