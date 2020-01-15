Uses Dos,DosFile,Crt,MCGaGraf,KeyBoard,Mouserec;

{--------------------LE SCROLLING------------------------------------------}

var
StopScrolling:Boolean;
Text:string;

const
{    #0:quitter le programme
     #1:vider la ligne
     #2:attente 0.5 seconde
     #3:d‚but du texte … centrer
     #4:fin du texte … centrer
     #5:onduler
     #6:arrˆter ondulation
     #7:vitesse lente
     #8:vitesse normale
     #9:vitesse rapide
     #20:texte bleu
     #21:rouge
     #22:vert
     #23:jaune
     #24:gris
     #25:beuark!
}
  WaveLen=32;
  WaveForm:Array[0..WaveLen-1] of Byte=(
    0,0,0,0,1,1,1,1,2,2,2,2,3,3,3,3,3,3,3,3,2,2,2,2,1,1,1,1,0,0,0,0);
  Width=320;
  Height=28;
  Margin=8;
  XPos=(320-Width) div 2;
  YPos=(200-Height) div 2;

type
  PLetterImg=^TLetterImg;
  TLetterImg=Array[0..254,0..Height-1] of Byte;
  PImage=^TImage;
  TImage=Array[0..199,0..319] of Byte;
  TPlain=Array[0..63999] of Byte;
  TLetter=record
    Img:PLetterImg;
    Width:Byte;
  end;

var
  Letters:Array[32..255] of TLetter;
  Image:PImage;
  Video:PImage;

procedure InitGraph;
begin
  asm
    mov ax,$0013
    int $10
  end;
  Video:=Addr(Mem[$A000:0]);
end;

procedure CloseGraph;
begin
  asm
    mov ax,$0003
    int $10
  end;
end;

procedure LoadImage;

var f:File;

function ReadName:String;
var s:String;
begin
  s:='    ';
  BlockRead(f,s[1],4);
  ReadName:=s;
end;

function ReadInt:LongInt;
var l:LongInt;b:Array[0..3] of Byte;
begin
  l:=0;
  BlockRead(f,b,4);
  l:=(((((LongInt(b[0]) shl 8)+LongInt(b[1])) shl 8)+LongInt(b[2])) shl 8)+LongInt(b[3]);
  ReadInt:=l;
end;

const
  BufSize=4096;
  BufPos:Integer=-1;
var
  Buf:Array[0..BufSize-1] of Byte;

function ReadByte:Byte;
var w:Word;
begin
  if (BufPos=-1) or (BufPos>=BufSize) then begin
    BufPos:=0;
    BlockRead(f,Buf,BufSize,w);
  end;
  ReadByte:=Buf[BufPos];
  Inc(BufPos);
end;

var
  Index,Size:LongInt;
  Name:String;
  Palette:Array[0..767] of Byte;
  i:Word;b:Byte;
  Regs:Registers;

begin
  Assign(f,'ALPHA4.LBM');
  Reset(f,1);
  ReadName;
  Size:=ReadInt+8;
  ReadName;
  Index:=12;
  repeat
    Seek(f,Index);
    Name:=ReadName;
    Index:=Index+ReadInt+8;
    Index:=Index+(Index and 1);
    if Name='CMAP' then begin
      BlockRead(f,Palette,768);
      for i:=0 to 767 do Palette[i]:=Palette[i] shr 2;
      Regs.AX:=$1012;
      Regs.BX:=$0000;
      Regs.CX:=$0100;
      Regs.ES:=Seg(Palette);
      Regs.DX:=Ofs(Palette);
      Intr($10,Regs);
    end else if Name='BODY' then begin
      i:=0;
      repeat
        b:=ReadByte;
        if b>128 then begin
          b:=257-b;
          FillChar(TPlain(Image^)[i],b,ReadByte);
          i:=i+b;
        end else begin
          b:=b+1;
          while b>0 do begin
            TPlain(Image^)[i]:=ReadByte;
            Dec(b);
            Inc(i);
          end;
        end;
      until i>=64000;
    end;
  until Index>=Size;
  Close(f);
end;

procedure LoadLetters;
var l,x,y,ix,iy:Integer;
begin
  for l:=32 to 255 do begin
    Letters[l].Img:=nil;
    Letters[l].Width:=0;
  end;
  ix:=0;
  iy:=0;
  l:=32;
  while (iy<200) and (l<256) do begin
    if Image^[iy,ix]=3 then with Letters[l] do begin
      Inc(ix);
      while (ix+Width<320) and (Image^[iy,ix+Width]<>2) do Inc(Width);
      if Width>0 then begin
        GetMem(Img,Height*Width);
        for y:=0 to Height-1 do for x:=0 to Width-1 do begin
          Img^[x,y]:=Image^[iy-25+y,ix+x];
        end;
      end;
      Inc(l);
      ix:=ix+Width;
    end;
    Inc(ix);
    if ix>=320 then begin
      Inc(iy);
      ix:=0;
    end;
  end;
end;

