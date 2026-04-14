unit TogglHelper.Controller;

interface

uses
  System.Net.HttpClient, System.Net.URLClient, System.NetEncoding,
  TogglHelper.User, TogglHelper.Projects, System.Classes,
  Vcl.StdCtrls, Vcl.Controls, Vcl.Forms, TogglHelper.FrameEntry, System.TimeSpan;

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
    FBaseDate: TDateTime;
    FJSonBody: string;
    FStyleName: string;
    FDoVersionCheck: Boolean;
    procedure SetApiToken(const AValue: string);
    procedure SetDoVersionCheck(const AValue: Boolean);
    procedure SaveConfig;
    procedure LoadConfig;
    procedure SetClientHeaders;
    function GetAppFolder: string;
    procedure OnResponseChange(Sender: TObject);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Reset;
    procedure NewEntry(AContainer: TScrollBox; ADefProjectIndex: Integer);
    procedure RealoadLastEntries(AContainer: TScrollBox);
    procedure PushAllEntries(AContainer: TScrollBox; ADate: TDateTime);
    procedure FillComboBox(AComboItems: TStrings; AItemArray: TArray<string>);
    procedure UpdateAllCbProj(AItemIndex: Integer; AContainer: TScrollBox);
    procedure ReorderEntries(AContainer: TScrollBox; ASortParam: TSortParam = TSortParam.Default);
    function GetTotalTimeSpan(AContainer: TScrollBox): TTimeSpan;
    function GetValidEntries(AContainer: TScrollBox): Integer;
    property Response: TStringList read FResponse;
    property User: TTogglUser read FUser;
    property Projects: TTogglProjects read FProjects;
    property ApiToken: string read FApiToken write SetApiToken;
    property BaseDate: TDateTime read FBaseDate;
    property StyleName: string read FStyleName write FStyleName;
    property DoCheckVersion: Boolean read FDoVersionCheck write SetDoVersionCheck;
    property LastSentDay: TDateTime read FBaseDate write FBaseDate;
  end;

var
  SingletonToggl: TToggleController;

implementation

uses
  System.SysUtils, System.NetConsts,
  System.JSON, System.DateUtils, Vcl.Dialogs,
  System.Generics.Collections, TogglHelper.EntryHelper,
  Vcl.Themes, System.IOUtils, System.Generics.Defaults,
  System.Math, Winapi.Windows, TogglHelper.DataVisualizer;

{ TToggleController }

procedure TToggleController.RealoadLastEntries(AContainer: TScrollBox);
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
        AContainer.VertScrollBar.Range := AContainer.VertScrollBar.Range + Entry.Height;
        Entry.Name := 'Entry_' + FormatDateTime('HH_NN_SS_ZZZ', Now);
        Entry.Parent := AContainer;
        Entry.Tag := AContainer.ComponentCount;
        Entry.Align := alTop;
        Entry.OnTagReorder := ReorderEntries;
        Entry.MapFromJson(JObj as TJSONObject)
      end;
    finally
      JArray.Free;
    end;
    ReorderEntries(AContainer);
  end
  );
end;

procedure TToggleController.ReorderEntries(AContainer: TScrollBox; ASortParam: TSortParam = TSortParam.Default);
begin
  if not Assigned(AContainer) then
    Exit;

  AContainer.LockDrawing;
  try
    var FrameList := TList<TFrameEntry>.Create;
    try
      for var i := 0 to AContainer.ComponentCount - 1 do
      begin
        if not (AContainer.Components[i] is TFrameEntry) then
          Continue;

        FrameList.Add(AContainer.Components[i] as TFrameEntry);
        TframeEntry(AContainer.Components[i]).Parent := nil;
      end;

      FrameList.Sort(TComparer<TFrameEntry>.Construct(
        function(const Left, Right: TFrameEntry): Integer
        begin
          case ASortParam of
            TSortParam.Default: Result := CompareValue(Left.Tag, Right.Tag);
            TSortParam.Description: Result := CompareStr(Left.edtEntry.Text, Right.edtEntry.Text);
            TSortParam.Time: Result := CompareTime(Left.tpStart.Time, Right.tpStart.Time);
          else
            Result := 0;
          end;
        end));

      for var i := 0 to Pred(FrameList.Count) do
      begin
        FrameList.Items[i].Parent := AContainer;
        FrameList.Items[i].Tag := i + 1;
        FrameList.Items[i].Top := FrameList.Items[i].Height * FrameList.Items[i].Tag;
      end;
    finally
      FrameList.Free;
    end;
  finally
    AContainer.UnlockDrawing;
  end;
end;

procedure TToggleController.Reset;
begin
  FProjects.List.Clear;
end;

constructor TToggleController.Create;
begin
  FConfigFile := GetAppFolder + '\config.json';
  FEntriesFile := GetAppFolder + '\entries.json';
  FJSonBody := GetAppFolder + '\body.json';
  FClient := THTTPClient.Create;
  FResponse := TStringList.Create;
  FResponse.OnChange := OnResponseChange;
  FBaseDate := 0;

  FUser := TTogglUser.Create(FClient, FResponse);
  FProjects := TTogglProjects.Create(FClient, FResponse);
  LoadConfig;
end;

destructor TToggleController.Destroy;
begin
  SaveConfig;
  FProjects.Free;
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

function TToggleController.GetAppFolder: string;
begin
  Result := IncludeTrailingPathDelimiter(TPath.GetHomePath) + TPath.GetFileNameWithoutExtension(Application.ExeName);

  if not TDirectory.Exists(Result) then
    TDirectory.CreateDirectory(Result);
