unit TogglHelper.Controller;

interface

uses
  System.Net.HttpClient, System.Net.URLClient, System.NetEncoding,
  TogglHelper.User, TogglHelper.Projects, TogglHelper.Tags, System.Classes;

type
  TToggleController = class
  private
    FConfigFile: string;
    FEntriesFile: string;
    FUser: TTogglUser;
    FApiToken: string;
    FProjects: TTogglProjects;
    FClient: THTTPClient;
    FResponse: TStringList;
    FTags: TTogglTags;
    procedure SetApiToken(const AValue: string);
    procedure SaveConfig;
    procedure LoadConfig;
    procedure SetClientHeaders;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Reset;
    procedure RealoadLastEntries(AContainer: TComponent);
    procedure PushAllEntries(AContainer: TComponent; ADate: TDateTime);
    property Response: TStringList read FResponse;
    property User: TTogglUser read FUser;
    property Projects: TTogglProjects read FProjects;
    property Tags: TTogglTags read FTags;
    property ApiToken: string read FApiToken write SetApiToken;
  end;

var
  SingletonToggl: TToggleController;

implementation

uses
  System.SysUtils, System.NetConsts, TogglHelper.FrameEntry,
  System.JSON, System.DateUtils, Vcl.Dialogs, Vcl.Forms, Vcl.StdCtrls, Vcl.Controls;

{ TToggleController }

procedure TToggleController.RealoadLastEntries(AContainer: TComponent);
begin
  if not FileExists(FEntriesFile) then
    Exit;

  if AContainer.ComponentCount > 0 then
    Exit;

  TThread.Synchronize(nil,
  procedure
  begin
    var Stream := TStringStream.Create;
    Stream.LoadFromFile(FEntriesFile);
    var JArray: TJsonArray;
    try
      JArray := TJSONObject.ParseJSONValue(Stream.DataString) as TJsonArray;
    finally
      Stream.Free;
    end;

    try
      for var JObj in JArray do
      begin
        var Entry := TframeEntry.Create(AContainer);
        (AContainer as TScrollBox).VertScrollBar.Range := (AContainer as TScrollBox).VertScrollBar.Range + Entry.Height;
        Entry.Name := 'Entry_' + FormatDateTime('HH_NN_SS_ZZZ', Now);
        Entry.Parent := (AContainer as TScrollBox);
        Entry.Align := alTop;

        var JEntry := '';
        JObj.TryGetValue<string>('description', JEntry);
        Entry.edtEntry.Text := JEntry;

        for var Key in SingletonToggl.Projects.List.Keys.ToArray do
          Entry.cbPrj.Items.Add(Key);

        var PrjID := 0;
        JObj.TryGetValue<Integer>('cb_prj_id', PrjID);
        Entry.cbPrj.ItemIndex := PrjID;

        for var Key in SingletonToggl.Tags.List.Keys.ToArray do
          Entry.cbTag.Items.Add(Key);

        var TagID := 0;
        JObj.TryGetValue<Integer>('cb_tag_id', TagID);
        Entry.cbTag.ItemIndex := TagID;

        var EntryTime: Double := 0.0;
        if JObj.TryGetValue<Double>('time_start', EntryTime) then
          Entry.tpStart.Time := EntryTime
        else
          Entry.tpStart.Time := Time;

        EntryTime := 0.0;
        if JObj.TryGetValue<Double>('time_stop', EntryTime) then
          Entry.tpStop.Time := EntryTime
        else
          Entry.tpStop.Time := IncHour(Time, -1);
      end;
    finally
      JArray.Free;
    end;
  end
  );
end;

procedure TToggleController.Reset;
begin
  FProjects.List.Clear;
  FTags.List.Clear;
end;

constructor TToggleController.Create;
begin
  FConfigFile := 'config.json';
  FEntriesFile := 'entries.json';
  FResponse := TStringList.Create;
  FClient := THTTPClient.Create;

  FUser := TTogglUser.Create(FClient, FResponse);
  FProjects := TTogglProjects.Create(FClient, FResponse);
  FTags := TTogglTags.Create(FClient, FResponse);
  LoadConfig;
end;

destructor TToggleController.Destroy;
begin
  SaveConfig;
  FProjects.Free;
  FTags.Free;
  FClient.Free;
  FUser.Free;
  FResponse.Free;

  inherited;