procedure ShowBkGnd;
var i:Integer;
begin
{  for i:=0 to 39 do begin
    Move(Image^[i,0],Video^[YPos-6+i,XPos-8],12);
    Move(Image^[i,12],Video^[YPos-6+i,XPos+Width-4],12);
  end;}
end;

{----------------------------------------------------------------------------}

var
  Buf:Array[0..Height-1,0..Width+Margin-1] of Byte;
  Increment:Integer;

const
  Center:Integer=0;
  Wait:Word=0;
  Clear:Integer=Width;
  Quit:Boolean=False;
  Wave:Boolean=False;
  Color:Byte=32;
  NextInc:Integer=2;

function InitChar(CharVal:Byte):Integer;
var i:Integer;
begin
  i:=0;
  case Char(CharVal) of
   #32..#255:i:=Letters[CharVal].Width;
   #0:Quit:=True;
   #1:i:=Width-Clear+Margin;
   #2:Wait:=25;
   #3:Center:=0;
   #4:i:=(Width-Center) div 2+Margin;
   #5:Wave:=True;
   #6:Wave:=False;
   #7:NextInc:=1;
   #8:NextInc:=2;
   #9:NextInc:=4;
   #20:Color:=32;
   #21:Color:=64;
   #22:Color:=96;
   #23:Color:=128;
   #24:Color:=160;
   #25:Color:=192;
  end;
  if i<0 then InitChar:=0 else InitChar:=i;
end;

procedure DrawChar(CharVal:Byte;CharP:Integer;C:Integer);
var y:Integer;b:Byte;
begin
  if CharVal>=32 then begin
    Clear:=0;
    for y:=0 to Height-1 do begin
      b:=Letters[CharVal].Img^[CharP,y];
      if b=0 then Buf[y,Width+Margin-Increment+C]:=0
             else Buf[y,Width+Margin-Increment+C]:=(b and 31) or Color;
    end;
    Inc(Center);
  end else begin
    if Clear<Width then Inc(Clear);
    for y:=0 to Height-1 do Buf[y,Width+Margin-Increment+C]:=0;
  end;
end;

var y:Integer;
    C:Byte;

const
  TextP:Integer=0;
  CharP:Integer=0;
  CharR:Integer=0;

var CharVal:Byte;

