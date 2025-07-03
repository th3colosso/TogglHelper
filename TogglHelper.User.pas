unit TogglHelper.User;

interface

uses
  System.Classes, System.Net.HttpClient;

type
  TTogglUser = class
  private
    FName: string;
    FEmail: string;
    FWorkspaceID: Integer;
    FClient: THTTPClient;
    FResponse: TStringList;
    FID: Integer;
    procedure RetrieveResponseValues(AResponse: IHTTPResponse);
  public
    constructor Create(AClient: THTTPClient; AResponse: TStringList);
    function Authenticate: Boolean;
    property Name: string read FName;
    property Email: string read FEmail;
    property WorkspaceID: Integer read FWorkspaceID;
    property ID: Integer read FID;
  end;

implementation

uses
  System.Net.URLClient, System.NetEncoding, System.JSON, System.SysUtils;

{ TTogglUser }

function TTogglUser.Authenticate: Boolean;
begin
  var Response := FClient.Get('https://api.track.toggl.com/api/v9/me');
  RetrieveResponseValues(Response);

  Result := Response.StatusCode = 200;
end;

constructor TTogglUser.Create(AClient: THTTPClient; AResponse: TStringList);
begin
  FResponse := AResponse;
  FClient := AClient;
end;

procedure TTogglUser.RetrieveResponseValues(AResponse: IHTTPResponse);
begin
  var Json :=  TJSONObject.ParseJSONValue(AResponse.ContentAsString);
  try
    Json.TryGetValue<string>('fullname', FName);
    Json.TryGetValue<string>('email', FEmail);
    Json.TryGetValue<Integer>('default_workspace_id', FWorkspaceID);
    Json.TryGetValue<Integer>('id', FID);

    FResponse.Clear;
    FResponse.Add('');
    FResponse.Add('== USER AUTH ==');
    FResponse.Add('> HTTP status code: ' + AResponse.StatusCode.ToString);
    FResponse.Add('> JSON: ');
    FResponse.Add(Json.Format(4));
  finally
    Json.Free;
  end;
end;

end.
