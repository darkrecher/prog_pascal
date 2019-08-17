Uses App,Objects,Menus,Views,Dialogs,Drivers,msgbox;

Const
  cmNothing=100;
  cmBip=101;
  cmMessage=102;
  cmWindow=103;
  cmPlay=104;

Type
  TNewApp=Object(TApplication)
    Procedure InitMenuBar; virtual;
    Procedure HandleEvent(var Event:TEvent); virtual;
    Procedure InitStatusLine; virtual;
  end;

  PBoiboite=^TBoiboite;
  TBoiboite=Object(TScroller)
    Morpion:Array[0..2,0..2] of Byte;
    Procedure Draw; Virtual;
    Constructor Init(Taille:TRect);
  end;

  PFenetre=^TFenetre;
  TFenetre=Object(TWindow)
    Arena:PBoiboite;
    Constructor Init;
    Procedure HandleEvent(var Event:TEvent); Virtual;
  end;

Procedure TNewApp.InitMenuBar;
var Bounds:TRect;
begin
  GetExtent(Bounds);
  Bounds.B.Y:=Bounds.A.Y+1;
  MenuBar:=New(PMenuBar,Init(Bounds,NewMenu(
    NewItem('Patate','',KbNoKey,cmMessage,HCNoContext,
    NewItem('Carotte','',KbNoKey,cmPlay,666,Nil)))));
end;

Procedure TFenetre.HandleEvent(var Event:TEvent);
begin
  TWindow.HandleEvent(Event);
  Case Event.What of
    EvCommand:Case Event.Command of
      cmPlay:Arena^.Morpion[0,0]:=0;
    else Exit;
    end;
  else Exit;
  end;
  ClearEvent(Event);
end;

Constructor TBoiboite.Init(Taille:TRect);
var i,j:Byte;R:TRect;
begin
   TScroller.Init(Taille,Nil,Nil);
   GrowMode:=gfGrowHix+gfGrowHiY;
   for i:=0 to 2 do for j:=0 to 2 do Morpion[i,j]:=2;
   Morpion[1,1]:=2;
   SetLimit(50,50);
end;

Procedure TBoiboite.Draw;
{var i,j:Byte;Ligne:TDrawBuffer;}
var B:TDrawBuffer;C:Byte;i,j:Integer;
begin
{  for i:=0 to Size.Y-1 do begin
    MoveChar(Ligne,'Z',GetColor(1),Size.X);
    WriteLine(0,i,Size.X,1,Ligne);
  end;
  for i:=0 to 2 do for j:=0 to 2 do Case Morpion[i,j] of
    1:WriteStr(i*2,j*2,'X',1);
    2:WriteStr(i*2,j*2,'O',1);
  end;
  WriteStr(1,1,'O',1);
  Write(#7);}
  C:=GetColor(1);
  MoveChar(B,' ',C,Size.X);
  for i:=0 to Size.Y-1 do WriteLine(0,i,Size.X,1,B);
  for i:=0 to 2 do for j:=0 to 2 do Case Morpion[i,j] of
    0:WriteStr(i*2,j*2,' ',1);
    1:WriteStr(i*2,j*2,'O',1);
    2:WriteStr(i*2,j*2,'X',1);
  end;
end;

Constructor TFenetre.Init;
var R:TRect;
begin
  DeskTop^.GetExtent(R);
  {R.A.X:=1;
  R.A.Y:=1;
  R.B.X:=8;
  R.B.Y:=8;}
  TWindow.Init(R,'Et nianiania',5);
  Options:=Options or ofTileAble;
  GetExtent(R);
  R.Grow(-1,-1);
  Arena:=New(PBoiboite,Init(R));
  Insert(Arena);
end;

Procedure TNewApp.InitStatusLine;
var Bounds:TRect;
begin
  GetExtent(Bounds);
  Bounds.A.Y:=Bounds.B.Y-1;
  StatusLine:=New(PStatusLine,Init(Bounds,NewStatusDef(HCNoContext,HCdragging,
  NewStatusKey('~Alt-X~ Quitter',kbAltX,cmQuit,
  NewStatusKey('~G~a~g~a~g~a',kbnokey,cmWindow,Nil)),NewStatusDef(650,700,
  NewStatusKey('You win!!!',kbNokey,cmNothing,Nil),Nil))));
end;

Procedure TNewApp.HandleEvent(var Event:TEvent);
var Nbr:LongInt;S:string;W:PWindow;R:TRect;
begin
  TApplication.HandleEvent(Event);
  Case Event.What of
    EvCommand:Case Event.Command of
      cmBip:Write(#7);
      cmMessage:begin
        Nbr:=MessageBox('Trying to know what does the function MessageBox sends',Nil,
        mfOKButton+mfNoButton+mfYesButton);
        FormatStr(S,'The Result is %d',Nbr);
        MessageBox(S,Nil,mfInformation);
      end;
      cmWindow:begin
        W:=New(PFenetre,Init);
        if W<>Nil then DeskTop^.Insert(W);
      end else Exit;
    end;
    else Exit;
  end;
  ClearEvent(Event);
end;

{Close=Cancel=11 Yes=12 No=13 Ok=10}

var
  Machin:TNewApp;


begin
  Machin.Init;
  Machin.Run;
  Machin.Done;
end.