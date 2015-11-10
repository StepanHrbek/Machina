FUNCTION VesaInit512x480:Boolean;
begin
 asm
     {set 640x480}
     mov ax,4f02h;mov bx,101h;int 10h;cmp ax,4fh;jnz @bad
(*     {read ptr to setbank}
     mov ax,4f01h;mov cx,101h;int 10h;cmp ax,4fh;jnz @bad
     mov ax,[es:12+offset pal];mov [cs:  offset vesabankptr],ax
     mov ax,[es:14+offset pal];mov [cs:2+offset vesabankptr],ax
     {set wrisir=512}
     mov ax,4f06h;mov bl,0;mov cx,512;int 10h;cmp ax,4fh;jnz @bad
     {end}
     mov VGA_MODE,2{svga512}
  *)   mov @result,1
     jmp @end
     @bad:mov @result,0
     @end:
     end;
end;

 var pal:array[1..10000] of byte;
 begin

 if not VesaInit512x480 then halt;
 asm {vesa here ?}
     mov ax,4f00h;push ds;pop es;lea di,pal;int 10h
     cmp ax,4fh;jnz @novesa
     {header ok ?}
     cmp word ptr [00+offset pal],'EV';jnz @novesa
     cmp word ptr [02+offset pal],'AS';jnz @novesa
     {version >= 1.2 ?}
     mov ax,[04+offset pal]
     cmp word ptr [02+offset pal],256*1+2;
     @novesa:
      end;
      end.