Unit Bombconf;

interface

Uses Objects,Dos;

  Const
    NbrBonus=4;

  Type
  TSection=(Nothing,PlayerConfig,ShrinkConfig,General,BonusConfig);
  TSpeed=(Slow,Average,Fast);
  TPlayerStart=(Center,Corner,Bof);
  TShrinkMode=(NoShrink,Spiral,Square,Verti,Hori,FromUp,FromDown,FromLeft,FromRight);
  BonusType=(Flamme,Bombe,NoBonus,Kick);
  TProba=Array[0..NbrBonus-1] of Byte;
  TConfig=Object(TObject)
    WallProba,Power,Bombs,AShrinkDelay,AShrinkPeriod,AShrinkNbr,NPlayers:Integer;
    AShrinkMode:TShrinkMode;
    ShrinkSpeed:TSpeed;
    PlayerStartsX,PlayerStartsY,PlayerColors:Array[0..3] of Byte;
    PlayerStartMode:TPlayerStart;
    ProbaBonus,CumuProba:TProba;
    UserSetProba:Boolean;
    Constructor Init;
    Function Load(FileName:string):Boolean; virtual;
    Procedure SetToDefault; virtual;
    Procedure DefinePlayerStartPos;
    Function MakeCumuProba:Boolean;
    Destructor Done; virtual;
  end;

Const
  TerrainSizeX=19;
  TerrainSizeY=11;
  Numbers=['0'..'9'];
  AuthorizedChars=['A'..'Z','0'..'9','_'];
  OneMinute=1092;
{une minute de jeu correspond … peu prŠs … 1092 "cycles" de jeu}
  GlobalSpeed=3;
  {dans un "cycle" de jeu, la proc‚dure TGame^.DoSomething est effectu‚e
  3 fois   (voir BOMBMAN.PAS) }
  ShrinkPeriodValues:Array[Spiral..FromRight,Slow..Fast] of Integer=(
  (OneMinute div 50,OneMinute div 100, OneMinute div 540),
  (OneMinute div 6,OneMinute div 10, OneMinute div 20),
  (OneMinute div 7,OneMinute div 12, OneMinute div 30),
  (OneMinute div 7,OneMinute div 11, OneMinute div 25),
  (OneMinute div 3,OneMinute div 5, OneMinute div 13),
  (OneMinute div 3,OneMinute div 5, OneMinute div 13),
  (OneMinute div 4,OneMinute div 6, OneMinute div 15),
  (OneMinute div 4,OneMinute div 6, OneMinute div 15) );

var Conf:TConfig;

implementation

Constructor TConfig.Init;
begin
end;

Procedure TConfig.DefinePlayerStartPos;
var i:Integer;
begin
  Case PlayerStartMode of
    Center:begin
      for i:=0 to 3 do begin
        PlayerStartsX[i]:=TerrainSizeX div 2-1;
        PlayerStartsY[i]:=TerrainSizeY div 2-1;
      end;
    end;
    Corner:begin
      PlayerStartsX[0]:=0;
      PlayerStartsY[0]:=0;
      PlayerStartsX[1]:=TerrainSizeX-1;
      PlayerStartsY[1]:=0;
      PlayerStartsX[2]:=0;
      PlayerStartsY[2]:=TerrainSizeY-1;
      PlayerStartsX[3]:=TerrainSizeX-1;
      PlayerStartsY[3]:=TerrainSizeY-1;
    end;
    Bof:begin
      PlayerStartsX[0]:=TerrainSizeX div 4;
      PlayerStartsY[0]:=TerrainSizeY div 4;
      PlayerStartsX[1]:=TerrainSizeX*3 div 4;
      PlayerStartsY[1]:=TerrainSizeY div 4;
      PlayerStartsX[2]:=TerrainSizeX div 4;
      PlayerStartsY[2]:=TerrainSizeY*3 div 4;
      PlayerStartsX[3]:=TerrainSizeX*3 div 4;
      PlayerStartsY[3]:=TerrainSizeY*3 div 4;
    end;
  end;
end;

