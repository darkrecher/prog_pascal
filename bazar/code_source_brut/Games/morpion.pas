Uses App,Objects,Menus,Views,Dialogs,Drivers,msgbox;

Const
  cmNothing=100;
  cmHistorik=101;
  cmNewGame=107;
  cmEssai=108;
  cmAnnule=102;
  cmComputerFirst=103;
  Grille:Array[0..6] of String[13]=(
    'ÚÄÄÄÂÄÄÄÂÄÄÄ¿',
    '³   ³   ³   ³',
    'ÃÄÄÄÅÄÄÄÅÄÄÄ´',
    '³   ³   ³   ³',
    'ÃÄÄÄÅÄÄÄÅÄÄÄ´',
    '³   ³   ³   ³',
    'ÀÄÄÄÁÄÄÄÁÄÄÄÙ');
  NbrFenetre:LongInt=0;

Type
  TPlayed=Record
    X,Y:Byte;
    Player:Boolean;
  end;

  TNewApp=Object(TApplication)
    Procedure InitMenuBar; virtual;
    Procedure HandleEvent(var Event:TEvent); virtual;
    Procedure InitStatusLine; virtual;
  end;

  PFenetre=^TFenetre;
  TFenetre=Object(TWindow)
    Morpion:Array[0..2,0..2] of Byte;
    PlayerOne,PlayerTwo,WhoseTurn,Stopped:Boolean;
    MorpiOrigine:TPoint;
    NbrCoups:LongInt;
    Played:Array[0..8] of TPlayed;
    Constructor Init;
    Procedure HandleEvent(var Event:TEvent); Virtual;
    Procedure Draw; virtual;
    Destructor Done; virtual;
  end;

  PCollectionProut=^TCollectionProut;
  TCollectionProut=Object(TCollection)
    Procedure FreeItem(P:Pointer);virtual;
  end;

var
  Focused:PFenetre;

Procedure SelectPlayers;
var D:PDialog;POne,PTwo:PRadioButtons;R:TRect;Answer:Integer;W:PFenetre;Event:TEvent;
begin
  R.Assign(5,1,50,22);
  D:=New(PDialog,Init(R,'Chai pas quoi mettre'));
  With D^ do begin
    R.Assign(1,2,15,3);
    Insert(New(PStaticText,Init(R,'Joueur un  (O)')));
    R.Assign(20,2,40,3);
    Insert(New(PStaticText,Init(R,'Joueur deux  (X)')));
    R.Assign(1,4,16,6);
    POne:=New(PRadiobuttons,Init(R,NewSItem('Humain',NewSItem('Ordinateur',nil))));
    Insert(POne);
    R.Assign(20,4,35,6);
    PTwo:=New(PRadiobuttons,Init(R,NewSItem('Humain',NewSItem('Ordinateur',nil))));
    Insert(PTwo);
    R.Assign(2,15,12,17);
    Insert(New(PButton,Init(R,'~O~K',cmOK,bfDefault)));
    R.Assign(18,15,28,17);
    Insert(New(PButton,Init(R,'~A~nnuler',cmCancel,bfNormal)));
  end;
  if DeskTop^.ExecView(D)=cmOk then begin
    W:=New(PFenetre,Init);
    POne^.GetData(Answer);
    W^.PlayerOne:=Answer=1;
    PTwo^.GetData(Answer);
    W^.PlayerTwo:=Answer=1;
    if W<>Nil then DeskTop^.Insert(W);
    W^.Draw;
    if W^.PlayerOne then begin
      Event.What:=evCommand;
      Event.Command:=cmComputerFirst;
      W^.HandleEvent(Event);
     end;
  end;
  Dispose(D,Done);
end;

Procedure TCollectionProut.FreeItem(P:Pointer);
begin
  if P<>Nil then DisposeStr(P);
end;

Function GivePlayer(Player:Boolean):String;
begin
  if Player=False then GivePlayer:='Joueur un' else GivePlayer:='Joueur deux';
end;

Function NbrToString(Nbr:Integer):string;
var S:string;
begin
  Str(Nbr,S);
  NbrToString:=S;
  Delete(S,1,2);
end;

