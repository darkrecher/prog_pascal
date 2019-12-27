Unit Menu;

Interface

Uses Graph,Dos,Crt;

Type
  PItemProc=Procedure;
  PItem=^TItem;
  PMenu=^TMenu;
  TMenu=Record
    Pos:PItem;
    Prem:PItem;
  end;

  Titem=Record
    Nom:String;
    Suivant:Pitem;
    SousMenu:PMenu;
    Proc:PitemProc;
    Enable:Boolean;
  end;

  Characters=Set of Char;

Procedure InitMouse;
Procedure HideMouse;
Procedure ShowMouse;
Procedure GetPosition(var X,Y:Integer);
Procedure DestroyMenu(Menu:PMenu);
Procedure Box(X,Y:Integer;Text:String);
Procedure PutBox(X,Y:Integer;Text:String;var Larg,Haut:Integer;var P:Pointer);
Procedure RemovBox(X,Y,Larg,Haut:Integer;var P:Pointer);
Function Bouton(Button:Integer):Boolean;
Function InitMenu(APrem:PItem):PMenu;
Function InitItem(ANom:String;AProc:PItemProc;ASousMenu:PMenu;ASuivant:PItem):PItem;
Function ExMenu(Menu:PMenu;X,Y:Integer):Boolean;
Function AskChain(BoxX,BoxY,X2,Y2,LMax,Size:Integer;Text:String;Chars:Characters;var Result:String):Boolean;

implementation

Type
  TRect=Record
    X1,X2,Y1,Y2:Integer;
  end;

Const
  MouseExists:Boolean=False;

Procedure InitMouse;
Var Reg:Registers;
begin
  Reg.AX:=$0000;
  Intr($33,Reg);
  if Reg.AX=$FFFF then begin
    Reg.AX:=$0001;
    Intr($33,Reg);
    MouseExists:=True;
  end;
end;

Procedure HideMouse;
Var Reg:Registers;
begin
  if MouseExists then begin
    Reg.AX:=$0002;
    Intr($33,Reg);
  end;
end;

Procedure ShowMouse;
Var Reg:Registers;
begin
  if MouseExists then begin
    Reg.AX:=$0001;
    Intr($33,Reg);
  end;
end;

Procedure GetPosition(var X,Y:Integer);
Var Reg:Registers;
begin
  if MouseExists then begin
    Reg.AX:=$0003;
    Intr($33,Reg);
    X:=Reg.CX;
    Y:=Reg.DX;
  end else begin
    X:=-1;
    Y:=-1;
  end;
end;

Function Bouton(Button:Integer):Boolean;
Var Reg:Registers;
begin
  if MouseExists then begin
    Reg.AX:=$0003;
    Intr($33,Reg);
    Bouton:=Reg.BX and (1 shl (Button-1))>0;
  end else Bouton:=False;
end;

Function InitMenu(APrem:PItem):PMenu;
var Menunu:PMenu;
begin
  New(Menunu);
  Menunu^.Prem:=Aprem;
  Menunu^.Pos:=Aprem;
  InitMenu:=Menunu;
end;

Function InitItem(ANom:String;AProc:PItemProc;ASousMenu:PMenu;ASuivant:PItem):PItem;
Var Itemtem:PItem;
begin
  New(Itemtem);
  With Itemtem^ do begin
    Nom:=ANom;
    Proc:=AProc;
    SousMenu:=ASousMenu;
    Suivant:=ASuivant;
    Enable:=True;
  end;
  InitItem:=Itemtem;
end;

Procedure DestroyMenu(Menu:PMenu);
Var P:PItem;
begin
  While Menu^.Prem<>Nil do begin
    P:=Menu^.Prem;
    Menu^.Prem:=Menu^.Prem^.Suivant;
    if P^.SousMenu<>Nil then DestroyMenu(P^.SousMenu);
    Dispose(P);
  end;
  Dispose(Menu);
end;

