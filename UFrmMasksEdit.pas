unit UFrmMasksEdit;

interface

uses Vcl.Forms, Vcl.StdCtrls, Vcl.Controls, System.Classes,
  //
  UConfig;

type
  TFrmMasksEdit = class(TForm)
    Label1: TLabel;
    EdName: TEdit;
    Label3: TLabel;
    EdMasks: TMemo;
    BtnOK: TButton;
    BtnCancel: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
  private
    Edit: Boolean;
    MasksTable: TMasksTable;

    function NameAlreadyExists: Boolean;
  end;

var
  FrmMasksEdit: TFrmMasksEdit;

function DoMasksEdit(Edit: Boolean; var MasksTable: TMasksTable): Boolean;

implementation

{$R *.dfm}

uses System.SysUtils, Vcl.Dialogs, System.UITypes;

function DoMasksEdit;
begin
  FrmMasksEdit := TFrmMasksEdit.Create(Application);
  FrmMasksEdit.Edit := Edit;
  FrmMasksEdit.MasksTable := MasksTable;
  Result := FrmMasksEdit.ShowModal = mrOk;
  if Result then MasksTable := FrmMasksEdit.MasksTable;  
  FrmMasksEdit.Free;
end;

procedure TFrmMasksEdit.FormCreate(Sender: TObject);
begin
  Width := Width+8; //fix theme behavior
end;

procedure TFrmMasksEdit.FormShow(Sender: TObject);
begin
  if Edit then
  begin
    Caption := 'Edit Masks Table';

    EdName.Text := MasksTable.Name;
    EdMasks.Text := MasksTable.Masks;
  end;
end;

procedure TFrmMasksEdit.BtnOKClick(Sender: TObject);
begin
  EdName.Text := Trim(EdName.Text);
  if EdName.Text = string.Empty then
  begin
    MessageDlg('Name is empty', mtError, [mbOK], 0);
    EdName.SetFocus;
    Exit;
  end;

  if NameAlreadyExists then
  begin
    MessageDlg('Name already exists', mtError, [mbOK], 0);
    EdName.SetFocus;
    Exit;
  end;

  //

  if not Edit then
  begin
    MasksTable := TMasksTable.Create;
    Config.MasksTables.Add(MasksTable);
  end;

  MasksTable.Name := EdName.Text;
  MasksTable.Masks := EdMasks.Text;

  ModalResult := mrOk;
end;

function TFrmMasksEdit.NameAlreadyExists: Boolean;
var
  M: TMasksTable;
begin
  M := Config.FindMasksTable(EdName.Text);

  Result := (M<>nil) and (M<>MasksTable);
end;

end.
