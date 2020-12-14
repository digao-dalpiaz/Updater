object FrmMasksEdit: TFrmMasksEdit
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'New Masks Table'
  ClientHeight = 380
  ClientWidth = 377
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 27
    Height = 13
    Caption = 'Name'
  end
  object Label3: TLabel
    Left = 8
    Top = 56
    Width = 29
    Height = 13
    Caption = 'Masks'
  end
  object EdName: TEdit
    Left = 8
    Top = 24
    Width = 361
    Height = 21
    CharCase = ecUpperCase
    TabOrder = 0
  end
  object EdMasks: TMemo
    Left = 8
    Top = 72
    Width = 361
    Height = 265
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Consolas'
    Font.Style = []
    ParentFont = False
    ScrollBars = ssBoth
    TabOrder = 1
    WordWrap = False
  end
  object BtnOK: TButton
    Left = 104
    Top = 344
    Width = 81
    Height = 29
    Caption = 'OK'
    TabOrder = 2
    OnClick = BtnOKClick
  end
  object BtnCancel: TButton
    Left = 192
    Top = 344
    Width = 81
    Height = 29
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 3
  end
end
