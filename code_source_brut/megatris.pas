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
    Destructor Done; virtual;
  end;

  TTile=Object(TObject)
    Solid:Boolean;
    Color:Byte;
    ArenaOwner:PArena;
    BlockOwner:PBlock;
    Constructor Init(AOwner:PArena;BOwner:PBlock);
    Procedure Draws(X,Y:Integer); virtual;
    Procedure RandomGeneration; virtual;
    Procedure Clear; virtual;
    Procedure GiveValues(Dest:PTile); virtual;
    Destructor Done; virtual;
  end;

  TBlock=Object(TObject)
    Tiles:Array[0..MaxTilesInABlock-1] of PTile;   { Tiles[0] et Coords[0] sont les }
    Coords:Array[0..MaxTilesInABlock-1] of TCoord; { caract‚ristiques du petit carr‚ principal}
    Owner:PGame;
    NbrTile,Form:Byte;
    Constructor Init(AOwner:PGame);
    Procedure Draws(X,Y:Integer;InAnArena:Boolean); virtual;
    Procedure Moves(Direction,Dist:Byte); virtual;
    Procedure RandomGeneration; virtual;
    Procedure SetOnArena(Dest:PArena); virtual;
    Procedure Rotate(Sens:Boolean); virtual;
    Destructor Done; virtual;
  end;