Procedure SuperScrolling;
var Compteur:Byte;
begin
  Compteur:=0;
  Text:=' et voici enfin le retour tant attendu du jeu le plus con de toute la galaxie :'#1#3#22#5'pong!!!'#4#2#2#20+
  'megatop non?   attendez, je vais arreter l''ondulation, j''ai le mal de mer       '#6#0;
  if Text<>'' then repeat
    Increment:=NextInc;
    if Wait=0 then Move(Buf[0,Increment],Buf[0,0],(Width+Margin)*Height-Increment);
    if Wait>0 then Dec(Wait);
    for C:=0 to Increment-1 do begin
      while (Wait=0) and (CharR=0) do begin
        Inc(TextP);
        if TextP>Length(Text) then TextP:=1;
        CharVal:=Ord(UpCase(Text[TextP]));
        CharR:=InitChar(CharVal);
        CharP:=0;
      end;
      if Wait=0 then begin
        DrawChar(CharVal,CharP,C);
        Dec(CharR);
        Inc(CharP);
      end;
    end;
    repeat until (Port[$3DA] and 8)=0;
    repeat until (Port[$3DA] and 8)<>0;
    if Wave then begin
      for y:=0 to Height-1 do Move(Buf[y,WaveForm[y mod WaveLen]],Video^[YPos+y,XPos],Width);
    end else begin
      for y:=0 to Height-1 do Move(Buf[y],Video^[YPos+y,XPos],Width);
    end;
    C:=WaveForm[WaveLen-1];
    Move(WaveForm[0],WaveForm[1],SizeOf(WaveForm)-SizeOf(WaveForm[0]));
    WaveForm[0]:=C;
    if KeyPressed then begin
      ReadKey;
      StopScrolling:=True;
    end;
    if Quit then begin
      Case Compteur of
       0:Text:=' ouf, ca va mieux.'#1'ce jeu a ete fait entierement par '#21'moi...'#20' sauf ce scrolling qui a ete fait par'+
        ' mon frere.    vous allez voir c''est vraiment super genial comme jeu, on peut jouer jusqu''a 4 joueurs'#1#0;
        1:Text:=' '#3'youpitralala!!!'#4#2#1'bon voila, le plus important est dit, le reste, c''est que des conneries, '+
        'vous pouvez appuyer sur une touche maintenant'#1'remerciements a ma mere, mon pere, ma soeur et mes freres et '+
        'toute ma famille'#0;
        2:Text:=' mais j''ai pas la place de tous les citer, je remercie aussi mes potes et mes potesses que '+
        'j''ai pas non plus la place de tous les citer'#1#0;
        3:Text:=' '{enormes remerciements a:'#1#21#3#4#2#5#2#2#6#2#1#20'}+'et surtout, je'+
        ' remercie...'#23'vous!'#20'  qui avez le courage d''executer ce jeu et de se farcir ce texte.'#1#0;
        4:Text:=' '#9'wargrshniokfplkzgruuik!! yakalelo!'#1#8'charade:mon premier est une lettre de l''alphabet'+
        ' et mon tout a une masse volumique de 10 tonnes par metre cube, je suis qui? je suis quoi?'#1#0;
        5:Text:=' je suis monsieur '#21'r'#20'!!'#1'and now, you will see the color of the degueulis de mammouth     '#25+
        'bou'#24'eua'#23'aar'#22'rrc'#21'kkk'#1#20'aah! ca va mieux!    vous etes toujours la?      '#0;
        6:Text:=' et maintenant une page de publicite:'#1'acheter les cd de '#23'natacha atlas!!'#20'    '+
        'mais c''est vrai c''est excellent comme musique!     et youpi!!'#1#0;
        7:Text:=' eh vous avez deja ecoute skyrock le dimanche de 11h a minuit? c''est de la'+
        ' giga-ultra-mega-supra-musique!! i love this!'#1#9#5'ouaaaaaaaayayayouyouyouyou!!'#1#6#8#0;
        8:Text:=' ich habe eine interro of deutsch tomorrow und my mother is persuaded que ich revise '+
        'und ich kann nicht blairer the allemand!!'#1#0;
        9:Text:=' '#9'oh'#8' '#9'r'#7'o'#9'b'#8'er'#7't'#9'!'#8'! '#9'q'#8'u'''#7'es'#8't'#7'-'#9'c'#7'e'#9' q'#8'u'#7'e'#8' '+
        #9't'#8'u'#7' f'#9'o'#8'u'#9's '#7'a'#8'v'#7'e'#9'c '#8'l'#7'a'#9' '#8'ma'#7'n'#9'i'#8'v'#7'e'#9'l'#7'l'#9'e '+
        #8'a'#8' '#7's'#8'cr'#9'o'#7'l'#8'l'#9'in'#7'g'#8'? ah! ca va mieux.'#1#0;
        10:Text:=' je vais maintenant vous dicter tres distinctement le numero gagnant de la tombola:'+
        'il s''agit du numero...843'#9'659846561365498463519783339'#1#8'ouais! germaine! on a gagne le grolo-grolo!!'#0;
        11:Text:='       les nouvelles de la bourse:la mer monte!   alors achetez de l''eau!'#1+
        'ahahahahaha!! je suis psychopathe!!!'#22'  ah bon? c''est votre vrai nom ou c''est un pseudonyme?    '#0;
        12:Text:=' '#20' eh oui, c''est lourd!! mais c''est moi!!'#1+
        'aaargh! ce scrolling est explose-z-yeux-tesque, vous trouvez pas?'#0;
        13:Text:=' '#1#5#9'free at last!! free at last!!'#1#6#8'euh ouais c''est cool, allez une derniere:'+
        '    je voudrais z''etre un fauteuil dans un salon de coiffure pour dames, pour que les fesses des'#0;
        14:Text:=' belles ames se posent contre mon orgueil!       n''importe quoi! bon je vais '+
        'me coucher.'#1'quelques jours plus tard:'#1'ca y est! ich habe fait meine controle of allemand'#0;
        15:Text:=' und ich habe a peu pres saved the meubles and the moyenne aber now j''ai une foutue disserte '+
        'de filosophie a rendre pour bientot et it takes me the head!! suite au prochain numero.'#1#0;
        16:Text:=' bon, peut etre que vous avez envie de jouer, alors je vais m''arreter la, '+
        'mais surtout, rappelez vous: votez pour r/eche\r grzmktbq!!'#1#0;
        17:StopScrolling:=True;
      end;
      Inc(Compteur);
      Quit:=False;
    end;
  until StopScrolling;
end;

{----------------------LE JEU-----------------------------------------------}

Type
  Direction=(Bas,Gauche,Haut,Droite);
  TBorder=Record
    Lim1,Lim2,Y,Effect,Effect2:Integer;
    X:LongInt;
    Exists:Boolean;
    Side:Direction;
    Player:Byte;
  end;

var
  DepX,DepY,Speed,BallY,i:Integer;
  BallX:LongInt;
  NbrPlayer:Byte;
  BackToMenu,EndGame,Up,Down,Left,Right:Boolean;
  Border:Array[0..3] of TBorder;
  Score:Array[1..4] of Word;
  PlayerExists:Array[1..4] of Boolean;
  Cursor:Array[0..8,0..4] of Byte;
  Sprite:Array[0..4,0..4] of Byte;
  Rectangle:Array[0..57,0..159] of Byte;
  ColorDegradeHoriz:Array[0..319] of Byte;
  ColorDegradeVertic:Array[0..199] of Byte;

Function NewStr(Nbr:Integer):string;
var S:string;
begin
  Str(Nbr,S);
  NewStr:=S;
end;

