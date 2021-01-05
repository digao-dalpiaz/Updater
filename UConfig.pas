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
    HiddenFiles: Boolean;
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
    SecureMode: Boolean;
    CheckForNewVersion: Boolean;

    Definitions: TDefinitionList;
    MasksTables: TMasksTableList;

    ConfigFile: string;

    constructor Create;
    destructor Destroy; override;

    procedure Load;
    procedure Save;

    function FindMasksTable(const Name: string): TMasksTable;
  end;

var Config: TConfig;

implementation

uses System.Classes, System.SysUtils, System.IOUtils,
  Xml.XmlDoc, Xml.XMLIntf, Soap.XSBuiltIns, System.Variants,
  Vcl.Forms;

constructor TConfig.Create;
begin
  inherited;
  Definitions := TDefinitionList.Create;
  MasksTables := TMasksTableList.Create;

  ConfigFile := TPath.Combine(ExtractFilePath(Application.ExeName), 'Config.xml');

  SecureMode := True; //default value
  CheckForNewVersion := True; //default value
end;

destructor TConfig.Destroy;
begin
  Definitions.Free;
  MasksTables.Free;
  inherited;
end;

{$REGION 'Utils'}
const STR_ENTER = #13#10;

function PipeToEnter(const Text: string): string;
begin
  Result := Text.Replace('|', STR_ENTER);
end;

function EnterToPipe(const Text: string): string;
begin
  Result := Text.Replace(STR_ENTER, '|');
end;

function XMLStrToTimestamp(V: string): TDateTime;
begin
  if not V.IsEmpty then
    Result := XMLTimeToDateTime(V)
  else
    Result := 0;
end;

function TimestampToXMLStr(V: TDateTime): string;
begin
  if V>0 then
    Result := DateTimeToXMLTime(V)
  else
    Result := string.Empty;
end;

function GetNode(Parent: IXMLNode; const Name: string): IXMLNode;
begin
  Result := Parent.ChildNodes.FindNode(Name);
  if Result=nil then
    raise Exception.CreateFmt('Node %s\%s not found on config file', [Parent.NodeName, Name]);
end;

type
  TNodeValueKind = (nvkString, nvkBoolean);

function GetNodeValue(Parent: IXMLNode; const Name: string; Kind: TNodeValueKind): Variant;
var V: OleVariant;
begin
  V := GetNode(Parent, Name).NodeValue;
  if (Kind=nvkString) and (V=null) then
    Result := string.Empty
  else
    Result := V;
end;
{$ENDREGION}

procedure TConfig.Load;
var
  XML: TXMLDocument;
  Root, XDefs, XMsks, N: IXMLNode;
  I: Integer;
  D: TDefinition;
  M: TMasksTable;
begin
  if not TFile.Exists(ConfigFile) then Exit;

  XML := TXMLDocument.Create(Application);
  try
    XML.LoadFromFile(ConfigFile);

    Root := XML.DocumentElement;

    SecureMode := GetNodeValue(Root, 'SecureMode', nvkBoolean);
    CheckForNewVersion := GetNodeValue(Root, 'CheckForNewVersion', nvkBoolean);

    XDefs := GetNode(Root, 'Definitions');
    for I := 0 to XDefs.ChildNodes.Count-1 do
    begin
      N := XDefs.ChildNodes[I];
      if N.NodeName='Definition' then
      begin
        D := TDefinition.Create;
        Definitions.Add(D);

        D.Name := GetNodeValue(N, 'Name', nvkString);
        D.Source := GetNodeValue(N, 'Source', nvkString);
        D.Destination := GetNodeValue(N, 'Destination', nvkString);
        D.Inclusions := PipeToEnter(GetNodeValue(N, 'Inclusions', nvkString));
        D.Exclusions := PipeToEnter(GetNodeValue(N, 'Exclusions', nvkString));
        D.HiddenFiles := GetNodeValue(N, 'HiddenFiles', nvkBoolean);
        D.Recursive := GetNodeValue(N, 'Recursive', nvkBoolean);
        D.Delete := GetNodeValue(N, 'Delete', nvkBoolean);
        D.LastUpdate := XMLStrToTimestamp(GetNodeValue(N, 'LastUpdate', nvkString));
        D.Checked := GetNodeValue(N, 'Checked', nvkBoolean);
      end;
    end;

    XMsks := GetNode(Root, 'MasksTables');
    for I := 0 to XMsks.ChildNodes.Count-1 do
    begin
      N := XMsks.ChildNodes[I];
      if N.NodeName='MasksTable' then
      begin
        M := TMasksTable.Create;
        MasksTables.Add(M);

        M.Name := GetNodeValue(N, 'Name', nvkString);
        M.Masks := PipeToEnter(GetNodeValue(N, 'Masks', nvkString));
      end;
    end;

  finally
    XML.Free;
  end;
end;

procedure TConfig.Save;
var
  XML: TXMLDocument;
  Root, XDefs, XMsks, N: IXMLNode;
  D: TDefinition;
  M: TMasksTable;
begin
  XML := TXMLDocument.Create(Application);
  try
    XML.Active := True;

    Root := XML.AddChild('Config');

    Root.AddChild('SecureMode').NodeValue := SecureMode;
    Root.AddChild('CheckForNewVersion').NodeValue := CheckForNewVersion;

    XDefs := Root.AddChild('Definitions');
    for D in Definitions do
    begin
      N := XDefs.AddChild('Definition');

      N.AddChild('Name').NodeValue := D.Name;
      N.AddChild('Source').NodeValue := D.Source;
      N.AddChild('Destination').NodeValue := D.Destination;
      N.AddChild('Inclusions').NodeValue := EnterToPipe(D.Inclusions);
      N.AddChild('Exclusions').NodeValue := EnterToPipe(D.Exclusions);
      N.AddChild('HiddenFiles').NodeValue := D.HiddenFiles;
      N.AddChild('Recursive').NodeValue := D.Recursive;
      N.AddChild('Delete').NodeValue := D.Delete;
      N.AddChild('LastUpdate').NodeValue := TimestampToXMLStr(D.LastUpdate);
      N.AddChild('Checked').NodeValue := D.Checked;
    end;

    XMsks := Root.AddChild('MasksTables');
    for M in MasksTables do
    begin
      N := XMsks.AddChild('MasksTable');

      N.AddChild('Name').NodeValue := M.Name;
      N.AddChild('Masks').NodeValue := EnterToPipe(M.Masks);
    end;

    XML.SaveToFile(ConfigFile);
  finally
    XML.Free;
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
