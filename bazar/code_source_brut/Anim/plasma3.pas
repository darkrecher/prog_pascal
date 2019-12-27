uses MCGAGraf,Crt;

type
  PPixeled=^TPixeled;
  TPixeled=Array[0..319,0..199] of Boolean;


var
  Zoom,DivZoom:Byte;
  i,j:Integer;
  Pixeled:PPixeled;
  C:Char;
  Stop:Boolean;

Procedure PlasmaPixel(X,Y,DistX,DistY:Integer);
var Color:Integer;Diviseur:Byte;
begin
  if Pixeled^[X,Y]=False then begin
    Diviseur:=0;
    Color:=0;
    if (X>0) and (X<256) then begin
      if (Y>0) and (Y<128) then begin
        if Pixeled^[X-DistX,Y-DistY] and Pixeled^[X+DistX,Y+DistY] then begin
          Color:=Buffer^[Y-DistY,X-DistX];
          Inc(Color,Buffer^[Y+DistY,X+DistX]);
          Diviseur:=2;
        end;
        if Pixeled^[X+DistX,Y-DistY] and Pixeled^[X-DistX,Y+DistY] then begin
          Inc(Color,Buffer^[Y-DistY,X+DistX]);
          Inc(Color,Buffer^[Y+DistY,X-DistX]);
          Inc(Diviseur,2);
        end;
      end;
      if Pixeled^[X+DistX,Y] and Pixeled^[X-DistX,Y] then begin
          Inc(Color,Buffer^[Y,X+DistX]);
          Inc(Color,Buffer^[Y,X-DistX]);
          Inc(Diviseur,2);
      end;
    end;
    if (Y>0) and (Y<128) then if Pixeled^[X,Y-DistY] and Pixeled^[X,Y+DistY] then begin
      Inc(Color,Buffer^[Y-DistY,X]);
      Inc(Color,Buffer^[Y+DistY,X]);
      Inc(Diviseur,2);
    end;
    Color:=Color div Diviseur;
    Inc(Color,Random(DistX*Zoom div divZoom+1)-DistX*Zoom div (2*DivZoom));
    if Color<0 then Color:=0;
    if Color>255 then Color:=255;
    Buffer^[Y,X]:=Color;
    Pixeled^[X,Y]:=True;
  end;
end;

Procedure Quadrillage(DistX,DistY:Integer);
var i,j:Integer;
begin
  for j:=0 to 128 div DistY do begin
    for i:=0 to 256 div DistX do PlasmaPixel(i*DistX,j*DistY,DistX,DistY);
  end;
end;

Procedure Plasma;
var i,j:Integer;
begin
  for i:=0 to 256 do for j:=0 to 128 do Pixeled^[i,j]:=False;
  Pixel(0,0,Random(256));
  Pixel(256,0,Random(256));
  Pixel(0,128,Random(256));
  Pixel(256,128,Random(256));
  Pixeled^[0,0]:=True;
  Pixeled^[0,128]:=True;
  Pixeled^[256,0]:=True;
  Pixeled^[256,128]:=True;
  j:=128;
  for i:=0 to 6 do begin
    Quadrillage(j,j div 2);
    j:=j div 2;
  end;
  Quadrillage(1,1);
end;

Function Fondu:Boolean;
var i,j:Integer;Result:Boolean;Screen,Buf:Byte;
begin
  Result:=True;
  for i:=0 to 256 do for j:=0 to 128 do begin
    Screen:=Video^[j,i];
    Buf:=Buffer^[j,i];
    if Screen>Buf then begin
      Dec(Video^[j,i]);
      Result:=False;
    end;
    if Screen<Buf then begin
      Inc(Video^[j,i]);
      Result:=False;
    end;
  end;
  Fondu:=Result;
end;

begin
  MCGAScreen;
  Randomize;
  New(Pixeled);
  Degrade(0,0,0,0,127,0,0,63);
  Degrade(128,0,0,63,255,63,63,63);
  DefinePal;
  C:=' ';
  Zoom:=Random(5)+1;
  DivZoom:=Random(5)+1;
  Plasma;
  AfficheAll;
  Repeat
    Zoom:=Random(5)+1;
    DivZoom:=Random(5)+1;
    Plasma;
    i:=0;
    Repeat
      Stop:=Fondu;
      if Keypressed then begin
        C:=Readkey;
        if C=#27 then Stop:=True;
      end;
      Inc(i);
      if i=100 then Stop:=True;
    Until Stop;
  Until C=#27;
  CloseScreen;
  Dispose(Pixeled);
end.
