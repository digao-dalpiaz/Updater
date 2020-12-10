unit UMasks;

interface

type
  TMasks = class
  public
    class function GetMasks(const DefinitionMasks: string): string;
  end;

implementation

uses System.Classes, System.SysUtils;

class function TMasks.GetMasks(const DefinitionMasks: string): string;
var
  S: TStringList;
  I: Integer;
begin
  S := TStringList.Create;
  try
    S.Text := DefinitionMasks;

    for I := S.Count downto 0 do
      if S[I].StartsWith('//') then S.Delete(I);

    Result := S.Text;
  finally
    S.Free;
  end;
end;

end.
