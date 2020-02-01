uses dos,dosfile,Crt;

Const
  Larg=80;
  Haut=10;

Type
  Screen=Array[0..199,0..319] of Byte;
  PElement=^TElement;
  Telement=Screen;

var
  Video,Bouffeur:PElement;
  Eye:Array[0..79,0..9] of Byte;
  ScreenY1,ScreenY2,ScreenX1,ScreenX2:Integer;
  i,j:Integer;

Procedure MegaScreen;
var x,y:integer;
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

Procedure DefinePal;
var Pal:Array[0..4,0..2] of Byte;Reg:Registers;
begin
  for i:=0 to 2 do for j:=0 to 1 do Pal[j,i]:=0;
  for i:=0 to 2 do Pal[2,i]:=63;
  Pal[3,0]:=63;
  Pal[3,1]:=58;
  Pal[3,2]:=0;
  Pal[4,0]:=60;
  Pal[4,1]:=47;
  Pal[4,2]:=26;
  Reg.AH:=$0010;
  Reg.AL:=$0012;
  Reg.BX:=$0000;
  Reg.CX:=$0005;
  Reg.ES:=Seg(Pal);
  Reg.DX:=Ofs(Pal);
  Intr($10,Reg);
end;

Procedure Affiche;
var i:Integer;
begin
  for i:=ScreenY1 to ScreenY2 do Move(Bouffeur^[i,ScreenX1],Video^[i,ScreenX1],ScreenX2-ScreenX1+1);
  ScreenX1:=319;
  ScreenX2:=0;
  ScreenY1:=199;
  ScreenY2:=0;
end;

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

Procedure DarkSquare(x1,y1,x2,y2:Integer);
var i,j:Integer;
begin
  for i:=y1 to y2 do FillChar(Bouffeur^[i,x1],x2-x1+1,0)
end;

Procedure TakeSprite;
var i,j:Byte;H:Handle;Truc:Array[0..799] of Byte;
begin
  FOpen(H,'turn.spr');
  FRead(H,Truc[0],800);
  FClose(H);
  for i:=0 to 79 do for j:=0 to 9 do Eye[i,j]:=Truc[i+80*j];
end;

Procedure TheEye(X,Y,NoModulatedAngle:Byte;CoefSize:Real);{0<angle<200}
var EcranX,EcranY,RoundedX,RoundedY,L,H:Integer;ImageX,ImageY,ax,ay,bx,by,MemoryX,MemoryY:Real;Angle:Byte;
begin
  Angle:=NoModulatedAngle mod 200;
  ax:=Cos((Angle/100)*Pi);
  ay:=Sin((Angle/100)*Pi);
  if Angle in [0..50] then begin
    L:=Trunc(((Haut div 2+(Larg div 2)*ax)+1)/CoefSize);
    H:=Trunc(((Haut div 2+(Larg div 2)*ay)+1)/CoefSize);
  end else if Angle in [51..100] then begin
    L:=Trunc(((Haut div 2+(Larg div 2)*-ax)+1)/CoefSize);
    H:=Trunc(((Haut div 2+(Larg div 2)*ay)+1)/CoefSize);
  end else if Angle in [100..150] then begin
    L:=Trunc(((Haut div 2+(Larg div 2)*-ax)+1)/CoefSize);
    H:=Trunc(((Haut div 2+(Larg div 2)*-ay)+1)/CoefSize);
  end else if Angle in [151..199] then begin
    L:=Trunc(((Haut div 2+(Larg div 2)*ax)+1)/CoefSize);
    H:=Trunc(((Haut div 2+(Larg div 2)*-ay)+1)/CoefSize);
  end;
  if Abs(L)>Abs(H) then H:=L else L:=H;
  ax:=ax*CoefSize;
  ay:=ay*CoefSize;
  bx:=ay;
  by:=-ax;
{  if L<0 then L:=-L;
  if H<0 then H:=-H;}
  ImageX:=-L*ax-H*bx;
  ImageY:=-L*ay-H*by;
  MemoryX:=ImageX;
  MemoryY:=ImageY;
  for EcranY:=Y-H to Y+H do begin
    ImageX:=MemoryX;
    ImageY:=MemoryY;
    for EcranX:=X-L to X+L do begin
      RoundedX:=Round(ImageX)+Larg div 2;
      RoundedY:=Round(ImageY)+Haut div 2;
      if (RoundedX in [0..Larg-1]) and (RoundedY in [0..Haut-1]) then
      Bouffeur^[EcranY,EcranX]:=Eye[RoundedX,RoundedY];
      ImageX:=ImageX+ax;
      ImageY:=ImageY+ay;
    end;
    MemoryX:=MemoryX+bx;
    MEmoryY:=MemoryY+by;
  end;
  Draw(X-L,Y-H,X+L,Y+H);
  Affiche;
  DarkSquare(X-L,Y-H,X+L,Y+H);
end;

begin
  MegaScreen;
  DefinePal;
  TakeSprite;
  i:=100;
  j:=0;
  Repeat
    TheEye(160,100,i,0.75+0.002*Abs(j));
    Inc(i);
    Inc(j);
    if j=700 then j:=-700;
    if i=200 then i:=0;
  Until keypressed;
  Dispose(Bouffeur);
end.

