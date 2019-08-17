Uses KeyBoard,Graph,Crt,Menu;

Type
  PElement=^TElement;
  Telement=Record
    X,Y,Z:Integer;
    Move:Boolean;
    id:LongInt;
    Suivant:PElement;
  end;

  LPElement=^LTElement;  {L stands for Ligne}
  LTElement=Record
    Point1,Point2:LongInt;
    Couleur:Byte;
    Suivant:LPelement;
  end;

Const
Colors:Array[1..15] of String=('bleu','vert','cyan','rouge','violet','marron','gris','gris',
'bleu','vert','cyan','rouge','rose','jaune','blanc');


Var
  MainMenu:PMenu;
  Premier,P,Suprimator:PElement;
  LPremier,LP,LSuprimator,LProut:LPElement;
  Compteur:LongInt;
  Clavier:Char;
  MouseX,MouseY:Integer;
  JustOnce:Boolean;

Procedure GraphVGA;
var Driver,Mode:Integer;
begin
  Driver:=9;
  Mode:=2;
  InitGraph(Driver,Mode,'c:\bp\bgi');
end;

Procedure FadeText(X,Y:Integer; Chaine:String);
var i:Integer;
begin
  for i:=1 to Length(Chaine)+2 do begin
    if i<Length(Chaine) then begin
      SetColor(8);
      OutTextXY(X+i*8-8,Y,Chaine[i]);
    end;
    if (i>1) and (i<Length(Chaine)-1) then begin
      SetColor(7);
      OutTextXY(X+i*8-16,Y,Chaine[i-1]);
    end;
    if i>2 then begin
      SetColor(15);
      OutTextXY(X+i*8-24,Y,Chaine[i-2]);
    end;
    Delay(80);
    if KeyPressed then begin
      Readkey;
      SetColor(15);
      i:=Length(Chaine)+2;
      OutTextXY(X,Y,Chaine);
    end;
  end;
end;

Function NewStr(Nbr:Integer):String;
var S:String;
begin
  Str(Nbr,S);
  NewStr:=S;
end;

Function NewVal(S:String):LongInt;
var Nbr:LongInt;Code:Integer;
begin
  Val(S,Nbr,Code);
  if Code=0 then NewVal:=Nbr;
end;

Procedure Projett(var X,Y:Integer);
begin
  X:=Round(500/(100+P^.Z)*P^.X);
  Y:=Round(500/(100+P^.Z)*P^.Y);
end;

Procedure AffichNbr;
var X,Y:Integer;
begin
  HideMouse;
  P:=Premier;
  SetColor(12);
  While P<>Nil do begin
    Projett(X,Y);
    OutTextXY(X+320,Y+231,NewStr(P^.id));
    P:=P^.Suivant;
  end;
  ShowMouse;
end;

Function Supprime(ident:Integer):Boolean;
var Error:Boolean;
begin
  P:=Premier;
  Suprimator:=Premier;
  Error:=True;
  if Premier^.id=ident then begin
    Premier:=Premier^.Suivant;
    Dispose(Suprimator);
    Suprimator:=Nil;
    Error:=False;
  end;
  While Suprimator<>Nil do begin
    Suprimator:=Suprimator^.Suivant;
    if Suprimator^.id=ident then begin
      if P^.Suivant^.Suivant=Nil then P^.Suivant:=Nil
      else P^.Suivant:=P^.Suivant^.Suivant;
      Dispose(Suprimator);
      Error:=False;
      Suprimator:=Nil;
    end;
    P:=P^.Suivant;
  end;
  Supprime:=Error;
end;

Function LSupprime(Pt1,Pt2:LongInt):Boolean;
var Error:Boolean;
begin
  LP:=LPremier;
  LSuprimator:=LPremier;
  Error:=True;
  if (LPremier^.Point1=Pt1) and (LPremier^.Point2=Pt2) then begin
    LPremier:=LPremier^.Suivant;
    Dispose(LSuprimator);
    LSuprimator:=Nil;
    Error:=False;
  end;
  While LSuprimator<>Nil do begin
    LSuprimator:=LSuprimator^.Suivant;
    if (LSuprimator^.Point1=Pt1) and (LSuprimator^.Point2=Pt2) then begin
      if LP^.Suivant^.Suivant=Nil then LP^.Suivant:=Nil
      else LP^.Suivant:=LP^.Suivant^.Suivant;
      Dispose(LSuprimator);
      Error:=False;
      LSuprimator:=Nil;
    end;
    LP:=LP^.Suivant;
  end;
  LSupprime:=Error;
