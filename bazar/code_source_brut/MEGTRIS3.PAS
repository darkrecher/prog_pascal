Uses Crt,MCGAGraf,Objects;

Const
  MaxSizeX=10;
  MaxSizeY=30;
  MaxTilesInABlock=4;

Type
  PUniverse=^TUniverse;
  PTile=^TTile;
  PGame=^TGame;
  PArena=^TArena;
  PBlock=^TBlock;

  TCoord=Record
    X,Y:Integer;
  end;

  TUniverse=Object(TObject)
    Player1Exists,Player2Exists:Boolean;
    Player1,Player2:PGame;
    Constructor Init(P1,P2:Boolean);
    Procedure TakeOrders; virtual;
    Procedure Play; virtual;
    Destructor Done; virtual;
  end;

  TGame=Object(TObject)
    Arena:PArena;
    CurrentAction:Word;
    CurrentBLock,NextBlock:PBLock;
    CoordNext,CoordArena:TCoord;
    WhichPlayer,GoLeft,GoRight,GoUp,GoDown,Action1,Action2,EndGame:Boolean;
    Constructor Init(ArenaX,ArenaY,NextX,NextY:Integer;SizeX,SizeY:Word;AWhichPlayer:Boolean);
    Procedure PlayOneCycle; virtual;
    Procedure SendBlockInArena; virtual;
    Procedure RefreshArena; virtual;
    Procedure OrganizeOrders; virtual;
    Procedure ResetOrders; virtual;
    Function MoveRotate:Boolean; virtual;
    Destructor Done; virtual;
  end;

  TArena=Object(TObject)
    Data:Array[0..MaxSizeX-1,0..MaxSizeY-1] of PTile;
    DataBool:Array[0..MaxSizeX-1,0..MaxSizeY-1] of Boolean;
    Owner:PGame;
    Size:TCoord;
    Constructor Init(SizeX,SizeY:Word;AOwner:PGame);
    Procedure Draws(X,Y:Word); virtual;
    Function Collides(AForm:Byte;CenterCoordX,CenterCoordY:Integer):Boolean; virtual;
    Function SeeWhatFalls:Boolean; virtual;
    Procedure DrawTheFalling(X,Y:Integer;TimeFall:Byte); virtual;
    Procedure TilesGoDown; virtual;
    Function WhatToDestroy:Boolean; virtual;
    Procedure DrawSomeTiles(X,Y:Word); virtual;
    Procedure SuppressTiles; virtual;
    Function LineFull(Ord:Integer):Boolean;
    Function LineEmpty(Ord:Integer):Boolean;
    Destructor Done; virtual;
  end;

  TTile=Object(TObject)
    Solid:Boolean;
    Color:Byte;
    Owner:PGame;
    Constructor Init(AOwner:PGame);
    Procedure Draws(X,Y:Integer;Hidden_By_The_Limits_Of_The_Arena:Boolean);
    Procedure RandomGeneration; virtual;
    Procedure Clear; virtual;
    Procedure GiveValues(Dest:PTile); virtual;
    Destructor Done; virtual;
  end;

  TBlock=Object(TObject)
    Tiles:Array[0..MaxTilesInABlock-1] of PTile;
    RelCoords:Array[0..MaxTilesInABlock-1] of TCoord;
    Center:TCoord;
    Owner:PGame;
    NbrTile,Form:Byte;
    Constructor Init(AOwner:PGame);
    Procedure Draws(X,Y:Integer;InAnArena:Boolean); virtual;
    Procedure Moves(Direction,Dist:Byte); virtual;
    Procedure RandomGeneration; virtual;
    Procedure SetOnArena(Dest:PArena); virtual;
    Procedure ImmediateSetOnArena(Dest:PArena);
    Procedure Rotate(Sens:Boolean); virtual;
    Destructor Done; virtual;
  end;
  {un block est un groupe de petit carrÇs, c'est le truc qui tombe
  dans l'aire de jeu et qu'on peut bouger et faire tourner}


