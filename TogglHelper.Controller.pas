unit TogglHelper.Controller;

interface

uses
  System.Net.HttpClient, System.Net.URLClient, System.NetEncoding,
  TogglHelper.User, TogglHelper.Projects, TogglHelper.Tags, System.Classes;

type
  TToggleController = class
  private
    FConfigFile: string;
    FUser: TTogglUser;
    FApiToken: string;
    FProjects: TTogglProjects;
    FClient: THTTPClient;
    FResponse: TStringList;
    FTags: TTogglTags;
    procedure SetApiToken(const AValue: string);
    procedure FreeClasses;
    procedure CreateClasses;
    procedure SaveConfig;
    procedure LoadConfig;
    procedure SetClientHeaders;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Reset;
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
  System.JSON, System.DateUtils, Vcl.Dialogs;

{ TToggleController }

procedure TToggleController.Reset;
begin
  FreeClasses;
  CreateClasses;
end;

constructor TToggleController.Create;
begin
  FConfigFile := 'config.json';
  FResponse := TStringList.Create;
  FClient := THTTPClient.Create;

  FUser := TTogglUser.Create(FClient, FResponse);
  CreateClasses;
  LoadConfig;
end;

procedure TToggleController.CreateClasses;
begin
  FProjects := TTogglProjects.Create(FClient, FResponse);
  FTags := TTogglTags.Create(FClient, FResponse);
end;

destructor TToggleController.Destroy;
begin
  SaveConfig;
  FreeClasses;
  FClient.Free;
  FUser.Free;
  FResponse.Free;

  inherited;
end;

procedure TToggleController.FreeClasses;
begin
  FProjects.Free;
  FTags.Free;
end;

procedure TToggleController.LoadConfig;
begin
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
  for var i := Pred(AContainer.ComponentCount) downto 0 do
  begin
    var Entry := (AContainer.Components[i] as TframeEntry);
    var TagArray := TJSONArray.Create;
    var JString := TStringList.Create;
    var JObj := TJSONObject.Create;
    try
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

      JString.Add(JObj.Format(4));
      JString.SaveToFile('EntriesJson.txt');

      var Response := FClient.post('https://api.track.toggl.com/api/v9/workspaces/'+FUser.WorkspaceID.ToString+'/time_entries', 'EntriesJson.txt');
    finally
      JString.Free;
      JObj.Free;
    end;
  end;
end;

procedure TToggleController.SaveConfig;
begin
  var JConfig := TJSONObject.Create;
  try
    JConfig.AddPair('api_token', FApiToken);

    var JPrjArray := TJsonArray.Create;
    for var Pair in FProjects.List do
    begin
      var JPrj := TJSONObject.Create;
      JPrj.AddPair('name', Pair.Key);
      JPrj.AddPair('id', Pair.Value);
      JPrjArray.Add(JPrj);
    end;
    JConfig.AddPair('projects', JPrjArray);

    var JTagArray := TJsonArray.Create;
    for var Pair in FTags.List do
    begin
      var JTag := TJSONObject.Create;
      JTag.AddPair('name', Pair.Key);
      JTag.AddPair('id', Pair.Value);
      JTagArray.Add(JTag);
    end;
    JConfig.AddPair('tags', JTagArray);

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
