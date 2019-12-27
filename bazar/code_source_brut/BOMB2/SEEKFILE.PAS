Uses Dos,Objects,KeyBoard;

Type
  PConfigFile=^TConfigFile;
  TConfigFile=Object(TObject)
    Name:string;
    Constructor Init(FileFound:SearchRec);
    Destructor Done; virtual;
  end;

Constructor TConfigFile.Init(FileFound:SearchRec);
begin
  Name:=Copy(FileFound.Name,1,Pos('.',FileFound.Name)-1);
end;

Destructor TConfigFile.Done;
begin
end;


Function SelectConfFiles:string;
var FileNames:TCollection;KeyReleased;

  Procedure SeekFiles
  var FileFound:SearchRec;NewFileName:PConfigFile;i:Integer;
  begin
    FileNames.Init(10,2);
    FindFirst('*.INI',Archive,FileFound);
    while DosError=0 do
    begin
      New(NewFileName,Init(FileFound));
      FileNames.Insert(NewFileName);
      FindNext(FileFound);
    end;
  end;


begin
  SeekFiles
  Repeat

    for i:=0 to FileNames.Count-1 do WriteLn(PConfigFile(FileNames.At(i))^.Name);
  Until K_Enter;
  ReadLn;
  FileNames.FreeAll;
  FileNames.Done;
end;


begin
  SelectConfFiles;
end.