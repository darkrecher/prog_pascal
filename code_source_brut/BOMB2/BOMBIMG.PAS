Unit BombImg;

Interface

Uses MCGaGraf,Objects;

Const
  MaxSizeSprite=30;
  TransparentColor=2;
  ColorDegradeLength=16;
  BonhommeColorCoords:Array[0..3] of Byte=(32,64,96,144);

Type
  BonhommeColor=(Red,Yellow,Green,Blue);
  PSprite=^TSprite;
  PAnimation=^TAnimation;
  PBonhomme=^TBonhomme;
  TSprite=Object(TObject)
    Dessin:Array[0..MaxSizeSprite-1,0..MaxSizeSprite-1] of Byte;
    SizeX,SizeY,HotPointX,HotpointY:Integer;
    Constructor Init(AX,AY,BX,BY,AHPX,AHPY:Integer;DataSource:PScreen);
    Procedure ConvertColor(SourceCol,DestCol:BonhommeColor); virtual;
    Procedure Rotat90Trigo(Angle:Integer); virtual;
    Procedure TranspDraws(X,Y:Integer); virtual;
    Procedure DrawsPlaf(X,Y:Integer); virtual;
    Destructor Done; virtual;
  end;
  TAnimDessins=Array[0..10] of PSprite;
  TAnimation=Object(TObject)
    Dessins:TAnimDessins;
    NbrImage,TotalTime,TimeForOne:Integer;
    Constructor Init(ANbrImage,ATotalTime:Integer;ADessins:TAnimDessins);
    Procedure TranspDraws(X,Y,Time:Integer); virtual;
    Procedure DrawsPlaf(X,Y,Time:Integer); virtual;
    Destructor Done; virtual;
  end;
  TBonhomme=Object(TObject)
    WalkAnims:Array[0..3] of PAnimation;
    DieAnim:PAnimation;
    Skull:PSprite;
    Constructor Init(XData,YData:Integer);
    Procedure ConvertColor(SourceCol,DestCol:BonhommeColor);
    Destructor Done; virtual;
  end;
  PFlamImg=^TFlamImg;
  TFlamImg=Object(TObject)
    Extremi:Array[0..3] of PAnimation;
    Verti,Hori,Center:PAnimation;
    Constructor Init(XData,YData:Integer);
    Destructor Done; virtual;
  end;
  PBombImg=^TBombImg;
  TBombImg=Object(TObject)
    Normal:PAnimation;
    Constructor Init(XData,YData:Integer);
    Destructor Done; virtual;
  end;
  TBonusImage=Record
    Flamme,Bombe,Kick:PSprite;
  end;
  Procedure RedrawImage(x1,y1,x2,y2:Integer;Image:PSCreen);
  Procedure AfficheArgh(X,Y:Integer);
  Procedure LoadImages;
  Procedure FreeImages;

var
  YellowBonhomme,GreenBonhomme,BlueBonhomme,RedBonhomme:PBonhomme;
  FlamImg:PFlamImg;BombsImg:PBombImg;
  ARGH:Array[0..5] of PSprite;
  BonusExplode:PAnimation;
  BonusImage:TBonusImage;

Implementation

Uses Bombfile;

