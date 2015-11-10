
{лллллллллллллллл TEXTURY лллллллллллллллл}

PROCEDURE FiltrujTextureInSeg(st:string;myseg:word);
const sir=256;
      vys=256;
      min=25;
      max=40;

procedure Add_OsekniTop(delta,top:byte);assembler;
 asm
     push ds
     push es;pop ds
     xor si,si
     xor di,di
     mov bl,delta;mov bh,bl;push bx;push bx;db 66h;pop bx
     mov cx,16384
     mov dl,top
     @1:
     db 66h;lodsw
     db 66h;add ax,bx
     cmp al,dl;jbe @nepretek1;mov al,dl;@nepretek1:
     cmp ah,dl;jbe @nepretek2;mov ah,dl;@nepretek2:db 66h;rol ax,16
     cmp al,dl;jbe @nepretek3;mov al,dl;@nepretek3:
     cmp ah,dl;jbe @nepretek4;mov ah,dl;@nepretek4:db 66h;rol ax,16
     db 66h;stosw
     loop @1
     pop ds
 end;

procedure Sub_OsekniBot(delta,bot:byte);assembler;
 asm
     push ds
     push es;pop ds
     xor si,si
     xor di,di
     mov bl,delta;mov bh,bl;push bx;push bx;db 66h;pop bx
     mov cx,16384
     mov dl,bot
     @1:
     db 66h;lodsw
     db 66h;sub ax,bx
     cmp al,dl;jae @nepodtek1;mov al,dl;@nepodtek1:
     cmp ah,dl;jae @nepodtek2;mov ah,dl;@nepodtek2:db 66h;rol ax,16
     cmp al,dl;jae @nepodtek3;mov al,dl;@nepodtek3:
     cmp ah,dl;jae @nepodtek4;mov ah,dl;@nepodtek4:db 66h;rol ax,16
     db 66h;stosw
     loop @1
     pop ds
 end;

procedure OsekniAll(bot,top:byte);assembler;
 asm
     push ds
     push es;pop ds
     xor si,si
     xor di,di
     mov cx,16384
     mov dl,bot
     mov dh,top
     @1:
     db 66h;lodsw
     cmp al,dl;jae @nepodtek1;mov al,dl;@nepodtek1:
     cmp ah,dl;jae @nepodtek2;mov ah,dl;@nepodtek2:
     cmp al,dh;jbe @nepretek1;mov al,dh;@nepretek1:
     cmp ah,dh;jbe @nepretek2;mov ah,dh;@nepretek2:db 66h;rol ax,16
     cmp al,dl;jae @nepodtek3;mov al,dl;@nepodtek3:
     cmp ah,dl;jae @nepodtek4;mov ah,dl;@nepodtek4:
     cmp al,dh;jbe @nepretek3;mov al,dh;@nepretek3:
     cmp ah,dh;jbe @nepretek4;mov ah,dh;@nepretek4:db 66h;rol ax,16
     db 66h;stosw
     loop @1
     pop ds
 end;

procedure ShlSeg(a,b:byte);assembler;asm
     push ds
     push es;pop ds
     xor si,si
     xor di,di
     mov bl,a;mov bh,bl;push bx;push bx;db 66h;pop bx
     mov dl,b;mov dh,dl;push dx;push dx;db 66h;pop dx
     mov cx,32768/2
     @1:
     db 66h;lodsw
     db 66h;sub ax,bx
     db 66h;add ax,ax
     db 66h;add ax,dx
     db 66h;stosw
     loop @1
     pop ds
 end;


procedure RandomujPutcolorSeg(a,b:byte);assembler;asm
     push ds
     push es;pop ds
     xor si,si
     xor di,di
     mov ch,b;mov cl,0
     mov al,a
     @1:
     add di,[cs:si]
     add di,5555
     stosb
     add si,22
     loop @1
     pop ds
 end;