Procedure DrawMenu;
var Left:Array[0..10,0..8] of Byte;Corner:Array[0..14,0..51] of Byte;
  Procedure TakeSprite;
  var H:Handle;i:Integer;Buf:Array[0..10228] of Byte;
  begin
    FOpen(H,'pong.spr');
    FRead(H,Buf[0],10229);
    FClose(H);
    Move(Buf[0],Left[0,0],99);
    Move(Buf[99],Corner[0,0],780);
    Move(Buf[879],Cursor[0,0],45);
    Move(Buf[924],Sprite[0,0],25);
    Move(Buf[949],Rectangle[0,0],9280);
  end;

  Procedure boutons(x,y:Integer;OO,BA,GOCH,DROATT:Char);
  begin
    Square(x+13,y,x+24,y+11,15);
    Square(x,y+13,x+11,y+24,15);
    Square(x+13,y+13,x+24,y+24,15);
    Square(x+26,y+13,x+37,y+24,15);
    OutText(x+16,y+2,OO);
    OutText(x+16,y+15,BA);
    OutText(x+3,y+15,GOCH);
    OutText(x+29,y+15,DROATT);
  end;

begin
  ClearScreen(0);
  TakeSprite;
  for i:=0 to 3 do begin
    FilledSquare(i*39+88,10,i*39+120,33,23);
    Square(i*39+90,12,i*39+118,31,19);
  end;
  LineHoriz(90,118,30,10);
  LineHoriz(90,118,31,10);
  LineHoriz(168,196,12,10);
  LineHoriz(168,196,13,10);
  LineVertic(129,12,31,10);
  LineVertic(130,12,31,10);
  LineVertic(234,12,31,10);
  LineVertic(235,12,31,10);
  for i:=0 to 4 do LineVertic(i*39+84,35,151,15);
  for i:=0 to 4 do LineHoriz(84,240,i*29+35,15);
  for i:=0 to 3 do OutText(0,45+i*29,'JOUEUR '+Chr(Byte(i)+49));
  OutText(131,155,'VITESSE');
  LineHoriz(15,264,170,15);
  Boutons(252,37,'Z','S','Q','D');
  Boutons(252,66,'O','L','K','M');
  Boutons(252,95,Chr(24),Chr(25),Chr(26),Chr(27));
  Boutons(252,124,'8','5','4','6');
  for i:=0 to 10 do Move(Left[i,0],Buffer^[165+i,4],9);
  for i:=0 to 14 do Move(Corner[i,0],Buffer^[161+i,268],52);
  AfficheAll;
end;

Procedure InitBorder(Which:Byte;P1,P2,P3,P4:Boolean;ASide:Direction);
var APLayer:Byte;AExists:Boolean;
begin
  if P1 then APlayer:=1;
  if P2 then APlayer:=2;
  if P3 then APlayer:=3;
  if P4 then APlayer:=4;
  if P1 or P2 or P3 or P4 then AExists:=True else AExists:=False;
  if AExists then begin
    if not(PlayerExists[APLayer]) then Inc(NbrPlayer);
    PlayerExists[APlayer]:=True;
    Score[APLayer]:=0;
  end;
  With Border[Which] do begin
    Exists:=AExists;
    Side:=ASide;
    Player:=APlayer;
    Effect:=0;
    Effect2:=0;
    if Exists then Case Aside of
      Haut:begin
        X:=160;
        Y:=5;
        Lim1:=0;
        Lim2:=109;
      end;
      Bas:begin
        X:=160;
        Y:=195;
        Lim1:=119;
        Lim2:=199;
      end;
      Gauche:begin
        X:=5;
        Y:=100;
        Lim1:=0;
        Lim2:=109;
      end;
      Droite:begin
        X:=315;
        Y:=100;
        Lim1:=189;
        Lim2:=319;
      end;
    end;
  end;
end;

Procedure DrawBall(X,Y:Integer);
var i,j:Byte;
begin
  Dec(X,2);
  Dec(Y,2);
  for i:=0 to 4 do for j:=0 to 4 do Pixel(X+i,Y+j,Sprite[j,i]);
end;



Procedure HandleMenu;
var x,y,k,Compteur:Byte;XCursor:Integer;Players:Array[0..3,0..3] of Boolean;BoutonReleased:Boolean;
Const
  BounceBall:Array[0..18] of ShortInt=(-6,-5,-4,-3,-3,-2,-2,-1,-1,0,1,1,2,2,3,3,4,5,6);

  Procedure DrawCursor(X:Integer);
  var i:Byte;
  begin
    FilledSquare(XCursor,165,XCursor+4,175,0);
    LineHoriz(15,264,170,15);
    for i:=0 to 8 do Move(Cursor[i,0],Buffer^[166+i,X],5);
    XCursor:=X;
  end;

  Procedure DrawCross(x,y,Color:Byte);
  var i:Byte;
  begin;
    for i:=0 to 19 do Pixel(94+x*39+i,40+y*29+i,Color);
    for i:=0 to 19 do Pixel(113+x*39-i,40+y*29+i,Color);
  end;

  Procedure RefreshBottom;
  begin
    DrawCursor(Speed+13);
    OutText(181,155,NewStr(Speed)+'    ');
    Draw(0,155,319,174);
    HideMouse;
    Affiche;
    ShowMouse;
   end;

