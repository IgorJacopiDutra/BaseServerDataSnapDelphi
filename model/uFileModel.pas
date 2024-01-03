unit uFileModel;

interface

uses
   System.Generics.Collections, System.JSON, REST.JSON, Datasnap.DBClient,
   uTools, NetEncoding, System.Classes;

type
   TFileModel = class
   private
      FName: string;
      FPath: string;
      FDataModificacao: string;
      FFileConvert: WideString;
      FSize: string;
      procedure SetPath(const Value: string);
      procedure SetDataModificacao(const Value: string);
      procedure SetFileConvert(const Value: WideString);
      procedure SetName(const Value: string);
      procedure SetSize(const Value: string);

   public
      function Incluir(AJSON: TJSONObject): TJSONValue;
      function Update(AId: string; AJSON: TJSONObject): TJSONValue;
      function UploadFile(AJSON: TJSONObject): TJSONValue;
      function Excluir(AId: string): TJSONValue;
      function GetId(AAutoIncrementar: Integer): Integer;
      function Obter(path, name: string): TJSONObject; overload;
      function Listagem(): TJSONArray; overload;
      property Name: string read FName write SetName;
      property FileConvert: WideString read FFileConvert write SetFileConvert;
      property Size: string read FSize write SetSize;
      property DataModificacao: string read FDataModificacao write SetDataModificacao;
      property Path: string read FPath write SetPath;
   end;

implementation

uses
   uFileDao, uSystem.JSONUtil, System.SysUtils;
{ TFileModel }

function ImageToBase64(const imagePath: string): string;
var
   imageStream: TMemoryStream;
   base64Encoder: TBase64Encoding;
begin
   imageStream := TMemoryStream.Create;
   try
      imageStream.LoadFromFile(imagePath);
      base64Encoder := TBase64Encoding.Create;
      try
         Result := base64Encoder.EncodeBytesToString(imageStream.Memory, imageStream.Size);
      finally
         base64Encoder.Free;
      end;
   finally
      imageStream.Free;
   end;
end;

function TFileModel.Update(AId: string; AJSON: TJSONObject): TJSONValue;
var
   VFileDao: TFileDao;
   VFile: TFileModel;
begin
   VFile := TJson.JsonToObject<TFileModel>(AJSON);
   try
      VFileDao := TFileDao.Create;
      try
         result := VFileDao.Update(AId, VFile);
      finally
         VFileDao.Free
      end;

   finally
      if Assigned(VFile) then
         VFile.Free;
   end;
end;

function TFileModel.Excluir(AId: string): TJSONValue;
begin

end;

function TFileModel.GetId(AAutoIncrementar: Integer): Integer;
begin

end;

function TFileModel.Incluir(AJSON: TJSONObject): TJSONValue;
var
   VFileDao: TFileDao;
   VFile: TFileModel;
   i: Integer;
   JFirstPair: TJSONPair;
   jsonObject: TJSONObject;
begin
   VFileDao := TFileDao.Create;
   try
      for i := 0 to AJSON.Size - 1 do
      begin
         JFirstPair := AJSON.Get(i);
         if JFirstPair.JsonString.Value = 'File' then
         begin
            jsonObject := AJSON.Get(i).jsonValue as TJsonObject;
            VFile := TJson.JsonToObject<TFileModel>(jsonObject);

         end;
         VFile.Free;
      end;
   finally
      VFileDao.Free;
   end;
end;

function TFileModel.Obter(path, name: string): TJSONObject;
var
   VLista: TObjectList<TFileModel>;
   VFile: TFileModel;
   searchResult: TSearchRec;
   arquivo: string;
   pathComplete: string;
   VFileDao: TFileDao;
   bytt: TBytes;
   Base64String: string;

   function FileToBytes(const FilePath: string): TBytes;
   var
      FileStream: TFileStream;
      BytesStream: TBytesStream;
   begin
      FileStream := TFileStream.Create(FilePath, fmOpenRead or fmShareDenyNone);
      try
         BytesStream := TBytesStream.Create;
         try
            BytesStream.CopyFrom(FileStream, 0);
            Result := BytesStream.Bytes;
         finally
            BytesStream.Free;
         end;
      finally
         FileStream.Free;
      end;
   end;

