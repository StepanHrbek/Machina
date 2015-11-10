UNIT Textury; {priblizna velikost CS=3513, DS=2}

{$i define.inc}

{ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß}
                             INTERFACE
{ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ}

USES  Chyby,Memo, Sys,Stringy,Vga,DMFile, Loadery,Objects,Dos;

{
---------------------------------------------------------------------------
                           Uvod k texturam
---------------------------------------------------------------------------

 Texturou se rozumi utvar 256x256/256 vyplnujici cely 64KB segment.
 Rutiny MakeTex a FilterTex slouzi k vytvoreni a upravam textur,
 Tex2Bit a Tex2BitPro k jejich pokladani do bitmap.
 texPlace je parser vyrazu pro popis pozadi pouzivanych Masinou.
}


FUNCTION  MakeTex(n:char;myseg:word):boolean;
FUNCTION  FilterTex(st:string;myseg:word):boolean;

PROCEDURE Tex2Bit(texseg:word;desttab:PLines;puttertabofs,destX,destY,sirka,vyska:word;writer:byte);
FUNCTION  Tex2BitPro(texseg:word;desttab:PLines;lastline,destX,destY,sirka,vyska:word;starter,ender,writer:byte):word;

FUNCTION  paramSetRgb(r,g,b:byte):string11;
PROCEDURE paramGetRgb(value:string11;var r,g,b:byte);
FUNCTION  paramGet(st:string;name:string11):string;
FUNCTION  paramSet(st:string;name:string11;value:string):string;

FUNCTION  texType(st:string):char;
PROCEDURE texPlaceTexture(workseg:word;b:PBitmap;st:string);
PROCEDURE texPlacePicture(b:PAbstractMap;st:string);
PROCEDURE texPlace(workseg:word;b:PBitmap;st:string);



{ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß}
                          IMPLEMENTATION
{ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ}

Uses DMBitmap;

const sir=256;{rozmery textury, nektere rutiny ale v sobe maji tyto}
      vys=256; {hodnoty natvrdo zakodovane}
      min=25; {pripustne barvy ve vysledne texture, nektere rutiny ale}
      max=40;  {v sobe maji tyto hodnoty natvrdo zakodovane}

function random2ax:word;assembler;
 const rndseed:word=$1234;
 asm
     push dx
     mov ax,1237h
     mul rndseed
     add ax,dx
     mov rndseed,ax
     pop dx
 end;

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

procedure ShlSeg(a,b:byte);assembler;
 asm
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

procedure RandomujPutcolorSeg(a,b:byte);assembler;
 asm
     {push ds
     push es;pop ds}
     xor si,si
     xor di,di
     mov ch,b;mov cl,0
     mov al,a
     @1:
     mov dx,ax
     call random2ax;add di,ax
     mov ax,dx
     add di,5555
     stosb
     add si,22
     loop @1
     {pop ds}
 end;

procedure RandomujSwapcolorSeg(b:byte);assembler;
 asm
     {push ds
     push es;pop ds}
     xor si,si
     xor di,di
     mov ch,b;mov cl,0
     @1:
     call random2ax;add di,ax
     add di,5555
     seges movsb
     add si,21
     loop @1
     {pop ds}
 end;

procedure Sesikmi1Seg;assembler;
 asm
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

procedure SwapniOsySeg;assembler;
 asm
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

procedure PrevalcujSeg;assembler;
 asm
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

procedure ZamlzSeg1;assembler;
 asm
     push ds
     push es;pop ds
     mov di,0
     mov cx,0
     mov al,[di]
     @1:add al,[di];add al,[di+sir];add al,[di-sir];add al,1;shr al,2;stosb;loop @1
     pop ds
 end;

procedure ZamlzSeg2;assembler;{was:12+6,100,2312}{now:4+11,71,1357}
 asm
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

procedure RozsypSeg;assembler;
 asm
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

procedure SubBox(xo:byte;adr,x,y:word);assembler;
 asm
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


