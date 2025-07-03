object frmMain: TfrmMain
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = 'TogglHelper'
  ClientHeight = 410
  ClientWidth = 793
  Color = clBtnFace
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
    Width = 793
    Height = 410
    ActivePage = tsSettings
    Align = alClient
    TabOrder = 0
    object tsSettings: TTabSheet
      Caption = 'Settings'
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
        Height = 281
        Caption = 'Result'
        TabOrder = 1
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
        object lblWorkSpace_UserID: TLabel
          Left = 24
          Top = 147
          Width = 106
          Height = 15
          Caption = 'Workspace / User ID'
        end
        object lblResponseJson: TLabel
          Left = 400
          Top = 35
          Width = 50
          Height = 15
          Caption = 'Response'
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
          Top = 224
          Width = 561
          Height = 41
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
          Height = 145
          ReadOnly = True
          ScrollBars = ssBoth
          TabOrder = 3
          WordWrap = False
        end
        object edtTogglID: TEdit
          Left = 24
          Top = 168
          Width = 345
          Height = 23
          ReadOnly = True
          TabOrder = 4
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
        Width = 785
        Height = 73
        Margins.Right = 0
        Align = alTop
        TabOrder = 0
        ExplicitTop = -6
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
          Width = 102
          Height = 25
          Caption = 'Add Entry'
          TabOrder = 2
          OnClick = btnAddClick
        end
        object btnPush: TButton
          Left = 616
          Top = 42
          Width = 153
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
        object actIndPush: TActivityIndicator
          Left = 586
          Top = 43
          IndicatorSize = aisSmall
        end
      end
      object sbEntries: TScrollBox
        Left = 0
        Top = 73
        Width = 785
        Height = 307
        VertScrollBar.Smooth = True
        VertScrollBar.Tracking = True
        Align = alClient
        AutoScroll = False
        BorderStyle = bsNone
        DoubleBuffered = False
        ParentDoubleBuffered = False
        TabOrder = 1
        ExplicitLeft = 3
        ExplicitTop = 71
      end
    end
  end
end
