program TogglHelper;

uses
  Vcl.Forms,
  TogglHelper.MainView in 'TogglHelper.MainView.pas' {frmMain},
  TogglHelper.User in 'TogglHelper.User.pas',
  TogglHelper.Controller in 'TogglHelper.Controller.pas',
  TogglHelper.Projects in 'TogglHelper.Projects.pas',
  TogglHelper.Tags in 'TogglHelper.Tags.pas',
  TogglHelper.FrameEntry in 'TogglHelper.FrameEntry.pas' {frameEntry: TFrame};

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