{---------------------------------------------------------------------------
 Textura vyplnujici cely 64KB segment 'myseg' je protazena vsemi filtry
 zadanymi ve stringu st. Zadavani filtru je podrobne popsano v helpu
 k parenistnimu editoru.
 Strucne: string je to rada slov oddelenych carkami;
          slovo je identifikator filtru (1 pismeno) a volitelne ciselne
           parametry oddelene lomitkem; nikde zadne mezery
 ---------------------------------------------------------------------------}
FUNCTION FilterTex(st:string;myseg:word):Boolean;

Var   a,b:byte;
      i:word;
      code:word;
      c:char;
      x0,y0,tsir,tvys:byte;
      x,y:word;

Begin
 FilterTex:=false;
 c:=st[1];
 delete(st,1,1);
 a:=0;
 b:=0;
 if st>'' then begin
   val(cutstring(st,'/'),a,code); if code>0 then exit;
   if st>'' then val(st,b,code);  if code>0 then exit;
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
 FilterTex:=true;
End;



{---------------------------------------------------------------------------
 Do zadaneho 64KB segmentu vygeneruje zadanou texturu.
 ---------------------------------------------------------------------------}
FUNCTION  MakeTex(n:char;myseg:word):boolean;
const bobu=9;
      sped=0;spee=21;mvel=15;minsed=32;
var   lastadr:array[0..2*bobu+1] of word;
      i,j:word;

procedure Zamlzit(myseg,adr:word);assembler;
asm mov es,myseg
    mov ah,max;mov di,adr;mov dx,mvel;@2:mov cx,mvel
    @1:cmp [es:di],ah;jnc @nomlha;inc byte ptr [es:di];@nomlha:inc di;loop @1
    add di,sir-mvel-4;dec dx;jnz @2;
    end;

procedure Odmlzit(myseg,adr:word);assembler;
asm mov es,myseg
    mov ah,minsed;mov di,adr;mov dx,mvel;@2:mov cx,mvel
    @1:mov al,[es:di];cmp al,ah;jc @nomlha
    dec al;mov [es:di],al;@nomlha:inc di;loop @1
    add di,sir-mvel-3;dec dx;jnz @2;
    end;

procedure Maxiryha(myseg,adr:word;size:word);assembler;
asm mov es,myseg
    mov di,adr;mov dx,100;
    @0:mov cx,size;mov al,max
    @1:add al,[es:di];add al,[es:di+1];add al,[es:di+sir];shr al,2
       stosb;stosb;add di,sir-2;stosb
       add di,sir;loop @1
    dec dx;jnz @0
    end;

procedure Foggy;
var i:word;
begin
 FillByte(ptr(myseg,0),65536,36);
 for i:=1 to 800 do zamlzit(myseg,random(65535));
end;


Begin

 case n of

 'a':{ ..........TEXTURA 0.......... }
  begin
   Foggy;
   for i:=1 to 60 do
    for j:=0 to bobu do begin
      inc(lastadr[2*j+1],sir*(random(spee)-sped)+(random(spee)-sped));
      odmlzit(myseg,lastadr[2*j+1]);
      end;
  end;

 'b':{ ..........TEXTURA 1.......... }
  begin
   FillByte(ptr(myseg,0),65536,31);
   asm
   mov es,myseg
   PUSH DS

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
   shr al,1
   stosb
   mov ah,bl
   loop @10
   dec dx
   jnz @11

   POP DS
   end;
  end;

 'c','d':{ ..........podobne TEXTURY 2,3.......... }
  begin
   Foggy;
   for i:=0 to 200*(ord(n)-ord('b')) do maxiryha(myseg,random(65535),4+random(4));
  end;

 'e':{ ..........jednoducha TEXTURA 4 optimalizovana na rychlost.......... }
  begin
   FillByte(ptr(myseg,0),65536,36);
   for i:=1 to 100 do zamlzit(myseg,random(65535));
   for i:=0 to 30 do maxiryha(myseg,random(65535),4+random(4));
   Sub_OsekniBot(36-min,min);
  end;

 'h':{..................hvezdicky...............}
  begin
   FillByte(ptr(myseg,0),65536,0);
   for i:=1 to 3000 do byte(mem[myseg:random(65535)]):=min+random(max-min+1);
  end;

 'x':{..........bludiste z barev 19 a 22.........}
  asm
   mov es,myseg
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
  begin
   FillByte(ptr(myseg,0),65536,0);
  end;

 else{.............chybny parametr...........}
  begin
   MakeTex:=false;
   exit;
  end;

 end;

 MakeTex:=true;
