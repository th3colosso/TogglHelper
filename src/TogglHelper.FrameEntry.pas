unit TogglHelper.FrameEntry;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.WinXPickers, Vcl.ComCtrls, Vcl.Imaging.pngimage;

type
  TProcObj = procedure(AComponent: TComponent) of object;

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
    procedure spBGDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure spBGDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
  private
    FOnTagChange: TProcObj;
  public
    property OnTagChange: TProcObj read FOnTagChange write FOnTagChange;
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

procedure TframeEntry.spBGDragDrop(Sender, Source: TObject; X, Y: Integer);
begin
  if not ((Sender is TShape) and (Source is TShape)) then
    Exit;

  var Src := Source as TShape;
  var Dest := Sender as TShape;

  var tmpTag := Src.Owner.Tag;
  Src.Owner.Tag := Dest.Owner.Tag;
  Dest.Owner.Tag := tmpTag;

  if Assigned(FOnTagChange) then
    FOnTagChange(Src.Owner.Owner);
end;

procedure TframeEntry.spBGDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := False;

  if not ((Sender is TShape) and (Source is TShape)) then
    Exit;

  var Src := Source as TShape;
  var Dest := Sender as TShape;

  if not Src.Owner.ClassNameIs('TframeEntry') then
    Exit;

  if Src.Owner.Tag = Dest.Owner.Tag then
    Exit;

  Accept := True;
end;

end.