Function TConfig.MakeCumuProba:Boolean;
var i,Somme:Integer;
begin
  Somme:=0;
  for i:=0 to nbrBonus-1 do begin
    Inc(Somme,ProbaBonus[i]);
    CumuProba[i]:=Somme;
  end;
  MakeCumuProba:=Somme=100;
end;

Function TConfig.Load(FileName:string):Boolean;
var ConfFile:Text;Line,ExtractedWord,ExtractedWord2:string;Cursor,ExtractedNbr,Proot,BonusChosen:Integer;
CurrentSection:TSection;Coherent:Boolean;

  Function ExtractWord(Line:string;var Cursor:Integer):string;
  var Result:string;
  begin
    Result:='';
    While (Cursor<=Length(Line)) and (UpCase(Line[Cursor]) in AuthorizedChars) do begin
      Result:=Result+UpCase(Line[Cursor]);
      Inc(Cursor);
    end;
    ExtractWord:=Result;
  end;

  Function ExtractInt(Line:string;var Cursor:Integer):Integer;
  var Result,Inutile:Integer;Extract:string;
  begin
    Extract:='0';
    While (Line[Cursor] in Numbers) and (Cursor<=Length(Line)) do begin
      Extract:=Extract+Line[Cursor];
      Inc(Cursor);
    end;
    Val(Extract,Result,Inutile);
    ExtractInt:=Result;
  end;

  Function CursorAtEnd(Line:string;Cursor:Integer):Boolean;
  begin
    CursorAtEnd:=Cursor=Length(Line)+1;
  end;

  Function FindSomething(Line:string;var Cursor:Integer):Boolean;
  begin
    While (Cursor<=Length(Line)) and (Line[Cursor]=' ') do Inc(Cursor);
    FindSomething:=not(CursorAtEnd(Line,Cursor));
  end;

  Function GotASignEqual(Line:string;var Cursor:Integer):Boolean;
  var Result:Boolean;
  begin
    Result:=FindSomething(Line,Cursor);
    Result:=Result and (Line[Cursor]='=');
    if Result then begin
      Inc(Cursor);
      Result:=Result and FindSomething(Line,Cursor);
    end;
    GotASignEqual:=Result;
  end;

  Function GiveCodeColor(S:string):Integer;
  begin
    GiveCodeColor:=-1;
    if S='RED' then GiveCodeColor:=0;
    if S='YELLOW' then GiveCodeColor:=1;
    if S='GREEN' then GiveCodeColor:=2;
    if S='BLUE' then GiveCodeColor:=3;
  end;

