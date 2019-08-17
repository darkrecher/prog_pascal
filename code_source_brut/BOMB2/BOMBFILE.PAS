Unit BombFile;


Interface

Uses DosFile,MCGAGraf;

var Sprites:PScreen;

Function Exists(FileName:string):Boolean;
Procedure Decompress(Fichier:Handle;Dest:PScreen);
Function LoadData:Boolean;
Procedure EndLoadData;

Implementation

Function Exists(FileName:string):Boolean;
var H:Handle;
begin
  if FOpen(H,FileName) then begin
    FClose(H);
    Exists:=True;
  end else begin
    WriteLn('impossible de trouver le fichier ',FileName);
    Exists:=False;
  end;
end;


Procedure Decompress(Fichier:Handle;Dest:PScreen);
type
  PBlock=^TBlock;
  TBlock=Array[0..32767] of Byte;

var BLockSize:LongInt;ScreenPos,BlockPos:Word;PieceLength,i,Value:Byte;
Block:PBLock;

  Function GetOneByte:Byte;
  begin
    if BlockPos=32768 then begin
      if BlockSize<32768 then FRead(Fichier,Block^[0],BlockSize) else begin
        FRead(Fichier,Block^[0],32768);
        Dec(BlockSize,32768);
      end;
      BlockPos:=0;
    end;
    GetOneByte:=Block^[BlockPos];
    Inc(BlockPos);
  end;

begin
  ScreenPos:=0;
  FRead(Fichier,BlockSize,4);
  New(Block);
  BlockPos:=32768;
  repeat
    PieceLength:=GetOneByte;
    if PieceLength>128 then begin
      Value:=GetOneByte;
      for i:=0 to 256-PieceLength do Dest^[(ScreenPos+i) div 320,(ScreenPos+i) mod 320]:=Value;
      Inc(ScreenPos,257-PieceLength);
    end else for i:=0 to PieceLength do begin
      Dest^[(ScreenPos) div 320,(ScreenPos) mod 320]:=GetOneByte;
      Inc(ScreenPos,1);
    end;
  Until ScreenPos=64000;
  Dispose(Block);
end;

Function LoadData:Boolean;
var H:Handle;
begin
  if Exists('Bombman.spr') and Exists('Bombman.pal') then begin
    New(Sprites);
    LoadData:=True;
    FOpen(H,'Bombman.spr');
    Decompress(H,Sprites);
    LoadPalette('bombman.pal');
    FClose(H);
  end else LoadData:=False;
end;

Procedure EndLoadData;
begin
  Dispose(Sprites);
end;

end.