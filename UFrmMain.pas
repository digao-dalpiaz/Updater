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
  private
    procedure FillDefinitions;
  end;

var
  FrmMain: TFrmMain;

implementation

{$R *.dfm}

uses UConfig;

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
begin
  //
end;

procedure TFrmMain.BtnEditClick(Sender: TObject);
begin
  //
end;

procedure TFrmMain.BtnRemoveClick(Sender: TObject);
begin
  //
end;

end.
