Uses Crt,MCGAGraf,Objects;

Const
  MaxSizeX=10;
  MaxSizeY=30;
  MaxTilesInABlock=4;

  NbrBlock=27;


  ProbaFormConst:Array[0..2,0..NbrBlock-1] of Byte=(
  (0,0,0, 2,2, 1,1,1,1, 0,0, 0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 2,2),
  (0,2,0, 0,0, 0,0,0,0, 0,0, 0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 1,1),
  (0,0,0, 0,0, 0,0,0,0, 2,2, 2,2, 1,1,1,1, 1,1,1,1, 1,1,1,1, 0,0));
  {ce tableau donne les probabilit‚s d'apparition des piŠces de diff‚rentes
  forme.
  il y a trois tableaux de probabilit‚ pr‚d‚finie.}


  Classic=1;

  Connect=2;




Type
  PUniverse=^TUniverse;
  PTile=^TTile;
  PGame=^TGame;
  PTetrislike=^TTetrislike;
  PConnect=^TConnect;
  PClassic=^TClassic;
  PArena=^TArena;
  PBlock=^TBlock;

  TCoord=Record
    X,Y:Integer;
  end;

  TUniverse=Object(TObject)
    Player1Exists,Player2Exists:Boolean;
    Player1,Player2:PGame;
    Constructor Init(P1,P2,Data1,Data2:Byte);
    Procedure TakeOrders; virtual;
    Procedure Play; virtual;
    Destructor Done; virtual;
  end;

  TGame=Object(TObject)
    WhichPlayer,GoLeft,GoRight,GoUp,GoDown,Action1,Action2,EndGame:Boolean;
    Constructor Init;
    Procedure OrganizeOrders; virtual;
    Procedure PlayOneCycle; virtual;
    Procedure ResetOrders; virtual;
    Destructor Done; virtual;
  end;

  TTetrisLike=Object(TGame)
    Arena:PArena;
    CurrentAction:Word;
    CurrentBLock,NextBlock:PBLock;
    CoordNext,CoordArena:TCoord;
    ProbaForm:Array[0..NbrBlock-1] of Byte;
    TetType:Byte;
    Constructor Init(ArenaX,ArenaY,NextX,NextY:Integer;SizeX,SizeY:Word;AWhichPlayer:Boolean;BlockPack:Byte);
    Procedure PlayOneCycle; virtual;
    Procedure SendBlockInArena; virtual;
    Procedure RefreshArena; virtual;
    Function MoveRotate:Boolean; virtual;
    Destructor Done; virtual;
  end;

  TConnect=Object(TTetrislike)
    MaxColor,NbrTileToAttach:Byte;
    Constructor Init(ArenaX,ArenaY,NextX,NextY:Integer;SizeX,SizeY:Word;AWhichPlayer:Boolean;
    BlockPack,AMaxColor,ANbrTileToAttach:Byte);
  end;

  TClassic=Object(TTetrislike)
    Constructor Init(ArenaX,ArenaY,NextX,NextY:Integer;SizeX,SizeY:Word;AWhichPlayer:Boolean;BlockPack:Byte);
  end;

  TArena=Object(TObject)
    Data:Array[0..MaxSizeX-1,0..MaxSizeY-1] of PTile;
    DataBool:Array[0..MaxSizeX-1,0..MaxSizeY-1] of Boolean;
    Owner:PTetrislike;
    Size:TCoord;
    Constructor Init(SizeX,SizeY:Word;AOwner:PTetrislike);
    Procedure Draws(X,Y:Word); virtual;
    Function TArena.LineFull(Ord:Integer):Boolean;
    Function TArena.LineEmpty(Ord:Integer):Boolean;
    Function Collides(AForm:Byte;CenterCoordX,CenterCoordY:Integer):Boolean; virtual;
    Function SeeWhatFalls:Boolean; virtual;
    Procedure DrawTheFalling(X,Y:Integer;TimeFall:Byte); virtual;
    Procedure TilesGoDown; virtual;
    Function WhatToDestroy:Boolean; virtual;
    Procedure DrawSomeTiles(X,Y:Word); virtual;
    Procedure SuppressTiles; virtual;
    Destructor Done; virtual;
  end;

  TTile=Object(TObject)
    Solid:Boolean;
    Color:Byte;
    Owner:PTetrisLike;
    Constructor Init(AOwner:PTetrislike);
    Procedure Draws(X,Y:Integer;Hidden_By_The_Limits_Of_The_Arena:Boolean);
    Procedure RandomGeneration(TetType,PieceForm:Byte);
    Procedure Clear; virtual;
    Procedure GiveValues(Dest:PTile); virtual;
    Destructor Done; virtual;
  end;

  TBlock=Object(TObject)
    Tiles:Array[0..MaxTilesInABlock-1] of PTile;
    RelCoords:Array[0..MaxTilesInABlock-1] of TCoord;
    Center:TCoord;
    Owner:PTetrislike;
    NbrTile,Form:Byte;
    Constructor Init(AOwner:PTetrislike);
    Procedure Draws(X,Y:Integer;InAnArena:Boolean); virtual;
    Procedure Moves(Direction,Dist:Byte); virtual;
    Procedure RandomGeneration; virtual;
    Procedure SetOnArena(Dest:PArena); virtual;
    Procedure ImmediateSetOnArena(Dest:PArena);
    Procedure Rotate(Sens:Boolean); virtual;
    Destructor Done; virtual;
  end;
  {un block est un groupe de petit carr‚s, c'est le truc qui tombe
  dans l'aire de jeu et qu'on peut bouger et faire tourner}