end;

Procedure LSearch(Pt1,Pt2:LongInt);
begin
  LP:=LPremier;
  While (LP<>Nil) and ((LP^.Point1<>Pt1) or (LP^.Point2<>Pt2)) do LP:=LP^.Suivant;
  if LP=Nil then begin
    LP:=LPremier;
    While (LP<>Nil) and ((LP^.Point1<>Pt2) or (LP^.Point2<>Pt1)) do LP:=LP^.Suivant;
  end;
end;

Procedure Search(ident:LongInt);
begin
  P:=Premier;
  While (P<>Nil) and (P^.id<>ident) do P:=P^.Suivant;
end;

Procedure Dessine;
var X1,X2,Y1,Y2:Integer;
begin
  HideMouse;
  if GetColor<>0 then SetColor(15);
  ClearDevice;
  P:=Premier;
  While P<>Nil do begin
    Projett(X1,Y1);
    PutPixel(X1+320,Y1+240,GetColor);
    P:=P^.Suivant;
  end;
  LP:=LPremier;
  While LP<>Nil do begin
    Search(LP^.Point1);
    Projett(X1,Y1);
    Search(LP^.Point2);
    Projett(X2,Y2);
    if GetColor<>0 then SetColor(LP^.Couleur);
    Line(X1+320,Y1+240,X2+320,Y2+240);
    LP:=LP^.Suivant;
  end;
  ShowMouse;
end;

Procedure CreatePoint;
begin
  New(P);            {le nouveau pointeur est cr‚‚ en d‚but de liste}
  P^.Suivant:=Premier;
  Premier:=P;
  Premier^.id:=Compteur;
  Premier^.X:=0;
  Premier^.Y:=0;
  Premier^.Z:=0;
  Compteur:=Compteur+1;
end;

Function AskLigne(var Pt1,Pt2:Longint):Boolean;
var Continue:Boolean;S:String;
begin
  AffichNbr;
  Repeat
    S:='';
    Continue:=AskChain(172,224,460,232,10,4,'Entrez le premier point de la ligne       ',['0'..'9'],S);
    if Continue then begin
      Search(NewVal(S));
      if P=Nil then Box(300,232,'Ce point n''existe pas') else Pt1:=NewVal(S);
    end;
  Until (P<>Nil) or (not(Continue));
  if Continue then Repeat
    S:='';
    Continue:=AskChain(168,224,464,232,10,4,'Entrez le deuxiŠme point de la ligne       ',['0'..'9'],S);
    if Continue then begin
      Search(NewVal(S));
      if P=Nil then Box(300,232,'Ce point n''existe pas') else Pt2:=NewVal(s);
    end;
  Until (P<>Nil) or (not(Continue));
  AskLigne:=Continue;
end;

{$f+}
Procedure NewPoint;
begin
  CreatePoint;
  Box(5,224,'Le point num‚ro '+NewStr(Compteur-1)+' a ‚t‚ cr‚‚ aux coordonn‚es 0,0,0\l      (au milieu de l''‚cran)');
end;


Procedure ReadCoord;
var S:String;
begin
  if Premier=Nil then Box(300,232,'Vous n''avez aucun point') else begin
    AffichNbr;
    S:='';
    if AskChain(50,220,570,228,10,4,'Entrez le num‚ro du point dont vous voulez voir les coordonn‚es       ',['0'..'9'],S)
    then begin
      Search(NewVal(S));
      if P=Nil then Box(320,232,'Ce point n''existe pas')
      else Box(300,210,'X:'+NewStr(P^.X)+'\lY:'+NewStr(P^.Y)+'\lZ:'+NewStr(P^.Z));
    end;
  end;
end;

