uses Graph,Crt;

type
  Etoiles=record
    X,Y,XEnPlus,YEnPlus:Real;
    Fini:Integer; {Fini:indique depuis combien de temps est apparu l'‚toile}
    Couleur:0..15;
  end;

Var
  Stars:Array[0..1000] of Etoiles;{il y aura un maximum de 1000 ‚toiles … l'‚cran}
  i,Compte:Byte;
  a,b,c,Vitesse,CentreX,CentreY,NbrStars:Integer;
  Action,Previous:Char;
  Nombre:String;
  Texte:LongInt;
  NoirEtBlanc:Boolean;

Procedure NewStar(A:Integer);
begin
  With Stars[A] do
  begin
    XEnPlus:=Random(501);
    YEnPlus:=Random(501);
    XEnPlus:=(XEnPlus-250)/100;
    YEnPlus:=(YEnPlus-250)/100;
    X:=60*XEnPlus+CentreX;
    Y:=60*YEnPlus+CentreY;
    Fini:=0;
    if NoirEtBlanc=False then Couleur:=Random(8);
  end;
end;


procedure AvanceEtoile(Se,CoefX,CoefY:integer); {Se=Special Effect}
begin
  With Stars[i] do begin
    Case Se of
      0:begin
        X:=X+XEnPlus+(Fini/17)*XEnPlus*CoefX;
        Y:=Y+YEnPlus+(Fini/17)*YEnPlus*CoefY;
      end;
      1:begin
        X:=X+XEnPlus+(Fini/17)*XEnPlus*CoefX;
        Y:=Y+YEnPlus+(Fini/17)*XEnPlus*CoefY;
      end;
      2:begin
        X:=X+XEnPlus+(Fini/17)*YEnPlus*CoefX;
        Y:=Y+YEnPlus+(Fini/17)*YEnPlus*CoefY;
      end;
      3:begin
        X:=X+XEnPlus+(Fini/17)*YEnPlus*CoefX;
        Y:=Y+YEnPlus+(Fini/17)*XEnPlus*CoefY;
      end;
    end;
  end;
  a:=Se;
  b:=CoefX;
  c:=CoefY;
end;

begin
  if ParamCount<1 then begin
    Writeln('Vous devez indiquer dans les parametres un nombre');
    Writeln('Qui permettra de regler la vitesse du programme');
    Writeln('plus ce nombre est grand, plus le programme sera lent.');
    Writeln('Exemple: Hypspace 150, Hypspace 0, Hypspace 500...');
    Exit;
  end else begin
    Val (ParamStr(1),Vitesse,a);
    if a<>0 then begin
      Write('Imbecile!!! Vous devez ecrire un nombre!!!');
      Exit;
    end;
    if Vitesse<0 then begin
      Write('Imbecile!!! Il faut mettre un nombre positif!!');
      Exit;
    end;
  end;
  Repeat
    ClrScr;
    Writeln ('Entrez le nombre d''‚toiles.');
    Readln(Nombre);
    Val (Nombre,NbrStars,a);
    if a<>0 then begin
      WriteLn('Imbecile!!! Vous devez ecrire un nombre!!!');
      ReadKey;
    end;
    if NbrStars<0 then begin
      WriteLn('Imbecile!!! Il faut mettre un nombre positif!!');
      a:=666;
      ReadKey;
    end;
    if NbrStars>1000 then begin
      WriteLn('D‚sol‚, mais il est impossible d''avoir plus de 1000 ‚toiles.');
      a:=666;
      ReadKey;
    end;
  Until a=0;
  Repeat
    Clrscr;
    Writeln('Voulez vous des ‚toiles en couleur?');
    Action:=ReadKey;
    Action:=Upcase(Action);
    if Action='O' then NoirEtBlanc:=False;
    if Action='N' then NoirEtBlanc:=True;
  Until (Action='O') or (Action='N');

  Randomize;
  a:=9;
  b:=2;
  InitGraph(a,b,'c:\bp\bgi');
  CentreX:=320;
  CentreY:=240;
  a:=0;
  Compte:=0;
  Action:='0';
  for i:=0 to NbrStars do NewStar(i);
  Texte:=0;
  Repeat
    for i:=0 to NbrStars do With Stars[i] do
    begin
      if Texte<100001 then begin
      Texte:=Texte+1;
      if (Texte=1) or (Texte=25001) or (Texte=50001) or (Texte=75001) then SetColor(15);
      if (Texte=25000) or (Texte=50000) or (Texte=75000) or (Texte=100000) then SetColor(0);
      if (Texte=1) or (Texte=25000) then OutTextXY(100,8,'Les super effets sp‚ciaux made by R‚chŠr Grzmktbq!!!!!');
      if (Texte=25001) or (Texte=50000)
      then OutTextXY(20,8,'Appuyez sur les flŠches pour d‚placer le point de d‚part des ‚toiles');
      if (Texte=50001) or (Texte=75000)
      then OutTextXY(20,8,'Appuyez sur Entr‚e pour remettre le point de d‚part au centre de l''‚cran');
      if (Texte=75001) or (Texte=100000)
      then OutTextXY(50,8,'Appuyez sur les touches de 0 … 9 pour voir les supers effets sp‚ciaux');
    end;
      PutPixel(Round(X),Round(Y),0);
      case Action of
        '0':begin
          AvanceEtoile(0,1,1);
          a:=0;
          b:=1;
          c:=1;
        end;
        '1':AvanceEtoile(0,1,-1);
        '2':AvanceEtoile(1,-1,1);
        '3':AvanceEtoile(3,-1,1);
        '4':begin
          if Compte=1 then
          begin
            a:=Random(4);
            Case a of
              0:begin
                a:=0;
                b:=-1;
                c:=1;
              end;
              1:begin
                a:=0;
                b:=1;
                c:=-1;
              end;
              2:begin
                a:=3;
                b:=1;
                c:=1;
              end;
              3:begin
                a:=3;
                b:=-1;
                c:=-1;
              end;
            end;
          end;
          AvanceEtoile(a,b,c);
          if Compte=100 then Compte:=0;
        end;
        '5':Case Compte of
          0..150:AvanceEtoile(3,1,1);
          151..180:AvanceEtoile(3,-1,-1);
          181..200:AvanceEtoile(3,1,1);
          201..221:AvanceEtoile(3,-1,-1);
          222:Compte:=180;
        end;
        '6':Case Compte of
          0..120:AvanceEtoile(3,1,-1);
          121..240:AvanceEtoile(3,-1,1);
          241:Compte:=0;
        end;
        '7':Case Compte of
          0..127:begin
            X:=X+XEnPlus+(Fini/(128-Compte))*XEnPlus;
            Y:=Y+YEnPlus+(Fini/17)*XEnPlus;
          end;
          128..254:begin
            X:=X+XEnPlus+(Fini/(Compte-127))*XEnPlus;
            Y:=Y+YEnPlus+(Fini/17)*XEnPlus;
          end;
          255:Compte:=0;
        end;
        '8':Case Compte of
          0..50:AvanceEtoile(0,1,1);
          51..150:AvanceEtoile(0,1,1);
          151..250:AvanceEtoile(0,-1,-1);
          251:Compte:=50;
        end;
        '9':begin
          if Compte=1 then begin
            a:=Random(4);
            Repeat
              b:=Random(3)-1;
            Until b<>0;
            Repeat
              c:=Random(3)-1;
            Until c<>0;
          end;
          AvanceEtoile(a,b,c);
          if Compte=100 then Compte:=0;
        end;
      end;

      if Fini>100 then AvanceEtoile(a,b,c);
      if Fini>150 then AvanceEtoile(a,b,c);
      if NoirEtBlanc=False then begin
        if Fini=31 then Couleur:=Couleur+8; {au d‚but les ‚toiles s'allument petit … petit}
      end else begin
        if Fini=0 then Couleur:=8;
        if Fini=11 then Couleur:=7;
        if Fini=20 then Couleur:=15;
      end;
      Fini:=Fini+1;
      PutPixel(Round(X),Round(Y),Couleur);
      if (X<0) or (X>639) or (Y<0) or (Y>479)  then
      begin
        PutPixel(Round(X),Round(Y),0);
        NewStar(i); {cr‚ation d'une nouvelle ‚toile quand y'en a une qui a}
      end;          {quitt‚ l'‚cran}
    end;
    Delay(Vitesse);
    if Action in ['4'..'9'] then Compte:=Compte+1;
    if KeyPressed then begin
      Previous:=Action;
      Action:=Readkey;
      if Action=#0 then begin
        Action:=ReadKey;
        Case Action of
          #72:CentreY:=CentreY-1;
          #75:CentreX:=CentreX-1;
          #77:CentreX:=CentreX+1;
          #80:CentreY:=CentreY+1;
        end;
      end;
      if Action=#13 then begin CentreX:=320; CentreY:=240; end;
      if Action<>#27 then if not (Action in ['0'..'9']) then Action:=Previous;
      if not (Action in ['4'..'9']) then Compte:=0;
    end;
  Until Action=#27;
  CloseGraph;
end.
