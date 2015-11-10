uses sluzby;

CONST mvel=15;soup=11;maxsed=30;{*25 pro za/odmlzit}
      sir=320;
      vys=200;


PROCEDURE Zamlzit(adr:word);assembler;
asm mov ax,0a000h;mov es,ax;mov ax,256*maxsed+1;mov di,adr;mov dx,mvel;@2:mov cx,mvel
    @1:cmp [es:di],ah;jnc @nomlha;add [es:di],al;@nomlha:inc di;loop @1
    add di,320-soup-2;dec dx;jnz @2;
    end;

PROCEDURE Odmlzit(adr:word);assembler;
asm mov ax,0a000h;mov es,ax;mov ax,1101h;mov di,adr;mov dx,mvel;@2:mov cx,mvel
    @1:mov al,[es:di];cmp al,maxsed+1;jnc @nomlha;cmp al,17;jc @nomlha
    dec al;mov [es:di],al;@nomlha:inc di;loop @1
    add di,320-soup;dec dx;jnz @2;
    end;


PROCEDURE Maxiryha(adr:word;size:word);assembler;
asm mov es,sega000;mov di,adr;mov dx,100;
    @0:mov cx,size;mov al,maxsed
    @1:add al,[es:di];add al,[es:di+1];add al,[es:di+sir];shr al,2
       stosb;stosb;add di,sir-2;stosb
       add di,sir;loop @1
    dec dx;jnz @0
    end;

var   i,k,xy,size:word;
      j:integer;
      a:array[0..vys-1,0..sir-1] of byte absolute $a000:0;
const myvis:word=0;
      smer:shortint=1;
      long:longint=0;
label 9;





PROCEDURE Rozhod(xy:word;dx,dy:integer;size:word;synu:byte);
var i:byte;
    w:word;
begin
 if (synu>1) {and ((size>8) or (random(10)>=0))} then begin
   asm
    mov di,xy
    mov bx,size
    mov dx,bx;@1:mov cx,bx;@2:inc byte ptr [es:di];inc di;loop @2;sub di,bx;add di,sir+1;dec dx;jnz @1

{    mov cx,0
    @1:
    mov di,xy
    mov es,sega000
    mov ax,[es:di];cmp al,ah;jc @R
    @L:cmp al,[es:di+sir];jc @LD
    @LU:           jmp @end
    @LD:add di,sir;jmp @end
    @R:inc di
       cmp al,[es:di+sir];jc @RD
    @RU:           jmp @end
    @RD:add di,sir;jmp @end
    @end:
    inc byte ptr [es:di]
    mov xy,di
    loop @1}
    end;
   if (synu>1) and (size>3) then for i:=1 to synu do rozhod(
     xy+dx+sir*dy,
     dx*21 div 20+(random(7)-3),
     dy*21 div 20+(random(7)),
     size-1,synu-random(2));
   end;
end;








CONST sirka=320;vy=40;sr=20;fnvys=4*vy;fnsir=4*sr;

PROCEDURE PutChar(ch:char;xy:word);
const chlo='`';
      chhi='z';
      p:array[chlo..chhi] of record p:array[1..6] of byte;end=((p:(0,0,0,0,0,0)),(p:(5,84,70,54,86,0)),(p:(1,3,18,40,56,88)),
       (p:(84,87,36,55,0,0)),(p:(1,7,20,103,70,0)),(p:(1,3,18,88,0,0)),(p:(1,18,88,0,0,0)),(p:(1,3,18,54,104,0)),
       (p:(1,35,86,0,0,0)),(p:(71,0,0,0,0,0)),(p:(71,7,0,0,0,0)),(p:(1,88,40,56,0,0)),(p:(1,3,0,0,0,0)),(p:(1,24,40,35,0,0)),
       (p:(1,35,19,0,0,0)),(p:(1,3,35,18,0,0)),(p:(1,18,38,86,0,0)),(p:(1,18,38,103,7,56)),(p:(1,18,38,86,56,0)),
       (p:(3,54,86,21,18,0)),(p:(71,18,0,0,0,0)),(p:(1,3,35,0,0,0)),(p:(23,39,0,0,0,0)),(p:(1,8,56,35,0,0)),(p:(2,19,0,0,0,0)),
       (p:(135,24,40,0,0,0)),(p:(18,2,3,0,0,0)));
      sx:array[0..8] of byte=(1,1,3,3,2,1,3,2,2);
      sy:array[0..8] of byte=(3,1,1,3,1,2,2,3,2);
var   i:byte;

procedure LINE(xy:word;x1,y1,x2,y2:byte);begin
 asm mov es,sega000
     mov dh,80{barva}
     mov al,sir/2;mul y1;shl ax,1;add al,x1;adc ah,0;mov di,ax;add di,xy
     mov al,x1;mov ah,x2;sub ah,al;mov bx,1    ;jnc @8;neg bx;neg ah
  @8:mov dl,y1;mov al,y2;sub al,dl;mov si,sir  ;jnc @7;neg si;neg al
  @7:cmp ah,al;jnc @1;xchg al,ah;xchg bx,si;@1:mov dl,ah;inc al;inc ah;mov ch,0;mov cl,ah;
  @2:mov [es:di],dh;add di,bx;sub dl,al;jnc @3;add dl,ah;add di,si;@3:loop @2;end;end;

begin
 if (ch>=chlo) and (ch<=chhi) then with p[ch] do for i:=1 to 6 do if p[i]>0 then
  line(xy,sr*sx[p[i] shr 4],vy*sy[p[i] shr 4],sr*sx[p[i] mod 16],vy*sy[p[i] mod 16]);
end;


CONST scrolX:word=0;
      scroller:string=' ahoj bubaku bleble bubu halali';
BEGIN
 asm mov ax,13h;int 10h;
 {fill}    mov ax,0a000h;mov es,ax;mov di,0;mov ax,1213h;mov cx,32768;rep stosw;end;
{ rozhod(100+100*320,30,-10,12,4);}

 for size:=1 to 20 do
  for i:=1 to 320 do if i mod size=0 then begin
   j:=random(900) div size;
   xy:=i+sir*(j+40);
   asm
    mov di,xy
    mov bx,size;inc bx
    mov al,2
    mov dx,bx;@1:mov cx,bx;@2:add [es:di],al;inc di;loop @2;sub di,bx;add di,sir+1;dec dx;jnz @1
   end;
   end;

 for i:=32 to 255 do setcolor(i,33,33,33);
 for i:=32 to 32+64 do setcolor(i,64+32-i,64+32-i,64+32-i);
 for i:=1 to 800 do zamlzit(random(65535));
 repeat
   refresh(1);
   inc(scrolX);
   setvis(scrolX);
   for i:=1 to 13 do maxiryha(random(65535),4+random(4));
   a[round(100+97*sin(scrolX/20)),4*scrolX-1]:=131;
   if scrolX mod sr=0 then begin
       putchar(scroller[(scrolX div sr) mod length(scroller)+1],4*scrolX-fnsir+15*sir);
       end;
 until port[$60]=1;
 9:
END.