procedure RandomujSwapcolorSeg(b:byte);assembler;asm
     push ds
     push es;pop ds
     xor si,si
     xor di,di
     mov ch,b;mov cl,0
     @1:
     add di,[cs:si]
     add di,5555
     movsb
     add si,21
     loop @1
     pop ds
 end;

procedure Sesikmi1Seg;assembler;asm
     push ds
     push es;pop ds
     xor si,si
     xor di,di
     mov cx,0
     @1:
     movsb
     add di,sir
     loop @1
     pop ds
 end;

procedure SwapniOsySeg;assembler;asm
     push ds
     push es;pop ds
     xor si,si
     xor di,di
     mov dx,sir
     @2:
     mov cx,dx
     push si
     push di
     @1:
     lodsb;xchg al,[di];mov [si-1],al
     add di,sir
     loop @1
     pop di;add di,sir+1
     pop si;add si,sir+1
     dec dx
     jnz @2
     pop ds
 end;


procedure PrevalcujSeg;assembler;asm
     push ds
     push es;pop ds
     xor si,si
     xor di,di
     mov cx,0
     @1:
     lodsb
     xchg al,[di]
     mov [si-2],al
     inc di
     add si,sir+1
     loop @1
     pop ds
 end;


procedure ZamlzSeg1;assembler;asm
     push ds
     push es;pop ds
     mov di,0
     mov cx,0
     mov al,[di]
     @1:add al,[di];add al,[di+sir];add al,[di-sir];add al,1;shr al,2;stosb;loop @1
     pop ds
 end;

procedure ZamlzSeg2;assembler;asm{was:12+6,100,2312}{now:4+11,71,1357}
     push ds
     push es;pop ds
     mov di,-2

     {first line loop   DI=65534..sir-4}
     mov al,[di-sir+1];add al,[di+sir+1]
     mov ah,[di-sir+2];add ah,[di+sir+2]
     mov dx,[di]
     mov bx,[di+2]
     mov cx,sir/2;call near ptr @3

     {main loop   DI=sir-2..65536-sir-4}
     mov al,[di-sir+1];add al,[di+sir+1]
     mov ah,[di-sir+2];add ah,[di+sir+2]
     mov cx,32768-sir;call near ptr @2

     {last line loop   DI=65536-sir-2..65532}
     mov al,[di-sir+1];add al,[di+sir+1]
     mov ah,[di-sir+2];add ah,[di+sir+2]
     mov cx,sir/2;call near ptr @2

     jmp @end

     {-PROC-}
     @1:
     db 66h{eax};mov ax,[di-sir];
     db 66h{eax};add ax,[di+sir];
     db 66h{eax};shr ax,8
     @2:
     db 66h{ebx};mov bx,[di];
     mov dx,bx
     db 66h{ebx};shr bx,16
     @3:
     add ax,dx
     add ax,bx
     add ax,404h
     shr ah,2;shr al,2
     add al,dh
     add ah,bl
     shr ah,1;shr al,1
     stosw
     loop @1
     ret near

     @end:
     pop ds
 end;


procedure RozsypSeg;assembler;asm
push ds
push es;pop ds
xor si,si
xor di,di

mov bx,[si]

mov dx,sir
@mlznextslp:
mov cx,vys;cmp dx,1;jnz @fullvys;sub cx,2;@fullvys:
@mlznextline:
add si,sir
mov ax,bx
mov bx,[si]

;{testuje presyp AL,AH}
cmp al,ah
jz @same1
jnc @incAH
sub ax,2*0ffh
@incAH:
add ax,0ffh
@same1:

;{testuje presyp AL,BL}
cmp al,bl
jz @same2
jnc @incBL
dec bx;{bl}
inc ax;{al}
jmp @same2
@incBL:
inc bx;{bl}
dec ax;{al}
@same2:

mov [si-sir],ax

loop @mlznextline
sub si,vys*sir-1
dec dx
jnz @mlznextslp
pop ds
end;

