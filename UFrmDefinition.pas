unit UFrmDefinition;

interface

uses Vcl.Forms, Vcl.StdCtrls, Vcl.Controls, System.Classes,
  //
  UConfig;

type
  TFrmDefinition = class(TForm)
    Label1: TLabel;
    EdName: TEdit;
    Label2: TLabel;
    EdSource: TEdit;
    Label3: TLabel;
    EdDestination: TEdit;
    Label4: TLabel;
    Label5: TLabel;
    EdInclusions: TMemo;
    EdExclusions: TMemo;
    CkRecursive: TCheckBox;
    CkDelete: TCheckBox;
    BtnOK: TButton;
    BtnCancel: TButton;
    procedure FormShow(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
  private
    Edit: Boolean;
    Def: TDefinition;
  end;

var
  FrmDefinition: TFrmDefinition;

function DoEditDefinition(Edit: Boolean; var Def: TDefinition): Boolean;

implementation

{$R *.dfm}

uses System.SysUtils, Vcl.Dialogs, System.UITypes;

function DoEditDefinition;
begin
  FrmDefinition := TFrmDefinition.Create(Application);
  FrmDefinition.Edit := Edit;
  FrmDefinition.Def := Def;
  Result := FrmDefinition.ShowModal = mrOk;
  if Result then Def := FrmDefinition.Def;  
  FrmDefinition.Free;
end;

procedure TFrmDefinition.FormShow(Sender: TObject);
begin
  if Edit then
  begin
    Caption := 'Edit Definition';

    EdName.Text := Def.Name;
    EdSource.Text := Def.Source;
    EdDestination.Text := Def.Destination;
    EdInclusions.Text := Def.Inclusions;
    EdExclusions.Text := Def.Exclusions;
    CkRecursive.Checked := Def.Recursive;
    CkDelete.Checked := Def.Delete;
  end;
end;

procedure TFrmDefinition.BtnOKClick(Sender: TObject);
begin
  EdName.Text := Trim(EdName.Text);
  if EdName.Text = string.Empty then
  begin
    MessageDlg('Name is empty', mtError, [mbOK], 0);
    EdName.SetFocus;
    Exit;
  end;

  EdSource.Text := Trim(EdSource.Text);
  if EdSource.Text = string.Empty then
  begin
    MessageDlg('Source is empty', mtError, [mbOK], 0);
    EdSource.SetFocus;
    Exit;
  end;

  EdDestination.Text := Trim(EdDestination.Text);
  if EdDestination.Text = string.Empty then
  begin
    MessageDlg('Destination is empty', mtError, [mbOK], 0);
    EdDestination.SetFocus;
    Exit;
  end;

  //

  if not Edit then
  begin
    Def := TDefinition.Create;
    Config.LstDefinition.Add(Def);
  end;

  Def.Name := EdName.Text;
  Def.Source := EdSource.Text;
  Def.Destination := EdDestination.Text;
  Def.Inclusions := EdInclusions.Text;
  Def.Exclusions := EdExclusions.Text;
  Def.Recursive := CkRecursive.Checked;
  Def.Delete := CkDelete.Checked;

  ModalResult := mrOk;
end;

end.
