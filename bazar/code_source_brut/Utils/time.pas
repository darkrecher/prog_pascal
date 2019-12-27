Uses Crt,Dos;

var
  OldInt1C:Pointer;
  Clock:Word;
  Second:Word;
  MilSecond:LongInt;
  X:LongInt;

{$F+}

Procedure TimeControl; interrupt;
begin
  Inc(Clock);
  Second:=(LongInt(Clock)*1000) div 18206;
  if Clock=18206 then begin
    Clock:=0;
    Second:=0;
    Inc(MilSecond);
  end;
end;

{$F-}

begin
  ClrScr;
  Clock:=0;
  Second:=0;
  MilSecond:=0;
  GetIntVec($1C,OldInt1C);
  SetIntVec($1C,@TimeControl);
  Repeat
    GotoXY(5,5);
    X:=MilSecond*1000+Second;
    WriteLn(X,'  ');
    Write(Clock,'  ');
  Until keypressed;
  SetIntVec($1C,OldInt1C);
end.