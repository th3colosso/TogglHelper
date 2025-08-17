unit TogglHelper.MainView;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, TogglHelper.User, Vcl.WinXPickers,
  Vcl.ExtCtrls, Vcl.WinXCtrls, Vcl.Menus, System.Notification;

type
{$SCOPEDENUMS ON}
  TStatus = (NoStatus, Authenticated, Error, Updating, Complete);
{$SCOPEDENUMS OFF}

  TfrmMain = class(TForm)
    pcMain: TPageControl;
    tsSettings: TTabSheet;
    lblToken: TLabel;
    btnAuth: TButton;
    gbTogglInfo: TGroupBox;
    edtFullName: TEdit;
    lblFullName: TLabel;
    lblEmail: TLabel;
    edtEmail: TEdit;
    edtApiToken: TEdit;
    pnlStatus: TPanel;
    edtDefWorkSpaceID: TEdit;
    lblWorkSpaceID: TLabel;
    tsEntries: TTabSheet;
    pnlDefault: TPanel;
    lblProjects: TLabel;
    btnUpdate: TButton;
    cbProjects: TComboBox;
    sbEntries: TScrollBox;
    btnAdd: TButton;
    btnPush: TButton;
    lblData: TLabel;
    dpBase: TDatePicker;
    lblUserID: TLabel;
    edtUserID: TEdit;
    actIndicator: TActivityIndicator;
    gbOther: TGroupBox;
    cbStyle: TComboBox;
    lblStyle: TLabel;
    btnSort: TButton;
    popSort: TPopupMenu;
    Date1: TMenuItem;
    Description1: TMenuItem;
    Tag1: TMenuItem;
    NC: TNotificationCenter;
    btnBulkEdit: TButton;
    procedure btnAddClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnAuthClick(Sender: TObject);
    procedure btnPushClick(Sender: TObject);
    procedure btnUpdateClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cbProjectsChange(Sender: TObject);
    procedure cbStyleChange(Sender: TObject);
    procedure Description1Click(Sender: TObject);
    procedure Date1Click(Sender: TObject);
    procedure Tag1Click(Sender: TObject);
    procedure NCReceiveLocalNotification(Sender: TObject; ANotification: TNotification);
    procedure btnSortMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure btnBulkEditMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  private
    procedure Authenticate;
    procedure UpdateBaseData;
    procedure AddEntry;
    procedure UpdateStatus(AStatus: TStatus);
    procedure LoadStyles;
    procedure CheckVersion;
  end;

var
  frmMain: TfrmMain;

implementation

uses
  System.Threading, System.UITypes, System.DateUtils,
  TogglHelper.Controller, TogglHelper.FrameEntry, Vcl.Themes,
  Vcl.Styles, Winapi.ShellAPI, System.RegularExpressions;

{$R *.dfm}

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  pcMain.ActivePage := tsEntries;
  dpBase.Date := Date;
  LoadStyles;
  CheckVersion;
end;

procedure TfrmMain.AddEntry;
begin
  SingletonToggl.NewEntry(sbEntries, cbProjects.ItemIndex);
end;

procedure TfrmMain.Authenticate;
begin
  var Token := Trim(edtApiToken.Text);
  if Token.IsEmpty then
  begin
    MessageDlg('Please provide your Toggle API Token!', TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], 0);
    Exit;
  end;

  SingletonToggl.ApiToken := Token;

  if not SingletonToggl.User.Authenticate then
  begin
    btnUpdate.Enabled := False;
    UpdateStatus(TStatus.Error);
    Exit;
  end;

  edtFullName.Text := SingletonToggl.User.Name;
  edtEmail.Text := SingletonToggl.User.Email;
  edtDefWorkSpaceID.Text := SingletonToggl.User.WorkspaceID.ToString;
  edtUserID.Text := SingletonToggl.User.ID.ToString;
  btnUpdate.Enabled := True;

  UpdateStatus(TStatus.Authenticated);
end;

procedure TfrmMain.btnAddClick(Sender: TObject);
begin
  if (cbProjects.Items.Count = 0) then
  begin
    MessageDlg('Please Authenticate and Update Data first!', TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], 0);
    pcMain.ActivePage := tsSettings;
    Exit;
  end;

  AddEntry;
end;

procedure TfrmMain.btnAuthClick(Sender: TObject);
begin
  Authenticate;
end;

procedure TfrmMain.btnBulkEditMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Request, Response: array [0..1] of string;
  Title: string;
  IsWholeLine: Boolean;
begin
  Request[0] := 'Text to find:';
  Request[1] := 'Replace with:';

  IsWholeLine := ssCtrl in Shift;

  Title := 'Bulk Edit';
  if IsWholeLine then
    Title := 'Bulk Edit [line_replace]';

  if not InputQuery(Title, Request, Response) then
  begin
    pnlDefault.SetFocus;
    Exit;
  end;

  for var i := 0 to Pred(sbEntries.ComponentCount) do
  begin
    var Entry := sbentries.Components[i] as TFrameEntry;
    if IsWholeLine then
    begin
      if TRegEx.IsMatch(Entry.edtEntry.Text, '\b' + Response[0] + '\b', [roIgnoreCase]) then
        Entry.edtEntry.Text := Response[1];
    end
    else
      Entry.edtEntry.Text := TRegEx.Replace(Entry.edtEntry.Text, '\b' + Response[0] + '\b', Response[1], [roIgnoreCase]);
  end;

  pnlDefault.SetFocus;
