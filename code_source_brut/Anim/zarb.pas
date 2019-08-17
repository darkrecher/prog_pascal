Uses Crt,MCGAGraf;

Const
  MorphSpeed=4;

var
  Screen:PScreen;

Function Morph:Boolean;
var i,j:Integer;Result:Boolean;Source,Dest:Byte;
begin
  Result:=False;
  for i:=0 to 319 do for j:=0 to 199 do begin
    Source:=Screen^[j,i];
    Dest:=Buffer^[j,i];
    if Abs(Source-Dest)<MorphSpeed then Buffer^[j,i]:=Source else begin
      if Source<Dest then begin
        Result:=True;
        Dec(Buffer^[j,i],MorphSpeed);
      end;
      if Source>Dest then begin
        Result:=True;
        Inc(Buffer^[j,i],MorphSpeed);
      end;
    end;
  end;
  Morph:=Result;
  AfficheAll;
end;

Procedure MakeImage;
var i,j,x,y:Integer;Choice,A,B,C,D:Byte;
begin
  Choice:=Random(12);
  A:=Random(10)+1;
  B:=Random(10)+1;
  C:=Random(7)-3;
  D:=Random(7)-3;
  for i:=0 to 319 do for j:=0 to 199 do begin
    x:=i-160;
    y:=j-100;
    if y=0 then y:=1;
    if x=0 then x:=1;
    Case Choice of
      0:Screen^[j,i]:= (x*16 div y+y*16 div x+y+x)*A div B ;
      1:Screen^[j,i]:=(x*16 div y+y*16 div x)*A div B ;
      2:Screen^[j,i]:=x*y*A div B ;
      6:Screen^[j,i]:=x*y*y div B ;
      7:Screen^[j,i]:=x*x*y div B ;
      11:Screen^[j,i]:=(x*x*y+y*y*x) div B ;
      4:Screen^[j,i]:=(x*y div 2+x*y*y div 4)*A div B ;
      5:Screen^[j,i]:=(D*x*x+x*y)*A div B ;
      3:Screen^[j,i]:=(D*y*y+x*y)*A div B ;
      8..9:Screen^[j,i]:=(D*y*y+D*x*x+x*y) div B ;
      10:Screen^[j,i]:=(D*y*y-D*x*x+x*y) div B ;
    end;
  end;
end;

var i,j,x,y:Integer;

begin
  New(Screen);
  MCGAScreen;
  Degrade(0,0,0,0,63,0,0,63);
  Degrade(64,0,0,63,127,0,63,63);
  Degrade(128,0,63,63,191,0,63,0);
  Degrade(192,0,63,0,255,0,0,0);
  DefinePal;
  Randomize;

  for i:=0 to 319 do for j:=0 to 199 do begin
    x:=i-160;
    y:=j-100;
    if y=0 then y:=1;
    if x=0 then x:=1;
    Buffer^[j,i]:=(y*y+30*x*x+y*y*y) div 64 ;
  end;
  AfficheAll;
  Delay(250);

  Repeat
    MakeImage;
    While Morph and not(keypressed) do;
    Delay(500);
  Until keypressed;
  CloseScreen;
  Dispose(Screen);
end.
