unit TogglHelper.VersionControl;

interface

type
  TVersionControl = class
  private
    FCurrentVersion: string;
    function GetLatestVersion: string;
  public
    procedure CheckAppVersion;
    property CurrentVersion: string read FCurrentVersion;
    property LatestVersion: string read GetLatestVersion;
  end;

implementation

{ TVersionControl }

procedure TVersionControl.CheckAppVersion;
begin

end;

function TVersionControl.GetLatestVersion: string;
begin

end;

end.
