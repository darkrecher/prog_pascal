Uses Mcgagraf,Crt,DosFile;

Const

  XPanel=280;
  YScore=20;
  YTriangle=42;

  XCenter=86;
  YCenter=100;
  XNext=197;
  YNext=22;
  XSpeed=198;
  YSpeed1=109;
  YSpeed2=116;

  HiScoreX=84;
  HiScoreY=70;
  HiScoreNameX=94;
  HiScoreNameY=118;

  {coordonn‚es pour afficher le tabeau des scores}
  XScoreHisto=184;
  XScoreHisto2=311;
  YScoreHisto=149;
  XBlocks=203;
  XScore1=236;
  XMul=242;
  XChainR=269;
  XEqual=275;
  XScore2=298;
  ScoreLineSizeY=10;

  {variables qui donnent la configuration}
  Hauteur:Byte=10;
  Largeur:Byte=5;
  MaxColor:Byte=3;
  Speed:Byte=80;{hum... en fait, ‡a devrait pas s'appeler Speed, mais "ralentissement"}
  NbrOfTriToAttach:Byte=3;
  TriImage:Byte=2;

  NbrLineScore=4;

  NameSize=15; {nombre maximal de caractŠres pour le nom dans les hiscorze}
  Authorized=['A'..'Z','0'..'9','''',',',' ','?',';','.',':','!'];

  Vide=128;
  Plein=255;
  TriUpLeft=0;
  TriUpRight=1;
  TriDownRight=2;
  TriDownLeft=3;

  Vertical=False;
  Horizontal=True;
  Left=False;
  Right=True;

Type
  TSquare=Array[0..3] of Byte;
  TSquareBoolean=Array[0..3] of Boolean;
  TabloDeBoolean=Array[0..12,0..17] of TSquareBoolean;
  TPiece=Array[0..2] of TSquare;
  Ordonnees=Array[0..17] of Byte;
  TLineScore=Record
    Blocks,Score1,Score2,Chainr:Word;
    Exists:Boolean;
  end;
  THiScore=Record
    Name:string[NameSize];
    Value:Word;
  end;
  PScoreImg=^TScoreImg;
  TScoreImg=Array[0..68,0..138] of Byte;
  Caracs=Set of Char;

var
  {variables qui contiennent des donn‚es}
  Tablo:Array[0..12,0..17] of TSquare;
  Next,Current:TPiece;
  XTablo,YTablo,XCurrent,YCurrent,SizeNext,SizeCurrent:Integer;
  ScoreHisto:Array[0..NbrLineScore-1] of TLineScore;
  SpeedInc,Score,TriDestroyed:Word;
  HiScore:Array[0..5] of THiScore;

  {variable qui contiennent des images}
  IntroImg,GameImg,Menu,Menu2:PScreen;
  DiagSlash,DiagAntiSlash:Array[0..2,0..10,0..15,0..15] of Byte;
  HiScoreImg:PScoreImg;

Function NewStr(X:Word):string;
var S:string;
begin
  Str(X,S);
  NewStr:=S;
end;

{-----------------Proc‚dures de loadation des images-------------------------}

Procedure TestFilePresence;
var Good:Boolean;

  Function Exists(FileName:string):Boolean;
  var H:Handle;
  begin
    if FOpen(H,FileName) then begin
      FClose(H);
      Exists:=True;
    end else begin
      WriteLn('impossible de trouver le fichier ',FileName);
      Exists:=False;
    end;
  end;

begin
  Good:=Exists('triangl.dat');
  Good:=Exists('triangl.sco') and Good;
  Good:=Exists('mcgachar') and Good;
  if not(Good) then Halt;
end;

Procedure Decompress(Fichier:Handle;Dest:PScreen);
type
  PBlock=^TBlock;
  TBlock=Array[0..32767] of Byte;

var BLockSize:LongInt;ScreenPos,BlockPos:Word;PieceLength,i,Value:Byte;
Block:PBLock;

  Function GetOneByte:Byte;
  begin
    if BlockPos=32768 then begin
      if BlockSize<32768 then FRead(Fichier,Block^[0],BlockSize) else begin
        FRead(Fichier,Block^[0],32768);
        Dec(BlockSize,32768);
      end;
      BlockPos:=0;
    end;
    GetOneByte:=Block^[BlockPos];
    Inc(BlockPos);
  end;

begin
  ScreenPos:=0;
  FRead(Fichier,BlockSize,4);
  New(Block);
  BlockPos:=32768;
  repeat
    PieceLength:=GetOneByte;
    if PieceLength>128 then begin
      Value:=GetOneByte;
      for i:=0 to 256-PieceLength do Dest^[(ScreenPos+i) div 320,(ScreenPos+i) mod 320]:=Value;
      Inc(ScreenPos,257-PieceLength);
    end else for i:=0 to PieceLength do begin
      Dest^[(ScreenPos) div 320,(ScreenPos) mod 320]:=GetOneByte;
      Inc(ScreenPos,1);
    end;
  Until ScreenPos=64000;
  Dispose(Block);
  Write('Û');
end;

Procedure TakeSprite;
var H:Handle;Buf:PScreen;X,Y,Color,TriType,i,j,k,l:Byte;
begin
  FOpen(H,'Triangl.dat');
  New(Buf);
  Decompress(H,Buf);
  for Color:=0 to 10 do for TriType:=0 to 2
  do for Y:=0 to 15 do Move(Buf^[Color*16+Y,TriType*16],DiagAntiSlash[TriType,Color,Y,0],16);
  for l:=0 to 2 do for i:=0 to 15 do for j:=0 to 10
  do for k:=0 to 15 do DiagSlash[l,j,i,k]:=DiagAntiSlash[l,j,i,15-k];
  New(HiScoreImg);
  for i:=0 to 68 do Move(Buf^[i,48],HiScoreImg^[i,0],139);
  Dispose(Buf);
  New(Menu);
  New(Menu2);
  New(GameImg);
  New(IntroImg);
  Decompress(H,IntroImg);
  Decompress(H,Menu);
  Decompress(H,Menu2);
  Decompress(H,GameImg);
  FRead(H,Pal[0,0],768);
  FClose(H);
end;

{------------------------ Procedures pour l'affichage -----------------------}

Procedure RedrawImage(x1,y1,x2,y2:Integer;Image:PSCreen);
var i:Integer;
begin
  for i:=y1 to y2 do Move(Image^[i,x1],Buffer^[i,x1],x2-x1+1);
end;

Procedure Triangle(X,Y:Integer;WhichSort,Color:Byte);
var i:Byte;
begin
  Dec(Color);
  Case WhichSort of
    TriUpLeft:for i:=0 to 14 do Move(DiagSlash[TriImage,Color,i,0],Buffer^[Y+i,X],15-i);
    TriUpRight:for i:=0 to 14 do Move(DiagAntiSlash[TriImage,Color,i,i],Buffer^[Y+i,X+i+1],15-i);
    TriDownRight:for i:=0 to 15 do Move(DiagSlash[TriImage,Color,i,15-i],Buffer^[Y+i,X+15-i],i+1);
    TriDownLeft:for i:=0 to 15 do Move(DiagAntiSlash[TriImage,Color,i,0],Buffer^[Y+i,X],i+1);
  end;
end;

Procedure TriangleUni(X,Y:Integer;WhichSort,Color:Byte);
var i:Byte;
begin
  Dec(Color);
  Case WhichSort of
    TriUpLeft:for i:=0 to 14 do LineHoriz(X,X+14-i,Y+i,Color);
    TriUpRight:for i:=0 to 14 do LineHoriz(X+i+1,X+15,Y+i,Color);
    TriDownRight:for i:=0 to 15 do LineHoriz(X+15-i,X+15,Y+i,Color);
    TriDownLeft:for i:=0 to 15 do LineHoriz(X,X+i,Y+i,Color);
  end;
end;

Procedure DrawSquare(X,Y:Integer;S:TSquare);
var i:Byte;
begin
  for i:=0 to 3 do if S[i]<>0 then Triangle(X,Y,i,S[i]);
end;

Procedure DisplayTablo(X1,Y1,X2,Y2:Byte);
var i,j:Integer;
begin
  if (Y1<=Hauteur-1) and (Y2<=Hauteur-1) and (X1<=Largeur-1) and (X2<=Largeur-1) then
    for i:=X1 to X2 do for j:=Y1 to Y2 do DrawSquare(XTablo+i*16,YTablo+j*16,Tablo[j,i]);
end;

Procedure DrawPiece(X,Y:Integer;Piece:TPiece;Size:Byte);
var i:Byte;
begin
  for i:=0 to Size-1 do DrawSquare(X,Y+i*16,Piece[i]);
end;

Procedure Redraw;
begin
  FilledSquare(XTablo,YTablo,XTablo+Largeur*16-1,YTablo+Hauteur*16-1,0);
  DisplayTablo(0,0,Largeur-1,Hauteur-1);
  DrawPiece(XTablo+XCurrent*16,YTablo+YCurrent*16,Current,SizeCurrent);
  Draw(XTablo,YTablo,XTablo+Largeur*16-1,YTablo+Hauteur*16-1);
  Affiche;
end;

Procedure AfficheScore;

  Procedure AfficheCenteredText(Y:Integer;Text:string);
  begin
    RedrawImage(XPanel-25,Y,XPanel+25,Y+8,GameImg);
    TranspText(XPanel-TextLength(Text) div 2,Y,Text,95,105,True);
    Draw(XPanel-25,Y,XPanel+25,Y+8);
    Affiche;
  end;

begin
  AfficheCenteredText(YScore,NewStr(Score));
  AfficheCenteredText(YTriangle,NewStr(TriDestroyed));
end;

Procedure ShowSpeed;
begin
  FilledSquare(XSpeed,YSpeed1,XSpeed+100-Speed,YSpeed2,241-(100-Speed) div 10);
  Draw(XSpeed,YSpeed1,XSpeed+100-Speed,YSpeed2);
  Affiche;
end;

{---------------- Procedures pour les trucs que peut faire le joueur --------}

Function WhatIsIn(X:TSquare):Byte;
var Sum:Integer;i:Byte;
begin
  Sum:=Ord(X[0]<>0)+Ord(X[1]<>0)+Ord(X[2]<>0)+Ord(X[3]<>0);
  if Sum=0 then WhatIsIn:=Vide else if Sum=2 then WhatIsIn:=Plein else for i:=0 to 3 do if X[i]<>0 then WhatIsIn:=i;
end;

Procedure MoveSquare(Source:TSquare;var Dest:TSquare);
begin
  Dest[0]:=Source[0];
  Dest[1]:=Source[1];
  Dest[2]:=Source[2];
  Dest[3]:=Source[3];
end;

Procedure Add(Source:TSquare;var Dest:TSquare);
begin
  Inc(Dest[0],Source[0]);
  Inc(Dest[1],Source[1]);
  Inc(Dest[2],Source[2]);
  Inc(Dest[3],Source[3]);
end;

Function DoesItFit(X1,X2:TSquare;Position:Boolean):Boolean;
var ContentsOfX1,ContentsOfX2:Byte;
begin
  ContentsOfX1:=WhatIsIn(X1);
  ContentsOfX2:=WhatIsIn(X2);
  if (ContentsOfX1=Vide) or (ContentsOfX2=Vide) then begin
    DoesItFit:=True;
    Exit;
  end else if (ContentsOfX1=Plein) or (ContentsOfX2=Plein) then begin
    DoesItFit:=False;
    Exit;
  end else begin
    if Position=Vertical then
    {X1 est la case du dessus, X2 celle du dessous}
      if ((ContentsOfX1=TriUpLeft) and (ContentsOfX2=TriDownRight))
      or ((ContentsOfX1=TriUpRight) and (ContentsOfX2=TriDownLeft))
      then DoesItFit:=True else DoesItFit:=False;
    if Position=Horizontal then
    {X1 est la case de gauche, X2 celle de droite}
      if ((ContentsOfX1=TriUpLeft) and (ContentsOfX2=TriDownRight))
      or ((ContentsOfX1=TriDownLeft) and (ContentsOfX2=TriUpRight))
      then DoesItFit:=True else DoesItFit:=False;
  end;
end;

Function CanIGoDown:Boolean;
begin
  CanIGoDown:=(YCurrent+SizeCurrent<Hauteur) and
  DoesItFit(Current[SizeCurrent-1],Tablo[YCurrent+SizeCurrent,XCurrent],Vertical)
  and (WhatIsIn(Tablo[YCurrent+SizeCurrent-1,XCurrent])=Vide);
end;

Function MoveHorizontal(Direction:Boolean):Boolean;
var i:Byte;Test:Boolean;
begin
  if Direction=Left then begin
    Test:=XCurrent>0;
    {pour chaque carr‚, il faut tester si il peut aller … gauche}
    {mais aussi si il peut revenir vers la droite une fois qu'il a boug‚}
    for i:=0 to SizeCurrent-1 do Test:=Test and DoesItFit(Tablo[YCurrent+i,XCurrent-1],Current[i],Horizontal)
    and DoesItFit(Current[i],Tablo[YCurrent+i,XCurrent],Horizontal);{ ® c'est le test du retour vers la droite}
  end else begin
    Test:=XCurrent<Largeur-1;
    for i:=0 to SizeCurrent-1 do Test:=Test and DoesItFit(Current[i],Tablo[YCurrent+i,XCurrent+1],Horizontal)
    and DoesItFit(Tablo[YCurrent+i,XCurrent],Current[i],Horizontal);
  end;
  MoveHorizontal:=Test;
end;

Function TryToTurn(X1,X2:TSquare):Boolean;
begin
  TryToTurn:=(WhatIsIn(X1)=Vide) or (WhatIsIn(X2)=Vide);
end;

Function ICanTurn:Boolean;
var Result:Boolean;i:Byte;
begin
  Result:=True;
  for i:=0 to SizeCurrent-1 do Result:=Result and TryToTurn(Current[i],Tablo[YCurrent+i,XCurrent]);
  ICanTurn:=Result;
end;

Procedure Rotate(var X:TSquare);
var Buf:Byte;
begin
  Buf:=X[0];
  X[0]:=X[1];
  X[1]:=Buf;
  Buf:=X[2];
  X[2]:=X[3];
  X[3]:=Buf;
end;

Procedure CycleColor(var X:TPiece);
var Buf,Square0,Square1:Byte;
begin
  Square0:=WhatIsIn(X[0]);
  if Square0=Plein then begin
    Buf:=X[0][0];
    X[0][0]:=X[0][2];
    X[0][2]:=Buf;
    Buf:=X[0][1];
    X[0][1]:=X[0][3];
    X[0][3]:=Buf;
  end else begin
    Square1:=WhatIsIn(X[1]);
    Buf:=X[0][Square0];
    X[0][Square0]:=X[1][Square1];
    X[1][Square1]:=Buf;
  end;
end;

var
  EndGame:Boolean;

Procedure Wait;
var Compteur:Integer;i:Byte;C:Char;
begin
  Compteur:=Speed*10;
  While keypressed do Readkey;
  Repeat
    Delay(1);
    Dec(Compteur);
    C:=' ';
    if keypressed then C:=Readkey;
    if C=#0 then C:=Readkey;
    if C=#75 then if MoveHorizontal(Left) then begin
      Dec(XCurrent);
      Redraw;
    end;
    if C=#77 then if MoveHorizontal(Right) then begin
      Inc(XCurrent);
      Redraw;
    end;
    if (C=#27) or (C=#80) then begin
      Compteur:=0;
      if C=#27 then EndGame:=True;
    end;
    if C='n' then begin
      if ICanTurn then for i:=0 to SizeCurrent-1 do Rotate(Current[i]);
      Redraw;
    end;
    if C='b' then begin
      CycleColor(Current);
      Redraw;
    end;
  Until Compteur=0;
end;

{- Procedures pour g‚rer ce qui se passe quand une piece vient d'ˆtre pos‚e -}

Procedure NextPiece;
var Which,i,j:Byte;
Const
  NbrPiece=8;
  PieceType:Array[0..NbrPiece-1,0..2,0..3] of Boolean=
  ( ((False,False,False,True),(True,False,False,False),(False,False,False,False)),
    ((False,False,True,False),(False,True,False,False),(False,False,False,False)),
    ((True,False,False,False),(False,False,False,True),(False,False,False,False)),
    ((False,True,False,False),(False,False,True,False),(False,False,False,False)),
    ((False,False,True,False),(True,False,False,False),(False,False,False,False)),
    ((False,False,False,True),(False,True,False,False),(False,False,False,False)),
    ((False,True,False,True),(False,False,False,False),(False,False,False,False)),
    ((True,False,True,False),(False,False,False,False),(False,False,False,False))
  );
  Sizes:Array[0..NbrPiece-1] of Byte=(2,2,2,2,2,2,1,1);
begin
  Which:=Random(NbrPiece);
  for i:=0 to 2 do for j:=0 to 3 do Next[i][j]:=0;
  for i:=0 to 2 do for j:=0 to 3 do if PieceType[Which,i,j] then Next[i][j]:=Random(MaxColor)+1;
  SizeNext:=Sizes[Which];
  RedrawImage(XNext,YNext,XNext+15,YNext+47,GameImg);
  DrawPiece(XNext,YNext,Next,SizeNext);
  Draw(XNext,YNext,XNext+15,YNext+47);
  Affiche;
end;

Function NewPiece:Boolean;
var i:Byte;Continue:Boolean;
begin
  Continue:=True;
  for i:=0 to SizeNext-1 do Continue:=Continue and DoesItFit(Next[i],Tablo[i,Largeur div 2],Vertical);
  if Continue then begin
    for i:=0 to SizeNext-1 do MoveSquare(Next[i],Current[i]);
    SizeCurrent:=SizeNext;
    XCurrent:=Largeur div 2;
    YCurrent:=0;
  end;
  NewPiece:=Continue;
end;

Procedure InitBoolean(var X:TabloDeBoolean);
var i,j,k:Byte;
begin
  for i:=0 to Hauteur-1 do for j:=0 to Largeur-1 do for k:=0 to 3 do X[i,j][k]:=False;
end;

Procedure AddBoolean(Source:TabloDeBoolean;var Dest:TabloDeBoolean);
var i,j,k:Byte;
begin
  for i:=0 to Hauteur-1 do for j:=0 to Largeur-1 do for k:=0 to 3 do Dest[i,j][k]:=Dest[i,j][k] or Source[i,j][k];
end;

Function TestOne(X,Y,Triangle:Byte;var Tested,Attached:TabloDeBoolean;var BlockDest:Word):Boolean;
var Compteur:Integer;Color:Byte;
Const
  Adjacent:Array[0..3,0..2] of ShortInt=(
  (2,-1,-1),
  (3,+1,-1),
  (0,+1,+1),
  (1,-1,+1));

  Procedure Attach(X,Y,Triangle:Byte);
  begin
    if not(Tested[Y,X][Triangle]) then begin
      Inc(Compteur);
      Tested[Y,X][Triangle]:=True;
      Attached[Y,X][Triangle]:=True;
      if Tablo[Y,X][Adjacent[Triangle,0]]=Color then Attach(X,Y,Adjacent[Triangle,0]);
      if (Adjacent[Triangle,1]=-1) and (X>0) then begin
        if Tablo[Y,X-1][1]=Color then Attach(X-1,Y,1);
        if Tablo[Y,X-1][2]=Color then Attach(X-1,Y,2);
      end;
      if (Adjacent[Triangle,1]=+1) and (X<Largeur-1) then begin
        if Tablo[Y,X+1][0]=Color then Attach(X+1,Y,0);
        if Tablo[Y,X+1][3]=Color then Attach(X+1,Y,3);
      end;
      if (Adjacent[Triangle,2]=-1) and (Y>0) then begin
        if Tablo[Y-1,X][2]=Color then Attach(X,Y-1,2);
        if Tablo[Y-1,X][3]=Color then Attach(X,Y-1,3);
      end;
      if (Adjacent[Triangle,2]=+1) and (Y<Hauteur-1) then begin
        if Tablo[Y+1,X][0]=Color then Attach(X,Y+1,0);
        if Tablo[Y+1,X][1]=Color then Attach(X,Y+1,1);
      end;
    end;
  end;

begin
  Color:=Tablo[Y,X][Triangle];
  Compteur:=0;
  if Color<>0 then Attach(X,Y,Triangle);
  if Compteur>=NbrOfTriToAttach then begin
    TestOne:=True;
    Inc(BlockDest,Compteur);
  end else TestOne:=False;
end;

Function TestAll(ToTest:TabloDeBoolean;var ToDestroy:TabloDeBoolean;var BlockDest:Word):Boolean;
var i,j,k:Byte;Tested,Attached:TabloDeBoolean;Zog1,Zog2:Boolean;
begin
  BlockDest:=0;
  InitBoolean(Tested);
  InitBoolean(Attached);
  InitBoolean(ToDestroy);
  Zog2:=False;
  for i:=0 to Hauteur-1 do for j:=0 to Largeur-1 do for k:=0 to 3 do if ToTest[i,j][k] then begin
    Zog1:=TestOne(j,i,k,Tested,Attached,BlockDest);
    if Zog1 then begin
      AddBoolean(Attached,ToDestroy);
      Zog2:=True;
    end;
    InitBoolean(Attached);
  end;
  TestAll:=Zog2;
end;

Procedure DrawSomeLightSquare(X,Y:Integer;ToDraw:TSquare;BSquare:TSquareBoolean);
var i:Byte;
begin
  for i:=0 to 3 do if (ToDraw[i]<>0) then if BSquare[i] then TriangleUni(X,Y,i,ToDraw[i]+1)
  else Triangle(X,Y,i,ToDraw[i]);
end;

Procedure BlinkBlink(var Blink:TabloDeBoolean);
const BlinkSpeed=50;
var i,j,k:Byte;
begin
  for k:=0 to 2 do begin
    FilledSquare(XTablo,YTablo,XTablo+Largeur*16-1,YTablo+Hauteur*16-1,0);
    for i:=0 to Largeur-1 do for j:=0 to Hauteur-1 do
      DrawSomeLightSquare(XTablo+i*16,YTablo+j*16,Tablo[j,i],Blink[j,i]);
    Draw(XTablo,YTablo,XTablo+Largeur*16-1,YTablo+Hauteur*16-1);
    Affiche;
    Delay(BlinkSpeed);
    Redraw;
    Delay(BlinkSpeed);
  end;
end;

Procedure RemoveTri(ToRemove:TabloDeBoolean);
var i,j,k:Byte;
begin
  for i:=0 to Hauteur-1 do for j:=0 to Largeur-1 do for k:=0 to 3 do
  if ToRemove[i,j][k] then Tablo[i,j][k]:=0;
end;

Procedure SquareToBool(Source:TSquare;var Dest:TSquareBoolean);
var i:Byte;
begin
  for i:=0 to 3 do Dest[i]:=Source[i]<>0;
end;

Function WhatFalls(var LimUp,LimDown:Ordonnees):Boolean;
var i,j,k:Byte;Result:Boolean;
begin
  Result:=False;
  for i:=0 to Largeur-1 do begin
    j:=Hauteur-1;
    While (j>0) and not(DoesItFit(Tablo[j-1,i],Tablo[j,i],Vertical)) do Dec(j);
    if j<>0 then LimDown[i]:=j-1 else LimDown[i]:=255;
  end;
  for i:=0 to Largeur-1 do if LimDown[i]<>255 then begin
    k:=LimDown[i];
    for j:=LimDown[i] downto 0 do if WhatIsIn(Tablo[j,i])<>Vide then k:=j;
    if (k<>LimDown[i]) or (WhatIsIn(Tablo[k,i])<>Vide) then begin
      LimUp[i]:=k;
      Result:=True;
    end else LimDown[i]:=255;
  end;
  WhatFalls:=Result;
end;

Procedure SmoothFall(LimUp,LimDown:Ordonnees);
const FallSpeed=10;
var i,j,k:Byte;
begin
  for k:=1 to 16 do begin
    for i:=0 to Largeur-1 do if LimDown[i]<>255 then begin
      FilledSquare(XTablo+i*16,YTablo+LimUp[i]*16,XTablo+i*16+15,YTablo+LimDown[i]*16+31,0);
      for j:=LimUp[i] to LimDown[i] do DrawSquare(XTablo+i*16,YTablo+j*16+k,Tablo[j,i]);
      DrawSquare(XTablo+i*16,YTablo+LimDown[i]*16+16,Tablo[LimDown[i]+1,i]);
      Draw(XTablo+i*16,YTablo+LimUp[i]*16,XTablo+i*16+15,YTablo+LimDown[i]*16+31);
    end;
    Affiche;
    Delay(FallSpeed);
  end;
  for i:=0 to Largeur-1 do if LimDown[i]<>255 then begin
    Add(Tablo[LimDown[i],i],Tablo[LimDown[i]+1,i]);
    for j:=LimDown[i] downto LimUp[i]+1 do MoveSquare(Tablo[j-1,i],Tablo[j,i]);
    for k:=0 to 3 do Tablo[LimUp[i],i][k]:=0;
  end;
  Redraw;
end;

{--------Proc‚dures de g‚ration du tableau de scores en bas … droite---------}

Procedure DisplayScoreHisto;
var i:Byte;

  Procedure DrawLineScore(Y:Integer;LineScore:TLineScore;Color1,Color2:Byte);
  begin
    RedrawImage(XScoreHisto,Y,XScoreHisto2,Y+8,GameImg);
    if LineScore.Exists then With LineScore do begin
      TranspText(XBlocks-TextLength(NewStr(Blocks)),Y,NewStr(Blocks),Color1,Color2,True);
      TranspText(XScore1-TextLength(NewStr(Score1)),Y,NewStr(Score1),Color1,Color2,True);
      TranspText(XChainR-TextLength(NewStr(Chainr)),Y,NewStr(ChainR),Color1,Color2,True);
      TranspText(XScore2-TextLength(NewStr(Score2)) div 2,Y,NewStr(Score2),Color1,Color2,True);
      TranspText(XMul,Y,'X',Color1,Color2,True);
      TranspText(XEqual,Y,'=',Color1,Color2,True);
    end;
  end;

begin
  DrawLineScore(YScoreHisto+(NbrLineScore-1)*ScoreLineSizeY,ScoreHisto[NbrLineScore-1],32,41);
  for i:=0 to NbrLineScore-2 do
  DrawLineScore(YScoreHisto+i*ScoreLineSizeY,ScoreHisto[i],95,105);
  Draw(XScoreHisto,YScoreHisto,XScoreHisto2,YScoreHisto+NbrLineScore*ScoreLineSizeY);
  Affiche;
end;

Procedure ClearScoreHisto;
var i:Integer;
begin
  for i:=0 to NbrLineScore-1 do ScoreHisto[i].Exists:=False;
end;

Procedure AddLineScore(BlockDest,ChainReac:Word);
var Buf:Word;i:Byte;

  Procedure TakeTheLineDown(Which:Byte);
  begin
    if ScoreHisto[Which+1].Exists then begin
      ScoreHisto[Which].Exists:=True;
      ScoreHisto[Which].Blocks:=ScoreHisto[Which+1].Blocks;
      ScoreHisto[Which].Score1:=ScoreHisto[Which+1].Score1;
      ScoreHisto[Which].ChainR:=ScoreHisto[Which+1].ChainR;
      ScoreHisto[Which].Score2:=ScoreHisto[Which+1].Score2;
    end else ScoreHisto[Which].Exists:=False;
  end;

begin
  for i:=0 to NbrLineScore-2 do TakeTheLineDown(i);
  With ScoreHisto[NbrLineScore-1] do begin
    Exists:=True;
    Blocks:=BlockDest;
    ChainR:=ChainReac;
    Buf:=0;
    for i:=0 to Blocks-1 do Inc(Buf,i+1);
    Score1:=Buf;
    Score2:=Buf*ChainR;
    Inc(Score,Score2);
    Inc(TriDestroyed,BlockDest);
    Inc(SpeedInc,BlockDest);
    While (SpeedInc>5) and (Speed>1) do begin
      Dec(SpeedInc,5);
      Dec(Speed);
    end;
  end;
end;

{la proc‚dure qui fait tout ce qu'y a … faire une fois que la piece est pos‚e}

Procedure SetBlockAndDestroy;
var i,j:Integer;ToTest,ToDestroy:TabloDeBoolean;Continue,Falling:Boolean;LimUp,LimDown:Ordonnees;
BlockDest,ChainReac:Word;
begin
  ChainReac:=0;
  DisplayScoreHisto;
  for i:=0 to SizeCurrent-1 do Add(Current[i],Tablo[YCurrent+i,XCurrent]);
  InitBoolean(ToTest);
  for i:=0 to SizeCurrent-1 do SquareToBool(Current[i],ToTest[YCurrent+i,XCurrent]);
  for i:=0 to SizeCurrent-1 do for j:=0 to 3 do Current[i][j]:=0;
  Continue:=TestAll(ToTest,ToDestroy,BlockDest);
  if Continue then begin
    Repeat
      Inc(ChainReac);
      BlinkBlink(ToDestroy);
      RemoveTri(ToDestroy);
      Redraw;
      AddLineScore(BlockDest,ChainReac);
      DisplayScoreHisto;
      AfficheScore;
      ShowSpeed;
      Continue:=WhatFalls(LimUp,LimDown);
      if Continue then begin
        Repeat
          SmoothFall(LimUp,LimDown);
          Falling:=WhatFalls(LimUp,LimDown);
        Until not(Falling);
        InitBoolean(ToTest);
        for i:=0 to Largeur-1 do for j:=0 to Hauteur-1 do SquareToBool(Tablo[j,i],ToTest[j,i]);
        Continue:=TestAll(ToTest,ToDestroy,BlockDest);
      end;
    Until not(Continue);
  end;
end;

{----------------Proc‚dures de g‚ration des high scorze----------------------}

Procedure TakeScore;
var i:Byte;H:Handle;
begin
  FOpen(H,'Triangl.sco');
  for i:=0 to 5 do begin
    HiScore[i].Name[0]:=Chr(NameSize);
    FRead(H,HiScore[i].Name[1],NameSize);
    FRead(H,HiScore[i].Value,2);
  end;
  FClose(H);
end;

Function CalculPos:Byte;
var Rank:Byte;
begin
  Rank:=6;
  While (HiScore[Rank-1].Value<Score) and (Rank>0) do Dec(Rank);
  if Rank<>6 then CalculPos:=Rank else CalculPos:=255;
end;

Procedure AddHiScore(Rank:Byte;NewName:String;NewValue:Word);
var i:Integer;
begin
  if Rank<5 then for i:=5 downto Rank+1 do begin
    HiScore[i].Name:=HiScore[i-1].Name;
    HiScore[i].Value:=HiScore[i-1].Value;
  end;
  HiScore[Rank].Name:=NewName;
  HiScore[Rank].Value:=NewValue;
end;

Function AskName:string;
var Answer:string;i:Byte;

  Procedure AfficheScoreImg(X1,Y1,X2,Y2:Integer);
  var i:Integer;
  begin
    for i:=Y1 to Y2 do Move(HiScoreImg^[i-HiScoreY,X1-HiScoreX],Buffer^[i,X1],X2-X1+1);
  end;

  function NewRead(X,Y,LMax:Integer;Writable:Caracs;Color1,Color2:Byte;Aliaz:Boolean):String;
  var s:string;c:char;Quit:Boolean;
  begin
    s:='';
    Quit:=False;
    Repeat
      if keypressed then begin
        AfficheScoreImg(X,Y,X+TextLength(S),Y+8);
        Draw(X,Y,X+TextLength(S),Y+8);
        c:=Readkey;
        Case C of
          #0:Readkey;
          #8:if Length(s)>0 then dec(s[0]);
          #13:Quit:=True;
          #27:Quit:=True;
        else if (UpCase(C) in Writable) and (Length(S)<LMax) then S:=S+UpCase(C);
        end;
        TranspText(X,Y,S,Color1,Color2,Aliaz);
        Draw(X,Y,X+TextLength(S),Y+8);
        Affiche;
      end;
    until Quit;
    NewRead:=s;
  end;

begin
  AfficheScoreImg(HiScoreX,HiScoreY,HiScoreX+138,HiScoreY+68);
  AfficheAll;
  Answer:=NewRead(HiScoreNameX,HiScoreNameY,NameSize,Authorized,18,23,True);
  for i:=Length(Answer) to NameSize-1 do Answer:=Answer+' ';
  Answer[0]:=Chr(NameSize);
  AskName:=Answer;
end;

Procedure WriteHiScore;
var i:Byte;H:Handle;
begin
  FOpen(H,'Triangl.sco');
  for i:=0 to 5 do begin
    FWrite(H,HiScore[i].Name[1],NameSize);
    FWrite(H,HiScore[i].Value,2);
  end;
  FClose(H);
end;

{-------------Proc‚dures de d‚but et de fin----------------------------------}

Procedure Intro;
begin
  While keypressed do Readkey;
  RedrawImage(0,0,319,199,IntroImg);
  AfficheAll;
  Readkey;
  Dispose(IntroImg);
end;

Procedure Init;
var i,j,k:Integer;
begin
  XTablo:=XCenter-Largeur*8;
  YTablo:=YCenter-Hauteur*8;
  RedrawImage(0,0,319,199,GameImg);
  for i:=0 to Largeur-1 do for j:=0 to Hauteur-1 do for k:=0 to 3 do Tablo[j,i][k]:=0;
  ClearScoreHisto;
  Score:=0;
  TriDestroyed:=0;
  SpeedInc:=0;
  NextPiece;
  NewPiece;
  NextPiece;
  Redraw;
  AfficheScore;
  ShowSpeed;
  LineVertic(XTablo-2,YTablo-1,YTablo+Hauteur*16,27);
  LineVertic(XTablo-1,YTablo,YTablo+Hauteur*16-1,28);
  LineVertic(XTablo+Largeur*16,YTablo,YTablo+Hauteur*16-1,18);
  LineVertic(XTablo+1+Largeur*16,YTablo-1,YTablo+Hauteur*16,21);
  LineHoriz(XTablo-1,XTablo+Largeur*16,YTablo-2,27);
  LineHoriz(XTablo,XTablo+Largeur*16-1,YTablo-1,28);
  LineHoriz(XTablo,XTablo+Largeur*16-1,YTablo+Hauteur*16,18);
  LineHoriz(XTablo-1,XTablo+Largeur*16,YTablo+Hauteur*16+1,21);
  Pixel(XTablo-2,YTablo-2,29);
  Pixel(XTablo-1,YTablo-1,31);
  Pixel(XTablo+Largeur*16,YTablo+Hauteur*16,16);
  Pixel(XTablo+Largeur*16+1,YTablo+1+Hauteur*16,19);
  LineHoriz(XCenter-2,XCenter,YTablo-3,28);
  AfficheAll;
end;

Procedure YouLose;
begin
  FilledSquare(XTablo,YTablo,XTablo+Largeur*16-1,YTablo+Hauteur*16-1,0);
  TranspText(XCenter-TextLength('YOU') div 2,YCenter-5,'YOU',32,44,True);
  TranspText(XCenter-TextLength('LOUZE!!') div 2,YCenter+5,'LOUZE!!',32,44,True);
  AfficheAll;
  Delay(1000);
  While keypressed do Readkey;
  Readkey;
end;

Procedure ExitGame;
begin
  Dispose(Menu);
  Dispose(Menu2);
  Dispose(HiScoreImg);
  Dispose(GameImg);
  CloseScreen;
  Halt;
end;

{------------‚norme proc‚dure qui gŠre tout le menu du d‚but-----------------}

Procedure MainMenu;
var
Text:Array[0..5] of string;
Compteur,i,Selected,NbrLines:Byte;
C:Char; Quit:Boolean;
Const
  Light:Array[0..9] of Byte=(5,4,3,2,1,0,1,2,3,4);
  BigScreenX1=52;
  BigScreenY1=74;
  BigScreenX2=259;
  BigScreenY2=149;
  TriScreenX1=56;
  TriScreenY1=50;
  TriScreenX2=253;
  TriScreenY2=66;
  LargScreenX1=32;
  HautScreenX1=88;
  DifficultyScreenX1=237;
  SpeedScreenX1=294;
  LittleScreenY1=172;
  LittleScreenY2=181;
  LittleScreenSizeX=18;


  MenuText:Array[0..5] of string=(
  'CONFIGURATION',
  'JOUER',
  'VOIR LES SCORES',
  'AIDE',
  'GENERIQUE',
  'QUITTER');
  MenuLines=6;

  Procedure AfficheText;
  var i:Byte;
  begin
    RedrawImage(BigScreenX1,BigScreenY1,BigScreenX2,BigScreenY2,Menu);
    for i:=0 to NbrLines-1 do TranspText(BigScreenX1+5,BigScreenY1+5+i*10,Text[i],95,105,True);
  end;

  Procedure HighLight(x1,y1,x2,y2:Integer;Light:Byte);
  var i,j:Integer;
  begin
    for i:=y1 to y2 do for j:=x1 to x2 do Pixel(j,i,Menu^[i,j]-Light);
  end;

  Procedure HandleMoves;
  begin
    if (C=#72) or (C=#80) then begin
      AfficheText;
      if C=#72 then if Selected=0 then Selected:=NbrLines-1 else Dec(Selected);
      if C=#80 then if Selected=NbrLines-1 then Selected:=0 else Inc(Selected);
      AfficheAll;
      Compteur:=0;
    end;
  end;

  Procedure HandleLights;
  begin
    Inc(Compteur);
    if Compteur=10 then Compteur:=0;
    HighLight(BigScreenX1,BigScreenY1+3+Selected*10,BigScreenX2,BigScreenY1+13+Selected*10,Light[Compteur]);
    TranspText(BigScreenX1+5,BigScreenY1+5+Selected*10,Text[Selected],90,103,True);
    Draw(BigScreenX1,BigScreenY1+3+Selected*10,BigScreenX2,BigScreenY1+13+Selected*10);
    Affiche;
  end;

  Procedure DrawSetOfTriangles;
  var X:Integer;i:Byte;
  begin
    RedrawImage(TriScreenX1,TriScreenY1,TriScreenX2,TriScreenY2,Menu);
    X:=TriScreenX1+(TriScreenX2-TriScreenX1-17*(MaxColor)) div 2;
    for i:=0 to MaxColor-1 do Triangle(X+i*17,TriScreenY1,TriDownLeft,i+1);
    Draw(TriScreenX1,TriScreenY1,TriScreenX2,TriScreenY2);
    Affiche;
  end;

  Procedure ShowConfig;
    Procedure ShowOne(X:Integer;Text:string);
    begin
      RedrawImage(X,LittleScreenY1,X+LittleScreenSizeX,LittleScreenY2,Menu);
      TranspText(X+3,LittleScreenY1+1,Text,95,105,True);
      Draw(X,LittleScreenY1,X+LittleScreenSizeX,LittleScreenY2);
      Affiche;
    end;
  begin
    ShowOne(HautScreenX1,NewStr(Hauteur));
    ShowOne(LargScreenX1,NewStr(Largeur));
    ShowOne(DifficultyScreenX1,NewStr(NbrOfTriToAttach));
    ShowOne(SpeedScreenX1,NewStr(11-Speed div 10));
  end;

  Procedure Setup;
  Const
  SetupText:Array[0..5] of string=(
  'LARGEUR'+#0+#141,
  'HAUTEUR'+#0+#138,
  'IMAGE DES TRIANGLES'+#0+#61,
  'NOMBRE DE COULEURS'+#0+#67,
  'NBRE DE TRIANGLES A COLLER'+#0+#14,
  'VITESSE'+#0+#143);
  SetupLines=6;
  var i:Byte;

    Procedure AddNumbers;
    begin
      Text[0]:=SetupText[0]+NewStr(Largeur);
      Text[1]:=SetupText[1]+NewStr(Hauteur);
      Text[2]:=SetupText[2]+NewStr(TriImage+1);
      Text[3]:=SetupText[3]+NewStr(MaxColor);
      Text[4]:=SetupText[4]+NewStr(NbrOfTriToAttach);
      Text[5]:=SetupText[5]+NewStr(11-Speed div 10);
    end;

    Procedure Modify(Variation:Boolean;Value,Min,Max:Byte;var Which:Byte);
    const Increase=True;Decrease=False;
    begin
      if Variation=Increase then if Which=Max then Which:=Min else Inc(Which,Value);
      if Variation=Decrease then if Which=Min then Which:=Max else Dec(Which,Value);
      Compteur:=0;
    end;

  begin
    NbrLines:=SetupLines;
    for i:=0 to NbrLines-1 do Text[i]:=SetupText[i];
    AddNumbers;
    AfficheText;
    Selected:=0;
    AfficheAll;
    Repeat
      C:='Z';
      if Keypressed then C:=Readkey;
      if C=#0 then C:=Readkey;
      if (C=#75) or (C=#77) then begin
        Case Selected of
          0:Modify(C=#77,1,3,10,Largeur);
          1:Modify(C=#77,1,3,10,Hauteur);
          2:Modify(C=#77,1,0,2,TriImage);
          3:Modify(C=#77,1,1,10,MaxColor);
          4:Modify(C=#77,1,1,15,NbrOfTriToAttach);
          5:Modify(C=#75,10,10,100,Speed);
        end;
        AddNumbers;
        DrawSetOfTriangles;
        ShowConfig;
      end;
      HandleMoves;
      HandleLights;
      Delay(60);
    Until (C=#27) or (C=#13);
    NbrLines:=MenuLines;
    for i:=0 to NbrLines-1 do Text[i]:=MenuText[i];
    AfficheText;
    Selected:=0;
    AfficheAll;
    C:='Z';
  end;

  Procedure BigText(PageMin,PageMax:Byte;Title:string);
  Const
    HugeScreenX1=11;
    HugeScreenY1=23;
    HugeScreenX2=309;
    HugeScreenY2=178;
    TitleX1=58;
    TitleY1=6;
{    TitleX2=251;
    TitleY2=15;}
    TinyScreenX1First=62;
    TinyScreenX1Second=89;
    TinyScreenY=186;
    TinyScreenSizeX=10;
    TinyScreenSizeY=9;
    Text2:Array[0..5,0..13] of string=((
    '',#0+#100+'TRIANGLATOR!!','','','',
    #0+#75+'UN TETRIS TOTAL BIZARRE',
    #0+#80'AVEC DES TRIANGLES!!','','','','','','',
    'EUH... ET COMMENT CA MARCHE?'),
    ('EN FAIT, C''EST PAS VRAIMENT UN TETRIS.',
    'PASQUE C''EST PAS DES LIGNES QU''Y FAUT FAIRE','',
    'VOUS VOUS RAPPELEZ PEUT ETRE D''UN VIEUX JEU',
    'QUI S''APPELAIT COLUMNS.',
    'DANS CE JEU, Y''AVAIT DES CARRES DE COULEURS',
    'DIFFERENTES QUI TOMBAIENT.',
    'ET IL FALLAIT ALIGNER TROIS CARRES DE MEME',
    'COULEURS POUR LES FAIRE DISPARAITRE.','',
    'EH BIN LA, C''EST PAREIL, SAUF QUE',
    'C''EST PAS DES CARRES MAIS DES TRIANGLES.',
    'ET IL FAUT EN ASSEMBLER TROIS',
    'POUR LES FAIRE DISPARAITRE.'),
    ('','ON PEUT ASSEMBLER LES TRIANGLES',
    'DE N''IMPORTE QUELLES FACONS, ',
    'IL FAUT JUSTE QU''IL SE TOUCHE PAR UN COTE.','','',
    'VOUS POUVEZ CONFIGURER UN TAS DE TRUCS, ',
    'MAIS SI VOUS JOUEZ POUR LA PREMIERE FOIS, ',
    'JE VOUS CONSEILLE D''UTILISER LA CONFIGURATION',
    'DE DEPART POUR S''ENTRAINER.','','',
    'OUI, C''EST VRAI QUE C''EST TOUJOURS UN PEU',
    'DIFFICILE LA PREMIERE FOIS.'),
    ('','POUR FAIRE TOURNER LA PIECE QUI TOMBE,',
    'APPUYEZ SUR N.',
    'POUR ECHANGER LES COULEURS DE LA PIECE,',
    'APPUYEZ SUR B.','','',
    '','','','','','',''),
    ('VOUS NE POUVEZ ENTRER DANS LES HIGH SCORES',
    'QUE SI VOUS JOUEZ AVEC LA CONFIGURATION',
    'PAR DEFAUT.','',
    'SINON C''EST DE LA TRICHE :',
    'VOUS METTEZ UNE CONFIGURATION HYPER FACILE',
    'VOUS FAITES PLEIN DE POINTS ET VOILA!!!',
    'VOUS ETES DANS LES SCORES ALORS QUE VOUS',
    'AVEZ RIEN FOUTU!!','','','','',''
    ),
    ('',#0+#100+'TRIANGLATOR','',
    'PROGRAMMATION :  RECHER  GRZMKTBQ',
    'GRAPHISMES :  RECHER  ZARMA',
    'IDEE DU JEU : ZOGFRIED ZARBA',
    'MUSIQUES ET SONS : YANAPAS','',
    'SOUTIEN MORAL :',
    'MA FAMILLE, MES POTES, MES POTESSES',
    'ET MES CDS DE MUSIQUE','',
    'REMERCIEMENTS A :',
    'TOUT CEUX QUI M''ONT SOUTIENDU MORALEMENT')
    );
  var i,Page:Integer;
  begin
    Page:=PageMin;
    Move(Menu2^[0,0],Buffer^[0,0],64000);
    for i:=0 to 13 do TranspText(HugeScreenX1+5,HugeScreenY1+i*10+5,Text2[Page,i],95,105,True);
    TranspText(TitleX1,TitleY1+1,Title,69,76,True);
    TranspText(TinyScreenX1First+2,TinyScreenY+1,NewStr(Page-PageMin+1),95,105,True);
    TranspText(TinyScreenX1Second+2,TinyScreenY+1,NewStr(PageMax-PageMin+1),95,105,True);
    AfficheAll;
    Repeat
      C:='Z';
      if keypressed then C:=Readkey;
      if C=#0 then C:=Readkey;
      if (C=#75) or (C=#77) then begin
        RedrawImage(HugeScreenX1,HugeScreenY1,HugeScreenX2,HugeScreenY2,Menu2);
        RedrawImage(TinyScreenX1First,TinyScreenY,TinyScreenX1Second+TinyScreenSizeX,TinyScreenY+TinyScreenSizeY,Menu2);
        if C=#75 then if Page>PageMin then Dec(Page);
        if C=#77 then if Page<PageMax then Inc(Page);
        for i:=0 to 13 do TranspText(HugeScreenX1+5,HugeScreenY1+i*10+5,Text2[Page,i],95,105,True);
        Draw(HugeScreenX1,HugeScreenY1,HugeScreenX2,HugeScreenY2);
        TranspText(TinyScreenX1First+2,TinyScreenY+1,NewStr(Page-PageMin+1),95,105,True);
        TranspText(TinyScreenX1Second+2,TinyScreenY+1,NewStr(PageMax-PageMin+1),95,105,True);
        Draw(TinyScreenX1First,TinyScreenY,TinyScreenX1Second+TinyScreenSizeX,TinyScreenY+TinyScreenSizeY);
        Affiche;
      end;
    Until (C=#13) or (C=#27);
    C:='Z';
    Move(Menu^[0,0],Buffer^[0,0],64000);
    AfficheText;
    DrawSetOfTriangles;
    ShowConfig;
    AfficheAll;
  end;

  Procedure ShowHiScore;
  var i:Byte;S:string;
  begin
    RedrawImage(BigScreenX1,BigScreenY1,BigScreenX2,BigScreenY2,Menu);
    for i:=0 to 5 do begin
      TranspText(BigScreenX1+10,BigScreenY1+5+i*10,HiScore[i].Name,95,105,True);
      S:=NewStr(HiScore[i].Value);
      TranspText(BigScreenX2-10-TextLength(S),BigScreenY1+5+i*10,S,95,105,True);
    end;
    Draw(BigScreenX1,BigScreenY1,BigScreenX2,BigScreenY2);
    Affiche;
    Readkey;
    AfficheText;
    Draw(BigScreenX1,BigScreenY1,BigScreenX2,BigScreenY2);
    Affiche;
  end;

begin
  Quit:=False;
  NbrLines:=MenuLines;
  Move(Menu^[0,0],Buffer^[0,0],64000);
  for i:=0 to NbrLines-1 do Text[i]:=MenuText[i];
  AfficheText;
  DrawSetOfTriangles;
  Speed:=Speed-Speed mod 10;
  if Speed=0 then Speed:=10;
  ShowConfig;
  Selected:=0;
  AfficheAll;
  Compteur:=0;
  Repeat
    C:='Z';
    if Keypressed then C:=Readkey;
    if C=#0 then C:=Readkey;
    if C=#13 then Case Selected of
      0:Setup;
      1:Quit:=True;
      2:ShowHiScore;
      3:BigText(0,4,#0+#85+'AIDE');
      4:BigText(5,5,#0+#10+'MON DIEU QU''IL EST FORT!!');
      5:ExitGame;
    end;
    if C=#27 then ExitGame;
    HandleMoves;
    HandleLights;
    Delay(60);
  Until Quit;
end;

var
  i,j,k:Integer;
  Lost:Boolean;

begin
  ClrScr;
  TestFilePresence;
  GotoXY(30,10);
  Write('Plize Wait, Loadingue');
  GotoXY(35,11);
  Write('.....');
  GotoXY(35,11);
  TakeSprite;
  TakeScore;
  MCGAScreen;
  DefinePal;
  LoadCarac;
  Randomize;
  Intro;

  Repeat
    EndGame:=False;
    MainMenu;
    ClearScreen(0);
    Init;
    While keypressed do Readkey;
    Repeat
      if CanIGoDown then begin
        Inc(YCurrent);
        Redraw;
        Wait;
      end else begin
        SetBlockAndDestroy;
        EndGame:=not(NewPiece);
        Lost:=EndGame;
        NextPiece;
        Redraw;
        Wait;
      end;
    Until EndGame;
    if (CalculPos<>255) and (Hauteur=10) and (Largeur=5) and (MaxColor=3)
    and (NbrOfTriToAttach=3) then begin
      AddHiScore(CalculPos,AskName,Score);
      WriteHiScore;
    end else if Lost then YouLose;
  Until False;
end.