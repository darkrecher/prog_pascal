Uses Crt,Keyboard;

Type
  TAuthorized=set of Char;

Const
  Password={Habiba16777216,;:!'}'g`aha`05666105';
  Authorized=['a'..'z','A'..'Z','1'..'9',' ',',','''',';','?','.',':','!'];

var
  Answer:string;
  i:Integer;

Function SmallReadkey:Char;
begin
  While not(K_Enter) do;
  if K_A then SmallReadkey:='a' else
  if K_H then SmallReadkey:='h' else
  if K_B then SmallReadkey:='b' else
  if K_I then SmallReadkey:='i' else
  if K_1 then SmallReadkey:='1' else
  if K_2 then SmallReadkey:='2' else
  if K_6 then SmallReadkey:='6' else
  if K_7 then SmallReadkey:='7' else
  if K_Z then SmallReadkey:=#13 else
  SmallReadkey:='h';
  While K_Enter do;
end;

function NewReadLn(LMax:Integer):String;
var
  j,x,y:Byte;
  s:string;
  c:char;
  Stop:Boolean;
begin
  x:=WhereX;
  y:=WhereY;
  s:='';
  repeat
    Gotoxy(x,y);
    ClrEol;
    for j:=1 to Length(S) do Write('*');
    c:=SmallReadkey;
    if (Length(s)<LMax) and (c in Authorized) then s:=s+c;
  until c=#13;
  NewReadLn:=s;
  WriteLn;
end;

begin
  ClrScr;
  AdvKeyOn;
  Answer:='';
  While Answer<>Password do begin
    Write('Mot de passe : ');
    Answer:=NewReadLn(20);
    for i:=1 to Length(Answer) do Dec(Byte(Answer[i]));
    WriteLn('Mauvais mot de passe');
  end;
  ClrScr;
  AdvKeyOff;
end.

