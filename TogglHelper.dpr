program TogglHelper;

uses
  Vcl.Forms,
  TogglHelper.MainView in 'src\TogglHelper.MainView.pas' {frmMain},
  TogglHelper.User in 'src\TogglHelper.User.pas',
  TogglHelper.Controller in 'src\TogglHelper.Controller.pas',
  TogglHelper.Projects in 'src\TogglHelper.Projects.pas',
  TogglHelper.Tags in 'src\TogglHelper.Tags.pas',
  TogglHelper.FrameEntry in 'src\TogglHelper.FrameEntry.pas' {frameEntry: TFrame},
  TogglHelper.EntryAdapter in 'src\TogglHelper.EntryAdapter.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
