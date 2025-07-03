object frameEntry: TframeEntry
  Left = 0
  Top = 0
  Width = 744
  Height = 127
  Margins.Left = 0
  Margins.Top = 5
  Margins.Right = 0
  Margins.Bottom = 5
  Align = alTop
  Padding.Left = 3
  Padding.Top = 3
  Padding.Right = 3
  Padding.Bottom = 3
  TabOrder = 0
  DesignSize = (
    744
    127)
  object spBG: TShape
    Left = 3
    Top = 3
    Width = 738
    Height = 121
    Align = alClient
    ExplicitLeft = 0
    ExplicitTop = 0
  end
  object lblTitle: TLabel
    Left = 24
    Top = 16
    Width = 138
    Height = 15
    Caption = 'What are you working on?'
  end
  object lblPrj: TLabel
    Left = 24
    Top = 66
    Width = 67
    Height = 15
    Caption = 'Entry Project'
  end
  object lblTag: TLabel
    Left = 328
    Top = 67
    Width = 49
    Height = 15
    Anchors = [akTop, akRight]
    Caption = 'Entry Tag'
  end
  object lblFrom: TLabel
    Left = 631
    Top = 16
    Width = 28
    Height = 15
    Anchors = [akTop, akRight]
    Caption = 'From'
  end
  object lblTo: TLabel
    Left = 631
    Top = 68
    Width = 13
    Height = 15
    Anchors = [akTop, akRight]
    Caption = 'To'
  end
  object imgClose: TImage
    Left = 720
    Top = 6
    Width = 17
    Height = 16
    Cursor = crHandPoint
    Anchors = [akTop, akRight]
    Center = True
    Picture.Data = {
      0954506E67496D61676589504E470D0A1A0A0000000D49484452000000200000
      00200806000000737A7AF4000000017352474200AECE1CE90000000467414D41
      0000B18F0BFC6105000000097048597300000EC300000EC301C76FA864000001
      434944415478DAEDD6BD4BC3401806F07B4D74E85228140ACDD44910A9ED6007
      174557FF57A78285E226148AD8762A385E20E0AE187A3DCFEA90A6F9783FC076
      48963B32E4F985DC3D39507BBEA0021C1C601E0443AB54C3AC56F7FD287A973C
      7CDAE9D48FE3F8C14D4FBA5A5FA100B3767BA2002EADB58BB531B75CC45FF8A3
      9B0EDC0B2D2FB43E45015E5AADE691E78D01E09C8B48862B6BDFDC78D30D438D
      02481194F05C0017410D2F0450119CF0520016C10D4701CA10927034200FB1AE
      D562493809908570E387249C0C4823363704E12CC0D637DFE4CB1A9304482F38
      57B19F92C62401B256BB31E64B5ADB2840D15693FE3B4A01987D2E4114022825
      C345E402380DC741640224F54A45EC00A4DD4E45EC1EC982E0C90DD7D2864B35
      E6AB3B13F6B080E79F4329587BC70D4F223CDF1FA9DF43E9190AF0DF5705A800
      7B077C03381EA430F2547D960000000049454E44AE426082}
    Proportional = True
    Stretch = True
    OnClick = imgCloseClick
  end
  object edtEntry: TEdit
    Left = 24
    Top = 37
    Width = 601
    Height = 23
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
    TextHint = 'Task Information (JIRA Ticket)'
  end
  object cbPrj: TComboBox
    Left = 24
    Top = 88
    Width = 297
    Height = 23
    Style = csDropDownList
    TabOrder = 1
  end
  object cbBillable: TCheckBox
    Left = 521
    Top = 16
    Width = 66
    Height = 17
    Anchors = [akTop, akRight]
    Caption = 'Billable'
    Checked = True
    State = cbChecked
    TabOrder = 2
  end
  object cbTag: TComboBox
    Left = 328
    Top = 88
    Width = 297
    Height = 23
    Style = csDropDownList
    Anchors = [akTop, akRight]
    TabOrder = 3
  end
  object tpStart: TDateTimePicker
    Left = 631
    Top = 39
    Width = 100
    Height = 23
    Anchors = [akTop, akRight]
    Date = 45841.000000000000000000
    Format = 'HH:mm'
    Time = 0.346176747683784900
    DateFormat = dfLong
    Kind = dtkTime
    ParseInput = True
    TabOrder = 4
  end
  object tpStop: TDateTimePicker
    Left = 631
    Top = 88
    Width = 100
    Height = 23
    Anchors = [akTop, akRight]
    Date = 45841.000000000000000000
    Format = 'HH:mm'
    Time = 0.346176747683784900
    DateFormat = dfLong
    Kind = dtkTime
    ParseInput = True
    TabOrder = 5
  end
end
