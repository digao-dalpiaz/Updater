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

  TMaskTable = class
    Name: string;
    Masks: string;
  end;
  TLstMaskTable = class(TObjectList<TMaskTable>);

  TConfig = class
    LstDefinition: TLstDefinition;
    LstMaskTable: TLstMaskTable;

    DefinitionsFile: string;
    MasksTablesFile: string;

    constructor Create;
    destructor Destroy; override;

    procedure LoadDefinitions;
    procedure SaveDefinitions;

    procedure LoadMasksTables;
    procedure SaveMasksTables;
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
  LstMaskTable := TLstMaskTable.Create;

  DefinitionsFile := TPath.Combine(ExtractFilePath(Application.ExeName), 'Definitions.ini');
  MasksTablesFile := TPath.Combine(ExtractFilePath(Application.ExeName), 'MasksTables.ini');
end;

destructor TConfig.Destroy;
begin
  LstDefinition.Free;
  LstMaskTable.Free;
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
        LstDefinition.Add(D);

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
    for D in LstDefinition do
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
  M: TMaskTable;
begin
  Ini := TIniFile.Create(MasksTablesFile);
  try
    S := TStringList.Create;
    try
      Ini.ReadSections(S);

      for Section in S do
      begin
        M := TMaskTable.Create;
        LstMaskTable.Add(M);

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
  M: TMaskTable;
  Section: string;
begin
  TFile.WriteAllText(MasksTablesFile, string.Empty); //ensure clear file

  Ini := TIniFile.Create(MasksTablesFile);
  try
    for M in LstMaskTable do
    begin
      Section := M.Name;

      Ini.WriteString(Section, 'Masks', EnterToPipe(M.Masks));
    end;
  finally
    Ini.Free;
  end;

end;

end.