begin
  for x:=0 to 3 do for y:=0 to 3 do Players[x,y]:=False;
  NbrPlayer:=0;
  Speed:=225;
  OutText(181,155,NewStr(Speed)+'    ');
  DrawCursor(Speed+13);
  AfficheAll;
  InitMouse;
  ChangeCursor(7,7,Seg(ACross),Ofs(ACross));
  PutMouse(20,20);
  BoutonReleased:=True;
  for i:=1 to 4 do PlayerExists[i]:=False;
  BallY:=197 shl 1;
  BallX:=317;
  Compteur:=0;
  Repeat
    if Bouton(1) and BoutonReleased then begin
      BoutonReleased:=False;
      GetPosition;
      if InSquare(84,35,240,151) then begin
        x:=(MouseX-84) div 39;
        y:=(MouseY-35) div 29;
        Players[x,y]:=not(Players[x,y]);
        DrawCross(x,y,Ord(Players[x,y])*15);
        for k:=0 to 3 do if (k<>y) and Players[x,k] then begin
          Players[x,k]:=False;
          DrawCross(x,k,0);
        end;
        HideMouse;
        AfficheAll;
        ShowMouse;
      end;
      if InSquare(15,166,264,174) then begin
        Speed:=(MouseX-15);
        RefreshBottom;
      end;
      if InSquare(4,165,12,175) then begin
        if Speed>0 then Dec(Speed);
        RefreshBottom;
      end;
      if InSquare(268,165,276,175) then begin
        if Speed<250 then Inc(Speed);
        RefreshBottom;
      end;
    end else MouseX:=-1;
    if not Bouton(1) then BoutonReleased:=True;

    if Compteur mod 13=0 then begin
      if BallX=317 then DepX:=-1;
      if BallX=2 then DepX:=1;
      FilledSquare(BallX-2,BallY shr 1-2,BallX+2,BallY shr 1+2,0);
      Inc(BallX,DepX);
      Inc(BallY,BounceBall[Compteur div 13]);
      DrawBall(BallX,BallY shr 1);
      Draw(BallX-3,BallY shr 1-6,BallX+3,BallY shr 1+6);
      HideMouse;
      Affiche;
      ShowMouse;
    end;
    Delay(5);
    Inc(Compteur);
    if Compteur=246 then Compteur:=0;

  Until InSquare(288,161,319,175);
  HideMouse;
  for i:=0 to 3 do InitBorder(i,Players[i,0],Players[i,1],Players[i,2],Players[i,3],Direction(i));
end;

Procedure TakeDir(Player:Byte);
  Procedure Define(AUp,ALeft,ADown,ARight:Boolean);
  begin
    Up:=AUp;
    Down:=ADown;
    Left:=ALeft;
    Right:=ARight;
  end;
begin
  Case Player of
    1:Define(K_Z,K_Q,K_S,K_D);
    2:Define(K_O,K_K,K_L,K_M);
    3:Define(K_Up,K_Left,K_Down,K_Right);
    4:Define(K_8,K_4,K_5,K_6);
  end;
end;

Procedure DegradeHoriz(Y:Integer);
begin
  Move(ColorDegradeHoriz[0],Buffer^[Y,0],320);
end;

Procedure DegradeVertic(X:Integer);
var i:Word;
begin
  for i:=0 to 199 do Pixel(X,i,ColorDegradeVertic[i]);
end;

Procedure RedrawAll;
begin
  ClearScreen(0);
  if Border[3].Exists=False then DegradeVertic(319);
  if Border[2].Exists=False then DegradeHoriz(0);
  if Border[1].Exists=False then DegradeVertic(0);
  if Border[0].Exists=False then DegradeHoriz(199);
  DrawBall(BallX shr 7,BallY shr 7);
end;

Procedure AfficheScore;
var i,k:Byte;
const Coord:Array[0..7] of Byte=(5,5,85,5,5,33,85,33);

  Procedure AffichePlayer(X,Y:Integer;APlayer:Byte);
  var j:Byte;
  begin
    FilledSquare(X,Y,X+26,Y+19,0);
    FilledSquare(X+30,Y+6,X+63,Y+16,0);
    for j:=0 to 3 do if Border[j].Player=APLayer then Case Border[j].Side of
      Haut:FilledSquare(X+2,Y+2,X+24,Y+3,16);
      Bas:FilledSquare(X+2,Y+16,X+24,Y+17,16);
      Gauche:FilledSquare(X+2,Y+2,X+3,Y+17,16);
      Droite:FilledSquare(X+23,Y+2,X+24,Y+17,16);
    end;
    OutText(X+31,Y+8,NewStr(Score[APlayer]));
    Inc(k,2);
  end;

