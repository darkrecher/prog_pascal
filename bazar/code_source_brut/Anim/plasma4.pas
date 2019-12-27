uses MCGAGraf,Crt;

type
  PPixeled=^TPixeled;
  TPixeled=Array[0..256,0..128] of Boolean;
  PMap=^TMap;
  TMap=Array[0..128,0..256] of Byte;

  var
  Zoom,DivZoom:Byte;
  i,j:Integer;
  Pixeled:PPixeled;
  C:Char;
  Stop:Boolean;
  RedBuf,RedScr,BlueBuf,BlueScr:PMap;

Procedure PlasmaPixel(X,Y,DistX,DistY:Integer;Map:PMap);
var Color:Integer;Diviseur:Byte;
begin
  if Pixeled^[X,Y]=False then begin
    Diviseur:=0;
    Color:=0;
    if (X>0) and (X<256) then begin
      if (Y>0) and (Y<128) then begin
        if Pixeled^[X-DistX,Y-DistY] and Pixeled^[X+DistX,Y+DistY] then begin
          Color:=Map^[Y-DistY,X-DistX];
          Inc(Color,Map^[Y+DistY,X+DistX]);
          Diviseur:=2;
        end;
        if Pixeled^[X+DistX,Y-DistY] and Pixeled^[X-DistX,Y+DistY] then begin
          Inc(Color,Map^[Y-DistY,X+DistX]);
          Inc(Color,Map^[Y+DistY,X-DistX]);
          Inc(Diviseur,2);
        end;
      end;
      if Pixeled^[X+DistX,Y] and Pixeled^[X-DistX,Y] then begin
          Inc(Color,Map^[Y,X+DistX]);
          Inc(Color,Map^[Y,X-DistX]);
          Inc(Diviseur,2);
      end;
    end;
    if (Y>0) and (Y<128) then if Pixeled^[X,Y-DistY] and Pixeled^[X,Y+DistY] then begin
      Inc(Color,Map^[Y-DistY,X]);
      Inc(Color,Map^[Y+DistY,X]);
      Inc(Diviseur,2);
    end;
    Color:=Color div Diviseur;
    Inc(Color,Random(DistX*Zoom div divZoom+1)-DistX*Zoom div (2*DivZoom));
    if Color<0 then Color:=0;
    if Color>15 then Color:=15;
    Map^[Y,X]:=Color;
    Pixeled^[X,Y]:=True;
  end;
end;

Procedure Quadrillage(DistX,DistY:Integer;Map:PMap);
var i,j:Integer;
begin
  for j:=0 to 128 div DistY do begin
    for i:=0 to 256 div DistX do PlasmaPixel(i*DistX,j*DistY,DistX,DistY,Map);
  end;
end;

Procedure Plasma(Map:PMap);
var i,j:Integer;
begin
  for i:=0 to 256 do for j:=0 to 128 do Pixeled^[i,j]:=False;
  Map^[0,0]:=Random(16);
  Map^[0,256]:=Random(16);
  Map^[128,0]:=Random(16);
  Map^[128,256]:=Random(16);
  Pixeled^[0,0]:=True;
  Pixeled^[0,128]:=True;
  Pixeled^[256,0]:=True;
  Pixeled^[256,128]:=True;
  j:=128;
  for i:=0 to 6 do begin
    Quadrillage(j,j div 2,Map);
    j:=j div 2;
  end;
  Quadrillage(1,1,Map);
end;

Procedure Display(Blue,Red:PMap);
var i,j:Integer;
begin
  for i:=0 to 128 do for j:=0 to 256 do Video^[i+35,j+31]:=Blue^[i,j] shl 4+Red^[i,j];
end;

Function Fondu(Source,Dest:PMap):Boolean;
var i,j:Integer;Result:Boolean;ValSource,ValDest:Byte;
begin
  Result:=True;
  for i:=0 to 256 do for j:=0 to 128 do begin
    ValSource:=Source^[j,i];
    ValDest:=Dest^[j,i];
    if ValDest>ValSource then begin
      Dec(Dest^[j,i]);
      Result:=False;
    end;
    if ValDest<ValSource then begin
      Inc(Dest^[j,i]);
      Result:=False;
    end;
  end;
  Fondu:=Result;
end;

Procedure Animate(Buf,Screen:PMap);
begin
  Zoom:=Random(5)+1;
  DivZoom:=Random(5)+1;
  Plasma(Buf);
  Repeat
    Display(BlueScr,RedScr);
    Delay(50);
  Until Fondu(Buf,Screen) or keypressed;
  if keypressed then Stop:=True;
end;

begin
  ClrsCr;
  WriteLn('C''est joli, mais c''est un peu lent!!');
  WriteLn('Alors s''il vous plait, ne quittez pas au bout de 5 secondes');
  WriteLn('soyez patient');
  Readkey;
  MCGAScreen;
  Randomize;
  New(Pixeled);
  New(BlueBuf);
  New(RedBuf);
  New(BlueScr);
  New(RedScr);
  for i:=0 to 256 do for j:=0 to 128 do begin
    RedScr^[j,i]:=0;
    BlueScr^[j,i]:=0;
  end;
  for i:=0 to 15 do Degrade(i*16,i*4,0,0,i*16+15,i*4+3,0,63);
  DefinePal;
  Zoom:=Random(5)+1;
  DivZoom:=Random(5)+1;
  While keypressed do Readkey;
  Stop:=False;

  Repeat
    Animate(BlueBuf,BlueScr);
    Animate(RedBuf,RedScr);
  Until Stop;

  CloseScreen;
  Dispose(Pixeled);
  Dispose(BlueBuf);
  Dispose(RedBuf);
  Dispose(BlueScr);
  Dispose(RedScr);
end.
