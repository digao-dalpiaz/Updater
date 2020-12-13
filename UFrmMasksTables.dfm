object FrmMasksTables: TFrmMasksTables
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Masks Tables'
  ClientHeight = 410
  ClientWidth = 714
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
  object Label2: TLabel
    Left = 8
    Top = 8
    Width = 31
    Height = 13
    Caption = 'Tables'
  end
  object BtnAdd: TSpeedButton
    Left = 296
    Top = 24
    Width = 33
    Height = 33
    Caption = '+'
    OnClick = BtnAddClick
  end
  object BtnDel: TSpeedButton
    Left = 296
    Top = 64
    Width = 33
    Height = 33
    Caption = '-'
    OnClick = BtnDelClick
  end
  object L: TListBox
    Left = 8
    Top = 24
    Width = 281
    Height = 377
    Style = lbOwnerDrawFixed
    TabOrder = 0
    OnClick = LClick
  end
  object BoxTable: TPanel
    Left = 336
    Top = 16
    Width = 377
    Height = 393
    BevelOuter = bvNone
    TabOrder = 1
    object Label3: TLabel
      Left = 8
      Top = 56
      Width = 29
      Height = 13
      Caption = 'Masks'
    end
    object Label1: TLabel
      Left = 8
      Top = 8
      Width = 27
      Height = 13
      Caption = 'Name'
    end
    object EdMasks: TMemo
      Left = 8
      Top = 72
      Width = 361
      Height = 313
      ScrollBars = ssBoth
      TabOrder = 1
      WordWrap = False
      OnChange = EditsOfTabkeChange
    end
    object EdName: TEdit
      Left = 8
      Top = 24
      Width = 361
      Height = 21
      CharCase = ecUpperCase
      TabOrder = 0
      OnChange = EditsOfTabkeChange
    end
  end
end