begin
  if NbrPlayer>=2 then begin
    for i:=0 to 57 do Move(Rectangle[i,0],Buffer^[71+i,80],160);
    OutText(135,61,'SCORES');
    k:=0;
    for i:=1 to 4 do if PlayerExists[i] then AffichePlayer(Coord[k]+80,Coord[k+1]+71,i);
  end;
end;

Procedure HandleBorder(Which:Byte);
var i,DistY,DistX:Integer;
  Procedure ToZero(Var X:Integer;Value:Integer);
  begin
    if X>0 then Dec(X,Value);
    if X<0 then Inc(X,Value);
  end;
  Procedure SlowBall;
  begin
    ToZero(DepX,Abs(DepX div 10));
    ToZero(DepY,Abs(DepY div 10));
  end;
  Procedure BounceBallHorizontally;
  begin
    With Border[Which] do begin
      SlowBall;
      DepX:=-DepX;
      Inc(DepY,Effect);
      if Side=Droite then Dec(DepX,Effect2) else Inc(DepX,Effect2);
      if DepY<-256 then DepY:=-256;
      if DepY>256 then DepY:=256;
      if DepX<-256 then DepX:=-256;
      if DepX>256 then DepX:=256;
    end;
  end;

  Procedure BounceBallVertically;
  begin
    With Border[Which] do begin
      SlowBall;
      DepY:=-DepY;
      Inc(DepX,Effect);
      if Side=Bas then Dec(DepY,Effect2) else Inc(DepY,Effect2);
      if DepX<-256 then DepX:=-256;
      if DepX>256 then DepX:=256;
      if DepY<-256 then DepY:=-256;
      if DepY>256 then DepY:=256;
    end;
  end;
