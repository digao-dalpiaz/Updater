unit UFrmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.ToolWin,
  System.ImageList, Vcl.ImgList, Vcl.StdCtrls, Vcl.CheckLst, Vcl.ExtCtrls;

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
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmMain: TFrmMain;

implementation

{$R *.dfm}

end.