Const
  TileSize=8;

  {valeurs possibles de TBlock^.Form, avec l'image du block … c“t‚ }
  Nothing=0;         {}         {}

  BigSquare=1;       { ÛÛ }     { 01 }
                     { ÛÛ }     { 23 }

  Single=2;          { Û }      { 0 }

  Line3Vertic=3;     { Û }      { 1 }
                     { Û }      { 0 }
                     { Û }      { 2 }

  Line3Horiz=4;      { ÛÛÛ }    { 102 }

  Line2Left=5;       { ÛÛ }     { 10 }

  Line2Right=6;      { ÛÛ }     { 01 }

  Line2Up=7;         { Û }      { 1 }
                     { Û }      { 0 }

  Line2Down=8;       { Û }      { 0 }
                     { Û }      { 1 }

  SnakeHorizOne=9;   {  ÛÛ }    {  23 }
                     { ÛÛ  }    { 01  }

  SnakeVerticOne=10; { Û  }     { 3  }
                     { ÛÛ }     { 21 }
                     {  Û }     {  0 }

  SnakeHorizTwo=11;  { ÛÛ  }    { 01  }
                     {  ÛÛ }    {  23 }

  SnakeVerticTwo=12; {  Û }     {  3 }
                     { ÛÛ }     { 12 }
                     { Û  }     { 0  }

  TorduOneOne=13;     { ÛÛ }     { 01 }
                      {  Û }     {  2 }
                      {  Û }     {  3 }

  TorduTwoOne=14;     {    Û }   {   0 }
                      { ÛÛÛÛ }   { 321 }

  TorduThreeOne=15;  { Û  }     { 3  }
                     { Û  }     { 2  }
                     { ÛÛ }     { 10 }

  TorduFourOne=16;   { ÛÛÛÛ }   { 123 }
                     { Û    }   { 0   }

  TorduOneTwo=17;    {  ÛÛ }     { 10 }
                     {  Û  }     { 2  }
                     {  Û  }     { 3  }

  TorduTwoTwo=18;     { Û    }   { 0   }
                      { ÛÛÛÛ }   { 123 }

  TorduThreeTwo=19;  {  Û }     {  3 }
                     {  Û }     {  2 }
                     { ÛÛ }     { 01 }

  TorduFourTwo=20;   { ÛÛÛÛ }   { 321 }
                     {    Û }   {   0 }

  T_One=21;          { Û  }         { 1  }
                     { ÛÛ }         { 20 }
                     { Û  }         { 3  }

  T_Two=22;          {  Û  }        {  0  }
                     { ÛÛÛ }        { 123 }

  T_Three=23;        {  Û }         {  3 }
                     { ÛÛ }         { 02 }
                     {  Û }         {  1 }

  T_Four=24;         { ÛÛÛ }        { 321 }
                     {  Û  }        {  0  }

  Line4Horiz=25;     { ÛÛÛÛ }       { 0123 }

  Line4Vertic=26;    { Û }          { 0 }
                     { Û }          { 1 }
                     { Û }          { 2 }
                     { Û }          { 3 }



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

Constructor TTile.Init(AOwner:PTetrislike);
begin
  Solid:=False;
  Owner:=AOwner;
  Color:=0;
end;

Function Max(X1,X2:Integer):Integer;
begin
  if X1>X2 then Max:=X1 else Max:=X2;
end;

Function Min(X1,X2:Integer):Integer;
begin
  if X1<X2 then Min:=X1 else Min:=X2;
end;

Procedure TTile.RandomGeneration(TetType,PieceForm:Byte);
begin
  Solid:=True;
  Case TetType of
    Connect:Color:=Random(PConnect(Owner)^.MaxColor);
    Classic:Color:=PieceForm;
  end;
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

Procedure TTile.Clear;
begin
  Solid:=False;
  Color:=0;
end;

Procedure TTile.GiveValues(Dest:PTile);
begin
  PTile(Dest)^.Solid:=Solid;
  PTile(Color)^.Color:=Color;
end;

Destructor TTile.Done;
begin
end;

{-------------------------------------------------------}

Constructor TArena.Init(SizeX,SizeY:Word;AOwner:PTetrislike);
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


Procedure TArena.Draws(X,Y:Word);
var i,j:Word;
begin
  for i:=0 to Size.X-1 do for j:=0 to Size.Y-1 do
  Data[i,j]^.Draws(X+i*TileSize,Y+j*TileSize,False);
  Draw(X,Y,X+Size.X*TileSize,Y+Size.Y*TileSize);
end;

{la fonction collides permet de savoir si un certain block se superpose
au tiles de l'arŠne. On doit indiquer la forme du block et les coordonn‚es
de sa case principale.
Ce qu'il y a de bien, c'est que c'est pas la peine de cr‚er un nouvel
objet block juste pour voir si il entre en collision avec les tiles de
l'arŠne, il y a juste des paramŠtres … entrer}
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
begin
  SeeWhatFalls:=False;
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

  Function ClassicDestroy:Boolean;
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

  Function ConnectDestroy:Boolean;
  var Tested,Testing:Array[0..MaxSizeX-1,0..MaxSizeY-1] of Boolean;i,j,i2,j2:Byte;NbrTileAttached:Word;

    Procedure Attach(X,Y:Integer;TheColor:Byte);
    begin
      Testing[X,Y]:=True;
      Tested[X,Y]:=True;
      Inc(NbrTileAttached);
      if (X>0) and not(Tested[X-1,Y]) and Data[X-1,Y]^.Solid and (Data[X-1,Y]^.Color=TheColor) then Attach(X-1,Y,TheColor);
      if (X<Size.X-1) and not(Tested[X+1,Y]) and Data[X+1,Y]^.Solid and
      (Data[X+1,Y]^.Color=TheColor) then Attach(X+1,Y,TheColor);
      if (Y>0) and not(Tested[X,Y-1]) and Data[X,Y-1]^.Solid and (Data[X,Y-1]^.Color=TheColor) then Attach(X,Y-1,TheColor);
      if (Y<Size.Y-1) and not(Tested[X,Y+1]) and Data[X,Y+1]^.Solid and
      (Data[X,Y+1]^.Color=TheColor) then Attach(X,Y+1,TheColor);
    end;
    {    un petit peu de r‚cursivit‚ pour faire joli    }

  begin
    FillChar(Tested,SizeOf(Tested),0);
    FillChar(Testing,SizeOf(Testing),0);
    FillChar(DataBool,SizeOf(DataBool),0);
    WhatToDestroy:=False;
    for i:=0 to Size.X-1 do for j:=0 to Size.Y-1 do begin
      NbrTileAttached:=0;
      if not(Tested[i,j]) and Data[i,j]^.Solid then Attach(i,j,Data[i,j]^.Color);
      if NbrTileAttached>=NbrTileToAttach then begin
        for i2:=0 to Size.X-1 do for j2:=0 to Size.Y-1 do if Testing[i2,j2] then DataBool[i2,j2]:=True;
        WhatToDestroy:=True;
      end;
      FillChar(Testing,SizeOf(Testing),0);
    end;
  end;

begin
  Case Owner^.TetType of
    Classic:
  end;
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

Constructor TBlock.Init(AOwner:PTetrislike);
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
{Const
  ProbaForm:Array[0..NbrBlock-1] of Byte=
  (0,0,0,0,0, 0,0,0,0, 0,0, 0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0);
  {ce tableau donne les probabilit‚s d'apparition des piŠces de diff‚rentes
  forme.}
begin
  ProbaSum:=0;
  for i:=0 to NbrBlock-1 do Inc(ProbaSum,Owner^.ProbaForm[i]);
  Choice:=Random(ProbaSum)+1;
  Form:=0;
  While Choice>0 do begin
    Dec(Choice,Owner^.ProbaForm[Form]);
    Inc(Form);
  end;
  Dec(Form);
  NbrTile:=NbrTileDescription[Form];
  if NbrTile<>0 then for i:=0 to NbrTile-1 do begin
    RelCoords[i].X:=FormDescription[Form,i,0];
    RelCoords[i].Y:=FormDescription[Form,i,1];
    PTile(Tiles[i])^.RandomGeneration(Owner^.TetType,Form);
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

{Glups!! J'aurais mieux fait de faire un tableau de constantes plut“t
que cette function RotatedForm!!
je changerais ‡a plus tard}
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

{cette proc‚dure Rotate est un peu porquesque, mais je vois pas trop comment
faire autrement}
Procedure TBLock.Rotate(Sens:Boolean);
var StockTiles:Array[0..3] of PTile;i:Byte;
begin
  if (Form<>Single) and (Form<>Nothing) then begin
    {changement des coordonn‚es des petits carr‚s}
    for i:=0 to NbrTile-1 do begin
      RelCoords[i].X:=FormDescription[RotatedForm(Form,Sens),i,0];
      RelCoords[i].Y:=FormDescription[RotatedForm(Form,Sens),i,1];
    end;
    {stockage des petits carr‚s (‡a va servir pour juste aprŠs) }
    for i:=0 to NbrTile-1 do begin
      StockTiles[i]:=New(PTile,Init(Nil));
      Tiles[i]^.GiveValues(StockTiles[i]);
    end;
    {remise en ordre des petits carr‚s pour certain cas}
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

Constructor TGame.Init;
begin
end;

Constructor TTetrisLike.Init(ArenaX,ArenaY,NextX,NextY:Integer;SizeX,SizeY:Word;AWhichPlayer:Boolean;BlockPack:Byte);
var i:Byte;
begin
  for i:=0 to NbrBlock-1 do ProbaForm[i]:=ProbaFormConst[BlockPack,i];
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

Procedure TTetrisLike.RefreshArena;
begin
  FilledSquare(CoordArena.X,CoordArena.Y,CoordArena.X+Arena^.Size.X*TileSize-1,CoordArena.Y+Arena^.Size.Y*TileSize-1,0);
  Arena^.Draws(CoordArena.X,CoordArena.Y);
  CurrentBLock^.Draws(CoordArena.X,CoordArena.Y,True);
  Affiche;
end;

Procedure TTetrisLike.SendBlockInArena;
var Stock:PBlock;
begin
  Stock:=CurrentBlock;
  CurrentBlock:=NextBlock;
  NextBlock:=Stock;
  NextBLock^.RandomGeneration;
  CurrentBlock^.Moves(Right,Arena^.Size.X div 2);
end;

Function TTetrisLike.MoveRotate:Boolean;
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
end;

Procedure TTetrisLike.PlayOneCycle;
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

Destructor TTetrisLike.Done;
begin
  Dispose(Arena,Done);
  Dispose(CurrentBlock,Done);
  Dispose(NextBlock,Done);
end;

Destructor TGame.Done;
begin
end;

Constructor TUniverse.Init(P1,P2,Data1,Data2:Byte);
begin
  if P1<>Nothing then begin
    Player1:=New(PTetrisLike,Init(160,0,260,75,7,15,Joueur1,0));
    Player1Exists:=True;
    Player1^.ResetOrders;
  end else Player1Exists:=False;
  if P2<>Nothing then begin
    Player2:=New(PTetrislike,Init(2,0,100,75,7,15,Joueur2,1));
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

Constructor TConnect.Init(ArenaX,ArenaY,NextX,NextY:Integer;SizeX,SizeY:Word;AWhichPlayer:Boolean;
    BlockPack,AMaxColor,ANbrTileToAttach:Byte);
begin
  TTetrislike.Init(ArenaX,ArenaY,NextX,NextY,SizeX,SizeY,AWhichPlayer,BlockPack);
  MaxColor:=AMaxColor;
  NbrTileToAttach:=NbrTileToAttach;
  TetType:=Connect;
end;

Constructor TClassic.Init(ArenaX,ArenaY,NextX,NextY:Integer;SizeX,SizeY:Word;AWhichPlayer:Boolean;BlockPack:Byte);
begin
  TTetrislike.Init(ArenaX,ArenaY,NextX,NextY,SizeX,SizeY,AWhichPlayer,BlockPack);
  TetType:=Classic;
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
  MCGaScreen;
  Randomize;
  New(Machin,Init(1,1,0,0));
  Machin^.Play;
  Machin^.Done;
  CLoseScreen;
end.