procedure SubBox(xo:byte;adr,x,y:word);assembler;asm
     push ds
     push es;pop ds
     mov di,adr;add di,x
     mov dx,y
     mov al,xo
     @2:
     mov cx,x
     sub di,cx
     @1:
     sub [di],al
     inc di
     loop @1
     add di,sir
     dec dx
     jnz @2
     pop ds
     end;


Var   a,b:byte;
      i:word;
      code:word;
      c:char;
      x0,y0,tsir,tvys:byte;
      x,y:word;

Begin
 c:=st[1];
 delete(st,1,1);
 a:=0;
 b:=0;
 if st>'' then begin
   val(cutstringfromstring('/',st),a,code); if code>0 then errorhalt(49);
   if st>'' then val(st,b,code);            if code>0 then errorhalt(49);
   end;
 asm mov es,myseg;end;
 case c of '+':begin if b=0 then b:=max;Add_OsekniTop(a,b);end;
           '-':begin if b=0 then b:=min;Sub_OsekniBot(a,b);end;
           '*':begin
               if a=0 then a:=25;
               if b=0 then b:=10;
               ShlSeg(a,b);
               end;
           '\':SwapniOsySeg;
           'o':begin
               if a=0 then a:=min;
               if b=0 then b:=max;
               OsekniAll(a,b);
               end;
           'a':begin
               if b=0 then b:=100;
               case a of 0:RandomujSwapcolorSeg(b);
                         1:Sesikmi1Seg;
                         2:;
                         end;
               end;
           'r':begin
               if a=0 then a:=32;
               if b=0 then b:=20;
               RandomujPutcolorSeg(a,b);
               end;
           'p':begin
               PrevalcujSeg;
               RozsypSeg;
               end;
           'm':ZamlzSeg1;
           'n':ZamlzSeg2;
           's':RozsypSeg;
           'z':begin
               if a=0 then a:=5;
               y0:=0;
               y:=y0;
               repeat
                x0:=random(256);
                x:=x0;
                tvys:=30+random(15);
                if word(y)+word(tvys)+30>word(y0)+vys then tvys:=y0+vys-y;
                repeat
                 tsir:=30+random(30);
                 if word(x)+word(tsir)+30>word(x0)+sir then tsir:=x0+sir-x;
                 asm mov es,myseg;end;
                 SubBox(a,sir*(y+5)+x+3,tsir-6,tvys-10);
                 inc(x,tsir);
                until x=x0+sir;
                inc(y,tvys);
               until y=y0+vys;
               for i:=1 to 3 do RozsypSeg;
               end;
           end;
End;



PROCEDURE MakeTextureInSeg(n:char;myseg:word);
const bobu=9;
      sped=0;spee=21;mvel=15;minsed=32;maxsed=40;
      fogsir=256;
var   cha:char;
      lastadr:array[0..2*bobu+1] of word;
      i,j:word;
      alfa:real;

procedure Zamlzit(adr:word);assembler;
asm mov ah,maxsed;mov di,adr;mov dx,mvel;@2:mov cx,mvel
    @1:cmp [es:di],ah;jnc @nomlha;inc byte ptr [es:di];@nomlha:inc di;loop @1
    add di,fogsir-mvel-4;dec dx;jnz @2;
    end;

procedure Odmlzit(adr:word);assembler;
asm mov ah,minsed;mov di,adr;mov dx,mvel;@2:mov cx,mvel
    @1:mov al,[es:di];cmp al,ah;jc @nomlha
    dec al;mov [es:di],al;@nomlha:inc di;loop @1
    add di,fogsir-mvel-3;dec dx;jnz @2;
    end;

procedure Maxiryha(adr:word;size:word);assembler;
asm mov di,adr;mov dx,100;
    @0:mov cx,size;mov al,maxsed
    @1:add al,[es:di];add al,[es:di+1];add al,[es:di+fogsir];shr al,2
       stosb;stosb;add di,fogsir-2;stosb
       add di,fogsir;loop @1
    dec dx;jnz @0
    end;


