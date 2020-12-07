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
    Delete: Boolean;

    LastUpdate: TDateTime;
    Checked: Boolean;
  end;
  TLstDefinition = class(TObjectList<TDefinition>);

  TConfig = class
    LstDefinition: TLstDefinition;

    DefinitionFile: string;

    constructor Create;
    destructor Destroy; override;

    procedure LoadDefinitions;
    procedure SaveDefinitions;
  end;

var Config: TConfig;

implementation

uses System.Classes, System.SysUtils, System.IniFiles, System.IOUtils,
  Vcl.Forms;

const STR_ENTER = #13#10;

constructor TConfig.Create;
begin
  inherited;
  LstDefinition := TLstDefinition.Create;

  DefinitionFile := TPath.Combine(ExtractFilePath(Application.ExeName), 'Definitions.ini');
end;

destructor TConfig.Destroy;
begin
  LstDefinition.Free;
  inherited;
end;

procedure TConfig.LoadDefinitions;
var
  Section: string;
  Ini: TIniFile;
  S: TStringList;
  D: TDefinition;
begin
  Ini := TIniFile.Create(DefinitionFile);
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
        D.Inclusions := Ini.ReadString(Section, 'Inclusions', '').Replace('|', STR_ENTER);
        D.Exclusions := Ini.ReadString(Section, 'Exclusions', '').Replace('|', STR_ENTER);
        D.Recursive := Ini.ReadBool(Section, 'Recursive', False);
        D.Delete := Ini.ReadBool(Section, 'Delete', False);
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
  TFile.WriteAllText(DefinitionFile, string.Empty); //ensure clear file

  Ini := TIniFile.Create(DefinitionFile);
  try
    for D in LstDefinition do
    begin
      Section := D.Name;

      Ini.WriteString(Section, 'Source', D.Source);
      Ini.WriteString(Section, 'Destination', D.Destination);
      Ini.WriteString(Section, 'Inclusions', D.Inclusions.Replace(STR_ENTER, '|'));
      Ini.WriteString(Section, 'Exclusions', D.Exclusions.Replace(STR_ENTER, '|'));
      Ini.WriteBool(Section, 'Recursive', D.Recursive);
      Ini.WriteBool(Section, 'Delete', D.Delete);
      Ini.WriteDateTime(Section, 'LastUpdate', D.LastUpdate);
      Ini.WriteBool(Section, 'Checked', D.Checked);
    end;
  finally
    Ini.Free;
  end;
end;

end.
