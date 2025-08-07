unit TogglHelper.EntryAdapter;

interface

uses
  TogglHelper.FrameEntry,
  System.JSON;

type
  TEntryAdapter = class
    class procedure AddEntryToJSON(AEntry: TframeEntry; AJSON: TJSONObject);
    class procedure FillEntryFromJSON(AEntry: TframeEntry; AJSON: TJSONObject);
  end;

implementation

uses
  TogglHelper.Controller,
  System.DateUtils,
  System.SysUtils;

{ TEntryAdapter }

class procedure TEntryAdapter.AddEntryToJSON(AEntry: TframeEntry; AJSON: TJSONObject);
begin
  AJSON.AddPair('created_with', 'TogglHelper');
  AJSON.AddPair('description', AEntry.edtEntry.Text);

  var TagKey := AEntry.cbTag.Text;
  var TagID := 0;
  var TagArray := TJSONArray.Create;
  if SingletonToggl.Tags.List.TryGetValue(TagKey, TagID) then
    TagArray.Add(TagID);
  AJSON.AddPair('tag_ids', TagArray);

  AJSON.AddPair('billable', AEntry.cbBillable.Checked);
  AJSON.AddPair('workspace_id', SingletonToggl.User.WorkspaceID);
  AJSON.AddPair('user_id', SingletonToggl.User.ID);

  var Start: TDateTime := AEntry.tpStart.Time + SingletonToggl.BaseDate;
  var Stop: TDateTime := AEntry.tpStop.Time + SingletonToggl.BaseDate;
  var Duration := SecondsBetween(Start, Stop);
  AJSON.AddPair('duration', Duration);
  AJSON.AddPair('start', FormatDateTime('YYYY"-"MM"-"DD"T"HH":"NN":"SS"."000"-03:00"', Start));

  var PrjKey := AEntry.cbPrj.Text;
  var PrjID := 0;
  if SingletonToggl.Projects.List.TryGetValue(PrjKey, PrjID) then
    AJSON.AddPair('project_id', PrjID);

  AJSON.AddPair('cb_prj_id', AEntry.cbPrj.ItemIndex);
  AJSON.AddPair('cb_tag_id', AEntry.cbTag.ItemIndex);
  AJSON.AddPair('time_start', AEntry.tpStart.Time);
  AJSON.AddPair('time_stop', AEntry.tpStop.Time);
  AJSON.AddPair('tag', AEntry.Tag);
end;

class procedure TEntryAdapter.FillEntryFromJSON(AEntry: TframeEntry; AJSON: TJSONObject);
begin
  var JTag := 0;
  if AJSON.TryGetValue<Integer>('tag', JTag) then
    AEntry.Tag := JTag;

  var JEntry := '';
  AJSON.TryGetValue<string>('description', JEntry);
  AEntry.edtEntry.Text := JEntry;

  SingletonToggl.FillComboBox(AEntry.cbPrj.Items, SingletonToggl.Projects.List.Keys.ToArray);
  var PrjID := 0;
  AJSON.TryGetValue<Integer>('cb_prj_id', PrjID);
  AEntry.cbPrj.ItemIndex := PrjID;

  SingletonToggl.FillComboBox(AEntry.cbTag.Items, SingletonToggl.Tags.List.Keys.ToArray);
  var TagID := 0;
  AJSON.TryGetValue<Integer>('cb_tag_id', TagID);
  AEntry.cbTag.ItemIndex := TagID;

  var EntryTime: Double := 0.0;
  if AJSON.TryGetValue<Double>('time_start', EntryTime) then
    AEntry.tpStart.Time := EntryTime
  else
    AEntry.tpStart.Time := Time;

  EntryTime := 0.0;
  if AJSON.TryGetValue<Double>('time_stop', EntryTime) then
    AEntry.tpStop.Time := EntryTime
  else
    AEntry.tpStop.Time := IncHour(Time, -1);
end;

end.
