{$M 4000,0,0}

uses crt;

VAR   pisseg,vodseg,handle,frameseg,videoseg:word;
      head:word absolute 0:$41a;
      tail:word absolute 0:$41c;

      i:word;

PROCEDURE MemDone;assembler;
 asm
 {----EMS----}
   mov ah,45h;mov dx,handle;int 67h;
 {----CONV----}
   mov ah,49h;mov es,pisseg;int 21h;
   mov ah,49h;mov es,vodseg;int 21h;
   end;

PROCEDURE ERRORHALT(n:byte);
begin
 asm mov ax,3;int 10h;end;
 tail:=head;
 case n of 1:write('I need more conv mem');
           2:write('I need EMM, QEMM or something similar');
           3:write('I need more EMS memory');
           4:write('I need mouse & driver');
           5:write('You hit ESC, don''t you ?'#10#10);
           end;
 memdone;
 port[$21]:=0;
 halt;
end;

PROCEDURE MemInit;assembler;
 asm
 {----EMS----}
   {test if present}mov ax,4000h;int 67h;cmp ax,0;jz @2;push 2;call errorhalt;@2:
   {get emm frame}mov ax,4100h;int 67h;mov frameseg,bx
   {alloc}mov ax,4300h;mov bx,16{*16KB};int 67h;or ah,ah;jnz @noems;mov handle,dx
 {----CONV----}
   {pisseg 65536}mov bx,65536/16;call @alloc;mov pisseg,ax
   {vodseg 65536}mov bx,65536/16;call @alloc;mov vodseg,ax
   jmp @99

@alloc:
   mov ah,48h;int 21h;jc @3;ret
   @3:push 1;call errorhalt

@noems:
   push 3;call errorhalt

   @99:
   end;

{
procedure plasma(x1,y1,x2,y2 : word);
var xn,yn,dxy,p1,p2,p3,p4 : word;
begin
 if (x2-x1<2) and (y2-y1<2) then EXIT;
 p1:=mp^[256*y1+x1]; p2:=mp^[256*y2+x1]; p3:=mp^[256*y1+x2];
 p4:=mp^[256*y2+x2]; xn:=(x2+x1) shr 1; yn:=(y2+y1) shr 1;
 dxy:=5*(x2-x1+y2-y1) div 3;
 if mp^[256*y1+xn]=0 then mp^[256*y1+xn]:=ncol(p1+p3,dxy,2);
 if mp^[256*yn+x1]=0 then mp^[256*yn+x1]:=ncol(p1+p2,dxy,2);
 if mp^[256*yn+x2]=0 then mp^[256*yn+x2]:=ncol(p3+p4,dxy,2);
 if mp^[256*y2+xn]=0 then mp^[256*y2+xn]:=ncol(p2+p4,dxy,2);
 mp^[256*yn+xn]:=ncol(p1+p2+p3+p4,dxy,4);
 plasma(x1,y1,xn,yn); plasma(xn,y1,x2,yn);
 plasma(x1,yn,xn,y2); plasma(xn,yn,x2,y2);
end;
}

var qwa:word;
PROCEDURE PulPage(pulpage:word{0..7});assembler;
 asm {video}
      mov bx,sega000;mov ax,pulpage;shr ax,1;jnc @sudapulpag;add bx,2048;@sudapulpag:mov videoseg,bx{adresa a000 nebo a800}
      mov ax,4f05h;mov bx,0;mov dx,pulpage;shr dx,1;int 10h{vesa window}
     {frame}
      mov ax,pulpage;shl ax,2;mov qwa,ax;
      mov ax,4400h;mov bx,qwa;         mov dx,handle;int 67h;
      mov ax,4401h;mov bx,qwa;inc bx;  mov dx,handle;int 67h;
      mov ax,4402h;mov bx,qwa;add bx,2;mov dx,handle;int 67h;
      mov ax,4403h;mov bx,qwa;add bx,3;mov dx,handle;int 67h;
     end;


BEGIN


 meminit;
 {port[$21]:=2;}

  asm
  mov ax,13h;int 10h
  end;

  asm
  mov dx,3d4h     {offset}
  mov al,13h
  out dx,al
  inc dx
  mov al,64
  out dx,al
  end;

 for i:=0 to 7 do begin
  pulpage(i);
  asm
  push ds
  mov es,videoseg
  mov ds,frameseg
  mov si,0;mov di,0;mov cx,16384;rep movsw
  pop ds
  end;
  readkey;{repeat until port[$60]<$80;}
  end;




 errorhalt(0);

END.