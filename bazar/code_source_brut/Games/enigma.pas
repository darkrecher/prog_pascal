Uses Crt;

Type
  TLine=Record
    Line:Array[0..65532] of Byte;
    Size:Word;
  end;
  PLine=^TLine;

var
  Line1,Line2:PLine;
  C:Char;
  i:Word;

Function NewStr(X:Word):string;
var S:string;
begin
  Str(X,S);
  NewStr:=S;
end;

Procedure WriteLine(Source:PLine);
var i:Word;Compteur:Word;
begin
  TextColor(10);
  GotoXY(5-Length(NewStr(Source^.Size)),WhereY);
  Write(NewStr(Source^.Size));
  TextColor(7);
  GotoXY(6,WhereY);
  Compteur:=5;
  if Source^.Size<>0 then for i:=0 to Source^.Size-1 do begin
    Write(NewStr(Source^.Line[i]));
    Inc(Compteur);
    if Compteur=1920 then begin
      Compteur:=0;
      TextColor(12);
      Write('Appuyez sur une touche pour voir la suite');
      C:=Readkey;
      if C=#27 then begin
        Dispose(Line1);
        Halt;
      end;
      WriteLn;
      TextColor(7);
    end;
  end;
  WriteLn;
end;

Function FindNewLine(Source:PLine):PLine;
var Value,Quantity:Byte;Dest:PLine;i,Cursor:Word;

  Procedure TakeNewValue(Which:Word);
  begin
    Quantity:=1;
    Value:=Source^.Line[Which];
  end;

  Procedure WriteInfo;
  begin
    Inc(Dest^.Size,2);
    Dest^.Line[Cursor]:=Quantity;
    Dest^.Line[Cursor+1]:=Value;
    Inc(Cursor,2);
    if Cursor>65530 then begin
      TextColor(12);
      Write('Depassement de capacit‚');
      Readkey;
      Halt;
    end;
  end;

begin
  New(Dest);
  Dest^.Size:=0;
  if Source^.Size<>0 then begin
    Cursor:=0;
    TakeNewValue(0);
    if Source^.Size>1 then for i:=1 to Source^.Size-1 do begin
      if Source^.Line[i]=Value then Inc(Quantity)
      else begin
        WriteInfo;
        TakeNewValue(i);
      end;
    end;
    WriteInfo;
  end;
  FindNewLine:=Dest;
end;

begin
  ClrScr;
  Randomize;
  New(Line1);
  Line1^.Size:=1;
  Line1^.Line[0]:=1;
  Repeat
    WriteLine(Line1);
    C:=Readkey;
    Line2:=FindNewLine(Line1);
    Dispose(Line1);
    Line1:=Line2;
  Until C=#27;
  Dispose(Line1);
end.