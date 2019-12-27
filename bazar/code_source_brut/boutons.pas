Uses Crt,Objects;

Const
  cmBeep=3;
  cmZog=4;
  cmNothing=0;
  cmFocusOnMyself=1;
  cmAdvanceSelection=2;

  Button=1;
  NumInfo=2;
  TextInfo=3;

  Yeux=4;
  Doigts=3;
  Insultes=5;
  Note1=1;
  Note2=2;

Type

  PInfoStr=^TInfoStr;
  TInfoStr=Object(TObject)
    Info:String;
    Enabled:Boolean;
    Suivant:PInfoStr;
    constructor Init(AInfo:String;AEnabled:Boolean;NextOne:PInfoStr);
    Function LengthMax:Byte; virtual;
    Procedure SetAValue(Name:String;NewStatus:Boolean); virtual;
    Function Count:Byte; virtual;
    Function Find(Nbr:Byte):PInfoStr; virtual;
    Function IsThereOneTrue:Boolean;
    destructor Done; virtual;
  end;

  PEntity=^TEntity;
  TEntity=Object(TObject)
    PosX,PosY,SizeX,SizeY:Word;
    Next:PEntity;
    Entitype:Word;
    Id:LongInt;
    constructor Init;
    Procedure Draw(Selected:Boolean); virtual;
    Function OneKeyPressed(Selected:Boolean;Key:Char):LongInt; virtual;
    Destructor Done; virtual;
  end;

  PButton=^TButton;
  TButton=Object(TEntity)
    Text:String;
    Command:LongInt;
    Touche:Char;
    constructor Init(AX,AY,ASizeX,ASizeY:Word;AId:LongInt;AText:string;ACommand:LongInt;ATouche:Char;ANext:PEntity);
    Procedure Draw(Selected:Boolean); virtual;
    Function OneKeyPressed(Selected:Boolean;Key:Char):LongInt; virtual;
    Destructor Done; virtual;
  end;

  PNumInfo=^TNumInfo;
  TNumInfo=Object(TEntity)
    Text:String;
    Touche:Char;
    Value,Max,Min:Word;
    BackToZero:Boolean;
    constructor Init(AX,AY,ASizeX,ASizeY,AValue,AMin,AMax:Word;
    ABackToZero:Boolean;AId:LongInt;AText:string;ATouche:Char;ANext:PEntity);
    Procedure Draw(Selected:Boolean); virtual;
    Function OneKeyPressed(Selected:Boolean;Key:Char):LongInt; virtual;
    Destructor Done; virtual;
  end;

  PTextInfo=^TTextInfo;
  TTextInfo=Object(TNumInfo)
    Values:PInfoStr;
    constructor Init(AX,AY,ASizeX,ASizeY,AValue:Word;AValues:PInfoStr;
    ABackToZero:Boolean;AId:LongInt;AText:string;ATouche:Char;ANext:PEntity);
    Function OneKeyPressed(Selected:Boolean;Key:Char):LongInt; virtual;
    Procedure Draw(Selected:Boolean); virtual;
    Procedure SetAValue(Name:string;NewStatus:Boolean);
    destructor Done; virtual;
  end;

  PBureau=^TBureau;
  TBureau=Object(TObject)
    Entities:PCollection;
    SelectedEnt:PEntity;
    constructor Init;
    Function Find(IdToFind:LongInt):PEntity; virtual;
    Procedure HandleEvent(Event:LongInt;Summonner:PEntity); virtual;
    Procedure UserPressedAKey(Key:Char); virtual;
    Procedure Suppress(IdToSup:LongInt); virtual;
    Procedure Refresh; virtual;
    Procedure Run; virtual;
    destructor Done; virtual;
  end;


Function NewStr(X:Word):string;
var S:string;
begin
  Str(X,S);
  NewStr:=S;
end;

Procedure PlayNote(Frequency:Word);
begin
  Sound(Frequency);
  Delay(400);
  NoSound;
end;

Constructor TInfoStr.Init(AInfo:String;AEnabled:Boolean;NextOne:PInfoStr);
begin
  Info:=AInfo;
  Enabled:=AEnabled;
  Suivant:=NextOne;
