

Uses Crt,Dos;

var
  Machin:SearchRec;
  Lecteur:String;
  Found:Boolean;

begin
{$I-}
  if ParamCount=1 then Lecteur:=ParamStr(1) else Lecteur:='C';
  FindFirst(Lecteur+':\*.*',AnyFile,Machin);
  Found:=DosError=0;
{$I+}
  if Found then begin
{    Write('OK');      }
    Halt(0);
  end else begin
{    Write('PAS OK');}
    Halt(25);
  end;

end.