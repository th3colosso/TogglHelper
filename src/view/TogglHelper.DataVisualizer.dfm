object frmVisualizer: TfrmVisualizer
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Data Visualizer'
  ClientHeight = 461
  ClientWidth = 484
  Color = clBtnFace
  Constraints.MaxWidth = 500
  Constraints.MinHeight = 500
  Constraints.MinWidth = 500
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  FormStyle = fsStayOnTop
  Position = poScreenCenter
  TextHeight = 15
  object mmData: TMemo
    Left = 0
    Top = 0
    Width = 484
    Height = 461
    Align = alClient
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 0
  end
end
