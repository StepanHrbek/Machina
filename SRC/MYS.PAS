const mouseactive       :byte=0;
      mouseflag         :byte=0;
      now_mousex        :word=0;
      now_mousey        :word=0;
      now_visx          :word=0;
      now_visy          :word=0;
      last_abs_x        :word=0;
      last_abs_y        :word=0;
      nowbank           :byte=0;
      wrisir            =360;{po kolika pixelech zacina nova lajna}

const s=13+256; {mys, text tabulek: zluta 13-16}
      t=s+1;
      u=t+1;
      v=u+1;
      sipka:array[0..127] of word=(
             u,  s,  s,  0,  0,  0,  0,  0,
             u,  t,  t,  s,  s,  0,  0,  0,
             t,  v,  u,  t,  s,  s,  s,  0,
             t,  u,  v,  v,  t,  t,  s,  0,
             t,  u,  v,  u,  v,  t,  s,  0,
             t,  v,  u,  v,  t,  s,  0,  0,
             t,  u,  v,  u,  s,  0,  0,  0,
             t,  v,  u,  v,  t,  0,  0,  0,
             t,  u,  t,  u,  u,  s,  0,  0,
             t,  t,  s,  t,  u,  t,  0,  0,
             t,  s,  0,  s,  u,  u,  s,  0,
             t,  0,  0,  0,  t,  u,  t,  0,
             0,  0,  0,  0,  s,  u,  u,  s,
             0,  0,  0,  0,  0,  t,  u,  s,
             0,  0,  0,  0,  0,  s,  t,  s,
             0,  0,  0,  0,  0,  0,  s,  s);

procedure bank(b:word);
begin
 {tuhle proc. vykilluj, neni tam nanic}
end;

PROCEDURE Ports2AX;assembler;
 asm
    {vga ports 2 ax}
     {write:}mov dx,3c4h;mov al,2;out dx,al;inc dx;in al,dx;mov ah,al
     {read:}mov dx,3ceh;mov al,4;out dx,al;inc dx;in al,dx
     end;

PROCEDURE BX2ports;assembler;
 asm
    {restore vga ports from bx}
     {write:}mov dx,3c4h;mov al,2;mov ah,bh;out dx,ax
     {read:}mov dx,3ceh;mov al,4;mov ah,bl;out dx,ax
     end;

PROCEDURE Mouse(on:byte);assembler;
var a:word;
    mouseUPbank:word;
{write:3c4,2,0-15; read:3ce,4,0-3}
 asm pushf;cli
     mov al,on
     cmp al,mouseflag;jz @99

    {save vga ports}
     call ports2ax;push ax

     mov al,on
     cmp al,0;jz @mazat_z_last_absolute_position
    {novy souradnice}
     mov cx,now_mousex;add cx,now_visx;mov last_abs_x,cx
     mov dx,now_mousey;add dx,now_visy;mov last_abs_y,dx
     jmp @joj
    {stary souradnice}
    @mazat_z_last_absolute_position:
     mov cx,last_abs_x
     mov dx,last_abs_y

    @joj:

     {nabankuje}
     mov ah,0;mov al,nowbank;PUSH AX
     mov ax,dx;shr ax,9;mov mouseUPbank,ax;call bank

     xor mouseflag,1
     mov es,sega000
     lea si,sipka
     shl dx,7{dx*wrisir/4};mov di,cx;shr di,2;add di,dx
     and cl,3;mov ah,cl;mov al,4;mov a,ax{read}
     mov ax,102h;shl ah,cl;mov dx,3c4h{write}
     mov cx,4
    @loop:
     push cx

     xchg a,ax{->read}
     add dl,10;out dx,ax
     inc ah;and ah,3
     xchg a,ax{->write}
     sub dl,10;out dx,ax

     mov cx,16;
    @1:
     mov bx,[si];dec bh;jnz @skip1;xchg bl,[es:di  ];mov [si],bl;@skip1:add si,8
     mov bx,[si];dec bh;jnz @skip2;xchg bl,[es:di+1];mov [si],bl;@skip2:add si,8
     add di,wrisir/4;jnc @nonewpage1;push ax;mov ax,mouseUPbank;inc ax;call bank;pop ax;@nonewpage1:
     loop @1
     sub si,2*16*8-2
     sub di,4*wrisir;jnc @nonewpage2;push ax;mov ax,mouseUPbank;       call bank;pop ax;@nonewpage2:

     shl ah,1;cmp ah,16;jnz @ok;mov ah,1;inc di;@ok:

     pop cx;loop @loop

    {restore last bank}
     POP AX;call bank

    {restore vga ports}
     pop bx;call bx2ports

     @99:
     popf
     end;