End;



{ßßßßßßßßßßßßßßßßßßßßßßßßß TEXTURY -> BITMAP ßßßßßßßßßßßßßßßßßßßßßßßßßßßßß}


const  tex_ramecekcolorLoA=26;
       tex_ramecekcolorHiA=25;
       tex_ramecekcolorLoB=43;
       tex_ramecekcolorHiB=44;
       pocet_starteru=10;
       putter_tab_size=32;
       w_ramA=2;
       w_ramB=8;
       w_ramC=9;
       putter_put=1;
       putter_skip=2;

procedure putter_tabs;assembler;
const  L =tex_ramecekcolorLoA;
       H =tex_ramecekcolorHiA;
       LL=tex_ramecekcolorLoB;
       HH=tex_ramecekcolorHiB;
asm
 dw offset @starter0
 dw offset @starter1
 dw offset @starter2
 dw offset @starter3
 dw offset @starter4
 dw offset @starter5
 dw offset @starter6
 dw offset @starter7
 dw offset @starter8
 dw offset @starter9
 dw offset @ender0
 dw offset @ender1
 dw offset @ender2
 dw offset @ender3
 dw offset @ender4
 dw offset @ender5
 dw offset @ender6
 dw offset @ender7
 dw offset @ender8
 dw offset @ender9
{O kolik lines goback, kolik lines nasleduje v datech, data:
 0-mazat nulou
 1-vkladat texturu
 2-skipnout
 ?-stos ?}
 @starter0: db 0,  0
 @starter1: db 0,  1,  0
 @starter2: db 0,  2,  L,L
 @starter3: db 0,  3,  0,L,L
 @starter4: db 32, 32, 1,2,2,2,1,2,2,1,2,2,1,2,1,2,1,2,1,2,1,2,1,2,1,1,2,1,1,2,1,1,1,2,255{mix1}
 @starter5: db 32, 32, 0,1,0,0,2,2,2,2,2,2,0,1,1,1,0,0,2,2,2,2,0,1,1,1,1,1,1,0,0,2,2,0,255{mix2bot}
 @starter6: db 32, 32, 0,0,1,0,2,2,2,2,2,2,0,0,1,1,1,0,2,2,2,2,0,0,1,1,1,1,1,0,2,2,0,0,255{mix2top}
 @starter7: db 0,  0
 @starter8: db 0,  1,  LL
 @starter9: db 0,  2,  LL,HH
{Kolik lines nasleduje v datech, data}
 @ender0: db 0
 @ender1: db 1, 0
 @ender2: db 2, H,H
 @ender3: db 3, H,H,0
 @ender4: db 0
 @ender5: db 0
 @ender6: db 0
 @ender7: db 0
 @ender8: db 1,  HH
 @ender9: db 2,  HH,LL
 end;



{---------------------------------------------------------------------------
 Umimsti kus textury nebo konstantni barvy, zadne checkingy okraju.
 ---------------------------------------------------------------------------}
