program TogglHelper;

uses
  Vcl.Forms,
  TogglHelper.MainView in 'src\view\TogglHelper.MainView.pas' {frmMain},
  TogglHelper.User in 'src\repository\TogglHelper.User.pas',
  TogglHelper.Controller in 'src\controller\TogglHelper.Controller.pas',
  TogglHelper.Projects in 'src\repository\TogglHelper.Projects.pas',
  TogglHelper.Tags in 'src\repository\TogglHelper.Tags.pas',
  TogglHelper.FrameEntry in 'src\view\TogglHelper.FrameEntry.pas' {FrameEntry: TFrame},
  TogglHelper.EntryHelper in 'src\utils\TogglHelper.EntryHelper.pas',
  Vcl.Themes,
  Vcl.Styles,
  TogglHelper.DataVisualizer in 'src\view\TogglHelper.DataVisualizer.pas' {frmVisualizer},
  TogglHelper.VersionControl in 'src\repository\TogglHelper.VersionControl.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
