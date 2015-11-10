BEGIN

 asm
     mov ax,13h;int 10h

     push ds
{     mov ds,sega000}
     mov es,sega000
     mov ax,2
     mov cx,2
     mov si,0
     mov di,0
     jmp @2
  @1:mov cl,[es:si]
  @2:inc si
     rep stosb
     xor al,3
     cmp di,0
     jnz @1
     pop ds
     end;

END.