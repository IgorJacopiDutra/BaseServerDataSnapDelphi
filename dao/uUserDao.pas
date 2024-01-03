unit uUserDao;

interface

uses
   uUserModel, System.Generics.Collections, FireDAC.Comp.Client, System.SysUtils,
   Datasnap.DBClient, System.JSON;

type
   TUserDao = class
   public
      function Get(id, user, dataCadastro, numPagina: string): TObjectList<TUserModel>; overload;
      function Insert(AModel: TUserModel): TJSONValue;
      function Update(AId: string; AModel: TUserModel): TJSONValue;
      function Delete(AId: string): TJSONValue;
      function GetId(AAutoIncrementar: Integer): Integer;
   end;

implementation

uses
   uConnectionDao, uTools;

const
   tableName = 'Users';
{ TUserDao }

function TUserDao.Update(AId: string; AModel: TUserModel): TJSONValue;
var
   VQry: TFDQuery;
   conn: TConnectionDao;
begin
   conn := TConnectionDao.Create;
   if conn.GetActive then
   begin
      VQry := conn.CriarQuery;
      try
         with VQry do
         begin
            Close;
            SQL.Clear;
            SQL.Add('UPDATE "' + tableName + '"');
            //SQL.Add('SET operador = :operador');
            //ParamByName('operador').AsString := 'SERVER';
            if isValidDateFormat(AModel.DataCadastro, 'yyyy-mm-dd') then
            begin
               SQL.Add('set dataCadastro = :dataCadastro');
               ParamByName('dataCadastro').AsDateTime := uTools.StrToDate(AModel.DataCadastro);
            end;

            if AModel.User <> '' then
            begin
               SQL.Add(', "USER" = :usera');
               ParamByName('usera').AsString := AModel.User;
            end;

            SQL.Add('WHERE id = :id');
            ParamByName('id').AsString := AId;

            try
               ExecSQL;
               conn.CommitBase;
               result := CreatDefaultResult(0, 'sucesso', 'atualizado. ' + IntToStr(RowsAffected) + ' registro(s) alterado(s)');
            except
               on E: Exception do
               begin
                  result := CreatDefaultResult(1, 'erro', E.message);
               end;
            end;
         end;
      finally
         conn.Free;
         VQry.Free;
      end;
   end
   else
   begin
      result := CreatDefaultResult(1, 'erro', conn.GetError);
   end;
end;

function TUserDao.Delete(AId: string): TJSONValue;
var
   VQry: TFDQuery;
   conn: TConnectionDao;
begin
   conn := TConnectionDao.Create;
   if conn.GetActive then
   begin
      VQry := conn.CriarQuery;
      try
         with VQry do
         begin
            Close;
            SQL.Clear;
            SQL.Add('DELETE FROM "' + tableName + '"');
            SQL.Add('WHERE id = :id');
            ParamByName('id').AsString := AId;
            try
               ExecSQL;
               conn.CommitBase;
               result := CreatDefaultResult(0, 'sucesso', 'deletado. ' + IntToStr(RowsAffected) + ' registro(s) deletado(s)');
            except
               on E: Exception do
               begin
                  result := CreatDefaultResult(1, 'erro', E.message);
               end;
            end;
         end;
      finally
         conn.Free;
         VQry.Free;
      end;
   end
   else
   begin
      result := CreatDefaultResult(1, 'erro', conn.GetError);
   end;
end;

function TUserDao.GetId(AAutoIncrementar: Integer): Integer;
var
   VQry: TFDQuery;
   conn: TConnectionDao;
   i: Integer;
begin
   if conn.GetActive then
   begin
      conn := TConnectionDao.Create;
      VQry := conn.CriarQuery;
      try
         VQry.Open('select gen_id(GEN_USERS, ' + IntToStr(AAutoIncrementar) + ' ) from rdb$database');
      finally
         conn.Free;
         VQry.Free;
      end;
   end;
end;

function TUserDao.Insert(AModel: TUserModel): TJSONValue;
var
   VQry: TFDQuery;
   conn: TConnectionDao;
   attempt: Integer;
