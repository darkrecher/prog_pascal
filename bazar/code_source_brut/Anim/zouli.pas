Uses MCgaGraf,Crt;

Type
  PStar=^TStar;
  TStar=Record
    SpeedX,SpeedY:Integer;
    X,Y,Time:Word;
    Color:Byte;
    Suivant:PStar;
  end;
  TSnake=Record
    X,Y:Word;
    DepX,DepY:Integer;
    Color:Byte;
    Exists,Circle:Boolean;
  end;

var
  Premier:PStar;
  X,Y:Word;
  DepX,DepY:Integer;
  Compteur:Byte;
  Choice:Boolean;

Const
  X1=0;
  Y1=0;
  X2=319;
  Y2=199;
  SizeX=X2-X1;
  SizeY=Y2-Y1;
  Speed=1;
  DivSpeed=1;
  Life=63;
  DotToCross=Life div 3;
  CrossToSquare=Life*2 div 3;
  AdvanceColor=1;
  LimColor=255;

  MarginX=140;
  MarginY=70;
  MaxSpeedX=128;
  MaxSpeedY=128;
  AccelX=50;
  AccelY=50;
  BrakeSpeedX=40;
  BrakeSpeedY=40;

  Wave:Array[0..15] of ShortInt=(0,2,3,4,4,3,2,0,0,-2,-3,-4,-4,-3,-2,0);
  WaveLength=16;

  CustomScreen:Array[0..24] of String=(
(''),
('                             CONFIGURATION DE TOUT LE BAZAR'),
(''),
(''),
('                                    SPERMATOZO‹DES'),
(''),
(' Spermatozo‹de 1     Spermatozo‹de 2     Spermatozo‹de 3     Spermatozo‹de 4'),
(''),
(''),
(' Couleur   :         Couleur   :         Couleur   :         Couleur   :'),
(' Mouvement :         Mouvement :         Mouvement :         Mouvement :'),
(''),
('                                        ETOILES'),
(''),
('    Quantit‚ d''etoiles rouge :      Quantit‚ d''etoiles verte       :'),
('    Quantit‚ d''etoiles bleue :      Quantit‚ d''etoiles Arc-en-ciel :'),
(''),
('                                     EFFETS SPECIAUX'),
(''),
('                                mouvement des etoiles       :'),
('                                vitesse des ‚toiles         :'),
('                                retour vers le centre       :'),
('                                effet sp‚cial               :'),
('                                periode de l''effet sp‚cial  :'),
('+ et - : modifier    Entr‚e:revenir … la d‚mo'));




Const
  RedStars:Byte=0;
  BlueStars:Byte=0;
  GreenStars:Byte=0;
  RainbowStars:Byte=20;
  CircleStars:Boolean=False;
  BackToCentre:Boolean=False;
  SpecialEffect:Boolean=False;
  NormalEffect:Boolean=True;
  Toggle:Byte=32;
  Slow:Byte=0;

Procedure NewStar(NX,NY:Word;NColor:Byte);
var P1,P2:PStar;
begin
  if Premier=Nil then begin
    New(P2);
    Premier:=P2;
  end else begin
    P1:=Premier;
    While P1^.Suivant<>Nil do P1:=P1^.Suivant;
    New(P2);
    P1^.Suivant:=P2;
  end;
  P2^.X:=NX;
  P2^.Y:=NY;
  P2^.SpeedX:=(NX shr 7-X1-SizeX div 2);
  P2^.SpeedY:=(NY shr 7-Y1-SizeY div 2);
  P2^.Time:=0;
  P2^.Color:=NColor;
  P2^.Suivant:=Nil;
end;

Procedure DeleteStar(var P:PStar);
var P1,P2:PStar;
begin
  if P=Premier then begin
    P1:=Premier^.Suivant;
    Dispose(Premier);
    Premier:=P1;
    P:=Premier;
  end else begin
    P2:=Premier;
    While P2<>P do begin
      P1:=P2;
      P2:=P2^.Suivant;
    end;
    P1^.Suivant:=P1^.Suivant^.Suivant;
    Dispose(P2);
    P:=P1^.Suivant;
  end;
