Uses MCGAGraf,Crt;

Const

  Nothing=0;
  Linear=1;
  Elliptic=2;
  Circular=3;

  MaxNbrCycle=200;
  LinearNbrCycle=18;
  LinearDistort:Array[0..LinearNbrCycle-1,0..1] of Integer=
  ((0,0),(0,0),(1,0),(1,0),(2,0),(3,0),(4,0),(4,0),(5,0),(5,0),
  (5,0),(4,0),(4,0),(3,0),(2,0),(1,0),(1,0),(0,0));

  EllipseNbrCycle=40;
  EllipseSizeX=21;
  EllipseSizeY=7;
  ImageEllipse:Array[0..EllipseSizeY-1,0..EllipseSizeX-1] of Byte=(
  (00,00,00,00,00,00,37,38,39,40,01,02,03,04,05,00,00,00,00,00,00),
  (00,00,00,34,35,36,00,00,00,00,00,00,0,000,00,06,07,08,00,00,00),
  (00,32,33,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,09,10,00),
  (31,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,11),
  (00,30,29,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,13,12,00),
  (00,00,00,28,27,26,00,00,00,00,00,00,00,00,00,16,15,14,00,00,00),
  (00,00,00,00,00,00,25,24,23,22,21,20,19,18,17,00,00,00,00,00,00)
  );

  CircleNbrCycle=16;
  CircleSizeX=7;
  CircleSizeY=7;
  ImageCircle:Array[0..CircleSizeX-1,0..CircleSizeY-1] of Byte=(
  (00,00,01,02,03,00,00),
  (00,16,00,00,00,04,00),
  (15,00,00,00,00,00,05),
  (14,00,00,00,00,00,06),
  (13,00,00,00,00,00,07),
  (00,12,00,00,00,08,00),
  (00,00,11,10,09,00,00)
  );

  AForward=True;
  ABackward=False;

  MaxPointX=128;
  MaxpointY=80;

  Loop=1;
  PingPong=2;
  TimerEvolution=Loop;

Type
  PPoint=^TPoint;
  TPoint=Record
    X,Y,DecX,DecY:Integer;
    Color,Timer:Byte;
    ColorMove,TimerMove:Boolean;
  end;

var
  Points:Array[0..MaXPointX-1,0..MaxPointY-1] of PPoint;
  NbrPointX,NbrPointY,NbrCycle:Byte;
  Distort:Array[0..MaxNbrCycle-1,0..1] of Integer;

Procedure RainbowPal;
begin
  Degrade(0,0,0,0,37,63,0,0);
  Degrade(37,63,0,0,73,63,63,0);
  Degrade(73,63,63,0,111,0,63,0);
  Degrade(111,0,63,0,146,0,63,63);
  Degrade(146,0,63,63,182,0,0,63);
  Degrade(182,0,0,63,218,63,0,63);
  Degrade(218,63,0,63,255,63,63,63);
  DefinePal;
end;

Procedure DrawCross(X,Y:Integer;Color:Byte);
begin
  Pixel(X,Y,Color);
  Pixel(X+1,Y,Color);
  Pixel(X-1,Y,Color);
  Pixel(X,Y+1,Color);
  Pixel(X,Y-1,Color);
  Draw(X-1,Y-1,X+1,Y+1);
end;

Procedure CreatePoint(var Point:PPoint;AX,AY:Integer;ATimer,AColor:Byte;AColorMove:Boolean);
begin
  New(Point);
  With Point^ do begin
    X:=AX;
    Y:=AY;
    Timer:=ATimer;
    Color:=AColor;
    DecX:=Distort[Timer,0];
    DecY:=Distort[Timer,1];
    ColorMove:=AColorMove;
    TimerMove:=AForward;
  end;
end;

Procedure HandlePoint(Point:PPoint);
begin
  With Point^ do begin
    DrawCross(X+DecX,Y+DecY,0);
    Draw(X+DecX,Y+DecY,X+DecX,Y+DecY);
    if TimerMove=AForward then Inc(Timer) else Dec(Timer);
    if (Timer=0) and (TimerEvolution=PingPong) then TimerMove:=AForward;
    if Timer>=NbrCycle then
      if TimerEvolution=PingPong then TimerMove:=ABackWard else Timer:=0;
    if ColorMove=AForward then Inc(Color) else Dec(Color);
    if Color=0 then ColorMove:=AForward;
    if Color=255 then ColorMove:=ABackward;
    DecX:=Distort[Timer,0];
    DecY:=Distort[Timer,1];
{    DecX:=((X-160)*Distort[Timer,0]) div (NbrCycle*2);
    DecY:=((Y-160)*Distort[Timer,0]) div (NbrCycle*2);}

    DrawCross(X+DecX,Y+DecY,Color);
    Draw(X+DecX,Y+DecY,X+DecX,Y+DecY);
    Affiche;
  end;
end;

Procedure ChoseDistortion(DType:Byte);
var i,x,y:Word;
begin
  Case DType of
    Nothing:begin
      NbrCycle:=0;
      Distort[0,0]:=0;
      Distort[0,1]:=0;
    end;
    Linear:begin
      NbrCycle:=LinearNbrCycle;
      for i:=0 to LinearNbrCycle-1 do begin
        Distort[i,0]:=LinearDistort[i,0];
        Distort[i,1]:=LinearDistort[i,1];
      end;
    end;
    Elliptic:begin
      NbrCycle:=EllipseNbrCycle;
      for i:=1 to EllipseNbrCycle do begin
        for x:=0 to EllipseSizeX-1 do for y:=0 to EllipseSizeY-1 do if ImageEllipse[y,x]=i then begin
          Distort[i-1,0]:=x-EllipseSizeX div 2;
          Distort[i-1,1]:=y;
        end;
      end;
    end;
    Circular:begin
      NbrCycle:=CircleNbrCycle;
      for i:=1 to CircleNbrCycle do begin
        for x:=0 to CircleSizeX-1 do for y:=0 to CircleSizeY-1 do if ImageCircle[y,x]=i then begin
          Distort[i-1,0]:=x-CircleSizeX div 2;
          Distort[i-1,1]:=y;
        end;
      end;
    end;
  end;
end;

Procedure CreateAll(NbrX,NbrY,DistX,DistY,CornerX,CornerY:Word;ColorInc:Byte);
var x,y:Integer;
begin
  NbrPointX:=NbrX;
  NbrPointY:=NbrY;
  for x:=0 to NbrX-1 do for y:=0 to NbrY-1 do CreatePoint(Points[x,y],x*DistX+CornerX,y*DistY+CornerY,
  (Round(Sqrt(Sqr(x{-(NbrX div 2)})+Sqr(y{-(NbrY div 2)})))) mod NbrCycle,(x-y+180)*ColorInc,AForward);
end;

Procedure HandleAll;
var x,y:Integer;
begin
  for x:=0 to NbrPointX-1 do for y:=0 to NbrPointY-1 do HandlePoint(Points[x,y]);
end;

Procedure DestroyAll;
var x,y:Integer;
begin
  for x:=0 to NbrPointX-1 do for y:=0 to NbrPointY-1 do Dispose(Points[x,y]);
end;



var Point:PPoint;

begin
  MCGAScreen;
  RainBowPal;
  ChoseDistortion(Circular);
  CreateAll(32,20,10,10,4,0,2);
  Repeat
    HandleAll;
    Delay(25);
  Until keypressed;
  DestroyAll;
  CloseScreen;
end.
