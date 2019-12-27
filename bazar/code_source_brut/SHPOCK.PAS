Uses Crt,MCGAGraf,Objects,KeyBoard;

{       #72:Up
        #75:Left
        #80:Down
        #77:Right  }

Const
  BounceDelay=3;
  AnglePrecision=32;
  RacketLength=36;
  RacketSlow=3;

  StopX1=0;
  StopX2=319;
  StopY1=125;
  StopY2=199-RacketLength div 2;
  StopAngle1=AnglePrecision div 6;
  StopAngle2=AnglePrecision-AnglePrecision div 6;


Type
  TDirection=(NoDir,Right,Up,Left,Down);
  TCoord=Record
    X,Y:Integer;
  end;
  TOrderPlayer=Record
    GLeft,GRight,GUp,GDown,GTurnTrigo,GTurnAntiTrigo,GQuit:Boolean;
  end;
  PUniverse=^TUniverse;
  PCapsule=^TCapsule;
  TRacket=Object(TObject)
    PosX,PosY,IntAngle,BordX1,BordY1,BordX2,BordY2:Integer;
    Angle:Real;
    MoveTime:Word;
    Positions:Array[0..RacketLength-1] of TCoord;
    Constructor Init(APosX,APosY,AIntAngle:Integer);
    Function ImpactPoint(Capsule:PCapsule):Integer;
    Procedure Draws(Color:Byte);
    Procedure ConvertAngle;
    Procedure Move(Dir:TDirection);
    Destructor Done; virtual;
  end;
  TCapsule=Object(TObject)
    PosX,PosY,DepX,DepY,Angle,Rayon:Real;
    BounceTimer:Integer;
    Owner:PUniverse;
    Constructor Init(APosX,APosY,ADepX,ADepY,AAngle,ARayon:Real;AOwner:PUniverse);
    Procedure CalculAngleRayon; virtual;
    Procedure CalculXY; virtual;
    Procedure DrawPoint(Color:Byte);
    Procedure Makemove; virtual;
    Procedure Makebounce(var Racket:TRacket);
    Destructor Done; virtual;
  end;
  TObstacle=Object(TObject)
    X1,Y1,X2,Y2:Word;
    Constructor Init(AX1,AY1,AX2,AY2:Word);
    Procedure Draws;
    Procedure HandleCollisions(Capsule:PCapsule);
    Destructor Done; virtual;
  end;
  TTotem=Object(TObject)
    X,Y,MouthY,MouthX1,MouthX2:Word;
    ArmLeft,ArmRight,BorderLeft,BorderRight:TObstacle;
    Constructor Init(AX,AY:Word);
    Procedure Draws;
    Procedure HandleInteractions(Capsule:PCapsule);
    Destructor Done; virtual;
  end;
  TStatusBar=Object(TObject)
    Score:Word;
    Constructor Init;
    Procedure AddScore(Nbr:Integer);
    Destructor Done; virtual;
  end;
  TUniverse=Object(TObject)
    Totem:TTotem;
    Point:TCapsule;
    Racket:TRacket;
    StatusBar:TStatusBar;
    OrderPlayer:TOrderPlayer;
    Capsules:TCollection;
    NbrCapsules:Word;
    Constructor Init;
    Procedure AddCapsule(X,Y:Real);
    Procedure TakeOrders;
    Procedure Play;
    Destructor Done; virtual;
  end;

Procedure Sort(var X1,X2:Real);
var Stock:Real;
begin
  if X1>X2 then begin
    Stock:=X1;
    X1:=X2;
    X2:=Stock;
  end;
end;

Constructor TCapsule.Init(APosX,APosY,ADepX,ADepY,AAngle,ARayon:Real;AOwner:PUniverse);
begin
  PosX:=APosX;
  PosY:=APosY;
  DepX:=ADepX;
  DepY:=ADepY;
  Angle:=AAngle;
  Rayon:=ARayon;
  BounceTimer:=0;
  Owner:=AOwner;
end;

Procedure TCapsule.CalculAngleRayon;
var Cosinus:Real;
begin
  Rayon:=Sqrt(Sqr(DepX)+Sqr(DepY));
  {   ArcCos(x) = ArcTan (sqrt (1-sqr (x)) /x)  }
  Cosinus:=DepX/Rayon;
  Angle:=ArcTan (sqrt (1-sqr (Cosinus)) /Cosinus);
  if DepX<0 then Angle:=Angle+Pi;
  if DepY>0 then Angle:=-Angle;
end;

Procedure TCapsule.CalculXY;
begin
  DepX:=Rayon*Cos(Angle);
  DepY:=-Rayon*Sin(Angle);
end;

Procedure TCapsule.DrawPoint(Color:Byte);
var X,Y:Word;
begin
  X:=Round(PosX);
  Y:=Round(PosY);
  Pixel(X,Y,Color);
  Draw(X-1,Y-1,X+1,Y+1);
end;

Procedure TCapsule.MakeMove;
begin
  PosX:=PosX+DepX;
  PosY:=PosY+DepY;
end;

Destructor TCapsule.Done;
begin
end;

Constructor TRacket.Init(APosX,APosY,AIntAngle:Integer);
begin
  PosX:=APosX;
  PosY:=APosY;
  IntAngle:=AIntAngle;
  ConvertAngle;
end;

Procedure TRacket.ConvertAngle;
begin
  IntAngle:=IntAngle mod AnglePrecision;
  Angle:=(IntAngle*Pi*2)/AnglePrecision;
end;

Procedure TRacket.Draws(Color:Byte);
var Cosi,Sinu,X1,Y1,X2,Y2:Real;  i:Byte;
begin
  Cosi:=Cos(Angle);
  Sinu:=Sin(Angle);
  X1:=PosX;
  Y1:=PosY;
  X2:=PosX;
  Y2:=PosY;
  Pixel(PosX,PosY,Color);
  for i:=0 to (RacketLength div 2)-1 do begin
    X1:=X1-Cosi;
    X2:=X2+Cosi;
    Y1:=Y1-Sinu;
    Y2:=Y2+Sinu;
    Positions[RacketLength div 2-i].X:=Round(X1);
    Positions[RacketLength div 2-i].Y:=Round(Y1);
    Positions[RacketLength div 2+i].X:=Round(X2);
    Positions[RacketLength div 2+i].Y:=Round(Y2);
    Pixel(Round(X1),Round(Y1),Color);
    Pixel(Round(X2),Round(Y2),Color);
  end;
  Sort(X1,X2);
  Sort(Y1,Y2);
  BordX1:=Round(X1)-5;
  BordX2:=Round(X2)+5;
  BordY1:=Round(Y1)-5;
  BordY2:=Round(Y2)+5;
  Draw(BordX1,BordY1,BordX2,BordY2);
end;

Procedure TRacket.Move(Dir:TDirection);
Const Speed=1;
begin
  Case Dir of
    Right:Inc(PosX,Speed);
    Left:Dec(PosX,Speed);
    Up:Dec(PosY,Speed);
    Down:Inc(PosY,Speed);
  end;
end;

Function TRacket.ImpactPoint(Capsule:PCapsule):Integer;
var i,Position:Integer;Dist,NewDist:Real;
begin
  Dist:=999;
  For i:=0 to RacketLength-1 do begin
    NewDist:=Sqr(Capsule^.PosX-Positions[i].X)+Sqr(Capsule^.PosY-Positions[i].Y);
    if NewDist<Dist then begin
      Dist:=NewDist;
      Position:=i;
    end;
  end;
  ImpactPoint:=Position;
end;

Destructor TRacket.Done;
begin
end;

Procedure TCapsule.Makebounce(var Racket:TRacket);
Const RacketForce=0.2;
var ForceY,ForceX:Real;Impact:Integer;
begin
  DepY:=-DepY;
  CalculAngleRayon;
  Angle:=Angle-2*Racket.Angle;
  CalculXY;
  if Owner^.OrderPlayer.GRight then DepX:=DepX+RacketForce;
  if Owner^.OrderPlayer.GLeft then DepX:=DepX-RacketForce;
  if Owner^.OrderPlayer.GUp then DepY:=DepY-RacketForce;
  if Owner^.OrderPlayer.GDown then DepY:=DepY+RacketForce;
  if Owner^.OrderPlayer.GTurnTrigo or Owner^.OrderPlayer.GTurnAntiTrigo then begin
    Impact:=Racket.ImpactPoint(@Self);
    if Impact<>RacketLength div 2 then begin
      ForceX:=Cos(Racket.Angle)*RacketForce*((Impact-RacketLength div 2) div (RacketLength div 4));
      ForceY:=Sin(Racket.Angle)*RacketForce*((Impact-RacketLength div 2) div (RacketLength div 4));
      if Owner^.OrderPlayer.GTurnTrigo then begin
        DepX:=DepX+ForceY;
        DepY:=DepY-ForceX;
      end;
      if Owner^.OrderPlayer.GTurnAntiTrigo then begin
        DepX:=DepX-ForceY;
        DepY:=DepY+ForceX;
      end;
    end;
  end;
  CalculAngleRayon;
  BounceTimer:=BounceDelay;
end;

Function Collides(Racket:TRacket;Truc:PCapsule):Boolean;
var i,X,Y:Integer;Result:Boolean;
begin
  Result:=False;
  X:=Round(Truc^.PosX);
  Y:=Round(Truc^.PosY);
  if (X>Racket.BordX1) and (X<Racket.BordX2)
  and (Y>Racket.BordY1) and (Y<Racket.BordY2) then begin
    for i:=0 to RacketLength-1 do Result:=Result or
    ( (Abs(X-Racket.Positions[i].X)<2) and (Abs(Y-Racket.Positions[i].Y)<2) )
  end;
  Collides:=Result;
end;

Constructor TObstacle.Init(AX1,AY1,AX2,AY2:Word);
begin
  X1:=AX1;
  Y1:=AY1;
  X2:=AX2;
  Y2:=AY2;
end;

Procedure TObstacle.Draws;
begin
  Square(X1,Y1,X2,Y2,12);
  Draw(X1,Y1,X2,Y2);
end;

Procedure TObstacle.HandleCollisions(Capsule:PCapsule);
begin
  With Capsule^ do begin
    if (PosX<X2) and (PosX>X1) then
    if ((PosY-Y1<3) and (PosY-Y1>0) and (DepY>0)) or
    ((Y2-PosY<3) and (Y2-PosY>0) and (DepY<0)) then begin
      DepY:=-DepY;
      CalculAngleRayon;
    end;
    if (PosY<Y2) and (PosY>Y1) then
    if ((PosX-X1<3) and (PosX-X1>0) and (DepX>0)) or
    ((X2-PosX<3) and (X2-PosX>0) and (DepX<0)) then begin
      DepX:=-DepX;
      CalculAngleRayon;
    end;
  end;
end;

Destructor TObstacle.Done;
begin
end;

Constructor TTotem.Init(AX,AY:Word);
begin
  X:=AX;
  Y:=AY;
  MouthY:=Y+10;
  MouthX1:=X+23;
  MouthX2:=MouthX1+20;
  ArmLeft.Init(X,Y+10,X+20,Y+20);
  ArmRight.Init(X+47,Y+10,X+20+47,Y+20);
  BorderLeft.Init(X+21,Y+10,X+24,Y+50);
  BorderRight.Init(X+21+23,Y+10,X+24+23,Y+50);
end;

Procedure TTotem.Draws;
begin
  ArmLeft.Draws;
  ArmRight.Draws;
  BorderLeft.Draws;
  BorderRight.Draws;
end;

Procedure TTotem.HandleInteractions(Capsule:PCapsule);
begin
  ArmLeft.HandleCollisions(Capsule);
  ArmRight.HandleCollisions(Capsule);
  BorderLeft.HandleCollisions(Capsule);
  BorderRight.HandleCollisions(Capsule);
{  With Capsule do
  if (PosX<MouthX2) and (PosX>MouthX1) and (PosY<MouthY+30) then begin
    AddScore(1);
  end;}
end;

Destructor TTotem.Done;
begin
end;

Constructor TStatusBar.Init;
begin
  Score:=0;
  TranspText(180-TextLength('SCORE : '),0,'SCORE : ',13,5,True);
  TranspText(180,0,'0',13,5,True);
  Draw(0,0,319,10);
  AfficheAll;
end;

Procedure TStatusbar.AddScore(Nbr:Integer);
  Function IntToStr(Nbr:Integer):string;
  var S:string;
  begin
    Str(Nbr,S);
    IntToStr:=S;
  end;
begin
  FilledSquare(180,0,180+TextLength(IntToStr(Score)),8,0);
  Inc(Score,Nbr);
  Transptext(180,0,IntToStr(Score),13,5,True);
  Draw(160,0,180+TextLength(IntToStr(Score)),8);
  Affiche;
end;

Destructor TStatusBar.Done;
begin
end;

Constructor TUniverse.Init;
begin
  Randomize;
  MCGAScreen;
  LoadCarac;
  Racket.Init(160,150,0);
{  Point.Init(50,50,-0.5,1,0,0);
  Point.CalculAngleRayon;       }
  Totem.Init(200,149);
  StatusBar.Init;
  Capsules.Init(5,1);
  AdvKeyOn;
  NbrCapsules:=0;
  AddCapsule(50,50);
end;

{
Init(APosX,APosY,ADepX,ADepY,AAngle,ARayon:Real);}

Procedure TUniverse.AddCapsule(X,Y:Real);
var ToInsert:PCapsule;
begin
  ToInsert:=New(PCapsule,Init(X,Y,-0.5,1,Pi/4+Pi*Random/2,Random+0.5,@Self));
  ToInsert^.CalculXY;
  Capsules.Insert(ToInsert);
  Inc(NbrCapsules);
end;

Procedure TUniverse.TakeOrders;
begin
  With OrderPlayer do begin
    GLeft:=K_Left;
    GRight:=K_Right;
    if GLeft and GRight then begin
      GLeft:=False;
      GRight:=False;
    end;
    GUp:=K_Up;
    GDown:=K_Down;
    if GUp and GDown then begin
      GUp:=False;
      GDown:=False;
    end;
    GTurnTrigo:=K_N;
    GTurnAntiTrigo:=K_B;
    if GTurnTrigo and GTurnAntiTrigo then begin
      GTurnTrigo:=False;
      GTurnAntiTrigo:=False;
    end;
    GQuit:=K_Esc;
  end;
end;

Function AngleCorrect(IntAngl:Integer):Boolean;
begin
  IntAngl:=IntAngl mod AnglePrecision;
  if IntAngl<0 then IntAngl:=AnglePrecision+IntAngl;
  AngleCorrect:=( (IntAngl>=0) and (IntAngl<=StopAngle1) ) or
  ( (IntAngl>=StopAngle2) and (IntAngl<=AnglePrecision) );
end;

Procedure TUniverse.Play;
var i:Word;
begin
  Repeat
    TakeOrders;
    Racket.Draws(0);
    if Racket.MoveTime=0 then With OrderPlayer do begin
      if GUp and (Racket.PosY>StopY1) then Racket.Move(Up);
      if GDown and (Racket.PosY<StopY2) then Racket.Move(Down);
      if GLeft and (Racket.PosX>StopX1) then Racket.Move(Left);
      if GRight and (Racket.PosX<StopX2) then Racket.Move(Right);
      if GTurnTrigo and AngleCorrect(Racket.IntAngle+1) then Inc(Racket.IntAngle);
      if GTurnAntiTrigo and AngleCorrect(Racket.IntAngle-1) then Dec(Racket.IntAngle);
      if GTurnTrigo or GTurnAntiTrigo then Racket.ConvertAngle;
      Racket.MoveTime:=RacketSlow;
    end else Dec(Racket.MoveTime);
    Racket.Draws(12);
    Affiche;


    Totem.Draws;
    Affiche;

    For i:=0 to NbrCapsules-1 do With PCapsule(Capsules.At(i))^ do begin
      DrawPoint(0);
      MakeMove;
      if ((PosX<=1) and (DepX<0)) or ((PosX>319.0) and (DepX>0)) then begin
        DepX:=-DepX;
        CalculAngleRayon;
      end;
      if ((PosY<10) and (DepY<0)) or ((PosY>199.0) and (DepY>0)) then begin
        DepY:=-DepY;
        CalculAngleRayon;
      end;
      if BounceTimer>0 then Dec(BounceTimer);
      if (BounceTimer=0) and (Collides(Racket,PCapsule(Capsules.At(i)))) then MakeBounce(Racket);
      Totem.HandleInteractions(PCapsule(Capsules.At(i)));
      DrawPoint(10);
      Affiche;
    end;

    Delay(5);
  Until OrderPlayer.GQuit;
end;

destructor TUniverse.Done;
var i:Word;
begin
  Totem.Done;
  StatusBar.Done;
{  Point.Done;}
  Racket.Done;
  CloseScreen;
  AdvKeyOff;
end;

var
  Universe:TUniverse;

begin
  Universe.Init;
  Universe.Play;
  Universe.Done;
end.