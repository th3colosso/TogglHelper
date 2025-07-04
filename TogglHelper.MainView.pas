unit TogglHelper.MainView;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, TogglHelper.User, Vcl.ExtCtrls, Vcl.WinXPickers, Vcl.WinXCtrls;

type

{$SCOPEDENUMS ON}
  TStatus = (NoStatus, Authenticated, Error, Updating, Complete);
{$SCOPEDENUMS OFF}

  TfrmMain = class(TForm)
    pcMain: TPageControl;
    tsSettings: TTabSheet;
    lblToken: TLabel;
    btnAuth: TButton;
    gbResult: TGroupBox;
    edtFullName: TEdit;
    lblFullName: TLabel;
    lblEmail: TLabel;
    edtEmail: TEdit;
    edtApiToken: TEdit;
    pnlStatus: TPanel;
    mmRes: TMemo;
    edtTogglID: TEdit;
    lblWorkSpace_UserID: TLabel;
    lblResponseJson: TLabel;
    tsEntries: TTabSheet;
    pnlDefault: TPanel;
    lblProjects: TLabel;
    btnUpdate: TButton;
    cbProjects: TComboBox;
    sbEntries: TScrollBox;
    cbTags: TComboBox;
    lblTag: TLabel;
    btnAdd: TButton;
    btnPush: TButton;
    lblData: TLabel;
    dpBase: TDatePicker;
    actIndIcator: TActivityIndicator;
    procedure btnAddClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnAuthClick(Sender: TObject);
    procedure btnPushClick(Sender: TObject);
    procedure btnUpdateClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    procedure Authenticate;
    procedure UpdateBaseData;
    procedure AddEntry;
    procedure UpdateStatus(AStatus: TStatus);
  end;

var
  frmMain: TfrmMain;

implementation

uses
  System.Threading, System.UITypes, System.DateUtils,
  TogglHelper.Controller, TogglHelper.FrameEntry;

{$R *.dfm}

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  pcMain.ActivePage := tsEntries;
  dpBase.Date := Date;
end;

procedure TfrmMain.AddEntry;
begin
  var Entry := TframeEntry.Create(sbEntries);
  sbEntries.VertScrollBar.Range := sbEntries.VertScrollBar.Range + Entry.Height;
  Entry.Name := 'Entry_' + FormatDateTime('HH_NN_SS_ZZZ', Now);
  Entry.Parent := sbEntries;
  Entry.cbPrj.Items := cbProjects.Items;
  Entry.cbPrj.ItemIndex := cbProjects.ItemIndex;
  Entry.cbTag.Items := cbTags.Items;
  Entry.cbTag.ItemIndex := cbTags.ItemIndex;
  Entry.tpStart.Time := IncHour(Time, -1);
  Entry.tpStop.Time := Time;
  Entry.edtEntry.Text := 'CGMSPR-123456 ';
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
    mmRes.Lines.Text := SingletonToggl.Response.Text;
    UpdateStatus(TStatus.Error);
    Exit;
  end;

  edtFullName.Text := SingletonToggl.User.Name;
  edtEmail.Text := SingletonToggl.User.Email;
  edtTogglID.Text := SingletonToggl.User.WorkspaceID.ToString + ' / ' + SingletonToggl.User.ID.ToString;
  mmRes.Lines.Text := SingletonToggl.Response.Text;
  btnUpdate.Enabled := True;

  UpdateStatus(TStatus.Authenticated);
end;

procedure TfrmMain.btnAddClick(Sender: TObject);
begin
  if (cbProjects.Items.Count = 0) or (cbTags.Items.Count = 0) then
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

procedure TfrmMain.btnPushClick(Sender: TObject);
begin
  TButton(Sender).Enabled := False;
  TTask.Run(
  procedure
  begin
    actIndIcator.Animate := True;
    try
      var btn := TButton(Sender);
      var CaptionOld := btn.Caption;
      btn.Caption := 'Sending Entries...';
      Sleep(500);
      SingletonToggl.PushAllEntries(sbEntries, dpBase.Date);
      btn.Caption := 'Done';
      Sleep(2000);
      btn.Caption := CaptionOld;
      btn.Enabled := True;
    finally
      actIndIcator.Animate := False;
    end;
  end
  );
end;

procedure TfrmMain.btnUpdateClick(Sender: TObject);
begin
  UpdateBaseData;
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  if not SingletonToggl.ApiToken.Trim.IsEmpty then
  begin
    edtApiToken.Text := SingletonToggl.ApiToken.Trim;
    Authenticate;

    if SingletonToggl.User.ID > 0 then
    begin
      UpdateBaseData;
    end;
  end;
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
      for var Key in SingletonToggl.Projects.List.Keys.ToArray do
        cbProjects.Items.Add(Key);
      cbProjects.ItemIndex := 0;
      mmRes.Lines.Add(SingletonToggl.Response.Text);

      //TAGS
      SingletonToggl.Tags.UpdateList;
      for var Key in SingletonToggl.Tags.List.Keys.ToArray do
        cbTags.Items.Add(Key);
      cbTags.ItemIndex := 0;
      mmRes.Lines.Add(SingletonToggl.Response.Text);

      SingletonToggl.RealoadLastEntries(sbEntries);

      UpdateStatus(TStatus.Complete);

      Self.Caption := Self.Caption + ' [ready]';
    except
      on E: Exception do
      begin
        UpdateStatus(TStatus.Error);
        mmRes.Text := E.Message;
      end;
    end;
  end
  );

end;

end.
