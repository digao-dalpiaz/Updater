unit UCommon;

interface

uses Vcl.Graphics, System.Types, Vcl.StdCtrls;

procedure InitDrawItem(C: TCanvas; Rect: TRect; State: TOwnerDrawState);
procedure EnableEditDirectoryAutoComplete(Edit: TEdit);

implementation

uses Winapi.Windows, System.SysUtils;

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

end.
