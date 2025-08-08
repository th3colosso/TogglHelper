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
    FBaseDate: TDateTime;
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
    procedure FillComboBox(AComboItems: TStrings; AItemArray: TArray<string>);
    procedure UpdateAllCombo(AItemIndex: Integer; AContainer: TComponent);
    procedure ReorderEntries(AContainer: TComponent);
    property Response: TStringList read FResponse;
    property User: TTogglUser read FUser;
    property Projects: TTogglProjects read FProjects;
    property Tags: TTogglTags read FTags;
    property ApiToken: string read FApiToken write SetApiToken;
    property BaseDate: TDateTime read FBaseDate;
  end;

var
  SingletonToggl: TToggleController;

implementation

uses
  System.SysUtils, System.NetConsts, TogglHelper.FrameEntry,
  System.JSON, System.DateUtils, Vcl.Dialogs, Vcl.Forms, Vcl.StdCtrls,
  Vcl.Controls, System.Generics.Collections, TogglHelper.EntryAdapter;

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
    var Stream := TStringStream.Create('', TEncoding.UTF8);
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
        Entry.Tag := AContainer.ComponentCount;
        Entry.Align := alTop;
        Entry.OnTagReorder := ReorderEntries;
        TEntryAdapter.FillEntryFromJSON(Entry, JObj as TJSONObject);
      end;
    finally
      JArray.Free;
    end;
    ReorderEntries(AContainer);
  end
  );
end;

procedure TToggleController.ReorderEntries(AContainer: TComponent);
begin
  if not Assigned(AContainer) then
    Exit;

  if not (AContainer is TScrollBox) then
    Exit;

  var SB := AContainer as TScrollBox;
  SB.LockDrawing;
  try
    var CompList := TList<TComponent>.Create;
    try
      for var i := 0 to SB.ComponentCount - 1 do
      begin
        if not (SB.Components[i] is TframeEntry) then
          Continue;

        CompList.Add(SB.Components[i]);
        TframeEntry(SB.Components[i]).Parent := nil;
      end;

      for var i := 1 to SB.ComponentCount do
      begin
        for var j := 0 to CompList.Count - 1 do
        begin
          if CompList.Items[j].Tag = i then
          begin
            TFrameEntry(CompList.Items[j]).Parent := SB;
            TFrameEntry(CompList.Items[j]).Top := TFrameEntry(CompList.Items[j]).Height * i;
            Break;
          end;
        end;
      end;
    finally
      CompList.Free;
    end;
  finally
    SB.UnlockDrawing;
  end;
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

procedure TToggleController.FillComboBox(AComboItems: TStrings; AItemArray: TArray<string>);
begin
  for var item in AItemArray do
    AComboItems.Add(item);
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
  FBaseDate := ADate;
  var JEntries := TJsonArray.Create;
  var JString := TStringStream.Create('', TEncoding.UTF8);
  try
    for var i := 0 to Pred(AContainer.ComponentCount) do
    begin
      var Entry := (AContainer.Components[i] as TframeEntry);
      var JObj := TJSONObject.Create;
      TEntryAdapter.AddEntryToJSON(Entry, JObj);

      JString.Clear;
      JString.WriteString(JObj.Format(4));
      JString.SaveToFile('body.json');

      JEntries.Add(JObj);

      if not Entry.cbPush.checked then
        continue;

      FClient.post('https://api.track.toggl.com/api/v9/workspaces/'+FUser.WorkspaceID.ToString+'/time_entries', 'body.json');
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
  FClient.ContentType := 'application/json; charset=utf-8';
end;

procedure TToggleController.UpdateAllCombo(AItemIndex: Integer; AContainer: TComponent);
begin
  for var i := 0 to Pred(AContainer.ComponentCount) do
  begin
    var Entry := (AContainer.Components[i] as TframeEntry);
    Entry.cbPrj.ItemIndex := AItemIndex;
  end;
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