Procedure SetCoord;
var S:String;X,Y,Z:Integer;
begin
  if Premier=Nil then Box(300,228,'Vous n''avez aucun point') else begin
    AffichNbr;
    S:='';
    if AskChain(250,224,318,232,10,4,'Entrez le num‚ro du point dont vous voulez modifier les coordonn‚es       ',['0'..'9'],S)
    then begin
      Search(NewVal(S));
      if P=Nil then Box(300,228,'Ce point n''existe pas')
      else begin
        S:='';
        if AskChain(275,224,435,232,10,4,'X:'+NewStr(P^.X)+' Y:'+NewStr(P^.Y)+' Z:'+NewStr(P^.Z)+
        '\lEntrez l''abscisse       ',['0'..'9'],S) then begin
          X:=NewVal(S);
          S:='';
          if AskChain(275,224,443,232,10,4,'X:'+NewStr(P^.X)+' Y:'+NewStr(P^.Y)+' Z:'+NewStr(P^.Z)+
          '\lEntrez l''ordonn‚e       ',['0'..'9'],S) then begin
            Y:=NewVal(S);
            S:='';
            if AskChain(275,224,459,232,10,4,'X:'+NewStr(P^.X)+' Y:'+NewStr(P^.Y)+' Z:'+NewStr(P^.Z)+
            '\lEntrez la Zordonn‚e       ',['0'..'9'],S) then begin
              Z:=NewVal(S);
              P^.X:=X;
              P^.Y:=Y;
              P^.Z:=Z;
            end;
          end;
        end;
      end;
    end;
  end;
end;

Procedure SupLine;
var Point1,Point2:LongInt;
begin
  if LPremier=Nil then Box(300,228,'Vous n''avez aucune ligne') else begin
    if AskLigne(Point1,Point2) then begin
      LSearch(Point1,Point2);
      if LP=Nil then Box(300,232,'La ligne n''existe pas') else begin
        LSupprime(Point1,Point2);
        LSupprime(Point2,Point1);
      end;
    end;
  end;
end;

Procedure SupPoint;
var S:String;Wait:Boolean;Point,Pt1,Pt2:LongInt;
begin
  if Premier=Nil then Box(300,232,'Vous n''avez aucun point') else begin
    AffichNbr;
    S:='';
    if AskChain(275,224,555,232,10,4,'Quel point voulez-vous supprimer?       ',['0'..'9'],S) then begin
      if Supprime(NewVal(S)) then Box(300,232,'Ce point n''existe pas') else begin
        Point:=NewVal(S);
        LProut:=LPremier;
        Wait:=True;
        While LProut<>Nil do begin
          if (LProut^.Point1=Point) or (LProut^.Point2=Point) then begin
            LProut^.Point1:=Pt1;
            LProut^.Point2:=Pt2;
            LProut:=LProut^.Suivant;
            Wait:=LSupprime(Pt1,Pt2);
          end;
          if Wait then LProut:=LProut^.Suivant else Wait:=True;
        end;
      end;
    end;
  end;
end;

Procedure NewLine;
var Point1,Point2,i:LongInt;Text,S:String;
begin
  if Compteur<2 then Box(250,224,'Il vous faut au moins 2 points pour avoir une ligne') else begin
    if AskLigne(Point1,Point2) then begin
      LSearch(Point1,Point2);
      if LP<>Nil then begin
        Box(280,224,'Il y a d‚j… une ligne entre ces deux points\lMais vous pouvez changer sa couleur');
        Text:='Entrez le nouveau code de la couleur\l\l\l';
      end else Text:='Entrez le code de la couleur (un nombre entre 1 et 15)\l\l\l';
      Text:=Text+'\0c1:'+Colors[i]+' ';
      for i:=2 to 15 do begin
        Text:=Text+'\'+NewStr(i)+'c'+NewStr(i)+':'+Colors[i]+' ';
        if i mod 5=0 then Text:=Text+'\l';
      end;
      Dec(Text[0],2);
      Repeat
        S:='';
        if AskChain(132,206,300,224,2,3,Text,['0'..'9'],S)=False then S:='gaga'
        else if (NewVal(S)>15) or (NewVal(S)<1) then Box(250,232,'Imb‚cile!! On vous a dit un nombre entre 1 et 15!!!');
      Until ((NewVal(S)<16) and (NewVal(S)>0)) or (S='gaga');
      if S<>'gaga' then begin
        if LP=Nil then begin
          New(LP);
          LP^.Suivant:=LPremier;
          LPremier:=LP;
          LPremier^.point1:=Point1;
          LPremier^.point2:=Point2;
          LPremier^.Couleur:=NewVal(S);
        end else LP^.Couleur:=NewVal(S);
      end;
    end;
  end;
end;

