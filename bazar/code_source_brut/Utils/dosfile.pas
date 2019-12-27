unit
  dosfile;

interface

type
  handle=word;

const
  posbeginning=0;
  pospointer=1;
  posendfile=2;
  dosfileerror:Word=0;
  filedatasize:Word=0;
  filepointerpos:LongInt=0;
  openread=           $00;
  openwrite=          $01;
  openreadwrite=      $02;
  openFCBallownothing=$00;
  openallownothing=   $10;
  openallowread=      $20;
  openallowwrite=     $30;
  openallowreadwrite= $40;
  openchildallow=     $00;
  openchilddeny=      $80;

function fcreate(var h:handle;nomfich:string):Boolean;
function fopen(var h:handle;nomfich:string):Boolean;
function fopenex(var h:handle;nomfich:string;mode:Byte):Boolean;
function fclose(var h:handle):Boolean;
function fread(var h:handle;var buf;nombre:word):Boolean;
function fwrite(var h:handle;var buf;nombre:word):Boolean;
function fseek(var h:handle;distance:longint;ref:byte):Boolean;

implementation

uses
  dos;

function fcreate(var h:handle;nomfich:string):Boolean;
var
  reg:registers;
  nom:string;
begin
  nom:=nomfich+#0;
  reg.ah:=$3c;
  reg.cx:=$00;
  reg.ds:=seg(nom);
  reg.dx:=ofs(nom)+1;
  intr($21,reg);
  h:=reg.ax;
  if (reg.Flags and fCarry)=0 then begin
    fcreate:=True;
    dosfileerror:=0;
  end else begin
    fcreate:=False;
    dosfileerror:=reg.ax;
  end;
end;

function fopen(var h:handle;nomfich:string):Boolean;
var
  reg:registers;
  nom:string;
begin
  nom:=nomfich+#0;
  reg.ax:=$3d02;
  reg.ds:=seg(nom);
  reg.dx:=ofs(nom)+1;
  intr($21,reg);
  h:=reg.ax;
  if (reg.Flags and fCarry)=0 then begin
    fopen:=True;
    dosfileerror:=0;
  end else begin
    fopen:=False;
    dosfileerror:=reg.ax;
  end;
end;

function fopenex(var h:handle;nomfich:string;mode:byte):Boolean;
var
  reg:registers;
  nom:string;
begin
  nom:=nomfich+#0;
  reg.ah:=$3d;
  reg.al:=mode;
  reg.ds:=seg(nom);
  reg.dx:=ofs(nom)+1;
  intr($21,reg);
  h:=reg.ax;
  if (reg.Flags and fCarry)=0 then begin
    fopenex:=True;
    dosfileerror:=0;
  end else begin
    fopenex:=False;
    dosfileerror:=reg.ax;
  end;
end;

function fclose(var h:handle):Boolean;
var
  reg:registers;
begin
  reg.ah:=$3e;
  reg.bx:=h;
  intr($21,reg);
  if (reg.Flags and fCarry)=0 then begin
    fclose:=True;
    dosfileerror:=0;
  end else begin
    fclose:=False;
    dosfileerror:=reg.ax;
  end;
end;

function fread(var h:handle;var buf;nombre:word):Boolean;
var
  reg:registers;
begin
  reg.ah:=$3f;
  reg.bx:=h;
  reg.cx:=nombre;
  reg.ds:=seg(buf);
  reg.dx:=ofs(buf);
  intr($21,reg);
  if (reg.Flags and fCarry)=0 then begin
    fread:=True;
    dosfileerror:=0;
    filedatasize:=reg.ax;
  end else begin
    fread:=False;
    dosfileerror:=reg.ax;
  end;
end;

function fwrite(var h:handle;var buf;nombre:word):Boolean;
var
  reg:registers;
begin
  reg.ah:=$40;
  reg.bx:=h;
  reg.cx:=nombre;
  reg.ds:=seg(buf);
  reg.dx:=ofs(buf);
  intr($21,reg);
  if (reg.Flags and fCarry)=0 then begin
    fwrite:=True;
    dosfileerror:=0;
    filedatasize:=reg.ax;
  end else begin
    fwrite:=False;
    dosfileerror:=reg.ax;
  end;
end;

function fseek(var h:handle;distance:longint;ref:byte):Boolean;
var
  reg:registers;
begin
  reg.ah:=$42;
  reg.al:=ref;
  reg.bx:=h;
  reg.cx:=memw[seg(distance):ofs(distance)+2];
  reg.dx:=memw[seg(distance):ofs(distance)];
  intr($21,reg);
  if (reg.Flags and fCarry)=0 then begin
    fseek:=True;
    dosfileerror:=0;
    filepointerpos:=(LongInt(reg.DX) shl 16)+reg.AX;
  end else begin
    fseek:=False;
    dosfileerror:=reg.ax;
  end;
end;

end.