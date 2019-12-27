Uses Crt,Objects,MCGAGraf,KeyBoard;

Const
  Focale=200;

  Transparent=255;

  Precision=6;
  PrecFactor=1 shl Precision;

  The1=True;
  The2=False;

Type
  Vector3D=Record
    X,Y,Z:LongInt;
  end;

  TCoord3D=Record
    X,Y,Z:LongInt;
  end;

  TCoord2D=Record
    X,Y:LongInt;
  end;

  PCamera=^TCamera;
  TCamera=Object(TObject)
    CamPos:TCoord3D;
    CamAngle,HeadAngle:Byte;
    CamCos,CamSin,HeadCos,HeadSin:Integer;
    Vertical,Front,Left:Vector3D;
    {Vertical, Front et Left constitue une base de vecteurs orthonormal
    dans l'espace}
    {Front est le vecteur qui indique dans quel direction la camera regarde}
    {cette base tourne dans tout les sens quand on fait regarder la camera
    de haut en bas ou de gauche … droite}
    Constructor Init(AX,AY,AZ:LongInt;ACam,AHead:Byte);
    Procedure CalculBazar;
    Destructor Done; virtual;
  end;

  PPoint=^TPoint;
  TPoint=Object(TObject)
    Coords,RelCoords:TCoord3D;
    Proj:TCoord2D;
    Color:Byte;
    BehindCam:Boolean;
    Constructor Init(AX,AY,AZ:LongInt;AColor:Byte);
    Procedure RelativePosition(Cam:PCamera;var Result:TCoord3D); virtual;
    Procedure Project(Cam:PCamera); virtual;
    Procedure Clear; virtual;
    Procedure Draws; virtual;
    Destructor Done; virtual;
  end;

  PLine=^TLine;
  TLine=Object(TObject)
    P1,P2:PPoint;
    Color:Byte;
    Segm:TCoord2D;
    BehindCam,Segmented,WhichPoint:Boolean;
    Constructor Init(AP1,AP2:PPoint;AColor:Byte);
    Procedure Clear; virtual;
    Procedure Draws; virtual;
    Destructor Done; virtual;
  end;

  PMachin3D=^TMachin3D;
  {objet de d‚part, qui ne gŠre pas les collisions}
  {il s'agit d'un ensemble de droites et de points}
  TMachin3D=Object(TObject)
    Lines,Points:PCollection;
    Constructor Init(MaxPoints,MaxLines:Word);
    Procedure Draws(Cam:PCamera); virtual;
    Procedure Clear; virtual;
    Destructor Done; virtual;
  end;

  PSolid3D=^TSolid3D;
  TSolid3D=Object(TMachin3D)
  {objet solide, tout les objets de ce type g‚reront les collisions.
  cette objet ne sert … rien en lui mˆme, sa seule utilit‚ est
  qu'on fait d‚river d'autres objets … partir de celui-l…}
    Immaterial:Boolean;
    Constructor Init(MaxPoints,MaxLines:Word;AImmaterial:Boolean);
    Procedure Collisions(Pos:TCoord3D;var Movement:Vector3D); virtual;
  end;

  PCuboid3D=^TCuboid3D;
  {objet solide. Pour la gestion des collisions, cet objet est assimil‚
  … un cube}
  TCuboid3D=Object(TSolid3D)
    UpLeftFront,DownRightFar:TCoord3D;
    Constructor Init(MaxPoints,MaxLines:Word;AUpLeftFront,ADownRightFar:TCoord3D;AImmaterial:Boolean);
    Procedure Collisions(Pos:TCoord3D;var Movement:Vector3D); virtual;
  end;

  PWorld=^TWorld;
  TWorld=Object(TObject)
    MinLimit,MaxLimit:TCoord3D;
    Cameras,Obj3D:PCollection;
    Constructor Init(MaxObj,MaxCameras:Word;AMinLimit,AMaxLimit:TCoord3D);
    Procedure Collisions(Pos:TCoord3D;var Movement:Vector3D); virtual;
    Procedure Draws(Cam:PCamera); virtual;
    Procedure Clear; virtual;
    Destructor Done; virtual;
  end;

  {voil…, ‡a c'‚tait tout les objets de bases, voyons maintenant
  les objets particuliers, ceux dont je me sers pour fabriquer le monde
  dans lequel on se d‚place}

  PCadrillage=^TCadrillage;
  TCadrillage=Object(TCuboid3D)
    Constructor Init(X1,Z1,X2,Z2,Y,SquareSize:LongInt;Color:Byte;AImmaterial:Boolean);
  end;

  PCube=^TCube;
  TCube=Object(TCuboid3D)
    Constructor Init(Center:TCoord3D;Size:LongInt;Color:Byte;AImmaterial:Boolean);
  end;

  POctaedre=^TOctaedre;
  TOctaedre=Object(TCuboid3D)
    Constructor Init(Center:TCoord3D;Size:LongInt;Color:Byte;AImmaterial:Boolean);
  end;

Constructor TCamera.Init(AX,AY,AZ:LongInt;ACam,AHead:Byte);
begin
  CamPos.X:=AX;
  CamPos.Y:=AY;
  CamPos.Z:=AZ;
  CamAngle:=ACam;
  HeadAngle:=AHead;
  CalculBazar;
end;

var
  Cosi:Array[0..255] of Integer;
  Sinu:Array[0..255] of Integer;

Procedure CosandSin;
var i:Byte;
begin
  for i:=0 to 255 do Cosi[i]:=Round(Cos( (Pi*i)/128 )*PrecFactor);
  for i:=0 to 255 do Sinu[i]:=Round(Sin( (Pi*i)/128 )*PrecFactor);
end;

Function Max(X1,X2:LongInt):LongInt;
begin
  if X1<X2 then Max:=X2 else Max:=X1;
end;

Function Min(X1,X2:LongInt):LongInt;
begin
  if X2<X1 then Min:=X2 else Min:=X1;
end;

Procedure MoveValue3D(Source:TCoord3D;var Dest:TCoord3D);
begin
  Dest.X:=Source.X;
  Dest.Y:=Source.Y;
  Dest.Z:=Source.Z;
end;

Procedure DefineValue3D(AX,AY,AZ:LongInt;var Dest:TCoord3D);
begin
  Dest.X:=AX;
  Dest.Y:=AY;
  Dest.Z:=AZ;
end;

Procedure AddValue3D(var Dest:TCoord3D;Add:Vector3D);
begin
  Inc(Dest.X,Add.X);
  Inc(Dest.Y,Add.Y);
  Inc(Dest.Z,Add.Z);
end;

Procedure TCamera.CalculBazar;
begin
  CamCos:=Cosi[CamAngle];
  CamSin:=Sinu[CamAngle];
  HeadCos:=Cosi[HeadAngle];
  HeadSin:=Sinu[HeadAngle];
  Vertical.X:=CamSin*HeadSin;
  Vertical.Y:=HeadCos;
  Vertical.Z:=-CamCos*HeadSin;
  Front.X:=-CamSin*HeadCos;
  Front.Y:=HeadSin;
  Front.Z:=CamCos*HeadCos;
  Left.X:=CamCos;
  Left.Y:=0;
  Left.Z:=CamSin;
end;

Destructor TCamera.Done;
begin
end;

Constructor TPoint.Init(AX,AY,AZ:LongInt;AColor:Byte);
begin
  Coords.X:=AX;
  Coords.Y:=AY;
  Coords.Z:=AZ;
  Color:=AColor;
end;

Procedure TPoint.RelativePosition(Cam:PCamera;var Result:TCoord3D);
var Value:TCoord3D;
begin
  With Cam^ do begin
    Value.X:=Coords.X-CamPos.X;
    Value.Y:=Coords.Y-CamPos.Y;
    Value.Z:=Coords.Z-CamPos.Z;{Left.Y est toujours ‚gal … 0}
    Result.X:=(Value.X*Left.X{+Left.Y*Value.Y}+Value.Z*Left.Z) div PrecFactor;
    Result.Y:=(Value.X*Vertical.X+Value.Z*Vertical.Z) div Sqr(PrecFactor)
    +(Value.Y*Vertical.Y) div PrecFactor;
    Result.Z:=(Value.X*Front.X+Value.Z*Front.Z) div Sqr(PrecFactor)
    +(Value.Y*Front.Y) div PrecFactor;
  end;
  BehindCam:=Result.Z<PrecFactor;
end;

Procedure TPoint.Project(Cam:PCamera);
begin
  RelativePosition(Cam,RelCoords);
  if not(BehindCam) then begin
    With RelCoords do begin
      Proj.X:=(Focale*(X div PrecFactor)) div (Z div PrecFactor)+159;
      Proj.Y:=(Focale*(Y div PrecFactor)) div (Z div PrecFactor)+99;
    end;
  end;
end;

Procedure TPoint.Draws;
begin
  if not(BehindCam) and (Color<>Transparent) then With Proj do begin
    Pixel(X,Y,Color);
    Draw(X,Y,X,Y);
  end;
end;

Procedure TPoint.Clear;
begin
  if not(BehindCam) and (Color<>Transparent) then With Proj do begin
    Pixel(X,Y,0);
    Draw(X,Y,X,Y);
  end;
end;

Destructor TPoint.Done;
begin
end;

Constructor TLine.Init(AP1,AP2:PPoint;AColor:Byte);
begin
  P1:=AP1;
  P2:=AP2;
  Color:=AColor;
end;

Procedure TLine.Draws;
var XTruc,YTruc,DifZ,CantFindANameForThisPutainDeVariable:LongInt;
begin
  if (Color<>Transparent) then begin
    if not(P1^.BehindCam and P2^.BehindCam) then begin
      BehindCam:=False;
      if P1^.BehindCam or P2^.BehindCam then begin
        Segmented:=True;

        DifZ:=P1^.RelCoords.Z-P2^.RelCoords.Z;
        CantFindANameForThisPutainDeVariable:=P1^.RelCoords.Z-PrecFactor;

        XTruc:=(CantFindANameForThisPutainDeVariable*(P2^.RelCoords.X-P1^.RelCoords.X))
        div DifZ+P1^.RelCoords.X;
        YTruc:=(CantFindANameForThisPutainDeVariable*(P2^.RelCoords.Y-P1^.RelCoords.Y))
        div DifZ+P1^.RelCoords.Y;

        Segm.X:=Focale*(XTruc div PrecFactor)+159;
        Segm.Y:=Focale*(YTruc div PrecFactor)+99;
        if P1^.BehindCam then begin
          WhichPoint:=The2;
          With P2^.Proj do begin
            Line(X,Y,Segm.X,Segm.Y,Color);
            Draw(Segm.X,Segm.Y,Segm.X,Segm.Y);
          end;
        end else begin
          WhichPoint:=The1;
          With P1^.Proj do begin
            Line(X,Y,Segm.X,Segm.Y,Color);
            Draw(Segm.X,Segm.Y,Segm.X,Segm.Y);
          end;
        end;
      end else begin
        Line(P1^.Proj.X,P1^.Proj.Y,P2^.Proj.X,P2^.Proj.Y,Color);
        Segmented:=False;
      end;
    end else BehindCam:=True;
  end;
end;

Procedure TLine.Clear;
begin
  if (Color<>Transparent) and not(BehindCam) then begin
    if Segmented then begin
      if WhichPoint=The1 then With P1^.Proj do begin
        Line(X,Y,Segm.X,Segm.Y,0);
        Draw(Segm.X,Segm.Y,Segm.X,Segm.Y);
      end else With P2^.Proj do begin
        Line(X,Y,Segm.X,Segm.Y,0);
        Draw(Segm.X,Segm.Y,Segm.X,Segm.Y);
      end;
    end else Line(P1^.Proj.X,P1^.Proj.Y,P2^.Proj.X,P2^.Proj.Y,0);
  end;
end;

Destructor TLine.Done;
begin
end;

Constructor TMachin3D.Init(MaxPoints,MaxLines:Word);
begin
  New(Points,Init(MaxPoints,2));
  New(Lines,Init(MaxLines,1));
end;

Procedure TMachin3D.Draws(Cam:PCamera);
var CurrentP:PPoint;i,Nbr:Word;
begin
{  Nbr:=Points^.Count;}
  if Points^.Count<>0 then for i:=0 to Points^.Count-1 do begin
    CurrentP:=PPoint(Points^.At(i));
    CurrentP^.Project(Cam);
    CurrentP^.Draws;
  end;
{  Nbr:=Lines^.Count;}
  if Lines^.Count<>0 then for i:=0 to Lines^.Count-1 do PLine(Lines^.At(i))^.Draws;
end;

Procedure TMachin3D.Clear;
var CurrentP:PPoint;i,Nbr:Word;
begin
  Nbr:=Points^.Count;
  if Nbr<>0 then for i:=0 to Nbr-1 do PPoint(Points^.At(i))^.Clear;
  Nbr:=Lines^.Count;
  if Nbr<>0 then for i:=0 to Nbr-1 do PLine(Lines^.At(i))^.Clear;
end;

Destructor TMachin3D.Done;
begin
  Points^.Done;
  Lines^.Done;
end;

Constructor TSolid3D.Init(MaxPoints,MaxLines:Word;AImmaterial:Boolean);
begin
  TMachin3D.Init(MaxPoints,MaxLines);
  Immaterial:=AImmaterial;
end;

Procedure TSolid3D.Collisions(Pos:TCoord3D;var Movement:Vector3D);
begin
end;

Constructor TCuboid3D.Init(MaxPoints,MaxLines:Word;AUpLeftFront,ADownRightFar:TCoord3D;AImmaterial:Boolean);
begin
  TSolid3D.Init(MaxPoints,MaxLines,AImmaterial);
  MoveValue3D(AUpLeftFront,UpLeftFront);
  MoveValue3D(ADownRightFar,DownRightFar);
end;

Procedure TCuboid3d.Collisions(Pos:TCoord3D;var Movement:Vector3D);
var ColX,ColY,ColZ:Boolean;

  Procedure HandleOneDimensionalCollision(Posi,ALimit,BLimit:LongInt;var Mvment:LongInt);
  begin
    if (Mvment<0) and (Posi>=BLimit) and (Posi+Mvment<=BLimit) then Mvment:={BLimit-Posi}0;
    if (Mvment>0) and (Posi<=ALimit) and (Posi+Mvment>=ALimit) then Mvment:={ALimit-Posi}0;
  end;

begin
  if not(Immaterial) then begin
    ColX:=(UpLeftFront.X<=Pos.X) and (Pos.X<=DownRightFar.X);
    ColY:=(UpLeftFront.Y<=Pos.Y) and (Pos.Y<=DownRightFar.Y);
    ColZ:=(UpLeftFront.Z<=Pos.Z) and (Pos.Z<=DownRightFar.Z);
    if ColX and Coly and ColZ then begin
      Movement.X:=0;
      Movement.Y:=0;
      Movement.Z:=0;
    end else begin
      if ColX and ColY then
      HandleOneDimensionalCollision(Pos.Z,UpLeftFront.Z,DownRightFar.Z,Movement.Z);
      if ColZ and ColY then
      HandleOneDimensionalCollision(Pos.X,UpLeftFront.X,DownRightFar.X,Movement.X);
      if ColZ and ColX then
      HandleOneDimensionalCollision(Pos.Y,UpLeftFront.Y,DownRightFar.Y,Movement.Y);
    end;
  end;
end;

Constructor TWorld.Init(MaxObj,MaxCameras:Word;AMinLimit,AMaxLimit:TCoord3D);
begin
  New(Obj3D,Init(MaxObj,3));
  New(Cameras,Init(MaxCameras,1));
  MoveValue3D(AMinLimit,MinLimit);
  MoveValue3D(AMaxLimit,MaxLimit);
end;

Procedure TWorld.Collisions(Pos:TCoord3D;var Movement:Vector3D);
var i:Word;

  Procedure HandleOneDimensionalCollision(Posi,ALimit,BLimit:LongInt;var Mvment:LongInt);
  begin
    if (Mvment<0) and (Posi+Mvment<=ALimit) then Mvment:=ALimit-Posi;
    if (Mvment>0) and (Posi+Mvment>=BLimit) then Mvment:=BLimit-Posi;
  end;

begin
  HandleOneDimensionalCollision(Pos.X,MinLimit.X,MaxLimit.X,Movement.X);
  HandleOneDimensionalCollision(Pos.Y,MinLimit.Y,MaxLimit.Y,Movement.Y);
  HandleOneDimensionalCollision(Pos.Z,MinLimit.Z,MaxLimit.Z,Movement.Z);
  if Obj3D^.Count<>0 then for i:=0 to Obj3D^.Count-1 do
  PSolid3D(Obj3D^.At(i))^.Collisions(Pos,Movement);
end;

Procedure TWorld.Draws(Cam:PCamera);
var i:Word;
begin
  if Obj3D^.Count<>0 then for i:=0 to Obj3D^.Count-1 do
  PMachin3D(Obj3D^.At(i))^.Draws(Cam);
end;

Procedure TWorld.Clear;
var i:Word;
begin
  if Obj3D^.Count<>0 then for i:=0 to Obj3D^.Count-1 do
  PMachin3D(Obj3D^.At(i))^.Clear;
end;

Destructor TWorld.Done;
begin
  Dispose(Obj3D,Done);
  Dispose(Cameras,Done);
end;

{---------------------------------------------------------------------------}

Constructor TCadrillage.Init(X1,Z1,X2,Z2,Y,SquareSize:LongInt;Color:Byte;AImmaterial:Boolean);
var i:LongInt;A,B:TCoord3D;NbrPointX,NbrPointZ:Word;
begin
  DefineValue3D(X1,Y-1,Z1,A);
  DefineValue3D(X2,Y+1,Z2,B);
  NbrPointX:=(X2-X1) div SquareSize+1;
  NbrPointZ:=(Z2-Z1) div SquareSize+1;
  TCuboid3D.Init(2*NbrPointZ+2*NbrPointX-4,NbrPointX+NbrPointZ,A,B,AImmaterial);
  i:=X1;
  for i:=0 to NbrPointX-1 do Points^.Insert(New(PPoint,Init(X1+i*SquareSize,Y,Z1,Color)));
  for i:=0 to NbrPointX-1 do Points^.Insert(New(PPoint,Init(X1+i*SquareSize,Y,Z2,Color)));
  for i:=1 to NbrPointZ-2 do Points^.Insert(New(PPoint,Init(X1,Y,Z1+i*SquareSize,Color)));
  for i:=1 to NbrPointZ-2 do Points^.Insert(New(PPoint,Init(X2,Y,Z1+i*SquareSize,Color)));

  for i:=0 to NbrPointX-1 do Lines^.Insert(New(PLine,Init(PPoint(Points^.At(i)),PPoint(Points^.At(i+NbrPointX)),Color)));
  for i:=0 to NbrPointZ-3 do
  Lines^.Insert(New(PLine,Init(PPoint(Points^.At(i+2*NbrPointX)),PPoint(Points^.At(i+2*NbrPointX+NbrPointZ-2)),Color)));
  Lines^.Insert(New(PLine,Init(PPoint(Points^.At(0)),PPoint(Points^.At(NbrPointX-1)),Color)));
  Lines^.Insert(New(PLine,Init(PPoint(Points^.At(NbrPointX)),PPoint(Points^.At(2*NbrPointX-1)),Color)));
end;

Constructor TCube.Init(Center:TCoord3D;Size:LongInt;Color:Byte;AImmaterial:Boolean);
var A,B:TCoord3D;i:Byte;
Const Links:Array[0..11,0..1] of Byte=( (0,1),(0,4),(0,3), (2,1),(2,3),(2,6), (7,6),(7,4),(7,3), (5,1),(5,4),(5,6));
begin
  DefineValue3D(Center.X-Size div 2,Center.Y-Size div 2,Center.Z-Size div 2,A);
  DefineValue3D(Center.X+Size div 2,Center.Y+Size div 2,Center.Z+Size div 2,B);
  TCuboid3D.Init(8,12,A,B,AImmaterial);
  for i:=0 to 1 do begin
    Points^.Insert(New(PPoint,Init(Center.X-Size div 2,Center.Y+Size div 6,Center.Z-Size div 2+i*Size,Color)));
    Points^.Insert(New(PPoint,Init(Center.X+Size div 6,Center.Y+Size div 2,Center.Z-Size div 2+i*Size,Color)));
    Points^.Insert(New(PPoint,Init(Center.X+Size div 2,Center.Y-Size div 6,Center.Z-Size div 2+i*Size,Color)));
    Points^.Insert(New(PPoint,Init(Center.X-Size div 6,Center.Y-Size div 2,Center.Z-Size div 2+i*Size,Color)));
  end;
  for i:=0 to 11 do Lines^.Insert(New(PLine,Init(PPoint(Points^.At(Links[i,0])),PPoint(Points^.At(Links[i,1])),Color)));
end;

Constructor TOctaedre.Init(Center:TCoord3D;Size:LongInt;Color:Byte;AImmaterial:Boolean);
var A,B:TCoord3D;i,j:Byte;Hauteur:LongInt;
Const Links:Array[0..3,0..1] of Byte=( (0,1),(1,3),(3,2),(2,0) );
begin
  Hauteur:=LongInt(Size)*181 div 256;
  DefineValue3D(Center.X-Size div 2,Center.Y-Hauteur,Center.Z-Size div 2,A);
  DefineValue3D(Center.X+Size div 2,Center.Y+Hauteur,Center.Z+Size div 2,B);
  TCuboid3D.Init(6,12,A,B,AImmaterial);
  for i:=0 to 1 do for j:=0 to 1 do
  Points^.Insert(New(PPoint,Init(Center.X-Size div 2+i*Size,Center.Y,Center.Z-Size div 2+j*Size,Color)));
  Points^.Insert(New(PPoint,Init(Center.X,Center.Y-Hauteur,Center.Z,Color)));
  Points^.Insert(New(PPoint,Init(Center.X,Center.Y+Hauteur,Center.Z,Color)));
  for i:=0 to 3 do Lines^.Insert(New(PLine,Init(PPoint(Points^.At(Links[i,0])),PPoint(Points^.At(Links[i,1])),Color)));
  for i:=0 to 3 do Lines^.Insert(New(PLine,Init(PPoint(Points^.At(i)),PPoint(Points^.At(4)),Color)));
  for i:=0 to 3 do Lines^.Insert(New(PLine,Init(PPoint(Points^.At(i)),PPoint(Points^.At(5)),Color)));
end;

var
  Pourri:PWorld;
  Myself:PCamera;

Procedure InvocationOfTheWorld;
var A,B:TCoord3D;
begin
  DefineValue3D(-50 shl Precision,-800 shl Precision,-50 shl Precision,A);
  DefineValue3D(50 shl Precision,10 shl Precision,150 shl Precision,B);
  Pourri:=New(PWorld,Init(4,1,A,B));

  Pourri^.Obj3D^.Insert(New(PCadrillage,Init(-50 shl Precision,-50 shl Precision,
  50 shl Precision,50 shl Precision,40 shl Precision,25 shl Precision,2,True)));

  Pourri^.Obj3D^.Insert(New(PCadrillage,Init(-50 shl Precision,50 shl Precision,
  50 shl Precision,150 shl Precision,40 shl Precision,25 shl Precision,10,True)));

  DefineValue3D(-30 shl Precision,-80 shl Precision,20 shl Precision,A);
  Pourri^.Obj3D^.Insert(New(PCube,Init(A,50 shl Precision,12,False)));

  DefineValue3D(5 shl Precision,10 shl Precision,120 shl Precision,A);
  Pourri^.Obj3D^.Insert(New(POctaedre,Init(A,30 shl Precision,14,False)));

  Myself:=New(PCamera,Init(0,0,0,12,0));
  Pourri^.Cameras^.Insert(Myself);

end;

var Speed:Boolean;
    CamMove:Vector3D;

begin
  WriteLn('Eh bien voil… voil…...');
  WriteLn('C''est moche, y''a pas beaucoup d''objets, et l''espace est tout petit!!');
  WriteLn('En plus y''a plein de bugs, et tout est calcul‚ avec un tas d''approximations.');
  WriteLn('Mais c''est quand mˆme un moteur 3D !!!');
  WriteLn;
  WriteLn('Pour se d‚placer, utilisez les flŠches');
  WriteLn('Pour regarder en haut et en bas, utilisez les touches "Q" et "W"');
  WriteLn('Pour marcher en crabe, utilisez Alt+Gauche et Alt+Droite');
  WriteLn('Pour se d‚placer verticalement, utilisez Alt+Q et Alt+W');
  Readkey;

  MCGAScreen;
  CosAndSin;
  AdvKeyOn;
  InvocationOfTheWorld;
  Repeat
    Pourri^.Draws(Myself);
    Speed:=not(Speed);
    if Speed then Pixel(319,199,0) else Pixel(319,199,15);
    Draw(318,198,319,199);
    if K_Left or K_Right or K_Q or K_W then begin
      if not(K_Alt or K_AltGr) then begin
        if K_Left then Inc(Myself^.CamAngle);
        if K_Right then Dec(Myself^.CamAngle);
        if K_W then Inc(Myself^.HeadAngle);
        if K_Q then Dec(Myself^.HeadAngle);
        Myself^.CalculBazar;
      end else begin
        if K_Left then With Myself^ do begin
          CamMove.X:=-Left.X;
          CamMove.Y:=-Left.Y;
          CamMove.Z:=-Left.Z;
          Pourri^.Collisions(CamPos,CamMove);
          AddValue3D(CamPos,CamMove);
        end;
        if K_Right then With Myself^ do begin
          CamMove.X:=Left.X;
          CamMove.Y:=Left.Y;
          CamMove.Z:=Left.Z;
          Pourri^.Collisions(CamPos,CamMove);
          AddValue3D(CamPos,CamMove);
        end;
        if K_Q then With Myself^ do begin
          CamMove.X:=-Vertical.X div PrecFactor;
          CamMove.Y:=-Vertical.Y;
          CamMove.Z:=-Vertical.Z div PrecFactor;
          Pourri^.Collisions(CamPos,CamMove);
          AddValue3D(CamPos,CamMove);
        end;
        if K_W then With Myself^ do begin
          CamMove.X:=Vertical.X div PrecFactor;
          CamMove.Y:=Vertical.Y;
          CamMove.Z:=Vertical.Z div PrecFactor;
          Pourri^.Collisions(CamPos,CamMove);
          AddValue3D(CamPos,CamMove);
        end;
      end;
    end;
    if K_Up then With Myself^ do begin
      CamMove.X:=Front.X div PrecFactor;
      CamMove.Y:=Front.Y;
      CamMove.Z:=Front.Z div PrecFactor;
      Pourri^.Collisions(CamPos,CamMove);
      AddValue3D(CamPos,CamMove);
    end;
    if K_Down then With Myself^ do begin
      CamMove.X:=-Front.X div PrecFactor;
      CamMove.Y:=-Front.Y;
      CamMove.Z:=-Front.Z div PrecFactor;
      Pourri^.Collisions(CamPos,CamMove);
      AddValue3D(CamPos,CamMove);
    end;

    AfficheAll;
{    Delay(10);}
    Pourri^.Clear;
  Until K_Esc;
  CloseScreen;
  AdvKeyOff;
  Dispose(Pourri,Done);
end.