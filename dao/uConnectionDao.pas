unit uConnectionDao;

interface

uses
   FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
   Vcl.Dialogs, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
   FireDAC.Stan.Async, FireDAC.Phys, Data.DB, FireDAC.Comp.Client,
   FireDAC.Phys.MySQLDef, FireDAC.Phys.FB, System.SysUtils, FireDAC.DApt,
   FireDAC.VCLUI.Wait, FireDAC.Phys.MSSQLDef, FireDAC.Phys.OracleDef,
   FireDAC.Phys.Oracle, uTools, Winapi.Windows;

type
   TConnectionDao = class
   private
      FConn: TFDConnection;
      FDPhysOracleDriverLink1: TFDPhysOracleDriverLink;
      FDPhysFBDriverLink1: TFDPhysFBDriverLink;
      FActive: Boolean;
      FError: string;
      procedure ConfigurarConnectionDao(sTipo: string);
      function getParamsConnectionByArq(sDir, sArq, sExt: string): string;
      function getParam(str: string): string;
      function getValue(str: string): string;
      function getParamByArq(sParam, sDir, sArq, sExt: string; bCript: Boolean): string;
   public
      constructor Create; overload;
      constructor Create(sTipo: string); overload;
      destructor Destroy; override;
      function GetDriver: string;
      function GetActive: boolean;
      function GetError: string;
      function GetConn: TFDConnection;
      function CriarQuery: TFDQuery;
      procedure CommitBase;
   published
      property Active: Boolean read FActive write FActive;
      property Error: string read FError write FError;
   end;

const
   FILEDB: string = 'ConfigDB.ini';

var
   ListaBancos: array of string;

implementation

uses
   System.Classes;

{ TConnectionDao }

function TConnectionDao.getParam(str: string): string;
begin
   Result := copy(str, 1, pos('=', str) - 1);
end;

function TConnectionDao.getValue(str: string): string;
begin
   Result := copy(str, pos('=', str) + 1, Length(str));
end;

function TConnectionDao.getParamsConnectionByArq(sDir, sArq, sExt: string): string;
var
   config: TStringList;
   i: Integer;
const
   paramsConnection = 'Database;User_Name;Password;DriverID;Port;Server;';
   paramsCript = paramsConnection;
begin
   try
      config := TStringList.Create;
      config.LoadFromFile(sDir + sArq + '.' + sExt);
      try
         for i := 0 to (config.Count - 1) do
         begin
            if (pos(UpperCase(getParam(config.Strings[i])), UpperCase(paramsCript)) > 0) then
               config.Strings[i] := getParam(config.Strings[i]) + '=' + getValue(config.Strings[i]);

            Result := config.text;
         end;
      finally
         config.Free;
      end;
   except
      on E: Exception do
      begin

      end;
   end;
end;

function TConnectionDao.getParamByArq(sParam, sDir, sArq, sExt: string; bCript: Boolean): string;
var
   i: Integer;
   config: TStringList;
begin
   config := TStringList.Create;
   try
      config.LoadFromFile(sDir + sArq + '.' + sExt);
      for i := 0 to (config.Count - 1) do
      begin
         if (UpperCase(getParam(config.Strings[i])) = UpperCase(sParam)) then
            getParamByArq := getValue(config.Strings[i]);
      end;
   finally
      config.Free;
   end;
end;

procedure TConnectionDao.ConfigurarConnectionDao(sTipo: string);
begin
   try
      FConn.Connected := false;
      FConn.Params.Clear;

      FConn.Params.Text := getParamsConnectionByArq('', 'ConfigDB', 'ini');
      FConn.DriverName := getParamByArq('DriverID', '', 'ConfigDB', 'ini', true);

      FDPhysFBDriverLink1 := TFDPhysFBDriverLink.Create(nil);

      if not (UpperCase(FConn.DriverName) = 'FB') then
      begin
         FConn.FormatOptions.MapRules.Add;
         FConn.FormatOptions.MapRules[FConn.FormatOptions.MapRules.Count - 1].SourceDataType := dtFmtBCD;
         FConn.FormatOptions.MapRules[FConn.FormatOptions.MapRules.Count - 1].TargetDataType := dtInt32;
         FConn.FormatOptions.MapRules.Add;
         FConn.FormatOptions.MapRules[FConn.FormatOptions.MapRules.Count - 1].SourceDataType := dtDateTimeStamp;
         FConn.FormatOptions.MapRules[FConn.FormatOptions.MapRules.Count - 1].TargetDataType := dtDateTime;
      end;

      try

         FConn.Connected := true;
         active := true;
      except
         on E: Exception do
         begin
            Error := e.Message;
            setLog('requisicoes', 'connection', 'get', FormatDateTime('ddMMyyyyhhmmss', Now), E.Message);
         end;
      end;
   except
      on E: Exception do
      begin
         Error := e.Message;
         setLog('requisicoes', 'connection', 'get', FormatDateTime('ddMMyyyyhhmmss', Now), E.Message);
      end;
   end;

end;

constructor TConnectionDao.Create;
begin
   active := false;
   Error := '';
   Create('app');
end;

constructor TConnectionDao.Create(sTipo: string);
begin

   try
      FConn := TFDConnection.Create(nil);
   except
      on E: Exception do
      begin
         setLog('requisicoes', 'connection', 'get', FormatDateTime('ddMMyyyyhhmmss', Now), E.Message);
      end;
   end;
   Self.ConfigurarConnectionDao(sTipo);
end;

function TConnectionDao.CriarQuery: TFDQuery;
var
   VQuery: TFDQuery;
begin
   VQuery := TFDQuery.Create(nil);
   VQuery.Connection := FConn;

   Result := VQuery;
end;

destructor TConnectionDao.Destroy;
begin
   FConn.Free;
   FDPhysOracleDriverLink1.Free;
   FDPhysFBDriverLink1.Free;
   inherited;
end;

function TConnectionDao.GetError: string;
begin
   result := Error;
end;

function TConnectionDao.GetActive: boolean;
begin
   result := Active;
end;

function TConnectionDao.GetConn: TFDConnection;
begin
   Result := FConn;
end;

function TConnectionDao.GetDriver: string;
begin
   Result := UpperCase(FConn.DriverName);
end;

procedure TConnectionDao.CommitBase;
begin
   FConn.Commit;
end;

end.