end;

procedure TfrmMain.btnPushClick(Sender: TObject);
begin
  TButton(Sender).Enabled := False;
  actIndIcator.Animate := True;
  var btn := TButton(Sender);
  var CaptionOld := btn.Caption;
  btn.Caption := 'Sending Entries...';

  TTask.Run(
  procedure
  begin
    try
      Sleep(500);
      SingletonToggl.PushAllEntries(sbEntries, dpBase.Date);
    finally
      btn.Caption := 'Done';
      Sleep(2000);
      btn.Caption := CaptionOld;
      btn.Enabled := True;
      TThread.Synchronize(nil,
      procedure
      begin
        actIndIcator.Animate := False;
      end);
    end;
  end);
end;

procedure TfrmMain.btnSortMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  popSort.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
  pnlDefault.SetFocus;
end;

procedure TfrmMain.btnUpdateClick(Sender: TObject);
begin
  UpdateBaseData;
end;

procedure TfrmMain.cbProjectsChange(Sender: TObject);
begin
  SingletonToggl.UpdateAllCombo((Sender as TComboBox).ItemIndex, sbEntries);
end;

procedure TfrmMain.cbStyleChange(Sender: TObject);
begin
  if SingletonToggl.StyleName.Equals(cbStyle.Text) then
    Exit;

  SingletonToggl.StyleName := cbStyle.Text;
  MessageDlg('Please restart app to apply changes!', TMsgDlgType.mtInformation, [TMsgDlgBtn.mbOK], 0);
end;

procedure TfrmMain.CheckVersion;
begin
  if SingletonToggl.IsLastVersion then
    Exit;

  var Noti := TNotification.Create;
  try
    Noti.Name := 'Update';
    Noti.Title := 'TogglHelper';
    Noti.AlertBody := 'There is a new release available on Github! Click here to download.';
    NC.PresentNotification(Noti);
  finally
    Noti.Free;
  end;
end;

procedure TfrmMain.Date1Click(Sender: TObject);
begin
  SingletonToggl.ReorderEntries(sbEntries, TSortParam.Time);
end;

procedure TfrmMain.Description1Click(Sender: TObject);
begin
  SingletonToggl.ReorderEntries(sbEntries, TSortParam.Description);
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  if not SingletonToggl.ApiToken.Trim.IsEmpty then
  begin
    edtApiToken.Text := SingletonToggl.ApiToken.Trim;
    Authenticate;

    {$IFDEF DEBUG}
      Exit;
    {$ENDIF}

    if SingletonToggl.User.ID > 0 then
    begin
      UpdateBaseData;
    end;
  end;
end;

procedure TfrmMain.LoadStyles;
begin
  for var Style in TStyleManager.StyleNames do
  begin
    cbStyle.Items.Add(Style);
  end;

  cbStyle.ItemIndex := cbStyle.Items.IndexOf(TStyleManager.ActiveStyle.Name);
end;

procedure TfrmMain.NCReceiveLocalNotification(Sender: TObject; ANotification: TNotification);
begin
  if ANotification.Name = 'Update' then
    ShellExecute(Self.Handle, 'open', 'https://github.com/th3colosso/TogglHelper/releases/latest', '', '', SW_SHOWNORMAL);
end;

procedure TfrmMain.Tag1Click(Sender: TObject);
begin
  SingletonToggl.ReorderEntries(sbEntries, TSortParam.Tag);
end;

procedure TfrmMain.UpdateStatus(AStatus: TStatus);
begin
  case AStatus of
    TStatus.NoStatus:
      begin
        pnlStatus.Caption := 'No Update Status';
        pnlStatus.Color := clGray;
      end;
    TStatus.Authenticated:
      begin
        pnlStatus.Caption := 'Authenticated';
        pnlStatus.Color := clGreen;
        Self.Caption := 'TogglHelper [authenticated]'
      end;
    TStatus.Error:
      begin
        pnlStatus.Caption := 'Error updating data';
        pnlStatus.Color := clRed;
      end;
    TStatus.Updating:
      begin
        pnlStatus.Caption := 'Updating data';
        pnlStatus.Color := clBlue;
        Self.Caption := 'TogglHelper [authenticated]'
      end;
    TStatus.Complete:
      begin
        pnlStatus.Caption := 'Update complete';
        pnlStatus.Color := clGreen;
        Self.Caption := Self.Caption + ' [ready]';
      end
    else
      begin
        pnlStatus.Caption := 'No Info';
        pnlStatus.Color := clGray;
      end;
  end;
end;

procedure TfrmMain.UpdateBaseData;
begin
  UpdateStatus(TStatus.Updating);

  SingletonToggl.Reset;

  TTask.Run(
  procedure
  begin
    try
      //PROJECTS
      SingletonToggl.Projects.UpdateList;
      SingletonToggl.FillComboBox(cbProjects.Items, SingletonToggl.Projects.List.Keys.ToArray);
      cbProjects.ItemIndex := 0;

      //TAGS
      SingletonToggl.Tags.UpdateList;

      SingletonToggl.RealoadLastEntries(sbEntries);

      UpdateStatus(TStatus.Complete);
    except
      on E: Exception do
      begin
        UpdateStatus(TStatus.Error);
      end;
    end;
  end
  );

end;

end.
