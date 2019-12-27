Uses Crt,Dos,DosFile;

Type
  Screen=Array[0..199,0..319] of Byte;
  PElement=^TElement;
  Telement=Screen;

Var
  Pal:Array[0..255,0..2] of Byte;
  Video,Bouffeur:PElement;
  ScreenX1,ScreenX2,ScreenY1,ScreenY2,X,Y1,DepY1,Lim1,Y2,DepY2,Lim2:Integer;
  UpDown1,Niok1,UpDown2,Niok2:Boolean;
  BallX,BallY,BallDepX,BallDepY:Integer;
  Rond:Array[0..8,0..8] of Byte;
  i,j:Integer;

Procedure Draw(x1,y1,x2,y2:Integer);
begin
  if ScreenX1>x1 then ScreenX1:=x1;
  if ScreenX2<x2 then ScreenX2:=x2;
  if ScreenY1>y1 then ScreenY1:=y1;
  if ScreenY2<y2 then ScreenY2:=y2;
  if ScreenX1<0 then ScreenX1:=0;
  if ScreenX2>319 then ScreenX2:=319;
  if ScreenY1<0 then ScreenY1:=0;
  if ScreenY2>199 then ScreenY2:=199;
end;

Procedure MegaScreen;
var y,x:Integer;
begin
  Asm
    Mov AH,$0000;
    Mov AL,$0013;
    Int $10;
  end;
  Video:=Addr(Mem[$A000:$0000]);
  New(Bouffeur);
  for y:=0 to 199 do for x:=0 to 319 do begin
    Video^[y,x]:=0;
    Bouffeur^[y,x]:=0;
  end;
end;

Procedure DefinePal2;
var i:Byte;Reg:Registers;
begin
  for i:=0 to 31 do begin
    Pal[i,0]:=i*2;
    Pal[i,1]:=0;
    Pal[i,2]:=0;
    Pal[i+32,0]:=63;
    Pal[i+32,1]:=i*2;
    Pal[i+32,2]:=0;
    Pal[i+64,0]:=63-(i*2);
    Pal[i+64,1]:=63;
    Pal[i+64,2]:=0;
    Pal[i+96,0]:=0;
    Pal[i+96,1]:=63;
    Pal[i+96,2]:=i*2;
    Pal[i+128,0]:=0;
    Pal[i+128,1]:=63-(i*2);
    Pal[i+128,2]:=63;
    Pal[i+160,0]:=i*2;
    Pal[i+160,1]:=0;
    Pal[i+160,2]:=63;
    Pal[i+192,0]:=63;
    Pal[i+192,1]:=i*2;
    Pal[i+192,2]:=63;
    Pal[i+224,0]:=63-(i*2);
    Pal[i+224,1]:=63-(i*2);
    Pal[i+224,2]:=63-(i*2);
  end;
  Reg.AH:=$0010;
  Reg.AL:=$0012;
  Reg.BX:=$0000;
  Reg.CX:=$0100;
  Reg.ES:=Seg(Pal);
  Reg.DX:=Ofs(Pal);
  Intr($10,Reg);
end;

Procedure DefinePal3;
var i:Byte;Reg:Registers;
function Courbe(i:Integer):Byte;
begin
  case (i div 64) mod 6 of
    0,5:Courbe:=63;
    1:Courbe:={63-(i mod 64);}Trunc(31.5*(1+cos((i mod 64)*pi/64)));
    2,3:Courbe:=0;
    4:Courbe:={i mod 64;}Trunc(31.5*(1+cos((i mod 64)*pi/64+pi)));
  end;
end;
begin
  for i:=1 to 255 do begin
    Pal[i,0]:=Courbe(i*LongInt(384) div 256);
    Pal[i,1]:=Courbe(i*LongInt(384) div 256+256);
    Pal[i,2]:=Courbe(i*LongInt(384) div 256+128);
  end;
  Reg.AH:=$0010;
  Reg.AL:=$0012;
  Reg.BX:=$0000;
  Reg.CX:=$0100;
  Reg.ES:=Seg(Pal);
  Reg.DX:=Ofs(Pal);
  Intr($10,Reg);
end;

Procedure Affiche;
var i:Integer;
begin
  for i:=ScreenY1 to ScreenY2 do Move(Bouffeur^[i,ScreenX1],Video^[i,ScreenX1],ScreenX2-ScreenX1+1);
end;