begin
  Assign(ConfFile,FileName);
  Load:=True;
  {$I-}
  Reset(ConfFile);
  if IOResult<>0 then begin
    Load:=False;
    WriteLn('fichier de configuration introuvable');
    WriteLn('le jeu va ˆtre ex‚cut‚ avec la configuration par d‚faut');
    Exit;
  end;
  {$I+}
  CurrentSection:=Nothing;
  While not(Eof(ConfFile)) do begin
    Coherent:=True;
    ReadLn(ConfFile,Line);
    Cursor:=1;
    if (Line<>'') and (Line[1]<>';') and FindSomething(Line,Cursor) then begin
      if Line[Cursor]='[' then begin
        Inc(Cursor);
        ExtractedWord:=ExtractWord(Line,Cursor);
        Coherent:=not(CursorAtEnd(Line,Cursor)) and (Line[Cursor]=']');
        if Coherent then begin
          Inc(Cursor);
          Coherent:=not(FindSomething(Line,Cursor));
        end;
        if Coherent then begin
          if ExtractedWord='PLAYERCONFIG' then CurrentSection:=PlayerConfig
          else if ExtractedWord='SHRINKCONFIG' then CurrentSection:=ShrinkConfig
          else if ExtractedWord='MAINRULES' then CurrentSection:=General
          else if ExtractedWord='BONUSPROBABILITY' then CurrentSection:=BonusConfig
          else Coherent:=False;
        end;

      end else begin
        ExtractedWord:=ExtractWord(Line,Cursor);
        Case CurrentSection of
          Nothing:Coherent:=False;
          PlayerConfig:begin
            if (ExtractedWord='BOMBS') or (ExtractedWord='POWER') then begin
              Coherent:=GotASignEqual(Line,Cursor);
              if Coherent then ExtractedNbr:=ExtractInt(Line,Cursor);
              Coherent:=Coherent and not(FindSomething(Line,Cursor));
              if Coherent then begin
                if ExtractedWord='BOMBS' then if ExtractedNbr in [1..10]
                                              then Bombs:=ExtractedNbr
                                              else Coherent:=False;
                if ExtractedWord='POWER' then if ExtractedNbr in [1..10]
                                              then Power:=ExtractedNbr
                                              else Coherent:=False;
              end;
            end else if (Copy(ExtractedWord,1,5)='COLOR') then begin
              Proot:=6;
              ExtractedNbr:=ExtractInt(ExtractedWord,Proot);
              Coherent:=(ExtractedNbr in [1..4]) and GotASignEqual(Line,Cursor);
              if Coherent then ExtractedWord:=ExtractWord(Line,Cursor);
              Coherent:=Coherent and (GiveCodeColor(ExtractedWord)<>-1) and not(FindSomething(Line,Cursor));
              if Coherent then PlayerColors[ExtractedNbr-1]:=GiveCodeColor(ExtractedWord);
            end else if ExtractedWord='STARTPOS' then begin
              Coherent:=GotASignEqual(Line,Cursor);
              if Coherent then ExtractedWord:=ExtractWord(Line,Cursor);
              Coherent:=Coherent and not(FindSomething(Line,Cursor));
              if Coherent then begin
                if ExtractedWord='CENTER' then PlayerStartMode:=Center
                else if ExtractedWord='CORNERS' then PlayerStartMode:=Corner
                else if ExtractedWord='AVERAGE' then PlayerStartMode:=Bof
                else Coherent:=False;
              end;
            end else Coherent:=False;
          end;
          General:begin
            if (ExtractedWord='WALL_PERCENT') or (ExtractedWord='NBR_PLAYERS') then begin
              Coherent:=GotASignEqual(Line,Cursor);
              if Coherent then ExtractedNbr:=ExtractInt(Line,Cursor);
              Coherent:=Coherent and not(FindSomething(Line,Cursor));
              if Coherent then begin
                if ExtractedWord='WALL_PERCENT' then if ExtractedNbr in [0..100]
                                              then WallProba:=ExtractedNbr
                                              else Coherent:=False;
                if ExtractedWord='NBR_PLAYERS' then if ExtractedNbr in [1..4]
                                              then NPlayers:=ExtractedNbr
                                              else Coherent:=False;
              end;
            end else Coherent:=False;
          end;
          ShrinkConfig:begin
            if (ExtractedWord='DELAY') or (ExtractedWord='QUANTITY') then begin
              Coherent:=GotASignEqual(Line,Cursor);
              if Coherent then ExtractedNbr:=ExtractInt(Line,Cursor);
              Coherent:=Coherent and not(FindSomething(Line,Cursor));
              if Coherent then begin
                if ExtractedWord='DELAY' then if (ExtractedNbr>=1) and (ExtractedNbr<=2000)
                                        then AShrinkDelay:=LongInt(ExtractedNbr)*OneMinute div 60
                                        else Coherent:=False;
                if ExtractedWord='QUANTITY' then if (ExtractedNbr>=1) and (ExtractedNbr<=209)
                                        then AShrinkNbr:=ExtractedNbr
                                        else Coherent:=False;
              end;
            end else if (ExtractedWord='MODE') or (ExtractedWord='SPEED') then begin
              Coherent:=GotASignEqual(Line,Cursor);
              if Coherent then ExtractedWord2:=ExtractWord(Line,Cursor);
              Coherent:=Coherent and not(FindSomething(Line,Cursor));
              if Coherent then begin
                if ExtractedWord='MODE' then begin
                  if ExtractedWord2='FROM_LEFT' then AShrinkMode:=FromLeft
                  else if ExtractedWord2='FROM_RIGHT' then AShrinkMode:=FromRight
                  else if ExtractedWord2='FROM_DOWN' then AShrinkMode:=FromDown
                  else if ExtractedWord2='FROM_UP' then AShrinkMode:=FromUp
                  else if ExtractedWord2='SPIRAL' then AShrinkMode:=Spiral
                  else if ExtractedWord2='SQUARE' then AShrinkMode:=Square
                  else if ExtractedWord2='HORIZONTAL' then AShrinkMode:=Hori
                  else if ExtractedWord2='VERTICAL' then AShrinkMode:=Verti
                  else if ExtractedWord2='NOSHRINK' then AShrinkMode:=NoShrink
                  else Coherent:=False;
                end;
                if ExtractedWord='SPEED' then begin
                  if ExtractedWord2='SLOW' then ShrinkSpeed:=Slow
                  else if ExtractedWord2='AVERAGE' then ShrinkSpeed:=Average
                  else if ExtractedWord2='FAST' then ShrinkSpeed:=Fast
                  else Coherent:=False;
                end;
              end;
            end else Coherent:=False;
          end;
          BonusConfig:begin
            UserSetProba:=True;
            if ExtractedWord='ADDPOWER' then BonusChosen:=Ord(Flamme)
            else if ExtractedWord='ADDBOMB' then BonusChosen:=Ord(Bombe)
            else if ExtractedWord='KICK' then BonusChosen:=Ord(Kick)
            else if ExtractedWord='NOBONUS' then BonusChosen:=Ord(NoBonus)
            else Coherent:=False;
            Coherent:=Coherent and GotASignEqual(Line,Cursor);
            if Coherent then begin
              ExtractedNbr:=ExtractInt(Line,Cursor);
              Coherent:=not(FindSomething(Line,Cursor)) and (ExtractedNbr>=0) and (ExtractedNbr<=100);
              if Coherent then ProbaBonus[BonusChosen]:=ExtractedNbr;
            end;
          end;
        end;
      end;
      if Coherent=False then begin
        WriteLn('la ligne ',Line);
        WriteLn('est incoh‚rente, ou bien elle n''est pas plac‚e dans la bonne section');
        WriteLn;
        Load:=False;
      end;
    end;
  end;
  if AShrinkMode<>NoShrink then AShrinkPeriod:=ShrinkPeriodValues[AShrinkMode,ShrinkSpeed];
  DefinePlayerStartPos;
  if not(MakeCumuProba) then begin
    if UserSetProba then begin
      WriteLn('Les probabilit‚s des bonus ne sont pas correctes, la somme ne vaut pas 100');
      WriteLn;
      Load:=False;
    end;
    ProbaBonus[Ord(Flamme)]:=30;
    ProbaBonus[Ord(Bombe)]:=30;
    ProbaBonus[Ord(NoBonus)]:=20;
    ProbaBonus[Ord(Kick)]:=20;
    MakeCumuProba;
  end;
end;
{bou lala!!  comme vous avez pu le voir, cette proc‚dure load
est vraiment programm‚ n'importe comment, y'a des petits morceaux
de programme coll‚ un peu partout, y'en a plein qui se r‚pŠte...
mais j'ai du mal … voir coment je ferais autrement}

Procedure TConfig.SetToDefault;
var i:Integer;
begin
  Bombs:=1;
  Power:=2;
  PlayerColors[0]:=0;
  PlayerColors[1]:=1;
  PlayerColors[2]:=2;
  PlayerColors[3]:=3;
  AShrinkDelay:=OneMinute;
  AShrinkPeriod:=18*GlobalSpeed;
  ShrinkSpeed:=Average;
  AShrinkMode:=Spiral;
  AShrinkNbr:=56;
  AShrinkPeriod:=ShrinkPeriodValues[AShrinkMode,ShrinkSpeed];
  PlayerStartMode:=Bof;
  DefinePlayerStartPos;
  WallProba:=60;
  NPlayers:=-1;
  for i:=0 to NbrBonus-1 do ProbaBonus[i]:=0;
end;

Destructor TConfig.Done;
begin
end;


end.

