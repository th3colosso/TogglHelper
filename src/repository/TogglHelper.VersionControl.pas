unit TogglHelper.VersionControl;

interface

type
  TVersionControl = class
  private
    class function CompareToAppVersion(const AVersion: string): Boolean;
  public
    class function IsLastVersion: Boolean;
    class var DownloadUrl: string;
  end;


implementation

uses
  System.SysUtils,
  System.Net.HttpClient,
  System.Net.URLClient,
  System.JSON,
  Vcl.Forms,
  Winapi.Windows,
  System.Generics.Collections;

const
  LatestReleaseURL = 'https://api.github.com/repos/th3colosso/TogglHelper/releases/latest';

{ TVersionControl }

class function TVersionControl.CompareToAppVersion(const AVersion: string): Boolean;
var
  Size, Handle: DWORD;
  Buffer: Pointer;
  FileInfo: PVSFixedFileInfo;
  Len: UINT;
begin
  Result := False;
  Size := GetFileVersionInfoSize(PChar(Application.ExeName), Handle);
  if Size = 0 then
    Exit;

  GetMem(Buffer, Size);
  try
    if GetFileVersionInfo(PChar(Application.ExeName), Handle, Size, Buffer) then
    begin
      if VerQueryValue(Buffer, '\', Pointer(FileInfo), Len) then
      begin
        var FormatedVersion := Format('v%d.%d.%d', [
          HiWord(FileInfo.dwFileVersionMS), // Major
          LoWord(FileInfo.dwFileVersionMS), // Minor
          HiWord(FileInfo.dwFileVersionLS)  // Release
        ]);

        Result := CompareStr(FormatedVersion, AVersion) >= 0;
      end;
    end;
  finally
    FreeMem(Buffer);
  end;
end;

class function TVersionControl.IsLastVersion;
begin
  try
    var Client := THTTPClient.Create;
    try
      var Response := Client.Get(LatestReleaseURL);
      if not Response.StatusCode = 200 then
        Exit(True);

      var Tag := EmptyStr;
      var JObj := TJSONObject.ParseJSONValue(Response.ContentAsString);
      try
        if not JObj.TryGetValue<string>('tag_name', Tag) then
          Exit(True);

        if Assigned(JObj.FindValue('assets')) then
        begin
          var LJArray := (JObj.FindValue('assets') as TJSONArray);
          if not LJArray[0].TryGetValue<string>('browser_download_url', DownloadUrl) then
            JObj.TryGetValue<string>('html_url', DownloadUrl);
        end;
      finally
        JObj.Free;
      end;

      Result := CompareToAppVersion(Tag);
    finally
      Client.Free;
    end;
  except
    Result := True;
  end;
end;

end.
