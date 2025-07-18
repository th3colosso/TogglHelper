object frmMain: TfrmMain
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'TogglHelper'
  ClientHeight = 625
  ClientWidth = 784
  Color = clBtnFace
  Constraints.MaxWidth = 800
  Constraints.MinHeight = 420
  Constraints.MinWidth = 800
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 15
  object pcMain: TPageControl
    Left = 0
    Top = 0
    Width = 784
    Height = 625
    ActivePage = tsEntries
    Align = alClient
    TabOrder = 0
    object tsSettings: TTabSheet
      Caption = 'Settings'
      DesignSize = (
        776
        595)
      object lblToken: TLabel
        Left = 36
        Top = 25
        Width = 53
        Height = 15
        Caption = 'API Token'
      end
      object btnAuth: TButton
        Left = 519
        Top = 21
        Width = 110
        Height = 25
        Caption = 'Authenticate'
        TabOrder = 0
        OnClick = btnAuthClick
      end
      object gbResult: TGroupBox
        Left = 36
        Top = 64
        Width = 701
        Height = 498
        Anchors = [akLeft, akTop, akBottom]
        Caption = 'Result'
        TabOrder = 1
        DesignSize = (
          701
          498)
        object lblFullName: TLabel
          Left = 24
          Top = 35
          Width = 52
          Height = 15
          Caption = 'Full name'
        end
        object lblEmail: TLabel
          Left = 24
          Top = 91
          Width = 29
          Height = 15
          Caption = 'Email'
        end
        object lblWorkSpaceID: TLabel
          Left = 24
          Top = 203
          Width = 113
          Height = 15
          Caption = 'Default Workspace ID'
        end
        object lblResponseJson: TLabel
          Left = 400
          Top = 35
          Width = 50
          Height = 15
          Caption = 'Response'
        end
        object lblUserID: TLabel
          Left = 24
          Top = 147
          Width = 37
          Height = 15
          Caption = 'User ID'
        end
        object edtFullName: TEdit
          Left = 24
          Top = 56
          Width = 345
          Height = 23
          ReadOnly = True
          TabOrder = 0
        end
        object edtEmail: TEdit
          Left = 24
          Top = 112
          Width = 345
          Height = 23
          ReadOnly = True
          TabOrder = 1
        end
        object pnlStatus: TPanel
          Left = 70
          Top = 441
          Width = 561
          Height = 41
          Anchors = [akLeft, akBottom]
          BevelOuter = bvNone
          Caption = 'No Update Status'
          Color = clGray
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBtnHighlight
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentBackground = False
          ParentFont = False
          TabOrder = 2
        end
        object mmRes: TMemo
          Left = 400
          Top = 56
          Width = 289
          Height = 362
          Anchors = [akLeft, akTop, akBottom]
          ReadOnly = True
          ScrollBars = ssBoth
          TabOrder = 3
          WordWrap = False
        end
        object edtDefWorkSpaceID: TEdit
          Left = 24
          Top = 224
          Width = 345
          Height = 23
          ReadOnly = True
          TabOrder = 4
        end
        object edtUserID: TEdit
          Left = 24
          Top = 168
          Width = 345
          Height = 23
          ReadOnly = True
          TabOrder = 5
        end
      end
      object edtApiToken: TEdit
        Left = 95
        Top = 22
        Width = 418
        Height = 23
        TabOrder = 2
      end
      object btnUpdate: TButton
        Left = 635
        Top = 21
        Width = 102
        Height = 25
        Caption = 'Update Data'
        Enabled = False
        TabOrder = 3
        OnClick = btnUpdateClick
      end
    end
    object tsEntries: TTabSheet
      Caption = 'Entries'
      ImageIndex = 1
      object pnlDefault: TPanel
        Left = 0
        Top = 0
        Width = 776
        Height = 73
        Margins.Right = 0
        Align = alTop
        TabOrder = 0
        object lblProjects: TLabel
          Left = 16
          Top = 12
          Width = 37
          Height = 15
          Caption = 'Project'
        end
        object lblTag: TLabel
          Left = 34
          Top = 43
          Width = 19
          Height = 15
          Caption = 'Tag'
        end
        object lblData: TLabel
          Left = 437
          Top = 12
          Width = 24
          Height = 15
          Caption = 'Date'
        end
        object cbProjects: TComboBox
          Left = 59
          Top = 9
          Width = 302
          Height = 23
          AutoDropDown = True
          Style = csDropDownList
          Sorted = True
          TabOrder = 0
        end
        object cbTags: TComboBox
          Left = 59
          Top = 40
          Width = 302
          Height = 23
          AutoDropDown = True
          Style = csDropDownList
          Sorted = True
          TabOrder = 1
        end
        object btnAdd: TButton
          Left = 467
          Top = 42
          Width = 94
          Height = 25
          Caption = 'Add Entry'
          TabOrder = 2
          OnClick = btnAddClick
        end
        object btnPush: TButton
          Left = 629
          Top = 42
          Width = 140
          Height = 25
          Caption = 'Push All Time Entries'
          TabOrder = 3
          OnClick = btnPushClick
        end
        object dpBase: TDatePicker
          Left = 467
          Top = 9
          Width = 302
          Height = 25
          Date = 45840.000000000000000000
          DateFormat = 'dd/mm/yyyy'
          DropDownCount = 8
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = []
          TabOrder = 4
        end
        object actIndicator: TActivityIndicator
          Left = 603
          Top = 43
          IndicatorSize = aisSmall
        end
      end
      object sbEntries: TScrollBox
        Left = 0
        Top = 73
        Width = 776
        Height = 522
        VertScrollBar.Smooth = True
        VertScrollBar.Tracking = True
        Align = alClient
        AutoScroll = False
        BorderStyle = bsNone
        DoubleBuffered = False
        ParentDoubleBuffered = False
        TabOrder = 1
      end
    end
  end
end
