uses crt,timer;

CONST
      mousepresent:boolean=false;
      mouseactive       :byte=0;
      mouseflag         :byte=0;
      vissir=640;
      visvys=400;

VAR
      Mbuttons                     :byte;
      presx,presy,presz            :word;
      tmrScrSync,
      mousex,mousey                :word;

PROCEDURE ResetMouse;assembler;asm mov ax,0;int 33h;inc ax;jnz @nomouse;mov mousepresent,1;mov Mbuttons,bl;@nomouse:end;
PROCEDURE MouseOn;assembler;   asm cmp mousepresent,0;jz @end;mov ax,1;int 33h;@end:end;
PROCEDURE MouseOff;assembler;  asm cmp mousepresent,0;jz @end;mov ax,2;int 33h;@end:end;

PROCEDURE ScanLastMousePress;assembler;
 {push:left=2,right=8,mid=32,  release:left=4,right=16,mid=64}
 asm cmp mousepresent,0;jz @nomouse
     mov ax,5;mov bx,0;int 33h;mov ax, 2;cmp bx,0;jnz @found
     mov ax,5;mov bx,1;int 33h;mov ax, 8;cmp bx,0;jnz @found
     cmp Mbuttons,3;jnz @skip3
     mov ax,5;mov bx,2;int 33h;mov ax,32;cmp bx,0;jnz @found
     @skip3:
     jmp @notfound
     @found:
     shr cx,1
     mov presx,cx
     mov presy,dx
     mov presz,ax
     @notfound:
     @nomouse:
     end;

PROCEDURE GetMouse(var x,y,z:word);
var i,j,k:word;
begin;
 asm xor bx,bx;xor cx,cx;xor dx,dx
     cmp mousepresent,0;jz @nomouse
     mov ax,3;int 33h;jmp @ismouse
     @nomouse:mov bx,0;mov cx,mousex;add cx,cx;mov dx,mousey
     @ismouse:mov k,bx;shr cx,1;mov i,cx;mov j,dx
     end;
 x:=i;y:=j;z:=k;
end;

PROCEDURE Mouse(on:byte);
begin
 if on>0 then mouseon else mouseoff;
end;

PROCEDURE DoMouseMoveCheck;
var   mi,mj,mk:word;
begin
 {---nahrada za vlastnihandler mysi---}
     ScanLastMousePress;
     if mouseactive>0 then begin
       GetMouse(mi,mj,mk);
       if (mi<>mousex) or (mj<>mousey) then
         asm
          mov al,mouseactive;push ax;mov mouseactive,0
          mov al,mouseflag;mov ah,0;push ax
          push 0;call mouse
          mov ax,mi;mov mousex,ax
          mov ax,mj;mov mousey,ax
          call mouse;pop ax;mov mouseactive,al;
          end;
       end;
end;

PROCEDURE InstallMouse(realhandler:boolean);assembler;
 asm
    {nastaveni range M-x}
     mov ax,7;mov cx,0;mov dx,2*vissir-16;int 33h
    {nastaveni range M-y}
     mov ax,8;mov cx,0;mov dx,visvys-16;int 33h;
    {nastaveni citlivosti
     call NastavCitlivostmysi}

(*
     cmp realhandler,0;jz @9
    {nastaveni handleru M}
     mov ax,ds;mov [cs:offset @q-2],ax
     mov ax,0ch;mov cx,7fh;mov dx,cs;mov es,dx;mov dx,offset @mousehandler;mov bx,dx;mov di,dx;int 33h;
     jmp @9

@MOUSEHANDLER:
     pusha
     push ds
     push es
     mov si,0;@q:mov ds,si;shr cx,1

    {nastavi externi promenny - souradnice stisku}
     and ax,2+8+32 +4+16;jz @nopress
     mov presx,cx
     mov presy,dx
     mov presz,ax
     @nopress:

     cmp mouseactive,0;jz @8{je vypnuta -> nic nedelam}

     mov now.mousex,cx
     mov now.mousey,dx

     cmp mouseflag,0;jz @8{neni videt -> nic nedelam}

     push 0;call MOUSE
     push 1;call MOUSE

     @8:
     pop es
     pop ds
     popa
     retf
*)
     @9:end;

PROCEDURE TimerScrolling;far;
begin
 DoMouseMoveCheck;
end;


BEGIN
 {asm mov ax,13h;int 10h;end;{}
 ResetMouse;
 InstallMouse(false{vlastnihandler});
 timer.tmrInit;
 tmrGetScrSync(@tmrScrSync);
 timer.tmrSyncScr(tmrScrSync,nil,nil,@TimerScrolling);
 mouse(1);

 readkey;
 timer.tmrStopScrSync;
 timer.tmrClose;
END.