Const
  TileSize=8;

  NbrBlock=27;

  {valeurs possibles de TBlock^.Form, avec l'image du block Ö cìtÇ }
  Nothing=0;         {}         {}

  BigSquare=1;       { €€ }     { 01 }
                     { €€ }     { 23 }

  Single=2;          { € }      { 0 }

  Line3Vertic=3;     { € }      { 1 }
                     { € }      { 0 }
                     { € }      { 2 }

  Line3Horiz=4;      { €€€ }    { 102 }

  Line2Left=5;       { €€ }     { 10 }

  Line2Right=6;      { €€ }     { 01 }

  Line2Up=7;         { € }      { 1 }
                     { € }      { 0 }

  Line2Down=8;       { € }      { 0 }
                     { € }      { 1 }

  SnakeHorizOne=9;   {  €€ }    {  23 }
                     { €€  }    { 01  }

  SnakeVerticOne=10; { €  }     { 3  }
                     { €€ }     { 21 }
                     {  € }     {  0 }

  SnakeHorizTwo=11;  { €€  }    { 01  }
                     {  €€ }    {  23 }

  SnakeVerticTwo=12; {  € }     {  3 }
                     { €€ }     { 12 }
                     { €  }     { 0  }

  TorduOneOne=13;     { €€ }     { 01 }
                      {  € }     {  2 }
                      {  € }     {  3 }

  TorduTwoOne=14;     {    € }   {   0 }
                      { €€€€ }   { 321 }

  TorduThreeOne=15;  { €  }     { 3  }
                     { €  }     { 2  }
                     { €€ }     { 10 }

  TorduFourOne=16;   { €€€€ }   { 123 }
                     { €    }   { 0   }

  TorduOneTwo=17;    {  €€ }     { 10 }
                     {  €  }     { 2  }
                     {  €  }     { 3  }

  TorduTwoTwo=18;     { €    }   { 0   }
                      { €€€€ }   { 123 }

  TorduThreeTwo=19;  {  € }     {  3 }
                     {  € }     {  2 }
                     { €€ }     { 01 }

  TorduFourTwo=20;   { €€€€ }   { 321 }
                     {    € }   {   0 }

  T_One=21;          { €  }         { 1  }
                     { €€ }         { 20 }
                     { €  }         { 3  }

  T_Two=22;          {  €  }        {  0  }
                     { €€€ }        { 123 }

  T_Three=23;        {  € }         {  3 }
                     { €€ }         { 02 }
                     {  € }         {  1 }

  T_Four=24;         { €€€ }        { 321 }
                     {  €  }        {  0  }

  Line4Horiz=25;     { €€€€ }       { 0123 }

  Line4Vertic=26;    { € }          { 0 }
                     { € }          { 1 }
                     { € }          { 2 }
                     { € }          { 3 }



  FormDescription:Array[0..NbrBlock-1,0..MaxTilesInABlock-1,0..1] of ShortInt=(
  ((0,0),(0,0),(0,0),(0,0)),  {Nothing}
  ((0,0),(1,0),(0,1),(1,1)),  {BigSquare}
  ((0,0),(0,0),(0,0),(0,0)),  {Single}
  ((0,0),(0,-1),(0,1),(0,0)),  {Line3Vertic}
  ((0,0),(-1,0),(1,0),(0,0)), {Line3Horiz}
  ((0,0),(-1,0),(0,0),(0,0)), {Line2Left}
  ((0,0),(1,0),(0,0),(0,0)), {Line2Right}
  ((0,0),(0,-1),(0,0),(0,0)),  {Line2Up}
  ((0,0),(0,1),(0,0),(0,0)),  {Line2Down}
  ((-1,1),(0,1),(0,0),(1,0)),  {SnakeHorizOne}
  ((1,1),(1,0),(0,0),(0,-1)),  {SnakeVerticTwo}
  ((-1,0),(0,0),(0,1),(1,1)),  {SnakeHorizTwo}
  ((-1,1),(-1,0),(0,0),(0,-1)), {SnakeVerticTwo}
  ((-1,-1),(0,-1),(0,0),(0,1)), {TorduOneOne}
  ((1,0),(1,1),(0,1),(-1,1)),   {TorduOneTwo}
  ((1,1),(0,1),(0,0),(0,-1)),   {TorduOneThree}
  ((-1,1),(-1,0),(0,0),(1,0)), {TorduOneFour}
  ((1,-1),(0,-1),(0,0),(0,1)), {TorduOneTwo}
  ((-1,0),(-1,1),(0,1),(1,1)), {TorduTwoTwo}
  ((-1,1),(0,1),(0,0),(0,-1)), {TorduThreeTwo}
  ((1,1),(1,0),(0,0),(-1,0)), {TorduFourTwo}
  ((1,0),(0,-1),(0,0),(0,1)),
  ((0,0),(-1,1),(0,1),(1,1)),
  ((-1,0),(0,1),(0,0),(0,-1)),
  ((0,1),(1,0),(0,0),(-1,0)),
  ((-2,0),(-1,0),(0,0),(1,0)),
  ((0,-1),(0,0),(0,1),(0,2)));


  NbrTileDescription:Array[0..NbrBlock-1] of Byte=
  (0,4,1,3,3,2,2,2,2,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4);

  NoDir=0;
  Right=1;
  Up=2;
  Left=3;
  Down=4;

  Joueur1=False;
  Joueur2=True;

  Trigo=True;
  AntiTrigo=False;

  MaxColor=4;
  NbrTileToAttach=4;

Constructor TTile.Init(AOwner:PGame);
begin
  Solid:=False;
  Color:=0;
  Owner:=AOwner;
end;

Function Max(X1,X2:Integer):Integer;
begin
  if X1>X2 then Max:=X1 else Max:=X2;
end;

Function Min(X1,X2:Integer):Integer;
begin
  if X1<X2 then Min:=X1 else Min:=X2;
end;

Procedure TTile.Draws(X,Y:Integer;Hidden_By_The_Limits_Of_The_Arena:Boolean);
begin
  if Hidden_By_The_Limits_Of_The_Arena then
  if (X+TileSize>Owner^.CoordArena.X) and (Y+TileSize>Owner^.CoordArena.Y)
  and (X<Owner^.CoordArena.X+Owner^.Arena^.Size.X*TileSize) and (Y<Owner^.CoordArena.Y+Owner^.Arena^.Size.Y*TileSize)
  then begin
    FilledSquare(Max(X,Owner^.CoordArena.X),Max(Y,Owner^.CoordArena.Y),
    Min(X+TileSize-1,Owner^.CoordArena.X+Owner^.Arena^.Size.X*TileSize),
    Min(Y+TileSize-1,Owner^.CoordArena.Y+Owner^.Arena^.Size.Y*TileSize),Color);
  end;
  if not(Hidden_By_The_Limits_Of_The_Arena) then if Solid then FilledSquare(X,Y,X+TileSize-1,Y+TileSize-1,Color);
end;

Procedure TTile.RandomGeneration;
begin
  Solid:=True;
  Color:=Random(MaxColor)+1;
end;

Procedure TTile.Clear;
begin
  Solid:=False;
  Color:=0;
end;

Procedure TTile.GiveValues(Dest:PTile);
begin
  PTile(Dest)^.Solid:=Solid;
  PTile(Dest)^.Color:=Color;
end;

Destructor TTile.Done;
begin
end;

{-------------------------------------------------------}

Constructor TArena.Init(SizeX,SizeY:Word;AOwner:PGame);
var i,j:Word;
begin
  Owner:=AOwner;
  if SizeX<=0 then SizeX:=1;
  if SizeY<=0 then SizeY:=1;
  Size.X:=SizeX;
  Size.Y:=SizeY;
  for i:=0 to SizeX-1 do for j:=0 to SizeY-1 do
  Data[i,j]:=New(PTile,Init(AOwner));
end;

Procedure TArena.Draws(X,Y:Word);
var i,j:Word;
begin
  for i:=0 to Size.X-1 do for j:=0 to Size.Y-1 do
  Data[i,j]^.Draws(X+i*TileSize,Y+j*TileSize,False);
  Draw(X,Y,X+Size.X*TileSize,Y+Size.Y*TileSize);
end;

Function TArena.LineFull(Ord:Integer):Boolean;
var Result:Boolean;i:Integer;
begin
  Result:=True;
  for i:=0 to Size.X-1 do Result:=Result and Data[i,Ord]^.Solid;
  LineFull:=Result;
end;

Function TArena.LineEmpty(Ord:Integer):Boolean;
var Result:Boolean;i:Integer;
begin
  Result:=True;
  for i:=0 to Size.X-1 do Result:=Result and not(Data[i,Ord]^.Solid);
  LineEmpty:=Result;
end;

{la fonction collides permet de savoir si un certain block se superpose
au tiles de l'aräne. On doit indiquer la forme du block et les coordonnÇes
de sa case principale.
Ce qu'il y a de bien, c'est que c'est pas la peine de crÇer un nouvel
objet block juste pour voir si il entre en collision avec les tiles de
l'aräne, il y a juste des paramätres Ö entrer}
Function TArena.Collides(AForm:Byte;CenterCoordX,CenterCoordY:Integer):Boolean;
var Result:Boolean;i,EndLoop:Byte;LocateX,LocateY:Integer;
begin
  Result:=False;
  EndLoop:=NbrTileDescription[AForm];
  i:=0;
  Repeat
    LocateX:=CenterCoordX+FormDescription[AForm,i,0];
    LocateY:=CenterCoordY+FormDescription[AForm,i,1];
    if LocateY>=0 then Result:=(LocateX<0) or (LocateX>Size.X-1)
    or (LocateY>Size.Y-1) or PTile(Data[LocateX,LocateY])^.Solid;
    Inc(i);
  Until Result or (i=EndLoop);
  Collides:=Result;
end;

Function TArena.SeeWhatFalls:Boolean;
var i,j,k:Integer;FoundEmptyLine,Merde:Boolean;
begin
  FillChar(DataBool,SizeOf(DataBool),0);
  i:=Size.Y-1;
  While (i>0) and not( LineEmpty(i) and not(LineEmpty(i-1)) ) do Dec(i);
  FoundEmptyLine:=i<>0;
  if FoundEmptyLine then for j:=0 to i-1 do for k:=0 to Size.X-1 do DataBool[k,j]:=True;
  SeeWhatFalls:=FoundEmptyLine;
end;

Procedure TArena.DrawTheFalling(X,Y:Integer;TimeFall:Byte);
var i,j:Word;
begin
  for i:=0 to Size.X-1 do for j:=0 to Size.Y-1 do if DataBool[i,j] then
  Data[i,j]^.Draws(X+i*TileSize,Y+j*TileSize+TimeFall,False) else
  Data[i,j]^.Draws(X+i*TileSize,Y+j*TileSize,False);
  Draw(X,Y,X+Size.X*TileSize,Y+Size.Y*TileSize);
end;

Procedure TArena.TilesGoDown;
var i,j:Integer;
begin
  for i:=0 to Size.X-1 do begin
    for j:=Size.Y-1 downto 0 do if DataBool[i,j] then
    Data[i,j]^.GiveValues(Data[i,j+1]);
    if DataBool[i,0] then Data[i,0]^.Clear;
  end;
end;

Function TArena.WhatToDestroy:Boolean;
var i,j:Integer;Result:Boolean;
begin
  FillChar(DataBool,SizeOf(DataBool),0);
  Result:=False;
  for i:=0 to Size.Y-1 do if LineFull(i) then begin
    for j:=0 to Size.X-1 do DataBool[j,i]:=True;
    Result:=True;
  end;
  WhatToDestroy:=Result;
end;

Procedure TArena.DrawSomeTiles(X,Y:Word);
var i,j:Word;
begin
  for i:=0 to Size.X-1 do for j:=0 to Size.Y-1 do if not(DataBool[i,j]) then
  Data[i,j]^.Draws(X+i*TileSize,Y+j*TileSize,False);
  Draw(X,Y,X+Size.X*TileSize,Y+Size.Y*TileSize);
end;

Procedure TArena.SuppressTiles;
var i,j:Word;
begin
  for i:=0 to Size.X-1 do for j:=0 to Size.Y-1 do if DataBool[i,j] then
  Data[i,j]^.Clear;
end;

Destructor TArena.Done;
var i,j:Word;
begin
  for i:=0 to Size.X-1 do for j:=0 to Size.Y-1 do Dispose(Data[i,j],Done);
end;

{-------------------------------------------------------}

Constructor TBlock.Init(AOwner:PGame);
var i:Byte;
begin
  Owner:=AOwner;
  for i:=0 to MaxTilesInABlock-1 do Tiles[i]:=New(PTile,Init(AOwner));
end;

Procedure TBlock.Draws(X,Y:Integer;InAnArena:Boolean);
var i:Byte;
begin
  if NbrTile<>0 then for i:=0 to NbrTile-1 do
  if InAnArena and (RelCoords[i].Y+Center.Y<0) then
  PTile(Tiles[i])^.Draws(X+(RelCoords[i].X+Center.X)*TileSize,Y+(RelCoords[i].Y+Center.Y)*TileSize,True)
  else PTile(Tiles[i])^.Draws(X+(RelCoords[i].X+Center.X)*TileSize,Y+(RelCoords[i].Y+Center.Y)*TileSize,False);
  Draw(X+Center.X-2*TileSize,Y+Center.Y-2*TileSize,X+Center.X+Tilesize*3-1,Y+Center.Y+Tilesize*3-1);
end;


Procedure TBlock.RandomGeneration;
var i,ProbaSum:Byte;Choice:Integer;
Const
  ProbaForm:Array[0..NbrBlock-1] of Byte=
  (0,0,0,0,0, 0,0,0,0, 2,2, 2,2, 1,1,1,1, 1,1,1,1, 1,1,1,1, 2,2);
  {ce tableau donne les probabilitÇs d'apparition des piäces de diffÇrentes
  forme.}
begin
  ProbaSum:=0;
  for i:=0 to NbrBlock-1 do Inc(ProbaSum,ProbaForm[i]);
  Choice:=Random(ProbaSum)+1;
  Form:=0;
  While Choice>0 do begin
    Dec(Choice,ProbaForm[Form]);
    Inc(Form);
  end;
  Dec(Form);
  NbrTile:=NbrTileDescription[Form];
  if NbrTile<>0 then for i:=0 to NbrTile-1 do begin
    RelCoords[i].X:=FormDescription[Form,i,0];
    RelCoords[i].Y:=FormDescription[Form,i,1];
    Tiles[i]^.Solid:=True;
    Tiles[i]^.Color:=Form+12;
  end;
  Center.X:=0;
  Center.Y:=0;
end;

Procedure TBlock.Moves(Direction,Dist:Byte);
var i:Byte;MoveValue:ShortInt;
begin
  if NbrTile<>0 then Case Direction of
    Left:Dec(Center.X,Dist);
    Right:Inc(Center.X,Dist);
    Up:Dec(Center.Y,Dist);
    Down:Inc(Center.Y,Dist);
  end;
end;

Procedure TBLock.SetOnArena(Dest:PArena);
var i:Byte;LocateX,LocateY:Integer;
begin
  if NbrTile<>0 then for i:=0 to NbrTile-1 do begin
    LocateX:=RelCoords[i].X+Center.X;
    LocateY:=RelCoords[i].Y+Center.Y;
    if (LocateX>=0) and (LocateX<Dest^.Size.X) and
    (LocateY>=0) and (LocateY<Dest^.Size.Y) then
    Tiles[i]^.GiveValues(Dest^.Data[LocateX,LocateY]);
  end;
end;

Procedure TBlock.ImmediateSetOnArena(Dest:PArena);
begin
  While not(Dest^.Collides(Form,Center.X,Center.Y+1)) do TBlock.Moves(Down,1);
  SetOnArena(Dest);
end;

{Glups!! J'aurais mieux fait de faire un tableau de constantes plutìt
que cette function RotatedForm!!
je changerais áa plus tard}
Function RotatedForm(ToRotate:Byte;Sens:Boolean):Byte;
begin
  if (ToRotate=Single) or (ToRotate=BigSquare) then RotatedForm:=ToRotate;
  if ToRotate=Line3Vertic then RotatedForm:=Line3Horiz;
  if ToRotate=Line3Horiz then RotatedForm:=Line3Vertic;
  if ToRotate=SnakeVerticOne then RotatedForm:=SnakeHorizOne;
  if ToRotate=SnakeHorizOne then RotatedForm:=SnakeVerticOne;
  if ToRotate=SnakeVerticTwo then RotatedForm:=SnakeHorizTwo;
  if ToRotate=SnakeHorizTwo then RotatedForm:=SnakeVerticTwo;
  if Torotate=Line4Horiz then RotatedForm:=Line4Vertic;
  if Torotate=Line4Vertic then RotatedForm:=Line4Horiz;
  if Sens=Trigo then Case ToRotate of
    Line2Left:RotatedForm:=Line2Down;
    Line2Up:RotatedForm:=Line2Left;
    Line2Right:RotatedForm:=Line2Up;
    Line2Down:RotatedForm:=Line2Right;
    TorduOneOne:RotatedForm:=TorduFourOne;
    TorduTwoOne:RotatedForm:=TorduOneOne;
    TorduThreeOne:RotatedForm:=TorduTwoOne;
    TorduFourOne:RotatedForm:=TorduThreeOne;
    TorduOneTwo:RotatedForm:=TorduTwoTwo;
    TorduTwoTwo:RotatedForm:=TorduThreeTwo;
    TorduThreeTwo:RotatedForm:=TorduFourTwo;
    TorduFourTwo:RotatedForm:=TorduOneTwo;
    T_One:RotatedForm:=T_Two;
    T_Two:RotatedForm:=T_Three;
    T_Three:RotatedForm:=T_Four;
    T_Four:RotatedForm:=T_One;
  end;
  if Sens=AntiTrigo then Case ToRotate of
    Line2Left:RotatedForm:=Line2Up;
    Line2Up:RotatedForm:=Line2Right;
    Line2Right:RotatedForm:=Line2Down;
    Line2Down:RotatedForm:=Line2Left;
    TorduOneOne:RotatedForm:=TorduTwoOne;
    TorduTwoOne:RotatedForm:=TorduThreeOne;
    TorduThreeOne:RotatedForm:=TorduFourOne;
    TorduFourOne:RotatedForm:=TorduOneOne;
    TorduOneTwo:RotatedForm:=TorduFourTwo;
    TorduTwoTwo:RotatedForm:=TorduOneTwo;
    TorduThreeTwo:RotatedForm:=TorduTwoTwo;
    TorduFourTwo:RotatedForm:=TorduThreeTwo;
    T_One:RotatedForm:=T_Four;
    T_Two:RotatedForm:=T_One;
    T_Three:RotatedForm:=T_Two;
    T_Four:RotatedForm:=T_Three;
  end;
end;

{cette procÇdure Rotate est un peu porquesque, mais je vois pas trop comment
faire autrement}
Procedure TBLock.Rotate(Sens:Boolean);
var StockTiles:Array[0..3] of PTile;i:Byte;
begin
  if (Form<>Single) and (Form<>Nothing) then begin
    {changement des coordonnÇes des petits carrÇs}
    for i:=0 to NbrTile-1 do begin
      RelCoords[i].X:=FormDescription[RotatedForm(Form,Sens),i,0];
      RelCoords[i].Y:=FormDescription[RotatedForm(Form,Sens),i,1];
    end;
    {stockage des petits carrÇs (áa va servir pour juste apräs) }
    for i:=0 to NbrTile-1 do begin
      StockTiles[i]:=New(PTile,Init(Nil));
      Tiles[i]^.GiveValues(StockTiles[i]);
    end;
    {remise en ordre des petits carrÇs pour certain cas}
    if Form=BigSquare then if Sens=Trigo then begin
      StockTiles[0]^.GiveValues(Tiles[2]);
      StockTiles[1]^.GiveValues(Tiles[0]);
      StockTiles[2]^.GiveValues(Tiles[3]);
      StockTiles[3]^.GiveValues(Tiles[1]);
    end else begin
      StockTiles[0]^.GiveValues(Tiles[1]);
      StockTiles[1]^.GiveValues(Tiles[3]);
      StockTiles[2]^.GiveValues(Tiles[0]);
      StockTiles[3]^.GiveValues(Tiles[2]);
    end;
    if ((Form=Line3Vertic) and (Sens=AntiTrigo)) or
    ((Form=Line3Horiz) and (Sens=Trigo)) then begin
      StockTiles[1]^.GiveValues(Tiles[2]);
      StockTiles[2]^.GiveValues(Tiles[1]);
    end;
    if ((Form=SnakeVerticOne) and (Sens=Trigo)) or
    ((Form=SnakeHorizOne) and (Sens=AntiTrigo)) or
    ((Form=SnakeVerticTwo) and (Sens=Trigo)) or
    ((Form=SnakeHorizTwo) and (Sens=AntiTrigo)) or
    ((Form=Line4Vertic) and (Sens=Antitrigo)) or
    ((Form=Line4Horiz) and (Sens=Trigo)) then begin
      StockTiles[0]^.GiveValues(Tiles[3]);
      StockTiles[1]^.GiveValues(Tiles[2]);
      StockTiles[2]^.GiveValues(Tiles[1]);
      StockTiles[3]^.GiveValues(Tiles[0]);
    end;

    for i:=0 to NbrTile-1 do Dispose(StockTiles[i],Done);
    Form:=RotatedForm(Form,Sens);
  end;
end;

Destructor TBlock.Done;
var i:Byte;
begin
  for i:=0 to MaxTilesInABlock-1 do Dispose(Tiles[i],Done);
end;

{-------------------------------------------------------}

Const
  {Valeur possible de CurrentAction}
  MovingBlock=1*4096;
  GeneratingNewBlock=2*4096;
  TilesFalling=3*4096;
  DestroyingTiles=4*4096;
  BlockFalls=5*4096;
  PrincipalActionPossibilities=15*4096;
  MoveTime=80;

  SlowFall=3;
  FallTime=SlowFall*TileSize;
  SlowBlink=5;
  BlinkTime=10*SlowBLink;

Constructor TGame.Init(ArenaX,ArenaY,NextX,NextY:Integer;SizeX,SizeY:Word;AWhichPlayer:Boolean);
begin
  CoordArena.X:=ArenaX;
  CoordArena.Y:=ArenaY;
  CoordNext.Y:=NextY;
  CoordNext.X:=NextX;
  WhichPlayer:=AWhichPlayer;
  New(Arena,Init(SizeX,SizeY,@Self));
  New(CurrentBLock,Init(@Self));
  New(NextBLock,Init(@Self));
  NextBlock^.Randomgeneration;
  CurrentAction:=GeneratingNewBlock;
  EndGame:=False;
  Square(ArenaX-2,ArenaY-2,ArenaX+SizeX*TileSize+1,ArenaY+SizeY*TileSize+1,15);
  AfficheAll;
end;

Procedure TGame.ResetOrders;
begin
  GoLeft:=False;
  GoRight:=False;
  GoUp:=False;
  GoDown:=False;
  Action1:=False;
  Action2:=False;
end;

Procedure TGame.OrganizeOrders;
begin
  if GoLeft and GoRight then begin
    GoLeft:=False;
    GoRight:=False;
  end;
  if GoUp and GoDown then begin
    GoUp:=False;
    GoDown:=False;
  end;
end;

Procedure TGame.RefreshArena;
begin
  FilledSquare(CoordArena.X,CoordArena.Y,CoordArena.X+Arena^.Size.X*TileSize-1,CoordArena.Y+Arena^.Size.Y*TileSize-1,0);
  Arena^.Draws(CoordArena.X,CoordArena.Y);
  CurrentBLock^.Draws(CoordArena.X,CoordArena.Y,True);
  Affiche;
end;

Procedure TGame.SendBlockInArena;
var Stock:PBlock;
begin
  Stock:=CurrentBlock;
  CurrentBlock:=NextBlock;
  NextBlock:=Stock;
  NextBLock^.RandomGeneration;
  CurrentBlock^.Moves(Right,Arena^.Size.X div 2);
end;

Function TGame.MoveRotate:Boolean;
var SomethingChanged:Boolean;Sens:Boolean;
begin
  SomethingChanged:=False;
  With CurrentBLock^ do begin
    if GoLeft and not(Arena^.Collides(Form,Center.X-1,Center.Y)) then begin
      Moves(Left,1);
      SomethingChanged:=True;
    end;
    if GoRight and not(Arena^.Collides(Form,Center.X+1,Center.Y)) then begin
      Moves(Right,1);
      SomethingChanged:=True;
    end;
    if GoDown then begin
      ImmediateSetOnArena(Arena);
      CurrentAction:=TilesFalling;
      SomethingChanged:=True;
    end;

    if Action1 xor Action2 then begin
      Sens:=Action1;
      if (Form=BigSquare) or (Form=Single) then begin
        Rotate(Sens);
        SomethingChanged:=True;
      end else if not(Arena^.Collides(RotatedForm(Form,Sens),Center.X,Center.Y)) then begin
        Rotate(Sens);
        SomethingChanged:=True;
      end else begin
        if (Form=Line3Horiz) or (Form=Line2Left) or (Form=Line2Right) then
        if not(Arena^.Collides(RotatedForm(Form,Sens),Center.X,Center.Y-1)) then begin
          Moves(Up,1);
          Rotate(Sens);
          CurrentAction:=TilesFalling;
          SetOnArena(Arena);
          SomethingChanged:=True;
        end;
        if (Form=Line3Vertic) or ((Form=Line2Up) and (Sens=Trigo)) or ((Form=Line2Down) and (Sens=AntiTrigo)) then
        if not(Arena^.Collides(RotatedForm(Form,Sens),Center.X+1,Center.Y)) then begin
          Moves(Right,1);
          Rotate(Sens);
          SomethingChanged:=True;
        end;
        if (Form=Line3Vertic) or ((Form=Line2Up) and (Sens=AntiTrigo)) or ((Form=Line2Down) and (Sens=Trigo)) then
        if not(Arena^.Collides(RotatedForm(Form,Sens),Center.X-1,Center.Y)) then begin
          Moves(Left,1);
          Rotate(Sens);
          SomethingChanged:=True;
        end;
      end;
    end;
  end;
  MoveRotate:=SomethingChanged;
  if SomethingChanged then ResetOrders;
end;

Procedure TGame.PlayOneCycle;
begin
  Case CurrentACtion and PrincipalActionPossibilities of

    GeneratingNewBLock:begin
      if PArena(Arena)^.Collides(NextBlock^.Form,Arena^.Size.X div 2,0) then
      EndGame:=True else begin
        SendBlockInArena;
        FilledSquare(CoordNext.X-TileSize,CoordNext.Y-TileSize,CoordNext.X+4*TileSize-1,CoordNext.Y+4*TileSize-1,0);
        NextBLock^.Draws(CoordNext.X+TileSize,CoordNext.Y+TileSize,False);
        CurrentAction:=MovingBlock+MoveTime;
        RefreshArena;
        ResetOrders;
      end;
    end;

    MovingBlock:begin
      if CurrentAction=MovingBlock then begin
        if Arena^.Collides(CurrentBlock^.Form,CurrentBlock^.Center.X,CurrentBlock^.Center.Y+1) then begin
          CurrentBlock^.SetOnArena(Arena);
          CurrentAction:=TilesFalling;
        end else CurrentAction:=BlockFalls;{begin
          CurrentBLock^.Moves(Down,1);
          RefreshArena;
          CurrentAction:=MovingBlock+MoveTime;
        end;}
      end else begin
        Dec(CurrentAction);
        OrganizeOrders;
        if MoveRotate then RefreshArena;
      end;
    end;

    BlockFalls:begin
      Inc(CurrentAction);
      if (CurrentAction and not(PrincipalActionPossibilities)) mod SlowFall=0 then begin
        FilledSquare(CoordArena.X,CoordArena.Y,
        CoordArena.X+Arena^.Size.X*TileSize-1,CoordArena.Y+Arena^.Size.Y*TileSize-1,0);
        Arena^.Draws(CoordArena.X,CoordArena.Y);
        CurrentBlock^.Draws(CoordArena.X,
        CoordArena.Y+((CurrentAction and not(PrincipalActionPossibilities)) div SlowFall),True);
        Affiche;
      end;
      if (CurrentAction and not(PrincipalActionPossibilities))=FallTime then begin
        CurrentBLock^.Moves(Down,1);
        RefreshArena;
        CurrentAction:=MovingBlock+MoveTime;
      end;
    end;

    TilesFalling:begin
      if CurrentAction<>TilesFalling then begin
        if ((CurrentAction-1) and not(PrincipalActionPossibilities)) mod SlowFall=0 then begin
          FilledSquare(CoordArena.X,CoordArena.Y,
          CoordArena.X+Arena^.Size.X*TileSize-1,CoordArena.Y+Arena^.Size.Y*TileSize-1,0);
          Arena^.DrawTheFalling(CoordArena.X,CoordArena.Y,
          ((CurrentAction-1) and not(PrincipalActionPossibilities)) div SlowFall);
          Affiche;
        end;
        Inc(CurrentAction);
        if CurrentAction=TilesFalling+FallTime+1 then begin
          Arena^.TilesGoDown;
          CurrentAction:=TilesFalling;
        end;
      end;
      if CurrentAction=TilesFalling then
      if Arena^.SeeWhatFalls then Inc(CurrentAction) else CurrentAction:=DestroyingTiles;
    end;

    DestroyingTiles:begin
      if CurrentAction=DestroyingTiles then begin
        if Arena^.WhatToDestroy then CurrentAction:=DestroyingTiles+BlinkTime+1
        else CurrentAction:=GeneratingNewBlock;
      end else begin
        FilledSquare(CoordArena.X,CoordArena.Y,
        CoordArena.X+Arena^.Size.X*TileSize-1,CoordArena.Y+Arena^.Size.Y*TileSize-1,0);
        if Odd((CurrentAction and not(PrincipalActionPossibilities)) div SlowBlink) then
        Arena^.DrawSomeTiles(CoordArena.X,CoordArena.Y) else Arena^.Draws(CoordArena.X,CoordArena.Y);
        Affiche;
        Dec(CurrentAction);
        if CurrentAction=DestroyingTiles+1 then begin
          Arena^.SuppressTiles;
          CurrentAction:=TilesFalling;
        end;
      end;
    end;

  end;
end;

Destructor TGame.Done;
begin
  Dispose(Arena,Done);
  Dispose(CurrentBlock,Done);
  Dispose(NextBlock,Done);
end;

Constructor TUniverse.Init(P1,P2:Boolean);
begin
  if P1 then begin
    New(Player1,Init(160,0,260,75,8,15,Joueur1));
    Player1Exists:=True;
    Player1^.ResetOrders;
  end else Player1Exists:=False;
  if P2 then begin
    New(Player2,Init(2,0,100,75,8,15,Joueur2));
    Player2Exists:=True;
    Player2^.ResetOrders;
  end else Player2Exists:=False;
end;

Procedure TUniverse.TakeOrders;
var Key:Char;
begin
{  if Player1Exists then Player1^.ResetOrders;
  if Player2Exists then Player2^.ResetOrders;}
  While KeyPressed do begin
    Key:=Readkey;
    if Key=#0 then begin
      Key:=Readkey;
      if Player1Exists then With Player1^ do Case Key of
        #72:GoUp:=True;
        #75:GoLeft:=True;
        #80:GoDown:=True;
        #77:GoRight:=True;
      end;
    end else begin
      if Player1Exists then With Player1^ do Case Key of
        'o':Action1:=True;
        'p':Action2:=True;
      end;
      if Player2Exists then With Player2^ do Case Key of
        'd':GoUp:=True;
        'x':GoLeft:=True;
        'c':GoDown:=True;
        'v':GoRight:=True;
        'a':Action1:=True;
        'z':Action2:=True;
      end;
    end;
  end;
end;

Procedure TUniverse.Play;
begin
  Repeat
    TakeOrders;
    if Player1Exists then Player1^.PlayoneCycle;
    if Player2Exists then Player2^.PlayoneCycle;
    Delay(5);
  Until (Player1Exists and Player1^.EndGame) or (Player2Exists and Player2^.EndGame);
end;

Destructor TUniverse.Done;
begin
  if Player1Exists then Dispose(Player1,Done);
  if Player2Exists then Dispose(Player2,Done);
end;

Procedure ExplainButtons(TwoPlayer:Boolean);
begin
  ClrScr;
  GotoXY(1,2);
  WriteLn('  Joueur 1 :  ');
  WriteLn('   ');
  WriteLn('   fläches de direction  : bouger la piäce');
  WriteLn('   "O" et "P"            : tourner la piäce dans un sens ou dans l''autre');
  if TwoPlayer then begin
    WriteLn('   ');
    WriteLn('   ');
    WriteLn('   ');
    WriteLn('  Joueur 2 :  ');
    WriteLn('   ');
    WriteLn('   "X", "C", "V"       : bouger la piäce');
    WriteLn('   "A" et "Z"          : tourner la piäce dans un sens ou dans l''autre');
    WriteLn('   ');
    WriteLn('   ');
    WriteLn('   ');
    WriteLn('   ');
    WriteLn('   Le joueur 1 est Ö droite, le joueur 2 est Ö gauche');
  end;
  While keypressed do Readkey;
  Readkey;
end;

var
  Machin:PUniverse;
  Answer:Char;

begin
  ClrScr;
  While keypressed do Readkey;
  GotoXY(20,12);
  Write('nombre de joueurs. (1 ou 2)');
  Answer:='Z';
  While (Answer<>'1') and (Answer<>'2') do Answer:=Readkey;
  ExplainButtons(Answer='2');
  MCGaScreen;
  Randomize;
  New(Machin,Init(True,Answer='2'));
  Machin^.Play;
  Machin^.Done;
  CLoseScreen;
end.