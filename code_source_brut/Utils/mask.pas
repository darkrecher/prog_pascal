uses Graph,Crt;

  {programme qui peut servir pour des jeux de vaisseau ou des jeux … la con
  de ce genre.
  Il v‚rifie si il y a une collision entre deux objets qui seraient
  affich‚s … l'‚cran
  (par exemple un monstre et un m‚ga-missile qui tue)
  il faut indiquer la gueule de l'image des deux objets et leurs positions
  relatives en X et en Y}

Type
  TTablo=Array[0..65520] of Byte;
  PSprite=^TSprite;
  TSprite=Record
    SizeMaskX,SizeX,SizeY:Word;
    Masque:^TTablo;
  end;

var
  Vaisso,Truc:PSprite;
  x1,y1,x2,y2:Integer;
  a:Char;

Function Min(X1,X2:Word):Word;
begin
  if X1<X2 then Min:=X1 else Min:=X2;
end;
           {Dist=Sprite1-Sprite2}
Function Collides(DistX,DistY:Integer;Sprite1,Sprite2:PSprite):Boolean;
var Result,Continue:Boolean;
    Decalage,Decalage2:Byte;
    i,j,DepX1,DepX2,DX,DY,DepY1,DepY2,X1,X2,Y1,Y2:Word;{L=Left;R=Right}