end;

Function TInfoStr.LengthMax:Byte;
var Answer:Byte;P:PInfoStr;
begin
  Answer:=0;
  P:=@Self;
  While P<>Nil do begin
    if Length(P^.Info)>Answer then Answer:=Length(P^.Info);
    P:=P^.Suivant;
  end;
  LengthMax:=Answer;
end;

Function TInfoStr.Count:Byte;
var i:Byte;P:PInfoStr;
begin
  i:=0;
  P:=@Self;
  While P<>Nil do begin
    Inc(i);
    P:=P^.Suivant;
  end;
  Count:=i;
end;

Function TInfoStr.Find(Nbr:Byte):PInfoStr;
var i:Byte;P:PInfoStr;
begin
  i:=Nbr;
  P:=@Self;
  While (P<>Nil) and (i<>0) do begin
    Dec(i);
    P:=P^.Suivant;
  end;
  Find:=P;
end;

Function TInfoStr.IsThereOneTrue:Boolean;
begin
  if Suivant=Nil then IsThereOneTrue:=Enabled else
  IsThereOneTrue:=Enabled or Suivant^.IsThereOneTrue;
end;

Procedure TInfoStr.SetAValue(Name:String;NewStatus:Boolean);
var P:PInfoStr;
begin
  P:=@Self;
  While (P<>Nil) and (P^.Info<>Name) do P:=P^.Suivant;
  if P<>Nil then begin
    P^.Enabled:=NewStatus;
    if not(Self.IsThereOneTrue) then P^.Enabled:=True;
    {cette ligne sert … empˆcher que tout soit Disabled, ce qui peut ˆtre gˆnant}
  end;
end;

destructor TInfoStr.Done;
begin
  if Suivant<>Nil then Dispose(Suivant,Done);
end;

Constructor TEntity.Init;
begin
end;

Procedure TEntity.Draw(Selected:Boolean);
var i,j:Byte;
begin
  TextBackGround(7);
  for j:=0 to SizeY-1 do begin
    GotoXY(PosX,PosY+j);
    for i:=0 to SizeX-1 do Write(' ');
  end;
end;

Function TEntity.OneKeyPressed(Selected:Boolean;Key:Char):LongInt;
begin
  OneKeyPressed:=cmNothing;
end;

Destructor TEntity.Done;
begin
end;


constructor TButton.Init(AX,AY,ASizeX,ASizeY:Word;AId:LongInt;AText:string;ACommand:LongInt;ATouche:Char;ANext:PEntity);
begin
  PosX:=AX;
  PosY:=AY;
  if ASizeX<Length(AText) then SizeX:=Length(AText) else SizeX:=ASizeX;
  if ASizeY=0 then SizeY:=1 else SizeY:=ASizeY;
  Command:=ACommand;
  Touche:=ATouche;
  Text:=AText;
  Next:=ANext;
  Id:=AId;
  Entitype:=Button;
end;

Procedure TButton.Draw(Selected:Boolean);
begin
  TEntity.Draw(Selected);
  GotoXY(PosX,PosY);
  if Selected then TextColor(15) else TextColor(0);
  Write(Text);
end;

Function TButton.OneKeyPressed(Selected:Boolean;Key:Char):LongInt;
begin
  OneKeyPressed:=cmNothing;
  if Key=Touche then Onekeypressed:=Command;
  if Selected then begin
    if Key=#13 then Onekeypressed:=Command;
    if Key=#9 then Onekeypressed:=cmAdvanceSelection;
  end;
end;

destructor TButton.Done;
begin
end;

constructor TNumInfo.Init(AX,AY,ASizeX,ASizeY,AValue,AMin,AMax:Word;
ABackToZero:Boolean;AId:LongInt;AText:string;ATouche:Char;ANext:PEntity);
begin
  PosX:=AX;
  PosY:=AY;
  if ASizeX<Length(AText)+1+Length(NewStr(AMax)) then SizeX:=Length(AText)+1+Length(NewStr(AMax)) else SizeX:=ASizeX;
  if ASizeY=0 then SizeY:=1 else SizeY:=ASizeY;
  Touche:=ATouche;
  Value:=AValue;
  Min:=AMin;
  Max:=AMax;
  Id:=AId;
  Text:=AText;
  Next:=ANext;
  Entitype:=NumInfo;
  BackToZero:=ABackToZero;
