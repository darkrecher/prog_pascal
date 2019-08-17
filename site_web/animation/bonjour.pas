Uses MCgaGraf,NewDelay,Crt;

Type
  PStar=^TStar;
  TStar=Record
    SpeedX,SpeedY:Integer;
    X,Y,Time:Word;
    Color:Byte;
    Suivant:PStar;
    Freezable:Boolean;
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
  Freeze,Choice:Boolean;
  Cycle,ColorText:Byte;

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

  MaxString=6;
  Message:Array[0..Maxstring-1] of string=(
  'BONJOUR','SALUT!','BIENVENUE!','HELLO!','GUTEN TAG!','SALAM ALIKOUM');

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

Procedure NewStar(NX,NY:Word;NColor:Byte;NFreezable:Boolean);
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
  With P2^ do begin
    X:=NX;
    Y:=NY;
    SpeedX:=(NX shr 7-X1-SizeX div 2);
    SpeedY:=(NY shr 7-Y1-SizeY div 2);
    Time:=0;
    Color:=NColor;
    Freezable:=NFreezable;
    Suivant:=Nil;
  end;
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

      if not(Freezable and Freeze) then begin

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

      end else DrawStar(RealX,RealY,Time,Color);

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
    Y+Wave[(Compteur+WaveLength div 4) mod WaveLength] shl 7,Color,False)
    else NewStar(X,Y,Color,False);
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
  if Stars<>0 then for i:=0 to Stars-1 do NewStar((Random(SizeX+1)+X1) shl 7,(Random(SizeY+1)+Y1) shl 7,Color,False);
end;

Procedure Letter(X,Y,Espace:Word;CharToWrite:Char;Color:Byte);
var i,j:Word;
begin
  With Carac[Ord(CharToWrite)] do if Exists then
  for i:=0 to 7 do for j:=0 to SizeX-1 do
  if Image[i,j]=255 then NewStar((X+j*Espace) shl 7,(Y+i*Espace) shl 7,Color,True);
end;

Procedure StarText(X,Y,Espace:Word;Text:string;Color:Byte);
var i:Word;
begin
  if Text<>'' then for i:=0 to Length(Text)-1 do begin
    Letter(X,Y,Espace,Text[i+1],Color);
    Inc(X,(Carac[Ord(Text[i+1])].SizeX+1)*Espace);
  end;
end;

Procedure NewCycle;

  Procedure NoSnake;
  begin
    SetupSnakes(False,False,False,False,False,False,False,False,0,0,0,0);
  end;

  Procedure NoStars;
  begin
    SetupStars(0,0,0,0);
  end;

begin
  Case Cycle mod 8 of
    0:begin
      SetupStars(2,0,0,0);
      NoSnake;
      ColorText:=65;
    end;
    1:begin
      NoStars;
      SetupSnakes(True,True,False,False,False,False,False,False,65,1,0,0);
      ColorText:=129;
    end;
    2:begin
      NoSnake;
      SetupStars(0,1,1,0);
      ColorText:=1;
    end;
    3:begin
      NoStars;
      SetupSnakes(True,True,False,False,False,False,False,False,129,1,0,0);
      ColorText:=193;
    end;
    4:begin
      NoSnake;
      SetupStars(0,0,0,2);
      ColorText:=1;
    end;
    5:begin
      NoStars;
      SetupSnakes(True,True,False,False,True,True,False,False,129,193,0,0);
      ColorText:=65;
    end;
    6:begin
      NoSnake;
      SetupStars(1,1,0,0);
      ColorText:=129;
    end;
    7:begin
      SetupSnakes(True,True,False,False,True,True,False,False,193,65,0,0);
      NoStars;
      ColorText:=1;
    end;
  end;
  Case Cycle mod 7 of
    0:SetupEffects(False,False,False,True,128,30);
    1:SetupEffects(False,True,False,True,128,30);
    2:SetupEffects(True,False,False,True,128,30);
    3:SetupEffects(False,False,True,False,64,30);
    4:SetupEffects(False,False,False,False,64,30);
    5:SetupEffects(False,True,True,False,8,30);
    6:SetupEffects(True,True,False,True,128,30);
  end;
  Inc(Cycle);
  if Cycle=56 then Cycle:=0;
end;

var
  i:Integer;
  C:Char;
  Stop:Boolean;

begin
  PatchCrt(Crt.Delay);
  MCGaScreen;
  LoadCarac;
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
  Cycle:=0;
  Stop:=False;
  Freeze:=False;
  InitSnake(Snake1,1);
  InitSnake(Snake2,65);
  InitSnake(Snake3,129);
  InitSnake(Snake4,193);
  C:='-';
  Repeat
    DisplayStar(Premier);
    Delay(Slow);
    Draw(X1,Y1,X2,Y2);
    Affiche;

    if Compteur=0 then NewCycle;
    if Compteur=55 then StarText(160-TextLength(Message[Cycle mod MaxString]),92,2,Message[Cycle mod MaxString],ColorText);
    if Compteur=56 then Freeze:=True;
    if Compteur=156 then Freeze:=False;
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
      if C=#27 then Stop:=True;
    end;
  Until Stop;
  CloseScreen;
  Destroy;
end.