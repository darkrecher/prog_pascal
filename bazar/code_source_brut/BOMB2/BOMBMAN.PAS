Uses BombImg,MCGAGraf,ZeTime,KeyBoard,Objects,Dos,BombConf;

Const
  TerrainCornerX=8;
  TerrainCornerY=21;
  TileSizeX=16;
  TileSizeY=TileSizeX;

Type
{  PBonus=^TBonus;}
  PTile=^TTile;
  PFlame=^TFlame;
  PPlayer=^TPlayer;
  PGame=^TGame;
  PBomb=^TBomb;
  PDeadPlayer=^TDeadPlayer;
  PUniverse=^TUniverse;
  TTileType=(Nothing,Wall,SuperWall,Flame,Bonus);
  TDirection=(Up,Right,Down,Left,None);
  TCoordTile=Record
    X,Y:Integer;
    Used:Boolean;
  end;

  TPlayers=Array[0..3] of PPLayer;
  TState=(Safe,Dangerous,SuperDangerous);
  TTile=Object(TObject)
    TileType:TTileType;
    Bomb:PBomb;
    X,Y:Integer;
    Owner:PGame;
    Redraw,CanLayBomb:Boolean;
    State:TState;
    Constructor Init(AX,AY:Integer;AOwner:PGame);
    Procedure Draws; virtual;
    Function Flamed(ADir:TDirection;AExt:Boolean):Boolean; virtual;
    Function CanWalk:Boolean; virtual;
    Procedure Handle; virtual;
    Function PlayersOnTile(var Resul:TPlayers):Integer;
    Function PlayersTouchingTile(var Resul:TPlayers):Integer;
    Destructor Done; virtual;
  end;

  PNothing=^TNothing;
  TNothing=Object(TTile)
    Flame:PFlame;
    Constructor Init(AX,AY:Integer;AOwner:PGame);
    Function Flamed(ADir:TDirection;AExt:Boolean):Boolean; virtual;
    Procedure Handle; virtual;
    Function CanWalk:Boolean; virtual;
    Procedure Draws; virtual;
    Destructor Done; virtual;
  end;

  PWall=^TWall;
  TWall=Object(TTile)
    Destroyed:Boolean;
    Constructor Init(AX,AY:Integer;AOwner:PGame);
    Function Flamed(ADir:TDirection;AExt:Boolean):Boolean; virtual;
    Function CanWalk:Boolean; virtual;
    Procedure Handle; virtual;
    Procedure Draws; virtual;
  end;

  PSuperWall=^TSuperWall;
  TSuperWall=Object(TTile)
    Constructor Init(AX,AY:Integer;AOwner:PGame);
    Function Flamed(ADir:TDirection;AExt:Boolean):Boolean; virtual;
    Function CanWalk:Boolean; virtual;
    Procedure Draws; virtual;
  end;

  PBonus=^TBonus;
  TBonus=Object(TTile)
    Dying:Boolean;
    DyingTimer:Integer;
    Image:PSprite;
    Constructor Init(AX,AY:Integer;AOwner:PGame;AImage:PSprite);
    Function Flamed(ADir:TDirection;AExt:Boolean):Boolean; virtual;
    Procedure PlayerTakes(Taker:PPlayer); virtual;
    Procedure Draws; virtual;
    Procedure Handle; virtual;
    Function CanWalk:Boolean; virtual;
  end;

  PFlameBonus=^TFlameBonus;
  TFlameBonus=Object(TBonus)
    Constructor Init(AX,AY:Integer;AOwner:PGame);
    Procedure PlayerTakes(Taker:PPlayer); virtual;
  end;

  PBombBonus=^TBombBonus;
  TBombBonus=Object(TBonus)
    Constructor Init(AX,AY:Integer;AOwner:PGame);
    Procedure PlayerTakes(Taker:PPlayer); virtual;
  end;

  PKickBonus=^TKickBonus;
  TKickBonus=Object(TBonus)
    Constructor Init(AX,AY:Integer;AOwner:PGame);
    Procedure PlayerTakes(Taker:PPlayer); virtual;
  end;

  TFlame=Object(TObject)
    Timer:Integer;
    Dir:TDirection;
    Extremity:Boolean;
    Owner:PTile;
    NoMoreUsed:Boolean;
    Constructor Init(ADir:TDirection;AExt:Boolean;AOwner:PTile);
    Procedure Handle; virtual;
    Procedure FusionFlame(ADir:TDirection;AExt:Boolean); virtual;
    Procedure Draws(XScreen,YScreen:Integer); virtual;
    Destructor Done; virtual;
  end;

  TPlayer=Object(TObject)
    PNumber,BombCapa,BombLeft,Power,Speed,WalkSlow,PosX,PosY,DyingTimer,WalkTimer,Wins:Integer;
    Tile1,Tile2,Tile3,Tile4:TCoordTile;
    CanKick,NoMoreUsed,Dying,Walking,Action1,Action2:Boolean;
    Dir:TDirection;
    Owner:PGame;
    Anim:PBonhomme;
    Constructor Init(APosX,APosY,APower,ABombs,ASpeed,APnumber,AWins:Integer;AOwner:PGame;AAnim:PBonhomme);
    Procedure TakeOrders; virtual;
    Procedure DoSomething; virtual;
    Procedure TranspDraws; virtual;
    Destructor Done; virtual;
  end;

  TDeadPlayer=Object(TObject)
    PNumber,Wins:Integer;
    Anim:PBonhomme;
    Owner:PGame;
    Constructor Init(APNumber,AWins:Integer;AAnim:PBonhomme;AOwner:PGame);
    Destructor Done; virtual;
  end;

 TBomb=Object(TObject)
    ExplodeTimer,JumpTimer,Power,PosX,PosY:Integer;
    Tile1,Tile2,Tile3,Tile4:TCoordTile;
    PlayerOwner:Integer;
    Owner:PGame;
    Dir:TDirection;
    {Jumping,Hopping,DudBomb}Moving,OnATile,NoMoreUsed:Boolean;
    Constructor Init(ATileX,ATileY,APower:Integer;APlayerOwner:Integer;AOwner:PGame);
    Procedure MakeMove(ADir:TDirection); virtual;
    Procedure StopBomb;
    Function HandleCollisions(MoveDir:TDirection):Boolean;
    Procedure Handle; virtual;
    Procedure SuppressFromGame; virtual;
    Procedure TranspDraws; virtual;
    Procedure DrawsPlaf; virtual;
    Procedure Explode; virtual;
    Destructor Done; virtual;
  end;

  TInfoBarAction=(PlayerStatus,ShowNothing,ShrinkWarning);
  TShrinkInfo=Record
    ShrinkDelay,ShrinkPeriod,ShrinkVar,ShrinkLine,ShrinkTimer,ShrinkNbr:Integer;
    Shrinking,ShrinkMessage:Boolean;
    ShrinkDir:TDirection;
    ShrinkMode:TShrinkMode;
    ShrinkPos:TCoordTile;
  end;
  TGame=Object(TObject)
    ShrinkInfo:TShrinkInfo;
    NbrPlayers,NbrDeads:Integer;
    TotalTime:Longint;
    Players:TPlayers;
    Deads:Array[0..3] of PDeadPlayer;
    Bombs:TCollection;
    Owner:PUniverse;
    PlayGround:Array[0..TerrainSizeX-1,0..TerrainSizeY-1] of PTile;
    NewTile:PTile;
    Constructor Init(ANbrPlayer:Integer;AOwner:PUniverse);
    Procedure ReplaceTile(X,Y:Integer);
    Procedure PutSuperWall(X,Y:Integer);
    Procedure LayBomb(X,Y,APower:Integer;APlayerOwner:Integer);
    Procedure PutBonusRandom(X,Y:Integer);
    Procedure CrossedExplosion(X,Y,Power:Integer);
    Function FoundBomb(X1,X2,Y1,Y2:Integer;ExcluedDir:TDirection;var BombFound:PBomb):Boolean;
    Procedure RedrawTiles;
    Procedure ReDrawInfoBar(Action:TInfoBarAction);
    Procedure RedrawTime;
    Function IsGameEnded:Boolean; virtual;
    Procedure HandleShrink;
    Procedure DoSomething; virtual;
    Function AskForReplay:Boolean;
    Destructor Done; virtual;
  end;

  TUniverse=Object(TObject)
    Game:PGame;
    Wins:Array[0..3] of Word;
    NbrJoueurs:Byte;
    StillWantToPlay:Boolean;
    Constructor Init;
    Procedure Play; virtual;
    Destructor Done; virtual;
  end;

