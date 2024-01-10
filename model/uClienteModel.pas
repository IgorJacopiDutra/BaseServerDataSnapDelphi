unit uClienteModel;

interface

uses
   System.Generics.Collections, System.JSON, REST.JSON, Datasnap.DBClient,
   uTools, System.SysUtils, uSystem.JSONUtil;

type
   TClienteModel = class
   private
      FID: Integer;
      FCliente: string;
      FDataCadastro: string;
      procedure SetID(const Value: Integer);
      procedure SetCliente(const Value: string);
      procedure SetDataCadastro(const Value: string);

   public
      function Insert(AJSON: TJSONObject): TJSONValue;
      function Update(AId: string; AJSON: TJSONObject): TJSONValue;
      function Delete(AId: string): TJSONValue;
      function GetId(AAutoIncrementar: Integer): Integer;
      function Get(id, Cliente, dataCadastro, numPagina: string): TJSONArray;
      property ID: Integer read FID write SetID;
      property Cliente: string read FCliente write SetCliente;
      property DataCadastro: string read FDataCadastro write SetDataCadastro;
   end;

implementation

uses
   uClienteDao;
{ TClienteModel }

function TClienteModel.Update(AId: string; AJSON: TJSONObject): TJSONValue;
var
   VClienteDao: TClienteDao;
   VCliente: TClienteModel;
begin
   if AJSON.ToJSON <> 'null' then
   begin
      VCliente := TJson.JsonToObject<TClienteModel>(AJSON);
      try
         VClienteDao := TClienteDao.Create;
         try
            Result := VClienteDao.Update(AId, VCliente);
         finally
            VClienteDao.Free
         end;
      finally
         VCliente.Free;
      end;
   end
   else
   begin
      result := creatDefaultResult(1, 'error', 'informar o body')
   end;
end;

function TClienteModel.Delete(AId: string): TJSONValue;
var
   VClienteDao: TClienteDao;
begin
   VClienteDao := TClienteDao.Create;
   try
      Result := VClienteDao.Delete(AId);
   finally
      VClienteDao.Free
   end;
end;

function TClienteModel.GetId(AAutoIncrementar: Integer): Integer;
var
   VClienteDao: TClienteDao;
begin
   VClienteDao := TClienteDao.Create;
   try
      Result := VClienteDao.GetId(AAutoIncrementar);
   finally
      VClienteDao.Free
   end;
end;

function TClienteModel.Insert(AJSON: TJSONObject): TJSONValue;
var
   VClienteDao: TClienteDao;
   VCliente: TClienteModel;
begin
   if AJSON.ToJSON <> 'null' then
   begin
      VCliente := TJson.JsonToObject<TClienteModel>(AJSON);
      VClienteDao := TClienteDao.Create;
      try
         Result := VClienteDao.Insert(VCliente);
      finally
         VClienteDao.Free;
         VCliente.Free;
      end;
   end
   else
   begin
      result := creatDefaultResult(1, 'error', 'informar o body')
   end;
end;

function TClienteModel.Get(id, Cliente, dataCadastro, numPagina: string): TJSONArray;
var
   VClienteDao: TClienteDao;
   VLista: TObjectList<TClienteModel>;
begin
   setLog('requisicoes', 'Cliente', 'get', FormatDateTime('ddMMyyyyhhmmss', Now), 'Model1');
   VClienteDao := TClienteDao.Create;
   try
      setLog('requisicoes', 'Cliente', 'get', FormatDateTime('ddMMyyyyhhmmss', Now), 'Model2');
      VLista := VClienteDao.Get(id, Cliente, dataCadastro, numPagina);
      try
         setLog('requisicoes', 'Cliente', 'get', FormatDateTime('ddMMyyyyhhmmss', Now), 'Model3');
         Result := TJSONUtil.ObjetoListaParaJson<TClienteModel>(VLista);
      finally
         if Assigned(VLista) then
            VLista.Free;
      end;
   finally
      if Assigned(VClienteDao) then
         VClienteDao.Free;
   end;
end;

procedure TClienteModel.SetDataCadastro(const Value: string);
begin
   FDataCadastro := Value;
end;

procedure TClienteModel.SetID(const Value: Integer);
begin
   FID := Value;
end;

procedure TClienteModel.SetCliente(const Value: string);
begin
   FCliente := Value;
end;

end.

