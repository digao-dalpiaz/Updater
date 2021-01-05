unit UFrmCustomization;

interface

uses Vcl.Forms, Vcl.StdCtrls, Vcl.Controls, Vcl.ExtCtrls, System.Classes;

type
  TFrmCustomization = class(TForm)
    CkCheckForNewVersion: TCheckBox;
    BottomLine: TBevel;
    BtnOK: TButton;
    BtnCancel: TButton;
    CkSecureMode: TCheckBox;
    CkWriteLogFile: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
  end;

var
  FrmCustomization: TFrmCustomization;

procedure DoCustomization;

implementation

{$R *.dfm}

uses UConfig, UFrmMain;

procedure DoCustomization;
begin
  FrmCustomization := TFrmCustomization.Create(Application);
  FrmCustomization.ShowModal;
  FrmCustomization.Free;
end;

procedure TFrmCustomization.FormCreate(Sender: TObject);
begin
  Width := Width+8; //fix theme behavior

  CkCheckForNewVersion.Checked := Config.CheckForNewVersion;
  CkWriteLogFile.Checked := Config.WriteLogFile;
  CkSecureMode.Checked := Config.SecureMode;
end;

procedure TFrmCustomization.BtnOKClick(Sender: TObject);
begin
  Config.CheckForNewVersion := CkCheckForNewVersion.Checked;
  Config.WriteLogFile := CkWriteLogFile.Checked;
  Config.SecureMode := CkSecureMode.Checked;

  FrmMain.UpdSecureMode;

  ModalResult := mrOk;
end;

end.
