unit keyboard;

interface

const

  K_Esc:Boolean=False;

  K_F1:Boolean=False;
  K_F2:Boolean=False;
  K_F3:Boolean=False;
  K_F4:Boolean=False;
  K_F5:Boolean=False;
  K_F6:Boolean=False;
  K_F7:Boolean=False;
  K_F8:Boolean=False;
  K_F9:Boolean=False;
  K_F10:Boolean=False;
  K_F11:Boolean=False;
  K_F12:Boolean=False;

  K_Impr:Boolean=False;
  K_Arr:Boolean=False;
  K_Pause:Boolean=False;

  K_Petit2:Boolean=False;
  K_Sh1:Boolean=False;
  K_Sh2:Boolean=False;
  K_Sh3:Boolean=False;
  K_Sh4:Boolean=False;
  K_Sh5:Boolean=False;
  K_Sh6:Boolean=False;
  K_Sh7:Boolean=False;
  K_Sh8:Boolean=False;
  K_Sh9:Boolean=False;
  K_Sh0:Boolean=False;
  K_Parent:Boolean=False;
  K_Egal:Boolean=False;
  K_Back:Boolean=False;

  K_Inser:Boolean=False;
  K_Home:Boolean=False;
  K_PgUp:Boolean=False;

  K_Verrnum:Boolean=False;
  K_Div:Boolean=False;
  K_Mul:Boolean=False;
  K_Moins:Boolean=False;

  K_Tab:Boolean=False;
  K_A:Boolean=False;
  K_Z:Boolean=False;
  K_E:Boolean=False;
  K_R:Boolean=False;
  K_T:Boolean=False;
  K_Y:Boolean=False;
  K_U:Boolean=False;
  K_I:Boolean=False;
  K_O:Boolean=False;
  K_P:Boolean=False;
  K_Chapeau:Boolean=False;
  K_Dollar:Boolean=False;
  K_Enter:Boolean=False;

  K_Del:Boolean=False;
  K_Fin:Boolean=False;
  K_PgDown:Boolean=False;

  K_7:Boolean=False;
  K_8:Boolean=False;
  K_9:Boolean=False;
  K_Plus:Boolean=False;

  K_Caps:Boolean=False;
  K_Q:Boolean=False;
  K_S:Boolean=False;
  K_D:Boolean=False;
  K_F:Boolean=False;
  K_G:Boolean=False;
  K_H:Boolean=False;
  K_J:Boolean=False;
  K_K:Boolean=False;
  K_L:Boolean=False;
  K_M:Boolean=False;
  K_ugrave:Boolean=False;
  K_Etoile:Boolean=False;

  K_4:Boolean=False;
  K_5:Boolean=False;
  K_6:Boolean=False;

  K_Shift:Boolean=False;
  K_Inf:Boolean=False;
  K_W:Boolean=False;
  K_X:Boolean=False;
  K_C:Boolean=False;
  K_V:Boolean=False;
  K_B:Boolean=False;
  K_N:Boolean=False;
  K_Virgule:Boolean=False;
  K_PointVirgule:Boolean=False;
  K_2Points:Boolean=False;
  K_Exclam:Boolean=False;

  K_Up:Boolean=False;

  K_1:Boolean=False;
  K_2:Boolean=False;
  K_3:Boolean=False;

  K_Ctrl:Boolean=False;
  K_WDemarrer:Boolean=False;
  K_Alt:Boolean=False;
  K_Space:Boolean=False;
  K_AltGr:Boolean=False;
  K_WMenu:Boolean=False;

  K_Left:Boolean=False;
  K_Down:Boolean=False;
  K_Right:Boolean=False;

  K_0:Boolean=False;
  K_Point:Boolean=False;

procedure AdvKeyOn;
procedure AdvKeyOff;

implementation

uses
  Dos;

var
  OldInt9:Pointer;

const
  Ext1:Boolean=False;
  Ext2:Boolean=False;

{$f+}
procedure NewInt9;interrupt;
var
  p:Word;
  Make:Boolean;