end;

Procedure LittleCross(X,Y:Word;Color:Byte);
begin
  Pixel(X,Y,Color);
  Pixel(X+1,Y,Color);
  Pixel(X,Y-1,Color);
  Pixel(X-1,Y,Color);
  Pixel(X,Y+1,Color);
end;

Procedure LittleSquare(X,Y:Word;Color:Byte);
begin
  Pixel(X,Y,Color);
  Pixel(X+1,Y+1,Color);
  Pixel(X+1,Y-1,Color);
  Pixel(X-1,Y+1,Color);
  Pixel(X-1,Y-1,Color);
  Pixel(X+1,Y,Color);
  Pixel(X,Y-1,Color);
  Pixel(X-1,Y,Color);
  Pixel(X,Y+1,Color);
end;

Procedure DrawStar(X,Y,Form:Word;Color:Byte);
begin
  if Form<DotToCross then Pixel(X,Y,Color) else
  if Form<CrossToSquare then LittleCross(X,Y,Color) else
  LittleSquare(X,Y,Color);
end;

Procedure Destroy;
var P:PStar;
begin
  P:=Premier;
  While P<>Nil do begin
    Premier:=Premier^.Suivant;
    Dispose(P);
    P:=Premier;
  end;
end;

Procedure DisplayStar(P:PStar);
var P1:PStar;Suppressed:Boolean;RealX,RealY:Integer;
begin
  P1:=P;
  Suppressed:=False;
  While P1<>Nil do begin
    With P1^ do begin
      RealX:=X shr 7;
      RealY:=Y shr 7;
      DrawStar(RealX,RealY,Time,0);
      Inc(Time);

      if (Time=Life) or (RealX<X1) or (RealX>X2) or (RealY<Y1) or (RealY>Y2) then begin
        Suppressed:=True;
        DeleteStar(P1);
      end else begin
        if NormalEffect then begin
          Inc(X,(SpeedX*Time*Speed) div DivSpeed);
          Inc(Y,(SpeedY*Time*Speed) div DivSpeed);
        end else if SpecialEffect then begin
          if Choice then begin
            Inc(X,-(SpeedY*Time*Speed) div DivSpeed);
            Inc(Y,(SpeedX*Time*Speed) div DivSpeed);
          end else begin
            Inc(X,(SpeedY*Time*Speed) div DivSpeed);
            Inc(Y,-(SpeedX*Time*Speed) div DivSpeed);
          end;
        end else begin
          if Choice then begin
            Inc(X,(SpeedX*Time*Speed) div DivSpeed);
            Inc(Y,(SpeedY*Time*Speed) div DivSpeed);
          end else begin
            Inc(X,-(SpeedX*Time*Speed) div DivSpeed);
            Inc(Y,-(SpeedY*Time*Speed) div DivSpeed);
          end;
        end;
        if CircleStars then begin
          Inc(X,Wave[Time mod WaveLength] shl 7);
          Inc(Y,Wave[(Time+WaveLength div 4) mod WaveLength] shl 7);
        end;

        RealX:=X shr 7;
        RealY:=Y shr 7;
        if BackToCentre then begin
          if Y shr 7<Y1+SizeY div 2 then Inc(SpeedY);
          if Y shr 7>Y1+SizeY div 2 then Dec(SpeedY);
          if X shr 7<X1+SizeX div 2 then Inc(SpeedX);
          if X shr 7>X1+SizeX div 2 then Dec(SpeedX);
        end;

        if (Time mod AdvanceColor=0) and (Color<LimColor) then Inc(Color);
        DrawStar(RealX,RealY,Time,Color);
      end;
    end;
    if Suppressed then Suppressed:=False else P1:=P1^.Suivant;
  end;
end;

var
  Snake1,Snake2,Snake3,Snake4:TSnake;

