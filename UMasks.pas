unit UMasks;

interface

uses UConfig;

type
  TMasks = class
  private
    class function FindMaskTable(const Name: string): TMaskTable;
  public
    class function GetMasks(const DefinitionMasks: string): string;
  end;

implementation

uses System.Classes, System.SysUtils;

class function TMasks.GetMasks(const DefinitionMasks: string): string;
var
  S: TStringList;
  I: Integer;
  A, MasksTable: string;
  M: TMaskTable;
begin
  S := TStringList.Create;
  try
    S.Text := DefinitionMasks;

    for I := S.Count-1 downto 0 do
    begin
      A := Trim(S[I]);

      if A.IsEmpty or A.StartsWith('//') then
      begin
        S.Delete(I);
        Continue;
      end;

      if A.StartsWith(':') then
      begin
        MasksTable := A.Substring(1);
        M := FindMaskTable(MasksTable);
        if M=nil then
          raise Exception.CreateFmt('Masks table "%s" not found', [MasksTable]);

        S[I] := M.Masks; //replace line by masks table
        Continue;
      end;
    end;

    Result := S.Text;
  finally
    S.Free;
  end;
end;

class function TMasks.FindMaskTable(const Name: string): TMaskTable;
var
  M: TMaskTable;
begin
  for M in Config.LstMaskTable do
    if SameText(M.Name, Name) then Exit(M);

  Exit(nil);
end;

end.
