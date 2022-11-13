object FrmConfiguration: TFrmConfiguration
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Configuration'
  ClientHeight = 274
  ClientWidth = 609
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
  object pnlBase: TPanel
    Left = 0
    Top = 0
    Width = 609
    Height = 274
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      609
      274)
    object grpFSISettings: TGroupBox
      Left = 8
      Top = 16
      Width = 592
      Height = 105
      Anchors = [akLeft, akTop, akRight]
      Caption = 'FSI'
      TabOrder = 2
      object lblDotnetSdkSite: TLabel
        Left = 220
        Top = 19
        Width = 221
        Height = 13
        Caption = 'https://dotnet.microsoft.com/en-us/download'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlue
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsUnderline]
        ParentFont = False
        OnClick = lblDotnetSdkSiteClick
        OnMouseEnter = lblDotnetSdkSiteMouseEnter
        OnMouseLeave = lblDotnetSdkSiteMouseLeave
      end
      object Label2: TLabel
        Left = 447
        Top = 19
        Width = 4
        Height = 13
        Caption = ')'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object chkUseDotnetFsi: TCheckBox
        Left = 16
        Top = 18
        Width = 200
        Height = 17
        Caption = 'Use dotnet fsi (requires the .NET SDK:'
        Checked = True
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        State = cbChecked
        TabOrder = 1
        OnClick = chkUseDotnetFsiClick
      end
      object pnlCustomFSI: TPanel
        Left = 3
        Top = 34
        Width = 582
        Height = 76
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 0
        DesignSize = (
          582
          76)
        object lblFSIBinaryArgs: TLabel
          Left = 16
          Top = 40
          Width = 56
          Height = 13
          Caption = 'Arguments:'
          Enabled = False
        end
        object lblFSIBinaryPath: TLabel
          Left = 13
          Top = 16
          Width = 59
          Height = 13
          Caption = 'Binary Path:'
          Enabled = False
        end
        object txtFSIBinary: TEdit
          Left = 78
          Top = 12
          Width = 467
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          Enabled = False
          TabOrder = 0
          TextHint = 'Fully qualified name of the FSI binary'
        end
        object txtFSIBinaryArgs: TEdit
          Left = 78
          Top = 36
          Width = 467
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          Enabled = False
          TabOrder = 1
          TextHint = 'Arguments for the FSI binary'
        end
        object cmdSelectBinary: TButton
          Left = 551
          Top = 10
          Width = 26
          Height = 25
          Anchors = [akTop, akRight]
          Caption = '...'
          Enabled = False
          TabOrder = 2
          OnClick = cmdSelectBinaryClick
        end
      end
    end
    object grpEditorSettings: TGroupBox
      Left = 8
      Top = 127
      Width = 592
      Height = 106
      Anchors = [akLeft, akTop, akRight, akBottom]
      Caption = 'Editor'
      TabOrder = 3
      object lblConvertTabsToSpaces: TLabel
        Left = 16
        Top = 24
        Width = 116
        Height = 13
        Caption = 'Convert tabs to spaces:'
      end
      object lblTabLength: TLabel
        Left = 24
        Top = 52
        Width = 58
        Height = 13
        Caption = 'Tab Length:'
      end
      object lblEchoText: TLabel
        Left = 16
        Top = 82
        Width = 139
        Height = 13
        Caption = 'Echo text from NPP in editor:'
      end
      object chkConvertToTabs: TCheckBox
        Left = 144
        Top = 23
        Width = 17
        Height = 17
        TabOrder = 0
        OnClick = chkConvertToTabsClick
        OnKeyUp = chkConvertToTabsKeyUp
      end
      object updnTabLength: TUpDown
        Left = 118
        Top = 48
        Width = 17
        Height = 21
        Associate = txtTabLength
        Min = 1
        Max = 20
        Position = 1
        TabOrder = 2
        Thousands = False
      end
      object txtTabLength: TEdit
        Left = 87
        Top = 48
        Width = 31
        Height = 21
        MaxLength = 2
        NumbersOnly = True
        TabOrder = 1
        Text = '1'
      end
      object chkEchoText: TCheckBox
        Left = 167
        Top = 81
        Width = 17
        Height = 17
        TabOrder = 3
        OnClick = chkConvertToTabsClick
        OnKeyUp = chkConvertToTabsKeyUp
      end
    end
    object cmdSave: TButton
      Left = 444
      Top = 240
      Width = 75
      Height = 26
      Anchors = [akRight, akBottom]
      Caption = 'Save'
      Default = True
      ModalResult = 1
      TabOrder = 0
      OnClick = cmdSaveClick
    end
    object cmdCancel: TButton
      Left = 525
      Top = 240
      Width = 75
      Height = 26
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
    end
  end
  object dlgFSIBinarySelect: TOpenDialog
    DefaultExt = 'exe'
    Filter = 'EXE|*.exe;*.bat;*.cmd'
    Options = [ofPathMustExist, ofFileMustExist, ofEnableSizing, ofDontAddToRecent]
    Left = 16
    Top = 232
  end
end
