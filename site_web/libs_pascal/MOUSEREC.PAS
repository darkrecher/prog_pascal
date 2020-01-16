unit mouserec;

interface

  type
    TCursor=Array[0..31] of Word;
  var
    MouseX,MouseY:Integer;
    MouseExists:Boolean;

  const
    ACross:TCursor=(65279,65279,65279,65279,65279,65279,65535,897,
                    65535,65279,65279,65279,65279,65279,65279,65535,
                    256,256,256,256,256,256,0,64638,
                    0,256,256,256,256,256,256,0);

  Procedure InitMouse;
  Procedure HideMouse;
  Procedure ShowMouse;
  Procedure GetPosition;
  Function Bouton(Button:Integer):Boolean;
  Procedure ChangeCursor(X,Y:Byte;Segm,Ofst:Word);

implementation

uses Dos;

Procedure InitMouse;
Var Reg:Registers;
begin
  Reg.AX:=$0000;
  Intr($33,Reg);
  if Reg.AX=$FFFF then begin
    Reg.AX:=$0001;
    Intr($33,Reg);
    MouseExists:=True;
  end;
end;

Procedure HideMouse;
Var Reg:Registers;
begin
  if MouseExists then begin
    Reg.AX:=$0002;
    Intr($33,Reg);
  end;
end;

Procedure ShowMouse;
Var Reg:Registers;
begin
  if MouseExists then begin
    Reg.AX:=$0001;
    Intr($33,Reg);
  end;
end;

Procedure GetPosition;
Var Reg:Registers;
begin
  if MouseExists then begin
    Reg.AX:=$0003;
    Intr($33,Reg);
    MouseX:=Reg.CX div 2;
    MouseY:=Reg.DX;
  end else begin
    MouseX:=-1;
    MouseY:=-1;
  end;
end;

Function Bouton(Button:Integer):Boolean;
Var Reg:Registers;
begin
  if MouseExists then begin
    Reg.AX:=$0003;
    Intr($33,Reg);
    Bouton:=Reg.BX and (1 shl (Button-1))>0;
  end else Bouton:=False;
end;

Procedure ChangeCursor(X,Y:Byte;Segm,Ofst:Word);
var Reg:Registers;
begin
  if MouseExists then begin
    Reg.AX:=$0009;
    Reg.BX:=X;
    Reg.CX:=Y;
    Reg.ES:=Segm;
    Reg.DX:=Ofst;
    Intr($33,Reg);
  end;
end;


end.