begin
   pathComplete := '';

   VFile := TFileModel.Create;
   try
      if FindFirst(pathComplete + '\*', faAnyFile, searchResult) = 0 then
      begin
         try
            repeat
               if (searchResult.Name <> '.') and (searchResult.Name <> '..') and (VFile.Name = searchResult.Name) then
               begin

                  arquivo := pathComplete + searchResult.Name;
                  VFile.Name := searchResult.Name;
                  VFile.DataModificacao := FormatDateTime('dd/MM/yyyy', FileDateToDateTime(searchResult.Time));
                  VFile.Size := IntToStr(searchResult.Size);

                  bytt := FileToBytes(arquivo);
                  Base64String := TNetEncoding.Base64.EncodeBytesToString(bytt);

                  VFile.FileConvert := Base64String;
                  VFile.path := pathComplete;

               end;
            until FindNext(searchResult) <> 0;
         finally
            FindClose(searchResult);
         end;
      end;
      result := TJson.ObjectToJsonObject(VFile);
   finally
      VFile.Free;
   end;
end;

function TFileModel.Listagem(): TJSONArray;
var
   VLista: TObjectList<TFileModel>;
   VFile: TFileModel;
   searchResult: TSearchRec;
   arquivo: string;
   pasta: string;
   VFileDao: TFileDao;
begin
   VFileDao := TFileDao.Create;
   try
      pasta := 'C:\Temp\arquivo\original\';
   finally
      VFileDao.Free
   end;

   VLista := TObjectList<TFileModel>.Create;
   try
      if FindFirst(pasta + '\*', faAnyFile, searchResult) = 0 then
      begin
         try
            repeat
               if (searchResult.Name <> '.') and (searchResult.Name <> '..') and (copy(searchResult.Name, 1, 10) <> 'assinatura') then
               begin
                  VFile := TFileModel.Create;
                  arquivo := pasta + '\';
                  VFile.Name := searchResult.Name;
                  VFile.DataModificacao := FormatDateTime('dd/MM/yyyy', FileDateToDateTime(searchResult.Time));
                  VFile.Size := IntToStr(searchResult.Size);
                  VFile.FileConvert := '';
                  VFile.path := arquivo;
                  VLista.Add(VFile);

               end;
            until FindNext(searchResult) <> 0;
         finally
            FindClose(searchResult);
         end;
      end;
      result := TJSONUtil.ObjetoListaParaJson<TFileModel>(VLista);
   finally
      FreeAndNil(VLista);
   end;
end;

procedure TFileModel.SetName(const Value: string);
begin
   FName := Value;
end;

procedure TFileModel.SetPath(const Value: string);
begin
   FPath := Value;
end;

procedure TFileModel.SetDataModificacao(const Value: string);
begin
   FDataModificacao := Value;
end;

procedure TFileModel.SetFileConvert(const Value: WideString);
begin
   FFileConvert := Value;
end;

procedure TFileModel.SetSize(const Value: string);
begin
   FSize := Value;
end;

function TFileModel.UploadFile(AJSON: TJSONObject): TJSONValue;
var
   VFile: TFileModel;
   lInStream: TStringStream;
   lOutStream: TMemoryStream;
   folder: string;
   VFileDao: TFileDao;
   bytt: TBytes;

   function BytesToFile(const Bytes: TBytes; const FilePath: string): Boolean;
   var
      FileStream: TFileStream;
   begin
      Result := False;

      if Length(Bytes) = 0 then
         Exit;

      FileStream := TFileStream.Create(FilePath, fmCreate);
      try
         FileStream.WriteBuffer(Bytes[0], Length(Bytes));
         Result := True;
      finally
         FileStream.Free;
      end;
   end;

begin
   try
      VFileDao := TFileDao.Create;

      folder := 'C:\Temp\arquivo\original\';

      VFile := TJson.JsonToObject<TFileModel>(AJSON);
      try
         if not (VFile.FFileConvert = '') then
         begin
            bytt := TNetEncoding.Base64.DecodeStringToBytes(VFile.FFileConvert);

            if not Directoryexists(folder) then
               CreateDir(folder);

            if BytesToFile(bytt, folder + VFile.FName) then
               result := CreatDefaultResult(0, 'sucesso', '')
            else
               result := CreatDefaultResult(1, 'erro', '');
         end
         else
            result := CreatDefaultResult(0, 'erro', 'Campo "Nom_imgconvertida" vazio.');
      finally
         VFile.Free
      end;
   except
      on E: Exception do
      begin
         result := CreatDefaultResult(0, 'erro', e.Message);
      end;
   end;
end;

end.

