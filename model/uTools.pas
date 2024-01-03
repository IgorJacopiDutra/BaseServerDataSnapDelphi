unit uTools;

interface

uses
   System.Classes, System.JSON, Datasnap.DBClient, Data.DBXPlatform,
   System.Generics.Collections, FireDAC.Comp.Client, MidasLib, Math,
   System.SysUtils, uLogger;

function getData(datas: string): string;

function getField(datas: string): string;

procedure setLog(folder, resource, action, Data, payload: string);

function creatDefaultResult(code: Integer; messages, detalhe: string): TJSONObject; overload;

function isValidDateFormat(const dateString, dateFormat: string): Boolean;

function StrToDate(const DateStr: string): TDateTime;

implementation

uses
   Vcl.SvcMgr, System.IOUtils, Winapi.Windows, Data.DB, uConnectionDao;

procedure setLog(folder, resource, action, Data, payload: string);
begin
   uLogger.GravarLog(folder, resource, action, payload);
end;

function getField(datas: string): string;
begin
   result := Copy(datas, 1, pos('=', datas) - 1);
end;

function getData(datas: string): string;
begin
   result := Copy(datas, pos('=', datas) + 1, length(datas) - 1);
end;

function creatDefaultResult(code: Integer; messages, detalhe: string): TJSONObject;
var
   jsonResult, jsonResultInformation: TJSONObject;
begin
   jsonResultInformation := TJSONObject.Create;
   jsonResultInformation.AddPair(TJSONPair.Create('code', TJSONNumber.Create(code)));
   jsonResultInformation.AddPair(TJSONPair.Create('message', TJSONString.Create(messages)));
   jsonResultInformation.AddPair(TJSONPair.Create('detalhe', TJSONString.Create(detalhe)));
   jsonResult := TJSONObject.Create;
   jsonResult.AddPair(TJSONPair.Create('result', jsonResultInformation));
   result := jsonResult;
end;

function isValidDateFormat(const dateString, dateFormat: string): Boolean;
var
  dt: TDateTime;
  formatSettings: TFormatSettings;
  cleanDateString: string;
begin
  cleanDateString := StringReplace(dateString, '''', '', [rfReplaceAll]);

  formatSettings.ShortDateFormat := dateFormat;
  formatSettings.DateSeparator := '-';
  formatSettings.ShortTimeFormat := '';

  Result := TryStrToDateTime(cleanDateString, dt, formatSettings);
end;

function StrToDate(const DateStr: string): TDateTime;
var
   Year, Month, Day: Word;
begin
  // Tenta extrair o ano, m�s e dia da string
   try
      Year := StrToIntDef(Copy(DateStr, 1, 4), 0);
      Month := StrToIntDef(Copy(DateStr, 6, 2), 0);
      Day := StrToIntDef(Copy(DateStr, 9, 2), 0);

    // Verifica se os valores s�o v�lidos
      if (Year > 0) and (Month >= 1) and (Month <= 12) and (Day >= 1) and (Day <= 31) then
      begin
      // Constr�i um objeto TDateTime
         Result := EncodeDate(Year, Month, Day);
      end
      else
      begin
      // Tratamento de erro se os valores n�o forem v�lidos
         raise Exception.Create('Erro: Formato de data inv�lido');
      end;
   except
    // Tratamento de erro se a convers�o falhar
      raise Exception.Create('Erro: Formato de data inv�lido');
   end;
end;

end.