Procedure GetSize(Menu:PMenu;Var X,Y:Integer);
Var P:PItem;Longueur:Integer;
begin
  P:=Menu^.Prem;
  X:=0;
  Y:=14;
  While P<>Nil do begin
    if P^.Nom='' then Y:=Y+5 else Y:=Y+10;
    Longueur:=Length(P^.Nom);
    if P^.SousMenu<>Nil then Longueur:=Longueur+2;
    if Longueur>X then X:=Longueur;
    P:=P^.Suivant;
  end;
  X:=X*8+16;
end;

Procedure GetCoord(Menu:PMenu;Item:PItem;X,Y:Integer;var R:TRect);
Var P:PItem; i:Integer;
begin
  P:=Menu^.Prem;
  i:=8;
  While P<>Item do begin
    if P^.Nom='' then i:=i+5 else i:=i+10;
    P:=P^.Suivant;
  end;
  R.X1:=X+4;
  GetSize(Menu,R.X2,R.Y2);
  R.X2:=X+R.X2-4;
  R.Y1:=Y+i;
  if P^.Nom='' then R.Y2:=Y+i+4 else R.Y2:=Y+i+9;
end;

Procedure AffichMenu(Menu:PMenu;X,Y:Integer);
Var P:PItem;YY,Longueur:Integer;R:TRect;
begin
  HideMouse;
  SetColor(15);
  GetCoord(Menu,Menu^.Pos,X,Y,R);
  GetSize(Menu,Longueur,YY);
  SetFillStyle(1,1);
  Bar(X,Y,X+Longueur,Y+YY);
  Rectangle(X,Y,X+Longueur,Y+YY);
  SetFillStyle(1,2);
  Bar(R.X1,R.Y1,R.X2,R.Y2);
  YY:=Y;
  P:=Menu^.Prem;
  While P<>Nil do begin
    if P^.Nom='' then Line(X,YY+10,X+Longueur,YY+10) else OutTextXY(X+8,YY+9,P^.Nom);
    if P^.SousMenu<>Nil then OutTextXY(X+8+Length(P^.Nom)*8,YY+8,' '+#16);
    if P^.Nom='' then YY:=YY+5 else YY:=YY+10;
    P:=P^.Suivant;
  end;
  ShowMouse;
end;

Function Suiv(Menu:PMenu;Item:PItem):PItem;
Var P:PItem;
begin
  P:=Item^.Suivant;
  if P=Nil then P:=Menu^.Prem;
  Suiv:=P;
end;

Function Prec(Menu:PMenu;Item:PItem):PItem;
Var P:PItem;
begin
  P:=Menu^.Prem;
  While Suiv(Menu,P)<>Item do P:=Suiv(Menu,P);
  Prec:=P;
end;

Function ExMenu(Menu:PMenu;X,Y:Integer):Boolean;
Var
  Clavier:Char;
  R:TRect;
  P:Pointer;
  Item,Ancien:PItem;
  MouseX,MouseY,AjustX,AjustY:Integer;
  Tut,ClickOut:Boolean;
  Larg,Haut:Integer;
begin
  GetSize(Menu,Larg,Haut);
  if X+Larg>639 then AjustX:=639-X-Larg else AjustX:=0;
  if Y+Haut>479 then AjustY:=479-Y-Haut else AjustY:=0;
  GetMem(P,ImageSize(0,0,Larg,Haut));
  HideMouse;
  GetImage(X+AjustX,Y+AjustY,X+Larg+AjustX,Y+Haut+AjustY,P^);
  ShowMouse;
  Ancien:=Nil;
  Tut:=False;
  Repeat
    if Ancien<>Menu^.Pos then begin
      AffichMenu(Menu,X+AjustX,Y+AjustY);
      Ancien:=Menu^.Pos;
    end;
    if KeyPressed then Clavier:=Readkey else Clavier:=#255;
    if Bouton(1) then begin
      Tut:=True;
      Item:=Menu^.Prem;
      ClickOut:=True;
      While Item<>Nil do begin
        GetCoord(Menu,Item,X+AjustX,Y+AjustY,R);
        GetPosition(MouseX,MouseY);
        if (MouseX>=R.X1) and (MouseX<=R.X2) and (MouseY>=R.Y1) and (MouseY<=R.Y2) then begin
          Menu^.Pos:=Item;
          ClickOut:=False;
        end;
        Item:=Item^.Suivant;
      end;
      if ClickOut=True then Clavier:=#27;
    end else if Tut then begin
      Tut:=False;
      Clavier:=#13;
    end;
    if Clavier=#27 then ExMenu:=False;
    if Clavier=#13 then with Menu^.Pos^ do begin
      if @Proc<>Nil then Proc;
      if Sousmenu<>Nil then begin
        GetCoord(Menu,Menu^.Pos,X+AjustX,Y+AjustY,R);
        if ExMenu(SousMenu,R.X1+8,R.Y2) then begin
          Clavier:=#27;
          ExMenu:=True;
        end;
      end else begin
        Clavier:=#27;
        ExMenu:=True;
      end;
    end;
    if Clavier=#0 then begin
      Clavier:=Readkey;
      Case Clavier of
        #72:Repeat Menu^.Pos:=Prec(Menu,Menu^.Pos); Until Menu^.Pos^.Nom<>'';
        #80:Repeat Menu^.Pos:=Suiv(Menu,Menu^.Pos); Until Menu^.Pos^.Nom<>'';
      end;
    end;
  Until Clavier=#27;
  HideMouse;
  PutImage(X+AjustX,Y+AjustY,P^,NormalPut);
  ShowMouse;
  FreeMem(P,ImageSize(0,0,Larg,Haut));
end;

Procedure GetBoxSize(Text:String;Var X,Y:Integer);
Var Largeur,Hauteur,i,Taille:Integer;Special:Boolean;
begin
  Largeur:=0;
  Hauteur:=0;
  Taille:=0;
  Special:=False;
  for i:=1 to Length(Text) do begin
    if Text[i]='\' then begin
      if Special=True then begin
        Inc(Taille);
        if Taille>Largeur then Inc(Largeur);
        Special:=False;
      end else Special:=True;
    end else begin
      if Special=True then begin
        Case Text[i] of
          'l':begin
            Inc(Hauteur);
            Taille:=0;
            Special:=False;
          end;
          '0'..'9':;
          'c':Special:=False;
          else begin
            Inc(Taille);
            if Taille>Largeur then Inc(Largeur);
            Special:=False;
          end;
        end;
      end else begin
        Inc(Taille);
        if Taille>Largeur then Inc(Largeur);
      end;
    end;
  end;
  X:=Largeur*8+16;
  Y:=Hauteur*10+24;
end;

Procedure PutBox(X,Y:Integer;Text:String;var Larg,Haut:Integer;var P:Pointer);
Var i,YY,XX,Color,AjustX,AjustY:Integer;Special:Boolean;S:String;
begin
  While KeyPressed do ReadKey;
  HideMouse;
  GetBoxSize(Text,Larg,Haut);
  if Larg+X>639 then AjustX:=639-Larg-X else AjustX:=0;
  if Haut+Y>479 then AjustY:=479-Haut-Y else AjustY:=0;
  GetMem(P,ImageSize(0,0,Larg,Haut));
  GetImage(X+AjustX,Y+AjustY,X+Larg+AjustX,Y+Haut+AjustY,P^);
  SetFillStyle(1,1);
  Bar(X+AjustX,Y+AjustY,X+Larg+AjustX,Y+Haut+AjustY);
  SetColor(15);
  Rectangle(X+AjustX,Y+AjustY,X+Larg+AjustX,Y+Haut+AjustY);
  S:='';
  YY:=Y+AjustY+8;
  XX:=X+AjustX+8;
  Color:=0;
  Special:=False;
  for i:=1 to Length(Text) do begin {\l:aller Ö la ligne}
    if Text[i]='\' then begin       {\Xc:SetColor(X)}
      if Special=True then begin    {\\:ecrire le caractäre \}
        S:=S+'\';
        Special:=False;
      end else begin
        Special:=True;
        OutTextXY(XX,YY,S);
        XX:=Length(S)*8+XX;
        S:='';
        Color:=0;
      end;
    end else begin
      if Special=True then begin
        Case Text[i] of
          'l':begin
            YY:=YY+10;
            XX:=X+AjustX+8;
            Special:=False;
            S:='';
          end;
          '0'..'9':Color:=Color*10+Byte(Text[i])-48;
          'c':if Color<16 then begin
            SetColor(Color);
            Special:=False;
            S:='';
          end;
          else begin
            S:=S+Text[i];
            Special:=False;
          end;
        end;
      end else S:=S+Text[i];
    end;
  end;
  OutTextXY(XX,YY,S);
  ShowMouse;
end;

Procedure RemovBox(X,Y,Larg,Haut:Integer;var P:Pointer);
var AjustX,AjustY:Integer;
begin
  if Larg+X>639 then AjustX:=639-Larg-X else AjustX:=0;
  if Haut+Y>479 then AjustY:=479-Haut-Y else AjustY:=0;
  HideMouse;
  PutImage(X+AjustX,Y+AjustY,P^,NormalPut);
  FreeMem(P,ImageSize(0,0,Larg,Haut));
  ShowMouse;
end;

Function ReadString(X,Y,LMax,Size,BoxX,BoxY,Larg,Haut:Integer;Chars:Characters;var S1:string;var NewX,NewY:Integer):Boolean;
var S2:String;C:Char;i,j,TextCursor,MouseX,MouseY:Integer;Imag:Pointer;
Procedure Affiche;
begin
  if TextCursor>J+Size-1 then J:=TextCursor-Size+1;
  if TextCursor<J+1 then J:=TextCursor-1;
  if J=0 then J:=1;
  HideMouse;
  Bar(X,Y,Size*8+X+16,Y+10);
  OuttextXY(X+8,Y+1,Copy(S1,J,Size));
  if (TextCursor>=J) and (TextCursor<J+Size) then Line(X+(TextCursor-J)*8+8,Y+9,X+(TextCursor-J)*8+15,Y+9);
  if J>1 then OutTextXY(X,Y,#17) else Bar(X,Y,X+7,Y+8);
  if J<Length(S1)-Size+1 then OutTextXY(X+Size*8+8,Y,#16) else Bar(X+Size*8+8,Y,X+Size*8+16,Y+10);
  ShowMouse;
end;
begin
  GetMem(Imag,ImageSize(0,0,Size*8+16,10));
  HideMouse;
  GetImage(X,Y,X+Size*8+16,Y+10,Imag^);
  ShowMouse;
  SetColor(0);
  SetFillStyle(1,3);
  NewX:=-1;
  S2:='';
  C:=#0;
  j:=1;
  TextCursor:=Length(S1)+1;
  Affiche;
  Repeat
    if KeyPressed then begin
      C:=ReadKey;
      Case C of
        #8:if TextCursor>1 then begin
          S2:='';
          for i:=1 to Length(S1) do if i<>TextCursor-1 then S2:=S2+S1[i];
          S1:=S2;
          TextCursor:=TextCursor-1
        end;
        #0:begin
          C:=Readkey;
          Case C of
            #83:begin
              S2:='';
              for i:=1 to Length(S1) do if i<>TextCursor then S2:=S2+S1[i];
              S1:=S2;
            end;
            #75:if TextCursor>1 then TextCursor:=TextCursor-1;
            #77:if TextCursor<Length(S1)+1 then TextCursor:=TextCursor+1;
            #71:TextCursor:=1;
            #79:TextCursor:=Length(S1)+1;
          end;
        end;
        else if (C in Chars-[#13,#27]) and (Length(S1)<LMax) then begin
          Insert(C,S1,TextCursor);
          Inc(TextCursor);
        end;
      end;
      Affiche;
    end;
    Repeat
      if Bouton(1) then begin
        GetPosition(MouseX,MouseY);
        if (MouseX>X) and (MouseX<X+Size*8+16) and (MouseY>Y) and (MouseY<Y+10) then begin
          if (MouseX>X) and (MouseX<X+8) and (MouseY>Y) and (MouseY<Y+8) then if J>1 then begin
            Dec(J);
            Dec(TextCursor);
          end else TextCursor:=1;
          if (MouseX>X+Size*8+8) and (MouseX<X+Size*8+16) and (MouseY>Y) and (MouseY<Y+8) then if J<Length(S1)-Size then begin
            Inc(J);
            Inc(TextCursor);
          end else TextCursor:=Length(S1)+1;
          if (MouseX>X+8) and (MouseX<X+Size*8+8) and (MouseY>Y) and (MouseY<Y+10) then TextCursor:=J+Trunc((MouseX-X-8)/8);
          if KeyPressed then Readkey;
          Affiche;
          Delay(200);
        end else if (MouseX>BoxX) and (MouseX<BoxX+Larg) and (MouseY>BoxY) and (MouseY<BoxY+10) then begin
          HideMouse;
          SetWriteMode(1);
          SetColor(15);
          Repeat
            GetPosition(MouseX,MouseY);
            if 639-MouseX<Larg then MouseX:=639-Larg;
            if 479-MouseY<Haut then MouseY:=479-Haut;
            if (MouseX<>NewX) or (MouseY<>NewY) then begin
              if NewX<>-1 then Rectangle(NewX,NewY,NewX+Larg,NewY+Haut);
              Rectangle(MouseX,MouseY,MouseX+Larg,MouseY+Haut);
              NewX:=MouseX;
              NewY:=MouseY;
            end;
          Until not(Bouton(1));
          if 639-NewX<Larg then NewX:=639-Larg;
          if 479-NewY<Haut then NewY:=479-Haut;
          C:=#13;
          Rectangle(NewX,NewY,NewX+Larg,NewY+Haut);
          SetWriteMode(0);
          ShowMouse;
        end;
      end;
    Until not(Bouton(1));
  Until (C=#13) or (C=#27);
  if C=#13 then ReadString:=True else ReadString:=False;
  HideMouse;
  PutImage(X,Y,Imag^,NormalPut);
  ShowMouse;
  FreeMem(Imag,ImageSize(0,0,Size*8+16,10));
end;

Procedure Box(X,Y:Integer;Text:String);
var P:Pointer;Larg,Haut:Integer;
begin
  PutBox(X,Y,Text,Larg,Haut,P);
  Repeat
    Delay(1);
  Until KeyPressed or Bouton(1) or Bouton(2);
  if KeyPressed then ReadKey;
  RemovBox(X,Y,Larg,Haut,P);
end;

  {DES PATES! DES PATES! DES PATES! DES PATES!
  MAIS Y EN A MARRE A LA FIN!!!
  NON MAIS LA JE RIGOLE PLUS!! TOUTES MES BELLES PATES ELLE}

Function AskChain(BoxX,BoxY,X2,Y2,LMax,Size:Integer;Text:String;Chars:Characters;var Result:String):Boolean;
var P:Pointer;Larg,Haut,NewX,NewY,OldX,OldY:Integer;
begin
  GetBoxSize(Text,Larg,Haut);
  if Larg+BoxX>639 then Larg:=639-Larg-BoxX else Larg:=0;
  if Haut+BoxY>479 then Haut:=479-Haut-BoxY else Haut:=0;
  NewX:=BoxX+Larg;
  NewY:=BoxY+Haut;
  Repeat
    OldX:=NewX;
    OldY:=NewY;
    PutBox(OldX,OldY,Text,Larg,Haut,P);
    AskChain:=ReadString(OldX+X2-BoxX,OldY+Y2-BoxY,LMax,Size,OldX,OldY,Larg,Haut,Chars,Result,NewX,NewY);
    RemovBox(OldX,OldY,Larg,Haut,P);
  Until NewX=-1;
end;

end.
