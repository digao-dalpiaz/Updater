unit UConfig;

interface

uses System.Generics.Collections;

type
  TDefinition = class
    Name: string;
    Source: string;
    Destination: string;
    Inclusions: string;
    Exclusions: string;
    Recursive: Boolean;
    Remove: Boolean;

    LastUpdate: TDateTime;
    Checked: Boolean;
  end;

  TConfig = class
    LstDefinition: TObjectList<TDefinition>;

    function GetDefinitionFile: string;

    procedure LoadDefinitions;
    procedure SaveDefinitions;
  end;

implementation

uses System.Classes, System.SysUtils, System.IniFiles, System.IOUtils,
  Vcl.Forms;

function TConfig.GetDefinitionFile: string;
begin
  Result := TPath.Combine(ExtractFilePath(Application.ExeName), 'Definitions.ini');
end;

procedure TConfig.LoadDefinitions;
var
  Section: string;
  Ini: TIniFile;
  S: TStringList;
  D: TDefinition;
begin
  Ini := TIniFile.Create(GetDefinitionFile);
  try
    S := TStringList.Create;
    try
      Ini.ReadSections(S);

      for Section in S do
      begin
        D := TDefinition.Create;
        LstDefinition.Add(D);

        D.Name := Section;
        D.Source := Ini.ReadString(Section, 'Source', '');
        D.Destination := Ini.ReadString(Section, 'Destination', '');
        D.Inclusions := Ini.ReadString(Section, 'Inclusions', '').Replace('|', #13#10);
        D.Exclusions := Ini.ReadString(Section, 'Exclusions', '').Replace('|', #13#10);
        D.Recursive := Ini.ReadBool(Section, 'Recursive', False);
        D.Remove := Ini.ReadBool(Section, 'Remove', False);
        D.LastUpdate := Ini.ReadDateTime(Section, 'LastUpdate', 0);
        D.Checked := Ini.ReadBool(Section, 'Checked', False);
      end;
    finally
      S.Free;
    end;
  finally
    Ini.Free;
  end;
end;

procedure TConfig.SaveDefinitions;
var
  Ini: TIniFile;
  D: TDefinition;
  Section: string;
begin
  Ini := TIniFile.Create(GetDefinitionFile);
  try
    for D in LstDefinition do
    begin
      Section := D.Name;

      Ini.WriteString(Section, 'Source', D.Source);
      Ini.WriteString(Section, 'Destination', D.Destination);
      Ini.WriteString(Section, 'Inclusions', D.Inclusions.Replace(#13#10, '|'));
      Ini.WriteString(Section, 'Exclusions', D.Exclusions.Replace(#13#10, '|'));
      Ini.WriteBool(Section, 'Recursive', D.Recursive);
      Ini.WriteBool(Section, 'Remove', D.Remove);
      Ini.WriteDateTime(Section, 'LastUpdate', D.LastUpdate);
      Ini.WriteBool(Section, 'Checked', D.Checked);
    end;
  finally
    Ini.Free;
  end;
end;

end.