procedure Foggy;
var i:word;
begin
 asm {fill seg}xor di,di;db 66h;mov ax,257*36;dw 257*36;mov cx,32768/2;db 66h;rep stosw;end;
 for i:=1 to 800 do zamlzit(random(65535));
end;

const min4=25;{nejnizsi barva pro texturu4}

Begin
 {nastavi ES pro vsechny dalsi procedury}
 asm mov es,myseg;end;

 case n of

 'a':{ ..........TEXTURA 0.......... }
   begin
   Foggy;
   for i:=1 to 60 do for j:=0 to bobu do begin
     {$R-}
     inc(lastadr[2*j+1],fogsir*(random(spee)-sped)+(random(spee)-sped));odmlzit(lastadr[2*j+1]);
     {$R-}{*}
     end;
   end;

 'b':{ ..........TEXTURA 1.......... }
   asm
   PUSH DS

   {fill seg}
   xor di,di;db 66h;mov ax,257*31;dw 257*31;mov cx,32768/2;db 66h;rep stosw;

   {main loop}
   mov ds,myseg
   xor ax,ax
   mov si,ax
   mov di,ax
                  mov bx,4
                  @qwe:
   @loop:
   lodsb
   test al,1
   jnz @single
   add di,3
   @single:
   add di,256
   inc si
   inc byte ptr [di]
   loop @loop
                  dec bx
                  jnz @qwe

   {zjemneni}
   mov di,0
   mov dx,4
   @11:
   mov cx,0
   mov ah,[es:di]
   @10:
   mov al,[es:di]
   mov bl,al
   add al,ah
{   inc al}
   shr al,1
   stosb
   mov ah,bl
   loop @10
   dec dx
   jnz @11

   POP DS
   end;

 'c','d':{ ..........TEXTURA 2,3.......... }
   begin
   if n='c' then Foggy;
   for i:=0 to 200 do maxiryha(random(65535),4+random(4));
   end;

 'e':{ ..........na rychlost optimalizovana TEXTURA.......... }
   begin
   asm {fill seg}xor di,di;db 66h;mov ax,257*36;dw 257*36;mov cx,32768/2;db 66h;rep stosw;end;
   for i:=1 to 100 do zamlzit(random(65535));
   for i:=0 to 30 do maxiryha(random(65535),4+random(4));
   asm
    {sub seg}
    xor di,di;mov cx,0;mov ah,2+min4
    @4:mov al,[es:di];sub al,36-min4;cmp al,3+min4;jc @ok;mov al,ah;@ok:stosb;
    loop @4{}
    end;
   end;

 'h':{..................hvezdicky...............}
    begin
    asm
     mov es,myseg
     xor di,di
     mov cx,65536/2/2
     db 66h;xor ax,ax;db 66h;rep stosw
     end;
    for i:=1 to 3000 do byte(mem[myseg:random(65535)]):=25+random(16);
    end;

 'x':{..........bludiste z barev 19 a 22.........}
  asm
   PUSH DS
   mov es,myseg
   mov ds,myseg
   xor si,si
   mov di,si
   db 66h;mov ax,19+22*256;dw 19+22*256
   mov cx,65536/4;db 66h;rep stosw
   mov bl,1
  @loop:
   add bh,bl
   jnc @notdown
   add di,256
   test [si],bl
   jz @notdown
   xchg al,ah
   @notdown:
   stosb
   inc bl
   loopnz @loop
   jcxz @end
   mov bl,[si];shl bl,3
   jmp @loop
   @end:
   POP DS
   end;

 'y':{.............cerne nic...........}
  asm
   mov es,myseg
   xor si,si
   mov di,si
   db 66h;mov ax,0;dw 0
   mov cx,65536/4;db 66h;rep stosw
   end;

 end;

End;
