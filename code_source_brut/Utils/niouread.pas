uses
  crt;

function NewRead(LMax:Integer):String;
var
  i,x,y:Byte;
  s:string;
  c:char;
begin
  x:=WhereX;
  y:=WhereY;
  s:='';
  repeat
    Gotoxy(x,y);
    ClrEol;
    Write(s);
    c:=Readkey;
    case c of
      #0:Readkey;
      #8:if Length(s)>0 then dec(s[0]);
      else if Length(s)<LMax then s:=s+c;
    end;
  until c=#13;
  NewRead:=s;
end;

begin
  NewRead(15);
end.