end;

procedure TToggleController.LoadConfig;
begin
  if not FileExists(FConfigFile) then
    Exit;

  var Stream := TStringStream.Create;
  try
    Stream.LoadFromFile(FConfigFile);

    var JConfig := TJSONObject.ParseJSONValue(Stream.DataString);
    try
      if JConfig.TryGetValue<string>('api_token', FApiToken) then
        SetClientHeaders;
    finally
      JConfig.Free;
    end;
  finally
    Stream.Free;
  end;
end;

procedure TToggleController.PushAllEntries(AContainer: TComponent; ADate: TDateTime);
begin
  var JEntries := TJsonArray.Create;
  var JString := TStringStream.Create;
  try
    for var i := Pred(AContainer.ComponentCount) downto 0 do
    begin
      var Entry := (AContainer.Components[i] as TframeEntry);
      var TagArray := TJSONArray.Create;
      var JObj := TJSONObject.Create;
      JObj.AddPair('created_with', 'TogglHelper');
      JObj.AddPair('description', Entry.edtEntry.Text);

      var TagKey := Entry.cbTag.Text;
      var TagID := 0;
      if FTags.List.TryGetValue(TagKey, TagID) then
        TagArray.Add(TagID);
      JObj.AddPair('tag_ids', TagArray);

      JObj.AddPair('billable', Entry.cbBillable.Checked);
      JObj.AddPair('workspace_id', FUser.WorkspaceID);
      Jobj.AddPair('user_id', FUser.ID);

      var Start: TDateTime := Entry.tpStart.Time + ADate;
      var Stop: TDateTime := Entry.tpStop.Time + ADate;
      var Duration := SecondsBetween(Start, Stop);
      JObj.AddPair('duration', Duration);
      JObj.AddPair('start', FormatDateTime('YYYY"-"MM"-"DD"T"HH":"NN":"SS"."000"-03:00"', Start));

      var PrjKey := Entry.cbPrj.Text;
      var PrjID := 0;
      if FProjects.List.TryGetValue(PrjKey, PrjID) then
        JObj.AddPair('project_id', PrjID);

      JString.Clear;
      JString.WriteString(JObj.Format(4));
      JString.SaveToFile('body.json');

      JObj.AddPair('cb_prj_id', Entry.cbPrj.ItemIndex);
      JObj.AddPair('cb_tag_id', Entry.cbTag.ItemIndex);
      JObj.AddPair('time_start', Entry.tpStart.Time);
      JObj.AddPair('time_stop', Entry.tpStop.Time);

      JEntries.Add(JObj);

      if not Entry.cbPush.checked then
        continue;

      var Response := FClient.post('https://api.track.toggl.com/api/v9/workspaces/'+FUser.WorkspaceID.ToString+'/time_entries', 'body.json');
    end;

    JString.Clear;
    JString.WriteString(JEntries.Format(4));
    JString.SaveToFile(FEntriesFile);
  finally
    JString.Free;
    JEntries.Free;
  end;
end;

procedure TToggleController.SaveConfig;
begin
  if FApiToken.Trim.IsEmpty then
    Exit;

  var JConfig := TJSONObject.Create;
  try
    JConfig.AddPair('api_token', FApiToken.Trim);

    var Stream := TStringStream.Create(JConfig.Format(2));
    try
      Stream.SaveToFile(FConfigFile);
    finally
      Stream.Free;
    end;
  finally
    JConfig.Free;
  end;
end;

procedure TToggleController.SetClientHeaders;
begin
  var AuthValue := ApiToken + ':api_token';
  var AuthHeader := 'Basic ' + TNetEncoding.Base64.Encode(AuthValue);
  FClient.CustomHeaders['Authorization'] := AuthHeader;
  FClient.CustomHeaders['Host'] := 'api.track.toggl.com';
  FClient.ContentType := 'application/json';
end;

procedure TToggleController.SetApiToken(const AValue: string);
begin
  if (AValue.IsEmpty) or (FApiToken = AValue) then
    Exit;

  FApiToken := AValue;

  SetClientHeaders;
end;

initialization
  SingletonToggl := TToggleController.Create;

finalization
  SingletonToggl.Free;

end.
