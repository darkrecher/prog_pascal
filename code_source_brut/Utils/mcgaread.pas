Uses MCGaGraf,NewDelay,Crt;

{ Programme qui fait comme la procedure Read du pascal en mode texte.
  Mais celui l… est pour le mode graphique.

  ATTENTION!!  la fonction newread de ce programme ne permet pas de
  d‚tecter si l'utilisateur a appuy‚ sur Echap ou sur Entr‚e … la fin.
  Il y a une petite correction … faire si on veut que ‡a fasse ‡a.

   }

Type
  Caracs=Set of Char;

Const
  Authorized=['A'..'Z'];

var
  S:string;

function NewRead(X,Y,LMax:Integer;Writable:Caracs;BackgrColor,Color1,Color2:Byte;Aliaz:Boolean):String;
var s:string;c:char;Quit:Boolean;
begin
  s:='';
  Quit:=False;
  Repeat
    if keypressed then begin
      c:=Readkey;
      if (c=#13) or (C=#27) then Quit:=True;
      C:=UpCase(C);
      if (c in Writable) and (Length(S)<LMax) then S:=S+C;
      FilledSquare(X,Y,X+TextLength(S),Y+8,BackgrColor);
      TranspText(X,Y,S,Color1,Color2,Aliaz);
      Draw(X,Y,X+TextLength(S),Y+8);
      Affiche;
    end;
  until Quit;
  NewRead:=s;
end;

begin
  PatchCrt(Crt.Delay);  {instruction pour debugger cette merde d'unit‚ crt
  qui foire sur les ordinateurs trop rapide}
  MCGAScreen;
  LoadCarac;
  S:=NewRead(50,50,10,Authorized,0,10,2,True);
  CloseScreen;
end.
