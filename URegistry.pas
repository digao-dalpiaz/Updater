unit URegistry;

interface

type
  TCustomization = class
  public
    class procedure LoadRegistry;
    class procedure SaveRegistry;
  end;

implementation

uses System.Win.Registry, Winapi.Windows, System.SysUtils, System.UITypes,
  UFrmMain;

const KEY = 'SOFTWARE\Digao\Updater';

class procedure TCustomization.LoadRegistry;
var
  R: TRegistry;

  function ReadIntDef(const Name: string; Default: Integer): Integer;
  begin
    if R.ValueExists(Name) then
      Result := R.ReadInteger(Name)
    else
      Result := Default;
  end;

var
  WP: TWindowPlacement;
begin
  R := TRegistry.Create;
  try
    R.RootKey := HKEY_CURRENT_USER;
    if R.OpenKeyReadOnly(KEY) then
    begin
      WP.rcNormalPosition.Left := ReadIntDef('X', FrmMain.Left);
      WP.rcNormalPosition.Top := ReadIntDef('Y', FrmMain.Top);
      WP.rcNormalPosition.Width := ReadIntDef('W', FrmMain.Width);
      WP.rcNormalPosition.Height := ReadIntDef('H', FrmMain.Height);

      WP.length := SizeOf(WP);
      SetWindowPlacement(FrmMain.Handle, WP);

      if ReadIntDef('Max', Integer(False)) = Integer(True) then
        FrmMain.WindowState := TWindowState.wsMaximized;

      FrmMain.LDefs.Height := ReadIntDef('DefinitionsHeight', FrmMain.LDefs.Height);
    end;
  finally
    R.Free;
  end;
end;

class procedure TCustomization.SaveRegistry;
var
  R: TRegistry;
  WP: TWindowPlacement;
begin
  R := TRegistry.Create;
  try
    R.RootKey := HKEY_CURRENT_USER;
    if not R.OpenKey(Key, True) then
      raise Exception.Create('Cannot create registry key');

    WP.length := SizeOf(WP);
    GetWindowPlacement(FrmMain.Handle, WP);

    R.WriteInteger('X', WP.rcNormalPosition.Left);
    R.WriteInteger('Y', WP.rcNormalPosition.Top);
    R.WriteInteger('W', WP.rcNormalPosition.Width);
    R.WriteInteger('H', WP.rcNormalPosition.Height);

    R.WriteInteger('Max', Integer(FrmMain.WindowState=TWindowState.wsMaximized));

    R.WriteInteger('DefinitionsHeight', FrmMain.LDefs.Height);
  finally
    R.Free;
  end;
end;

end.
