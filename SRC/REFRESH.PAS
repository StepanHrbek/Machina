uses crt;

var   pole:array[0..256] of word;
      sekv:array[1..60000] of byte;
      f:file;

procedure proc(a:byte);
begin
 inc(pole[a]);
end;

label bad;

BEGIN
 asm  {set 640x480}
     mov ax,4f02h;mov bx,101h;int 10h;cmp ax,4fh;jnz bad
 end;

 writeln('stiskni neco');
 readkey;

 fillchar(pole,sizeof(pole),0);
 asm mov cx,60000
     mov bx,offset sekv
     @2:
     mov dx,3dah;
     in al,dx
     mov [bx],al
     inc bx
     cmp al,ah
     jz @same
     push ax
     call proc
     @same:
     mov ah,al
     loop @2;
     end;

 assign(f,'data.dat');
 rewrite(f,1);
 blockwrite(f,pole,2*256);
 blockwrite(f,sekv,60000);
 close(f);
 asm mov ax,3;int 10h;end;
 halt;

 bad:
 writeln('nemas nahranej VESA BIOS');
END.