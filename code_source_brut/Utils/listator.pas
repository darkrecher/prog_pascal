Uses NewDelay,Crt,DosFile,Dos;

Type
  PElement=^TElement;
  TElement=Record
    Name:String[50];
    Flouzz:Word;
    Date:Word;
    Suivant:PElement;
  end;
  Characters=Set of Char;

var
  Premier:PElement;
  NbrElem,Scroll,Cursor,i,j,PMax:Word;
  FlouzMax:-1..65535;
  Key:Char;
  Color:Byte;
  S:String;
  PosXCursor:0..3;

Function NewStr(Nbr:Word):string;
var S:string;
begin
  Str(Nbr,S);
  NewStr:=S;
end;

Function NewVal(S:string):LongInt;
var Nbr:LongInt;Code:Integer;
begin
  Val(S,Nbr,Code);
  if Code=0 then NewVal:=Nbr;
end;

Procedure OffCursor;Assembler;
asm
  mov ah,01
  mov ch,15
  mov cl,0
  int $10
end;

Procedure OnCursor;Assembler;
asm
  mov ah,01
  mov ch,14
  mov cl,15
  int $10
end;

Procedure Decale(Nbr:Integer);{Decale les infos des ‚l‚ments vers la gauche}
var P1,P2:Pelement;           {de l'‚l‚ment 0 … Nbr inclus.}
begin                         {L'info de l'‚l‚ment 0 est perdu.}
  P1:=Premier;
  P2:=Premier^.Suivant;
  i:=0;
  While (P2<>Nil) and (i<Nbr-1) do begin
    P1^.Name:=P2^.Name;
    P1^.Flouzz:=P2^.Flouzz;
    P1^.Date:=P2^.Date;
    P1:=P1^.Suivant;
    P2:=P2^.Suivant;
    inc(i);
  end;
  P1^.Name:='';
  P1^.Flouzz:=0;
  P1^.Date:=0;
end;

Procedure Create;
var P:PElement;
begin
  New(P);                {le nouveau pointeur est cr‚‚ en d‚but de liste}
  P^.Suivant:=Premier;
  Premier:=P;
  Premier^.Flouzz:=0;
  Premier^.Name:='';
  Premier^.Date:=0;
  Inc(NbrElem);
end;

Procedure Supprime(Nbr:Integer);
var P1,P2:PElement;
begin
  P1:=Premier;
  P2:=Premier^.Suivant;
  i:=0;
  if Nbr=0 then begin
    Premier:=Premier^.Suivant;
    Dispose(P1);
    Dec(NbrElem);
  end else begin
    if Nbr>1 then for i:=0 to Nbr-2 do if P1<>Nil then P1:=P1^.Suivant;
    if Nbr>1 then for i:=0 to Nbr-2 do if P2<>Nil then P2:=P2^.Suivant;
    if P2<>Nil then begin
      P1^.Suivant:=P1^.Suivant^.Suivant;
      Dispose(P2);
      Dec(NbrElem);
    end;
  end;
end;

Function GetName(Nbr:Word):String;
var P:PElement;i:Word;
begin
  P:=Premier;
  if Nbr<>0 then for i:=0 to Nbr-1 do if P<>Nil then P:=P^.Suivant;
  if P<>Nil then GetName:=P^.Name;
end;

Function GetFlouzz(Nbr:Word):Word;
var P:PElement;i:Word;
begin
  P:=Premier;
  if Nbr<>0 then for i:=0 to Nbr-1 do if P<>Nil then P:=P^.Suivant;
  if P<>Nil then GetFlouzz:=P^.Flouzz;
end;

Function GetDate(Nbr:Word):Word;
var P:PElement;i:Word;
begin
  P:=Premier;
  if Nbr<>0 then for i:=0 to Nbr-1 do if P<>Nil then P:=P^.Suivant;
  if P<>Nil then GetDate:=P^.Date;
end;

Procedure DefineName(Nbr:Word;S:String);
var P:PElement;i:Word;
begin
  P:=Premier;
  if Nbr<>0 then for i:=0 to Nbr-1 do if P<>Nil then P:=P^.Suivant;
  if P<>Nil then P^.Name:=S;
end;

Procedure DefineFlouzz(Nbr:Word;Floz:Word);
var P:PElement;i:Word;
begin
  P:=Premier;
  if Nbr<>0 then for i:=0 to Nbr-1 do if P<>Nil then P:=P^.Suivant;
  if P<>Nil then P^.Flouzz:=Floz;
end;

Procedure DefineDate(Nbr:Word;ZeDate:Word);
var P:PElement;i:Word;
begin
  P:=Premier;
  if Nbr<>0 then for i:=0 to Nbr-1 do if P<>Nil then P:=P^.Suivant;
  if P<>Nil then P^.Date:=ZeDate;
end;

Procedure Exchange(Nbr1,Nbr2:Word);
var StockName:string;i:Word;StockFlouzz,StockDate:Word;
begin
  StockFlouzz:=GetFlouzz(Nbr1);
  StockName:=GetName(Nbr1);
  StockDate:=GetDate(Nbr1);
  DefineFlouzz(Nbr1,GetFlouzz(Nbr2));
  DefineName(Nbr1,GetName(Nbr2));
  DefineDate(Nbr1,GetDate(Nbr2));
  DefineFlouzz(Nbr2,StockFlouzz);
  DefineName(Nbr2,StockName);
  DefineDate(Nbr2,StockDate);
end;

Procedure ClasseDate(Nbr1,Nbr2:Word);{Nbr1=Premier ‚l‚ment,Nbr2:Nombre d'‚lement … classer}
var PMin:Word;DateMin:Word;i,j:Integer;
begin
  if Nbr2>1 then begin
    for i:=Nbr1 to Nbr1+Nbr2-1 do begin
      DateMin:=65535;
      for j:=i to Nbr1+Nbr2-1 do if GetDate(j)<DateMin then begin
        DateMin:=GetDate(j);
        PMin:=j;
      end;
      Exchange(i,PMin);
    end;
  end;
end;

Procedure Destroy;
var P:PElement;
begin
  While Premier<>Nil do begin
    P:=Premier;
    Premier:=Premier^.Suivant;
    Dispose(P);
  end;
end;

Function DrawXCursor:Byte;
begin
  Case PosXCursor of
    0:DrawXCursor:=2;
    1:DrawXCursor:=54;
    2:DrawXCursor:=63;
    3:DrawXCursor:=70;
  end;
end;

Procedure NewMove(Source:string;var Dest:string;Pos:Byte);
var i:Byte;
begin
  for i:=0 to Length(Source)-1 do Dest[Pos+i+1]:=Source[i+1];
end;

Function Meuuuh(P:PElement):string;
var S,Source:string;i:Byte;
begin
  S:='';
  for i:=0 to 75 do S:=S+' ';
  NewMove('³'+P^.Name,S,0);
  NewMove('³ '+NewStr(P^.Flouzz),S,51);
  NewMove('³  '+NewStr(P^.Date shr 5),S,59);
  NewMove('³  '+NewStr(P^.Date mod 32),S,66);
  NewMove('³',S,73);
  Meuuuh:=S;
end;

Procedure Affiche(Scroll:Integer);
var P:PElement;
begin
  TextColor(7);
  ClrScr;
  GotoXY(1,1);
  Writeln('                Nom                           argent vers‚   Mois  Jour');
  P:=Premier;
  i:=0;
  if Scroll<>0 then for i:=0 to Scroll-1 do P:=P^.Suivant;
  i:=0;
  While (P<>Nil) and (i<=11) do begin
    GotoXY(1,i*2+2);
    WriteLn(Meuuuh(P));
    if P^.Suivant=Nil then Write('ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÙ')
    else Write('ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄ´');
    P:=P^.Suivant;
    Inc(i);
  end;
end;

Procedure SummonSquare(SizeX,SizeY:Integer);
var i,j:Byte;
begin
  TextColor(7);
  for i:=0 to (SizeY-3) div 2 do begin
    if i>0 then begin
      GotoXY(39,11-i+1);
      Write('³³');
      GotoXY(39,12+i-1);
      Write('³³');
    end;
    GotoXY(39,11-i);
    Write('Ú¿');
    GotoXY(39,12+i);
    Write('ÀÙ');
    Delay(75);
  end;
  if Odd(SizeY) then begin
    GotoXY(39,12+SizeY div 2);
    Write('ÀÙ');
    GotoXY(39,11+SizeY div 2);
    Write('³³');
    Delay(75);
  end;
  if SizeX>3 then for i:=0 to (SizeX-4) div 2 do begin
    for j:=0 to SizeY-1 do begin
      GotoXY(38-i,12-(SizeY div 2)+j);
      if j=0 then Write('ÚÄ') else if j=SizeY-1 then Write('ÀÄ') else Write('³ ');
      GotoXY(40+i,12-(SizeY div 2)+j);
      if j=0 then Write('Ä¿') else if j=SizeY-1 then Write('ÄÙ') else Write(' ³');
    end;
    Delay(30);
  end;
  if Odd(SizeX) then begin
    for j:=0 to SizeY-1 do begin
      GotoXY(40+(SizeX-2) div 2,12-(SizeY div 2)+j);
      if j=0 then Write('Ä¿') else if j=SizeY-1 then Write('ÄÙ') else Write(' ³');
    end;
    Delay(75);
  end;
end;

Procedure NewWrite(S:string);
begin
  SummonSquare(Length(S)+2,5);
  GotoXY(40-Length(S) div 2,12);
  Write(S);
  While keypressed do readkey;
  Readkey;
end;

Procedure PrintLine(S:String);
var i:Byte;R:Registers;
begin
  for i:=1 to Length(S) do begin
    R.AH:=$0;
    R.AL:=Ord(S[i]);
    R.DX:=$0;
    intr($17,R);
  end;
  asm
    mov AH,$0000;
    mov AL,$000D;
    mov DX,$0000;
    int $17;
    mov AH,$0000;
    mov AL,$000A;
    mov DX,$0000;
    int $17;
  end;
end;

Procedure Imprime;
var i:Word;P:PELement;
begin
  SummonSquare(77,7);
  GotoXY(14,10);
  WriteLn('Il est possible que cela n''imprime pas correctement.');
  GotoXY(11,11);
  WriteLn('En fait, il y a de forte chance que votre ordinateur explose.');
  GotoXY(8,13);
  WriteLn('Par cons‚quent, vous feriez mieux de vous ‚loignez de 10 mŠtres,');
  GotoXY(3,14);
  WriteLn('et de demander … une personne que vous n''aimez pas d''appuyer sur une touche');
  Readkey;
  Affiche(Scroll);
  Asm
    mov AH,$0001;
    mov DX,$0000;
    int $17;
  end;
  PrintLine('                Nom                           argent vers‚   Mois  Jour');
  i:=0;
  P:=Premier;
  While P<>Nil do begin
    PrintLine(Meuuuh(P));
    if P^.Suivant=Nil then PrintLine('ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÙ')
    else PrintLine('ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄ´');
    Inc(i);
    P:=P^.Suivant;
    if i=12 then begin
      SummonSquare(56,5);
      GotoXY(14,12);
      WriteLn('Mettez une nouvelle feuille et appuyez sur une touche.');
      Readkey;
      Affiche(Scroll);
    end;
  end;
end;


Function NewRead(Abs,Ord,LMax:Integer;Chars:Characters;var S:String):Boolean;
var
  i,x,y,Cursor:Byte;
  S2:string;
  c:char;
begin
  x:=Abs;
  y:=Ord;
  Cursor:=Length(S)+1;
  repeat
    Gotoxy(x,y);
    For i:=0 to LMax-1 do Write(' ');
    GotoXY(X,Y);
    Write(s);
    GotoXY(X+Cursor-1,Y);
    c:=Readkey;
    case c of
      #8:if Length(S)>0 then begin
        S2:='';
        for i:=1 to Length(S) do if i<>Cursor-1 then S2:=S2+S[i];
        S:=S2;
        Dec(Cursor);
      end;
      #0:begin
        c:=Readkey;
        Case C of
          #75:if Cursor>1 then Dec(Cursor);
          #77:if Cursor<Length(S)+1 then Inc(Cursor);
        end;
      end;
      else if (Length(s)<LMax) and (c in Chars) then begin
        Insert(C,S,Cursor);
        Inc(Cursor);
      end;
    end;
  until (c=#13) or (c=#27);
  NewRead:=c=#13;
end;

Procedure DefineS;
begin
  Case PosXCursor of
    0:if GetName(Cursor+Scroll)='' then S:='' else S:=GetName(Cursor+Scroll);
    1:S:=NewStr(GetFlouzz(Cursor+Scroll));
    2:S:=NewStr(GetDate(Cursor+Scroll) shr 5);
    3:S:=NewStr(GetDate(Cursor+Scroll) mod 32);
  end;
end;

Procedure Save;
var h:handle;i:Word;P:PElement;
begin
  if not(FOpen(h,'listator.svg')) then FCreate(h,'listator.svg');
  FWrite(h,NbrElem,2);
  P:=Premier;
  for i:=0 to NbrElem-1 do begin
    FWrite(h,P^.Name,51);
    FWrite(h,P^.Flouzz,2);
    FWrite(h,P^.Date,2);
    P:=P^.Suivant;
  end;
  FClose(h);
  NewWrite('La liste a ‚t‚ sauvegard‚ dans le fichier listator.svg');
  Affiche(Scroll);
end;

Procedure Load;
var h:handle;i:Word;P:PElement;NbrElemSaved:Word;
begin
  if not(Fopen(h,'listator.svg')) then NewWrite('le fichier listator.svg est introuvable') else begin
    FRead(h,NbrElemSaved,2);
    if NbrElem<NbrElemSaved then for i:=NbrElem to NbrElemSaved-1 do Create;
    if NbrElem>NbrElemSaved then for i:=NbrElemSaved to NbrElem-1 do Supprime(0);
    P:=Premier;
    for i:=0 to NbrElem do begin
      FRead(h,P^.Name,51);
      FRead(h,P^.Flouzz,2);
      FRead(h,P^.Date,2);
      P:=P^.Suivant;
    end;
    Scroll:=0;
    Cursor:=0;
  end;
  Fclose(h);
  Affiche(Scroll);
end;

begin
  PatchCrt(Crt.Delay);  {instruction pour debugger cette merde d'unit‚ crt
  qui foire sur les ordinateurs trop rapide}
  OffCursor;
  Clrscr;
  Premier:=Nil;
  NbrElem:=0;
  Scroll:=0;
  Cursor:=0;
  PosXCursor:=0;
  for i:=0 to 3 do Create;
  DefineName(0,'Salut … toi!');
  DefineName(1,'O Grand Gourou de la Secte de la Lune Solaire');
  DefineName(2,'Enfonce la touche "H" avec ta divine main');
  DefineName(3,'pour acc‚der … l''aide');
  for i:=0 to 3 do DefineFlouzz(i,666);
  DefineDate(0,409);
  DefineDate(1,238);
  DefineDate(2,3168);
  Affiche(Scroll);
  S:=GetName(0);
  Repeat
    if KeyPressed then begin
      Key:=ReadKey;
      Case Key of
        'h':begin
          SummonSquare(79,23);
          While keypressed do readkey;
          GotoXY(2,2);
          WriteLn('                              LISTATOR');
          WriteLn;
          WriteLn('³                      The return of Wilfried Langlois');
          WriteLn;
          WriteLn('³Ceci est un programme con‡u pour les gourous des sectes,');
          WriteLn('³afin qu''ils puissent plus facilement g‚rer leurs disciples.');
          WriteLn('³On peut entrer le nom des disciples, l''argent qu''ils ont g‚n‚reusement donn‚');
          WriteLn('³… la secte et leurs dates d''adh‚sion.');
          WriteLn;
          WriteLn('³Dirigez-vous avec les fleches et appuyer sur entr‚e pour modifier une case.');
          WriteLn('³Appuyez sur la touche "+" pour rajouter un ‚l‚ment de liste.');
          WriteLn('³Appuyez sur "suppr" pour supprimer l''‚lement sur lequel vous ˆtes.');
          WriteLn('³Appuyer sur "inser" pour ins‚rer un ‚l‚ment … l''endroit o— vous ˆtes.');
          WriteLn('³Appuyer sur C pour classer vos disciples selon leur fid‚lit‚ … la secte,');
          WriteLn('³en sachant que plus un disciple est fidŠle, plus il donne d''argent, et que');
          WriteLn('³parmi les disciples qui ont donn‚ la mˆme somme, celui qui s''est inscrit');
          WriteLn('³le plus t“t est le plus d‚vou‚ envers la secte.');
          WriteLn('³Appuyez sur S pour sauvegarder la liste et sur L pour la charger.');
          WriteLn('³Il n''y a qu''un seul fichier de sauvegarde.');
          WriteLn('³Appuyez sur I pour imprimer la liste.');
          WriteLn('³Appuyez sur W pour voir qui sont les personnes qui ont fait ce super programme');
          Readkey;
          SummonSquare(79,6);
          GotoXY(3,11);
          Write('Ah oui! J''oubliais, ce programme peut aussi servir … g‚rer des r‚servations');
          GotoXY(11,12);
          Write('de voyage. Mais ce n''est pas l… son utilisation primaire.');
          While keypressed do readkey;
          Readkey;
          Affiche(Scroll);
        end;
        #0:begin
          Key:=Readkey;
          TextColor(7);
          if S='' then S:=' ';
          GotoXY(DrawXCursor,Cursor*2+2);
          Write(S);
          Case Key of
            #72:if Cursor>0 then Dec(Cursor) else if Scroll>0 then begin
              Dec(Scroll);
              Affiche(Scroll);
            end;
            #80:if (Cursor<11) and (Cursor+Scroll<NbrElem-1) then Inc(Cursor) else begin
              if Cursor+Scroll<NbrElem-1 then Inc(Scroll);
              Affiche(Scroll);
            end;
            #75:if PosXCursor>0 then Dec(PosXCursor);
            #77:if PosXCursor<3 then Inc(PosXCursor);
            #82:begin
              Create;
              Decale(Scroll+Cursor+1);
              Affiche(Scroll);
            end;
            #83:if NbrElem>1 then begin
              Supprime(Cursor+Scroll);
              if Cursor+Scroll=NbrElem then Dec(Cursor);
              Affiche(Scroll);
            end else begin
              SummonSquare(76,5);
              GotoXY(20,11);
              WriteLn('On ne peut pas supprimer la derniŠre case.');
              GotoXY(3,12);
              WriteLn('De plus, je ne vois pas pourquoi vous voudriez supprimer la derniŠre case.');
              GotoXY(20,13);
              Write('Une liste sans case, c''est un peu idiot.');
              Readkey;
              Affiche(Scroll);
            end;
          end;
          DefineS;
        end;
        '+':begin
          Create;
          Decale(NbrElem);
          Affiche(Scroll);
        end;
        #13:begin
          OnCursor;
          Case PosXCursor of
            1:begin
              S:=NewStr(GetFlouzz(Cursor+Scroll));
              if S='0' then S:='';
              SummonSquare(8,5);
              if NewRead(37,12,5,['0'..'9'],S) then begin
                if S='' then S:='0';
                if NewVal(S)>65535 then begin
                  SummonSquare(62,5);
                  GotoXY(12,11);
                  WriteLn('Vous ne pouvez pas mettre un nombre plus grand que 65535.');
                  GotoXY(10,12);
                  WriteLn('D''ailleurs si il faut donner plus de 65535F pour un voyage,');
                  GotoXY(27,13);
                  WriteLn('c''est vraiment trop cher.');
                  Readkey;
                  S:='0';
                end;
                DefineFlouzz(Cursor+Scroll,NewVal(S));
              end;
            end;
            0:begin
              if S='' then S:='';
              SummonSquare(53,5);
              if NewRead(15,12,50,['a'..'z','A'..'Z','0'..'9',' ','‚','Š','…','—','.',';',',',''''],S)
              then DefineName(Cursor+Scroll,S);
              if S='' then S:='';
            end;
            2:begin
              S:=NewStr(GetDate(Cursor+Scroll) shr 5);
              if S='0' then S:='';
              SummonSquare(5,5);
              if NewRead(39,12,2,['0'..'9'],S) then begin
                if S='' then S:='0';
                DefineDate(Cursor+Scroll,(GetDate(Cursor+Scroll) mod 32)+(NewVal(S) shl 5));
              end;
            end;
            3:begin
              S:=NewStr(GetDate(Cursor+Scroll) mod 32);
              if S='0' then S:='';
              SummonSquare(5,5);
              if NewRead(39,12,2,['0'..'9'],S) then begin
                if S='' then S:='0';
                DefineDate(Cursor+Scroll,((GetDate(Cursor+Scroll) shr 5)shl 5)+NewVal(S));
              end;
            end;
          end;
          OffCursor;
          Affiche(Scroll);
        end;
        'c':if NbrElem>1 then begin
          for i:=0 to NbrElem-1 do begin
            FlouzMax:=-1;
            for j:=i to NbrElem-1 do if GetFlouzz(j)>FlouzMax then begin
              FlouzMax:=GetFlouzz(j);
              PMax:=j;
            end;
            Exchange(i,PMax);
          end;
          FlouzMax:=-1;
          j:=0;
          for i:=0 to NbrElem-1 do begin
            if GetFlouzz(i)=FlouzMax then Inc(j) else begin
              FlouzMax:=GetFlouzz(i);
              if j>0 then begin
                ClasseDate(i-j-1,j+1);
                j:=0;
              end;
            end;
          end;
          if j>0 then ClasseDate(i-j,j+1);
          Affiche(Scroll);
        end else begin
          SummonSquare(77,3);
          GotoXY(3,12);
          Write('Il est totalement inutile de vouloir classer une liste avec une seule case!');
          Readkey;
          Affiche(Scroll);
          DefineS;
        end;
        's':Save;
        'l':Load;
        'i':Imprime;
        'w':begin
          NewWrite('LISTATOR    version 1.000000000000');
          NewWrite('Conception:Wilfried Langlois');
          NewWrite('R‚alisation:Wilfried Langlois');
          NewWrite('Programmation:Wilfried Langlois');
          NewWrite('Graphismes:Wilfried Langlois');
          NewWrite('Musique et sons inexistants:Wilfried Langlois');
          NewWrite('Relations publiques:Wilfried Langlois');
          NewWrite('Directeur marketing:Wilfried Langlois');
          NewWrite('Testeur:Wilfried Langlois');
          NewWrite('Distributeur:Wilfried Langlois');
          NewWrite('L''homme qui valait 3 centimes:Wilfried Langlois');
          NewWrite('Savant fou qui va d‚truire la Terre:Wilfried Langlois');
          NewWrite('Bouffon de service:Wilfried Langlois');
          SummonSquare(60,6);
          GotoXY(16,11);
          Write('pr‚sident en chef, directeur principal, Num‚ro 1,');
          GotoXY(11,12);
          Write('Grand maŒtre, et commandeur des croyants:Wilfried Langlois');
          While keypressed do readkey;
          Readkey;
          NewWrite('Wilfried Langlois: le justicier au service de l''humanit‚');
          NewWrite('Votez pour Wilfried Langlois!!');
          NewWrite('Wilfried Langlois lave plus blanc que blanc!');
          NewWrite('Envoyez vos dons … la "Wilfried Langlois Fondation"');
          NewWrite('36 15 Wilfried Langlois:des cadeaux … gogo');
          NewWrite('Comment un humain peut-il porter un nom aussi ridicule??');
          Affiche(Scroll);
        end;
      end;
    end;
    Inc(Color);
    if Color in[0,42,85,127,170,212] then begin
      GotoXY(DrawXCursor,Cursor*2+2);
      Case Color of
        0:TextColor(2);
        127:TextColor(10);
      end;
      Write(S);
    end;
    Delay(3);
  Until Key=#27;
  Destroy;
  ClrScr;
  OnCursor;
  TextColor(7);
end.