Function NewStr(X:Integer):string;
var S:string;
begin
  Str(X,S);
  NewStr:=S;
end;

Function Centered(Pos:Integer):Shortint;
var Dec:Integer;
begin
  Dec:=Pos mod TileSizeX;
  if (Dec=TileSizeX div 2-1) or (Dec=TileSizeX div 2) then Centered:=0
  else if Dec<TileSizeX div 2-1 then Centered:=-1
  else Centered:=+1;
end;

Procedure MainTile(PosX,PosY:Integer;var Tile:TCoordTile);
begin
  Tile.X:=PosX div TileSizeX;
  Tile.Y:=PosY div TileSizeY;
  Tile.Used:=True;
end;

Procedure TouchingTiles(PosX,PosY:Integer;var Tile1,Tile2,Tile3,Tile4:TCoordTile);
var DecX,DecY,TileX,TileY:ShortInt;
begin
  DecX:=Centered(PosX);
  DecY:=Centered(PosY);
  MainTile(PosX,PosY,Tile1);
  if DecX<>0 then begin
    Tile2.Used:=True;
    Tile2.X:=Tile1.X+DecX;
    Tile2.Y:=Tile1.Y;
  end else Tile2.Used:=False;
  if DecY<>0 then begin
    Tile3.Used:=True;
    Tile3.X:=Tile1.X;
    Tile3.Y:=Tile1.Y+DecY;
  end else Tile3.Used:=False;
  if (DecY<>0) and (DecX<>0) then begin
    Tile4.Used:=True;
    Tile4.X:=Tile1.X+DecX;
    Tile4.Y:=Tile1.Y+DecY;
  end else Tile4.Used:=False;
end;  {Tile2 est toujours la case plac‚e sur la mˆme ligne que la case principale }
      {Tile3 est toujours la case plac‚e sur la mˆme colonne que la case principale }

Constructor TTile.Init(AX,AY:Integer;AOwner:PGame);
begin
  Bomb:=nil;
  Owner:=AOwner;
  X:=AX;
  Y:=AY;
  Redraw:=True;
end;

Procedure TTile.Draws;
begin
end;

Procedure TTile.Handle;
begin
end;

Function TTile.CanWalk:Boolean;
begin
  CanWalk:=True;
end;

Function TTile.Flamed(ADir:TDirection;AExt:Boolean):Boolean;
begin
  Flamed:=True;
end;

Function TTile.PlayersOnTile(var Resul:TPlayers):Integer;
var i,Resultat:Integer;Tile:TCoordTile;
begin
  Resultat:=0;
  for i:=0 to Owner^.NbrPlayers-1 do begin
    MainTile(Owner^.Players[i]^.PosX,Owner^.Players[i]^.PosY,Tile);
    if (Tile.X=X) and (Tile.Y=Y) then begin
      Resul[Resultat]:=Owner^.Players[i];
      Inc(Resultat);
    end;
  end;
  PlayersOnTile:=Resultat;
end;

Function TTile.PlayersTouchingTile(var Resul:TPlayers):Integer;
var i,Resultat,AX,AY,BX,BY:Integer;
begin
  Resultat:=0;
  for i:=0 to Owner^.NbrPlayers-1 do begin
    AX:=Owner^.Players[i]^.PosX;
    AY:=Owner^.Players[i]^.PosY;
    BX:=X*TileSizeX+TileSizeX div 2;
    BY:=Y*TileSizeY+TileSizeY div 2;
    if (Abs(BX-AX)<=16) and (Abs(BY-AY)<=16) then begin
      Resul[Resultat]:=Owner^.Players[i];
      Inc(Resultat);
    end;
  end;
  PlayersTouchingTile:=Resultat;
end;

Destructor TTile.Done;
begin
end;

Constructor TBonus.Init(AX,AY:Integer;AOwner:PGame;AImage:Psprite);
begin
  TTile.Init(AX,AY,AOwner);
  Image:=AImage;
  TileType:=Bonus;
  CanLayBomb:=True;
  State:=Safe;
  Dying:=False;
end;

Function TBonus.Flamed(ADir:TDirection;AExt:Boolean):Boolean;
begin
  Dying:=True;
  DyingTimer:=60;
  Flamed:=False;
end;

Procedure TBonus.Draws;
var XScreen,YScreen:Integer;
begin
  XScreen:=X*TileSizeX+TerrainCornerX;
  YScreen:=Y*TileSizeY+TerrainCornerY;
  if not Dying then Image^.DrawsPlaf(XScreen,YScreen)
  else BonusExplode^.DrawsPlaf(XScreen,YScreen,60-DyingTimer);
end;

Procedure TBonus.PlayerTakes(Taker:PPlayer);
begin
  Owner^.NewTile:=New(PNothing,Init(X,Y,Owner));
  Owner^.ReplaceTile(X,Y);
end;

