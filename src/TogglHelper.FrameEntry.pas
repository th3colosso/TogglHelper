unit TogglHelper.FrameEntry;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.WinXPickers,
  Vcl.ComCtrls, Vcl.Imaging.pngimage;

type
{$SCOPEDENUMS ON}
  TSortParam = (Default, Description, Time, Tag);
{$SCOPEDENUMS OFF}

  TProcReorder = procedure(AComponent: TScrollBox; ASortParam: TSortParam = TSortParam.Default) of object;

  TFrameEntry = class(TFrame)
    pnlMain: TPanel;
    lblTitle: TLabel;
    lblPrj: TLabel;
    lblTag: TLabel;
    lblFrom: TLabel;
    lblTo: TLabel;
    imgClose: TImage;
    edtEntry: TEdit;
    cbPrj: TComboBox;
    cbBillable: TCheckBox;
    cbTag: TComboBox;
    tpStart: TDateTimePicker;
    tpStop: TDateTimePicker;
    cbPush: TCheckBox;
    procedure imgCloseClick(Sender: TObject);
    procedure pnlMainDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure pnlMainDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
  private
    FOnTagReorder: TProcReorder;
  public
    property OnTagReorder: TProcReorder read FOnTagReorder write FOnTagReorder;
  end;

implementation

{$R *.dfm}

procedure TFrameEntry.imgCloseClick(Sender: TObject);
var
  Img: TImage absolute Sender;
begin
  var ScrollBox := (Img.Owner.Owner as TScrollBox);
  ScrollBox.VertScrollBar.Range := ScrollBox.VertScrollBar.Range - Self.Height;
  Img.Owner.Free;
end;

procedure TFrameEntry.pnlMainDragDrop(Sender, Source: TObject; X, Y: Integer);
begin
  if not ((Sender is TPanel) and (Source is TPanel)) then
    Exit;

  var Src := Source as TPanel;
  var Dest := Sender as TPanel;

  var tmpTag := Src.Owner.Tag;
  Src.Owner.Tag := Dest.Owner.Tag;
  Dest.Owner.Tag := tmpTag;

  if Assigned(FOnTagReorder) then
  begin
    var Entry := Src.Owner;
    if Assigned(Entry) then
    begin
      if Entry.Owner is TScrollBox then
        FOnTagReorder(Entry.Owner as TScrollBox);
    end;
  end;
end;

procedure TFrameEntry.pnlMainDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := False;

  if not ((Sender is TPanel) and (Source is TPanel)) then
    Exit;

  var Src := Source as TPanel;
  var Dest := Sender as TPanel;

  if not Src.Owner.ClassNameIs('TframeEntry') then
    Exit;

  if Src.Owner.Tag = Dest.Owner.Tag then
    Exit;

  Accept := True;
end;

end.
