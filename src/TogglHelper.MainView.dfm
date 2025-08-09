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
        Width = 333
        Height = 333
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
        object lblWorkSpaceID: TLabel
          Left = 24
          Top = 203
          Width = 113
          Height = 15
          Caption = 'Default Workspace ID'
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
          Width = 277
          Height = 23
          ReadOnly = True
          TabOrder = 0
        end
        object edtEmail: TEdit
          Left = 24
          Top = 112
          Width = 277
          Height = 23
          ReadOnly = True
          TabOrder = 1
        end
        object pnlStatus: TPanel
          Left = 24
          Top = 269
          Width = 277
          Height = 41
          BevelInner = bvLowered
          BevelKind = bkSoft
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
        object edtDefWorkSpaceID: TEdit
          Left = 24
          Top = 224
          Width = 277
          Height = 23
          ReadOnly = True
          TabOrder = 3
        end
        object edtUserID: TEdit
          Left = 24
          Top = 168
          Width = 277
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
      object gbOther: TGroupBox
        Left = 404
        Top = 64
        Width = 333
        Height = 333
        Caption = 'Options'
        TabOrder = 4
        object lblStyle: TLabel
          Left = 24
          Top = 27
          Width = 62
          Height = 15
          Caption = 'App Theme'
        end
        object cbStyle: TComboBox
          Left = 24
          Top = 48
          Width = 221
          Height = 23
          Style = csDropDownList
          TabOrder = 0
          OnChange = cbStyleChange
        end
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
          Top = 46
          Width = 37
          Height = 15
          Caption = 'Project'
        end
        object lblData: TLabel
          Left = 29
          Top = 12
          Width = 24
          Height = 15
          Caption = 'Date'
        end
        object cbProjects: TComboBox
          Left = 59
          Top = 43
          Width = 302
          Height = 23
          AutoDropDown = True
          Style = csDropDownList
          Sorted = True
          TabOrder = 0
          OnChange = cbProjectsChange
        end
        object btnAdd: TButton
          Left = 571
          Top = 11
          Width = 94
          Height = 25
          Caption = 'Add Entry'
          TabOrder = 1
          OnClick = btnAddClick
        end
        object btnPush: TButton
          Left = 571
          Top = 42
          Width = 198
          Height = 25
          Caption = 'Push All Time Entries'
          TabOrder = 2
          OnClick = btnPushClick
        end
        object dpBase: TDatePicker
          Left = 59
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
          TabOrder = 3
        end
        object actIndicator: TActivityIndicator
          Left = 541
          Top = 42
          IndicatorSize = aisSmall
        end
        object btnSort: TButton
          Left = 671
          Top = 11
          Width = 94
          Height = 25
          Caption = 'Sort Entries'
          TabOrder = 5
          OnMouseDown = btnSortMouseDown
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
  object popSort: TPopupMenu
    AutoHotkeys = maManual
    TrackButton = tbLeftButton
    Left = 440
    Top = 36
    object Description1: TMenuItem
      Caption = 'Description'
      OnClick = Description1Click
    end
    object Date1: TMenuItem
      Caption = 'Time'
      OnClick = Date1Click
    end
    object Tag1: TMenuItem
      Caption = 'Tag'
      OnClick = Tag1Click
    end
  end
  object NC: TNotificationCenter
    OnReceiveLocalNotification = NCReceiveLocalNotification
    Left = 384
    Top = 36
  end
end
