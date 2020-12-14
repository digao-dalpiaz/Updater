unit UCommon;

interface

uses Vcl.Graphics, System.Types, Vcl.StdCtrls;

procedure InitDrawItem(C: TCanvas; Rect: TRect; State: TOwnerDrawState);
procedure EnableEditDirectoryAutoComplete(Edit: TEdit);
procedure ShowMasksHelp;

implementation

uses Winapi.Windows, System.SysUtils, Vcl.Dialogs;

procedure InitDrawItem(C: TCanvas; Rect: TRect; State: TOwnerDrawState);
begin
  if odSelected in State then C.Brush.Color := $00984603;
  C.FillRect(Rect);

  C.Font.Color := clWhite;
end;

function SHAutoComplete(hwndEdit: HWnd; dwFlags: DWORD): HResult; stdcall;
  external 'Shlwapi.dll';

procedure EnableEditDirectoryAutoComplete(Edit: TEdit);
const
  SHACF_AUTOSUGGEST_FORCE_ON = $10000000;
  SHACF_FILESYS_DIRS = $00000020;
begin
  if SHAutoComplete(Edit.Handle,
    SHACF_AUTOSUGGEST_FORCE_ON or SHACF_FILESYS_DIRS)<>S_OK then
    raise Exception.Create('Error calling SHAutoComplete');
end;

procedure ShowMasksHelp;
begin
  ShowMessage(
    'Masks help:'+#13+
    #13+
    '- Line starting with "//" means comment line.'+#13+
    '- You can use "*" and "?" masks.'+#13+
    '- You can specify only file name part, like "abc*.txt".'+#13+
    '- You can specify relative path, like "folder\*.txt" or "*\folder\*"'+#13+
    '- To use masks tables, specify a line with ":" prefix and the name of table. Example: ":MY_MASKS"'+#13+
    '- If you want to force only file name part, use "<F>" prefix. Example: "<F>*abc*". This won''t consider folders part.'
  );
end;

end.
