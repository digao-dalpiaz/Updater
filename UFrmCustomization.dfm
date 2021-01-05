object FrmCustomization: TFrmCustomization
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Customization'
  ClientHeight = 140
  ClientWidth = 409
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
  object BottomLine: TBevel
    Left = 8
    Top = 96
    Width = 393
    Height = 9
    Shape = bsTopLine
  end
  object CkNewVersion: TCheckBox
    Left = 8
    Top = 8
    Width = 185
    Height = 17
    Caption = 'Check for new version on startup'
    TabOrder = 0
  end
  object BtnOK: TButton
    Left = 120
    Top = 104
    Width = 81
    Height = 29
    Caption = 'OK'
    TabOrder = 1
    OnClick = BtnOKClick
  end
  object BtnCancel: TButton
    Left = 208
    Top = 104
    Width = 81
    Height = 29
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
end
