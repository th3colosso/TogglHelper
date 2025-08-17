unit TogglHelper.DataVisualizer;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TfrmVisualizer = class(TForm)
    mmData: TMemo;
  end;

var
  frmVisualizer: TfrmVisualizer;

implementation

{$R *.dfm}

end.
