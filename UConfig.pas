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
  TDefinitionList = class(TObjectList<TDefinition>);

  TMasksTable = class
    Name: string;
    Masks: string;
  end;
  TMasksTableList = class(TObjectList<TMasksTable>);

  TConfig = class
    Definitions: TDefinitionList;
    MasksTables: TMasksTableList;

    DefinitionsFile: string;
    MasksTablesFile: string;

    constructor Create;
    destructor Destroy; override;

    procedure LoadDefinitions;
    procedure SaveDefinitions;

    procedure LoadMasksTables;
    procedure SaveMasksTables;

    function FindMasksTable(const Name: string): TMasksTable;
  end;

var Config: TConfig;

implementation

uses System.Classes, System.SysUtils, System.IniFiles, System.IOUtils,
  Vcl.Forms;

const STR_ENTER = #13#10;

constructor TConfig.Create;
begin
  inherited;
  Definitions := TDefinitionList.Create;
  MasksTables := TMasksTableList.Create;

  DefinitionsFile := TPath.Combine(ExtractFilePath(Application.ExeName), 'Definitions.ini');
  MasksTablesFile := TPath.Combine(ExtractFilePath(Application.ExeName), 'MasksTables.ini');
end;

destructor TConfig.Destroy;
begin
  Definitions.Free;
  MasksTables.Free;
  inherited;
end;

function PipeToEnter(const Text: string): string;
begin
  Result := Text.Replace('|', STR_ENTER);
end;

function EnterToPipe(const Text: string): string;
begin
  Result := Text.Replace(STR_ENTER, '|');
end;

procedure TConfig.LoadDefinitions;
var
  Section: string;
  Ini: TIniFile;
  S: TStringList;
  D: TDefinition;
begin
  Ini := TIniFile.Create(DefinitionsFile);
  try
    S := TStringList.Create;
    try
      Ini.ReadSections(S);

      for Section in S do
      begin
        D := TDefinition.Create;
        Definitions.Add(D);

        D.Name := Section;
        D.Source := Ini.ReadString(Section, 'Source', '');
        D.Destination := Ini.ReadString(Section, 'Destination', '');
        D.Inclusions := PipeToEnter(Ini.ReadString(Section, 'Inclusions', ''));
        D.Exclusions := PipeToEnter(Ini.ReadString(Section, 'Exclusions', ''));
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
  TFile.WriteAllText(DefinitionsFile, string.Empty); //ensure clear file

  Ini := TIniFile.Create(DefinitionsFile);
  try
    for D in Definitions do
    begin
      Section := D.Name;

      Ini.WriteString(Section, 'Source', D.Source);
      Ini.WriteString(Section, 'Destination', D.Destination);
      Ini.WriteString(Section, 'Inclusions', EnterToPipe(D.Inclusions));
      Ini.WriteString(Section, 'Exclusions', EnterToPipe(D.Exclusions));
      Ini.WriteBool(Section, 'Recursive', D.Recursive);
      Ini.WriteBool(Section, 'Delete', D.Delete);
      Ini.WriteDateTime(Section, 'LastUpdate', D.LastUpdate);
      Ini.WriteBool(Section, 'Checked', D.Checked);
    end;
  finally
    Ini.Free;
  end;
end;

procedure TConfig.LoadMasksTables;
var
  Section: string;
  Ini: TIniFile;
  S: TStringList;
  M: TMasksTable;
begin
  Ini := TIniFile.Create(MasksTablesFile);
  try
    S := TStringList.Create;
    try
      Ini.ReadSections(S);

      for Section in S do
      begin
        M := TMasksTable.Create;
        MasksTables.Add(M);

        M.Name := Section;
        M.Masks := PipeToEnter(Ini.ReadString(Section, 'Masks', ''));
      end;
    finally
      S.Free;
    end;
  finally
    Ini.Free;
  end;
end;

procedure TConfig.SaveMasksTables;
var
  Ini: TIniFile;
  M: TMasksTable;
  Section: string;
begin
  TFile.WriteAllText(MasksTablesFile, string.Empty); //ensure clear file

  Ini := TIniFile.Create(MasksTablesFile);
  try
    for M in MasksTables do
    begin
      Section := M.Name;

      Ini.WriteString(Section, 'Masks', EnterToPipe(M.Masks));
    end;
  finally
    Ini.Free;
  end;
end;

function TConfig.FindMasksTable(const Name: string): TMasksTable;
var
  M: TMasksTable;
begin
  for M in MasksTables do
    if SameText(M.Name, Name) then Exit(M);

  Exit(nil);
end;

end.