PROCEDURE Tex2Bit(texseg:word;desttab:PLines;puttertabofs,destX,destY,sirka,vyska:word;writer:byte);assembler;
 var  nowhandle:word;
 asm
      cmp vyska,0;jz @end
      cmp sirka,0;jz @end

      PUSH ds
      mov ds,texseg
      db 0fh,0b4h,5eh,offset desttab{LFS BX,tab}
      mov ax,destY;shl ax,2;add bx,ax
      mov si,destY;and si,31;shl si,9;add si,destX

      mov ah,putter_put

      {---WRITER---}

      {writuje 'lines' linek}
      @nextline:
       db 64h,0c4h,3fh{LES DI,[FS:BX]}
       add bx,4
       add di,destX

       push si
       mov cx,sirka
       {nacte do AH typ teto linky}
       push bx
       mov bx,puttertabofs;or bx,bx;jz @nechAHbyt;mov ah,[cs:bx];inc puttertabofs;@nechAHbyt:
       pop bx
       {vetveni podle typu}
       cmp ah,putter_put;jz @movs_thingy
       cmp ah,putter_skip;jz @movsdone


      @STOS_Thingy:
       mov al,ah
       call REP_STOSB
       jmp @movsdone


      @MOVS_Thingy:
       {levej ramecek}
       test writer,w_ramA;jnz @w_ramA1
       cmp writer,w_ramB;jz @w_ramB1
       cmp writer,w_ramC;jz @w_ramC1
       jmp @mnedelat_ramecek1
         @w_ramA1:sub cx,2;jc @movsdone;mov al,tex_ramecekcolorLoA;stosb;inc si;jmp @mnedelat_ramecek1
         @w_ramB1:sub cx,2;jc @movsdone;mov al,tex_ramecekcolorLoB;stosb;inc si;jmp @mnedelat_ramecek1
         @w_ramC1:sub cx,4;jc @movsdone;mov al,tex_ramecekcolorHiB;stosb;inc si
                                        mov al,tex_ramecekcolorLoB;stosb;inc si
         @mnedelat_ramecek1:
       {prostredek}
       call REP_MOVSB_si
       {pravej ramecek}
       test writer,w_ramA;jnz @w_ramA2
       cmp writer,w_ramB;jz @w_ramB2
       cmp writer,w_ramC;jz @w_ramC2
       jmp @mnedelat_ramecek2
         @w_ramA2:mov al,tex_ramecekcolorHiA;stosb;jmp @mnedelat_ramecek2
         @w_ramB2:mov al,tex_ramecekcolorHiB;stosb;jmp @mnedelat_ramecek2
         @w_ramC2:mov al,tex_ramecekcolorLoB;stosb
                  mov al,tex_ramecekcolorHiB;stosb
         @mnedelat_ramecek2:


      @movsDONE:
       pop si
       add si,256

      dec vyska
      jnz @nextline

      POP ds

      @end:
      end;


{---------------------------------------------------------------------------
 Umimsti kus textury vcetne ramecku, hlida si presahy pres okraje.
 ---------------------------------------------------------------------------}
FUNCTION  Tex2BitPro(texseg:word;desttab:PLines;lastline,destX,destY,sirka,vyska:word;starter,ender,writer:byte):word;
var   RadekCounter:word;
      SIintexture:word;
      ofsstarter,ofsender,dest,ofsdest,starteru,filleru,enderu:word;
      i,j,k:word;
begin
 ofsstarter:=memw[cseg:ofs(putter_tabs)+2*starter];
 ofsender  :=memw[cseg:ofs(putter_tabs)+2*(pocet_starteru+ender)];
 {decne fromline}
 i:=mem[cseg:ofsstarter];          inc(ofsstarter);
 if i<destY then dec(destY,i) else destY:=0;
 {zjisti kolik bude starteru, enderu}
 starteru  :=mem[cseg:ofsstarter]; inc(ofsstarter);
 enderu    :=mem[cseg:ofsender];   inc(ofsender);
 {zarovna pocty starteru, filleru, enderu aby se vesly pod lastline}
 if destY+starteru             >lastline then starteru:=lastline-destY;
 if destY+starteru+enderu      >lastline then enderu  :=lastline-destY-starteru;
 if destY+starteru+enderu+vyska>lastline then filleru :=lastline-destY-starteru-enderu
                                         else filleru :=vyska         -starteru-enderu;
 {vykresli to}
 Tex2Bit(texseg,desttab,ofsstarter,destX,destY,sirka,starteru,writer);inc(destY,starteru);
 Tex2Bit(texseg,desttab,0         ,destX,destY,sirka,filleru ,writer);inc(destY,filleru);
 Tex2Bit(texseg,desttab,ofsender  ,destX,destY,sirka,enderu  ,writer);inc(destY,enderu);
 {vrati line kde skoncil+1}
 Tex2BitPro:=destY;
end;



{ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ TEXTURY ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ}


{---------------------------------------------------------------------------
 Zakulati jeden z rohu.
 ---------------------------------------------------------------------------}