Procedure Historik;
var D:PDialog;R:Trect;List:PListBox;Collec:PCollectionProut;i:Byte;
begin
  R.Assign(5,1,50,22);
  D:=New(PDialog,Init(R,'Coups Jou‚s'));
  Collec:=New(PCollectionProut,Init(9,1));
  With Focused^ do begin
    if NbrCoups>0 then for i:=0 to NbrCoups-1 do Collec^.Insert(Newstr(NbrToString(Played[i].X)+'     '
    +NbrToString(Played[i].Y)+'     '+GivePlayer(Played[i].Player)));
  end;
  With D^ do begin
    R.Assign(1,3,40,12);
    List:=New(PListBox,Init(R,1,Nil));
    List^.NewList(Collec);
    Insert(List);
    R.Assign(1,2,40,3);
    Insert(New(PStaticText,Init(R,'X     Y     Joueur')));
    R.Assign(2,14,15,16);
    Insert(New(PButton,Init(R,'~O~K',cmOK,bfDefault)));
  end;
  DeskTop^.ExecView(D);
  Dispose(D,Done);
end;

Procedure Annule;

  Procedure CancelLastOne;
  begin
    With Focused^ do begin
      Morpion[Played[NbrCoups-1].X,Played[NbrCoups-1].Y]:=0;
      Dec(NbrCoups);
      WhoseTurn:=not(WhoseTurn);
      Stopped:=False;
      Draw;
    end;
  end;

begin
  With Focused^ do begin
    if NbrCoups>0 then CancelLastOne;
    if (PlayerOne or PlayerTwo) and (NbrCoups>0) then CancelLastOne;
    if ((NbrCoups=0) and not PlayerOne)
    or ((NbrCoups=1) and PlayerOne) then DisableCommands([cmAnnule]);
  end;
end;

Procedure TNewApp.InitMenuBar;
var Bounds:TRect;
begin
  GetExtent(Bounds);
  Bounds.B.Y:=Bounds.A.Y+1;
  MenuBar:=New(PMenuBar,Init(Bounds,NewMenu(
    NewSubMenu('Jeu',0,NewMenu(
      NewItem('Nouveau','',KbNoKey,cmNewGame,HCNoContext,
      NewItem('Fermer','',KbNoKey,cmClose,HCNoContext,
      NewItem('Quitter','',KbNoKey,cmQuit,HCNoContext,Nil)))),
    NewSubMenu('Partie en cours',0,NewMenu(
      NewItem('Voir les coups jou‚s','',KbNoKey,cmHistorik,HCNoContext,
      NewItem('Annuler le dernier coup','',KbNoKey,cmAnnule,HCNoContext,Nil))),
    Nil)))));
  DisableCommands([cmHistorik,cmAnnule]);
end;

