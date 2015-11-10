
TYPE  TFliHead=record
        totalFLIlen:longint;
        magic,frames,width,height,depth,flags,speed:word;
        next,frit:longint;
        future:array[1..101] of byte;
        delaj:byte;
        end;
CONST longtimer:word=0;
      FLIseg:word=0;
      addtofli=0{50};
{$define addtofli}
VAR   FLIhead:TFLIhead;
      nowFLIframe,frame1seg,frame1ofs,frame2seg,frame2ofs:word;

PROCEDURE prepareFLIframe;assembler;
var oldDS,width,height,srcseg,srcofs:word;
 asm {zkopiruje nektery promenny z DS do SS}
     mov ax,frame1seg;mov srcseg,ax
     mov ax,frame1ofs;mov srcofs,ax
     mov ax,FLIhead.width;mov width,ax
     mov ax,FLIhead.height;mov height,ax

     mov es,workseg;mov oldDS,DS;mov DS,srcseg;mov si,srcofs
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
       push 4;call errorhalt

     @FLI_COLORS:
       push es;mov es,oldDS;lea di,3*addtofli+pal
       lodsw;mov dx,ax{dx=pocet paketu}
       @nextpacket:
       {skip}
       lodsb;mov ah,0;mov cx,ax;add cx,ax;add cx,ax;add di,cx
       {change}
       lodsb;mov ah,0;mov cx,ax;add cx,ax;add cx,ax;jnz @no256;mov cx,300h;@no256:
       lea bx,768+pal;sub bx,di;cmp bx,cx;jc @lastpaquet
       rep movsb
       dec dx;jnz @nextpacket
       pop es
       jmp @chunk_done
      @lastpaquet:
       mov cx,bx
       rep movsb
       pop es
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
       mov ax,width;mul height;shr ax,2;mov cx,ax;mov di,0;db 66h;xor ax,ax;db 66h;rep stosw
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
       mov ax,width;mul height;add ax,3;shr ax,2;mov cx,ax;mov di,0;db 66h;rep movsw
       {jmp @chunkdone}

     @CHUNK_DONE:
       POP SI;add si,[si] { chunklen must be < 64K }
       POP CX
       dec cx
       jnz @nextchunk

     mov DS,oldDS
     {nastavi pointery na dalsi frame
      inc(frame1ofs,meml[frame1seg:frame1ofs]);
      inc(frame1seg,frame1ofs shr 4);
      frame1ofs:=frame1ofs and 15;}
     mov es,frame1seg
     mov si,frame1ofs
     add si,[es:si]{kdyz neni frame>65520 tak to tu nepretece}
     mov ax,si;shr ax,4;add frame1seg,ax{...upravi frame1seg}
     and si,15;mov frame1ofs,si{...upravi frame1ofs}
     end;


PROCEDURE initFLI(st:string);
begin
with flihead do begin
 if OpenDataFile(st)=0 then errorhalt(10);
 if ReadDataFile(128,ofs(flihead),dseg)<>128 then errorhalt(11);
 if depth<>8 then errorhalt(4);
 if not AllocConv16((totalFLIlen-128+15) shr 4,fliseg) then errorhalt(7);
 ReadDataFile(totalFLIlen-128,0,fliseg);
 nowFLIframe:=0;
 frame1seg:=fliseg;
 frame1ofs:=0;
 delaj:=1;
 prepareFLIframe;
 frame2seg:=frame1seg;frame2ofs:=frame1ofs;
 CloseDataFile;
 end;
end;



TYPE  pirrec=record
               filename:string[8];
               pirs:byte;
               InPirX,InPirY:array[0..7] of word;
               pirVys,pirSir:byte;
{               OnScreenX,OnScreenY:word; }
               end;

CONST Xanimos:array[1..3] of pirrec=(
                  (filename:'flag';{s rezervou 4 do vsech stran}
                   pirs:8;
                   InPirX:(0,80,160,240,0,80,160,240);
                   InPirY:(0,0,0,0,82,82,82,82);
                   pirVys:86;
                   pirSir:80{;
                   OnScreenX:wrisir div 2;
                   OnScreenY:visvys*2}),
                  (filename:'ship';
                   pirs:5;
                   InPirX:(0,256 div 3,512 div 3,0,256 div 3,0,0,0);
                   InPirY:(3,3,3,99,99,0,0,0);
                   pirVys:99;
                   pirSir:85{;
                   OnScreenX:wrisir div 2;
                   OnScreenY:visvys*2}),
                  (filename:'ship';
                   pirs:1;
                   InPirX:(0,256 div 3,512 div 3,0,256 div 3,0,0,0);
                   InPirY:(3,3,3,99,99,0,0,0);
                   pirVys:99;
                   pirSir:85{;
                   OnScreenX:wrisir div 2;
                   OnScreenY:visvys*2}));

PROCEDURE initPIR(st:string);
var size:word;
begin
with flihead do begin
 if OpenDataFile(st)=0 then errorhalt(10);
 if ReadDataFile(5,ofs(xsir),dseg)<>5 then errorhalt(11);
 ReadDataFile(3*barevw,ofs(pal)+768-3*barevw,dseg);
 size:=xsir*xvys;
 asm mov es,workseg;xor di,di;mov cx,xsir{xsir*2/2};db 66h;xor ax,ax;db 66h;rep stosw;end;
 ReadDataFile(size,4*xsir,workseg);
 asm mov es,workseg;mov di,xsir;shl di,2;add di,size;mov cx,xsir{xsir*2/2};db 66h;xor ax,ax;db 66h;rep stosw;end;
 nowFLIframe:=0;
 speed:=4;
 width:=xsir;
 delaj:=1;
 CloseDataFile;
 end;
end;

