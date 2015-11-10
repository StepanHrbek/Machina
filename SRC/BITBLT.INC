{const wrisir=512;
      wrivys=512;
      vissir=360;
      visvys=464;
var   wriy,framewriseg:word;
procedure bank;begin end;
procedure reframe;begin end;}

{$ifdef pix2}
PROCEDURE Bitmap2Screen2(totalwidth,srcseg,x1,y1,xwidth,yheight:word;pozadi:byte;destx,desty:word);assembler;
{$else}
PROCEDURE Bitmap2Screen1(totalwidth,srcseg,x1,y1,xwidth,yheight:word;pozadi:byte;destx,desty:word);assembler;
{$endif}
var oldDS,bit,line,currentx1,currentsir4,vyscounter:word;
 {fs:bx-pikcr ve workseg od 0/0 (WORKSEG 0,1,2,3,4,5..)
  es:di-skreen v destx/desty (SEGA000 0,4,8...1,5,9...  a 2xVIC radek)
  ds:si-background v destx/desty (EMS 0,4,8...1,5,9...  a 2xVIC radek)}
 asm
     mov al,pozadi;mov [cs:offset @zapozadi-1],al
     MOV oldDS,DS
     mov bit,0
     mov ax,srcseg;db 8eh,0e0h{mov FS,ax}
     mov es,sega000
     {spocita alternativni (kratsi) height pri animaci v dolni pulce screenu}
{    doublepixels... height:=(wriy*16+wrivys-y1)/2
     singlepixels... height:=(wriy*16+wrivys-y1)}
     mov ax,wriy;shl ax,4;add ax,wrivys;sub ax,desty;jc @konec
     {$ifdef pix2}shr ax,1{$endif}
     cmp ax,yheight;jnc @nezkracovat;mov yheight,ax;jmp @prepared;
     @nezkracovat:
(*     mov ax,wriy;shl ax,3;{$ifdef pix2}add ax,wrivys/2{$else}add ax,wrivys{$endif};sub ax,desty;jc @konec
     cmp ax,yheight;jnc @nezkracovat;mov yheight,ax;jmp @prepared;
     @nezkracovat:*)
     {zvetsi desty,srcy1 a zmensi height pri animaci v horni pulce screenu}
     mov ax,wriy;shl ax,3;sub ax,desty;jc @prepared
     cmp ax,yheight;jnc @konec
     add desty,ax;add y1,ax;sub yheight,ax
  @prepared:
     cmp yheight,0;jz @konec
  @nextbit:
     mov ax,102h;mov cx,bit;shl ah,cl;mov dx,3c4h;out dx,ax{...set write bit}
     mov ax,desty;mov line,ax
     mov ax,yheight;mov vyscounter,ax
     mov ax,destx;sub ax,bit;add ax,3;mov bx,ax;shr ax,2;mov currentx1,ax
     and bx,3;add bx,xwidth;shr bx,2;mov currentsir4,bx
     mov di,desty;{$ifdef pix2}shl di,8{$else}shl di,7{$endif};add di,currentx1{...spocita DI}
     mov si,di;and si,2047;mov ax,3;sub ax,bit;shl ax,11;or si,ax{...spocita SI}
     mov bx,bit;sub bx,destx;and bx,3;mov ax,totalwidth;mul y1;add bx,ax;add bx,x1{...spocita BX}
  @next16lines:
     pusha;mov DS,oldDS
     mov ax,line;{$ifdef pix2}shr ax,3{$else}shr ax,4{$endif}
     push ax

     {nabankuje}
     shr ax,5;call bank

     call reframe
     popa;mov DS,framewriseg
  @nextline:
     push bx
     mov cx,currentsir4
     dec si;dec di;inc cx;jmp @background{zaridi vymazani 4 pixelu PRED}
  @nextpixel:
     db 64h{FS};mov al,[bx];add bx,4;cmp al,0;@zapozadi:{flibackground};jnz @foreground
     @background:{$ifdef pix2}mov al,[si+wrisir/4];mov [es:di+wrisir/4],al;{$endif}movsb;loop @nextpixel;jmp @zaloop
     @foreground:{$ifdef addtofli}add al,addtofli;{$endif}inc si;
                 {$ifdef pix2}mov [es:di+wrisir/4],al;{$endif}stosb;loop @nextpixel
    @zaloop:
     {$ifdef pix2}mov al,[si+wrisir/4];mov [es:di+wrisir/4],al;{$endif}movsb;dec si;dec di;{zaridi vymazani 4 pixelu ZA}
     pop bx;add bx,totalwidth
     {$ifdef pix2}mov ax,wrisir/2{$else}mov ax,wrisir/4{$endif};sub ax,currentsir4;add si,ax;add di,ax;
     dec vyscounter;jz @endofbit
     inc line;{$ifdef pix2}test line,7{$else}test line,15{$endif};jnz @nextline;sub si,2048;jmp @next16lines
  @endofbit:
     inc bit;cmp bit,4;jnz @nextbit
     @konec:
     MOV DS,oldDS
     end;
