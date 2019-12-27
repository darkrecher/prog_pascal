Uses Crt;

{euh.. je sais plus ce que c'est comme programme...}

begin
  asm
    mov AH,$0001;
    mov DX,$0000;
    int $17;
    mov AH,$0000;
    mov AL,$0041;
    mov DX,$0000;
    int $17;
    mov AH,$0000;
    mov AL,$000D;
    mov DX,$0000;
    int $17;
    mov AH,$0000;
    mov AL,$000A;
    mov DX,$0000;
    int $17;
    mov AH,$0000;
    mov AL,$0042;
    mov DX,$0000;
    int $17;
    mov AH,$0000;
    mov AL,$000D;
    mov DX,$0000;
    int $17;
    mov AH,$0000;
    mov AL,$000A;
    mov DX,$0000;
    int $17;
  end;
end.







