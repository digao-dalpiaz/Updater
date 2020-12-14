unit UCommon;

interface

uses Vcl.Graphics, System.Types, Vcl.StdCtrls;

procedure InitDrawItem(C: TCanvas; Rect: TRect; State: TOwnerDrawState);

implementation

uses Winapi.Windows;

procedure InitDrawItem(C: TCanvas; Rect: TRect; State: TOwnerDrawState);
begin
  if odSelected in State then C.Brush.Color := $00984603;
  C.FillRect(Rect);

  C.Font.Color := clWhite;
end;

end.
