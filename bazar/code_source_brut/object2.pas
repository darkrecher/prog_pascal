{$M 16384,16384,655360}

Uses Dos,App,Objects,Menus,Views,Dialogs,Drivers,msgbox,Memory,StdDlg;

Const
  cmOuvreFichier=100;
  cmChangeDir=101;
  hlChangeDir=101;

Type
  PCollectionLigne=^TCollectionLigne;
  TCollectionLigne=Object(TCollection)
    Procedure FreeItem(P:Pointer); virtual;
  end;

  PVisionneur=^TVisionneur;
  TVisionneur=Object(TScroller)
    LignesFich:PCollection;
    EstOK:Boolean;
    Constructor Init(var Taille:TRect;AscenseurH,AscenseurV:PScrollBar;var NomFichier:PathStr);
    Destructor Done; virtual;
    Procedure Draw; virtual;
    Function Valid(Command:Word):Boolean; virtual;
  end;

  PFenetre=^TFenetre;
  TFenetre=Object(TWindow)
    Constructor Init(Var NomFichier:PathStr);
  end;

  TTravail=Object(TApplication)
    Procedure HandleEvent(var Evenement:TEvent); virtual;
    Procedure InitMenuBar; virtual;
    Procedure InitStatusLine; virtual;
    Procedure OutOfMemory; virtual;
  end;

  Procedure TCollectionLigne.FreeItem(P:Pointer);
  begin
    DisposeStr(P);
  end;

  Constructor TVisionneur.Init(var Taille:TRect;AscenseurH,AscenseurV:PScrollBar;var NomFichier:PathStr);
  var Fichier:Text;Ligne:string;LongueurMax,i,j:Integer;
  begin
    TScroller.Init(Taille,AscenseurH,AscenseurV);
    GrowMode:=gfGrowHix+gfGrowHiY;
    EstOk:=True;
    LignesFich:=New(PCollectionLigne,Init(5,5));
  {$I-}
    Assign(Fichier,NomFichier);
    Reset(Fichier);
    if IOResult<>0 then begin
      MessageBox('Ouverture de '+NomFichier+' impossible.',Nil,mfError+mfOKButton);
      EstOk:=False;
    end else begin
      LongueurMax:=0;
      While not EOF(Fichier) and not LowMemory do begin
        Readln(Fichier,Ligne);
        if Length(Ligne)>LongueurMax then LongueurMax:=Length(Ligne);
        LignesFich^.Insert(NewStr(Ligne));
      end;
      Close(Fichier);
    end;
  {$I+}
    SetLimit(LongueurMax,LignesFich^.Count);
  end;

Destructor TVisionneur.Done;
begin
  Dispose(LignesFich,Done);
  TScroller.Done;
end;

Procedure TVisionneur.Draw;
var B:TDrawBuffer;C:Byte;i,j:Integer;S:string;P:Pstring;
begin
  C:=GetColor(1);
  for i:=0 to Size.Y-1 do begin
    MoveChar(B,' ',C,Size.X);
    if Delta.Y+i<LignesFich^.Count then begin
      P:=LignesFich^.At(Delta.Y+i);
      if P<>Nil then S:=Copy(P^,Delta.X+1,Size.X) else S:='';
      MoveStr(B,S,C);
    end;
    WriteLine(0,i,Size.X,1,B);
  end;
end;

Function TVisionneur.Valid(Command:Word):Boolean;
begin
  Valid:=EstOk;
end;

Constructor TFenetre.Init(var NomFichier:PathStr);
Const NumeroFenetre:Integer=1;
var R:TRect;
begin
  DeskTop^.GetExtent(R);
  TWindow.Init(R,NomFichier,NumeroFenetre);
  Options:=Options or ofTileAble;
  Inc(NumeroFenetre);
  GetExtent(R);
  R.Grow(-1,-1);
  Insert(New(PVisionneur,Init(R,
    StandardScrollBar(sbHorizontal+sbHandleKeyboard),
    StandardScrollBar(sbVertical+sbHandleKeyboard),
    NomFichier)));
end;

