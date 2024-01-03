unit uFileDao;

interface

uses
   uFileModel, System.Generics.Collections, FireDAC.Comp.Client, System.SysUtils,
   Datasnap.DBClient, System.JSON;

type
   TFileDao = class
   public
   public
      function Get(path, fileName: string): TObjectList<TFileModel>; overload;
      function Insert(AModel: TFileModel): TJSONValue;
      function Update(AId: string; AModel: TFileModel): TJSONValue;
      function Delete(AId: string): TJSONValue;
      function GetId(AAutoIncrementar: Integer): Integer;
   end;

implementation

uses
   uConnectionDao, uTools;

{ TFileDao }

function TFileDao.Update(AId: string; AModel: TFileModel): TJSONValue;
begin

end;

function TFileDao.Delete(AId: string): TJSONValue;
begin

end;

function TFileDao.GetId(AAutoIncrementar: Integer): Integer;
begin

end;

function TFileDao.Insert(AModel: TFileModel): TJSONValue;
begin

end;

function TFileDao.Get(path, fileName: string): TObjectList<TFileModel>;
begin

end;

end.

