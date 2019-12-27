Uses Crt,DosFile;

 {programme qui recupere la palette d'un fichier LBM pour la mettre
 dans un fichier

 premier paramŠtre : fichier LBM
 deuxiŠme paramŠtre : nom du fichier … cr‚‚r

 aucun contr“le n'est fait, aucune v‚rification, et aucun message n'est
 donn‚ si ‡a a march‚ ou pas.
 en bref c'est de la merde et il faudra corriger ‡a}

var
  H:Handle;
  Pal:Array[0..767] of Byte;
  i:Integer;

begin
  if ParamCount=2 then begin
    FOpen(H,ParamStr(1));
    FSeek(H,48,posbeginning);
    FRead(H,Pal,768);
    FClose(H);
    for i:=0 to 767 do Pal[i]:=Pal[i] shr 2;
    FCreate(H,ParamStr(2));
    FWrite(H,Pal,768);
    FClose(H);
  end;
end.