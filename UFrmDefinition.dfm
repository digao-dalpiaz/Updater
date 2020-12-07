object FrmDefinition: TFrmDefinition
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'New Definition'
  ClientHeight = 481
  ClientWidth = 638
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
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
  object Label2: TLabel
    Left = 8
    Top = 56
    Width = 33
    Height = 13
    Caption = 'Source'
  end
  object Label3: TLabel
    Left = 8
    Top = 104
    Width = 54
    Height = 13
    Caption = 'Destination'
  end
  object Label4: TLabel
    Left = 8
    Top = 160
    Width = 47
    Height = 13
    Caption = 'Inclusions'
  end
  object Label5: TLabel
    Left = 320
    Top = 160
    Width = 49
    Height = 13
    Caption = 'Exclusions'
  end
  object EdName: TEdit
    Left = 8
    Top = 24
    Width = 353
    Height = 21
    TabOrder = 0
  end
  object EdSource: TEdit
    Left = 8
    Top = 72
    Width = 353
    Height = 21
    TabOrder = 1
  end
  object EdDestination: TEdit
    Left = 8
    Top = 120
    Width = 353
    Height = 21
    TabOrder = 2
  end
  object EdInclusions: TMemo
    Left = 8
    Top = 176
    Width = 305
    Height = 185
    Lines.Strings = (
      'EdInclusions')
    ScrollBars = ssBoth
    TabOrder = 3
    WordWrap = False
  end
  object EdExclusions: TMemo
    Left = 320
    Top = 176
    Width = 305
    Height = 185
    Lines.Strings = (
      'Memo1')
    ScrollBars = ssBoth
    TabOrder = 4
    WordWrap = False
  end
  object CkRecursive: TCheckBox
    Left = 8
    Top = 376
    Width = 137
    Height = 17
    Caption = 'Recursive subdirectories'
    TabOrder = 5
  end
  object CkDelete: TCheckBox
    Left = 8
    Top = 400
    Width = 145
    Height = 17
    Caption = 'Delete files on destination'
    TabOrder = 6
  end
  object BtnOK: TButton
    Left = 232
    Top = 440
    Width = 81
    Height = 25
    Caption = 'OK'
    TabOrder = 7
    OnClick = BtnOKClick
  end
  object BtnCancel: TButton
    Left = 320
    Top = 440
    Width = 81
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 8
  end
end