begin
  Result:=False;
  if DistY>0 then begin
    DepY1:=0;
    DepY2:=DistY;
    DY:=Min(SPrite2^.SizeY-DistY,Sprite1^.SizeY);
    Continue:=DistY<Sprite2^.SizeY;
  end else begin
    DepY2:=0;
    DepY1:=-DistY;
    DY:=Min(SPrite1^.SizeY-DistY,Sprite2^.SizeY);
    Continue:=-DistY<Sprite1^.SizeY;
  end;
  if Continue then begin
    OutTextXY(50,150,'Y=True');
    if DistX>0 then begin
      DepX1:=0;
      DepX2:=DistX div 8;
      DX:=Min(Sprite2^.SizeMaskX-DepX2,Sprite1^.SizeMaskX);
      Continue:=DistX<Sprite2^.SizeX;
    end else begin
      DepX2:=0;
      DepX1:=-DistX div 8;
      DX:=Min(Sprite1^.SizeMaskX-DepX1,Sprite2^.SizeMaskX);
      Continue:=-DistX<Sprite1^.SizeX;
    end;
  end;
  if Continue then begin
    OutTextXY(50,160,'X=True');
    Decalage:=Abs(DistX) mod 8;
    Decalage2:=(8-Decalage) mod 8;
    {c'est le Sprite1 qui se d‚cale en X pour se placer au niveau du Sprite2}
    if DistX>0 then begin
      X1:=DepX1;
      X2:=DepX2;
      for i:=0 to DX-1 do begin
        Y1:=DepY1;
        Y2:=DepY2;
        for j:=0 to DY-1 do begin
          Result:=Result or
          (Sprite2^.Masque^[X2+Y2*Sprite2^.SizeMaskX] and (Sprite1^.Masque^[X1+Y1*Sprite1^.SizeMaskX] shr Decalage)>1);
          if i<>0 then Result:=Result or
          (Sprite2^.Masque^[X2+Y2*Sprite2^.SizeMaskX] and (Sprite1^.Masque^[X1-1+Y1*Sprite1^.SizeMaskX] shl (Decalage2))>1);
          Inc(Y1);
          Inc(Y2);
        end;
        Inc(X1);
        Inc(X2);
      end;
    end;
    if DistX<0 then begin
      X1:=DepX1;
      X2:=DepX2;
      for i:=0 to DX-1 do begin
        Y1:=DepY1;
        Y2:=DepY2;
        for j:=0 to DY-1 do begin
          Result:=Result or
          (Sprite2^.Masque^[X2+Y2*Sprite2^.SizeMaskX] and (Sprite1^.Masque^[X1+Y1*Sprite1^.SizeMaskX] shl Decalage)>1);
          if i<>DX-1 then Result:=Result or
          (Sprite2^.Masque^[X2+Y2*Sprite2^.SizeMaskX] and (Sprite1^.Masque^[X1+1+Y1*Sprite1^.SizeMaskX] shr (Decalage2))>1);
          Inc(Y1);
          Inc(Y2);
        end;
        Inc(X1);
        Inc(X2);
      end;
    end
  end;
  Collides:=Result;
  if Result then OutTextXY(50,180,'Collision=True');
end;

Procedure AfficheMask(X,Y:Word;Color:Byte;Sprite:PSprite);
var i,j:Word;
begin
  for i:=0 to Sprite^.SizeMaskX-1 do for j:=0 to Sprite^.SizeY-1 do With Sprite^ do begin
    if Masque^[i+j*SizeMaskX] and 128=128 then PutPixel(i*8+X,j+Y,Color+GetPixel(i*8+X,j+Y));
    if Masque^[i+j*SizeMaskX] and 64=64 then PutPixel(i*8+1+X,j+Y,Color+GetPixel(i*8+X+1,j+Y));
    if Masque^[i+j*SizeMaskX] and 32=32 then PutPixel(i*8+2+X,j+Y,Color+GetPixel(i*8+X+2,j+Y));
    if Masque^[i+j*SizeMaskX] and 16=16 then PutPixel(i*8+3+X,j+Y,Color+GetPixel(i*8+X+3,j+Y));
    if Masque^[i+j*SizeMaskX] and 8=8 then PutPixel(i*8+4+X,j+Y,Color+GetPixel(i*8+X+4,j+Y));
    if Masque^[i+j*SizeMaskX] and 4=4 then PutPixel(i*8+5+X,j+Y,Color+GetPixel(i*8+X+5,j+Y));
    if Masque^[i+j*SizeMaskX] and 2=2 then PutPixel(i*8+6+X,j+Y,Color+GetPixel(i*8+X+6,j+Y));
    if Masque^[i+j*SizeMaskX] and 1=1 then PutPixel(i*8+7+X,j+Y,Color+GetPixel(i*8+X+7,j+Y));
  end;
end;

Procedure RandomMask(var Sprite:PSprite);
var i,j:Word;
begin
  With Sprite^ do begin
    SizeX:=Random(50)+5;
    SizeY:=Random(50)+5;
    SizeMaskX:=(SizeX+7) div 8;
    GetMem(Masque,SizeMaskX*SizeY);
    for i:=0 to SizeMaskX do for j:=0 to SizeY do Masque^[i+j*SizeMaskX]:=Random(8);
  end;
end;

Procedure DefineMask(var Sprite:PSprite);
var i:Byte;
begin
  With Sprite^ do begin
    SizeX:=10;
    SizeY:=10;
    SizeMaskX:=(SizeX+7) div 8;
    GetMem(Masque,SizeMaskX*SizeY);
    Masque^[0]:=255;
    Masque^[1]:=192;
    for i:=1 to 17 do Masque^[i]:=192;
    Masque^[18]:=255;
    Masque^[19]:=192;
  end;
end;

Procedure DefineMask2(var Sprite:PSprite);
var i:Byte;
begin
  With Sprite^ do begin
    SizeX:=5;
    SizeY:=5;
    SizeMaskX:=(SizeX+7) div 8;
    GetMem(Masque,SizeMaskX*SizeY);
    for i:=0 to 4 do Masque^[i]:=248;
  end;
end;

begin
  x2:=2;
  x1:=9;
  InitGraph(x1,x2,'c:\bp\bgi');
  New(Vaisso);
  New(Truc);
  Randomize;
  Repeat
    x1:=Random(50)+20;
    x2:=Random(50)+20;
    y1:=Random(50)+20;
    y2:=Random(50)+20;
    RandomMask(Vaisso);
    RandomMask(Truc);
    AfficheMask(x1,y1,10,Vaisso);
    AfficheMask(x2,y2,5,Truc);
    Collides(x1-x2,y1-y2,Vaisso,Truc);
    a:=Readkey;
    FreeMem(Vaisso^.Masque,Vaisso^.SizeMaskX*Vaisso^.SizeY);
    FreeMem(Truc^.Masque,Truc^.SizeMaskX*Truc^.SizeY);
    ClearDevice;
  Until a='q';
  CloseGraph;
  Dispose(Vaisso);
  Dispose(Truc);
end.