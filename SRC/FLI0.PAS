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

CONST wrisir=512;
{      wordseg:word=0;}

VAR   FLIhead:TFLIhead;
      fliseg,nowframe,frameseg,frameofs,frame2seg,frame2ofs:word;

PROCEDURE errorhalt(i:word);
begin
 asm mov ax,3;int 10h;end;
 write('chyba: ',i);
 halt;
end;

PROCEDURE OneFrame(width,height,srcseg,srcofs,destx,desty:word);assembler;
 asm mov es,sega000{*workseg};PUSH DS;mov ds,srcseg;mov si,srcofs
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

LABEL again;

BEGIN
with flihead do begin
 OpenDataFile('birdshow.fli');
 ReadDataFile(128,ofs(flihead),dseg);
 if depth<>8 then errorhalt(4);
 if not AllocConv16((totalFLIlen-128+15) shr 4,fliseg) then errorhalt(7);
{ if not AllocConv16((width*height+15) shr 4,workseg) then errorhalt(7);}
 ReadDataFile(totalFLIlen-128,0,fliseg);
 asm mov ax,13h;int 10h;end;{mode13x;}
 nowframe:=0;
 frameseg:=fliseg;
 frameofs:=0;
 repeat
   OneFrame(width,height,frameseg,frameofs,0,0);
   inc(frameofs,meml[frameseg:frameofs]);
   inc(frameseg,frameofs shr 4);
   frameofs:=frameofs and 15;
   refresh(speed);
   inc(nowframe);
   if nowframe=1 then begin frame2seg:=frameseg;frame2ofs:=frameofs;end;
   if nowframe>frames then begin nowframe:=1;frameseg:=frame2seg;frameofs:=frame2ofs;end;
   {if nowframe=frames then refresh(20);}
 until port[$60]<$80;
 deallocConv(fliseg);
{ deallocConv(workseg);}
 end;
END.