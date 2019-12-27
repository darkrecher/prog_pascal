Uses Dosfile,Crt;

{  programme qui extrait l'image d'un fichier LBM.
   un nouveau fichier est cr‚‚, il contient l'image
   l'image n'est pas compress‚e du tout.
   voir LBMMCGA.TXT}

Type
  PScreen=^TScreen;
  TScreen=Array[0..63999] of Byte;

Var
  Fichier:handle;
  BlockName:String[4];
  BlockSize,ScreenPos:LongInt;
  Screen:PScreen;
  i,PieceLength:Byte;
  Pixels:Array[0..127] of Byte;
  EndFile:Boolean;
  PictureCoord:Array[0..3] of Integer;{x1,y1,x2,y2}
  Error:Integer;

Function LireNbr(h:Handle;Size:Byte):LongInt;
var Buf:Array[0..3] of Byte;i:Byte;Nbr:LongInt;
begin
  if FRead(h,Buf,Size) then begin
    Nbr:=0;
    for i:=0 to Size-1 do Nbr:=(Nbr shl 8)+Buf[i];
    LireNbr:=Nbr;
  end else LireNbr:=0;
end;

Procedure BadParam;
begin
  WriteLn('You might have foired in your writation of the paramŠtres');
  WriteLn('Please consult the help file to use this mega-programme');
  Halt;
end;

begin
  if ParamCount<>6 then BadParam else for i:=0 to 3 do begin
    Val(ParamStr(i+3),PictureCoord[i],Error);
    if Error<>0 then BadParam;
  end;
  if FOpen(Fichier,ParamStr(1)) then begin
    New(Screen);
    BlockName:='    ';
    FRead(Fichier,BlockName[1],4);
    if BlockName='FORM' then begin
      FSeek(Fichier,12,posbeginning);
      Repeat
        FRead(Fichier,BlockName[1],4);
        if FileDataSize=4 then begin
          EndFile:=False;
          BlockSize:=LireNbr(Fichier,4);
          if not(BlockName='BODY') then
          Fseek(Fichier,BlockSize+(BlockSize and 1),PosPointer);{les blocs commence toujours … une adresse paire}
        end else EndFile:=True;                                 {c'est bizarre mais c'est comme ‡a}
      Until (EndFile) or (BlockName='BODY');
    end else WriteLn('Ce n''est pas un fichier LBM!!');
    if EndFile then WriteLn('Il doit y avoir un petit problŠme dans le fichier') else begin
      Write('Decompression du fichier lbm');
      ScreenPos:=0;
      repeat
        FRead(Fichier,PieceLength,1);
        if PieceLength>128 then begin
          FRead(Fichier,Pixels[0],1);
          for i:=0 to 256-PieceLength do Screen^[ScreenPos+i]:=Pixels[0];
          Inc(ScreenPos,257-PieceLength);
        end else begin
          FRead(Fichier,Pixels,PieceLength+1);
          Move(Pixels,Screen^[ScreenPos],PieceLength+1);
          Inc(ScreenPos,PieceLength+1);
        end;
        GotoXY(31,WhereY);
        Write(ScreenPos div 640,'%');
      Until ScreenPos=64000;
      FClose(Fichier);
      WriteLn;
      Write('Cr‚ation de ',ParamStr(2));
      if FCreate(Fichier,ParamStr(2)) then for i:=PictureCoord[1] to PictureCoord[3] do begin
        FWrite(Fichier,Screen^[i*320+PictureCoord[0]],PictureCoord[2]-PictureCoord[0]+1);
        GotoXY(14+Length(ParamStr(2)),WhereY);
        Write(((i-PictureCoord[1]) div (PictureCoord[3]-PictureCoord[1]))*100,'%');
      end;
    end;
    FClose(Fichier);
    Dispose(Screen);
  end else WriteLn('On ne peut pas ouvrir le fichier');
end.