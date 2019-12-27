Uses Crt,DosFile,Dos;

{  programme qui rassemble plusieurs fichiers bout … bout.

 Le premier paramŠtre est le nom du fichier destination.
 si le fichier destination n'existe pas, il est cr‚‚.
 si il existe, les autre fichiers sont mis … la suite du fichier destination.

 tout les paramŠtres suivant sont les noms de fichiers … rassembler,
 il faut indiquer ces noms de fichiers dans l'ordre.

}

var
  AFile:SearchRec;
  Source,Dest:Handle;
  Buf:Array[0..31999] of Byte;
  i,j:Byte;

Function HeSaidYes:Boolean;
var C:Char;
begin
  Repeat
    C:=Readkey;
  Until C in ['o','O','y','Y','n','N'];
  if C in ['o','O','y','Y'] then HeSaidYes:=True;
  if C in ['n','N'] then HeSaidYes:=False;
end;

Procedure WriteBlock(Source:Handle;Count:Word);
begin
  FRead(Source,Buf,Count);
  Write('o');
  GotoXY(WhereX-1,WhereY);
  FWrite(Dest,Buf,Count);
  Write('O');
end;

begin
 if ParamCount>=2 then begin
   if Fopen(Dest,ParamStr(1)) then begin
      WriteLn('Le fichier de destination existe d‚j…, voulez vous continuer? O/N');
      if not(HeSaidYes) then Halt else FSeek(Dest,0,PosEndFile);
    end else FCreate(Dest,ParamStr(1));
    for i:=2 to ParamCount do begin
      FindFirst(ParamStr(i),AnyFile,AFile);
      if DosError<>0 then begin
        Write('le fichier ',ParamStr(i),' n''existe pas');
        Halt;
      end;
      FOpen(Source,ParamStr(i));
      Write(ParamStr(i),' ');
      for j:=0 to AFile.Size div 31999+Ord(AFile.Size mod 31999<>0)-1 do Write('.');
      GotoXY(Length(ParamStr(i))+2,WhereY);
      if AFile.Size>31999 then for j:=0 to AFile.Size div 31999-1 do begin
        WriteBlock(Source,31999);
      end;
      if AFile.Size mod 31999<>0 then WriteBlock(Source,AFile.Size mod 31999);
      WriteLn;
      FClose(Source);
    end;
    FClose(Dest);
  end;
end.