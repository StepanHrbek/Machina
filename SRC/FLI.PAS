{$M 4000,0,0}
USES  sluzby;

TYPE  TFliHead=record
        totalFLIlen:longint;
        magic,frames,width,height,depth,flags,speed:word;
        next,frit:longint;
        future:array[1..102] of byte;
        end;
        {   frames    Number of frames in FLI.  FLI files have
                      a maxium length of 4000 frames.
            width     Screen width (320).
            height    Screen height (200).
            depth     Depth of a pixel (8).
            flags     Must be 0.
            speed     Number of video ticks between frames.
            next      Set to 0.
            frit      Set to 0.
            expand    All zeroes -- for future enhancement.}

CONST wrisir=320;
      workseg:word=0;
      backseg:word=0;
      longtimer:longint=0;

VAR   FLIhead:TFLIhead;
      fliseg,nowframe,frameseg,frameofs,frame2seg,frame2ofs:word;

PROCEDURE errorhalt(i:word);
begin
 asm mov ax,3;int 10h;end;
 write('chyba: ',i);
 halt;
end;

PROCEDURE OneFrame(width,height,srcseg,srcofs:word);assembler;
 asm mov es,workseg;PUSH DS;mov ds,srcseg;mov si,srcofs
     mov cx,[si+6]{chunks}
     add si,16
     @nextchunk:
       PUSH CX
       PUSH SI
       add si,4;lodsw
       cmp ax,11;jz @FLI_COLORS
       cmp ax,12;jz @FLI_LC
       cmp ax,13;jz @FLI_BLACK
       cmp ax,15;jz @FLI_BRUN
       cmp ax,16;jz @FLI_COPY
       push 4;call errorhalt{*}

     @FLI_COLORS:
       lodsw;mov cx,ax{cx=pocet paketu}
       mov dx,3c8h
       mov ah,0 {prave zpracovavana barva}
       @nextpacket:
       push cx
       lodsb;add ah,al;mov al,ah
       out dx,al
       lodsb;mov ah,0;or al,al;jnz @no256;inc ah;@no256:
       mov cx,ax;add cx,ax;add cx,ax
       inc dx;rep outsb;dec dx
       pop cx;loop @nextpacket
       jmp @chunk_done

     @FLI_LC:
       push bp
       lodsw           {pocet radku na preskoceni}
       mov cx,width    {ax*320=offset 1.modifikovaneho radku}
       mov bx,ax
       mul cx
       mov bp,ax
       lodsw           {pocet opravovanych radku}
       add ax,bx
       mul cx          {ax+(pocet radku a preskoceni)*320=offset 1. jiz nemodifikovaneho bodu}
       xor ch,ch
       mov word ptr cs:[@PocetRadekLC+2],ax {modifikuj kod->faster}
       xor ah,ah
     @ZpracRadkuLC:
       mov di,bp       {offset radku}
       mov dh,[si]     {pocet paketu}
       inc si
       test dh,dh
       jz @DalsiRadekLC
     @ZpracPaketLC:
       lodsb
       add di,ax       {tentokrat je na zacatku kazdeho paketu pocet preskakovanych bodu}
       mov cl,[si]     {a opacne jako predtim}
       inc si
       cmp cl,80h
       jae @NeprimaDataLC {<80h ->copy  next cl bytes}
       rep movsb
       jmp @DalsiPaketLC
     @NeprimaDataLC:   {>80h ->repeat next bajt 256-cl times}
       neg cl
       lodsb
       rep stosb
     @DalsiPaketLC:    {one more paket in this line?}
       dec dh
       jnz @ZpracPaketLC {<>0 ->yes}
     @DalsiRadekLC:
       add bp,320      {offset of begin of next line}
     @PocetRadekLC:
       cmp bp,1000     {here is the modified code;one more line?}
       jnz @ZpracRadkuLC  {<>0 ->yes}
       pop bp
       jmp @chunk_done

     @FLI_BLACK:
       mov ax,width;mul height;shr ax,1;mov cx,ax;mov ax,0;mov di,0;rep stosw
       jmp @chunk_done

     @FLI_BRUN:
       mov di,0
       mov dx,height      {dekodovani cele obrazovky pakovane metodou RLE}
      @1:
       mov ah,[si]     {na zacatku kazdeho radku pocet paketu obsahujicich 1 radek}
       xor ch,ch
       inc si
      @ZpracujPaket:
       mov cl,[si]     {read a byte}
       inc si
       cmp cl,81h
       jae @RetezecDat {if <80h}
       lodsb           {then repeat next byte cl times}
       rep stosb
       jmp @DalsiPaket {next paket}
      @RetezecDat:      {if >80h}
       neg cl          {then move next 100h-cl bytes}
       rep movsb
      @DalsiPaket:
       dec ah          {one more paket?}
       jnz @ZpracujPaket {<>0 ->yes}
       dec dx          {one more line?}
       jnz @1          {<>0 ->yes}
       jmp @chunk_done

     @FLI_COPY:
       mov ax,width;mul height;shr ax,1;mov cx,ax;mov di,0;rep movsw
       {jmp @chunkdone}

     @CHUNK_DONE:
       POP SI;add si,[si] { chunklen must be < 64K }
       POP CX
       dec cx
       jnz @nextchunk

     POP DS
     end;

PROCEDURE Frame2Screen(width,height,destx,desty:word);assembler;
 asm mov ax,wrisir;mul desty;add ax,destx;adc dx,0
     mov es,sega000;mov di,ax
     PUSH DS;mov ds,workseg;mov si,0
     mov dx,height;@line:mov cx,width;shr cx,1;
     rep movsw;
{     @nextpix:lodsb;cmp al,1;jz @nostos;mov [es:di],al;@nostos:inc di;loop @nextpix}
     jnc @noodd;movsb;@noodd:sub di,width;add di,wrisir;dec dx;jnz @line;
     POP DS
     end;{}