end;

Procedure TNumInfo.Draw(Selected:Boolean);
begin
  TEntity.Draw(Selected);
  GotoXY(PosX,PosY);
  if Selected then TextColor(15) else TextColor(0);
  Write(Text,' ',NewStr(Value));
end;

Function TNumInfo.OneKeyPressed(Selected:Boolean;Key:Char):LongInt;
begin
  OneKeyPressed:=cmNothing;
  if Key=Touche then OneKeyPressed:=cmFocusOnMyself;
  if Selected then begin
    if Key in ['+','-'] then begin
      if Key='+' then if Value<Max then Inc(Value)
                      else if BackToZero then Value:=Min;
      if Key='-' then if Value>Min then Dec(Value)
                      else if BackToZero then Value:=Max;
      Self.Draw(True);
    end;
    if Key=#9 then OneKeyPressed:=cmAdvanceSelection;
  end;
end;

Destructor TNumInfo.Done;
begin
end;

constructor TTextInfo.Init(AX,AY,ASizeX,ASizeY,AValue:Word;AValues:PInfoStr;
ABackToZero:Boolean;AId:LongInt;AText:string;ATouche:Char;ANext:PEntity);
begin
  TNumInfo.Init(AX,AY,ASizeX,ASizeY,AValue,0,AValues^.Count-1,ABackToZero,
  AId,AText,ATouche,ANext);
  Values:=AValues;
  Entitype:=TextInfo;
  if SizeX<Length(Text)+1+AValues^.LengthMax then SizeX:=Length(Text)+1+AValues^.LengthMax;
end;

Procedure TTextInfo.Draw(Selected:Boolean);
begin
  TEntity.Draw(Selected);
  GotoXY(PosX,PosY);
  if Selected then TextColor(15) else TextColor(0);
  Write(Text,' ',Values^.Find(Value)^.Info);
end;

Function TTextInfo.OneKeyPressed(Selected:Boolean;Key:Char):LongInt;
var i:Byte;
begin
  OneKeyPressed:=cmNothing;
  if Key=Touche then OneKeyPressed:=cmFocusOnMyself;
  if Selected then begin
    if Key in ['+','-'] then begin
      if Key='+' then begin
        i:=Value;
        Repeat
          if i<Max then Inc(i) else i:=0;
        Until Values^.Find(i)^.Enabled;
      end;
      if Key='-' then begin
        i:=Value;
        Repeat
          if i>0 then Dec(i) else i:=Max;
        Until Values^.Find(i)^.Enabled;
      end;
      Value:=i;
      Self.Draw(True);
    end;
    if Key=#9 then OneKeyPressed:=cmAdvanceSelection;
  end;
end;

Procedure TTextInfo.SetAValue(Name:string;NewStatus:Boolean);
var i:Word;
begin
  Values^.SetAValue(Name,NewStatus);
  i:=Value;
  While not(Values^.Find(i)^.Enabled) do if i<Max then Inc(i) else i:=0;
  Value:=i;
end;

destructor TTextInfo.Done;
begin
  Dispose(Values,Done);
end;

constructor TBureau.Init;
begin
  New(Entities,Init(6,1));
  Entities^.Insert(New(PButton,Init(10,10,20,1,Note1,' BeepBeep',cmBeep,'l',Nil)));
  Entities^.Insert(New(PButton,Init(10,12,20,1,Note2,' Supprimer l''option "Patate"',cmZog,'z',PEntity(Entities^.At(0)))));
  Entities^.Insert(New(PNumInfo,Init(10,14,20,1,2,0,5,True,Doigts,'Combien de doigts?','d',PEntity(Entities^.At(1)))));
  Entities^.Insert(New(PNumInfo,Init(10,16,20,1,2,0,3,False,Yeux,'Combien de yeux','y',PEntity(Entities^.At(2)))));
  Entities^.Insert(New(PTextInfo,Init(10,18,20,1,1,
  New(PInfoStr,Init('Cretin',True,
  New(PInfoStr,Init('Patate',True,
  New(PInfoStr,Init('Debile',True,Nil)))))),True,Insultes,'Qualit‚','q',PEntity(Entities^.At(3)))));
  PButton(Entities^.At(0))^.Next:=PEntity(Entities^.At(4));
  SelectedEnt:=PEntity(Entities^.At(0));