PROCEDURE ZakulRoh(b:PBitmap;x1,y1,smer:integer;ratio:real);
const r=6*16;
var   y,sir:integer;
      usex,usey:integer;
begin
 if smer>1 then dec(y1,r+1);
 for y:=0 to r do begin
   sir:=round(ratio*(r-round(sqrt(sqr(r)-sqr(y)))));
   case smer of
     0:begin usey:=r-y+y1;usex:=x1    ;end;
     1:begin usey:=r-y+y1;usex:=x1-sir;end;
     2:begin usey:=  y+y1;usex:=x1    ;end;
     3:begin usey:=  y+y1;usex:=x1-sir;end;
     {$ifdef beta}
     else erBetaMsg('zakulroh 1');
     {$endif}
     end;
   if (usey>=0) and (usey<{minI(}b^.sizeY{,b^.tabsize)}) and (usex>=0) and (usex+sir<=b^.sizeX)
    then fillchar(b^.tab^[usey]^[usex],sir,0);
   end;
end;




{---------------------------------------------------------------------------
 Podle syntaxstringu/texture vygeneruje v bitmape pozadi.
 Jinak receno, vygeneruje a naplaca tam textury.
 ---------------------------------------------------------------------------}
PROCEDURE texPlaceTexture(workseg:word;b:PBitmap;st:string);
var   textureinworkseg,basetexture:char;
      origst:string;
      sub:string;
      st1:string;
      modifikant:string[30];
      i,j,lastline,lines,nowline,wasline,code,putX0,putSir,mapSir,roh0,rohsir:word;
      starter,ender,writer,filter:char;
      picc,picy,picx:word;picxy:longint;
      usepicypal:boolean;
      ratio:real;
