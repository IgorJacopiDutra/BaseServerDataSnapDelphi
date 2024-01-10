unit uClienteControl;

interface

uses
   System.SysUtils, uClienteModel, System.Classes,
{$IFDEF WIN32}
   Datasnap.DSServer, Datasnap.DSAuth,
{$ENDIF WIN32}
   System.JSON, uTools, Forms;

type
{$METHODINFO ON}
   TClienteControl = class(TComponent)
   private
      FClienteModel: TClienteModel;
   public
      constructor Create(AOwner: TComponent); override;
      destructor Destroy; override;
      function Cliente(AId: string): TJSONValue; // Get
      function acceptCliente(AId: string; AJSON: TJSONObject): TJSONValue; // put
      function updateCliente(AJSON: TJSONObject): TJSONValue; // post
      function cancelCliente(AId: string): TJSONValue; // Delete
   end;
{$METHODINFO OFF}

implementation

uses
   Data.DBXPlatform;

{ TClienteControl }

function TClienteControl.acceptCliente(AId: string; AJSON: TJSONObject): TJSONValue;
begin
   if AId = '' then
      result := creatDefaultResult(1, 'error', 'a rota esta incorreta')
   else
   begin
      result := FClienteModel.Update(AId, AJSON);
   end;
end;

function TClienteControl.cancelCliente(AId: string): TJSONValue;
begin
   result := FClienteModel.Delete(AId);
end;

constructor TClienteControl.Create(AOwner: TComponent);
begin
   inherited Create(AOwner);

   FClienteModel := TClienteModel.Create;
end;

destructor TClienteControl.Destroy;
begin
   FClienteModel.Free;
   inherited;
end;

function TClienteControl.Cliente(AId: string): TJSONValue;
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

      setLog('requisicoes', 'Cliente', 'get', FormatDateTime('ddMMyyyyhhmmss', Now), params.ToString);

      try
         jsonResult := TJSONObject.Create;
         try
            jsonResult.AddPair(TJSONPair.Create('Cliente', FClienteModel.Get(params.GetValue('ID', ''), params.GetValue('Cliente', ''), params.GetValue('dataCadastro', ''), params.GetValue('numPagina', ''))));
         finally
            result := jsonResult;
         end;
      except
         on E: Exception do
         begin
            result := CreatDefaultResult(1, 'erro', E.Message);
            setLog('requisicoes', 'Cliente', 'get', FormatDateTime('ddMMyyyyhhmmss', Now), 'JSON: ' + params.ToString + #13 + ' Message: ' + E.Message);
         end;
      end;
   finally
      params.Free;
   end;
end;

function TClienteControl.updateCliente(AJSON: TJSONObject): TJSONValue;
begin
   result := FClienteModel.Insert(AJSON);
end;

end.