Procedure Save;
var A,B,C:LongInt;S:String;Points,Lines:File of LongInt;BoxP:Pointer;BoxLarg,BoxHaut:Integer;
begin
  if Premier=Nil then Box(275,232,'Vous n''avez vraiment rien du tout … sauvegarder\l     il n''y a que le n‚ant') else begin
    S:='';
    Clavier:='z';
    if AskChain(200,224,512,232,8,8,'Entrez le nom du fichier de sauvegarde           ',['a'..'z']+['0'..'9'],S) then begin
      if S='' then Box(176,228,'nom invalide(mettez quelque chose!!!)') else begin
        Assign(Points,S+'.pts');
        {$i-}
          Reset(Points);
        {$i+}
        if IOResult=0 then begin
          PutBox(250,232,'Le fichier '+S+' existe d‚j…, voulez vous l''‚craser(Splatch!!)',BoxLarg,BoxHaut,BoxP);
          Repeat
            if KeyPressed then Clavier:=Readkey;
          Until (Clavier='y') or (Clavier='o') or (Clavier='n');
          RemovBox(250,232,BoxLarg,BoxHaut,BoxP);
        end;
        if Clavier<>'n' then begin
          Rewrite(Points);
          P:=Premier;
          While P<>Nil do begin
            A:=P^.X;
            B:=P^.Y;
            C:=P^.Z;
            Write(Points,P^.id,A,B,C);
            P:=P^.Suivant;
          end;
          Close(Points);
          LP:=LPremier;
          Assign(Lines,S+'.lin');
          Rewrite(Lines);
          While LP<>Nil do begin
            A:=LP^.Couleur;
            Write(Lines,LP^.Point1,LP^.Point2,A);
            LP:=LP^.Suivant;
          end;
          Close(Lines);
        end;
      end;
    end;
  end;
end;

Procedure Load;
var S:String;Points,Lines:File of LongInt;a,b,c,d:LongInt;
begin
  S:='';
  if AskChain(144,224,504,232,8,8,'Entrez le nom de votre fichier de sauvegarde           ',['a'..'z']+['0'..'9'],S) then begin
    Assign(Points,S+'.pts');
    {$i-}
      Reset(Points);
    {$i+}
    if IOResult=0 then begin
      While EoF(Points)=False do begin
        Read(Points,a,b,c,d);
        CreatePoint;
        Premier^.id:=a;
        Premier^.X:=b;
        Premier^.Y:=c;
        Premier^.Z:=d;
      end;
      Close(Points);
      Assign(Lines,S+'.lin');
      Reset(Lines);
      While EoF(Lines)=False do begin
        Read(Lines,a,b,c);
        New(LP);
        LP^.Suivant:=LPremier;
        LPremier:=LP;
        LPremier^.point1:=a;
        LPremier^.point2:=b;
        LPremier^.Couleur:=c;
      end;
      Close(Lines);
    end else Box(224,228,'Ce fichier n''existe pas');
  end;
end;

