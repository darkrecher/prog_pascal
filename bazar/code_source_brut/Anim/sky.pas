Uses Crt,Dos;

Type
  Screen=Array[0..199,0..319] of Byte;
  PElement=^TElement;
  Telement=Screen;

Var
  Video,Bouffeur:PElement;
  x,y,ScreenX1,ScreenX2,ScreenY1,ScreenY2:Integer;
  TakeColor:Byte;
  Timer:Boolean;

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

Procedure DefinePal4;
var i:Byte;Pal:Array[0..255,0..2] of Byte;Reg:Registers;
begin
  for i:=0 to 63 do begin
    Pal[i,0]:=i;
    Pal[i,1]:=i;
    Pal[i,2]:=i;
  end;
  for i:=64 to 127 do begin
    Pal[i,0]:=63-i;
    Pal[i,1]:=63-i;
    Pal[i,2]:=63;
  end;
  for i:=128 to 191 do begin
    Pal[i,0]:=0;
    Pal[i,1]:=0;
    Pal[i,2]:=63-i;
  end;
  Reg.AH:=$0010;
  Reg.AL:=$0012;
  Reg.BX:=$0000;
  Reg.CX:=$0100;
  Reg.ES:=Seg(Pal);
  Reg.DX:=Ofs(Pal);
  Intr($10,Reg);
end;

begin
  MegaScreen;
  DefinePal4;
  Randomize;
  for x:=0 to 319 do for y:=0 to 199 do Bouffeur^[y,x]:=Random(192);
  While keypressed do Readkey;
  Repeat
    Draw(0,0,319,199);
    Affiche;
    for x:=1 to 318 do for y:=1 to 198 do begin
{      TakeColor:=Random(9);
      if x=0 then Inc(TakeColor);
      if x=319 then Dec(TakeColor);
      if y=0 then Inc(TakeColor,3);
      if y=199 then Dec(TakeColor,3);
      Case TakeColor of
        0:Bouffeur^[y,x]:=Video^[y-1,x-1];
        1:Bouffeur^[y,x]:=Video^[y-1,x];
        2:Bouffeur^[y,x]:=Video^[y-1,x+1];
        3:Bouffeur^[y,x]:=Video^[y,x-1];
        5:Bouffeur^[y,x]:=Video^[y,x+1];
        6:Bouffeur^[y,x]:=Video^[y+1,x-1];
        7:Bouffeur^[y,x]:=Video^[y+1,x];
        8:Bouffeur^[y,x]:=Video^[y+1,x+1];
      end;}
      if not((x in [150..170]) and (y in[90..110])) then
      Bouffeur^[y,x]:=(Video^[y+1,x]+Video^[y-1,x]+Video^[y,x+1]+Video^[y,x-1]+Video^[y,x]) div 5-1;
    end;
  Until keypressed;
  Dispose(Bouffeur);
end.