label 1,nedelete11,putit,nextflag,bug;
begin
 origst:=st;
 textureinworkseg:=#0;
 lastline:=b^.sizeY;
 nowline:=0;
 1:
 wasline:=nowline;

 {odstrihne jedno slovo}
 sub:=CutString(st,' ');
 if sub='' then exit;

 {nastavi defaults}
 starter:='0';
 ender:='0';
 writer:='0';
 mapSir:=b^.sizeX;
 putSir:=mapSir;
 putX0:=0;

 {nacte flags}
 nextflag:
 case sub[1] of '-','=':begin
                    i:=pos('.',sub);
                    st1:=copy(sub,2,i-2);
                    val(st1,j,code);
                    if code>0 then goto bug;
                    case sub[1] of '-':if nowline>=j then dec(nowline,j) else nowline:=0;
                                   '=':if j<lastline then nowline:=j else j:=lastline;
                                   end;
                    end;
                '(':begin
                    st1:=CutString(sub,',');delete(st1,1,1);
                    if length(st1)>0 then begin
                      val(st1,putX0,code);
                      if (putX0>=mapSir) or (code>0) then goto bug;
                      end;
                    st1:=CutString(sub,')');
                    if length(st1)>0 then begin
                      val(st1,putSir,code);
                      if (putX0+putSir>mapSir) or (code>0) then goto bug;
                      end;
                    goto nextflag;{skipne delete(sub,1,1)}
                    end;
                else goto nedelete11;
                end;
 delete(sub,1,i);
 goto nextflag;
 nedelete11:

 {zjisti na kolik radek to bude}
 i:=1;while (length(sub)>=i) and (sub[i]>='0') and (sub[i]<='9') do inc(i);dec(i);
 if i=0 then lines:=32000 else val(copy(sub,1,i),lines,code);
 {if nowline+lines>lastline then lines:=lastline-nowline;}
 delete(sub,1,i);

 {zjisti jaka textura a vygeneruje ji}
 if sub='' then goto bug;
 basetexture:=sub[1];
 delete(sub,1,1);
 case basetexture of 'r':begin
                         if sub='' then begin i:=0;j:=3;end
                                   else begin
                                     i:=ord(sub[1])-48;
                                     if i>3 then goto bug;
                                     j:=i;
                                     end;
                         for i:=i to j do begin
                           if odd(i) then roh0:=putX0+putSir
                                     else roh0:=putX0;
                           case i of 0,1:rohsir:=0;
                                     2,3:rohsir:=lastline;
                                     end;
                           if typeof(b^)<>typeof(TDMBitmap)
                            then ratio:=1
                            else with PDMBitmap(b)^ do ratio:=doporucXres/doporucYres*3/4;
                           zakulroh(b,roh0,rohsir,i,ratio);
                           end;
                         goto 1;
                         end;
                     '~':basetexture:=textureinworkseg;
                     '<':begin{nacte texturu z disku}
                         usepicypal:=sub[1]='*';
                         if usepicypal then delete(sub,1,1);
                         if not OpenDMFile(cutstring(sub,'>')) then goto bug;
                         textureinworkseg:=basetexture;
                         picc:=0;
                         ReadFile(@picx,5);
                         picxy:=longint(picx)*picy;
                         if (picc>16) or (picxy>65536) then goto bug;
                         if usepicypal
                           then with b^.pal^ do begin
                             for i:=1 to picc do begin
                               ReadFile(@pal[24+i].r,1);
                               ReadFile(@pal[24+i].g,1);
                               ReadFile(@pal[24+i].b,1);
                               {Setup(24+i,24+i,pifUsed); neni treba, uz je used}
                               end;
                             end
                           else SeekFileFromCur(3*picc);
                         if picxy=65536 then begin
                           ReadFile(ptr(workseg,0),1);
                           ReadFile(ptr(workseg,1),65535);
                           end
                         else
                           ReadFile(ptr(workseg,0),picxy);
                         CloseFile;
                         asm mov si,0;mov es,workseg;mov cx,word ptr picxy;
                             mov al,256-25;sub al,byte ptr picc
                             @1:sub [es:si],al;inc si;loop @1
                             end;
                         {rozplizne to pres celej seg}
                         if picx<256 then for i:=picy-1 downto 0 do
                           {asm
                             mov si,i;shl si,8
                             mov di,si;add di,picx
                             mov cx,256
                             sub cx,picx
                             call REP_MOVSB_si_nz_w
                           end;}
                           for j:=0 to (256 div picx)-1 do
                             move(mem[workseg:i*picx],mem[workseg:i*256+j*picx],picx);
                         for i:=picy to 255 do
                           move(mem[workseg:(i-picy)*256],mem[workseg:i*256],256);
                         end;
                    else if (basetexture<>textureinworkseg) or (modifikant<>'') then begin
                           MakeTex(basetexture,workseg);
                           textureinworkseg:=basetexture;
                           modifikant:='';
                           end;
                    end;

 {nacte a provede pozadovane upravy textury}
 if sub='' then goto putit;
 if sub[1]='(' then begin
   delete(sub,1,1);
   modifikant:=cutstring(sub,')');
   st1:=modifikant;
   while st1>'' do FilterTex(cutstring(st1,','),workseg);
   end;

 {nacte starter,ender,writer}
 if sub='' then goto putit;
 starter:=sub[1];
 delete(sub,1,1);
 case starter of '-':starter:='0';
                 end;

 if sub='' then goto putit;
 ender:=sub[1];
 delete(sub,1,1);
 case ender of '-':ender:='0';
               end;

 if sub='' then goto putit;
 writer:=sub[1];
 delete(sub,1,1);
 case writer of '-':writer:='0';
                end;

 if sub>'' then goto bug;

 {putne to a kdyz neni konec, zaloopuje k dalsimu slovu}
 putit:
 if basetexture<>'z' then nowline:=Tex2BitPro(workseg,b^.tab,lastline,
        putX0,nowline,putSir,lines,ord(starter)-48,ord(ender)-48,ord(writer)-48);
 goto 1;

bug:
 ReportErr(_(_erSomeErrInTex)+' '+origst);
 b^.Clr2Ful;
end;




FUNCTION paramSetRgb(r,g,b:byte):string11;
begin
 paramSetRgb:='#'+hex[r shr 4]+hex[r mod 16]+hex[g shr 4]+hex[g mod 16]+hex[b shr 4]+hex[b mod 16];
end;

