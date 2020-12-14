program Updater;

uses
  Vcl.Forms,
  Vcl.Themes,
  Vcl.Styles,
  UFrmMain in 'UFrmMain.pas' {FrmMain},
  UFrmDefinition in 'UFrmDefinition.pas' {FrmDefinition},
  UFrmMasksManage in 'UFrmMasksManage.pas' {FrmMasksManage},
  UFrmMasksEdit in 'UFrmMasksEdit.pas' {FrmMasksEdit},
  UConfig in 'UConfig.pas',
  URegistry in 'URegistry.pas',
  UEngine in 'UEngine.pas',
  UMasks in 'UMasks.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Charcoal Dark Slate');
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
