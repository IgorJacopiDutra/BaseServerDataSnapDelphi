unit uUserControl;

interface

uses
   System.SysUtils, uUserModel, System.Classes,
{$IFDEF WIN32}
   Datasnap.DSServer, Datasnap.DSAuth,
{$ENDIF WIN32}
   System.JSON, uTools, Forms;

type
{$METHODINFO ON}
   TUserControl = class(TComponent)
   private
      FUserModel: TUserModel;
   public
      constructor Create(AOwner: TComponent); override;
      destructor Destroy; override;
      function User(AId: string): TJSONValue; // Get
      function acceptUser(AId: string; AJSON: TJSONObject): TJSONValue; // put
      function updateUser(AJSON: TJSONObject): TJSONValue; // post
      function cancelUser(AId: string): TJSONValue; // Delete
   end;
{$METHODINFO OFF}

implementation

uses
   Data.DBXPlatform;

{ TUserControl }

function TUserControl.acceptUser(AId: string; AJSON: TJSONObject): TJSONValue;
begin
   if AId = '' then
      result := creatDefaultResult(1, 'error', 'a rota esta incorreta')
   else
   begin
      result := FUserModel.Update(AId, AJSON);
   end;
end;

function TUserControl.cancelUser(AId: string): TJSONValue;
begin
   result := FUserModel.Delete(AId);
end;

constructor TUserControl.Create(AOwner: TComponent);
begin
   inherited Create(AOwner);

   FUserModel := TUserModel.Create;
end;

destructor TUserControl.Destroy;
begin
   FUserModel.Free;
   inherited;
end;

function TUserControl.User(AId: string): TJSONValue;
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

      setLog('requisicoes', 'user', 'get', FormatDateTime('ddMMyyyyhhmmss', Now), params.ToString);

      try
         jsonResult := TJSONObject.Create;
         try
            jsonResult.AddPair(TJSONPair.Create('user', FUserModel.Get(params.GetValue('ID', ''), params.GetValue('user', ''), params.GetValue('dataCadastro', ''), params.GetValue('numPagina', ''))));
         finally
            result := jsonResult;
         end;
      except
         on E: Exception do
         begin
            result := CreatDefaultResult(1, 'erro', E.Message);
            setLog('requisicoes', 'user', 'get', FormatDateTime('ddMMyyyyhhmmss', Now), 'JSON: ' + params.ToString + #13 + ' Message: ' + E.Message);
         end;
      end;
   finally
      params.Free;
   end;
end;

function TUserControl.updateUser(AJSON: TJSONObject): TJSONValue;
begin
   result := FUserModel.Insert(AJSON);
end;

end.