Constructor TSprite.Init(AX,AY,BX,BY,AHPX,AHPY:Integer;DataSource:PScreen);
var i,j:Integer;
begin
{je ne fais pas les tests pour voir si AX,AY,BX,BY correspondent bien a des
coordonnees d'‚cran, ‡a prend de la place et c'est inutile}
  SizeX:=BX-AX+1;
  SizeY:=BY-AY+1;
  if SizeX>MaxSizeSprite then SizeX:=MaxSizeSprite;
  if SizeY>MaxSizeSprite then SizeY:=MaxSizeSprite;
  for i:=0 to SizeX-1 do for j:=0 to SizeY-1 do Dessin[j,i]:=DataSource^[j+AY,i+AX];
  {l'ordonn‚e est en premier et l'abscisse en deuxiŠme, c'est invers‚,
  c'est pour pouvoir faire le "move" dans la proc‚dure DrawsPlaf}
  HotPointX:=AHPX;
  HotPointY:=AHPY;
end;

Procedure TSprite.ConvertColor(SourceCol,DestCol:BonhommeColor);
var i,j:Integer;SColCoord,DColCoord:Byte;
begin
  SColCoord:=BonhommeColorCoords[Ord(SourceCol)];
  DColCoord:=BonhommeColorCoords[Ord(DestCol)];
  for i:=0 to SizeX-1 do for j:=0 to SizeY-1 do
  if (Dessin[j,i]>=SColCoord) and (Dessin[j,i]<=SColCoord+ColorDegradeLength-1) then
  Inc(Dessin[j,i],DColCoord-SColCoord);
end;

Procedure TSprite.Rotat90Trigo(Angle:Integer);
var i,NewSizeX,NewSizeY:Integer;NewDessin:Array[0..MaxSizeSprite-1,0..MaxSizeSprite-1] of Byte;

  Procedure RotatOneTime;
  var j,k:Integer;
  begin
    NewSizeX:=SizeY;
    NewSizeY:=SizeX;
    for j:=0 to SizeX-1 do for k:=0 to SizeY-1 do NewDessin[SizeX-1-j,k]:=Dessin[k,j];
    {rappelez vous que les x et y sont invers‚s}
    for j:=0 to NewSizeX-1 do for k:=0 to NewSizeY-1 do Dessin[k,j]:=NewDessin[k,j];
    SizeX:=NewSizeX;
    SizeY:=NewSizeY;
  end;

begin
  if Angle>0 then for i:=0 to Angle-1 do RotatOneTime;
  {c'est trŠs moche et trŠs lent de faire plusieurs fois une rotation de 90 degr‚s
  quand on veut tourner de 180 ou de 270 degr‚s, mais bon, on fait ‡a
  qu'une fois au d‚but de l'‚xecution et j'ai pas le courage de coder
  des rotations de 2*90 et 3*90 degr‚s et en plus j'm'en fous }
end;


Procedure TSPrite.TranspDraws(X,Y:Integer);
var XImg,YImg,XScrn,XDebut,YSCrn:Integer;Color:Byte;
begin
  XDebut:=X+HotPointX;
  YScrn:=Y+HotPointY;
  for YImg:=0 to SizeY-1 do begin
    XScrn:=XDebut;
    for XImg:=0 to SizeX-1 do begin
      Color:=Dessin[YImg,XImg];
      if Color<>TransparentColor then Pixel(XScrn,YScrn,Color);
      Inc(XScrn);
    end;
    Inc(YScrn);
  end;
end;

Procedure TSprite.DrawsPlaf(X,Y:Integer);
var YScreen,YImage,XImage:Integer;
begin
  YImage:=Y+HotPointY;
  XImage:=X+HotPointX;
  for YScreen:=0 to SizeY-1 do begin
    Move(Dessin[YScreen,0],Buffer^[YImage,XImage],SizeX);
    Inc(YImage);
  end;
end;

Destructor TSprite.Done;
begin
end;

Constructor TAnimation.Init(ANbrImage,ATotalTime:Integer;ADessins:TAnimDessins);
begin
  NbrImage:=ANbrImage;
  TotalTime:=ATotalTime;
  TimeForOne:=TotalTime div NbrImage;
  TotalTime:=TimeForOne*NbrImage;
  Dessins:=ADessins;
end;

Procedure TAnimation.TranspDraws(X,Y,Time:Integer);
begin
  Time:=Time mod TotalTime;
  Dessins[Time div TimeForOne]^.TranspDraws(X,Y);
end;

Procedure TAnimation.DrawsPlaf(X,Y,Time:Integer);
begin
  Time:=Time mod TotalTime;
  Dessins[Time div TimeForOne]^.DrawsPlaf(X,Y);
end;

Destructor TAnimation.Done;
var i,j:Integer;
begin
  for i:=0 to NbrImage-1 do for j:=i+1 to NbrImage-1 do
  if (Dessins[i]<>nil) and (Dessins[j]<>nil) and (Dessins[i]=Dessins[j]) then
  Dessins[j]:=nil;
  for i:=0 to NbrImage-1 do if Dessins[i]<>nil then Dispose(Dessins[i],Done);
end;

Constructor TBonhomme.Init(XData,YData:Integer);
var i,j:Integer;WalkDessins:TAnimDessins;
begin
  for j:=0 to 3 do begin
    for i:=0 to 10 do WalkDessins[i]:=nil;
    for i:=0 to 2 do
    New(WalkDessins[i],Init(XData+3+17*i,YData+19*j,XData+3+17*i+11+Ord((j=0) or (j=2)),YData+19*j+17,-6,-11,Sprites));
    WalkDessins[3]:=WalkDessins[2];
    WalkDessins[2]:=WalkDessins[0];
    New(WalkAnims[j],Init(4,30,WalkDessins));
  end;
  for i:=0 to 3 do WalkDessins[i]:=nil;
  for i:=0 to 7 do
  New(WalkDessins[i],Init(XData+1+17*i,YData+4*19,XData+1+17*i+15,YData+4*19+17,-8,-10,Sprites));
  WalkDessins[8]:=WalkDessins[7];
  WalkDessins[9]:=WalkDessins[7];
  WalkDessins[10]:=WalkDessins[7];
  New(DieAnim,Init(11,88,WalkDessins));
  New(Skull,Init(XData+1,YData+5*19,XData+1+15,YData+5*19+15,0,0,Sprites));
end;

Procedure TBonhomme.ConvertColor(SourceCol,DestCol:BonhommeColor);
var i,j:Integer;
begin
  for i:=0 to 3 do for j:=0 to WalkAnims[i]^.NbrImage-1 do
  WalkAnims[i]^.Dessins[j]^.ConvertColor(SourceCol,DestCol);
  for j:=0 to DieAnim^.NbrImage-1 do DieAnim^.Dessins[j]^.ConvertColor(SourceCol,DestCol);
  Skull^.ConvertColor(SourceCol,DestCol);
end;

Destructor TBonhomme.Done;
var i:Integer;
begin
  for i:=0 to 3 do Dispose(WalkAnims[i],Done);
  Dispose(DieAnim,Done);
  Dispose(Skull,Done);
end;

Constructor TFlamImg.Init(XData,YData:Integer);
var i,j:Integer;FlamDessins:TAnimDessins;
begin
  for j:=0 to 10 do FlamDessins[i]:=nil;
  for i:=0 to 3 do begin
    for j:=0 to 2 do begin
      New(FlamDessins[j],Init(XData+17*j,YData+17,XData+17*j+15,YData+17+15,0,0,Sprites));
      FlamDessins[j]^.Rotat90Trigo((4-i) mod 4)
    end;
    FlamDessins[3]:=FlamDessins[1];
    FlamDessins[4]:=FlamDessins[0];
    New(Extremi[i],Init(5,50,FlamDessins));
    for j:=0 to 4 do FlamDessins[j]:=nil;
  end;
  for j:=0 to 2 do New(FlamDessins[j],Init(XData+17*j,YData+17*2,XData+17*j+15,YData+17*2+15,0,0,Sprites));
  FlamDessins[3]:=FlamDessins[1];
  FlamDessins[4]:=FlamDessins[0];
  New(Center,Init(5,50,FLamDessins));
  for j:=0 to 4 do FlamDessins[j]:=nil;
  for j:=0 to 2 do New(FlamDessins[j],Init(XData+17*j,YData,XData+17*j+15,YData+15,0,0,Sprites));
  FlamDessins[3]:=FlamDessins[1];
  FlamDessins[4]:=FlamDessins[0];
  New(Hori,Init(5,50,FLamDessins));
  for j:=0 to 4 do FlamDessins[j]:=nil;
  for j:=0 to 2 do New(FlamDessins[j],Init(XData+17*j,YData,XData+17*j+15,YData+15,0,0,Sprites));
  for j:=0 to 2 do FlamDessins[j]^.Rotat90Trigo(1);
  FlamDessins[3]:=FlamDessins[1];
  FlamDessins[4]:=FlamDessins[0];
  New(Verti,Init(5,50,FLamDessins));
  for j:=0 to 4 do FlamDessins[j]:=nil;
end;

Destructor TFlamImg.Done;
var i:Integer;
begin
  Dispose(Center,Done);
  Dispose(Verti,Done);
  Dispose(Hori,Done);
  for i:=0 to 3 do Dispose(Extremi[i],Done);
end;

Constructor TBombImg.Init(XData,YData:Integer);
var i:Integer;BombDessins:TAnimDessins;
begin
  for i:=0 to 10 do BombDessins[i]:=nil;
  for i:=0 to 2 do New(BombDessins[i],Init(XData+17*i,YData,XData+17*i+15,YData+15,-8,-8,Sprites));
  BombDessins[3]:=BombDessins[1];
  New(Normal,Init(4,40,BombDessins));
end;

Destructor TBombimg.Done;
begin
  Dispose(Normal,Done);
end;

Procedure LoadArgh(XData,YData:Integer);
var i:Integer;
begin
  for i:=0 to 4 do New(ARGH[i],Init(XData+30*i,YData,XData+30*i+29,YData+17,0,0,Sprites));
  New(ARGH[5],Init(XData+150,YData,XData+176,YData+17,0,0,Sprites));
end;

Procedure AfficheArgh(X,Y:Integer);
var i:Integer;
begin
  for i:=0 to 5 do ARGH[i]^.DrawsPlaf(X+30*i,Y);
end;

Procedure FreeArgh;
var i:Integer;
begin
  for i:=0 to 5 do Dispose(ARGH[i],Done);
end;

Procedure LoadBonusExplode(X,Y:Integer);
var i:Integer;BoomDessins:TAnimDessins;
begin
  for i:=0 to 10 do BoomDessins[i]:=nil;
  for i:=0 to 2 do New(BoomDessins[i],Init(X+i*17+1,Y+1,X+16+i*17,Y+16,0,0,Sprites));
  New(BonusExplode,Init(3,60,BoomDessins));
end;

Procedure LoadBonusImage(X,Y:Integer);
var i:Integer;
begin
  i:=0;
  New(BonusImage.Flamme,Init(X+17*i+1,Y+1,X+16+17*i,Y+16,0,0,Sprites));
  Inc(i);
  New(BonusImage.Bombe,Init(X+17*i+1,Y+1,X+16+17*i,Y+16,0,0,Sprites));
  Inc(i);
  New(BonusImage.Kick,Init(X+17*i+1,Y+1,X+16+17*i,Y+16,0,0,Sprites));
end;

Procedure FreeBonusImage;
begin
  Dispose(BonusImage.Flamme,Done);
  Dispose(BonusImage.Bombe,Done);
  Dispose(BonusImage.Kick,Done);
end;

Procedure RedrawImage(x1,y1,x2,y2:Integer;Image:PSCreen);
var i:Integer;
begin
  for i:=y1 to y2 do Move(Image^[i,x1],Buffer^[i,x1],x2-x1+1);
end;


Procedure LoadImages;
begin
  LoadData;
  New(RedBonhomme,Init(0,0));
  New(BlueBonhomme,Init(0,0));
  New(GreenBonhomme,Init(0,0));
  New(YellowBonhomme,Init(0,0));
  New(FlamImg,Init(55,1));
  New(BombsImg,Init(55,52));
  BlueBonhomme^.ConvertColor(Red,Blue);
  GreenBonhomme^.ConvertColor(Red,Green);
  YellowBonhomme^.ConvertColor(Red,Yellow);
  LoadArgh(68,109);
  LoadBonusExplode(105,0);
  LoadBonusImage(105,17);
  EndLoadData;
end;

Procedure FreeImages;
begin
  Dispose(RedBonhomme,Done);
  Dispose(BlueBonhomme,Done);
  Dispose(GreenBonhomme,Done);
  Dispose(YellowBonhomme,Done);
  Dispose(FlamImg,Done);
  Dispose(BombsImg,Done);
  Dispose(BonusExplode,Done);
  FreeBonusImage;
  FreeArgh;
end;

end.