Procedure ScrollRight(DepX:Integer);
var i,j:Integer;
begin
  for i:=0 to 199 do begin
    Move(Bouffeur^[i,DepX],Bouffeur^[i,0],318);
    for j:=0 to DepX do Bouffeur^[i,319-j]:=0;
  end;
  Draw(0,0,319,199);
  Affiche;
end;

Procedure Sinusoid(X:Integer;var Y,DepY,Lim:Integer;var UpDown,Niok:Boolean);
begin
  Inc(Y,DepY div 16);
  if UpDown then Inc(DepY,1) else Dec(DepY,1);
  if DepY=0 then Niok:=True;
  if Niok and (Abs(DepY)=Lim) then begin
    UpDown:=not(Updown);
    Niok:=False;
    Lim:=Random(75)+32;
    if UpDown then DepY:=-Lim else DepY:=Lim;
  end;
end;

Procedure InitSinusoid(DepartY:Integer;var Y,Lim,DepY:Integer;var UpDown,Niok:Boolean);
begin
  Y:=DepartY;
  Lim:=Random(128)+16;
  DepY:=Lim1;
  UpDown:=False;
  Niok:=False;
end;

{Procedure LineVertic(Pt1,Pt2,Pt3:Integer;Color:Byte);
var i:Integer;
begin
  for i:=Pt2 to Pt3 do Bouffeur^[i,Pt1]:=Color;
end;}

Procedure LineFade(Pt1,Pt2,Pt3:Integer);
var i:Integer;AddColor,Color:Real;
begin
  Color:=1;
  AddColor:=255/(Pt3-Pt2+Ord(Pt3=Pt2));
  for i:=Pt2 to Pt3 do begin
    Bouffeur^[i,Pt1]:=Round(Color);
    Color:=Color+AddColor;
  end;
end;

Procedure TakeSprite;
Var H:Handle;i:Integer;
begin
  FOpen(H,'fusion.spr');
  for i:=0 to 8 do FRead(H,Rond[i,0],9);
  FClose(H);
end;

Procedure AfficheRond(X,Y:Integer);
var i,j:Byte;
begin
  for i:=0 to 8 do for j:=0 to 8 do Inc(Bouffeur^[Y+i,X+j],Rond[j,i]*2);
end;

Procedure CycleColors;
var i,j:Word;
begin
  for i:=0 to 199 do for j:=0 to 319 do Inc(Bouffeur^[i,j]);
  Draw(0,0,319,199);
  Affiche;
end;

begin
  MegaScreen;
  Randomize;
  DefinePal2;
  InitSinusoid(800,Y1,Lim1,DepY1,UpDown1,Niok1);
  InitSinusoid(2400,Y2,Lim2,DepY2,UpDown2,Niok2);
  TakeSprite;
  BallX:=5120;
  BallY:=1600;
  BallDepX:=Random(33)-16;
  BallDepY:=Random(33)-16;
  for X:=0 to 5104 do begin
    Sinusoid(X,Y1,Lim1,DepY1,UpDown1,Niok1);
    Sinusoid(X,Y2,Lim2,DepY2,UpDown2,Niok2);
    if X mod 16=0 then begin
      if Y1>Y2 then LineFade(X shr 4,Y2 shr 4,Y1 shr 4)
      else LineFade(X shr 4,Y1 shr 4,Y2 shr 4);
    end;
  end;
  Repeat
    ScrollRight(1);
    CycleColors;
    for X:=0 to 16 do begin
      Sinusoid(5088+X,Y1,Lim1,DepY1,UpDown1,Niok1);
      Sinusoid(5088+X,Y2,Lim2,DepY2,UpDown2,Niok2);
      if X=16 then begin
        if Y1>Y2 then LineFade(318,Y2 shr 4,Y1 shr 4) else LineFade(318,Y1 shr 4,Y2 shr 4);
      end;
    end;
    AfficheRond(310,BallY shr 4);
    BallX:=5120;
    Inc(BallY,BallDepY);
    Inc(BallDepY,Random(9)-4);
    if BallX<320 then Inc(BallDepX,4);
    if BallY>2880 then Dec(BallDepY,4);
    if BallY<320 then Inc(BallDepY,4);
    if BallDepX>16 then Dec(BallDepX,4);
    if BallDepY>16 then Dec(BallDepY,4);
    if BallDepY<-16 then Inc(BallDepY,4);
 {   Delay(5);}
  Until KeyPressed;
  Dispose(Bouffeur);
end.