(*
PROCEDURE Frame2Screen(width,height,destx,desty:word);assembler;
var bit,line,currentx1,currentsir4,vyscounter:word;
 {fs:bx-pikcr ve workseg od 0/0 (WORKSEG 0,1,2,3,4,5..)
  es:di-skreen v destx/desty (SEGA000 0,4,8...1,5,9...  a 2xVIC radek)
  ds:si-background v destx/desty (EMS 0,4,8...1,5,9...  a 2xVIC radek)
----->
  push si;push di
  @nextpixel:
  mov al,[fs:bx];add bx,4;jz (movsb;mov al,[si+wrisir/4];mov [es:di+wrisir/4],al)
                        else (inc si;mov [es:di+wrisir/4],al;stosb);loop @nextpixel
  pop di;pop si
  add di,wrisir/4;add si,wrisir/4;inc line;cmp line,16;jz @novej16radek

  @novej16radek:


  x  bit  x4    w0 w1 w2 w3
  0   0   0     0  1  1  1
  0   1   0     0     1  1
  0   2   0     0        1
  0   3   0     0
  1   0   1     0
  1   1   0     0  1  1  1
  1   2   0     0     1  1
  1   3   0     0        1
  2   0   1     0        1
  2   1   1     0
  2   2   0     0  1  1  1
  2   3   0     0     1  1
  3   0   1     0     1  1
  3   1   1     0        1
  3   2   1     0
  3   3   0     0  1  1  1       w + (3+x-bit)and3
}
 asm
     mov bit,0
  @nextbit:
     mov ax,102h;mov cx,bit;shl ah,cl;mov dx,3c4h;out dx,ax{...set write bit}
     mov ax,desty;mov line,ax
     mov ax,height;mov vyscounter,ax
     mov ax,destx;sub ax,bit;add ax,3;mov bx,ax;shr ax,2;mov currentx1,ax
     and bx,3;add bx,width;shr bx,2;mov currentsir4,bx
     mov di,desty;shl di,7;add di,currentx1{...spocita di}
     mov si,di;and si,2047;mov ax,bit;shl ax,12;or si,ax{...spocita si}
  @next16lines:
     push si;push di
     mov ax,line;shr ax,4;push ax;call reframe;mov ds,framewriseg
     pop di;pop si;
  @nextline:
     mov cx,currentsir4
  @nextpixel:
     mov al,[fs:bx];add bx,4;or al,al;jnz @foreground
     @background:movsb;mov al,[si+wrisir/4];mov [es:di+wrisir/4],al;loop @nextpixel;jmp @zaloop
     @foreground:inc si;mov [es:di+wrisir/4],al;stosb              ;loop @nextpixel
    @zaloop:
     mov ax,wrisir/4;sub ax,currentsir4;add si,ax;add di,ax
     dec vyscounter;jz @endofbit
     inc line;test line,15;jnz @nextline;jmp @next16lines
  @endofbit:
     inc bit;cmp bit,4;jnz @nextbit
     end;{}
  *)

CONST mvel=15;soup=11;maxsed=25;
var   i:word;
PROCEDURE Zamlzit(adr:word);assembler;
asm mov ax,0a000h;mov es,ax;mov ax,256*maxsed+1;mov di,adr;mov dx,mvel;@2:mov cx,mvel
    @1:cmp [es:di],ah;jnc @nomlha;add [es:di],al;@nomlha:inc di;loop @1
    add di,320-soup-2;dec dx;jnz @2;
    end;

LABEL again;

BEGIN
with flihead do begin
 OpenDataFile('birdshow.fli');
 ReadDataFile(128,ofs(flihead),dseg);
 if depth<>8 then errorhalt(4);
 if not AllocConv16((totalFLIlen-128+15) shr 4,fliseg) then errorhalt(7);
 if not AllocConv16((width*height+15) shr 4,workseg) then errorhalt(7);
 if not AllocConv16((width*height+15) shr 4,backseg) then errorhalt(7);
 ReadDataFile(totalFLIlen-128,0,fliseg);

{ asm mov ax,13h;int 10h;end;{mode13x;}
 asm mov ax,13h;int 10h;
     mov ax,0a000h;mov es,ax;mov di,0;mov ax,1313h;mov cx,32768;rep stosw;end;
 for i:=1 to 800 do zamlzit(random(65535));{}

 {store background}
 asm PUSH DS
     mov es,backseg;mov ds,sega000
     mov si,0;mov di,0;mov cx,32000;rep movsw
     POP DS
     end;

 nowframe:=0;
 frameseg:=fliseg;
 frameofs:=0;
 repeat
   inc(longtimer);
   OneFrame(width,height,frameseg,frameofs);
   inc(frameofs,meml[frameseg:frameofs]);
   inc(frameseg,frameofs shr 4);
   frameofs:=frameofs and 15;
   refresh(speed);
   Frame2Screen(width,height,round(20*(1+sin(longtimer/10))),0);
   inc(nowframe);
   if nowframe=1 then begin frame2seg:=frameseg;frame2ofs:=frameofs;end;
   if nowframe>frames then begin nowframe:=1;frameseg:=frame2seg;frameofs:=frame2ofs;end;
   {if nowframe=frames then refresh(20);}
 until port[$60]<$80;
 deallocConv(fliseg);
 deallocConv(workseg);
 deallocConv(backseg);
 end;
END.