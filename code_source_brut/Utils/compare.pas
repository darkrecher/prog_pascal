uses NewDelay,crt,Dos,DosFile;

{  Programme qui compare les valeurs des octets de deux fichier diff‚rents

(le programme indiquera la position des octets qui sont diff‚rents, et
leurs valeurs.

Premier et deuxiŠme paramŠtre : Les fichiers … comparer

  [TroisiŠme paramŠtre] : point de d‚part de lecture du premier fichier
  [quatriŠme paramŠtre] : point de d‚part de lecture du deuxiŠme fichier

  on peut donc comparer des fichiers en d‚calant le cadre de lecture
  Ex : Compare Machin.Dat Chose.Dat 50 51

  [cinquiŠme paramŠtre] : seuil de tol‚rance. Exemple :
  si le seuil de tol‚rance est fix‚ … 5
  si les deux octets … comparer ont pour valeurs 85 et 83 (en d‚cimal)
  ces deux octets ne seront pas indiqu‚s. car 85-83 est plus petit que 5

  (ce paramŠtre est totalement inutile, mais ‡a m'a servi UNE FOIS pour
  essayer de comprendre comment etait organis‚ les fichiers
  de sauvegarde dun jeu d‚bile

}

var
  File1,File2:SearchRec;
  Depart1,Depart2,BytesToRead:LongInt;
  i,a:Word;
  Amplitude:Byte;
  H1,H2:Handle;
  Buf1,Buf2:Array[0..31999] of Byte;

Function Min(X1,X2:LongInt):LongInt;
begin
  if X1<X2 then Min:=X1 else Min:=X2;
end;

Procedure TakeParam(Param:Byte;var Dest:LongInt);
var Code:Integer;
begin
  Val(ParamStr(Param),Dest,Code);
  if Code<>0 then begin
    WriteLn('Le paramŠtre ',Param,' doit ˆtre un nombre');
    Halt;
  end;
end;

Procedure TakeParamByte(Param:Byte;var Dest:Byte);
var Code:Integer;
begin
  Val(ParamStr(Param),Dest,Code);
  if Code<>0 then begin
    WriteLn('Le paramŠtre ',Param,' doit ˆtre un nombre');
    Halt;
  end;
end;


Procedure ShowProgress;
var X,Y:Byte;
begin
  X:=WhereX;
  Y:=WhereY;
  GotoXY(1,25);
  Write((i*100) div a,'% achev‚');
  GotoXY(X,Y);
end;

Function NewStr(Nbr:LongInt):string;
var S:string;
begin
  Str(Nbr,S);
  NewStr:=S;
end;

Function IntoHexa(Nbr:Byte):String;
const chiffres:Array[0..15] of Char='0123456789ABCDEF';
begin
  IntoHexa:=chiffres[Nbr div 16]+chiffres[Nbr mod 16];
end;

Procedure WriteLine(X:Byte;Octet,Deci,Hexa,Ascii:String);
var S:string;i:Byte;
begin
  S:='³';
  for i:=0 to 9-Length(Octet) do S:=S+' ';
  S:=S+Octet+' ³   '+Deci;
  for i:=0 to 5-Length(Deci) do S:=S+' ';
  S:=S+'³  '+hexa+'  ³   '+Ascii+'    ³';
  GotoXY(X,WhereY);
  Write(S);
end;

Function NewChr(Nbr:Byte):Char;
begin
  if Nbr>27 then NewChr:=Chr(Nbr) else NewChr:=' ';
end;

Function Compare(Count:Word):Boolean;
var j:Word;SthgDifferent:Boolean;C:Char;
Const S='³   octet   ³ d‚cimal ³ hexa ³ ASCII  ³';
begin
  SthgDifferent:=False;
  C:='a';
  for j:=0 to Count-1 do begin
    if Abs(Buf1[j]-Buf2[j])>Amplitude then begin
      if not(SthgDifferent) or (WhereY=24) then begin
        if SthgDifferent and (WhereY=24) then C:=Readkey;
        ClrScr;
        if C=#27 then Halt;
        ShowProgress;
        GotoXY(10,1);
        Write(File1.Name);
        GotoXY(50,1);
        Write(File2.Name);
        GotoXY(1,2);
        Write(S);
        GotoXY(41,2);
        Write(S);
        GotoXY(1,3);
        SthgDifferent:=True;
      end;
      WriteLine(1,NewStr(j+Depart1+i*32000),NewStr(Buf1[j]),IntoHexa(Buf1[j]),NewChr(Buf1[j]));
      WriteLine(41,NewStr(j+Depart2+i*32000),NewStr(Buf2[j]),IntoHexa(Buf2[j]),NewChr(Buf2[j]));
      WriteLn;
    end;
  end;
  if SthgDifferent and (WhereY<>4) then C:=Readkey;
  if C=#27 then begin
    ClrScr;
    Halt;
  end;
  Compare:=SthgDifferent;
end;

begin
  PatchCrt(Crt.Delay);  {instruction pour debugger cette merde d'unit‚ crt
  qui foire sur les ordinateurs trop rapide}
  if ParamCount>=2 then begin
    FindFirst(ParamStr(1),AnyFile,File1);
    if DosError<>0 then begin
      Write('Impossible de trouver le premier fichier');
      Halt;
    end;
    FindFirst(ParamStr(2),AnyFile,File2);
    if DosError<>0 then begin
      Write('Impossible de trouver le deuxiŠme fichier');
      Halt;
    end;
    if ParamCount>=3 then TakeParam(3,Depart1) else Depart1:=0;
    if ParamCount>=4 then TakeParam(4,Depart2) else Depart2:=0;
    if ParamCount>=5 then TakeParamByte(5,Amplitude) else Amplitude:=0;
    if Depart1>File1.Size then begin
      Write('Le premier nombre est trop grand');
      Halt;
    end;
    if Depart2>File2.Size then begin
      Write('Le deuxiŠme nombre est trop grand');
      Halt;
    end;
    FOpen(H1,ParamStr(1));
    FOpen(H2,ParamStr(2));
    FSeek(H1,depart1,posbeginning);
    FSeek(H2,depart2,posbeginning);
    BytesToRead:=Min(File1.Size-Depart1,File2.Size-Depart2);
    a:=BytesToRead div 32000+1;
    ClrScr;
    if BytesToRead>32000 then for i:=0 to (BytesToRead div 32000)-1 do begin
      ShowProgress;
      WriteLn('Lecture de 32Ko du fichier ',File1.Name);
      FRead(H1,Buf1,32000);
      WriteLn('Lecture de 32Ko du fichier ',File2.Name);
      FRead(H2,Buf2,32000);
      WriteLn('Comparaison');
      if Compare(32000) then ClrScr else WriteLn('Pas de diff‚rence');
      if WhereY>20 then ClrScr;
    end;
    if BytesToRead mod 32000<>0 then begin
      i:=BytesToRead div 32000;
      ShowProgress;
      WriteLn('Lecture de ',BytesToRead mod 32000,' octets du fichier ',File1.Name);
      FRead(H1,Buf1,BytesToRead mod 32000);
      WriteLn('Lecture de ',BytesToRead mod 32000,' octets du fichier ',File2.Name);
      FRead(H2,Buf2,BytesToRead mod 32000);
      WriteLn('Comparaison');
      if Compare(BytesToRead mod 32000) then ClrScr else WriteLn('Pas de diff‚rence');
    end;
    Inc(i);
    ShowProgress;
    FClose(H1);
    FClose(H2);
  end;
end.