PROCEDURE paramGetRgb(value:string11;var r,g,b:byte);
const colors:array[1..16] of record name:string[7];r,g,b:byte;end=(
        (name:'black'  ;r:$00;g:$00;b:$00),
        (name:'silver' ;r:$c0;g:$c0;b:$c0),
        (name:'gray'   ;r:$80;g:$80;b:$80),
        (name:'white'  ;r:$ff;g:$ff;b:$ff),
        (name:'maroon' ;r:$80;g:$00;b:$00),
        (name:'red'    ;r:$ff;g:$00;b:$00),
        (name:'purple' ;r:$80;g:$00;b:$80),
        (name:'fuchsia';r:$ff;g:$00;b:$ff),
        (name:'green'  ;r:$00;g:$80;b:$00),
        (name:'lime'   ;r:$00;g:$ff;b:$00),
        (name:'olive'  ;r:$80;g:$80;b:$00),
        (name:'yellow' ;r:$ff;g:$ff;b:$00),
        (name:'navy'   ;r:$00;g:$00;b:$80),
        (name:'blue'   ;r:$00;g:$00;b:$ff),
        (name:'teal'   ;r:$00;g:$80;b:$80),
        (name:'aqua'   ;r:$00;g:$ff;b:$ff)
        );
var i:integer;
begin
 r:=0;
 g:=0;
 b:=0;
 if value='' then exit;
 if value[1]='#' then begin
   r:=dehexed(copy(value,2,2));
   g:=dehexed(copy(value,4,2));
   b:=dehexed(copy(value,6,2));
   exit;
   end
 else
   for i:=1 to 16 do
    if colors[i].name=value then begin
     r:=colors[i].r;
     g:=colors[i].g;
     b:=colors[i].b;
     exit;
     end;
 ReportErr(_(_erBadColor)+' '+value);
end;

FUNCTION paramGet(st:string;name:string11):string;
var   i,pred,za:integer;
      ch:char;
begin
 paramGet:='';
 {prochazi seznam}
 i:=1;
 while i<length(st) do begin
   while (st[i]=' ') do
    if i=length(st) then exit else inc(i);
   pred:=pos('=',copy(st,i,255))+i-1;
   if pred=i-1 then break;
   if st[pred+1]='"' then begin inc(pred);ch:='"';end else ch:=' ';
   za:=pos(ch,copy(st,pred+1,255))+pred;
   if za=pred then za:=255;
   if LoCased(copy(st,i,length(name)))=LoCased(name) then begin
     {nacte polozku nalezenou v seznamu}
     paramGet:=copy(st,pred+1,za-pred-1);
     exit;
     end;
   i:=za+1;
   end;
end;

FUNCTION paramSet(st:string;name:string11;value:string):string;
var   i,pred,za:integer;
      ch:char;
begin
 {zajisti aby byly spravne nastaveny uvozovky}
 if (value[1]<>'"') or (value[length(value)]<>'"') then begin
   value:=WithoutChar('"',value);
   if value[1]<>'#' then value:='"'+value+'"';
   end;
 {prochazi seznam}
 i:=1;
 while i<length(st) do begin
   while (st[i]=' ') do
    if i=length(st) then exit else inc(i);
   pred:=pos('=',copy(st,i,255))+i-1;
   if pred=i-1 then break;
   if st[pred+1]='"' then begin inc(pred);ch:='"';end else ch:=' ';
   za:=pos(ch,copy(st,pred+1,255))+pred;
   if za=pred then za:=255;
   if LoCased(copy(st,i,length(name)))=LoCased(name) then begin
     {vymeni polozku nalezenou v seznamu}
     delete(st,pred+1,za-pred-1);
     if st[pred+1]='"' then begin delete(st,pred,2);dec(pred);end;
     if (pred<length(st)) and (st[pred+1]<>' ') then insert(' ',st,pred+1);
     insert(value,st,pred+1);
     paramSet:=st;
     exit;
     end;
   i:=za+1;
   end;
 {pripoji novou polozku na konec seznamu}
 if (st<>'') and (st[length(st)]<>' ') then st:=st+' ';
 paramSet:=st+name+'='+value;
end;

{---------------------------------------------------------------------------
 Podle syntaxstringu/picture vygeneruje v bitmape pozadi.
 Jinak receno, polozi na pozadi obrazek.
 ---------------------------------------------------------------------------}
