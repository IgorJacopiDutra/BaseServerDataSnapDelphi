program BaseServerDataSnapDelphi;
{$APPTYPE GUI}

{$R *.dres}

uses
  Vcl.Forms,
  Web.WebReq,
  IdHTTPWebBrokerBridge,
  frmPrincipal in 'view\frmPrincipal.pas' {frmStarter},
  uServerMethods in 'controller\uServerMethods.pas',
  uWebModule in 'model\uWebModule.pas' {WebModule1: TWebModule},
  uConnectionDao in 'dao\uConnectionDao.pas',
  uTools in 'model\uTools.pas',
  uLogger in 'model\uLogger.pas',
  uUserControl in 'controller\uUserControl.pas',
  uUserModel in 'model\uUserModel.pas',
  uUserDao in 'dao\uUserDao.pas',
  uSystem.JSONUtil in 'model\uSystem.JSONUtil.pas',
  uFileControl in 'controller\uFileControl.pas',
  uFileModel in 'model\uFileModel.pas',
  uFileDao in 'dao\uFileDao.pas',
  uClienteDao in 'dao\uClienteDao.pas',
  uClienteModel in 'model\uClienteModel.pas',
  uClienteControl in 'controller\uClienteControl.pas';

{$R *.res}

begin
  if WebRequestHandler <> nil then
    WebRequestHandler.WebModuleClass := WebModuleClass;
  Application.Initialize;
  Application.CreateForm(TfrmStarter, frmStarter);
  Application.Run;
end.