Procedure SetupSnakes(Ex1,Ex2,Ex3,Ex4,Circle1,Circle2,Circle3,Circle4:Boolean;
Color1,Color2,Color3,Color4:Byte);
begin
  With Snake1 do begin
    Exists:=Ex1;
    Circle:=Circle1;
    Color:=Color1;
  end;
  With Snake2 do begin
    Exists:=Ex2;
    Circle:=Circle2;
    Color:=Color2;
  end;
  With Snake3 do begin
    Exists:=Ex3;
    Circle:=Circle3;
    Color:=Color3;
  end;
  With Snake4 do begin
    Exists:=Ex4;
    Circle:=Circle4;
    Color:=Color4;
  end;
end;

Procedure SetupStars(Red,Green,Blue,Rainbow:Byte);
begin
  RedStars:=Red;
  BlueStars:=Blue;
  GreenStars:=Green;
  RainbowStars:=Rainbow;
end;

Procedure SetupEffects(ACircleStars,ABackToCentre,ASpecialEffect,ANormalEffect:Boolean;
AToggle,ASlow:Byte);
begin
  CircleStars:=ACircleStars;
  BackToCentre:=ABackToCentre;
  SpecialEffect:=ASpecialEffect;
  NormalEffect:=ANormalEffect;
  Toggle:=AToggle;
  Slow:=ASlow;
end;

Procedure Custom;
Const
  XBox:Array[0..20] of Byte=(5,25,45,65,14,34,54,74,14,34,54,74,31,69,31,69,63,63,63,63,63);
  YBox:Array[0..20] of Byte=(9,9,9,9,10,10,10,10,11,11,11,11,15,15,16,16,20,21,22,23,24);
  GoDown:Array[0..20] of Byte=(4,4,4,4,4,4,4,4,4,3,3,2,2,2,2,1,1,1,1,1,1);
  GoUp:Array[0..20] of ShortInt=(-20,-19,-18,-17,4,4,4,4,4,4,4,4,4,2,2,2,1,1,1,1,1);
  Max:Array[0..20] of Byte=(1,1,1,1,3,3,3,3,1,1,1,1,50,50,50,50,1,100,1,2,7);
  RectangleX1:Array[0..6] of Byte=(14,34,54,74,32,69,63);
  RectangleY1:Array[0..6] of Byte=(10,10,10,10,15,15,20);
  RectangleX2:Array[0..6] of Byte=(20,40,60,80,34,71,73);
  RectangleY2:Array[0..6] of Byte=(11,11,11,11,16,16,24);
  ToggleValues:Array[0..7] of Byte=(0,2,4,8,16,32,64,128);

var C:Char;Pos:Byte;Value:Array[0..20] of Byte;
i:Byte;

Procedure OffCursor;Assembler;
asm
  mov ah,01
  mov ch,15
  mov cl,0
  int $10
end;

Procedure Rectangle(X1,Y1,X2,Y2:Byte);
var i,j:Byte;
begin
  for i:=Y1 to Y2 do begin
    GotoXY(X1,i);
    for j:=X1 to X2 do Write(' ');
  end;
end;

Function YesNo(X:Byte):string;
begin
  if X=0 then YesNo:='Desactiv‚';
  if X=1 then YesNo:='Activ‚   ';
end;

Function Color(X:Byte):string;
begin
  if X=0 then Color:='Rouge  ';
  if X=1 then Color:='Vert   ';
  if X=2 then Color:='Bleu   ';
  if X=3 then Color:='Rainbow';
end;

Function Movement(X:Byte):string;
begin
  if X=0 then Movement:='Normal';
  if X=1 then Movement:='Cercle';
end;

Function NewStr(X:Byte):string;
var S:string;
begin
  Str(X,S);
  While Length(S)<3 do S:=S+' ';
  NewStr:=S;
end;

Function SpeEffect(X:Byte):string;
begin
  if X=0 then SpeEffect:='Aucun   ';
  if X=1 then SpeEffect:='Yo-Yo   ';
  if X=2 then SpeEffect:='Rotation';