Procedure TFenetre.HandleEvent(var Event:TEvent);
var Coord:TPoint;Result,x,y:Byte;S:String;

  Function Test:Boolean;
  var i:Byte;Result:Boolean;
  begin
    Result:=False;
    for i:=0 to 2 do begin
      if (Morpion[i,0]=Morpion[i,1]) and (Morpion[i,1]=Morpion[i,2]) and (Morpion[i,0]<>0) then Result:=True;
      if (Morpion[0,i]=Morpion[1,i]) and (Morpion[1,i]=Morpion[2,i]) and (Morpion[0,i]<>0) then Result:=True;
    end;
    if (Morpion[0,0]=Morpion[1,1]) and (Morpion[1,1]=Morpion[2,2]) and (Morpion[1,1]<>0) then Result:=True;
    if (Morpion[2,0]=Morpion[1,1]) and (Morpion[1,1]=Morpion[0,2]) and (Morpion[1,1]<>0) then Result:=True;
    Test:=Result;
  end;

  Procedure IAofZeMorpion(var x,y:Byte);

    Function FindTwo(x0,y0,x1,y1,x2,y2,CrossOrCircle:Byte;var x,y:Byte):Boolean;
    begin
      if (Morpion[x1,y1]=CrossOrCircle) and (Morpion[x2,y2]=CrossOrCircle) and (Morpion[x0,y0]=0) then begin
        x:=x0;
        y:=y0;
        FindTwo:=True;
      end else
      if (Morpion[x1,y1]=CrossOrCircle) and (Morpion[x0,y0]=CrossOrCircle) and (Morpion[x2,y2]=0) then begin
        x:=x2;
        y:=y2;
        FindTwo:=True;
      end else
      if (Morpion[x0,y0]=CrossOrCircle) and (Morpion[x2,y2]=CrossOrCircle) and (Morpion[x1,y1]=0) then begin
        x:=x1;
        y:=y1;
        FindTwo:=True;
      end else FindTwo:=False;
    end;

    Function PutThird(CrossOrCircle:Byte;var x,y:Byte):Boolean;
    var i:Byte;Stop:Boolean;
    begin
      i:=0;
      Repeat
        Stop:=FindTwo(i,0,i,1,i,2,CrossOrCircle,x,y);
        if not(Stop) then Stop:=FindTwo(0,i,1,i,2,i,CrossOrCircle,x,y);
        Inc(i);
      Until (i=3) or Stop;
      if not(Stop) then Stop:=FindTwo(0,0,1,1,2,2,CrossOrCircle,x,y);
      if not(Stop) then Stop:=FindTwo(0,2,1,1,2,0,CrossOrCircle,x,y);
      PutThird:=Stop;
    end;

  var Number:Byte;

    Function ChoseOne(x1,y1:Byte;var x,y:Byte):Boolean;
    begin
      ChoseOne:=False;
      if Morpion[x1,y1]=0 then begin
        Inc(Number);
        if Random(Number)=0 then begin
          ChoseOne:=True;
          x:=x1;
          y:=y1;
        end;
      end;
    end;

  var i,CrossOrCircle:Byte;
  begin
    if WhoseTurn then CrossOrCircle:=2 else CrossOrCircle:=1;
    if not(PutThird(CrossOrCircle,x,y)) then begin
      if not(WhoseTurn) then CrossOrCircle:=2 else CrossOrCircle:=1;
      if not(PutThird(CrossOrCircle,x,y)) then begin
        if Morpion[1,1]=0 then begin
          x:=1;
          y:=1;
        end else begin
          Number:=0;
{$B+}
          if not(ChoseOne(0,0,x,y) or ChoseOne(2,0,x,y) or ChoseOne(0,2,x,y) or ChoseOne(2,2,x,y)) then begin
{$B-}
            Number:=0;
            ChoseOne(1,0,x,y);
            ChoseOne(2,1,x,y);
            ChoseOne(0,1,x,y);
            ChoseOne(1,2,x,y);
          end;
        end;
      end;
    end;
  end;

  Procedure Play(x,y:Byte);
  begin
    if WhoseTurn then Morpion[X,Y]:=2 else Morpion[X,Y]:=1;
    Played[NbrCoups].X:=X;
    Played[NbrCoups].Y:=Y;
    Played[NbrCoups].Player:=WhoseTurn;
    WhoseTurn:=not(WhoseTurn);
    Inc(NbrCoups);
    Draw;
    if Test then begin
      Stopped:=True;
      Draw;
      FormatStr(S,'Le '+GivePlayer(not(WhoseTurn))+' a gagn‚ au %deme tour ',NbrCoups);
      MessageBox(S,Nil,mfOkButton+mfInformation);
    end else if NbrCoups=9 then begin
      Stopped:=True;
      Draw;
      MessageBox('Match Nul',Nil,mfOKButton+mfInformation);
    end else if (not(WhoseTurn) and PlayerOne) or (WhoseTurn and PlayerTwo) then begin
      IAofZeMorpion(x,y);
      Play(x,y);
    end;
  end;

begin
  TWindow.HandleEvent(Event);
  Case Event.What of
    EvBroadCast:Case Event.Command of
      cmReceivedFocus:Focused:=@Self;
      cmClose:Focused:=Nil;
      else Exit;
    end;
    evMouseDown:if Event.Buttons=mbLeftButton then begin
      MakeLocal(Event.Where,Coord);
      Case Coord.X-MorpiOrigine.X of
        2:Coord.X:=0;
        6:Coord.X:=1;
        10:Coord.X:=2;
        else Coord.X:=-1
      end;
      Case Coord.Y-MorpiOrigine.Y of
        1:Coord.Y:=0;
        3:Coord.Y:=1;
        5:Coord.Y:=2;
        else Coord.Y:=-1
      end;
      if (Coord.X>-1) and (Coord.Y>-1) then if (Morpion[Coord.X,Coord.Y]=0) and (not(Stopped)) then begin
        Play(Coord.X,Coord.Y);
        EnableCommands([cmAnnule]);
      end;
    end else Exit;
    evCommand:Case Event.Command of
      cmComputerFirst:begin
        IAOfZeMorpion(x,y);
        Play(x,y);
      end;
      else Exit;
    end;
  else Exit;
  end;
  ClearEvent(Event);
