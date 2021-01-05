program Updater;

uses
  Vcl.Forms,
  Vcl.Themes,
  Vcl.Styles,
  UFrmMain in 'UFrmMain.pas' {FrmMain},
  UFrmDefinition in 'UFrmDefinition.pas' {FrmDefinition},
  UFrmMasksManage in 'UFrmMasksManage.pas' {FrmMasksManage},
  UFrmMasksEdit in 'UFrmMasksEdit.pas' {FrmMasksEdit},
  UFrmMasksAutoComplete in 'UFrmMasksAutoComplete.pas' {FrmMasksAutoComplete},
  UFrmCustomization in 'UFrmCustomization.pas' {FrmCustomization},
  UConfig in 'UConfig.pas',
  URegistry in 'URegistry.pas',
  UEngine in 'UEngine.pas',
  UMasks in 'UMasks.pas',
  UCommon in 'UCommon.pas',
  UVersionCheck in 'UVersionCheck.pas',
  UVars in 'UVars.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Charcoal Dark Slate');
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
