unit TogglHelper.VersionControl;

interface

type
  TVersionControl = class
  private
    class function CompareToAppVersion(const AVersion: string): Boolean;
  public
    class function IsLastVersion: Boolean;
  end;

const
  LatestReleaseURL = 'https://api.github.com/repos/th3colosso/TogglHelper/releases/latest';

implementation

uses
  System.SysUtils,
  System.Net.HttpClient,
  System.Net.URLClient,
  System.JSON,
  Vcl.Forms,
  Winapi.Windows;

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
