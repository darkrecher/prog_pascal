Uses Crt;

 {  calculatrice. Bon ‡a parait con comme ‡a, mais c'est difficile
 … structurer un machin pareil. Il faut respecter les parenthŠses et
 les priorit‚s d'op‚ration }

Type
  Characters=Set of Char;

var
  S:string;
  Pos:Byte;

Function NewRead(Abs,Ord,LMax:Integer;Chars:Characters;var S:String):Boolean;
var
  i,x,y,Cursor:Byte;
  S2:string;
  c:char;
begin
  x:=Abs;
  y:=Ord;
  Cursor:=Length(S)+1;
  repeat
    Gotoxy(x,y);
    For i:=0 to LMax-1 do Write(' ');
    GotoXY(X,Y);
    Write(s);
    GotoXY(X+Cursor-1,Y);
    c:=Readkey;
    case c of
      #8:if Length(S)>0 then begin
        S2:='';
        for i:=1 to Length(S) do if i<>Cursor-1 then S2:=S2+S[i];
        S:=S2;
        Dec(Cursor);
      end;
      #0:begin
        c:=Readkey;
        Case C of
          #75:if Cursor>1 then Dec(Cursor);
          #77:if Cursor<Length(S)+1 then Inc(Cursor);
        end;
      end;
      else if (Length(s)<LMax) and (c in Chars) then begin
        Insert(C,S,Cursor);
        Inc(Cursor);
      end;
    end;
  until (c=#13) or (c=#27);
  NewRead:=c=#13;
end;

Procedure Error;
begin
  Write('Il y a une erreur!!!!');
  Readkey;
  Halt;
end;

Function EvaluateExpression:LongInt;

Function EvaluateFactor:LongInt;
var Number:LongInt;
begin
  Number:=0;
  if S[Pos]='(' then begin
    Inc(Pos);
    Number:=EvaluateExpression;
    if S[Pos]=')' then Inc(Pos) else Error;
  end else if S[Pos] in ['0'..'9'] then While S[Pos] in ['0'..'9'] do begin
    Number:=Number*10+Ord(S[Pos])-48;
    Inc(Pos);
  end else Error{!!!!};
  EvaluateFactor:=Number;
end;

Function EvaluateTerm:LongInt;
var Number:LongInt;
begin
  Number:=EvaluateFactor;
  While S[Pos] in ['*','/'] do begin
    if S[Pos]='*' then begin
      Inc(Pos);
      Number:=Number*EvaluateFactor;
    end else if S[Pos]='/' then begin
      Inc(Pos);
      Number:=Number div EvaluateFactor;
    end;
  end;
  EvaluateTerm:=Number;
end;

var signe:ShortInt;Number:LongInt;
begin
  if S[Pos]='+' then Signe:=1;
  if S[Pos]='-' then Signe:=-1;
  if S[Pos] in ['+','-'] then Inc(Pos) else Signe:=1;
  Number:=EvaluateTerm*Signe;
  While S[Pos] in ['+','-'] do begin
    if S[Pos]='+' then begin
      Inc(Pos);
      Inc(Number,EvaluateTerm);
    end else begin
      Inc(Pos);
      Dec(Number,EvaluateTerm);
    end;
  end;
  EvaluateExpression:=Number;
end;

var Resultat:LongInt;
begin
  NewRead(1,1,255,['0'..'9','+','-','*','/','(',')'],S);
  WriteLn;
  Pos:=1;
  Resultat:=EvaluateExpression;
  if Pos-1<>Length(S) then Error;
  Write(Resultat);
  Readkey;
end.
