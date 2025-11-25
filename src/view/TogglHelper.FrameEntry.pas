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
    lblHourCount: TLabel;
    lblHours: TLabel;
    procedure imgCloseClick(Sender: TObject);
    procedure pnlMainDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure pnlMainDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure tpStartChange(Sender: TObject);
    procedure ZeroSeconds;
    procedure UpdateElapsedTime;
    procedure tpStopChange(Sender: TObject);
  private
    FOnTagReorder: TProcReorder;
  public
    property OnTagReorder: TProcReorder read FOnTagReorder write FOnTagReorder;
  end;

implementation

uses
  System.DateUtils, System.TimeSpan;

{$R *.dfm}

procedure TFrameEntry.imgCloseClick(Sender: TObject);
var
  Img: TImage absolute Sender;
begin
  if Img.Owner.Owner is TScrollBox then
  begin
    var ScrollBox := (Img.Owner.Owner as TScrollBox);
    ScrollBox.VertScrollBar.Range := ScrollBox.VertScrollBar.Range - Self.Height;
  end;

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

procedure TFrameEntry.tpStartChange(Sender: TObject);
begin
  UpdateElapsedTime;
end;

procedure TFrameEntry.tpStopChange(Sender: TObject);
begin
  UpdateElapsedTime;
end;

procedure TFrameEntry.UpdateElapsedTime;
begin
  ZeroSeconds;
  var Span := TTimeSpan.FromSeconds(tpStart.DateTime.SecondSpan(tpStop.DateTime));
  lblHours.Caption := Format('%.2dh%.2dm', [Span.Hours + (Span.Days * 24), Span.Minutes]);
end;

procedure TFrameEntry.ZeroSeconds;
begin
  RecodeSecond(tpStart.DateTime, 0);
  RecodeSecond(tpStop.DateTime, 0);
end;

end.