PROCEDURE texPlacePicture(b:PAbstractMap;st:string);
var bkg        :PBitmap;
    srcSize    :TPoint;
    destRect   :TRect;
    destRng    :TRect;
    newSrcRect :TRect;
    newDestRect:TRect;
    x,y        :word;
    background :PathStr;
    bgtype     :string11;
 procedure flood_bgcolor;
 var rr,gg,bb   :byte;
     bgcolor    :string11;
 begin
  bgcolor:=paramGet(st,'bgcolor');
  {if bgcolor='' then bgcolor:='black';}
  paramGetRgb(bgcolor,rr,gg,bb);
  b^.Col2Ful(b^.Color(rr,gg,bb,255));
 end;
begin
 background:=DecodeLink(paramGet(st,'background'),false{fuk});
 if background<>'' then begin
   bkg:=picLoad(background);
   if bkg<>nil then begin
     JoinMapTo(bkg,b,true);
     bgtype:=locased(paramGet(st,'bgtype'));
     if (bgtype='') or (bgtype='wallpaper') then begin
         {wallpaper}
         y:=0;
         while y<b^.sizeY do begin
           x:=0;
           while x<b^.sizeX do begin
             b^.BtB2Box(bkg,0,0,minI(bkg^.sizeX,b^.sizeX-x),minI(bkg^.sizeY,b^.sizeY-y),x,y);
             inc(x,bkg^.sizeX);
             end;
           inc(y,bkg^.sizeY);
           end;
         KillObj(bkg);
         exit;
         end else
     if bgtype='stretch' then begin
         {stretch to full page}
         b^.ResizeBtF2Ful(0,bkg);
         KillObj(bkg);
         exit;
         end else
     if bgtype='center' then begin
         {one centered picture}
         srcsize.x:=bkg^.sizeX;
         srcsize.y:=bkg^.sizeY;
         destRect.Assign((b^.sizeX-bkg^.sizeX) div 2,(b^.sizeY-bkg^.sizeY) div 2,
          (b^.sizeX-bkg^.sizeX) div 2+bkg^.sizeX,(b^.sizeY-bkg^.sizeY) div 2+bkg^.sizeY);
         destRng.Assign(0,0,b^.sizeX,b^.sizeY);
         GetResizeBltClipping(srcSize,destRect,destRng,newSrcRect,newDestRect);
         flood_bgcolor;
         b^.BtB2Box(bkg,newSrcRect.a.x,newSrcRect.a.y,newSrcRect.b.x-newSrcRect.a.x,newSrcRect.b.y-newSrcRect.a.y,
                        newDestRect.a.x,newDestRect.a.y);
         KillObj(bkg);
         exit;
         end
     else ReportErr(_(_erSyntaxErrInTex)+' bgtype='+bgtype);
     KillObj(bkg);
     end;
   end;
 flood_bgcolor;
end;

{---------------------------------------------------------------------------
 Vraci o jaky typ syntaxe jde.
 't'=texture
 'p'=picture
 'n'=none
 ---------------------------------------------------------------------------}
FUNCTION texType(st:string):char;
begin
 if st='' then texType:='n' else begin
   st:=GetCore(st);
   if (length(st)>=2) and (st[1] in ['a'..'z','A'..'Z']) and (st[2] in ['a'..'z','A'..'Z'])
    then texType:='p' else texType:='t';
   end;
end;

{---------------------------------------------------------------------------
 Podle syntaxstringu vygeneruje v bitmape pozadi.
 ---------------------------------------------------------------------------}
PROCEDURE texPlace(workseg:word;b:PBitmap;st:string);
var ok:boolean;
begin
 case texType(st) of
  'p':texPlacePicture(b,st);
  't':texPlaceTexture(workseg,b,st);
  else begin b^.Clr2Ful;end;
  end;
end;

{°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°INIT/DONE°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°}

END.

udelat filtry:
 - prouzky s barvou prumeru prvnich x pixelu
 - sinusovy zvlneni do stran (posuny po celych radkach)
 - plynule snizovani amplitudy u kraju

