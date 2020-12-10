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
  A: string;
begin
  S := TStringList.Create;
  try
    S.Text := DefinitionMasks;

    for I := S.Count-1 downto 0 do
    begin
      A := Trim(S[I]);

      if A.IsEmpty or A.StartsWith('//') then S.Delete(I);
    end;

    Result := S.Text;
  finally
    S.Free;
  end;
end;

end.
