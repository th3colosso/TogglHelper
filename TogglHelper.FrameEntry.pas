unit TogglHelper.FrameEntry;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.WinXPickers, Vcl.ComCtrls, Vcl.Imaging.pngimage;

type
  TframeEntry = class(TFrame)
    edtEntry: TEdit;
    lblTitle: TLabel;
    spBG: TShape;
    cbPrj: TComboBox;
    cbBillable: TCheckBox;
    lblPrj: TLabel;
    cbTag: TComboBox;
    lblTag: TLabel;
    lblFrom: TLabel;
    lblTo: TLabel;
    tpStart: TDateTimePicker;
    tpStop: TDateTimePicker;
    imgClose: TImage;
    cbPush: TCheckBox;
    procedure imgCloseClick(Sender: TObject);
  end;

implementation

{$R *.dfm}

procedure TframeEntry.imgCloseClick(Sender: TObject);
var
  Img: TImage absolute Sender;
begin
  var ScrollBox := (Img.Owner.Owner as TScrollBox);
  ScrollBox.VertScrollBar.Range := ScrollBox.VertScrollBar.Range - Self.Height;
  Img.Owner.Free;
end;

end.
