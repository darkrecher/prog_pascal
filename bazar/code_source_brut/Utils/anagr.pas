uses Crt,Print;

var C:Char;
Compteur:Byte;

procedure Anagramme(Source,Dest:String);
var i:Integer;s:String;
begin
  if Source<>'' then for i:=1 to Length(Source) do begin
    s:=Source;
    Delete(s,i,1);
    Anagramme(s,Dest+Source[i]);
  end else begin
    Inc(Compteur);
    if Compteur<10 then Write(Dest+' ') else begin
      WriteLn(Dest);
      Compteur:=0;
    end;
    if keypressed then Halt;
    C:=Readkey;
    if c='q' then Halt;
  end;
end;

begin
  Compteur:=0;
  Writeln;
  Anagramme('ABCD','');
end.