begin
  With Border[Which] do begin
    if (Side=Gauche) or (Side=Droite) then begin
      if Exists then begin
        for i:=-10 to 10 do Pixel(X,Y+i,0);
        if Left and (X>Lim1) then begin
          Dec(X);
          if (Side=Droite) and (Effect2<100) then Inc(Effect2,11);
        end;
        if (Side=Droite) and (not(Left) or (X=Lim1)) then Effect2:=0;
        if Right and (X<Lim2) then begin
          Inc(X);
          if (Side=Gauche) and (Effect2<100) then Inc(Effect2,11);
        end;
        if (Side=Gauche) and (not(Right) or (X=Lim2)) then Effect2:=0;
        if Up and (Y>12) then begin
          Dec(Y,2);
          if Effect>0 then Effect:=0;
          if Effect>-100 then Dec(Effect,7);
        end;
        if Y=12 then Dec(Y);
        if Down and (Y<187) then begin
          Inc(Y,2);
          if Effect<0 then Effect:=0;
          if Effect<100 then Inc(Effect,7);
        end;
        if Y=187 then Inc(Y);
        if not(Up or Down) then Effect:=0;
        for i:=-10 to 10 do Pixel(X,Y+i,64+Abs(i));
        Draw(X-1,Y-14,X+1,Y+14);
        Affiche;
        DistY:=(BallY shr 7)-Y;
        DistX:=(BallX shr 7)-X;
        if Abs(DistY)<=12 then begin
          if (DistX<=3) and (DistX>0) and (DepX<=0) then BounceBallHorizontally;
          if (DistX>=-3) and (DistX<0) and (DepX>=0) then BounceBallHorizontally;
        end;
        if (Side=Gauche) and (BallX<0) then begin
          for i:=0 to 3 do if Border[i].Player<>Border[Which].Player then
          Inc(Score[Border[i].Player]);
          FilledSquare(BallX shr 7-2,BallY shr 7-2,BallX shr 7+2,BallY shr 7+2,0);
          BallX:=(X+3) shl 7;
          BallY:=Y shl 7;
          DepX:=128;
          DepY:=0;
          AfficheScore;
          OutText(120,130-Ord(NbrPlayer<2)*50,'YOU LOUZE');
          OutText(30,140-Ord(NbrPlayer<2)*50,'APPUYEZ SUR UNE TOUCHE DE DIRECTION');
          OutText(70,150-Ord(NbrPlayer<2)*50,'POUR RELANCER LA BALLE');
          AfficheAll;
          Delay(750);
          Repeat
            TakeDir(Border[Which].Player);
            if Up then DepY:=-128;
            if Down then DepY:=128;
            if Left then DepX:=-128;
          Until Up or Down or Right or Left;
          ClearScreen(0);
          RedrawAll;
          AfficheAll;
        end;
        if (Side=Droite) and (BallX>319 shl 7) then begin
          for i:=0 to 3 do if Border[i].Player<>Border[Which].Player then
          Inc(Score[Border[i].Player]);
          FilledSquare(BallX shr 7-2,BallY shr 7-2,BallX shr 7+2,BallY shr 7+2,0);
          BallX:=(X-3) shl 7;
          BallY:=Y shl 7;
          DepX:=-128;
          DepY:=0;
          AfficheScore;
          OutText(120,130-Ord(NbrPlayer<2)*50,'YOU LOUZE');
          OutText(30,140-Ord(NbrPlayer<2)*50,'APPUYEZ SUR UNE TOUCHE DE DIRECTION');
          OutText(70,150-Ord(NbrPlayer<2)*50,'POUR RELANCER LA BALLE');
          AfficheAll;
          Delay(750);
          Repeat
            TakeDir(Border[Which].Player);
            if Up then DepY:=-128;
            if Down then DepY:=128;
            if Right then DepX:=128;
          Until Up or Down or Left or Right;
          ClearScreen(0);
          RedrawAll;
          AfficheAll;
        end;
      end else if (Side=Gauche) and (BallX shr 7<6) then begin
        DegradeVertic(0);
        Draw(0,0,2,199);
        Affiche;
        if BallX shr 7<3 then DepX:=-DepX;
      end else if (Side=Droite) and (BallX shr 7>313) then begin
        DegradeVertic(319);
        Draw(317,0,319,199);
        Affiche;
        if BallX shr 7>316 then DepX:=-DepX;
      end;
    end else if (Side=Bas) or (Side=Haut) then begin
      if Exists then begin
        for i:=-10 to 10 do Pixel(X+i,Y,0);
        if Up and (Y>Lim1) then begin
          Dec(Y);
          if (Side=Bas) and (Effect2<100) then Inc(Effect2,11);
        end;
        if (Side=Bas) and (not(Up) or (Y=Lim1)) then Effect2:=0;
        if Down and (Y<Lim2) then begin
          Inc(Y);
          if (Side=Haut) and (Effect2<100) then Inc(Effect2,11);
        end;
        if (Side=Haut) and (not(Down) or (Y=Lim2)) then Effect2:=0;
        if Left and (X>12) then begin
          Dec(X,2);
          if Effect>0 then Effect:=0;
          if Effect>-100 then Dec(Effect,7);
        end;
        if X=12 then Dec(X);
        if Right and (X<307) then begin
          Inc(X,2);
          if Effect<0 then Effect:=0;
          if Effect<100 then Inc(Effect,7);
        end;
        if X=307 then Inc(X);
        if not(Left or Right) then Effect:=0;
        for i:=-10 to 10 do Pixel(X+i,Y,64+Abs(i));
        Draw(X-14,Y-1,X+14,Y+1);
        Affiche;
        DistY:=(BallY shr 7)-Y;
        DistX:=(BallX shr 7)-X;
        if Abs(DistX)<=12 then begin
          if (DistY<=3) and (DistY>0) and (DepY<=0) then BounceBallVertically;
          if (DistY>=-3) and (DistY<0) and (DepY>=0) then BounceBallVertically;
        end;
        if (Side=Haut) and (BallY<0) then begin
          for i:=0 to 3 do if Border[i].Player<>Border[Which].Player then
          Inc(Score[Border[i].Player]);
          FilledSquare(BallX shr 7-2,BallY shr 7-2,BallX shr 7+2,BallY shr 7+2,0);
          BallX:=X shl 7;
          if BallX<385 then BallX:=385;
          if BallX>316 shl 7 then BallX:=316 shl 7;
          BallY:=(Y+3) shl 7;
          DepY:=128;
          DepX:=0;
          AfficheScore;
          OutText(120,130-Ord(NbrPlayer<2)*50,'YOU LOUZE');
          OutText(30,140-Ord(NbrPlayer<2)*50,'APPUYEZ SUR UNE TOUCHE DE DIRECTION');
          OutText(70,150-Ord(NbrPlayer<2)*50,'POUR RELANCER LA BALLE');
          AfficheAll;
          Delay(750);
          Repeat
            TakeDir(Border[Which].Player);
            if Left then DepX:=-128;
            if Right then DepX:=128;
            if Up then DepY:=-128;
          Until Left or Down or Right or Up;
          ClearScreen(0);
          RedrawAll;
          AfficheAll;
        end;
        if (Side=Bas) and (BallY>199 shl 7) then begin
          for i:=0 to 3 do if Border[i].Player<>Border[Which].Player then
          Inc(Score[Border[i].Player]);
          FilledSquare(BallX shr 7-2,BallY shr 7-2,BallX shr 7+2,BallY shr 7+2,0);
          BallX:=X shl 7;
          if BallX<385 then BallX:=385;
          if BallX>316 shl 7 then BallX:=316 shl 7;
          BallY:=(Y-3) shl 7;
          DepY:=-128;
          DepX:=0;
          AfficheScore;
          OutText(120,130-Ord(NbrPlayer<2)*50,'YOU LOUZE');
          OutText(30,140-Ord(NbrPlayer<2)*50,'APPUYEZ SUR UNE TOUCHE DE DIRECTION');
          OutText(70,150-Ord(NbrPlayer<2)*50,'POUR RELANCER LA BALLE');
          AfficheAll;
          Delay(750);
          Repeat
            TakeDir(Border[Which].Player);
            if Left then DepX:=-128;
            if Right then DepX:=128;
            if Down then DepY:=128;
          Until Left or Up or Right or Down;
          ClearScreen(0);
          RedrawAll;
          AfficheAll;
        end;
      end else if (Side=Haut) and (BallY shr 7<6) then begin
        DegradeHoriz(0);
        Draw(0,0,319,2);
        Affiche;
        if BallY shr 7<3 then DepY:=-DepY;
      end else if (Side=Bas) and (BallY shr 7>193) then begin
        DegradeHoriz(199);
        Draw(0,197,319,199);
        Affiche;
        if BallY shr 7>196 then DepY:=-DepY;
      end;
    end;
  end;