begin
  asm
    cli
  end;
  p:=port[$60];
  case p of
    224:ext1:=true;
    225:ext2:=true;
    else begin
      if ext1 and (p and 127=42) then p:=0;
      if ext2 and (p and 127=29) then p:=0;
      if p<>0 then begin
        Make:=p and 128=0;
        p:=p and 127;
        if ext1 then p:=p or 256;
        if ext2 then p:=p or 512;
{ne pas toucher ce qu'il y a avant}
{ si on veut savoir en permanence si la touche est appuy‚e :
    if p=$.... then K_....:=Make;  }
{ si on veut uniquement savoir si elle est appuy‚e en dernier :
    K_....:=(p=....) and Make; }
        If p=$1 then K_Esc:=Make;

        if p=$3B then K_F1:=Make;
        if p=$3C then K_F2:=Make;
        if p=$3D then K_F3:=Make;
        if p=$3E then K_F4:=Make;
        if p=$3F then K_F5:=Make;
        if p=$40 then K_F6:=Make;
        if p=$41 then K_F7:=Make;
        if p=$42 then K_F8:=Make;
        if p=$43 then K_F9:=Make;
        if p=$44 then K_F10:=Make;
        if p=$57 then K_F11:=Make;
        if p=$58 then K_F12:=Make;

        if p=$45 then K_Impr:=Make;
        if p=$46 then K_Arr:=Make;
        if p=$245 then K_Pause:=Make;

        if p=$29 then K_Petit2:=Make;
        if p=$2 then K_Sh1:=Make;
        if p=$3 then K_Sh2:=Make;
        if p=$4 then K_Sh3:=Make;
        if p=$5 then K_Sh4:=Make;
        if p=$6 then K_Sh5:=Make;
        if p=$7 then K_Sh6:=Make;
        if p=$8 then K_Sh7:=Make;
        if p=$9 then K_Sh8:=Make;
        if p=$a then K_Sh9:=Make;
        if p=$b then K_Sh0:=Make;
        if p=$c then K_Parent:=Make;
        if p=$d then K_Egal:=Make;
        if p=$e then K_Back:=Make;

        if p=$152 then K_Inser:=Make;
        if p=$147 then K_Home:=Make;
        if p=$149 then K_PgUp:=Make;

        if p=$45 then K_Verrnum:=Make;
        if p=$135 then K_Mul:=Make;
        if p=$37 then K_Div:=Make;
        if p=$4a then K_Moins:=Make;

        if p=$4a then K_Tab:=Make;
        if p=$10 then K_A:=Make;
        if p=$11 then K_Z:=Make;
        if p=$12 then K_E:=Make;
        if p=$13 then K_R:=Make;
        if p=$14 then K_T:=Make;
        if p=$15 then K_Y:=Make;
        if p=$16 then K_U:=Make;
        if p=$17 then K_I:=Make;
        if p=$18 then K_O:=Make;
        if p=$19 then K_P:=Make;
        if p=$1a then K_Chapeau:=Make;
        if p=$1b then K_Dollar:=Make;
        if (p=$1C) or (p=$11C) then K_Enter:=Make;

        if p=$153 then K_Del:=Make;
        if p=$14f then K_Fin:=Make;
        if p=$151 then K_PgDown:=Make;

        if p=$47 then K_7:=Make;
        if p=$48 then K_8:=Make;
        if p=$49 then K_9:=Make;
        if p=$4e then K_Plus:=Make;

        if p=$1e then K_Q:=Make;
        if p=$1F then K_S:=Make;
        if p=$20 then K_D:=Make;
        if p=$21 then K_F:=Make;
        if p=$22 then K_G:=Make;
        if p=$23 then K_H:=Make;
        if p=$24 then K_J:=Make;
        if p=$25 then K_K:=Make;
        if p=$26 then K_L:=Make;
        if p=$27 then K_M:=Make;
        if p=$28 then K_ugrave:=Make;
        if p=$2b then K_Etoile:=Make;

        if p=$4B then K_4:=Make;
        if p=$4C then K_5:=Make;
        if p=$4D then K_6:=Make;

        if (p=$36) or (p=$2A) then K_Shift:=Make;
        if p=$56 then K_Inf:=Make;
        if p=$2c then K_W:=Make;
        if p=$2d then K_X:=Make;
        if p=$2e then K_C:=Make;
        if p=$2F then K_V:=Make;
        if p=$30 then K_B:=Make;
        if p=$31 then K_N:=Make;
        if p=$32 then K_Virgule:=Make;
        if p=$33 then K_PointVirgule:=Make;
        if p=$34 then K_2Points:=Make;
        if p=$35 then K_Exclam:=Make;

        if p=$148 then K_Up:=Make;

        if p=$4F then K_1:=Make;
        if p=$50 then K_2:=Make;
        if p=$51 then K_3:=Make;

        if (p=$1D) or (p=$11D) then K_Ctrl:=Make;
        if p=$38 then K_Alt:=Make;
        if p=$15c then K_WDemarrer:=Make;
        If p=$39 then K_Space:=Make;
        if p=$138 then K_AltGr:=Make;
        if p=$15d then K_WMenu:=Make;

        if p=$14B then K_Left:=Make;
        if p=$150 then K_Down:=Make;
        if p=$14D then K_Right:=Make;

        if p=$52 then K_0:=Make;
        if p=$53 then K_Point:=Make;

{ne pas toucher ce qu'il y a aprŠs}
        ext2:=false;
      end;
      ext1:=False;
    end;
  end;
  port[$20]:=$20;
  asm
    sti
  end;
end;

{$f-}

procedure AdvKeyOn;
begin
  SetIntVec(9,@NewInt9);
end;

procedure AdvKeyOff;
begin
  SetIntVec(9,OldInt9);
end;

begin
  GetIntVec(9,OldInt9);
end.