end;

function TToggleController.GetTotalTimeSpan(AContainer: TScrollBox): TTimeSpan;
begin
  Result := TTimeSpan.Create(0);
  for var i := 0 to Pred(AContainer.ComponentCount) do
  begin
    if not (AContainer.Components[i] is TFrameEntry) then
      continue;

    var LEntry := (AContainer.Components[i] as TFrameEntry);

    if not LEntry.cbPush.Checked then
      continue;

    LEntry.UpdateElapsedTime;
    Result := Result.Add(LEntry.ElapsedTime);
  end;
end;

function TToggleController.GetValidEntries(AContainer: TScrollBox): Integer;
begin
  Result := 0;
  for var i := 0 to Pred(AContainer.ComponentCount) do
  begin
    if not (AContainer.Components[i] is TFrameEntry) then
      continue;

    var LEntry := (AContainer.Components[i] as TFrameEntry);

    if not LEntry.cbPush.Checked then
      continue;

    Inc(Result);
  end;
end;

procedure TToggleController.LoadConfig;
begin
  if not FileExists(FConfigFile) then
    Exit;

  var Stream := TStringStream.Create('', TEncoding.UTF8);
  try
    Stream.LoadFromFile(FConfigFile);

    var JConfig := TJSONObject.ParseJSONValue(Stream.DataString);
    try
      if JConfig.TryGetValue<string>('api_token', FApiToken) then
        SetClientHeaders;

      var AppStyle := EmptyStr;
      if JConfig.TryGetValue<string>('app_theme', AppStyle) then
      begin
        FStyleName := AppStyle;
        TStyleManager.TrySetStyle(AppStyle, False);
      end;

      var LCheck: Boolean;
      if JConfig.TryGetValue<Boolean>('check_for_updates', LCheck) then
        FDoVersionCheck := LCheck;

    finally
      JConfig.Free;
    end;
  finally
    Stream.Free;
  end;
end;

procedure TToggleController.NewEntry(AContainer: TScrollBox; ADefProjectIndex: Integer);
begin
  var Entry := TFrameEntry.Create(AContainer);
  Entry.Init(ADefProjectIndex);
  AContainer.VertScrollBar.Range := AContainer.VertScrollBar.Range + Entry.Height;
end;

procedure TToggleController.OnResponseChange(Sender: TObject);
begin
  if not (GetKeyState(VK_CONTROL) < 0) then
    Exit;

  TThread.Synchronize(nil,
  procedure
  begin
    var DataView := TfrmVisualizer.Create(nil);
    try
      DataView.mmData.Lines := FResponse;
      DataView.ShowModal;
    finally
      DataView.Free;
    end;
  end);
end;

procedure TToggleController.PushAllEntries(AContainer: TScrollBox; ADate: TDateTime);
begin
  FBaseDate := ADate;
  var JEntries := TJsonArray.Create;
  var JString := TStringStream.Create('', TEncoding.UTF8);
  try
    for var i := 0 to Pred(AContainer.ComponentCount) do
    begin
      var Entry := (AContainer.Components[i] as TFrameEntry);
      var JObj := TJSONObject.Create;

      if Trim(Entry.edtEntry.Text).IsEmpty then
      begin
        JObj.Free;
        Continue;
      end;

      Entry.MapToJSON(JObj);

      JString.Clear;
      JString.WriteString(JObj.Format(4));
      JString.SaveToFile(FJSonBody);

      JEntries.Add(JObj);

      if not Entry.cbPush.checked then
        continue;

      var HttpResponse := FClient.post('https://api.track.toggl.com/api/v9/workspaces/'+FUser.WorkspaceID.ToString+'/time_entries', FJSonBody);
      var SBuilder := TStringBuilder.Create;
      try
        SBuilder
          .AppendLine('== POST ENTRY ==')
          .AppendLine('> HTTP status code: ' + HttpResponse.StatusCode.ToString)
          .AppendLine('> JSON:');

        var JObjResponse := TJSONObject.ParseJSONValue(HttpResponse.ContentAsString);
        try
          SBuilder.AppendLine(JobjResponse.Format(4));
        finally
          JObjResponse.Free;
        end;

        FResponse.Text := SBuilder.ToString;
      finally
        Sbuilder.Free;
      end;
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
  var JConfig := TJSONObject.Create;
  try
    if not FApiToken.Trim.IsEmpty then
      JConfig.AddPair('api_token', FApiToken.Trim);

    JConfig.AddPair('app_theme', FStyleName);
    JConfig.AddPair('check_for_updates', TJSONBool.Create(FDoVersionCheck));

    var Stream := TStringStream.Create(JConfig.Format(2), TEncoding.UTF8);
    try
      Stream.SaveToFile(FConfigFile);
    finally
      Stream.Free;
    end;
  finally
    JConfig.Free;
  end;
end;

procedure TToggleController.SetDoVersionCheck(const AValue: Boolean);
begin
  if FDoVersionCheck = AValue then
    Exit;

  FDoVersionCheck := AValue;
  SaveConfig;
end;

procedure TToggleController.SetClientHeaders;
begin
  var AuthValue := ApiToken + ':api_token';
  var AuthHeader := 'Basic ' + TNetEncoding.Base64.Encode(AuthValue);
  FClient.CustomHeaders['Authorization'] := AuthHeader;
  FClient.CustomHeaders['Host'] := 'api.track.toggl.com';
  FClient.ContentType := 'application/json; charset=utf-8';
end;

procedure TToggleController.UpdateAllCbProj(AItemIndex: Integer; AContainer: TScrollBox);
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
