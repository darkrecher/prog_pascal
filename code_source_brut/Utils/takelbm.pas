Uses Crt,DosFile;

{ programme qui recupere l'image dans un fichier LBM.
  l'image r‚cup‚r‚ reste compress‚.
  Il faudra donc la decompresser si on veut l'utiliser.
  l'algorithme de compression est celui des fichiers LBM}

Type
  TData=Array[0..63999] of Byte;
  PData=^TData;

var
  Data:PData;
  H,NewFile:Handle;
  BlockName:string[4];
  BlockSize,Compteur:LongInt;
  EndFile,DataMade,LBMOpened,NewFileOpened:Boolean;

Procedure EndMessage(s:string);
begin
  Write(s);
  Halt;
  if LBMOpened then FClose(H);
  if NewFileOpened then FClose(NewFile);
  if DataMade then Dispose(Data);
end;

Function LireNbr(h:Handle;Size:Byte):LongInt;
var Buf:Array[0..3] of Byte;i:Byte;Nbr:LongInt;
begin
  if FRead(h,Buf,Size) then begin
    Nbr:=0;
    for i:=0 to Size-1 do Nbr:=(Nbr shl 8)+Buf[i];
    LireNbr:=Nbr;
  end else LireNbr:=0;
end;

begin
  LBMOpened:=False;
  NewFileOpened:=True;
  DataMade:=False;
  Compteur:=0;
  if ParamCount<2 then EndMessage('Indiquez le nom du fichier LBM et le nom du fichier … cr‚er');
  if FOpen(NewFile,ParamStr(2)) then begin
    NewFileOpened:=True;
    EndMessage('Le fichier … cr‚er existe d‚j…');
  end;
  if not(FOpen(H,ParamStr(1))) then EndMessage('Fichier Introuvable');
  LBMOpened:=True;
  BlockName:='    ';
  FRead(H,BlockName[1],4);
  if BlockName<>'FORM' then EndMessage('Ceci n''est pas un fichier LBM');
  FSeek(H,12,posbeginning);
  Compteur:=12;
  Repeat
    FRead(H,BlockName[1],4);
    if FileDataSize=4 then begin
      EndFile:=False;
      BlockSize:=LireNbr(H,4);
      if not(BlockName='BODY') then begin
        Fseek(H,BlockSize+(BlockSize and 1),PosPointer);{les blocs commence toujours … une adresse paire}
        Inc(Compteur,BlockSize+8);                            {c'est bizarre mais c'est comme ‡a}
      end;
    end else EndFile:=True;
  Until (EndFile) or (BlockName='BODY');
  if EndFile then EndMessage('Fichier pourri');
  if BlockSize>64000 then EndMessage('Taille du fichier trop grande');
  New(Data);
  DataMade:=True;
  FRead(H,Data^,BlockSize);
  FCreate(NewFile,ParamStr(2));
  NewFileOpened:=True;
  FWrite(NewFile,BlockSize,4);
  FWrite(NewFile,Data^,BlockSize);
  EndMessage('Nouveau fichier cr‚‚.');
end.
