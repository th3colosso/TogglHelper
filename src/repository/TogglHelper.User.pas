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
  try
    var Response := FClient.Get('https://api.track.toggl.com/api/v9/me');
    RetrieveResponseValues(Response);

    Result := Response.StatusCode = 200;
  except
    Result := False;
  end;
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

    var SBuilder := TStringBuilder.Create;
    try
      SBuilder
        .AppendLine('== == USER AUTH == ==')
        .AppendLine('> HTTP status code: ' + AResponse.StatusCode.ToString)
        .AppendLine('> JSON:')
        .AppendLine(Json.Format(4));

      FResponse.Text := SBuilder.ToString;
    finally
      Sbuilder.Free;
    end;
  finally
    Json.Free;
  end;
end;

end.
