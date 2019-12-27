uses crt,dos;

type
  PFich=^TFich;
  PListe=^TListe;
  TListe=array [0..15999] of PFich;
  TFich=SearchRec;

var
  Liste:PListe;
  Verif:SearchRec;
  i,c,z:Integer;
  Taille:Longint;
  Fini:Boolean;
  Action:Char;
  Date:DateTime;
  Ext:String[3];
  Chemin:String;

Procedure OffCursor;Assembler;
asm
  mov ah,01
  mov ch,15
  mov cl,0
  int $10
end;

procedure EcrireNbr (nbr:longint);
var s:string;
begin
  Str(Nbr,s);
  if Length(s)<4 then Write(s) else begin
    if Length(s)<7 then Write(copy(S,1,Length(s)-3),' ',Copy(S,Length(s)-2,3)) else begin
      if Length(s)<10 then Write(copy(S,1,Length(s)-6),' ',Copy(S,Length(s)-5,3),' ',Copy(S,Length(s)-2,3)) else begin
        Write(Copy(S,1,Length(s)-9),' ',Copy(S,Length(s)-8,3),' ',Copy(S,Length(s)-5,3),' ',Copy(S,Length(s)-2,3));
      end;
    end;
  end;
end;

procedure Dir (FirstFile:LongInt);
var Octets:String;
begin
  for i:=FirstFile to FirstFile+23 do if i<=c-1 then begin
    TextColor(7);
    if Liste^[i]^.Attr=$10 then TextColor(9);
    if Liste^[i]^.Attr=$08 then TextColor(15);
    if (Pos('.',liste^[i]^.name)<>0) and (Pos('.',liste^[i]^.name)<>1)then begin
      Ext:=(Copy(Liste^[i]^.Name,Pos('.',Liste^[i]^.Name)+1,3));
      if Ext='EXE'then TextColor(12);
      if Ext='COM'then TextColor(12);
      if Ext='BAT'then Textcolor(12);
      if Ext='DLL'then Textcolor(6);
      if Ext='DL_'then Textcolor(6);
      if Ext='TXT'then Textcolor(14);
      if Ext='DOC'then Textcolor(14);
      if Ext='ARJ'then Textcolor(10);
      if Ext='ZIP'then Textcolor(10);
      Write (Copy(Liste^[i]^.Name,1,Pos('.',Liste^[i]^.Name)-1));
      GotoXY(10,WhereY);
      Write(Ext);
    end else Write(Liste^[i]^.Name);
    if Liste^[i]^.Attr=$10 then begin
      GotoXY(20,WhereY);
      Write('<REP>');
    end else begin
      Str(Liste^[i]^.Size,Octets);
      GotoXY(25-Length(Octets)-((Length(octets)-1) div 3),WhereY);
      EcrireNbr(Liste^[i]^.Size);
    end;
    GotoXY(27,WhereY);
    UnpackTime(Liste^[i]^.time,Date);
    With Date do begin
      Write(Day,'/',Month,'/',Year-1900);
      GotoXY(38,WhereY);
      Write(Hour,'h');
      GotoXY(42,WhereY);
      WriteLn(Min);
    end;
  end;
end;

begin
  c:=0;
  Getdir(0,Chemin);
  if Paramcount=1 then Chdir(Paramstr(1));
  Fini:=False;
  Offcursor;
  Taille:=0;
  New(Liste);
  FindFirst('*.*',AnyFile,Verif);
  while DosError=0 do begin
    New(Liste^[c]);
    liste^[c]^:=verif;
    Taille:=verif.size+taille;
    c:=c+1;
    FindNext(verif);
  end;

  z:=0;
  repeat;
    clrscr;
    Dir(z);
    action:=readkey;
    if action=#0 then Action:=readkey;
    if Action=' 'then begin
      z:=z+24;
      if z>c-22 then Fini:=True;
    end;
    if (action=#80) and (z<c-24) then z:=z+1;
    if (action=#72) and (z>0) then z:=z-1;
    if action=#27 then Fini:=true;
  until Fini;
  if (action<>#27) and (z<c-24) then clrscr;
  if action<>#27 then Dir(z);

  TextColor(7);
  EcrireNbr (c);
  write (' fichiers et r‚pertoires        ');
  EcrireNbr (taille);
  writeln (' octets');
  EcrireNbr (Diskfree(0));
  writeln (' octets libres');
  for i:=0 to c-1 do Dispose(Liste^[i]);
  Dispose(Liste);
  Chdir(Chemin);
end.

