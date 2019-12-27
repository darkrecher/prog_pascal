Uses Crt,Dos;

Type
  Screen=Array[0..199,0..319] of Byte;
  PElement=^TElement;
  Telement=Screen;

Var
  Pal:Array[0..255,0..2] of Byte;
  Video,Bouffeur:PElement;
  x,y:Integer;
  ScreenX1,ScreenX2,ScreenY1,ScreenY2:Integer;
  Reg:Registers;
  ColorOfDepart:Byte;

Const
  Flag:Byte=0;

Procedure NewInt8;Interrupt;
begin
  Inc(Flag);
end;

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

Procedure CloseScreen;
begin
  Asm
    Mov AH,$0000;
    Mov AL,$003;
    Int $10;
  end;
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

Procedure DefinePal;
var i,j:Byte;
begin
  for j:=0 to 6 do begin
    for i:=1 to 16 do begin
      if not(Odd(j)) then Pal[j*32+i+31,0]:=i*4-1 else Pal[j*32+i+31,0]:=0;
      if (j mod 4=1) or (j mod 4=2) then Pal[j*32+i+31,1]:=i*4-1 else Pal[j*32+i+31,1]:=0;
      if J>2 then Pal[j*32+i+31,2]:=i*4-1 else Pal[j*32+i+31,2]:=0;
    end;
    for i:=1 to 16 do begin
      if (Odd(j)) then Pal[j*32+i+47,0]:=i*4-1 else Pal[j*32+i+47,0]:=63;
      if (j mod 4=3) or (j mod 4=0) then Pal[j*32+i+47,1]:=i*4-1 else Pal[j*32+i+47,1]:=63;
      if J<=2 then Pal[j*32+i+47,2]:=i*4-1 else Pal[j*32+i+47,2]:=63;
    end;
  end;
  Pal[15,0]:=40;
  Pal[15,1]:=40;
  Pal[15,2]:=40;
end;

var Base:Word;

{Function Random(N:Word):Word;
begin
  asm
    mov ax,Base
    ror ax,1
    xor Base,ax
    inc Base
  end;
  Random:=Base mod N;
end;}

Function InferieurA223(x:Byte):Byte;
begin
  if x<223 then InferieurA223:=x else InferieurA223:=0;
end;

Procedure CreateFlame(X,Y:Integer;Color:Byte);
begin
  Bouffeur^[Y,X]:=Color;
  if Color>InferieurA223(ColorOfDepart-32) then begin
    CreateFlame(X,Y-1,Color-Random(5)-1);
    if Random(2)=0 then CreateFlame(X-1,Y-1,Color-Random(5)-1);
    if Random(2)=0 then CreateFlame(X+1,Y-1,Color-Random(5)-1);
  end;
end;

Procedure DarkSquare(x1,y1,x2,y2:Integer);
var i:Integer;
begin
  for i:=y1 to y2 do FillChar(Bouffeur^[i,x1],x2-x1+1,0);
end;

var
  OldInt8:Pointer;

begin
  GetIntVec($1C,OldInt8);
  SetIntVec($1C,@NewInt8);
  MegaScreen;
  Randomize;
  Base:=System.Random(65535);
  DefinePal;
  Reg.AH:=$0010;
  Reg.AL:=$0012;
  Reg.BX:=$0000;
  Reg.CX:=$0100;
  Reg.ES:=Seg(Pal);
  Reg.DX:=Ofs(Pal);
  Intr($10,Reg);
  ColorOfDepart:=95;
  While KeyPressed do Readkey;
  Repeat
    Repeat Until Flag>=3;
    DarkSquare(15,15,85,50);
    CreateFlame(50,50,ColorOfDepart);
    Inc(ColorOfDepart);
    Draw(15,15,85,50);
    Affiche;
    Flag:=0;
  Until keypressed;
  CloseScreen;
  SetIntVec($1C,OldInt8);
end.