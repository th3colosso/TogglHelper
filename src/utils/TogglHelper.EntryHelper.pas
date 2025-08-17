unit TogglHelper.EntryHelper;

interface

uses
  TogglHelper.FrameEntry,
  System.JSON;

type
  TEntryHelper = class Helper for TFrameEntry
    procedure MapToJSON(AJSON: TJSONObject);
    procedure MapFromJson(AJSON: TJSONObject);
  end;

implementation

uses
  TogglHelper.Controller,
  System.DateUtils,
  System.SysUtils;

{ TEntryHelper }

procedure TEntryHelper.MapFromJson(AJSON: TJSONObject);
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

  SingletonToggl.FillComboBox(Self.cbTag.Items, SingletonToggl.Tags.List.Keys.ToArray);
  var TagID := 0;
  AJSON.TryGetValue<Integer>('cb_tag_id', TagID);
  Self.cbTag.ItemIndex := TagID;

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
end;

procedure TEntryHelper.MapToJSON(AJSON: TJSONObject);
begin
  AJSON.AddPair('created_with', 'TogglHelper');
  AJSON.AddPair('description', Self.edtEntry.Text);

  var TagKey := Self.cbTag.Text;
  var TagID := 0;
  var TagArray := TJSONArray.Create;
  if SingletonToggl.Tags.List.TryGetValue(TagKey, TagID) then
    TagArray.Add(TagID);
  AJSON.AddPair('tag_ids', TagArray);

  AJSON.AddPair('billable', Self.cbBillable.Checked);
  AJSON.AddPair('workspace_id', SingletonToggl.User.WorkspaceID);
  AJSON.AddPair('user_id', SingletonToggl.User.ID);

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
  AJSON.AddPair('cb_tag_id', Self.cbTag.ItemIndex);
  AJSON.AddPair('time_start', Self.tpStart.Time);
  AJSON.AddPair('time_stop', Self.tpStop.Time);
  AJSON.AddPair('tag', Self.Tag);
end;

end.
