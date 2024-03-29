unit frmPrincipal;

interface

uses
   Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
   Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.AppEvnts,
   Vcl.StdCtrls, IdHTTPWebBrokerBridge, Web.HTTPApp, FireDAC.Phys.ODBCDef,
   FireDAC.Phys.FBDef, FireDAC.Phys.MSSQLDef, FireDAC.Phys.MSSQL,
   FireDAC.Phys.IBBase, FireDAC.Phys.FB, FireDAC.Stan.Intf, FireDAC.Phys,
   FireDAC.Phys.ODBCBase, FireDAC.Phys.ODBC;

type
   TfrmStarter = class(TForm)
      ButtonStart: TButton;
      ButtonStop: TButton;
      EditPort: TEdit;
      Label1: TLabel;
      ApplicationEvents1: TApplicationEvents;
      ButtonOpenBrowser: TButton;
      FDPhysODBCDriverLink1: TFDPhysODBCDriverLink;
      FDPhysFBDriverLink1: TFDPhysFBDriverLink;
      FDPhysMSSQLDriverLink1: TFDPhysMSSQLDriverLink;
      procedure FormCreate(Sender: TObject);
      procedure ApplicationEvents1Idle(Sender: TObject; var Done: Boolean);
      procedure ButtonStartClick(Sender: TObject);
      procedure ButtonStopClick(Sender: TObject);
      procedure ButtonOpenBrowserClick(Sender: TObject);
   private
      FServer: TIdHTTPWebBrokerBridge;
      procedure StartServer;
    { Private declarations }
   public
    { Public declarations }
   end;

var
   frmStarter: TfrmStarter;

implementation

{$R *.dfm}

uses
   WinApi.Windows, Winapi.ShellApi, Datasnap.DSSession;

procedure TfrmStarter.ApplicationEvents1Idle(Sender: TObject; var Done: Boolean);
begin
   ButtonStart.Enabled := not FServer.Active;
   ButtonStop.Enabled := FServer.Active;
   EditPort.Enabled := not FServer.Active;
end;

procedure TfrmStarter.ButtonOpenBrowserClick(Sender: TObject);
var
   LURL: string;
begin
   StartServer;
   LURL := Format('http://localhost:%s', [EditPort.Text]);
   ShellExecute(0, nil, PChar(LURL), nil, nil, SW_SHOWNOACTIVATE);
end;

procedure TfrmStarter.ButtonStartClick(Sender: TObject);
begin
   StartServer;
end;

procedure TerminateThreads;
begin
   if TDSSessionManager.Instance <> nil then
      TDSSessionManager.Instance.TerminateAllSessions;
end;

procedure TfrmStarter.ButtonStopClick(Sender: TObject);
begin
   TerminateThreads;
   FServer.Active := False;
   FServer.Bindings.Clear;
end;

procedure TfrmStarter.FormCreate(Sender: TObject);
begin
   FServer := TIdHTTPWebBrokerBridge.Create(Self);
end;

procedure TfrmStarter.StartServer;
begin

   if not FServer.Active then
   begin
      FServer.Bindings.Clear;
      FServer.DefaultPort := StrToInt(EditPort.Text);
      FServer.Active := True;
   end;
end;

end.

