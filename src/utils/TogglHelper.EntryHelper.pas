unit TogglHelper.EntryHelper;

interface

uses
  TogglHelper.FrameEntry,
  System.JSON;

type
  TEntryHelper = class Helper for TFrameEntry
    procedure ZeroSeconds;
    procedure MapToJSON(const AJSON: TJSONObject);
    procedure MapFromJson(const AJSON: TJSONObject);
    procedure Init(const ADefProjectIndex: Integer);
  end;

implementation

uses
  TogglHelper.Controller,
  System.DateUtils,
  System.SysUtils,
  Vcl.Controls;

{ TEntryHelper }

procedure TEntryHelper.Init(const ADefProjectIndex: Integer);
begin
  Self.Name := 'Entry_' + FormatDateTime('HH_NN_SS_ZZZ', Now);
  Self.Tag := Self.Owner.ComponentCount;
  Self.Top := Self.Height * Self.Tag;
  if Self.Owner is TWinControl then
    Self.Parent := (Self.Owner as TWinControl);
  Self.Align := altop;
  SingletonToggl.FillComboBox(Self.cbPrj.Items, SingletonToggl.Projects.List.Keys.ToArray);
  Self.cbPrj.ItemIndex := ADefProjectIndex;
  Self.tpStart.Time := IncHour(Time, -1);
  Self.tpStop.Time := Time;
  Self.UpdateElapsedTime;
  Self.edtEntry.Text := 'CGMFRAVII-12345 ';
  Self.OnTagReorder := SingletonToggl.ReorderEntries;
end;

procedure TEntryHelper.MapFromJson(const AJSON: TJSONObject);
begin
  var JTag := 0;
  if AJSON.TryGetValue<Integer>('tag', JTag) then
    Self.Tag := JTag;

  var JEntry := '';
  AJSON.TryGetValue<string>('description', JEntry);
  Self.edtEntry.Text := JEntry;

  SingletonToggl.FillComboBox(Self.cbPrj.Items, SingletonToggl.Projects.List.Keys.ToArray);
  var PrjID := 0;
  AJSON.TryGetValue<Integer>('cb_prj_id', PrjID);
  Self.cbPrj.ItemIndex := PrjID;

  var EntryTime: Double := 0.0;
  if AJSON.TryGetValue<Double>('time_start', EntryTime) then
    Self.tpStart.Time := EntryTime
  else
    Self.tpStart.Time := Time;

  EntryTime := 0.0;
  if AJSON.TryGetValue<Double>('time_stop', EntryTime) then
    Self.tpStop.Time := EntryTime
  else
    Self.tpStop.Time := IncHour(Time, -1);

  Self.UpdateElapsedTime;
end;

procedure TEntryHelper.MapToJSON(const AJSON: TJSONObject);
begin
  AJSON.AddPair('created_with', 'TogglHelper');
  AJSON.AddPair('description', Self.edtEntry.Text);

  AJSON.AddPair('billable', Self.cbBillable.Checked);
  AJSON.AddPair('workspace_id', SingletonToggl.User.WorkspaceID);
  AJSON.AddPair('user_id', SingletonToggl.User.ID);

  ZeroSeconds;
  var Start: TDateTime := Self.tpStart.Time + SingletonToggl.BaseDate;
  var Stop: TDateTime := Self.tpStop.Time + SingletonToggl.BaseDate;
  var Duration := SecondsBetween(Start, Stop);
  AJSON.AddPair('duration', Duration);
  AJSON.AddPair('start', FormatDateTime('YYYY"-"MM"-"DD"T"HH":"NN":"SS"."000"-03:00"', Start));

  var PrjKey := Self.cbPrj.Text;
  var PrjID := 0;
  if SingletonToggl.Projects.List.TryGetValue(PrjKey, PrjID) then
    AJSON.AddPair('project_id', PrjID);

  AJSON.AddPair('cb_prj_id', Self.cbPrj.ItemIndex);
  AJSON.AddPair('time_start', Self.tpStart.Time);
  AJSON.AddPair('time_stop', Self.tpStop.Time);
  AJSON.AddPair('tag', Self.Tag);
end;

procedure TEntryHelper.ZeroSeconds;
var
  H, N, S, MS: Word;
begin
  DecodeTime(Self.tpStart.Time, H, N, S, MS);
  Self.tpStart.Time := EncodeTime(H, N, 0, 0);
  DecodeTime(Self.tpStop.Time, H, N, S, MS);
  Self.tpStop.Time := EncodeTime(H, N, 0, 0);
end;

end.
