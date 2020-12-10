program Updater;

uses
  Vcl.Forms,
  UFrmMain in 'UFrmMain.pas' {FrmMain},
  UConfig in 'UConfig.pas',
  UFrmDefinition in 'UFrmDefinition.pas' {FrmDefinition},
  UEngine in 'UEngine.pas',
  URegistry in 'URegistry.pas',
  Vcl.Themes,
  Vcl.Styles,
  UMasks in 'UMasks.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Charcoal Dark Slate');
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