end;

Function TBureau.Find(IdToFind:LongInt):PEntity;
var i,Nbr:Word;Actual,Answer:PEntity;Stop:Boolean;
begin
  Nbr:=Entities^.Count;
  Answer:=Nil;
  i:=0;
  Stop:=False;
  if Nbr<>0 then While not(Stop) do begin
    Actual:=PEntity(Entities^.At(i));
    if Actual^.Id=IdToFind then begin
      Stop:=True;
      Answer:=Actual;
    end;
    Inc(i);
    if i=Nbr then Stop:=True;
  end;
  Find:=Answer;
end;

Procedure TBureau.Suppress(IdToSup:LongInt);
var EntToSupr,NextOne,Actual:PEntity;i:Word;
begin
  EntToSupr:=Find(IdToSup);
  if EntToSupr<>Nil then begin
    NextOne:=EntToSupr^.Next;
    if NextOne=EntToSupr then NextOne:=Nil;
    if SelectedEnt=EntToSupr then SelectedEnt:=NextOne;
    for i:=0 to Entities^.Count-1 do begin
      Actual:=PEntity(Entities^.At(i));
      if Actual^.Next=EntToSupr then Actual^.Next:=NextOne;
    end;
    Entities^.Free(EntToSupr);
  end;
end;

Procedure TBureau.HandleEvent(Event:LongInt;Summonner:PEntity);

  Procedure SelectSummonner;
  begin
    if SelectedEnt<>Summonner then begin
      SelectedEnt^.Draw(False);
      SelectedEnt:=Summonner;
      SelectedEnt^.Draw(True);
    end;
  end;

  Procedure AdvanceSelection;
  begin
    if SelectedEnt=Nil then SelectedEnt:=PEntity(Entities^.At(0))
    else begin
      SelectedEnt^.Draw(False);
      SelectedEnt:=SelectedEnt^.Next;
    end;
    SelectedEnt^.Draw(True);
  end;

begin
  Case Event of
    cmZog:begin
      PTextInfo(Find(Insultes))^.SetAValue('Patate',False);
      PTextInfo(Find(Insultes))^.Draw(False);
    end;
    cmBeep:PlayNote(800);
    cmFocusOnMyself:SelectSummonner;
    cmAdvanceSelection:AdvanceSelection;
  end;
end;

Procedure TBureau.UserPressedAKey(Key:Char);
var Actual:PEntity;i:Word;
begin
  i:=0;
  While i<Entities^.Count do begin
    Actual:=PEntity(Entities^.At(i));
    if Actual<>SelectedEnt then HandleEvent(Actual^.OneKeyPressed(False,Key),Actual);
    Inc(i);
  end;
  if SelectedEnt<>Nil then HandleEvent(SelectedEnt^.OneKeyPressed(True,Key),SelectedEnt);
end;

Procedure TBureau.Refresh;
var i:Word;Actual:PEntity;
begin
  TextBackGround(Blue);
  ClrScr;
  if Entities^.Count>0 then for i:=0 to Entities^.Count-1 do begin
    Actual:=PEntity(Entities^.At(i));
    if Actual<>SelectedEnt then Actual^.Draw(False);
  end;
  if SelectedEnt<>Nil then SelectedEnt^.Draw(True);
end;

Procedure TBureau.Run;
var C:Char;
begin
  TBureau.Refresh;
  c:=' ';
  Repeat
    if Keypressed then begin
      C:=Readkey;
      if C=#0 then C:=Readkey else UserPressedAKey(C);
    end;
  Until C=#27;
end;

Destructor TBureau.Done;
begin
  Dispose(Entities,Done);
end;

var
  Bureau:PBureau;

begin
  Bureau:=New(PBureau,Init);
  Bureau^.Run;
  Dispose(Bureau,Done);
end.