Procedure TBonus.Handle;
begin
  if Dying then begin
    if (DyingTimer mod 20)=0 then Redraw:=True;
    Dec(DyingTimer);
    if DyingTimer=0 then begin
      Owner^.NewTile:=New(PNothing,Init(X,Y,Owner));
      Owner^.ReplaceTile(X,Y);
{  cette derniŠre instruction me parait douteuse, car l'objet TBonus demande
… l'objet Game d'ˆtre d‚truit et remplac‚ par un autre objet d‚rivant de TTile,
ce qui ‚quivaut presque … un suicide d'objet. (je dis presque, car l'objet
ne se d‚truit pas lui mˆme, il demande … quelqu'un d'autre qu'on le d‚truise) }
    end;
  end;
end;

Function TBonus.CanWalk:Boolean;
begin
  CanWalk:=True;
end;

Constructor TFlameBonus.Init(AX,AY:Integer;AOwner:PGame);
begin
  TBonus.Init(AX,AY,AOwner,BonusImage.Flamme);
end;

Procedure TFlameBonus.PlayerTakes(Taker:PPlayer);
begin
  TBonus.PlayerTakes(Taker);
  Inc(Taker^.Power);
end;

Constructor TBombBonus.Init(AX,AY:Integer;AOwner:PGame);
begin
  TBonus.Init(AX,AY,AOwner,BonusImage.Bombe);
end;

Procedure TBombBonus.PlayerTakes(Taker:PPlayer);
begin
  TBonus.PlayerTakes(Taker);
  Inc(Taker^.BombCapa);
  Inc(Taker^.BombLeft);
end;

Constructor TKickBonus.Init(AX,AY:Integer;AOwner:PGame);
begin
  TBonus.Init(AX,AY,AOwner,BonusImage.Kick);
end;

Procedure TKickBonus.PlayerTakes(Taker:PPlayer);
begin
  TBonus.PlayerTakes(Taker);
  Taker^.CanKick:=True;
end;

Constructor TNothing.Init(AX,AY:Integer;AOwner:PGame);
begin
  TTile.Init(AX,AY,AOwner);
  TileType:=Nothing;
  CanLayBomb:=True;
  Flame:=nil;
  State:=Safe;
end;

Procedure TNothing.Draws;
var XScreen,YScreen:Integer;
begin
  if (Bomb<>Nil) and Bomb^.OnATile then Bomb^.DrawsPlaf else begin
    XScreen:=X*TileSizeX+TerrainCornerX;
    YScreen:=Y*TileSizeY+TerrainCornerY;
    if Flame<>nil then Flame^.Draws(XScreen,YScreen) else
    FilledSquare(XScreen,YScreen,XScreen+TileSizeX-1,YScreen+TileSizeY-1,2);
  end;
end;

Function TNothing.Flamed(ADir:TDirection;AExt:Boolean):Boolean;
begin
  if Bomb<>nil then Bomb^.Explode;
  Flamed:=True;
  if Flame=nil then begin
    Flame:=New(PFlame,Init(ADir,AExt,@Self));
    State:=Dangerous;
  end else Flame^.FusionFlame(ADir,AExt);
end;

Procedure TNothing.Handle;
begin
  if Flame<>Nil then begin
    if not(Flame^.NoMoreUsed) then Flame^.Handle;
    if Flame^.NoMoreUsed then begin
      Dispose(Flame,Done);
      Flame:=Nil;
      State:=Safe;
    end;
  end;
end;

Function TNothing.CanWalk:Boolean;
begin
  CanWalk:=Bomb=nil;
end;

Destructor TNothing.Done;
begin
  if Flame<>Nil then Dispose(Flame,Done);
end;

Constructor TWall.Init(AX,AY:Integer;AOwner:PGame);
begin
  TTile.Init(AX,AY,AOwner);
  TileType:=Wall;
  CanLayBomb:=False;
  State:=Safe;
  Destroyed:=False;
end;

Function TWall.CanWalk:Boolean;
begin
  CanWalk:=False;
end;

Function TWall.Flamed(ADir:TDirection;AExt:Boolean):Boolean;
begin
  Flamed:=False;
  Destroyed:=True;
end;

Procedure TWall.Handle;
begin
  if Destroyed then Owner^.PutBonusRandom(X,Y);
end;

Procedure TWall.Draws;
var XScreen,YScreen:Integer;
begin
  XScreen:=X*TileSizeX+TerrainCornerX;
  YScreen:=Y*TileSizeY+TerrainCornerY;
  FilledSquare(XScreen,YScreen,XScreen+TileSizeX-1,YScreen+TileSizeY-1,8);
end;

Constructor TSuperWall.Init(AX,AY:Integer;AOwner:PGame);
begin
  TTile.Init(AX,AY,AOwner);
  TileType:=SuperWall;
  CanLayBomb:=False;
  State:=SuperDangerous;
end;

Function TSuperWall.CanWalk:Boolean;
begin
  CanWalk:=False;
end;

Function TSuperWall.Flamed(ADir:TDirection;AExt:Boolean):Boolean;
begin
  Flamed:=False;
end;

Procedure TSuperWall.Draws;
var XScreen,YScreen:Integer;
begin
  XScreen:=X*TileSizeX+TerrainCornerX;
  YScreen:=Y*TileSizeY+TerrainCornerY;
  FilledSquare(XScreen,YScreen,XScreen+TileSizeX-1,YScreen+TileSizeY-1,7);
end;

Constructor TFlame.Init(ADir:TDirection;AExt:Boolean;AOwner:PTile);
begin
  Dir:=ADir;
  Extremity:=AExt;
  Owner:=AOwner;
  Timer:=0;
  NoMoreUsed:=False;
end;

Procedure TFlame.Draws(XScreen,YScreen:Integer);
begin
  if Extremity and (Dir<>None) then
  FlamImg^.Extremi[Ord(Dir)]^.DrawsPlaf(XScreen,YScreen,Timer)
  else if not(Extremity) and (Dir in [Left,Right]) then
  FlamImg^.Hori^.DrawsPlaf(XScreen,YScreen,Timer)
  else if not(Extremity) and (Dir in [Up,Down]) then
  FlamImg^.Verti^.DrawsPlaf(XScreen,YScreen,Timer)
  else if Dir=None then FlamImg^.Center^.DrawsPlaf(XScreen,YScreen,Timer);
end;

Procedure TFlame.FusionFlame(ADir:TDirection;AExt:Boolean);

  Procedure FusionedFire(Adir,BDir:TDirection;var ResuDir:TDirection;AExt,BExt:Boolean;var ResuExt:Boolean);
  begin
    if (ADir=None) or (BDir=None) then begin
      ResuDir:=None;
      ResuExt:=False;
    end else if ( (ADir in [Left,Right]) and (BDir in [Up,Down]) ) or
                ( (BDir in [Left,Right]) and (ADir in [Up,Down]) ) then begin
      ResuDir:=None;
      ResuExt:=False;
    end else if not(AExt) or not(BExt) then begin
      ResuDir:=ADir;
      ResuExt:=False;
    end else if ADir=BDir then begin
      ResuDir:=ADir;
      ResuExt:=True;
    end else begin
      ResuDir:=ADir;
      ResuExt:=False;
    end;
  end;

begin
  FusionedFire(Dir,ADir,Dir,Extremity,AExt,Extremity);
  Timer:=0;
end;

Procedure TFlame.Handle;
begin
  if Timer mod 10=0 then Owner^.Redraw:=True;
  if Owner^.Bomb<>Nil then Owner^.Bomb^.Explode;
  if Timer=50 then NoMoreUsed:=True;
  Inc(Timer);
end;

Destructor TFlame.Done;
begin
end;

Constructor TPlayer.Init(APosX,APosY,APower,ABombs,ASpeed,APnumber,AWins:Integer;AOwner:PGame;AAnim:PBonhomme);
begin
  PNumber:=APNumber;
  PosX:=APosX;
  PosY:=APosY;
  TouchingTiles(PosX,PosY,Tile1,Tile2,Tile3,Tile4);
  Power:=APower;
  BombCapa:=ABombs;
  BombLeft:=BombCapa;
  Speed:=ASpeed;
  Dir:=TDirection(Random(4));
  WalkSlow:=10-Speed;
  Owner:=AOwner;
  Dying:=False;
  DyingTimer:=0;
  NoMoreUsed:=False;
  Anim:=AAnim;
  Wins:=AWins;
  Cankick:=False;
end;

Procedure TPlayer.TakeOrders;

  Procedure TakeOrdersFromKeyboard(KGauche,KDroite,KHaut,KBas,KAc1,KAc2:Boolean);
  begin
    if (KGauche or KHaut or KDroite or KBas) and ( (KGauche Xor KDroite) or (KHaut Xor KBas) ) then begin
      Walking:=True;
      if KGauche then Dir:=Left;
      if KHaut then Dir:=Up;
      if KDroite then Dir:=Right;
      if KBas then Dir:=Down;
    end;
    Action1:=KAc1;
    Action2:=KAc2;
  end;

begin
  Walking:=False;
  Case PNumber of
    0:TakeOrdersFromKeyBoard(K_Q,K_D,K_Z,K_S,K_Sh1,K_Petit2);
    1:TakeOrdersFromKeyBoard(K_4,K_6,K_8,K_5,K_PgDown,K_Fin);
    2:TakeOrdersFromKeyBoard(K_Left,K_Right,K_Up,K_Down,K_Back,K_Egal);
    3:TakeOrdersFromKeyBoard(K_K,K_M,K_O,K_L,K_Sh7,K_Sh6);
  end;
end;

Procedure TPlayer.DoSomething;
var CanMove,Zip:Boolean;ZipDir,RealMoveDir:TDirection;DecaHori,DecaVerti:ShortInt;
i,j:Integer;BombToKick:PBomb;
begin
  TouchingTiles(PosX,PosY,Tile1,Tile2,Tile3,Tile4);
  for i:=Tile1.X-1 to Tile1.X+1 do for j:=Tile1.Y-1 to Tile1.Y+1 do
   if (i>=0) and (i<=TerrainSizeX-1) and (j>=0) and (j<=TerrainSizeY-1) then
   Owner^.PlayGround[i,j]^.Redraw:=True;
  if Owner^.PlayGround[Tile1.X,Tile1.Y]^.State=Dangerous then Dying:=True;
  if Owner^.PlayGround[Tile1.X,Tile1.Y]^.State=SuperDangerous then Dying:=True;
  if Tile2.Used then if Owner^.PlayGround[Tile2.X,Tile2.Y]^.State=SuperDangerous then Dying:=True;
  if Tile3.Used then if Owner^.PlayGround[Tile3.X,Tile3.Y]^.State=SuperDangerous then Dying:=True;
  if Tile4.Used then if Owner^.PlayGround[Tile4.X,Tile4.Y]^.State=SuperDangerous then Dying:=True;
  if Dying then begin
    Inc(DyingTimer);
    if DyingTimer=88 then NoMoreUsed:=True;
  end else begin
    TakeOrders;
    if not(Walking) or (WalkTimer=29) then WalkTimer:=0 else Inc(WalkTimer);
    {gestion des bonus que le joueur il prend}
    if Owner^.PlayGround[Tile1.X,Tile1.Y]^.TileType=Bonus then PBonus(Owner^.PlayGround[Tile1.X,Tile1.Y])^.PlayerTakes(@Self);
    if Tile2.Used then if Owner^.PlayGround[Tile2.X,Tile2.Y]^.TileType=Bonus then
    PBonus(Owner^.PlayGround[Tile2.X,Tile2.Y])^.PlayerTakes(@Self);
    if Tile3.Used then if Owner^.PlayGround[Tile3.X,Tile3.Y]^.TileType=Bonus then
    PBonus(Owner^.PlayGround[Tile3.X,Tile3.Y])^.PlayerTakes(@Self);
    if Tile4.Used then if Owner^.PlayGround[Tile4.X,Tile4.Y]^.TileType=Bonus then
    PBonus(Owner^.PlayGround[Tile4.X,Tile4.Y])^.PlayerTakes(@Self);
    {gestion de la pose de bombes}
    if Action1 then
    if (BombLeft>0) and (Owner^.PlayGround[Tile1.X,Tile1.Y]^.Bomb=Nil)
    and Owner^.PlayGround[Tile1.X,Tile1.Y]^.CanLayBomb then begin
      Owner^.LayBomb(Tile1.X,Tile1.Y,Power,PNumber);
      Dec(BombLeft);
    end;
    {gestion du mouvement}
    CanMove:=False;
    Zip:=False;
    if Walking and ((Dir=Left) or (Dir=Right)) then
    if Centered(PosX)<>0 then CanMove:=True else begin
      if ((Dir=Left) and (Tile1.X>0) and Owner^.Playground[Tile1.X-1,Tile1.Y]^.CanWalk)
      or ((Dir=Right) and (Tile1.X<TerrainSizeX-1) and Owner^.Playground[Tile1.X+1,Tile1.Y]^.CanWalk)
      then begin
        DecaVerti:=Centered(PosY);
        if DecaVerti=0 then CanMove:=True else begin
          if Dir=Left then DecaHori:=-1 else DecaHori:=+1;
          if not(Owner^.Playground[Tile1.X+DecaHori,Tile1.Y+DecaVerti]^.CanWalk) then begin
            Zip:=True;
            if DecaVerti=+1 then ZipDir:=Up else ZipDir:=Down;
          end else CanMove:=True;
        end;
      end;
      if CanKick then begin
        if (Dir=Left) and (Tile1.X>0) and (Owner^.Playground[Tile1.X-1,Tile1.Y]^.Bomb<>Nil) then begin
          BombToKick:=Owner^.Playground[Tile1.X-1,Tile1.Y]^.Bomb;
          if BombToKick^.OnATile and BombToKick^.HandleCollisions(Left) then
          BombToKick^.MakeMove(Left);
        end;
        if (Dir=Right) and (Tile1.X<TerrainSizeX-1) and (Owner^.Playground[Tile1.X+1,Tile1.Y]^.Bomb<>Nil) then begin
          BombToKick:=Owner^.Playground[Tile1.X+1,Tile1.Y]^.Bomb;
          if BombToKick^.OnATile and BombToKick^.HandleCollisions(Right) then
          BombToKick^.MakeMove(Right);
        end;
      end;
    end;
    if Walking and ((Dir=Up) or (Dir=Down)) then
    if Centered(PosY)<>0 then CanMove:=True else begin
      if ((Dir=Up) and (Tile1.Y>0) and Owner^.Playground[Tile1.X,Tile1.Y-1]^.CanWalk)
      or ((Dir=Down) and (Tile1.Y<TerrainSizeY-1) and Owner^.Playground[Tile1.X,Tile1.Y+1]^.CanWalk)
      then begin
        DecaHori:=Centered(PosX);
        if DecaHori=0 then CanMove:=True else begin
          if Dir=Up then DecaVerti:=-1 else DecaVerti:=+1;
          if not(Owner^.Playground[Tile1.X+DecaHori,Tile1.Y+DecaVerti]^.CanWalk) then begin
            Zip:=True;
            if DecaHori=+1 then ZipDir:=Left else ZipDir:=Right;
          end else CanMove:=True;
        end;
      end;
      if CanKick then begin
        if (Dir=Up) and (Tile1.Y>0) and (Owner^.Playground[Tile1.X,Tile1.Y-1]^.Bomb<>Nil) then begin
          BombToKick:=Owner^.PlayGround[Tile1.X,Tile1.Y-1]^.Bomb;
          if BombToKick^.OnATile and BombToKick^.HandleCollisions(Up) then
          BombToKick^.MakeMove(Up);
        end;
        if (Dir=Down) and (Tile1.Y<TerrainSizeY-1) and (Owner^.Playground[Tile1.X,Tile1.Y+1]^.Bomb<>Nil) then begin
          BombToKick:=Owner^.PlayGround[Tile1.X,Tile1.Y+1]^.Bomb;
          if BombToKick^.OnATile and BombToKick^.HandleCollisions(Down) then
          BombToKick^.MakeMove(Down);
        end;
      end;
    end;
    if CanMove or Zip then begin
      if CanMove then RealMoveDir:=Dir else RealMoveDir:=ZipDir;
      Dec(WalkSLow,Speed);
      if WalkSlow<0 then begin
        Inc(WalkSlow,10);
        if RealMoveDir=Right then Inc(PosX);
        if RealMoveDir=Left then Dec(PosX);
        if RealMoveDir=Up then Dec(PosY);
        if RealMoveDir=Down then Inc(PosY);
      end;
    end;
  end;
end;

Procedure TPlayer.TranspDraws;
begin
  if Dying then Anim^.DieAnim^.TranspDraws(PosX+TerrainCornerX,PosY+TerrainCornerY,DyingTimer)
  else if Dir<>None then Anim^.WalkAnims[Ord(Dir)]^.TranspDraws(PosX+TerrainCornerX,PosY+TerrainCornerY,WalkTimer);
end;

Destructor TPlayer.Done;
begin
end;

Constructor TDeadPlayer.Init(APNumber,AWins:Integer;AAnim:PBonhomme;AOwner:PGame);
begin
  PNumber:=APNumber;
  Wins:=AWins;
  Anim:=AAnim;
  Owner:=AOwner;
end;

Destructor TDeadPlayer.Done;
begin
end;

Constructor TBomb.Init(ATileX,ATileY,APower:Integer;APlayerOwner:Integer;AOwner:PGame);
begin
  Power:=APower;
  Dir:=None;
  PlayerOwner:=APlayerOwner;
  Owner:=AOwner;
  Tile1.Used:=True;
  Tile1.X:=ATileX;
  Tile1.Y:=ATileY;
  PosX:=Tile1.X*TileSizeX+TileSizeX div 2;
  PosY:=Tile1.Y*TileSizeY+TileSizeY div 2;
  Tile2.Used:=False;
  Tile3.Used:=False;
  Tile4.Used:=False;
  ExplodeTimer:=150;
  NoMoreUsed:=False;
  OnATile:=True;
  Moving:=False;
end;

Procedure TBomb.TranspDraws;
var XScreen,YScreen:Integer;
begin
  XScreen:=PosX+TerrainCornerX;
  YScreen:=PosY+TerrainCornerY;
  BombsImg^.Normal^.TranspDraws(XScreen,YScreen,ExplodeTimer);
end;

Procedure TBomb.DrawsPlaf;
var XScreen,YScreen:Integer;
begin
  XScreen:=PosX+TerrainCornerX;
  YScreen:=PosY+TerrainCornerY;
  BombsImg^.Normal^.DrawsPlaf(XScreen,YScreen,ExplodeTimer);
end;

Procedure TBomb.MakeMove(ADir:TDirection);
begin
  OnATile:=False;
  Moving:=True;
  Dir:=ADir;
  Owner^.PlayGround[Tile1.X,Tile1.Y]^.Bomb:=nil;
end;

Function TGame.FoundBomb(X1,X2,Y1,Y2:Integer;ExcluedDir:TDirection;var BombFound:PBomb):Boolean;
var i:Integer;Resul:Boolean;
begin
  Resul:=False;
  BombFound:=Nil;
  for i:=0 to Bombs.Count-1 do With PBomb(Bombs.At(i))^ do
  if not(Resul) and not(OnATile) and Moving and (PosX<X2) and (PosX>X1) and (PosY<Y2) and (PosY>Y1)
  then begin
    Resul:=True;
    BombFound:=PBomb(Bombs.At(i));
  end;
  FoundBomb:=Resul;
end;

Function TBomb.HandleCollisions(MoveDir:TDirection):Boolean;
{valeur renvoy‚ = false <=> il y a eu une collision
 valeur renvoy‚ = true <=> il n'y a pas eu de collision}
var Resultat:Boolean;i,XX,YY:Integer;OtherBomb:PBomb;PlayerNewPos:TCoordTile;
begin
  Resultat:=True;
  if ((MoveDir in [Left,Right]) and (Centered(PosX)=0)) or
  ((MoveDir in [Up,Down]) and (Centered(PosY)=0)) then begin
    Case MoveDir of
      Left:Resultat:=(Tile1.X>0) and Owner^.PlayGround[Tile1.X-1,Tile1.Y]^.CanWalk;
      Right:Resultat:=(Tile1.X<TerrainSizeX-1) and Owner^.PlayGround[Tile1.X+1,Tile1.Y]^.CanWalk;
      Up:Resultat:=(Tile1.Y>0) and Owner^.PlayGround[Tile1.X,Tile1.Y-1]^.CanWalk;
      Down:Resultat:=(Tile1.Y<TerrainSizeY-1) and Owner^.PlayGround[Tile1.X,Tile1.Y+1]^.CanWalk;
    end;
  end;
  if Resultat then begin
    Case MoveDir of
      Left:begin XX:=PosX-16; YY:=PosY; end;
      Right:begin XX:=PosX+16; YY:=PosY; end;
      Up:begin XX:=PosX; YY:=PosY-16; end;
      Down:begin XX:=PosX; YY:=PosY+16; end;
    end;
    for i:=0 to Owner^.NbrPlayers-1 do
    if (Abs(Owner^.Players[i]^.PosX-XX)<2) and (Abs(Owner^.Players[i]^.PosY-YY)<2) then
    begin
      Resultat:=False;
      Case MoveDir of
        Left:PlayerNewPos.X:=Self.Tile1.X*TileSizeX+TileSizeX div 2 -TileSizeX-1;
        Right:PlayerNewPos.X:=Self.Tile1.X*TileSizeX+TileSizeX div 2 +TileSizeX+1;
        Up,Down:PlayerNewPos.X:=Self.Tile1.X*TileSizeX+TileSizeX div 2;
      end;
      Case MoveDir of
        Left,Right:PlayerNewPos.Y:=Self.Tile1.Y*TileSizeY+TileSizeY div 2;
        Up:PlayerNewPos.Y:=Self.Tile1.Y*TileSizeY+TileSizeY div 2 -TileSizeY-1;
        Down:PlayerNewPos.Y:=Self.Tile1.Y*TileSizeY+TileSizeY div 2 +TileSizeY+1;
      end;
      if ( (Dir=Left) and (PlayerNewPos.X<Owner^.Players[i]^.PosX) ) or
      ( (Dir=Right) and (PlayerNewPos.X>Owner^.Players[i]^.PosX) ) or
      ( (Dir=Up) and (PlayerNewPos.Y<Owner^.Players[i]^.PosY) ) or
      ( (Dir=Down) and (PlayerNewPos.Y>Owner^.Players[i]^.PosY) ) then begin
        Owner^.Players[i]^.PosY:=PlayerNewPos.Y;
        Owner^.Players[i]^.PosX:=PlayerNewPos.X;
      end;
    end;
    if Owner^.FoundBomb(XX-1,XX+1,YY-1,YY+1,MoveDir,OtherBomb) then begin
      Resultat:=False;
      OtherBomb^.StopBomb;
    end;
  end;
  HandleCollisions:=Resultat;
end;

Procedure TBomb.StopBomb;
begin
  PosX:=Tile1.X*TileSizeX+TileSizeX div 2;
  PosY:=Tile1.Y*TilesizeY+TileSizeY div 2;
  if Dir in [Up,Down] then begin
    Owner^.PlayGround[Tile1.X,Tile1.Y-1]^.Redraw:=True;
    Owner^.PlayGround[Tile1.X,Tile1.Y+1]^.Redraw:=True;
  end;
  if Dir in [Left,Right] then begin
    Owner^.PlayGround[Tile1.X-1,Tile1.Y]^.Redraw:=True;
    Owner^.PlayGround[Tile1.X+1,Tile1.Y]^.Redraw:=True;
  end;
  OnATile:=True;
  Moving:=False;
  Owner^.PlayGround[Tile1.X,Tile1.Y]^.Bomb:=@Self;
end;

Procedure TBomb.Handle;
begin
  if ExplodeTimer mod 10=0 then if OnATile then Owner^.PlayGround[Tile1.X,Tile1.Y]^.Redraw:=True;
  Dec(ExplodeTimer);
  if ExplodeTimer<=0 then Explode;
  if not(OnaTile) and Moving then begin
    case Dir of
      Left:Dec(PosX);
      Right:Inc(PosX);
      Up:Dec(PosY);
      Down:Inc(PosY);
    end;
    TouchingTiles(PosX,PosY,Tile1,Tile2,Tile3,Tile4);
    if Owner^.PlayGround[Tile1.X,Tile1.Y]^.TileType=Bonus then begin
      Owner^.NewTile:=New(PNothing,Init(Tile1.X,Tile1.Y,Owner));
      Owner^.ReplaceTile(Tile1.X,Tile1.Y);
    end;
    if (Owner^.PlayGround[Tile1.X,Tile1.Y]^.TileType=Nothing) and
    (PNothing(Owner^.PlayGround[Tile1.X,Tile1.Y])^.Flame<>Nil) then Explode else begin
      Owner^.PlayGround[Tile1.X,Tile1.Y]^.Redraw:=True;
      if Dir in [Up,Down] then begin
        Owner^.PlayGround[Tile1.X,Tile1.Y-1]^.Redraw:=True;
        Owner^.PlayGround[Tile1.X,Tile1.Y+1]^.Redraw:=True;
      end;
      if Dir in [Left,Right] then begin
        Owner^.PlayGround[Tile1.X-1,Tile1.Y]^.Redraw:=True;
        Owner^.PlayGround[Tile1.X+1,Tile1.Y]^.Redraw:=True;
      end;
      if not(HandleCollisions(Dir)) then StopBomb;
    end;
  end;
end;

Procedure TBomb.SuppressFromGame;
var i:Integer;
begin
  NoMoreUsed:=True;
  if OnATile then begin
    Owner^.PlayGround[Tile1.X,Tile1.Y]^.Bomb:=Nil;
    Owner^.PlayGround[Tile1.X,Tile1.Y]^.Redraw:=True;
  end;
  for i:=0 to Owner^.NbrPlayers-1 do if Owner^.Players[i]^.PNumber=PlayerOwner
  then Inc(Owner^.Players[i]^.BombLeft);
end;

Procedure TBomb.Explode;
var i:Integer;
begin
  SuppressFromGame;
  Owner^.CrossedExplosion(Tile1.X,Tile1.Y,Power);
end;

Destructor TBomb.Done;
begin
end;

Constructor TGame.Init(ANbrPlayer:Integer;AOwner:PUniverse);
var i,j:Byte;

  Function GiveAnimBonhomme(i:Byte):PBonhomme;
  begin
    Case i of
      0:GiveAnimBonhomme:=RedBonhomme;
      1:GiveAnimBonhomme:=YellowBonhomme;
      2:GiveAnimBonhomme:=GreenBonhomme;
      3:GiveAnimBonhomme:=BlueBonhomme;
      else GiveAnimBonhomme:=nil;
    end;
  end;

  Procedure PutNothing(X,Y:Integer);
  begin
    NewTile:=New(PNothing,Init(X,Y,@Self));
    ReplaceTile(X,Y);
  end;

begin
  Owner:=AOwner;
  NbrPlayers:=ANbrPlayer;
  for i:=0 to TerrainSizeX-1 do for j:=0 to TerrainSizeY-1 do
  if Odd(i) and Odd(j) then PlayGround[i,j]:=New(PSuperWall,Init(i,j,@Self)) else
  if Random(100)>=Conf.WallProba then PlayGround[i,j]:=New(PNothing,Init(i,j,@Self))
  else PlayGround[i,j]:=New(PWall,Init(i,j,@Self));
  for i:=0 to 3 do Deads[i]:=nil;
  NbrDeads:=0;
  for i:=0 to 3 do if NbrPlayers>i then begin
    New(Players[i],Init(Conf.PlayerStartsX[i]*16+8,Conf.PlayerStartsY[i]*16+8,
    Conf.Power,Conf.Bombs,10,i,Owner^.Wins[i],@Self,GiveAnimBonhomme(Conf.PlayerColors[i])));
    if PlayGround[Conf.PlayerStartsX[i],Conf.PlayerStartsY[i]]^.TileType=Wall
    then PutNothing(Conf.PlayerStartsX[i],Conf.PlayerStartsY[i]);
    if i in [0,2] then if PlayGround[Conf.PlayerStartsX[i]+1,Conf.PlayerStartsY[i]]^.TileType=Wall
    then PutNothing(Conf.PlayerStartsX[i]+1,Conf.PlayerStartsY[i]);
    if i in [1,3] then if PlayGround[Conf.PlayerStartsX[i]-1,Conf.PlayerStartsY[i]]^.TileType=Wall
    then PutNothing(Conf.PlayerStartsX[i]-1,Conf.PlayerStartsY[i]);
    if i in [0,1] then if PlayGround[Conf.PlayerStartsX[i],Conf.PlayerStartsY[i]+1]^.TileType=Wall
    then PutNothing(Conf.PlayerStartsX[i],Conf.PlayerStartsY[i]+1);
    if i in [2,3] then if PlayGround[Conf.PlayerStartsX[i],Conf.PlayerStartsY[i]-1]^.TileType=Wall
    then PutNothing(Conf.PlayerStartsX[i],Conf.PlayerStartsY[i]-1);
  end else Players[i]:=nil;
{  if NbrPlayers>0 then New(Players[0],Init(16*3+8,16*2+8,Conf.Power,Conf.Bombs,10,0,Owner^.Wins[0],@Self,GiveAnimBonhomme(0)))
  else Players[0]:=nil;
  if NbrPlayers>1 then New(Players[1],Init(16*5+8,16*6+8,Conf.Power,Conf.Bombs,10,1,Owner^.Wins[1],@Self,GiveAnimBonhomme(1)))
  else Players[1]:=nil;
  if NbrPlayers>2 then New(Players[2],Init(16*1+8,16*10+8,Conf.Power,Conf.Bombs,10,2,Owner^.Wins[2],@Self,GiveAnimBonhomme(2)))
  else Players[2]:=nil;
  if NbrPlayers>3 then New(Players[3],Init(16*7+8,16*2+8,Conf.Power,Conf.Bombs,10,3,Owner^.Wins[3],@Self,GiveAnimBonhomme(3)))
  else Players[3]:=nil;}
  Bombs.Init(15,2);
  for i:=0 to TerrainSizeX-1 do for j:=0 to TerrainSizeY-1 do PlayGround[i,j]^.Redraw:=True;
  With ShrinkInfo do begin
    ShrinkTimer:=0;
    Shrinking:=False;
    ShrinkMessage:=False;
    ShrinkNbr:=Conf.AShrinkNbr;
    ShrinkMode:=Conf.AShrinkMode;
    ShrinkDelay:=Conf.AShrinkDelay;
    ShrinkPeriod:=Conf.AShrinkPeriod;
  end;
  TotalTime:=0;
  RedrawTiles;
  RedrawInfoBar(PlayerStatus);
  RedrawTime;
  AfficheAll;
end;

Procedure TGame.ReplaceTile(X,Y:Integer);
var Old:PBomb;
begin
  Old:=PlayGround[X,Y]^.Bomb;
  Dispose(PlayGround[X,Y],Done);
  PlayGround[X,Y]:=NewTile;
  PlayGround[X,Y]^.Bomb:=Old;
  PlayGround[X,Y]^.Redraw:=True;
end;

Procedure TGame.PutSuperWall(X,Y:Integer);
begin
  if PlayGround[X,Y]^.Bomb<>Nil then PlayGround[X,Y]^.Bomb^.SuppressFromGame;
  NewTile:=New(PSuperWall,Init(X,Y,@Self));
  ReplaceTile(X,Y);
end;

Procedure TGame.LayBomb(X,Y,APower:Integer;APlayerOwner:Integer);
var NewBomb:PBomb;
begin
  NewBomb:=New(PBomb,Init(X,Y,APower,APlayerOwner,@Self));
  Bombs.Insert(NewBomb);
  PlayGround[X,Y]^.Bomb:=NewBomb;
end;

Procedure TGame.PutBonusRandom(X,Y:Integer);
var NbrRandom,Choice:Integer;
begin
  NbrRandom:=Random(100);
  Choice:=0;
  While (Choice<NbrBonus) and (NbrRandom>=Conf.CumuProba[Choice]) do Inc(Choice);
  Case BonusType(Choice) of
    Flamme:NewTile:=New(PFlameBonus,Init(X,Y,@Self));
    Bombe:NewTile:=New(PBombBonus,Init(X,Y,@Self));
    NoBonus:NewTile:=New(PNothing,Init(X,Y,@Self));
    Kick:NewTile:=New(PKickBonus,Init(X,Y,@Self));
    else NewTile:=New(PNothing,Init(X,Y,@Self));
  end;
  ReplaceTile(X,Y);
end;

Procedure TGame.CrossedExplosion(X,Y,Power:Integer);
var i:Integer;
begin
  if Power>=0 then PlayGround[X,Y]^.Flamed(None,False);
  if Power>0 then begin
    i:=1;
    While (i<=Power-1) and (X+i<=TerrainSizeX-1) and PlayGround[X+i,Y]^.Flamed(Right,False) do Inc(i);
    if (Power>0) and (i>Power-1) and (X+i<=TerrainSizeX-1) then  PlayGround[X+i,Y]^.Flamed(Right,True);
    i:=1;
    While (i<=Power-1) and (Y+i<=TerrainSizeY-1) and PlayGround[X,Y+i]^.Flamed(Down,False) do Inc(i);
    if (Power>0) and (Y+i<=TerrainSizeY-1) and (i>Power-1) then PlayGround[X,Y+i]^.Flamed(Down,True);
    i:=1;
    While (i<=Power-1) and (X-i>=0) and PlayGround[X-i,Y]^.Flamed(Left,False) do Inc(i);
    if (Power>0) and (X-i>=0) and (i>Power-1) then PlayGround[X-i,Y]^.Flamed(Left,True);
    i:=1;
    While (i<=Power-1) and (Y-i>=0) and PlayGround[X,Y-i]^.Flamed(Up,False) do Inc(i);
    if (Power>0) and (Y-i>=0) and (i>Power-1) then PlayGround[X,Y-i]^.Flamed(Up,True);
  end;
end;

Procedure TGame.RedrawInfoBar(Action:TInfoBarAction);
var i,j:Integer;P:PPlayer;D:PDeadPlayer;
begin
  FilledSquare(0,0,249,TerrainCornerY-1,0);
  Case Action of
    PlayerStatus:begin
      i:=0;
      Repeat
        j:=0;
        While (j<NbrPlayers) and (Players[j]^.PNumber<>i) do Inc(j);
        if j<NbrPlayers then begin
          Players[j]^.Anim^.WalkAnims[2]^.TranspDraws(i*50+6,11,0);
          OutText(50*i+16,10,NewStr(Players[j]^.Wins));
        end else begin
          j:=0;
          While (j<NbrDeads) and (Deads[j]^.PNumber<>i) do Inc(j);
          if j<NbrDeads then begin
            Deads[j]^.Anim^.Skull^.DrawsPlaf(i*50,3);
            OutText(50*i+16,10,NewStr(Deads[j]^.Wins));
          end;
        end;
        Inc(i);
      Until i=Owner^.NbrJoueurs;
    end;
    ShowNothing:;
    ShrinkWarning:AfficheArgh(50,0);
  end;
  Draw(0,0,249,TerrainCornerY-1);
  Affiche;
end;

Procedure TGame.RedrawTime;
var Seconds:LongInt;
begin
  Seconds:=(TotalTime shl 16) div 1193180;
  FilledSquare(250,5,300,15,0);
  OutText(250,5,NewStr(Seconds div 60)+' : '+NewStr(Seconds mod 60));
  Draw(250,5,300,15);
  Affiche;
end;

Procedure TGame.RedrawTiles;
var X,Y:Integer;

  Procedure RedrawTheTopOfTheAireDeJeuBecauseOfTheHeadOfTheBonhommeQuiDepasse(Player:PPlayer);
  begin
    if Player^.PosY<12 then With Player^ do begin
      FilledSquare(PosX-6+TerrainCornerX,TerrainCornerY-3,PosX+7+TerrainCornerX,TerrainCornerY-1,0);
    end;
  end;

begin
{  for X:=0 to NbrPlayers-1 do RedrawTheTopOfTheAireDeJeuBecauseOfTheHeadOfTheBonhommeQuiDepasse(Players[X]);}
  FilledSquare(TerrainCornerX,TerrainCornerY-3,319,TerrainCornerY-1,0);
  for X:=0 to TerrainSizeX-1 do for Y:=0 to TerrainSizeY-1 do
  if PlayGround[X,Y]^.Redraw then begin
    PlayGround[X,Y]^.Draws;
    PlayGround[X,Y]^.Redraw:=False;
  end;
end;

Procedure TGame.HandleShrink;
var i:Integer;
begin
  With ShrinkInfo do begin
    if Shrinking then begin
      Inc(ShrinkTimer);
      if ShrinkTimer=ShrinkPeriod then begin
        if ShrinkMode=Spiral then begin
          PutSuperWall(ShrinkPos.X,ShrinkPos.Y);
          Case ShrinkDir of
            Up:Dec(ShrinkPos.Y);
            Left:Dec(ShrinkPos.X);
            Down:Inc(ShrinkPos.Y);
            Right:Inc(ShrinkPos.X);
          end;
          Dec(ShrinkLine);
          if ShrinkLine=0 then begin
            if ShrinkDir=Left then ShrinkDir:=Up else ShrinkDir:=Succ(ShrinkDir);
            if ShrinkDir in [Up,Down]
            then begin
              Inc(ShrinkVar);
              ShrinkLine:=TerrainSizeY-ShrinkVar;
            end else ShrinkLine:=TerrainSizeX-ShrinkVar;
          end;
        end;
        if ShrinkMode in [Hori,FromUp] then for i:=0 to TerrainSizeX-1 do
        PutSuperWall(i,ShrinkVar);
        if ShrinkMode in [Hori,FromDown] then for i:=0 to TerrainSizeX-1 do
        PutSuperWall(i,TerrainSizeY-1-ShrinkVar);
        if ShrinkMode in [Verti,FromLeft] then for i:=0 to TerrainSizeY-1 do
        PutSuperWall(ShrinkVar,i);
        if ShrinkMode in [Verti,FromRight] then for i:=0 to TerrainSizeY-1 do
        PutSuperWall(TerrainSizeX-1-ShrinkVar,i);
        if ShrinkMode=Square then begin
          for i:=ShrinkVar to TerrainSizeX-ShrinkVar-1 do begin
            PutSuperWall(i,TerrainSizeY-1-ShrinkVar);
            PutSuperWall(i,ShrinkVar);
          end;
          for i:=ShrinkVar to TerrainSizeY-ShrinkVar-1 do begin
            PutSuperWall(ShrinkVar,i);
            PutSuperWall(TerrainSizeX-1-ShrinkVar,i);
          end;
        end;
        if ShrinkMode in [Hori,Verti,FromRight,FromUp,FromDown,FromLeft,Square] then Inc(ShrinkVar);
        Dec(ShrinkNbr);
        if ShrinkNbr=0 then Shrinking:=False;
        ShrinkTimer:=0;
      end;
    end else if TotalTime=ShrinkDelay then if ShrinkMode<>NoShrink
    then ShrinkMessage:=True;
    if ShrinkMessage then begin
      if ShrinkTimer in [0,40,80,120] then RedrawInfoBar(ShrinkWarning)
      else if ShrinkTimer in [20,60,100] then RedrawInfoBar(ShowNothing)
      else if ShrinkTimer=140 then begin
        RedrawInfoBar(PlayerStatus);
        ShrinkMessage:=False;
        if ShrinkMode<>NoShrink then Shrinking:=True;
        ShrinkTimer:=-1;
        ShrinkVar:=0;
        if ShrinkMode=Spiral then begin
          ShrinkPos.X:=0;
          ShrinkPos.Y:=0;
          ShrinkLine:=TerrainSizeX-1;
          ShrinkDir:=Right;
        end;
      end;
      Inc(ShrinkTimer);
    end;
  end;
end;

Procedure TGame.DoSomething;
var i,j:Integer;MustRedrawInfoBar:Boolean;

  Procedure SortPlayersForDrawing;
  {procedure pour dessiner les bonshommes dans l'ordre, en allant du haut
  vers le bas. Si on fait pas ‡a, ‡a chie pour les bonshommes qui se superposent}
  var Treated:Array[0..3] of Boolean;i,j,MinValue,SelectedPlayer:Integer;
  begin
    for i:=0 to 3 do Treated[i]:=False;
    for i:=0 to NbrPlayers-1 do begin
      MinValue:=32000;
      for j:=0 to NbrPlayers-1 do if (Players[j]^.PosY<MinValue) and not(Treated[j]) then begin
        SelectedPlayer:=j;
        MinValue:=Players[SelectedPlayer]^.PosY;
      end;
      Players[SelectedPlayer]^.TranspDraws;
      Treated[SelectedPlayer]:=True;
    end;
  end;

begin
  for i:=0 to NbrPlayers-1 do Players[i]^.DoSomething;
  i:=0;
  MustRedrawInfoBar:=False;
  Repeat
    if Players[i]^.NoMoreUsed then begin
      New(Deads[NbrDeads],Init(Players[i]^.PNumber,Players[i]^.Wins,Players[i]^.Anim,Players[i]^.Owner));
      Inc(NbrDeads);
      MustRedrawInfoBar:=True;
      Dispose(Players[i],Done);
      Players[i]:=nil;
      if i<NbrPlayers-1 then for j:=i+1 to NbrPlayers-1 do Players[j-1]:=Players[j];
      Players[NbrPlayers-1]:=nil;
      Dec(NbrPlayers);
    end else Inc(i);
  Until i>=NbrPlayers;
  if MustRedrawInfoBar and not(ShrinkInfo.ShrinkMessage) then RedrawInfoBar(PlayerStatus);
  for i:=0 to TerrainSizeX-1 do for j:=0 to TerrainSizeY-1 do PlayGround[i,j]^.Handle;
  if Bombs.Count>0 then begin
    for i:=0 to Bombs.Count-1 do if not(PBomb(Bombs.At(i))^.NoMoreUsed) then
    PBomb(Bombs.At(i))^.Handle;
    i:=0;
    Repeat
      if PBomb(Bombs.At(i))^.NoMoreUsed then Bombs.Free(Bombs.At(i)) else Inc(i);
    Until i>=Bombs.Count;
  end;
  HandleShrink;
  RedrawTiles;
  if Bombs.Count>0 then for i:=0 to Bombs.Count-1 do if not(PBomb(Bombs.At(i))^.OnATile) then
   PBomb(Bombs.At(i))^.TranspDraws;
  SortPlayersForDrawing;
  AfficheAll;
end;

Function TGame.IsGameEnded:Boolean;
var SomeoneDies:Boolean;var i:Integer;
begin
  SomeoneDies:=False;
  for i:=0 to NbrPlayers-1 do if Players[i]<>nil then if Players[i]^.Dying then SomeoneDies:=True;
  IsGameEnded:=K_Esc or ( not(SomeoneDies) and (NbrPlayers in [1,0]) );
end;

Function TGame.AskForReplay:Boolean;
{valeur du boolean renvoy‚ : true=rejouer false=quitter}
var i:Integer;
  Procedure CenteredText(Y:Integer;Text:String);
  begin
    OutText(160-TextLength(Text) div 2,Y,Text);
  end;

begin
  ClearScreen(0);
  AskForReplay:=False;
  CenteredText(120,'APPUYEZ SUR ESC POUR QUITTER');
  CenteredText(130,'APPUYEZ SUR ENTREE POUR REJOUER');
  if NbrPlayers=0 then begin
    CenteredText(100,'VOUS ETES TOUS MORTS!!');
    for i:=0 to Owner^.NbrJoueurs-1 do begin
      TranspText(130,150+10*i,'JOUEUR '+NewStr(i+1)+' : '+NewStr(Owner^.Wins[i]),
      BonhommeColorCoords[Conf.PlayerColors[i]],BonhommeColorCoords[Conf.PlayerColors[i]]+11,True);
    end;
    AfficheAll;
    While not(K_Enter) and not(K_Esc) do;
    if K_Enter then AskForReplay:=True;
  end else
  if (NbrPlayers=1) and (Players[0]<>nil) then With Players[0]^ do begin
    Inc(Self.Owner^.Wins[Players[0]^.PNumber]);
    CenteredText(100,'LE JOUEUR '+NewStr(PNumber+1)+' A DETRUIT TOUT LE MONDE');
    for i:=0 to Self.Owner^.NbrJoueurs-1 do begin
      TranspText(130,150+10*i,'JOUEUR '+NewStr(i+1)+' : '+NewStr(Self.Owner^.Wins[i]),
      BonhommeColorCoords[Conf.PlayerColors[i]],BonhommeColorCoords[Conf.PlayerColors[i]]+11,True);
      Draw(130,150+10*i,250,160+10*i);
    end;
    i:=0;
    Repeat
      SetChronometer;
      FilledSquare(0,0,20,20,0);
      FilledSquare(0,175,20,199,0);
      FilledSquare(300,0,319,20,0);
      FilledSquare(300,175,319,199,0);
      Anim^.WalkAnims[i]^.TranspDraws(8,12,0);
      Anim^.WalkAnims[i]^.TranspDraws(319-8,12,0);
      Anim^.WalkAnims[i]^.TranspDraws(8,199-12,0);
      Anim^.WalkAnims[i]^.TranspDraws(319-8,199-12,0);
      inc(i);
      if i=4 then i:=0;
      AfficheAll;
      Repeat Until (ElapsedTime>4) or K_Enter or K_Esc;
      if K_Enter then AskForReplay:=True;
    Until K_Enter or K_Esc;
  end else begin
    for i:=0 to Owner^.NbrJoueurs-1 do begin
      TranspText(130,150+10*i,'JOUEUR '+NewStr(i+1)+' : '+NewStr(Owner^.Wins[i]),
      BonhommeColorCoords[Conf.PlayerColors[i]],BonhommeColorCoords[Conf.PlayerColors[i]]+11,True);
      Draw(130,150+10*i,250,160+10*i);
    end;
    AfficheAll;
    While K_Esc do;
    While not(K_Enter) and not(K_Esc) do;
    if K_Enter then AskForReplay:=True;
  end;
  ClearScreen(0);
end;

Destructor TGame.Done;
var i,j:Integer;
begin
  for i:=0 to TerrainSizeX-1 do for j:=0 to TerrainSizeY-1 do Dispose(PlayGround[i,j],Done);
  if NbrPlayers>0 then for i:=0 to NbrPlayers-1 do Dispose(Players[i],Done);
  if NbrDeads>0 then for i:=0 to NbrDeads-1 do Dispose(Deads[i],Done);
  Bombs.FreeAll;
  Bombs.Done;
end;

Constructor TUniverse.Init;

Function AskNbrJoueurs:Integer;
begin
  AskNbrJoueurs:=2;
  OutText(50,100,'COMBIEN DE JOUEURS : 2 3 OU 4?');
  AfficheAll;
  While not(K_2 or K_3 or K_4) do;
  if K_2 then AskNbrJoueurs:=2;
  if K_3 then AskNbrJoueurs:=3;
  if K_4 then AskNbrJoueurs:=4;
end;

var i:Integer;
begin
  Conf.Init;
  Conf.SetToDefault;
  if ParamCount>0 then begin
    if not(Conf.Load(ParamStr(1))) then begin
      WriteLn('Appuyez sur Entr‚e pour continuer');
      ReadLn;
    end;
  end;
  MCGAScreen;
  LoadImages;
  LoadCarac;
  AdvKeyOn;
  if Conf.NPlayers in [1..4] then NbrJoueurs:=Conf.NPlayers
  else NbrJoueurs:=AskNbrJoueurs;
  for i:=0 to NbrJoueurs-1 do Wins[i]:=0;
  TimeControlOn;
  Randomize;
end;

Procedure TUniverse.Play;
var StopPlay:Boolean;
begin
  Repeat
    New(Game,Init(NbrJoueurs,@Self));
    Repeat
      SetChronometer;
      Game^.DoSomething;
      StopPlay:=Game^.IsGameEnded;
      if not(StopPlay) then Game^.DoSomething;
      StopPlay:=StopPlay or Game^.IsGameEnded;
      if not(StopPlay) then Game^.DoSomething;
      StopPlay:=StopPlay or Game^.IsGameEnded;
      if not(StopPlay) then begin
        While ElapsedTime<1 do;
        Inc(Game^.TotalTime);
        Game^.RedrawTime;
      end;
    Until StopPlay;
    StillWantToPlay:=Game^.AskForReplay;
    Dispose(Game,Done);
  Until not(StillWantToPlay);
end;

Destructor TUniverse.Done;
begin
  FreeImages;
  TimeControlOff;
  AdvKeyOff;
  CloseScreen;
end;

var Universe:PUniverse;


begin
  New(Universe,Init);
  Universe^.Play;
  Dispose(Universe,Done);
end.