Uses Crt;

var
  C:Char;

begin
  Write('A=PLASMA   B=STARS');
  C:=Readkey;
  if C='a' then Halt(1);
 { if C='b' then Halt(2);}
end.