uses sluzby;

CONST mvel=15;soup=11;maxsed=25;

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

const fogsir=320;

PROCEDURE Maxiryha(adr:word;size:word);assembler;
asm mov es,sega000;mov di,adr;mov dx,100;
    @0:mov cx,size;mov al,maxsed
    @1:add al,[es:di];add al,[es:di+1];add al,[es:di+fogsir];shr al,2
       stosb;stosb;add di,fogsir-2;stosb
       add di,fogsir;loop @1
    dec dx;jnz @0
    end;

var   i:word;
const myvis:word=0;
      smer:shortint=1;
      long:longint=0;
label 9;

BEGIN
 asm mov ax,13h;int 10h;
 {fill}    mov ax,0a000h;mov es,ax;mov di,0;mov ax,1313h;mov cx,32768;rep stosw;end;

 for i:=1 to 800 do zamlzit(random(65535));
 repeat
   maxiryha(random(65535),4+random(4));
   inc(long);
   case long of 200,400,640,840:begin
     for i:=1 to 100 do begin
       inc(myvis,smer);
       refresh(1);
       setvis(myvis);
       if port[$60]=1 then goto 9;
       end;
     smer:=-smer;
     end;
     end;
 until port[$60]=1;
 9:
END.
