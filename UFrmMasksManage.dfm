object FrmMasksManage: TFrmMasksManage
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Masks Tables'
  ClientHeight = 313
  ClientWidth = 393
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object BtnAdd: TSpeedButton
    Left = 344
    Top = 8
    Width = 41
    Height = 33
    Caption = '+'
    OnClick = BtnAddClick
  end
  object BtnDel: TSpeedButton
    Left = 344
    Top = 88
    Width = 41
    Height = 33
    Caption = '-'
    OnClick = BtnDelClick
  end
  object BtnMod: TSpeedButton
    Left = 344
    Top = 48
    Width = 41
    Height = 33
    Caption = '^'
    OnClick = BtnModClick
  end
  object L: TListBox
    Left = 8
    Top = 8
    Width = 329
    Height = 297
    Style = lbOwnerDrawFixed
    ItemHeight = 20
    Sorted = True
    TabOrder = 0
    OnClick = LClick
    OnDblClick = LDblClick
    OnDrawItem = LDrawItem
  end
end