Procedure TTravail.HandleEvent(var Evenement:TEvent);

  Procedure OuvreFich;
  var D:PFileDialog;NomFichier:PathStr;W:PWindow;
  begin
    D:=PFileDialog(ValidView(New(PFileDialog,Init('*.*','Ouvrir Fichier','Coucou qui est l… ?',fdOpenButton,100))));
    if D<>Nil then begin
      if DeskTop^.ExecView(D)<>cmCancel then begin
        D^.GetFileName(NomFichier);
        W:=PWindow(ValidView(
          New(PFenetre,Init(NomFichier))));
        if W<>Nil then DeskTop^.Insert(W);
      end;
      Dispose(D,Done);
    end;
  end;

  Procedure ChangeDir;
  var D:PChDirDialog;
  begin
    D:=PchDirDialog(ValidView(New(PChDirDialog,Init(0,hlChangeDir))));
    if D<>Nil then begin
      DeskTop^.ExecView(D);
      Dispose(D,Done);
    end;
  end;

  Procedure Pavage;
  var R:TRect;
  begin
    DeskTop^.GetExtent(R);
    DeskTop^.Tile(R);
  end;

  Procedure CascadeDuplicateIdentifier;
  var R:TRect;
  begin
    DeskTop^.GetExtent(R);
    DeskTop^.Cascade(R);
  end;

begin
  TApplication.HandleEvent(Evenement);
  Case Evenement.What of evCommand:
    begin
      Case Evenement.Command of
        cmOuvreFichier:OuvreFich;
        cmChangeDir:ChangeDir;
        cmCascade:CascadeDuplicateIdentifier;
        cmTile:Pavage;
        else Exit;
      end;
    ClearEvent(Evenement);
    end;
  end;
end;

Procedure TTravail.InitMenuBar;
var R:TRect;
begin
GetExtent(R);
R.B.Y:=R.A.Y+1;
MenuBar:=New(PMenuBar,Init(R,NewMenu(
  NewSubMenu('Fichier',100,NewMenu(
    NewItem('Ouvrir','',kbNokey,cmOuvreFichier,hcNoContext,
    NewItem('Changer rep','',kbNokey,cmChangeDir,hcNoContext,
    NewItem('Quitter','',kbNokey,cmQuit,hcNoContext,Nil)))),
  NewSubMenu('Visuel',hcNoContext,NewMenu(
    NewItem('Retaille/bouge','',kbNokey,cmResize,hcNoContext,
    NewItem('Zoom','',kbNokey,cmZoom,hcNoContext,
    NewItem('Suivante','',kbNokey,cmNext,hcNoContext,
    NewItem('Fermer','',kbNokey,cmClose,hcNoContext,
    NewItem('Pavage','',kbNokey,cmTile,hcNoContext,
    NewItem('Cascade','',kbNokey,cmCascade,hcNoContext,Nil))))))),Nil)))));
end;

Procedure TTravail.InitStatusLine;
var R:TRect;
begin
  GetExtent(R);
  R.A.Y:=R.B.Y-1;
  StatusLine:=New(PStatusLine,Init(R,
    NewStatusDef(0,$FFFF,
    NewStatusKey('',kbF10,cmMenu,
    NewStatusKey('Quitter',kbNokey,cmQuit,
    NewStatusKey('Ouvrir',kbNokey,cmOuvreFichier,
    NewStatusKey('Fermer',kbNokey,cmClose,
    NewStatusKey('Zoom',kbNokey,cmZoom,
    NewStatusKey('Fenˆtre',kbNokey,cmNext,
    NewStatusKey('Ch Dir',kbNokey,cmChangeDir,
    Nil))))))),Nil)));
end;

Procedure TTravail.OutOfMemory;
var D:PDialog;R:TRect;C:Word;
begin
  MessageBox('M‚moire insuffisante pour poursuivre.',Nil,mfError+mfOkButton);
end;

var Visionneur_de_Fichier:TTRavail;
begin
  Visionneur_de_Fichier.Init;
  Visionneur_de_Fichier.Run;
  Visionneur_de_Fichier.Done;
end.