end;

Function Min(N1,N2:Integer):Integer;
begin
  if N1<N2 then Min:=N1 else Min:=N2;
end;

Function ThereMightBeADuplicateIdentifierWithThisFuckinProcedureCalledDelete(S:string;Index,Count:Integer):string;
var Dest:string;
begin
  Dest:=S;
  Delete(Dest,Index,Count);
  ThereMightBeADuplicateIdentifierWithThisFuckinProcedureCalledDelete:=Dest;
end;

Procedure TFenetre.Draw;
var i,j:Integer;S:string;
begin
  TWindow.Draw;
  if not(Stopped) then begin
    S:='Tour num‚ro '+NbrToString(NbrCoups+1)+'   '+GivePlayer(WhoseTurn);
    WriteStr(1,1,ThereMightBeADuplicateIdentifierWithThisFuckinProcedureCalledDelete
    (S,Min(Size.X-1,Length(S)),Length(S)-Size.X+2),2);
  end;
  MorpiOrigine.X:=(Size.X-11) div 2;
  MorpiOrigine.Y:=(Size.Y-4) div 2+1;
  for i:=0 to Min(6,Size.Y-MorpiOrigine.Y-2) do WriteStr(Morpiorigine.X,Morpiorigine.Y+i,
  Copy(Grille[i],0,Size.X-MorpiOrigine.X-1),2);
  for j:=0 to Min(2,(Size.Y-MorpiOrigine.Y+1) div 2-2) do for i:=0 to
  Min(2,(Size.X-MorpiOrigine.X) div 4-1) do Case Morpion[i,j] of
    0:WriteStr(i*4+2+Morpiorigine.X,j*2+1+Morpiorigine.Y,' ',2);
    1:WriteStr(i*4+2+Morpiorigine.X,j*2+1+Morpiorigine.Y,'O',2);
    2:WriteStr(i*4+2+Morpiorigine.X,j*2+1+Morpiorigine.Y,'X',2);
  end;
end;

Constructor TFenetre.Init;
var R:TRect;i,j:Byte;
begin
  DeskTop^.GetExtent(R);
  TWindow.Init(R,'Et nianiania',5);
  Options:=Options or ofTileAble;
  GetExtent(R);
  R.Grow(-1,-1);
  for i:=0 to 2 do for j:=0 to 2 do Morpion[i,j]:=0;
  WhoseTurn:=False;
  NbrCoups:=0;
  Stopped:=False;
  Inc(NbrFenetre);
  EnableCommands([cmHistorik]);
end;

destructor TFenetre.Done;
begin
  TWindow.Done;
  Dec(NbrFenetre);
  if NbrFenetre=0 then DisableCommands([cmHistorik,cmAnnule]);
end;

Procedure TNewApp.InitStatusLine;
var Bounds:TRect;
begin
  GetExtent(Bounds);
  Bounds.A.Y:=Bounds.B.Y-1;
  StatusLine:=New(PStatusLine,Init(Bounds,NewStatusDef(0,20,
  NewStatusKey('~Alt-X~ Quitter',kbAltX,cmQuit,Nil),Nil)));
end;

Procedure TNewApp.HandleEvent(var Event:TEvent);
begin
  TApplication.HandleEvent(Event);
  Case Event.What of
    EvCommand:Case Event.Command of
      cmNewGame:SelectPlayers;
      cmHistorik:Historik;
      cmAnnule:Annule;
      else Exit;
    end;
    else Exit;
  end;
  ClearEvent(Event);
end;

var
  Machin:TNewApp;

begin
  Randomize;
  Machin.Init;
  Machin.Run;
  Machin.Done;
end.