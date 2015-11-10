var key,oldscrollock,scrollock,locks:byte;
const rozsvecetDiody:byte=1;
      longtimer:longint=0;

PROCEDURE Refresh(n:byte);assembler;
 asm mov ch,0;mov cl,n;@2:mov dx,3dah;in al,dx;shr al,4;jc @2; @5:mov dx,3dah;in al,dx;shr al,4;jnc @5;loop @2;end;


PROCEDURE LightLocks;assembler;
 asm cmp rozsvecetDiody,0;jz @end
     mov cx,10000;@l1:loop @l1;mov dx,64h;mov al,0edh ;out dx,al
     mov cx,10000;@l2:loop @l2;mov dx,61h;mov al,locks;out dx,al
     @end:
     end;

PROCEDURE InitKeyb;assembler;
 asm
    pushf;cli
   {nastavi promennou LOCKS}
    mov ah,2;int 16h
    shr al,4;mov ah,al;and ah,1;mov oldscrollock,ah;and al,2+4
    test scrollock,1;jz @nolock;inc al;@nolock:mov locks,al
   {rozsviti locky}
    xor locks,2
    call lightLocks
    popf
    end;

BEGIN
InitKeyb;
asm cli end;
repeat
 refresh(1);
 key:=port[$60];
 if key<128 then write(key,',');
 inc(longtimer);
 if key=41 then asm xor locks,1;call lightLocks;end;

until (key=1) or (longtimer>500);
asm sti end;

END.