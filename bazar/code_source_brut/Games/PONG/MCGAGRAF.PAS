unit MCGAGraf;

interface

type
  PScreen=^TScreen;
  TScreen=Array[0..199,0..319] of Byte;
  TCarac=Record
    Image:Array[0..7,0..6] of Byte;
    SizeX:Byte;
    Exists:Boolean;
  end;
Var
  Pal:Array[0..255,0..2] of Byte;
  Video,Buffer:PScreen;
  ScreenX1,ScreenX2,ScreenY1,ScreenY2:Integer;
  Carac:Array[0..255] of TCarac;
 {Ce tableau contient les images des caractŠres, il faut les loader au d‚but
  du programme par la proc‚dure LoadCarac
  tout les caractŠres ont la mˆme hauteur (=8Pixel), mais ils ont
  chacun une largeur propre:TCarac.SizeX. La largeur maximale est 7 pixels.

  Les images des caractŠres sont stock‚es dans le fichier MCGACHAR
  Dans ce fichier, chaque caractŠres prend 56 octets (8*7=56)
  chaque octets peut prendre 3 valeurs:
  0 : Pixel transparent      FF : Pixel qui a la couleur principale
  8 : Pixel qui a la couleur secondaire

  la couleur secondaire, c'est la couleur de certains petits pixels,
  pour faire comme de l'anti-aliasing.

  si t'as rien compris, voir les proc‚dures LoadCarac, OutText, TranspText}

  Procedure McgaScreen;
  Procedure CloseScreen;
  Procedure Draw(x1,y1,x2,y2:Integer);
  procedure Pixel(X,Y:Word;Color:Byte);
  Procedure AfficheAll;
  Procedure Affiche;
  Procedure DefinePal;
  Procedure DefineAColor(Red,Green,Blue,Color:Byte);
  Function LoadPalette(FileName:string):Boolean;
  Function LoadCarac:Boolean;
  Procedure OutText(X,Y:Integer;Text:String);
  Procedure LineHoriz(x1,x2,y:Integer;Color:Byte);
  Procedure LineVertic(x,y1,y2:Integer;Color:Byte);
  Procedure Square(x1,y1,x2,y2:Integer;Color:Byte);
  Procedure FilledSquare(x1,y1,x2,y2:Integer;Color:Byte);
  Procedure ClearScreen(Color:Byte);
  Procedure Degrade(Color1,Red1,Green1,Blue1,Color2,Red2,Green2,Blue2:Byte);
  Procedure TranspText(X,Y:Integer;Text:string;Color1,Color2:Byte;Adouci:Boolean);
  Function TextLength(Text:string):Word;

implementation

uses Dos,DosFile;

procedure Pixel(X,Y:Word;Color:Byte);assembler;
asm
  cmp x,320
  jnb @@1
  cmp y,200
  jnb @@1
  les bx,Buffer
  add bh,Byte(y)
  mov dx,y
  shl dx,6
  add bx,dx
  add bx,x
  mov cl,color
  mov es:[bx],cl
@@1:
end;

Procedure McgaScreen;
var x,y:integer;
begin
  Asm
    Mov AH,$0000;
    Mov AL,$0013;
    Int $10;
  end;
  Video:=Addr(Mem[$A000:$0000]);
  New(Buffer);
  for y:=0 to 199 do for x:=0 to 319 do begin
    Video^[y,x]:=0;
    Buffer^[y,x]:=0;
  end;
end;

Procedure CloseScreen;
begin
  Asm
    Mov AH,$0000;
    Mov AL,$003;
    Int $10;
  end;
  Dispose(Buffer);
end;

Procedure Affiche;
var i:Word;
begin
  for i:=ScreenY1 to ScreenY2 do Move(Buffer^[i,ScreenX1],Video^[i,ScreenX1],ScreenX2-ScreenX1+1);
  ScreenX1:=319;
  ScreenX2:=0;
  ScreenY1:=199;
  ScreenY2:=0;
end;

Procedure AfficheAll;
var i:Word;
begin
  for i:=0 to 199 do Move(Buffer^[i,0],Video^[i,0],320);
end;

Procedure Draw(x1,y1,x2,y2:Integer);
begin
  if ScreenX1>x1 then ScreenX1:=x1;
  if ScreenX2<x2 then ScreenX2:=x2;
  if ScreenY1>y1 then ScreenY1:=y1;
  if ScreenY2<y2 then ScreenY2:=y2;
  if ScreenX1<0 then ScreenX1:=0;
  if ScreenX2>319 then ScreenX2:=319;
  if ScreenY1<0 then ScreenY1:=0;
  if ScreenY2>199 then ScreenY2:=199;
end;

Procedure DefinePal;
var Reg:Registers;
begin
  Reg.AH:=$0010;
  Reg.AL:=$0012;
  Reg.BX:=$0000;
  Reg.CX:=$0100;
  Reg.ES:=Seg(Pal);
  Reg.DX:=Ofs(Pal);
  Intr($10,Reg);
end;

Procedure DefineAColor(Red,Green,Blue,Color:Byte);assembler;
asm
  mov ah,$10
  mov al,$10
  mov bl,Color
  xor bh,bh
  mov ch,Green
  mov cl,Blue
  mov dh,Red
  int $10
end;

Procedure ClearScreen(Color:Byte);
begin
  FillChar(Buffer^[0,0],64000,Color);
end;

Function LoadPalette(FileName:string):Boolean;
var H:Handle;
begin
  if FOpen(H,FileName) then begin
    FRead(H,Pal,768);
    FClose(H);
    DefinePal;
    LoadPalette:=True;
  end else LoadPalette:=False;
end;

{Proc‚dure pour charger ma super police de caractŠres en m‚moire}

Function LoadCarac:Boolean;
var H:Handle;i:Byte;

  Procedure LoadOneCarac(AsciiValue:Byte);
  var Stop:Boolean;j:Byte;Sum:Integer;
  begin
    With Carac[AsciiValue] do begin
      FRead(H,Image[0,0],56);
      SizeX:=7;
      Exists:=True;
      Stop:=False;
      Repeat
        Sum:=0;
        for j:=0 to 7 do Inc(Sum,Image[j,SizeX-1]);
        if Sum=0 then Dec(SizeX) else Stop:=True;
      Until (SizeX=0) or Stop;
    end;
  end;

  Procedure EmptyCarac(AsciiValue:Byte);
  begin
    With Carac[AsciiValue] do begin
      FillChar(Image[0,0],56,0);
      SizeX:=7;
      Exists:=True;
    end;
  end;

begin
  for i:=0 to 255 do Carac[i].Exists:=False;
  if FOpen(H,'mcgachar') then begin
    for i:=0 to 25 do LoadOneCarac(Ord('A')+i);
    for i:=0 to 9 do LoadOneCarac(Ord('0')+i);
    for i:=0 to 3 do LoadOneCarac(24+i);
    LoadOneCarac(Ord(''''));
    LoadOneCarac(Ord('?'));
    LoadOneCarac(Ord(','));
    LoadOneCarac(Ord(';'));
    LoadOneCarac(Ord('.'));
    LoadOneCarac(Ord(':'));
    LoadOneCarac(Ord('!'));
    LoadOneCarac(Ord('='));
    {Si tu veux rajouter des caractŠres dans la police,
    modifie le fichier MCGACHAR
    et modifie cette proc‚dure, rajoute des LoadOneCarac ici
    ATTENTION!! L'ordre dans lequel tu charge les caractŠres est important
    dans le fichier MCGACHAR, les caractŠres sont stock‚s
    dans un certain ordre, il faut les charger dans le mˆme ordre.
    Regarde plus haut pour savoir comment est foutu le fichier MCGACHAR
    regarde un peu plus bas si tu ne comprends toujours rien}
    EmptyCarac(32);
    EmptyCarac(255);
    LoadCarac:=True;
    FClose(H);
  end else LoadCarac:=False;
end;

{Proc‚dure pour afficher bˆtement le texte commme ‡a, avec un rectangle noir
autour du texte, le texte est affich‚ avec la couleur 255 comme couleur principale
et la couleur 8 comme couleur secondaire.
Donc si ta palette de couleur est pas adapt‚e, cette proc‚dure sert … rien
Cette proc‚dure est assez rapide}

Procedure OutText(X,Y:Integer;Text:string);
var i,j:Byte;SkipNext:Boolean;
begin
  SkipNext:=False;
  if Text<>'' then for i:=1 to Length(Text) do if not SkipNext then With Carac[Ord(Text[i])] do begin
    if Exists then begin
      for j:=0 to 7 do Move(Image[j,0],Buffer^[Y+j,X],SizeX);
      Inc(X,SizeX);
      LineVertic(X,Y,Y+7,0);
      Inc(X);
    end;
    if Text[i]=#0 then begin
      j:=Ord(Text[i+1]);
      FilledSquare(X,Y,X+j,Y+7,0);
      Inc(X,j);
      SkipNext:=True;
    end;
  end else SkipNext:=False;
end;

{Proc‚dure pour afficher que le texte, sans gros rectangle pas beau.
les paramŠtres Color1 et Color2 sont les num‚ros des couleurs principales
et secondaires.
le paramŠtres Adouci est un Boolean, qui indique si tu veux afficher le texte
avec ou sans anti-aliasing.
Donc, si tu mets "False" dans le paramŠtre Adouci, tu ne mets pas d'anti-aliasing
et tu peux mettre n'importe quoi comme valeur dans le paramŠtre Color2}

Procedure TranspText(X,Y:Integer;Text:string;Color1,Color2:Byte;Adouci:Boolean);
var i,j,k:Byte;SkipNext:Boolean;
begin
  SkipNext:=False;
  if Text<>'' then for i:=1 to Length(Text) do if not SkipNext then With Carac[Ord(Text[i])] do begin
    if Exists then begin
      for j:=0 to 7 do for k:=0 to SizeX-1 do if Image[j,k]=255 then Pixel(X+k,Y+j,Color1)
      else if (Image[j,k]=8) and (Adouci) then Pixel(X+k,Y+j,Color2);
      Inc(X,SizeX+1);
    end;
    if Text[i]=#0 then begin
      Inc(X,Ord(Text[i+1]));
      SkipNext:=True;
    end;
  end else SkipNext:=False;
end;

{Pour les proc‚dures OutText et TranspText :
 - On ne peut ‚crire que des  majuscules.

 - Tu peux mettre un espace de largeur n au milieu du texte en ‚crivant #0+#n
Exemple : 'SALUT LES'+#0+#25+'AMIS!'   tu auras dans ce cas un espace de
25 pixels entre tes deux morceaux de texte}


{Fonction qui donne en pixel la largeur d'un texte, ‡a peut servir
tu peux mettre comme paramŠtre une chaŒne de caractŠres qui a des #0+#n
la fonction en tient compte}

Function TextLength(Text:string):Word;
var L:Word;i:Byte;SkipNext:Boolean;
begin
  L:=0;
  SkipNext:=False;
  if Text<>'' then for i:=1 to Length(Text) do if not(SkipNext) then
  if Text[i]<>#0 then Inc(L,Carac[Ord(Text[i])].SizeX+1) else begin
    SkipNext:=True;
    Inc(L,Ord(Text[i+1]));
  end else SkipNext:=False;
  TextLength:=L-1;
end;

Procedure LineHoriz(x1,x2,y:Integer;Color:Byte);
var x:Integer;
begin
  if x1>x2 then begin x1:=x; x1:=x2; x2:=x; end;
  if x1<0 then x1:=0;
  if x2>319 then x2:=319;
  if (y>=0) and (y<=199) and (x1<319) and (x2>0) then FillChar(Buffer^[y,x1],x2-x1+1,Color);
end;

Procedure LineVertic(x,y1,y2:Integer;Color:Byte);
var i,y:Integer;
begin
  if y1>y2 then begin y1:=y; y1:=y2; y2:=y; end;
  if y1<0 then y1:=0;
  if y2>199 then y2:=199;
  if (x>=0) and (x<=319) and (y1<199) and (y2>0) then for i:=y1 to y2 do Pixel(x,i,Color);
end;

Procedure Square(x1,y1,x2,y2:Integer;Color:Byte);
begin
  LineVertic(x1,y1,y2,Color);
  LineVertic(x2,y1,y2,Color);
  LineHoriz(x1,x2,y1,Color);
  LineHoriz(x1,x2,y2,Color);
end;

Procedure FilledSquare(x1,y1,x2,y2:Integer;Color:Byte);
var i,Zarba:Integer;
begin
  if x1<0 then x1:=0;
  if x2>319 then x2:=319;
  if y1<0 then y1:=0;
  if y2>199 then y2:=199;
  if y1>y2 then begin y1:=Zarba; y1:=y2; y2:=Zarba; end;
  if x1>x2 then begin x1:=Zarba; x1:=x2; x2:=Zarba; end;
  Zarba:=x2-x1+1;
  if (x1<319) and (x2>0) and (y1<199) and (y2>0) then for i:=y1 to y2 do FillChar(Buffer^[i,x1],Zarba,Color);
end;

{Proc‚dure pour faire des b“ d‚grad‚s dans la palette de couleur
On doit indiquer les num‚ros de couleurs de fin et de d‚part
, les valeurs rouge-vert-bleu que doit prendre la couleur de d‚part
et les valeurs RVB que doit prendre la couleur de fin.
La proc‚dure fait un b“ d‚grad‚ entre ces deux couleurs}

Procedure Degrade(Color1,Red1,Green1,Blue1,Color2,Red2,Green2,Blue2:Byte);
var Red,Green,Blue,DepRed,DepGreen,DepBlue:Integer;i:Byte;
begin
  if Color1<Color2 then begin
    Red:=Red1 shl 5;
    Green:=Green1 shl 5;
    Blue:=Blue1 shl 5;
    DepRed:=((Red2-Red1+Ord(Red1<Red2)-Ord(Red1>Red2)) shl 5) div (Color2-Color1+1);
    DepGreen:=((Green2-Green1+Ord(Green1<Green2)-Ord(Green1>Green2)) shl 5) div (Color2-Color1+1);
    DepBlue:=((Blue2-Blue1+Ord(Blue1<Blue2)-Ord(Blue1>Blue2)) shl 5) div (Color2-Color1+1);
    for i:=Color1 to Color2 do begin
      Pal[i,0]:=Red shr 5;
      Pal[i,1]:=Green shr 5;
      Pal[i,2]:=Blue shr 5;
      Inc(Red,DepRed);
      Inc(Green,DepGreen);
      Inc(Blue,DepBlue);
    end;
  end else;
end;

end.