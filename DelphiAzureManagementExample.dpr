program DelphiAzureManagementExample;

uses
  System.StartUpCopy,
  FMX.Forms,
  Chronogears.Form.Main in 'Chronogears.Form.Main.pas' {MainForm},
  Chronogears.Azure.Model in 'Chronogears.Azure.Model.pas',
  Chronogears.Form.Authorize in 'Chronogears.Form.Authorize.pas' {AuthorizeForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TAuthorizeForm, AuthorizeForm);
  Application.Run;
end.