Procedure MovePoint;
var X,Y:Integer;FirstTime,Continue:Boolean;Text,S:String;
begin
  if Premier=Nil then Box(176,228,'Vous n''avez auncun point … d‚placer') else begin
    P:=Premier;
    AffichNbr;
    While P<>Nil do begin
      P^.Move:=False;
      P:=P^.Suivant;
    end;
    Text:='Entrez le num‚ro d''un point … d‚placer:\l\lAppuyez sur Entr‚e sans rien ‚crire ';
    FirstTime:=True;
    Repeat;
      S:='';
      if FirstTime then Continue:=AskChain(225,220,561,228,10,4,Text+'si vous voulez d‚placer tout les points',['0'..'9'],S)
      else Continue:=AskChain(225,220,561,228,10,4,Text+'pour d‚placez les points s‚lectionn‚s',['0'..'9'],S);
      if Continue and (S<>'') then begin
        Search(NewVal(S));
        if P=Nil then Box(300,224,'Ce point n''existe pas') else begin
          SetColor(10);
          Projett(X,Y);
          OutTextXY(X+320,Y+231,S);
          P^.Move:=True;
          FirstTime:=False;
        end;
      end;
    Until (S='') or (Continue=False);
    if Continue then begin
      if FirstTime then begin
        P:=Premier;
        While P<>Nil do begin
          P^.Move:=True;
          P:=P^.Suivant;
        end;
      end;
      SetColor(15);
      Dessine;
      if JustOnce then begin
        Box(52,216,'Utilisez les flŠches droite et gauche pour bouger horizontalement\l'+
        'les flŠches haut et bas pour ‚loigner et rapprocher\l"e" et "d" pour bouger verticalement\l'+
        'Appuyez sur Echap quand vous avez fini');
        JustOnce:=False;
      end;

      HideMouse;
      AdvKeyOn;
      K_Esc:=False;
      K_Enter:=False;
      K_Space:=False;
      Repeat
        if (K_Up) or (K_Down) or (K_Left) or (K_Right) or (K_E) or (K_D) then begin
          SetColor(0);
          Dessine;
          if (K_Up) then begin
            P:=Premier;
            While P<>Nil do begin
              if P^.Move=True then P^.Z:=P^.Z+1;
              P:=P^.Suivant;
            end;
          end;
          if (K_Down) then begin
            P:=Premier;
            While P<>Nil do begin
              if (P^.Move=True) and (P^.Z>-99) then P^.Z:=P^.Z-1;
              P:=P^.Suivant;
            end;
          end;
          if (K_Left) then begin
            P:=Premier;
            While P<>Nil do begin
              if P^.Move=True then P^.X:=P^.X-1;
              P:=P^.Suivant;
            end;
          end;
          if (K_Right) then begin
            P:=Premier;
            While P<>Nil do begin
              if P^.Move=True then P^.X:=P^.X+1;
              P:=P^.Suivant;
            end;
          end;
          if (K_E) then begin
            P:=Premier;
            While P<>Nil do begin
              if P^.Move=True then P^.Y:=P^.Y-1;
              P:=P^.Suivant;
            end;
          end;
          if (K_D) then begin
            P:=Premier;
            While P<>Nil do begin
              if P^.Move=True then P^.Y:=P^.Y+1;
              P:=P^.Suivant;
            end;
          end;
          SetColor(15);
          Dessine;
          Delay(10);
        end;
      Until (K_Esc) or (K_Space) or (K_Enter);
      P:=Premier;
      While P<>Nil do begin
        P^.Move:=False;
        P:=P^.Suivant;
      end;
      AdvKeyOff;
      ShowMouse;
    end;
  end;
end;
{$f-}

begin
  GraphVGA;
  ClearDevice;
  Premier:=Nil;
  LPremier:=Nil;
  Compteur:=0;
  JustOnce:=True;
  MainMenu:=InitMenu(
    InitItem('Points',Nil,InitMenu(
      InitItem('Ajouter',NewPoint,Nil,
      InitItem('Supptimer',SupPoint,Nil,Nil))),
    InitItem('Lignes',Nil,InitMenu(
      InitItem('Ajouter',NewLine,Nil,
      InitItem('Supprimer',SupLine,Nil,Nil))),
    InitItem('Coordonn‚es d''un point',Nil,InitMenu(
      InitItem('Lire',ReadCoord,Nil,
      InitItem('Modifiez',SetCoord,Nil,Nil))),
    InitItem('Deplacer des points',MovePoint,Nil,
    InitItem('',Nil,Nil,
    InitItem('Sauvegarder',Save,Nil,
    InitItem('Charger',Load,Nil,Nil))))))));
    FadeText(156,215,'L''‚cran est noir, il n''y a que le n‚ant');
    FadeText(80,225,'Mon dieu, que suis-je cens‚(e) faire? Il n''y a que le vide!');
    FadeText(32,235,'Mais comme nous sommes indulgent, on va vous donner un curseur de souris');
    FadeText(16,245,'Si vous ˆtes intelligent(e), vous pourrez essayer d''appuyer sur les boutons');
    FadeText(12,255,'Mais si vous en avez assez de ce n‚ant, appuyez sur Echap et retournez au lit');
    FadeText(24,275,'pour enlever tout ce texte inutile, donnez un coup de poing sur le clavier');
    Readkey;
    ClearDevice;
    InitMouse;
  Repeat
    if Bouton(2) then begin
      GetPosition(MouseX,MouseY);
      ExMenu(MainMenu,MouseX,MouseY);
      SetColor(15);
      Dessine;
    end;
    if KeyPressed then begin
      Clavier:=Readkey;
      if Clavier<>#27 then begin
        ExMenu(MainMenu,0,0);
        SetColor(15);
        Dessine;
        Clavier:=#254;
      end;
    end;
  Until Clavier=#27;
  While Premier<>Nil do begin
    P:=Premier;
    Premier:=Premier^.Suivant;
    Dispose(P);
  end;
  While LPremier<>Nil do begin
    LP:=LPremier;
    LPremier:=LPremier^.Suivant;
    Dispose(LP);
  end;
  DestroyMenu(MainMenu);
  CloseGraph;
end.
