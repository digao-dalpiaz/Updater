unit UFrmMain;

interface

uses Vcl.Forms, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Controls, Vcl.CheckLst,
  System.ImageList, Vcl.ImgList, Vcl.ComCtrls, System.Classes, Vcl.ToolWin;

type
  TFrmMain = class(TForm)
    ToolBar: TToolBar;
    BtnNew: TToolButton;
    BtnEdit: TToolButton;
    BtnRemove: TToolButton;
    ToolButton4: TToolButton;
    BtnUp: TToolButton;
    BtnDown: TToolButton;
    ToolButton7: TToolButton;
    BtnMasks: TToolButton;
    ToolButton9: TToolButton;
    BtnExecute: TToolButton;
    IL: TImageList;
    LDefs: TCheckListBox;
    LLogs: TListBox;
    Splitter1: TSplitter;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BtnNewClick(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
    procedure BtnRemoveClick(Sender: TObject);
    procedure BtnUpClick(Sender: TObject);
    procedure BtnDownClick(Sender: TObject);
  private
    procedure FillDefinitions;
    procedure MoveDefinition(Flag: Integer);
  end;

var
  FrmMain: TFrmMain;

implementation

{$R *.dfm}

uses UConfig, UFrmDefinition, System.SysUtils;

procedure TFrmMain.FormCreate(Sender: TObject);
begin
  Config := TConfig.Create;
  Config.LoadDefinitions;

  FillDefinitions;
end;

procedure TFrmMain.FormDestroy(Sender: TObject);
begin
  Config.SaveDefinitions;
  Config.Free;
end;

procedure TFrmMain.FillDefinitions;
var
  D: TDefinition;
  Index: Integer;
begin
  for D in Config.LstDefinition do
  begin
    Index := LDefs.Items.AddObject(D.Name, D);
    LDefs.Checked[Index] := D.Checked;
  end;
end;

procedure TFrmMain.BtnNewClick(Sender: TObject);
var
  D: TDefinition;
  Index: Integer;
begin
  if DoEditDefinition(False, D) then
  begin
    Index := LDefs.Items.AddObject(D.Name, D);
    LDefs.ItemIndex := Index;
  end;
end;

procedure TFrmMain.BtnEditClick(Sender: TObject);
var
  D: TDefinition;
begin
  D := TDefinition(LDefs.Items.Objects[LDefs.ItemIndex]);
  if DoEditDefinition(True, D) then
  begin
    LDefs.Items[LDefs.ItemIndex] := D.Name;
  end;
end;

procedure TFrmMain.BtnRemoveClick(Sender: TObject);
var
  D: TDefinition;
begin
  D := TDefinition(LDefs.Items.Objects[LDefs.ItemIndex]);

  Config.LstDefinition.Remove(D);
  LDefs.DeleteSelected;
end;

procedure TFrmMain.MoveDefinition(Flag: Integer);
var
  Index, NewIndex: Integer;
begin
  Index := LDefs.ItemIndex;
  NewIndex := Index + Flag;

  Config.LstDefinition.Exchange(Index, NewIndex);
  LDefs.Items.Exchange(Index, NewIndex);
end;

procedure TFrmMain.BtnUpClick(Sender: TObject);
begin
  MoveDefinition(-1);
end;

procedure TFrmMain.BtnDownClick(Sender: TObject);
begin
  MoveDefinition(+1);
end;

end.
