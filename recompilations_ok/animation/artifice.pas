uses Graph,Crt;

Type
  Spark=Record
    Y,XenPlus,YenPlus,X,FinX,FinY:Integer;{FinX et FinY:les coordonnées du pixel}
  end;                                 {qui est à l'extremité et qui doit être}
                                       {effacé}

Var
  Artif:Array[0..5,0..19] of Spark; {il y a toujours 6 fusées à l'ecran}
  a,i,Vitesse:Integer;
  WhichSpark:0..20;
  Fini:Array[0..5] of Integer;
  Variab:Array[0..5] of Integer;{Variab:indique quand la fusee doit exploser, et indique la couleur de l'explosion}
  Fusee:Array[0..5] of 0..3;{0:Creer  une nouvelle fusée,1:la fusée part}
                            {2:Créer les etincelles,3:les étincelles se dispersent}
Procedure Baoum(u,v:Integer);
begin
  With Artif[u,v] do begin
    X:=Artif[u,0].X;
    Y:=Artif[u,0].Y;
    FinX:=X;
    FinY:=Y;
    Xenplus:=Random(40)-20;
    YenPlus:=Random(40)-20;
  end;
end;

begin
  if ParamCount<1 then begin
    Writeln('Si la vitesse de cette superbe animation ne vous convient pas');
    WriteLn('Vous pouvez la configurer.');
    WriteLn('Il suffit d''indiquer un nombre en paramètres au moment de lancer le programme.');
    WriteLn('Plus le nombre est grand, plus c''est lent.');
    WriteLn('Mettez plutôt un nombre comme 5 ou 6, mais pas plus.');
    { 2019-05-05 : Désactivation de l'attente d'appuyer sur une touche.
      On ne voit plus le texte affiché au départ, mais il faut bien avouer que osef, un peu.
      Et comme ça, ça lance l'anim tout de suite
    }
    {Readkey;}
    {While keypressed do Readkey;}
    Vitesse:=1;
  end else begin
    Val (ParamStr(1),Vitesse,a);
    if a<>0 then begin
      Write('Imbécile!!! Vous devez écrire un nombre!!!');
      Exit;
    end;
    if Vitesse<0 then begin
      Write('Imbécile!!! Il faut mettre un nombre positif!!');
      Exit;
    end;
  end;
  Randomize;
  a:=9;
  i:=2;
  InitGraph(a,i,'c:\bp\bgi');
  SetFillStyle(0,0);
  for i:=0 to 5 do Fusee[i]:=0;
  i:=0;
  Repeat
    for i:=0 to 5 do begin
      if Fusee[i]=0 then begin
        With Artif[i,0] do begin
          Y:=4800;
          X:=Random(5000)+700;
          XenPlus:=Random(30)-15;
          YenPlus:=-20;
          Fini[i]:=0;
          FinX:=X;
          FinY:=Y;
          Variab[i]:=Random(280)+15;
          Fusee[i]:=1;
        end;
      end;

      if Fusee[i]=1 then begin
        With Artif[i,0] do begin
          if Fini[i]>10 then begin
            FinX:=FinX+XenPlus;
            FinY:=FinY+YenPlus+(Fini[i]-11) div 15;
            PutPixel(FinX div 10,FinY div 10,0);
          end;
          if Fini[i]<Variab[i]-10 then begin
            X:=X+XenPlus;
            Y:=Y+YenPlus+Fini[i] div 15;
            PutPixel(X div 10,Y div 10,15);
          end;
          Fini[i]:=Fini[i]+1;
          if Fini[i]=Variab[i] then Fusee[i]:=2;
          if (X<0) or (X>6400) then begin
            Bar(X div 10,Y div 10,FinX div 10,FinY div 10);
            Fusee[i]:=0;
          end;
        end;
      end;

      if Fusee[i]=2 then begin
        a:=Random(7)+1;
        WhichSpark:=0;
        Repeat
          Baoum(i,WhichSpark);
          WhichSpark:=WhichSpark+1;
        Until WhichSpark=20;
        Fusee[i]:=3;
        Fini[i]:=0;
        Variab[i]:=a;
      end;

      if Fusee[i]=3 then begin
        WhichSpark:=0;
        Repeat
          With Artif[i,WhichSpark] do begin
            PutPixel(X div 10,Y div 10,Variab[i]);
            if Fini[i]<89 then begin
              X:=X+XenPlus;
              Y:=Y+YenPlus+Fini[i] div 4;
            end;
            if Fini[i]>10 then begin
              FinX:=FinX+XenPlus;
              FinY:=FinY+YenPlus+(Fini[i]-11) div 4;
            end;
             PutPixel(X div 10,Y div 10,Variab[i]+8);
             PutPixel(FinX div 10,FinY div 10,0);
          end;
          WhichSpark:=WhichSpark+1;
        Until WhichSpark=20;
        Fini[i]:=Fini[i]+1;
        if Fini[i]=100 then Fusee[i]:=0;
      end;
    end;
    { 2019-05-05 : Déplacement du Delay en dehors de la boucle. Sinon c'est vraiment trop lent.
      (Comment j'ai pu faire une erreur aussi idiote, même à l'époque ?)
    }
    Delay(Vitesse);
  Until KeyPressed;
end.



