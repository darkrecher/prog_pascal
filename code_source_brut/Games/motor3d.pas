Uses Crt,MCGAGraf;

Const
  Focale=80;

  Precision=7;
  PrecFactor=1 shl Precision;

Type
  TPoint=Record
    X,Y,Z:LongInt;
    Color:Byte;
  end;

var
  CamX,CamY,CamZ:LongInt;
  CamAngle:Byte;
  CamCos,CamSin:Integer;
  Cosi:Array[0..255] of Integer;
  Sinu:Array[0..255] of Integer;

Procedure CalculCoordsAndProjett(Point:TPoint);
var Result:TPoint;NewX,NewZ:LongInt;
begin
  With Point do begin
    Result.Y:=Y-CamY;
    Result.X:=X-CamX;
    Result.Z:=Z-CamZ;
    Result.Color:=Color;
  end;
  With Result do begin
    NewX:=(X*CamCos+Z*CamSin) div PrecFactor;
    NewZ:=(Z*CamCos-X*CamSin) div PrecFactor;
    X:=NewX;
    Z:=NewZ;
    if Result.Z>PrecFactor then begin
      X:=(Focale*(X div PrecFactor)) div (Z div PrecFactor)+159;
      Y:=(Focale*(Y div PrecFactor)) div (Z div PrecFactor)+99;
      Pixel(X,Y,Color);
      Draw(X,Y,X,Y);
    end;
  end;
end;

Procedure CosandSin;
var i:Byte;
begin
  for i:=0 to 255 do Cosi[i]:=Round(Cos( (Pi*i)/128 )*PrecFactor);
  for i:=0 to 255 do Sinu[i]:=Round(Sin( (Pi*i)/128 )*PrecFactor);
end;

Procedure SetCos;
begin
  CamCos:=Cosi[CamAngle];
  CamSin:=Sinu[CamAngle];
end;

var
  i:Byte;
  Bazar:Array[0..49] of TPoint;
  U,V,W:Array[0..5] of TPoint;
  Alpha,Teta:Byte;
  C:Char;

begin
  MCGAScreen;
  CosAndSin;
{  for i:=0 to 24 do begin
    Bazar[i].X:=((i div 5)*15-30)*Precfactor;
    Bazar[i].Z:=((i mod 5)*15-30)*Precfactor;
    Bazar[i].Y:=-20*Precfactor;
    Bazar[25+i].X:=((i div 5)*15-30)*Precfactor;
    Bazar[25+i].Z:=((i mod 5)*15-30)*Precfactor;
    Bazar[25+i].Y:=20*Precfactor;
  end;
  CamX:=0;
  CamY:=0;
  CamZ:=0;
  CamAngle:=20;
  SetCos;
  Repeat
    for i:=0 to 49 do begin
      Bazar[i].Color:=0;
      CalculCoordsAndProjett(Bazar[i]);
    end;
    Inc(CamAngle);
    SetCos;
    Inc(CamX,CamCos);
    Inc(CamZ,CamSin);
    Inc(CamY,CamSin div 2);
    for i:=0 to 49 do begin
      Bazar[i].Color:=10;
      CalculCoordsAndProjett(Bazar[i]);
    end;
    Affiche;
    Delay(10);
  Until keypressed;}

  Alpha:=0;
  Teta:=0;
  CamX:=0;
  CamY:=5 shl Precision;
  CamZ:=-100 shl Precision;
  CamAngle:=0;
  SetCos;
  Repeat
    for i:=0 to 5 do begin
      U[i].Color:=0;
      V[i].Color:=0;
      W[i].Color:=0;
      CalculCoordsAndProjett(U[i]);
      CalculCoordsAndProjett(V[i]);
      CalculCoordsAndProjett(W[i]);
    end;
    if Keypressed then C:=Readkey;
    if C='o' then Inc(Alpha);
    if C='p' then Dec(Alpha);
    if C='a' then Inc(Teta);
    if C='q' then Dec(Teta);
    for i:=0 to 5 do begin
      U[i].X:=Cosi[Teta]*i*16;
      U[i].Y:=0;
      U[i].Z:=Sinu[Teta]*i*16;

      V[i].X:=(LongInt(Sinu[Alpha])*Sinu[Teta]*i*16) div Precfactor;
      V[i].Y:=Cosi[Alpha]*i*16;
      V[i].Z:=(LongInt(-Sinu[Alpha])*Cosi[Teta]*i*16) div Precfactor;

      W[i].X:=(LongInt(-Sinu[Teta])*Cosi[Alpha]*i*16) div Precfactor;
      W[i].Y:=Sinu[Alpha]*i*16;
      W[i].Z:=(LongInt(Cosi[Alpha])*Cosi[Teta]*i*16) div Precfactor;
    end;
    for i:=0 to 5 do begin
      U[i].Color:=10;
      V[i].Color:=15;
      W[i].Color:=13;
      CalculCoordsAndProjett(U[i]);
      CalculCoordsAndProjett(V[i]);
      CalculCoordsAndProjett(W[i]);
    end;
    Delay(10);
    Affiche;
  Until C=#27;
  CloseScreen;
end.