unit UFrmMasksTables;

interface

uses Vcl.Forms, Vcl.Buttons, Vcl.StdCtrls, Vcl.Controls, System.Classes,
  //
  UConfig, Vcl.ExtCtrls;

type
  TFrmMasksTables = class(TForm)
    L: TListBox;
    Label2: TLabel;
    BtnAdd: TSpeedButton;
    BtnDel: TSpeedButton;
    BoxTable: TPanel;
    EdMasks: TMemo;
    Label3: TLabel;
    EdName: TEdit;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure BtnAddClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
    procedure LClick(Sender: TObject);
    procedure EditsOfTabkeChange(Sender: TObject);
  private
    LoadingTable: Boolean;

    procedure LoadTables;
    procedure UpdatePanel;

    function GetSelectedTable: TMaskTable;
  end;

var
  FrmMasksTables: TFrmMasksTables;

implementation

{$R *.dfm}

uses System.SysUtils;

procedure TFrmMasksTables.FormCreate(Sender: TObject);
begin
  Width := Width+8; //fix theme behavior

  LoadTables;
  UpdatePanel;
end;

procedure TFrmMasksTables.LoadTables;
var
  M: TMaskTable;
begin
  for M in Config.LstMaskTable do
    L.Items.AddObject(M.Name, M);
end;

function TFrmMasksTables.GetSelectedTable: TMaskTable;
begin
  Result := TMaskTable(L.Items.Objects[L.ItemIndex]);
end;

procedure TFrmMasksTables.UpdatePanel;
var
  Sel: Boolean;
  M: TMaskTable;
begin
  Sel := L.ItemIndex <> -1;

  BtnDel.Enabled := Sel;
  BoxTable.Enabled := Sel;

  LoadingTable := True;
  try
    if Sel then
    begin
      M := GetSelectedTable;

      EdName.Text := M.Name;
      EdMasks.Text := M.Masks;
    end else
    begin
      EdName.Text := string.Empty;
      EdMasks.Text := string.Empty;
    end;
  finally
    LoadingTable := False;
  end;
end;

procedure TFrmMasksTables.LClick(Sender: TObject);
begin
  UpdatePanel;
end;

procedure TFrmMasksTables.BtnAddClick(Sender: TObject);
var
  M: TMaskTable;
  Index: Integer;
begin
  M := TMaskTable.Create;
  Config.LstMaskTable.Add(M);

  M.Name := 'NEW_TABLE';
  Index := L.Items.AddObject(M.Name, M);
  L.ItemIndex := Index;

  UpdatePanel;
end;

procedure TFrmMasksTables.BtnDelClick(Sender: TObject);
var
  M: TMaskTable;
begin
  M := GetSelectedTable;

  Config.LstMaskTable.Remove(M);
  L.DeleteSelected;

  UpdatePanel;
end;

procedure TFrmMasksTables.EditsOfTabkeChange(Sender: TObject);
var
  M: TMaskTable;
begin
  if LoadingTable then Exit;  

  M := GetSelectedTable;

  M.Name := Trim(EdName.Text);
  M.Masks := EdMasks.Text;

  if L.Items[L.ItemIndex]<>M.Name then
    L.Items[L.ItemIndex] := M.Name;
end;

end.
