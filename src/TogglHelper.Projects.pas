unit TogglHelper.Projects;

interface

uses
  System.Classes, System.Net.HttpClient, System.Generics.Collections;

type
  TTogglProjects = class
  private
    FList: TDictionary<string, Integer>;
    FApiToken: string;
    FClient: THTTPClient;
    FResponse: TStringList;
    procedure RetrieveResponseValues(AResponse: IHTTPResponse);
  public
    constructor Create(AClient: THTTPClient; AResponse: TStringList);
    destructor Destroy; override;
    property List: TDictionary<string, Integer> read FList write FList;
    property ApiToken: string read FApiToken write FApiToken;
    procedure UpdateList;
  end;

implementation

uses
  System.JSON, System.SysUtils;

{ TTogglProjects }

constructor TTogglProjects.Create(AClient: THTTPClient; AResponse: TStringList);
begin
  FList := TDictionary<string, Integer>.Create;
  FClient := AClient;
  FResponse := AResponse;
end;

destructor TTogglProjects.Destroy;
begin
  FList.Free;
  inherited;
end;

procedure TTogglProjects.RetrieveResponseValues(AResponse: IHTTPResponse);
begin
  var JArray := TJSONObject.ParseJSONValue(AResponse.ContentAsString) as TJsonArray;
  try  
    for var i := 0 to Pred(JArray.Count) do
    begin
      var JObj := JArray.Items[i] as TJSONObject;

      var IsActive := False;
      var JValue := '';
      if JObj.TryGetValue<string>('status', JValue) then
        IsActive := JValue = 'active';

      var JName := '';
      var JId := 0;
      if IsActive and JObj.TryGetValue<string>('name', JName) and JObj.TryGetValue<Integer>('id', JId) then
        List.Add(JName, JId);

      FResponse.Clear;
      FResponse.Add('');
      FResponse.Add('== GET PROJECTS ==');
      FResponse.Add('> HTTP status code: ' + AResponse.StatusCode.ToString);
      FResponse.Add('> JSON: ');
      FResponse.Add(JArray.Format(4));
    end;
  finally
    JArray.Free;
  end;
end;

procedure TTogglProjects.UpdateList;
begin
  var Response := FClient.Get('https://api.track.toggl.com/api/v9/me/projects');
  RetrieveResponseValues(Response);
end;

end.
