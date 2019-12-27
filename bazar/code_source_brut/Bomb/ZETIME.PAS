Unit ZeTime;

interface

Procedure TimeControlOn;
Procedure TimeControlOff;
Procedure PeriodicPr; interrupt;
Procedure SetChronometer;

var ElapsedTime:LongInt;

implementation

uses Dos;

var
  OldInt1C:Pointer;

Procedure PeriodicPr;
var varAX,varBX,varCX,varDX:Word;
    varOF,varDF,varIF,varTF,varSF,varZF:Boolean;
begin
  asm
    mov AX,varAX
    mov BX,varBX
    mov CX,varCX
    mov DX,varDX
    pushf
  end;
  Inc(ElapsedTime);
  asm
    mov varAX,AX
    mov varBX,BX
    mov varCX,CX
    mov varDX,DX
    popf
  end;
end;

Procedure TimeControlOn;
begin
  GetIntVec($1C,OldInt1C);
  SetIntVec($1C,@PeriodicPr);
  ElapsedTime:=0;
end;

Procedure TimeControlOff;
begin
  SetIntVec($1C,OldInt1C);
end;

Procedure SetChronometer;
begin
  ElapsedTime:=0;
end;

end.