begin
   conn := TConnectionDao.Create;
   if conn.GetActive then
   begin
      VQry := conn.CriarQuery;
      try
         while attempt < 3 do
         begin
            with VQry do
            begin
               Close;
               SQL.Clear;
               SQL.Add('INSERT INTO "' + tableName + '"');
               SQL.Add('(id, "USER", dataCadastro)');
               SQL.Add('values');
               SQL.Add('(:id, :usera, :dataCadastro)');

               ParamByName('id').AsInteger := GetId(1);
               ParamByName('usera').AsString := AModel.User;

               if isValidDateFormat(AModel.DataCadastro, 'yyyy-mm-dd') then
                  ParamByName('dataCadastro').AsDateTime := uTools.StrToDate(AModel.DataCadastro);

               try
                  VQry.ExecSQL;
                  conn.CommitBase;
                  result := CreatDefaultResult(0, 'sucesso', 'ID ' + ParamByName('id').AsString);
                  break;
               except
                  on E: Exception do
                  begin
                     result := CreatDefaultResult(1, 'erro', E.message);
                     inc(attempt);
                  end;
               end;
            end;
         end;
      finally
         conn.Free;
         VQry.Free;
      end;
   end
   else
   begin
      result := CreatDefaultResult(1, 'erro', conn.GetError);
   end;
end;

function TUserDao.Get(id, user, dataCadastro, numPagina: string): TObjectList<TUserModel>;
var
   VQry: TFDQuery;
   VLista: TObjectList<TUserModel>;
   VUser: TUserModel;
   conn: TConnectionDao;
begin
   conn := TConnectionDao.Create;
   VLista := TObjectList<TUserModel>.Create;
   if conn.GetActive then
   begin
      VQry := conn.CriarQuery;
      setLog('requisicoes', 'user', 'get', FormatDateTime('ddMMyyyyhhmmss', Now), 'Obter1');
      if numPagina = '' then
         numPagina := '0';

      try
         with VQry do
         begin
            Close;
            SQL.Clear;
            if conn.GetDriver = 'ORA' then
            begin
               SQL.Add('SELECT * FROM( ');
            end;
            SQL.Add('SELECT ');
            if conn.GetDriver = 'FB' then
            begin
               SQL.Add(' first 50 skip ' + numPagina);
            end
            else if conn.GetDriver = 'ORA' then
            begin
               SQL.Add(' ROW_NUMBER() OVER (ORDER BY ID) Row_Num,');
            end;

            SQL.Add('id, "USER", dataCadastro');
            SQL.Add('FROM "' + tableName + '"');

            SQL.Add('WHERE 1 = 1');

            if id <> '' then
               SQL.Add('AND ID = ' + QuotedStr(id));

            if user <> '' then
               SQL.Add('AND "USER" = ' + QuotedStr(user));

            SQL.Add('ORDER BY "USER"');

            if conn.GetDriver = 'ORA' then
            begin
               SQL.Add(') WHERE Row_Num BETWEEN ' + numPagina + ' and ' + IntToStr(StrToInt(numPagina) + 50));
            end;

            Open;
            setLog('requisicoes', 'user', 'get', FormatDateTime('ddMMyyyyhhmmss', Now), 'Obter2');

            if RecordCount > 0 then
            begin
               First;
               while not Eof do
               begin
                  VUser := TUserModel.Create;
                  VUser.id := FieldByName('id').AsInteger;
                  VUser.user := FieldByName('user').AsString;
                  VUser.dataCadastro := FormatDateTime('yyyy-mm-dd', FieldByName('dataCadastro').AsDateTime);

                  VLista.Add(VUser);
                  Next;
               end;
            end;
         end;
         setLog('requisicoes', 'user', 'get', FormatDateTime('ddMMyyyyhhmmss', Now), 'Obter3');
      finally
         if Assigned(conn) then
            conn.Free;
         if Assigned(VQry) then
            VQry.Free;
      end;
   end;
   Result := VLista;
end;

end.

