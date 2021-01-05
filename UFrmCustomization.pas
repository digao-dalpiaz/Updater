unit UFrmCustomization;

interface

uses Vcl.Forms, Vcl.StdCtrls, Vcl.Controls, Vcl.ExtCtrls, System.Classes;

type
  TFrmCustomization = class(TForm)
    CkNewVersion: TCheckBox;
    BottomLine: TBevel;
    BtnOK: TButton;
    BtnCancel: TButton;
    procedure FormCreate(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
  end;

var
  FrmCustomization: TFrmCustomization;

procedure DoCustomization;

implementation

{$R *.dfm}

uses UConfig;

procedure DoCustomization;
begin
  FrmCustomization := TFrmCustomization.Create(Application);
  FrmCustomization.ShowModal;
  FrmCustomization.Free;
end;

procedure TFrmCustomization.FormCreate(Sender: TObject);
begin
  Width := Width+8; //fix theme behavior

  CkNewVersion.Checked := Config.CheckForNewVersion;
end;

procedure TFrmCustomization.BtnOKClick(Sender: TObject);
begin
  Config.CheckForNewVersion := CkNewVersion.Checked;

  ModalResult := mrOk;
end;

end.
