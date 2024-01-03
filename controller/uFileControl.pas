unit uFileControl;

interface

uses
   System.SysUtils, uFileModel, System.Classes,
{$IFDEF WIN32}
   Datasnap.DSServer, Datasnap.DSAuth,
{$ENDIF WIN32}
   System.JSON, uTools;

type
{$METHODINFO ON}
   TFileControl = class(TComponent)
   private
      FFileModel: TFileModel;
   public
      constructor Create(AOwner: TComponent); override;
      destructor Destroy; override;
      function File_(): TJSONValue; // Get
      function Files(): TJSONValue; // Get
      function acceptFile(AId: string; AJSON: TJSONObject): TJSONValue; // put
      function updateFile(AJSON: TJSONObject): TJSONValue; // post
      function cancelFile(AId: string): TJSONValue; // Delete
   end;
{$METHODINFO OFF}

implementation

uses
   Data.DBXPlatform;

{ TFileControl }

function TFileControl.acceptFile(AId: string; AJSON: TJSONObject): TJSONValue;
begin
   if AId = '' then
      result := creatDefaultResult(1, 'error', 'a rota esta incorreta')
   else
   begin
      result := FFileModel.Update(AId, AJSON);
   end;
end;

function TFileControl.cancelFile(AId: string): TJSONValue;
begin
   result := FFileModel.Excluir(AId);
end;

constructor TFileControl.Create(AOwner: TComponent);
begin
   inherited Create(AOwner);

   FFileModel := TFileModel.Create;
end;

destructor TFileControl.Destroy;
begin
   FFileModel.Free;
   inherited;
end;

function TFileControl.File_: TJSONValue;
var
   jsonResult: TJSONObject;
   metaData: TDSInvocationMetadata;
   iPaginasTotal, iPaginaAtual: Integer;
   sJSON: string;
   path, name: string;
   i: Integer;
begin
   sJSON := '';

   metaData := GetInvocationMetadata;
   for i := 0 to Pred(metaData.QueryParams.Count) do
   begin
      sJSON := sJSON + getData(metaData.QueryParams[i]) + '=' + getData(metaData.QueryParams[i]);
      if (getField(metaData.QueryParams[i]) = 'path') then
         path := getData(metaData.QueryParams[i]);
      if (getField(metaData.QueryParams[i]) = 'name') then
         name := getData(metaData.QueryParams[i]);
   end;

   setLog('requisicoes', 'File', 'get', FormatDateTime('ddMMyyyyhhmmss', Now), sJSON);

   try
      jsonResult := TJSONObject.Create;
      try
         jsonResult.AddPair(TJSONPair.Create('File', FFileModel.Obter(path, name)));
      finally
         result := jsonResult;
      end;
   except
      on E: Exception do
      begin
         result := CreatDefaultResult(1, 'erro', E.Message);
         setLog('requisicoes', 'File', 'get', FormatDateTime('ddMMyyyyhhmmss', Now), 'JSON: ' + sJSON + #13 + ' Message: ' + E.Message);
      end;
   end;
end;

function TFileControl.Files(): TJSONValue;
var
   jsonResult: TJSONObject;
   metaData: TDSInvocationMetadata;
   params: TJSONObject;
   i: Integer;
begin
   params := TJSONObject.Create;
   try
      metaData := GetInvocationMetadata;

      with metaData do
      begin
         for i := 0 to Pred(QueryParams.Count) do
         begin
            params.AddPair(getField(QueryParams[i]), getData(QueryParams[i]));
         end;
      end;

      setLog('requisicoes', '', 'get', FormatDateTime('ddMMyyyyhhmmss', Now), params.ToString);

      try
         jsonResult := TJSONObject.Create;
         try
            jsonResult.AddPair(TJSONPair.Create('Files', FFileModel.Listagem()));
         finally
            result := jsonResult;
         end;
      except
         on E: Exception do
         begin
            result := CreatDefaultResult(1, 'erro', E.Message);
            setLog('requisicoes', 'files', 'get', FormatDateTime('ddMMyyyyhhmmss', Now), 'JSON: ' + params.ToString + #13 + ' Message: ' + E.Message);
         end;
      end;
   finally
      params.Free;
   end;
end;

function TFileControl.updateFile(AJSON: TJSONObject): TJSONValue;
begin
   setLog('requisicoes', 'File', 'post', FormatDateTime('ddMMyyyyhhmmss', Now), AJSON.ToString);
   result := FFileModel.Incluir(AJSON);
end;

end.

