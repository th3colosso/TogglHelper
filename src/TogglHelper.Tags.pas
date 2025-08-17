unit TogglHelper.Tags;

interface

uses
  System.Classes, System.Net.HttpClient, System.Generics.Collections;

type
  TTogglTags = class
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

{ TTogglTags }

constructor TTogglTags.Create(AClient: THTTPClient; AResponse: TStringList);
begin
  FList := TDictionary<string, Integer>.Create;
  FClient := AClient;
  FResponse := AResponse;
end;

destructor TTogglTags.Destroy;
begin
  FList.Free;
  inherited;
end;

procedure TTogglTags.RetrieveResponseValues(AResponse: IHTTPResponse);
begin
  var JArray := TJSONObject.ParseJSONValue(AResponse.ContentAsString) as TJsonArray;
  try
    for var i := 0 to Pred(JArray.Count) do
    begin
      var JObj := JArray.Items[i] as TJSONObject;

      var IsActive := True;
      var JValue := '';
      if JObj.TryGetValue<string>('deleted_at', JValue) then
        IsActive := not JValue.Trim.IsEmpty;

      var JName := '';
      var JId := 0;
      if IsActive and JObj.TryGetValue<string>('name', JName) and JObj.TryGetValue<Integer>('id', JId) then
        List.Add(JName, JId);
    end;

    var SBuilder := TStringBuilder.Create;
    try
      SBuilder
        .AppendLine('== GET TAGS ==')
        .AppendLine('> HTTP status code: ' + AResponse.StatusCode.ToString)
        .AppendLine('> JSON:')
        .AppendLine(JArray.Format(4));

      FResponse.Text := SBuilder.ToString;
    finally
      Sbuilder.Free;
    end;
  finally
    JArray.Free;
  end;
end;

procedure TTogglTags.UpdateList;
begin
  var Response := FClient.Get('https://api.track.toggl.com/api/v9/me/tags');
  RetrieveResponseValues(Response);
end;

end.