end;

Function WhatToWrite:string;
begin
  Case Pos of
    0..3:WhatToWrite:=YesNo(Value[Pos]);
    4..7:WhatToWrite:=Color(Value[Pos]);
    8..11:WhatToWrite:=Movement(Value[Pos]);
    12..15:WhatToWrite:=NewStr(Value[Pos]);
    16:WhatToWrite:=Movement(Value[Pos]);
    17:WhatToWrite:=NewStr(Value[Pos]);
    18:WhatToWrite:=YesNo(Value[Pos]);
    19:WhatToWrite:=SpeEffect(Value[Pos]);
    20:WhatToWrite:=NewStr(ToggleValues[Value[Pos]]);
  end;
end;

Procedure DefineValueSnake(Snake:TSnake;V1,V2,V3:Byte);
begin
  Value[V1]:=Ord(Snake.Exists);
  Value[V3]:=Ord(Snake.Circle);
  Case Snake.Color of
    1:Value[V2]:=0;
    65:Value[V2]:=1;
    129:Value[V2]:=2;
    193:Value[V2]:=3;
  end;
end;

begin
  CloseScreen;
  TextBackGround(Blue);
  TextColor(15);
  OffCursor;
  ClrScr;
  for i:=0 to 23 do WriteLn(CustomScreen[i]);
  TextColor(LightGreen);
  Write(CustomScreen[24]);
  TextColor(15);
  TextBackGround(7);
  for i:=0 to 6 do Rectangle(RectangleX1[i],RectangleY1[i],RectangleX2[i],RectangleY2[i]);

  DefineValueSnake(Snake1,0,4,8);
  DefineValueSnake(Snake2,1,5,9);
  DefineValueSnake(Snake3,2,6,10);
  DefineValueSnake(Snake4,3,7,11);
  Value[12]:=RedStars;
  Value[13]:=GreenStars;
  Value[14]:=BlueStars;
  Value[15]:=RainbowStars;
  Value[16]:=Ord(CircleStars);
  Value[17]:=100-Slow;
  Value[18]:=Ord(BackToCentre);
  if NormalEffect then Value[19]:=0 else if SpecialEffect then Value[19]:=2 else Value[19]:=1;
  for i:=0 to 7 do if Toggle=ToggleValues[i] then Value[20]:=i;

  for Pos:=0 to 20 do begin
    GotoXY(XBox[Pos],YBox[Pos]);
    Write(WhatToWrite);
  end;
  Pos:=0;
  TextBackGround(Green);
  TextColor(0);
  GotoXY(XBox[Pos],YBox[Pos]);
  Write(WhatToWrite);
  Repeat
    C:='Z';
    if keypressed then C:=Readkey;
    if C=#0 then C:=Readkey;
    if (C=#72) or (C=#80) or (C=#75) or (C=#77) or (C='+') or (C='-') then begin
      TextBackGround(7);
      TextColor(15);
      GotoXY(XBox[Pos],YBox[Pos]);
      Write(WhatToWrite);
      if C=#75 then if Pos=0 then Pos:=20 else Dec(Pos);
      if C=#77 then Inc(Pos);
      if C=#80 then Inc(Pos,GoDown[Pos]);
      if C=#72 then Dec(Pos,GoUp[Pos]);
      Pos:=Pos mod 21;
      if C='+' then if Value[Pos]=Max[Pos] then Value[Pos]:=0 else Inc(Value[Pos]);
      if C='-' then if Value[Pos]=0 then Value[Pos]:=Max[Pos] else Dec(Value[Pos]);
      TextBackGround(Green);
      TextColor(0);
      GotoXY(XBox[Pos],YBox[Pos]);
      Write(WhatToWrite);
    end;
  Until C=#13;
  SetupSnakes(Value[0]=1,Value[1]=1,Value[2]=1,Value[3]=1,Value[8]=1,Value[9]=1,Value[10]=1,Value[11]=1,
  Value[4]*64+1,Value[5]*64+1,Value[6]*64+1,Value[7]*64+1);
  SetupStars(Value[12],Value[13],Value[14],Value[15]);
  SetupEffects(Value[16]=1,Value[18]=1,Value[19]=2,Value[19]=0,ToggleValues[Value[20]],100-Value[17]);
  Choice:=False;
  MCGAScreen;
  DefinePal;
end;

Procedure InitSnake(var Snake:TSnake;AColor:Byte);
begin
  With Snake do begin
    X:=(Random(SizeX)+X1) shl 7;
    Y:=(Random(SizeY)+Y1) shl 7;
    DepX:=Random(255)-128;
    DepY:=Random(255)-128;
    Color:=AColor;
    Exists:=False;
    Circle:=False;
  end;
end;

Procedure HandleSnake(var Snake:TSnake);
begin
  if Snake.Exists then With Snake do begin
    if Circle then NewStar(X+Wave[Compteur mod WaveLength] shl 7,
    Y+Wave[(Compteur+WaveLength div 4) mod WaveLength] shl 7,Color)
    else NewStar(X,Y,Color);
    Inc(X,DepX);
    Inc(Y,DepY);
    if X shr 7<MarginX+X1 then Inc(DepX,BrakeSpeedX)
    else if MarginX+X shr 7>X2 then Dec(DepX,BrakeSpeedX)
    else Inc(DepX,Random(AccelX+1)-AccelX div 2);
    if Y2-Y shr 7<MarginY then Dec(DepY,BrakeSpeedY)
    else if Y shr 7-Y1<MarginY then Inc(DepY,BrakeSpeedY)
    else Inc(DepY,Random(AccelY+1)-AccelY div 2);
    if DepX>MaxSpeedX then DepX:=MaxSpeedX;
    if DepX<-MaxSpeedX then DepX:=-MaxSpeedX;
    if DepY>MaxSpeedY then DepY:=MaxSpeedY;
    if DepY<-MaxSpeedY then DepY:=-MaxSpeedY;
  end;
end;

Procedure HandleStars(Stars,Color:Byte);
var i:Byte;
begin
  if Stars<>0 then for i:=0 to Stars-1 do NewStar((Random(SizeX+1)+X1) shl 7,(Random(SizeY+1)+Y1) shl 7,Color);
end;

Procedure Predefined(x:ShortInt);
Const
SnakeEx:Array[0..3,0..3] of Boolean=((True,False,False,False),
                                     (False,True,False,False),
                                     (False,False,True,False),
                                     (False,True,False,True));
AEffects:Array[0..8,0..3] of Boolean=((False,True,False,True),
                                      (False,False,False,False),
                                      (False,True,True,False),
                                      (True,False,False,True),
                                      (False,False,False,False),
                                      (False,False,True,False),
                                      (False,True,False,True),
                                      (True,False,False,True),
                                      (True,True,True,False));
BEffects:Array[0..8,0..1] of Byte=((32,30),(32,30),(32,30),(32,20),
(16,30),(128,30),(32,30),(32,30),(8,45));
Stars:Array[0..4,0..3] of Byte=((4,0,0,0),(0,4,0,0),(0,0,4,0),(10,0,0,0),(1,1,1,0));
begin
  if x=-1 then begin
    SetupStars(0,0,0,0);
    SetupSnakes(True,True,True,False,False,False,False,False,1,65,129,193);
    SetupEffects(False,False,False,True,32,25)
  end;
  if x in [0..3] then begin
    SetupStars(0,0,0,0);
    SetupSnakes(SnakeEx[x,0],SnakeEx[x,1],SnakeEx[x,2],SnakeEx[x,3],SnakeEx[x,0],SnakeEx[x,1],SnakeEx[x,2],SnakeEx[x,3],
    Random(3)*64+1,Random(3)*64+1,Random(3)*64+1,Random(3)*64+1);
    SetupEffects(AEffects[x,0],AEffects[x,1],AEffects[x,2],AEffects[x,3],
    BEffects[x,0],BEffects[x,1]);
  end;
  if x in [4..8] then begin
    SetupStars(Stars[x-4,0],Stars[x-4,1],Stars[x-4,2],Stars[x-4,3]);
    SetupSnakes(False,False,False,False,False,False,False,False,1,1,1,1);
    SetupEffects(AEffects[x,0],AEffects[x,1],AEffects[x,2],AEffects[x,3],
    BEffects[x,0],BEffects[x,1]);
  end;
  if x=9 then begin
    SetupStars(0,0,0,4);
    SetupSnakes(True,True,True,True,False,False,False,False,193,193,193,193);
    SetupEffects(False,False,False,True,32,0);
  end;
end;

Procedure SquareStar(X1,Y1,X2,Y2,Espace:Word);
var i,j:Word;
begin
  for i:=0 to (X2-X1+1) div Espace do for j:=0 to (Y2-Y1+1) div Espace do
  NewStar((X1+i*Espace) shl 7,(Y1+j*Espace) shl 7,193);
end;

var
  i:Integer;
  C:Char;
  Stop:Boolean;

begin
  WriteLn('                             Spermatozo‹des Simulator');
  GotoXY(50,WhereY+1);
  WriteLn('Made by R/eche\r Grzmktbq');
  WriteLn;
  WriteLn('Pendant la d‚mo, vous pouvez appuyer sur les touches de 0 … 9');
  WriteLn('pour voir les supers effets sp‚ciaux');
  WriteLn;
  WriteLn('et sur la touche F1 pour configurer vous mˆme les supers effets sp‚ciaux');
  WriteLn;
  WriteLn;
  WriteLn;
  WriteLn('Par contre, c''est bizarre, c''est plus rapide sur un 486 que sur les Pentium de mes potes');
  While keypressed Do Readkey;
  Readkey;
  MCGaScreen;
  Randomize;
  Premier:=Nil;
  Degrade(1,63,0,0,32,63,63,63);
  Degrade(33,63,63,63,64,0,0,0);
  Degrade(65,0,63,0,96,63,63,63);
  Degrade(97,63,63,63,128,0,0,0);
  Degrade(129,0,0,63,160,63,63,63);
  Degrade(161,63,63,63,192,0,0,0);

  Degrade(193,63,0,0,202,63,63,0);
  Degrade(203,63,63,0,212,0,63,0);
  Degrade(213,0,63,0,223,0,63,63);
  Degrade(224,0,63,63,233,0,0,63);
  Degrade(234,0,0,63,245,63,0,63);
  Degrade(245,63,0,63,255,0,0,0);

  DefinePal;
  While keypressed do Readkey;
  Compteur:=0;
  Stop:=False;
  InitSnake(Snake1,1);
  InitSnake(Snake2,65);
  InitSnake(Snake3,129);
  InitSnake(Snake4,193);
  Predefined(-1);
  Repeat
    DisplayStar(Premier);
    Delay(Slow);
    Draw(X1,Y1,X2,Y2);
    Affiche;

    Inc(Compteur);
    if (Toggle<>0) and (Compteur mod Toggle=0) then Choice:=not(Choice);

    HandleSnake(Snake1);
    HandleSnake(Snake2);
    HandleSnake(Snake3);
    HandleSnake(Snake4);

    HandleStars(RedStars,1);
    HandleStars(GreenStars,65);
    HandleStars(BlueStars,129);
    HandleStars(RainbowStars,193);

    if Keypressed then begin
      C:=Readkey;
      if C=#59 then Custom;
      if C=#27 then Stop:=True;
      if C in ['0'..'9'] then begin
        Predefined(Ord(C)-48);
      end;
      if C='c' then SquareStar(150,90,170,110,4);
      if C='r' then SquareStar(120,70,140,90,4);
      if C='p' then begin
        SquareStar(0,100,319,100,4);
        SquareStar(160,0,160,199,4);
      end;
      if C='z' then SquareStar(0,0,319,199,16);
    end;
  Until Stop;
  CloseScreen;
  Destroy
end.