end;

{-------------------------------------------------------------------}

Procedure Intro;
var H:Handle;Degrade:Array[0..95,0..2] of Byte;i,j:Byte;ColorPong:Array[0..15,0..2] of Byte;

begin
  MCGasCreen;
  FOPen(H,'Pong.img');
  LoadPalette('Pong.Pal');
  Move(Pal[144,0],Degrade[0,0],288);
  Move(Pal[16,0],ColorPong[0,0],48);
  FillChar(Pal[144,0],288,0);
  DefinePal;
  FRead(H,Buffer^[0,0],64000);
  AfficheAll;
  for i:=0 to 95 do begin
    DefineAColor(Degrade[i,0],Degrade[i,1],Degrade[i,2],i+144);
    Delay(10);
  end;
  While keypressed do Readkey;
  Repeat Delay(1) Until keypressed;
  LoadPalette('Pong.Pal');
  for i:=0 to 63 do begin
    for j:=0 to 15 do if ColorPong[j,0]<63 then begin
      Inc(ColorPong[j,0]);
      Inc(ColorPong[j,1]);
      Inc(ColorPong[j,2]);
    end;
    Move(ColorPong[0,0],Pal[16,0],48);
    DefinePal;
  end;
  for i:=0 to 112 do begin
    for j:=0 to 2 do Pal[127+i,j]:=63;
    for j:=0 to 16 do begin
      if Pal[127+i+j,0]<55 then Inc(Pal[127+i+j,0],4);
      if Pal[127+i+j,1]<55 then Inc(Pal[127+i+j,1],4);
      if Pal[127+i+j,2]<55 then Inc(Pal[127+i+j,2],4);
    end;
    Delay(40);
    DefinePal;
  end;
  FClose(H);
end;

Procedure DirectionRandom;
var Angle:Byte;
begin
  Randomize;
  Angle:=Random(256);
  DepX:=Round(Cos((Angle*Pi)/128)*128);
  DepY:=Round(Sin((Angle*Pi)/128)*128);
end;

begin
{---------------------LE SCROLLING----------------------------------------------}

  InitGraph;
  GetMem(Image,64000);
  LoadImage;
  LoadLetters;
  ShowBkGnd;
  FillChar(Buf,SizeOf(Buf),0);
  StopScrolling:=False;
  SuperScrolling;
  CloseGraph;

  Intro;

{----------------------------LE JEU----------------------------------------}
  ClearScreen(0);
  AfficheAll;
  LoadPalette('Pong.Pal');
  LoadCarac;
  AdvKeyOn;
  EndGame:=False;
  Repeat
    BackToMenu:=False;
    DrawMenu;
    HandleMenu;
    for i:=0 to 319 do ColorDegradeHoriz[i]:=i shr 2+160;
    for i:=0 to 199 do ColorDegradeVertic[i]:=(800+i*2) div 5;
    ClearScreen(0);
    DirectionRandom;
    BallX:=160 shl 7;
    BallY:=100 shl 7;
    RedrawAll;
    AfficheAll;
    Repeat
      FilledSquare(BallX shr 7-2,BallY shr 7-2,BallX shr 7+2,BallY shr 7+2,0);
      Draw(BallX shr 7-2,BallY shr 7-2,BallX shr 7+2,BallY shr 7+2);
      Inc(BallX,DepX);
      Inc(BallY,DepY);
      DrawBall(BallX shr 7,BallY shr 7);
      Draw(BallX shr 7-2,BallY shr 7-2,BallX shr 7+2,BallY shr 7+2);
      Affiche;
      for i:=0 to 3 do begin
        if Border[i].Exists then TakeDir(Border[i].Player);
        HandleBorder(i);
      end;
      Delay(250-Speed);
      if K_Esc then begin
        AfficheScore;
        OutText(80,131-Ord(NbrPlayer<2)*40,'F1 POUR QUITTER');
        OutText(80,141-Ord(NbrPlayer<2)*40,'F2 POUR RETOURNER AU MENU');
        OutText(80,151-Ord(NbrPlayer<2)*40,'ESPACE POUR CONTINUER');
        AfficheAll;
        Repeat
          if K_F1 then EndGame:=True;
          if K_F2 then BackToMenu:=True;
        Until EndGame or K_Space or BackToMenu;
        RedrawAll;
        AfficheAll;
      end;
    Until EndGame or BackToMenu;
  Until EndGame;
  CloseScreen;
  AdvKeyOff;
end.