Const
  TileSize=16;

  {valeurs possibles de TBlock^.Form}
  Nothing=0;         {}
  BigSquare=1;       { #o }
                     { oo }

  Single=2;          { # }

  Line3Vertic=3;     { o }
                     { # }
                     { o }

  Line3Horiz=4;      { o#o }

  Line2Left=5;       { o# }

  Line2Right=6;      { #o }

  Line2Up=7;         { o }
                     { # }

  Line2Down=8;       { # }
                     { o }

   { # = Position du petit carr‚ principal
     o = Position des autres petits carr‚s}

  FormDescription:Array[0..8,0..MaxTilesInABlock-1,0..1] of ShortInt=(
  ((0,0),(0,0),(0,0),(0,0)),  {Nothing}
  ((0,0),(1,0),(0,1),(1,1)),  {BigSquare}
  ((0,0),(0,0),(0,0),(0,0)),  {Single}
  ((0,0),(0,-1),(0,1),(0,0)),  {Line3Vertic}
  ((0,0),(-1,0),(1,0),(0,0)), {Line3Horiz}
  ((0,0),(-1,0),(0,0),(0,0)), {Line2Left}
  ((0,0),(1,0),(0,0),(0,0)), {Line2Right}
  ((0,0),(0,-1),(0,0),(0,0)),  {Line2Up}
  ((0,0),(0,1),(0,0),(0,0)));  {Line2Down}

  {les coordon‚es des petits carr‚s doivent ˆtre d‚finies … partir de la position
  du centre, c'est pour ‡a que les coordonn‚es du petit carr‚ principal
  (c'est le premier dans le tableau) sont toujours (0,0) }

  NbrTileDescription:Array[0..8] of Byte=(0,4,1,3,3,2,2,2,2);

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

Constructor TTile.Init(AOwner:PArena;BOwner:PBlock);
begin
  Solid:=False;
  Color:=0;
  ArenaOwner:=AOwner;
  BlockOwner:=BOwner;
{  if Random(2)=1 then Solid:=False else Solid:=True;}
end;

Procedure TTile.Draws(X,Y:Integer);
begin
  if Solid then FilledSquare(X,Y,X+TileSize-1,Y+TileSize-1,Color);
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
  Data[i,j]:=New(PTile,Init(@Self,Nil));
end;

Procedure TArena.Draws(X,Y:Word);
var i,j:Word;
begin
  for i:=0 to Size.X-1 do for j:=0 to Size.Y-1 do
  PTile(Data[i,j])^.Draws(X+i*TileSize,Y+j*TileSize);
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
var i,j:Word;FoundEmptyTile,AllMustFall,Result:Boolean;
begin
  FillChar(DataBool,SizeOf(DataBool),0);
  Result:=False;
  for i:=0 to Size.X-1 do begin
    FoundEmptyTile:=False;
    AllmustFall:=False;
    for j:=Size.Y-1 downto 0 do begin
      if not(FoundEmptyTile) and not(Data[i,j]^.Solid) then FoundEmptyTile:=True;
      if FoundEmptyTile and Data[i,j]^.Solid then AllMustFall:=True;
      if AllMustFall then DataBool[i,j]:=True;
    end;
    Result:=Result or AllMustFall;
  end;
  SeeWhatFalls:=Result;
end;

Procedure TArena.DrawTheFalling(X,Y:Integer;TimeFall:Byte);
var i,j:Word;
begin
  for i:=0 to Size.X-1 do for j:=0 to Size.Y-1 do if DataBool[i,j] then
  Data[i,j]^.Draws(X+i*TileSize,Y+j*TileSize+TimeFall) else
  Data[i,j]^.Draws(X+i*TileSize,Y+j*TileSize);
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

Procedure TArena.DrawSomeTiles(X,Y:Word);
var i,j:Word;
begin
  for i:=0 to Size.X-1 do for j:=0 to Size.Y-1 do if not(DataBool[i,j]) then
  PTile(Data[i,j])^.Draws(X+i*TileSize,Y+j*TileSize);
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
  for i:=0 to MaxTilesInABlock-1 do Tiles[i]:=New(PTile,Init(Nil,@Self));
end;

Procedure TBlock.Draws(X,Y:Integer;InAnArena:Boolean);
var i:Byte;
begin
  if NbrTile<>0 then for i:=0 to NbrTile-1 do
  if not(InAnArena and (Coords[i].Y<0)) then
  PTile(Tiles[i])^.Draws(X+Coords[i].X*TileSize,Y+Coords[i].Y*TileSize);
  Draw(X-TileSize,Y-TileSize,X+Tilesize*2-1,Y+Tilesize*2-1);
end;


Procedure TBlock.RandomGeneration;
var i,Choice:Byte;
Const
  ProbaForm:Array[0..8] of Byte=(0,1,2,3,3,3,3,4,4);
  {ce tableau donne les probabilit‚s d'apparition des piŠces de diff‚rentes
  forme. Attention, il faut donner les probabilit‚s cumul‚s, c'est
  pour ‡a que les nombres sont croissants}
begin
  Choice:=Random(ProbaForm[8])+1;
  Form:=0;
  While Choice<>ProbaForm[Form] do Inc(Form);
  NbrTile:=NbrTileDescription[Form];
  if NbrTile<>0 then for i:=0 to NbrTile-1 do begin
    Coords[i].X:=FormDescription[Form,i,0];
    Coords[i].Y:=FormDescription[Form,i,1];
    PTile(Tiles[i])^.RandomGeneration;
  end;
end;

Procedure TBlock.Moves(Direction,Dist:Byte);
var i:Byte;MoveValue:ShortInt;
begin
  if NbrTile<>0 then begin
    if (Direction=Right) or (Direction=Down) then MoveValue:=Dist;
    if (Direction=Left) or (Direction=Up) then MoveValue:=-Dist;
    if (Direction=Left) or (Direction=Right) then
    for i:=0 to NbrTile-1 do Inc(Coords[i].X,MoveValue);
    if (Direction=Up) or (Direction=Down) then
    for i:=0 to NbrTile-1 do Inc(Coords[i].Y,MoveValue);
  end;
end;

Procedure TBLock.SetOnArena(Dest:PArena);
var i:Byte;LocateX,LocateY:Integer;
begin
  if NbrTile<>0 then for i:=0 to NbrTile-1 do begin
    LocateX:=Coords[i].X;
    LocateY:=Coords[i].Y;
    if (LocateX>=0) and (LocateX<PArena(Dest)^.Size.X) and
    (LocateY>=0) and (LocateY<PArena(Dest)^.Size.Y) then
    PTile(Tiles[i])^.GiveValues(PArena(Dest)^.Data[LocateX,LocateY]);
  end;
end;

Function RotatedForm(ToRotate:Byte;Sens:Boolean):Byte;
begin
  if (ToRotate=Single) or (ToRotate=BigSquare) then RotatedForm:=ToRotate;
  if ToRotate=Line3Vertic then RotatedForm:=Line3Horiz;
  if ToRotate=Line3Horiz then RotatedForm:=Line3Vertic;
  if Sens=Trigo then Case ToRotate of
    Line2Left:RotatedForm:=Line2Down;
    Line2Up:RotatedForm:=Line2Left;
    Line2Right:RotatedForm:=Line2Up;
    Line2Down:RotatedForm:=Line2Right;
  end;
  if Sens=AntiTrigo then Case ToRotate of
    Line2Left:RotatedForm:=Line2Up;
    Line2Up:RotatedForm:=Line2Right;
    Line2Right:RotatedForm:=Line2Down;
    Line2Down:RotatedForm:=Line2Left;
  end;
end;

{cette proc‚dure Rotate est un peu porquesque, mais je vois pas trop comment
faire autrement}
Procedure TBLock.Rotate(Sens:Boolean);
var StockTiles:Array[0..3] of PTile;i:Byte;
begin
  if (Form<>Single) and (Form<>Nothing) then begin
    for i:=0 to NbrTile-1 do begin
      StockTiles[i]:=New(PTile,Init(Nil,@Self));
      Tiles[i]^.GiveValues(StockTiles[i]);
    end;
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
    if Form=Line3Vertic then begin
      Coords[1].X:=Coords[0].X-1;
      Coords[1].Y:=Coords[0].Y;
      Coords[2].X:=Coords[0].X+1;
      Coords[2].Y:=Coords[0].Y;
      if Sens=Trigo then begin
        StockTiles[1]^.GiveValues(Tiles[2]);
        StockTiles[2]^.GiveValues(Tiles[1]);
      end;
    end;
    if Form=Line3Horiz then begin
      Coords[1].X:=Coords[0].X;
      Coords[1].Y:=Coords[0].Y-1;
      Coords[2].X:=Coords[0].X;
      Coords[2].Y:=Coords[0].Y+1;
      if Sens=AntiTrigo then begin
        StockTiles[1]^.GiveValues(Tiles[2]);
        StockTiles[2]^.GiveValues(Tiles[1]);
      end;
    end;
    if (Form=Line2Left) or (Form=Line2Right) or (Form=Line2Up) or (Form=Line2Down) then begin
      Coords[1].X:=Coords[0].X+FormDescription[RotatedForm(Form,Sens),1,0];
      Coords[1].Y:=Coords[0].Y+FormDescription[RotatedForm(Form,Sens),1,1];
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
  PrincipalActionPossibilities=15*4096;
  MoveTime=80;

  SlowFall=3;
  FallTime=SlowFall*TileSize;
  SlowBlink=5;
  BlinkTime=10*SlowBLink;

Constructor Tgame.Init(ArenaX,ArenaY,NextX,NextY:Integer;SizeX,SizeY:Word;AWhichPlayer:Boolean);
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
end;

Function TGame.MoveRotate:Boolean;
var SomethingChanged:Boolean;Sens:Boolean;
begin
  SomethingChanged:=False;
  With CurrentBLock^ do begin
    if GoLeft and not(Arena^.Collides(Form,Coords[0].X-1,Coords[0].Y)) then begin
      Moves(Left,1);
      SomethingChanged:=True;
    end;
    if GoRight and not(Arena^.Collides(Form,Coords[0].X+1,Coords[0].Y)) then begin
      Moves(Right,1);
      SomethingChanged:=True;
    end;
    if GoDown then if not(Arena^.Collides(Form,Coords[0].X,Coords[0].Y+1)) then begin
      Moves(Down,1);
      SomethingChanged:=True;
    end else begin
      CurrentAction:=TilesFalling;
      SetOnArena(Arena);
    end;

    if Action1 xor Action2 then begin
      Sens:=Action1;
      if (Form=BigSquare) or (Form=Single) then begin
        Rotate(Sens);
        SomethingChanged:=True;
      end else if not(Arena^.Collides(RotatedForm(Form,Sens),Coords[0].X,Coords[0].Y)) then begin
        Rotate(Sens);
        SomethingChanged:=True;
      end else begin
        if (Form=Line3Horiz) or (Form=Line2Left) or (Form=Line2Right) then
        if not(Arena^.Collides(RotatedForm(Form,Sens),Coords[0].X,Coords[0].Y-1)) then begin
          Moves(Up,1);
          Rotate(Sens);
          CurrentAction:=TilesFalling;
          SetOnArena(Arena);
          SomethingChanged:=True;
        end;
        if (Form=Line3Vertic) or ((Form=Line2Up) and (Sens=Trigo)) or ((Form=Line2Down) and (Sens=AntiTrigo)) then
        if not(Arena^.Collides(RotatedForm(Form,Sens),Coords[0].X+1,Coords[0].Y)) then begin
          Moves(Right,1);
          Rotate(Sens);
          SomethingChanged:=True;
        end;
        if (Form=Line3Vertic) or ((Form=Line2Up) and (Sens=AntiTrigo)) or ((Form=Line2Down) and (Sens=Trigo)) then
        if not(Arena^.Collides(RotatedForm(Form,Sens),Coords[0].X-1,Coords[0].Y)) then begin
          Moves(Left,1);
          Rotate(Sens);
          SomethingChanged:=True;
        end;
      end;
    end;
  end;
  MoveRotate:=SomethingChanged;
end;

Procedure TGame.PlayOneCycle;
begin
  Case CurrentACtion and PrincipalActionPossibilities of

    GeneratingNewBLock:begin
      NextBLock^.Moves(Right,Arena^.Size.X div 2);
      if PArena(Arena)^.Collides(NextBlock^.Form,NextBlock^.Coords[0].X,NextBlock^.Coords[0].Y) then
      EndGame:=True else begin
        SendBlockInArena;
        FilledSquare(CoordNext.X,CoordNext.Y,CoordNext.X+3*TileSize-1,CoordNext.Y+3*TileSize-1,0);
        NextBLock^.Draws(CoordNext.X+TileSize,CoordNext.Y+TileSize,False);
        CurrentAction:=MovingBlock+MoveTime;
        RefreshArena;
      end;
    end;

    MovingBlock:begin
      if CurrentAction=MovingBlock then begin
        if Arena^.Collides(CurrentBlock^.Form,CurrentBlock^.Coords[0].X,CurrentBlock^.Coords[0].Y+1) then begin
          CurrentBlock^.SetOnArena(Arena);
          CurrentAction:=TilesFalling;
        end else begin
          CurrentBLock^.Moves(Down,1);
          RefreshArena;
          CurrentAction:=MovingBlock+MoveTime;
        end;
      end else begin
        Dec(CurrentAction);
        OrganizeOrders;
        if MoveRotate then RefreshArena;
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
    New(Player1,Init(160,0,110,50,6,12,Joueur1));
    Player1Exists:=True;
  end else Player1Exists:=False;
  if P2 then begin
    New(Player2,Init(0,00,110,150,6,12,Joueur2));
    Player2Exists:=True;
  end else Player2Exists:=False;
end;

Procedure TUniverse.TakeOrders;
var Key:Char;
begin
  if Player1Exists then Player1^.ResetOrders;
  if Player2Exists then Player2^.ResetOrders;
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

var Machin:PUniverse;

begin
  MCGaScreen;
  Randomize;
  New(Machin,Init(True,False));
  Machin^.Play;
  Machin^.Done;
  CLoseScreen;
end.