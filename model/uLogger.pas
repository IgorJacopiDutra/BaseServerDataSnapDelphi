unit uLogger;

interface

uses
   System.SysUtils, System.Classes;

procedure GravarLog(folder, resource, action, payload: string);

implementation

uses
   System.IOUtils;

procedure GravarLog(folder, resource, action, payload: string);
var
   path, fileName: string;
begin
   try
      path := ExtractFilePath(ParamStr(0)) + IncludeTrailingPathDelimiter(folder) + IncludeTrailingPathDelimiter(resource);
      ForceDirectories(path);
      fileName := Format('%s%s_%s_%s.txt', [path, action, FormatDateTime('YYYYMMDD_HHNNSS', Now), IntToStr(Random(999))]);
      TFile.WriteAllText(fileName, Format('%s - %s', [DateTimeToStr(Now), payload]));
   except
      on E: Exception do


   end;
end;

end.

