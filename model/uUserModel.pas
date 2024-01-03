unit uUserModel;

interface

uses
   System.Generics.Collections, System.JSON, REST.JSON, Datasnap.DBClient,
   uTools, System.SysUtils, uSystem.JSONUtil;

type
   TUserModel = class
   private
      FID: Integer;
      FUser: string;
      FDataCadastro: string;
      procedure SetID(const Value: Integer);
      procedure SetUser(const Value: string);
      procedure SetDataCadastro(const Value: string);

   public
      function Insert(AJSON: TJSONObject): TJSONValue;
      function Update(AId: string; AJSON: TJSONObject): TJSONValue;
      function Delete(AId: string): TJSONValue;
      function GetId(AAutoIncrementar: Integer): Integer;
      function Get(id, user, dataCadastro, numPagina: string): TJSONArray;
      property ID: Integer read FID write SetID;
      property User: string read FUser write SetUser;
      property DataCadastro: string read FDataCadastro write SetDataCadastro;
   end;

implementation

uses
   uUserDao;
{ TUserModel }

function TUserModel.Update(AId: string; AJSON: TJSONObject): TJSONValue;
var
   VUserDao: TUserDao;
   VUser: TUserModel;
begin
   if AJSON.ToJSON <> 'null' then
   begin
      VUser := TJson.JsonToObject<TUserModel>(AJSON);
      try
         VUserDao := TUserDao.Create;
         try
            Result := VUserDao.Update(AId, VUser);
         finally
            VUserDao.Free
         end;
      finally
         VUser.Free;
      end;
   end
   else
   begin
      result := creatDefaultResult(1, 'error', 'informar o body')
   end;
end;

function TUserModel.Delete(AId: string): TJSONValue;
var
   VUserDao: TUserDao;
begin
   VUserDao := TUserDao.Create;
   try
      Result := VUserDao.Delete(AId);
   finally
      VUserDao.Free
   end;
end;

function TUserModel.GetId(AAutoIncrementar: Integer): Integer;
var
   VUserDao: TUserDao;
begin
   VUserDao := TUserDao.Create;
   try
      Result := VUserDao.GetId(AAutoIncrementar);
   finally
      VUserDao.Free
   end;
end;

function TUserModel.Insert(AJSON: TJSONObject): TJSONValue;
var
   VUserDao: TUserDao;
   VUser: TUserModel;
begin
   if AJSON.ToJSON <> 'null' then
   begin
      VUser := TJson.JsonToObject<TUserModel>(AJSON);
      VUserDao := TUserDao.Create;
      try
         Result := VUserDao.Insert(VUser);
      finally
         VUserDao.Free;
         VUser.Free;
      end;
   end
   else
   begin
      result := creatDefaultResult(1, 'error', 'informar o body')
   end;
end;

function TUserModel.Get(id, user, dataCadastro, numPagina: string): TJSONArray;
var
   VUserDao: TUserDao;
   VLista: TObjectList<TUserModel>;
begin
   setLog('requisicoes', 'User', 'get', FormatDateTime('ddMMyyyyhhmmss', Now), 'Model1');
   VUserDao := TUserDao.Create;
   try
      setLog('requisicoes', 'User', 'get', FormatDateTime('ddMMyyyyhhmmss', Now), 'Model2');
      VLista := VUserDao.Get(id, user, dataCadastro, numPagina);
      try
         setLog('requisicoes', 'User', 'get', FormatDateTime('ddMMyyyyhhmmss', Now), 'Model3');
         Result := TJSONUtil.ObjetoListaParaJson<TUserModel>(VLista);
      finally
         if Assigned(VLista) then
            VLista.Free;
      end;
   finally
      if Assigned(VUserDao) then
         VUserDao.Free;
   end;
end;

procedure TUserModel.SetDataCadastro(const Value: string);
begin
   FDataCadastro := Value;
end;

procedure TUserModel.SetID(const Value: Integer);
begin
   FID := Value;
end;

procedure TUserModel.SetUser(const Value: string);
begin
   FUser := Value;
end;

end.

