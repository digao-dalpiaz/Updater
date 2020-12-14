unit UFrmDefinition;

interface

uses Vcl.Forms, Vcl.Buttons, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Controls,
  System.Classes,
  //
  UConfig;

type
  TFrmDefinition = class(TForm)
    LbName: TLabel;
    EdName: TEdit;
    LbSource: TLabel;
    EdSource: TEdit;
    LbDestination: TLabel;
    EdDestination: TEdit;
    LbInclusions: TLabel;
    LbExclusions: TLabel;
    EdInclusions: TMemo;
    EdExclusions: TMemo;
    CkRecursive: TCheckBox;
    CkDelete: TCheckBox;
    BtnOK: TButton;
    BtnCancel: TButton;
    BottomLine: TBevel;
    BtnSourceFolder: TSpeedButton;
    BtnDestinationFolder: TSpeedButton;
    procedure FormShow(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
    procedure BtnSourceFolderClick(Sender: TObject);
    procedure BtnDestinationFolderClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure EdMasksKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EdMasksKeyPress(Sender: TObject; var Key: Char);
  private
    Edit: Boolean;
    Def: TDefinition;

    LastKeyIsMasksIdent: Boolean;
  end;

var
  FrmDefinition: TFrmDefinition;

function DoEditDefinition(Edit: Boolean; var Def: TDefinition): Boolean;

implementation

{$R *.dfm}

uses System.SysUtils, Vcl.Dialogs, System.UITypes, Vcl.FileCtrl,
  UFrmMasksAutoComplete, UCommon;

function DoEditDefinition;
begin
  FrmDefinition := TFrmDefinition.Create(Application);
  FrmDefinition.Edit := Edit;
  FrmDefinition.Def := Def;
  Result := FrmDefinition.ShowModal = mrOk;
  if Result then Def := FrmDefinition.Def;
  FrmDefinition.Free;
end;

procedure TFrmDefinition.FormCreate(Sender: TObject);
begin
  Width := Width+8; //fix theme behavior

  EnableEditDirectoryAutoComplete(EdSource);
  EnableEditDirectoryAutoComplete(EdDestination);
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

  procedure ValidateEdit(Ed: TEdit; const Name: string);
  begin
    Ed.Text := Trim(Ed.Text);
    if Ed.Text = string.Empty then
    begin
      MessageDlg(Name+' is empty', mtError, [mbOK], 0);
      Ed.SetFocus;
      Abort;
    end;
  end;

begin
  ValidateEdit(EdName, 'Name');
  ValidateEdit(EdSource, 'Source');
  ValidateEdit(EdDestination, 'Destination');

  //

  if not Edit then
  begin
    Def := TDefinition.Create;
    Config.Definitions.Add(Def);
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

procedure TFrmDefinition.BtnSourceFolderClick(Sender: TObject);
var
  Dir: string;
begin
  Dir := EdSource.Text;
  if SelectDirectory('Source folder:', string.Empty, Dir) then
    EdSource.Text := Dir;
end;

procedure TFrmDefinition.BtnDestinationFolderClick(Sender: TObject);
var
  Dir: string;
begin
  Dir := EdDestination.Text;
  if SelectDirectory('Destination folder:', string.Empty, Dir) then
    EdDestination.Text := Dir;
end;

procedure TFrmDefinition.EdMasksKeyPress(Sender: TObject; var Key: Char);
begin
  if Key=':' then
    LastKeyIsMasksIdent := True;
end;

procedure TFrmDefinition.EdMasksKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if LastKeyIsMasksIdent then
  begin
    LastKeyIsMasksIdent := False;
    DoMasksAutoComplete(TMemo(Sender));
  end;
end;

end.
