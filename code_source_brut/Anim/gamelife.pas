Uses Crt,Dos;

Type
  Screen=Array[0..199,0..319] of Byte;
  PElement=^TElement;
  Telement=Screen;
  PLotsOfPunyLittleHuman=^TLotsOfPunyLittleHuman;
  TLotsOfPunyLittleHuman=Array[-1..320,-1..200] of Boolean;

Var
  Reg:Registers;
  Pal:Array[0..255,0..2] of Byte;
  Video,Bouffeur:PElement;
  World,NewWorld:PLotsOfPunyLittleHuman;
  x,y,i,LimX,LimY,Color,Timer:Integer;
  ColorTab:Array[0..319] of Byte;

Procedure MegaScreen;
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
var i,Light:Byte;
begin
  for Light:=0 to 1 do begin
    for i:=0 to 15 do begin
      Pal[Light*128+i,0]:=31+Light*32;
      Pal[Light*128+i,1]:=31-2*i+Light*32;
      Pal[Light*128+i,2]:=31-2*i+Light*32;
    end;
    for i:=16 to 31 do begin
      Pal[Light*128+i,0]:=31+Light*32;
      Pal[Light*128+i,1]:=Light*32;
      Pal[Light*128+i,2]:=2*(i-16)+Light*32;
    end;
    for i:=32 to 47 do begin
      Pal[Light*128+i,0]:=31-2*(i-32)+Light*32;
      Pal[Light*128+i,1]:=Light*32;
      Pal[Light*128+i,2]:=31+Light*32;
    end;
    for i:=48 to 63 do begin
      Pal[Light*128+i,0]:=Light*32;
      Pal[Light*128+i,1]:=2*(i-48)+Light*32;
      Pal[Light*128+i,2]:=31+Light*32;
    end;
    for i:=64 to 79 do begin
      Pal[Light*128+i,0]:=Light*32;
      Pal[Light*128+i,1]:=31+Light*32;
      Pal[Light*128+i,2]:=31-2*(i-64)+Light*32;
    end;
    for i:=80 to 95 do begin
      Pal[Light*128+i,0]:=2*(i-80)+Light*32;
      Pal[Light*128+i,1]:=31+Light*32;
      Pal[Light*128+i,2]:=Light*32;
    end;
    for i:=96 to 111 do begin
      Pal[Light*128+i,0]:=31-2*(i-96)+Light*32;
      Pal[Light*128+i,1]:=31-2*(i-96)+Light*32;
      Pal[Light*128+i,2]:=Light*32;
    end;
    for i:=112 to 127 do begin
      Pal[Light*128+i,0]:=2*(i-112)+Light*32;
      Pal[Light*128+i,1]:=2*(i-112)+Light*32;
      Pal[Light*128+i,2]:=2*(i-112)+Light*32;
    end;
  end;
  Pal[0,0]:=0;
  Pal[0,1]:=0;
  Pal[0,2]:=0;
end;

Procedure Affiche;
var i:Integer;
begin
  for i:=0 to 199 do Move(Bouffeur^[i,0],Video^[i,0],320);
end;


Function CountPeople(X,Y:Integer):Byte;
var People:Byte;
begin
  People:=0;
  if World^[X+1,Y-1] then Inc(People);
  if World^[X+1,Y] then Inc(People);
  if World^[X+1,Y+1] then Inc(People);
  if World^[X,Y+1] then Inc(People);
  if World^[X,Y-1] then Inc(People);
  if World^[X-1,Y+1] then Inc(People);
  if World^[X-1,Y] then Inc(People);
  if World^[X-1,Y-1] then Inc(People);
  CountPeople:=People;
end;

begin
  MegaScreen;
  DefinePal2;
  Reg.AH:=$0010;
  Reg.AL:=$0012;
  Reg.BX:=$0000;
  Reg.CX:=$0100;
  Reg.ES:=Seg(Pal);
  Reg.DX:=Ofs(Pal);
  Intr($10,Reg);
  Randomize;
  New(World);
  New(NewWorld);
  LimX:=320;
  LimY:=200;
  for i:=0 to LimX-1 do ColorTab[i]:=Round(128/LimX*i);
  Timer:=0;
  for y:=0 to 1 do for x:=-1 to 320 do World^[x,-1+y*(LimY+1)]:=False;
  for x:=0 to 1 do for y:=-1 to 200 do World^[-1+x*(LimX+1),y]:=False;
  for y:=0 to 1 do for x:=-1 to 320 do NewWorld^[x,-1+y*(LimY+1)]:=False;
  for x:=0 to 1 do for y:=-1 to 200 do NewWorld^[-1+x*(LimX+1),y]:=False;
  for x:=0 to LimX-1 do for y:=0 to LimY-1 do if Random(2)=0 then World^[x,y]:=True else World^[x,y]:=False;
  Repeat
    for x:=0 to LimX-1 do for y:=0 to LimY-1 do if World^[x,y] then begin
      if CountPeople(x,y) in [2,3] then NewWorld^[x,y]:=True else NewWorld^[x,y]:=False;
    end else if CountPeople(x,y)=3 then NewWorld^[x,y]:=True else NewWorld^[x,y]:=False;
    for x:=0 to LimX-1 do Move(NewWorld^[x,0],World^[x,0],LimY);
    for x:=0 to LimX-1 do for y:=0 to LimY-1 do Bouffeur^[y+100-(LimY div 2),x+160-(LimX div 2)]:=
      Timer+ColorTab[x]+Ord(World^[x,y])*128-Ord(ColorTab[x]+Timer>127)*127;
    Affiche;
    Inc(Timer);
    if Timer=128 then Timer:=0;
  Until KeyPressed;
  Dispose(World);
  Dispose(NewWorld);
  Dispose(Bouffeur);
end.

