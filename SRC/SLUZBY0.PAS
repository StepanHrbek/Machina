{!!!!!!!!!!!!!!! posledni verze se setvis scrollingem v editoru !!!!!!!!!!!}
             {dalsi verze uz scrolluje pouze fyzickym kopirovanim}

UNIT Sluzby;

INTERFACE

{graphix}
PROCEDURE Mode13x;
PROCEDURE SetColor(color,r,g,b:byte);
PROCEDURE SetBright(n:byte);
PROCEDURE ShowPal(from,len:byte);
PROCEDURE SmoothSetVis(visx,visy:word);
PROCEDURE Ports2AX;
PROCEDURE BX2ports;
PROCEDURE Refresh(n:byte);
PROCEDURE Refresh2(n:byte);
{VGA driver}
PROCEDURE loadVGAdriver(st:string);{string zakonceny nulou}
PROCEDURE Bank;
PROCEDURE InitBank;
PROCEDURE ExitBank;
{VESA}
PROCEDURE VesaInit;
PROCEDURE VesaSetVis(visx,visy:word);
PROCEDURE VesaBank;
{keyboard}
FUNCTION  KeyPressed:Boolean;
FUNCTION  ReadKey:char;
PROCEDURE WaitKey;
{mouse}
PROCEDURE ResetMouse;
PROCEDURE MouseOn;
PROCEDURE MouseOff;
FUNCTION  MousePress:Boolean;
{PROCEDURE GetMouse(var x,y,z:word);}
PROCEDURE GetMouseChange(var x,y:integer);
PROCEDURE MoveTxtMouse(x,y:word);
{system}
PROCEDURE Execute0(prg:string);{string zakonceny nulou}
PROCEDURE RestoreOldDta;
PROCEDURE StoreOldDta;
{text}
PROCEDURE SplitY(y:word);
PROCEDURE SetVis(vis:word);
PROCEDURE GotoXY(x:word;y:byte);
PROCEDURE GotoXYaVis(x,y:byte);
PROCEDURE End28Msg(st:string);
FUNCTION  AskExit:char;
FUNCTION  Ask(veta:string;maxlen:byte;def:string;first:char):string;
FUNCTION  FileSelect(veta,typ,preselect:string):string;
PROCEDURE Help;
{memory}
FUNCTION  AllocConv16(size16:word;var segment:word):Boolean;
FUNCTION  AllocEMS16K(size16K:word;var handle:word):Boolean;
PROCEDURE DeallocConv(var segment:word);
PROCEDURE DeallocEMS(var handle:word);
PROCEDURE CopySeg(src,dest:word);
PROCEDURE MakeTextureInSeg(n:byte;myseg:word);
{file}
FUNCTION  OpenDataFile(st:string):byte;
FUNCTION  LengthDataFile:longint;
FUNCTION  ReadDataFile(len,kamofs,kamseg:word):word;
PROCEDURE CloseDataFile;
FUNCTION  InteligentneHledejSoubor(hledej:string;var nalezeno:string):boolean;
PROCEDURE DeleteFile0(st:string);
{INI}
FUNCTION  ReadIni(INIname:string;vars:pointer):Boolean;
PROCEDURE WriteIni(INIname:string;vars:pointer);

{$I nazvy.inc}
{$I tenkej.inc}
{$I tlustej.inc}
{$I sipka.inc}
{$I bigfont2.inc}
{$I bard.inc}
{$I setup.inc}
{$I const.inc}

CONST mousepresent:boolean=false;
      textattr:byte=7;
      lastchar='©';
      txsir=80;
      shiftSetvis=11;
      nowbank:byte=0;
      bardhacky:array[#128..lastchar] of word=(
        {nic,car,hac,kr[4] 'A'..'z'[64] dx[16] dy[16]}
        {€}2*64-64+ord('C')+256* 8+1*8192,
        {}0*64-64+ord('u')+256* 0+1*8192,
        {‚}1*64-64+ord('e')+256* 4+1*8192,
        {ƒ}2*64-64+ord('d')+256* 1+5*8192,
        {„}0*64-64+ord('a')+256* 0+1*8192,
        {…}2*64-64+ord('D')+256*12+2*8192,
        {†}2*64-64+ord('T')+256* 9+1*8192,
        {‡}2*64-64+ord('c')+256* 1+1*8192,
        {ˆ}2*64-64+ord('e')+256* 1+1*8192,
        {‰}2*64-64+ord('E')+256* 9+1*8192,
        {Š}1*64-64+ord('L')+256*10+0*8192,
        {‹}1*64-64+ord('I')+256*11+0*8192,
        {Œ}2*64-64+ord('l')+256* 0+1*8192,
        {}1*64-64+ord('l')+256* 2+1*8192,
        {Ž}0*64-64+ord('A')+256* 0+1*8192,
        {}1*64-64+ord('A')+256*15+1*8192,
        {}1*64-64+ord('E')+256*12+1*8192,
        {‘}2*64-64+ord('z')+256* 0+1*8192,
        {’}2*64-64+ord('Z')+256* 6+1*8192,
        {“}0*64-64+ord('o')+256* 0+1*8192,
        {”}0*64-64+ord('o')+256* 0+1*8192,
        {•}1*64-64+ord('O')+256*10+0*8192,
        {–}3*64-64+ord('u')+256* 0+0*8192,
        {—}1*64-64+ord('U')+256*17+1*8192,
        {˜}1*64-64+ord('y')+256* 5+1*8192,
        {™}0*64-64+ord('O')+256* 0+1*8192,
        {š}0*64-64+ord('U')+256* 0+1*8192,
        {›}2*64-64+ord('S')+256* 7+1*8192,
        {œ}2*64-64+ord('L')+256*10+1*8192,
        {}1*64-64+ord('Y')+256*10+1*8192,
        {ž}2*64-64+ord('R')+256*10+2*8192,
        {Ÿ}2*64-64+ord('t')+256* 0+3*8192,
        { }1*64-64+ord('a')+256* 5+1*8192,
        {¡}1*64-64+ord('i')+256* 1+6*8192,
        {¢}1*64-64+ord('o')+256* 5+1*8192,
        {£}1*64-64+ord('u')+256* 4+1*8192,
        {¤}2*64-64+ord('n')+256* 2+1*8192,
        {¥}2*64-64+ord('N')+256*11+1*8192,
        {¦}3*64-64+ord('U')+256*12+0*8192,
        {§}0*64-64+ord('O')+256*12+1*8192,
        {¨}2*64-64+ord('s')+256* 0+1*8192,
        {©}2*64-64+ord('r')+256* 1+1*8192
        );

VAR   pal:array[0..767] of byte;
      nowbright:byte;
      oldDTAofs,oldDTAseg:word;
      newDTA:array[1..43] of byte;
      lasttextvis,nowvis,datahandle,workseg:word;
      txvys:byte absolute 0:$484;
{      txsirtxvys:word absolute 0:$44c;}

IMPLEMENTATION

USES dos;

{ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ KEYBOARD ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ}
FUNCTION  KeyPressed;begin asm mov ah,0bh;int 21h;mov @result,al;end;end;
FUNCTION  ReadKey;begin asm mov ah,8;int 21h;mov @result,al;end;end;
PROCEDURE WaitKey;assembler;asm mov ax,0c08h;int 21h;end;

{ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ MEMORY ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ}
FUNCTION  AllocConv16(size16:word;var segment:word):Boolean;
var i:word;
begin
 asm mov @result,1
     mov ah,48h;mov bx,size16;int 21h;jnc @ok;mov @result,0;xor ax,ax;@ok:
     mov i,ax
     end;
 segment:=i;
end;

FUNCTION  AllocEMS16K(size16K:word;var handle:word):Boolean;
var i:word;
begin
 asm mov @result,1
     mov ax,4300h;mov bx,size16K;int 67h;or ah,ah;jz @ok;mov @result,0;xor dx,dx;@ok:
     mov i,dx
     end;
 handle:=i;
end;

PROCEDURE DeallocConv(var segment:word);assembler;
 asm mov bx,[ss:bp+6]{offset}
     mov es,[ss:bp+8]{segment}
     mov ax,[es:bx];or ax,ax;jz @end
     mov word ptr [es:bx],0;mov es,ax;mov ah,49h;int 21h;
     @end:end;

PROCEDURE DeallocEMS(var handle:word);assembler;
 asm mov bx,[ss:bp+6]{offset}
     mov es,[ss:bp+8]{segment}
     mov dx,[es:bx];or dx,dx;jz @end
     mov word ptr [es:bx],0;mov ah,45h;int 67h
     @end:end;

PROCEDURE CopySeg(src,dest:word);assembler;
 asm
      PUSH DS
      mov es,dest
      mov ds,src
      mov cx,16384;xor si,si;xor di,di;db 66h;rep movsw
      POP DS
      end;

PROCEDURE MakeTextureInSeg(n:byte;myseg:word);
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

Begin
 {nastavi ES pro vsechny dalsi procedury}
 asm mov es,myseg;end;

 case n of

 0:{ ..........TEXTURA 0.......... }
   begin
   Foggy;
   for i:=1 to 60 do for j:=0 to bobu do begin
     alfa:=alfa+0.2;
     inc(lastadr[2*j  ],fogsir*round(random(2)+30*sin(alfa))+round(random(2)+40*cos(alfa)));zamlzit(lastadr[2*j]);
     inc(lastadr[2*j+1],fogsir*(random(spee)-sped)+(random(spee)-sped));odmlzit(lastadr[2*j+1]);
     end;
   end;

 1:{ ..........TEXTURA 1.......... }
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

 2,3:{ ..........TEXTURA 2,3.......... }
   begin
   if n=2 then Foggy;
   for i:=0 to 200 do maxiryha(random(65535),4+random(4));
   end;

 end;

End;

{ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ MOUSE ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ}
PROCEDURE ResetMouse;assembler;asm mov ax,0;int 33h;inc ax;jnz @nomouse;mov mousepresent,1;@nomouse:end;
PROCEDURE MouseOn;assembler;   asm mov ax,1;int 33h;end;
PROCEDURE MouseOff;assembler;  asm mov ax,2;int 33h;end;

FUNCTION MousePress:Boolean;
begin
 asm mov bl,mousepresent;or bl,bl;jz @nomouse
     mov ax,3;int 33h
     @nomouse:
     mov @result,bl
     end;
end;

PROCEDURE GetMouse(var x,y,z:word);{lokalni proc}
var i,j,k:word;
begin;
 asm xor bx,bx;xor cx,cx;xor dx,dx
     cmp mousepresent,0;jz @nomouse
     mov ax,3;int 33h;jmp @ismouse
     @nomouse:{mov bx,0;mov cx,now.mousex;add cx,cx;mov dx,now.mousey}
     @ismouse:mov k,bx;mov i,cx;mov j,dx
     end;
 x:=i;y:=j;z:=k;
end;

PROCEDURE MoveTxtMouse(x,y:word);assembler;{nastaveni polohy M-x-y}
 asm mov ax,4;mov cx,x;shl cx,1;mov dx,y;int 33h;end;

PROCEDURE GetMouseChange(var x,y:integer);
var i,j:integer;
begin
 asm xor cx,cx;xor dx,dx
     cmp mousepresent,0;jz @nomouse
     mov ax,0bh;int 33h
     @nomouse:
     mov i,cx;mov j,dx
     end;
 x:=i div 2;
 y:=j;
end;
{
PROCEDURE ReadVisFromHardware;assembler;
 asm mov dx,3d4h;mov al,0ch;out dx,al;inc dx;in al,dx;mov bh,al
     dec dx     ;mov al,0dh;out dx,al;inc dx;in al,dx;mov bl,al
     mov nowvis,bx
     end;
}
{ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ SYSTEM ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ}
PROCEDURE Refresh(n:byte);assembler;
 asm mov ch,0;mov cl,n;@2:mov dx,3dah;in al,dx;test al,8;jnz @2; @5:in al,dx;test al,8;jz @5;loop @2;end;

PROCEDURE Refresh2(n:byte);assembler;
 asm mov ch,0;mov cl,n;@2:mov dx,3dah;in al,dx;test al,8;jz @2;  @5:in al,dx;test al,8;jnz @5;loop @2;end;

PROCEDURE RestoreOldDta;assembler;
 asm mov ah,1ah;mov dx,oldDTAofs;push ds;mov ds,oldDTAseg;int 21h;pop ds;end;

PROCEDURE StoreOldDta;assembler;
 asm mov ah,2fh;int 21h;mov oldDTAseg,es;mov oldDTAofs,bx
     mov ah,1ah;mov dx,offset newDTA;int 21h;end;

PROCEDURE Ports2AX;assembler;
 asm
    {vga ports 2 ax}
     {write:}mov dx,3c4h;mov al,2;out dx,al;inc dx;in al,dx;mov ah,al
     {read:}mov dx,3ceh;mov al,4;out dx,al;inc dx;in al,dx
     end;

PROCEDURE BX2ports;assembler;
 asm
    {restore vga ports from bx}
     {write:}mov dx,3c4h;mov al,2;mov ah,bh;out dx,ax
     {read:}mov dx,3ceh;mov al,4;mov ah,bl;out dx,ax
     end;

PROCEDURE Execute0(prg:string);
const fakeepb:array[0..15] of byte=(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
var   o,s:word;
begin
 s:=seg(prg);
 o:=ofs(prg)+1;
 asm
    PUSHF;CLI
    mov [cs:offset @ss],ss
    mov [cs:offset @sp],sp
    mov [cs:offset @bp],bp
    mov [cs:offset @ds],ds
    mov ax,4b00h
{    mov dx,o;mov es,s}
{    push ss;pop es;mov dx,di;inc dx}
    push ds;pop es;mov bx,offset fakeepb
    PUSH DS
    push ss;pop ds;mov dx,1+offset prg;add dx,bp
    int 21h
    POP DS
    mov ss,[cs:offset @ss]
    mov sp,[cs:offset @sp]
    mov bp,[cs:offset @bp]
    mov ds,[cs:offset @ds]
    POPF
    jmp @99

@ss: dw 0
@sp: dw 0
@bp: dw 0
@ds: dw 0

    @99:
    end;
end;


{ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ VGA driver ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ}

PROCEDURE hereisVGAdriver;far;assembler;
 asm dw 108h,108h,108h,108h{bank,init,exit,setvis}
     retf
     dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
     dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
     end;

PROCEDURE loadVGAdriver(st:string);
var hand:word;
begin
 asm PUSH DS
     {open}
     mov ax,ss;mov ds,ax
     mov ax,3d00h;mov dx,65536-255{1+offset st};add dx,bp;
     int 21h;jc @end;mov hand,ax
     {read}
     mov ax,cs;mov ds,ax
     mov ah,3fh;mov bx,hand;mov cx,200;lea dx,hereisVGAdriver;int 21h
     {close}
     mov ah,3eh;mov bx,hand;int 21h
     @end:
     POP DS
     end;
end;

PROCEDURE     Bank;    assembler;asm pusha;mov ah,0;div viditelnychbanku;mov nowbank,ah;mov al,ah
                                     mov bx,offset hereisVGAdriver-100h;add bx,[cs:bx+100h];push cs;call bx;
                                     popa;end;
PROCEDURE InitBank;    assembler;asm mov bx,offset hereisVGAdriver-100h;add bx,[cs:bx+102h];jmp bx;end;
PROCEDURE ExitBank;    assembler;asm mov bx,offset hereisVGAdriver-100h;add bx,[cs:bx+104h];jmp bx;end;
PROCEDURE  VisBank;far;assembler;asm mov ah,0;div viditelnychbanku;mov al,ah;
                                     mov bx,offset hereisVGAdriver-100h;add bx,[cs:bx+106h];jmp bx;end;



{ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ V E S A ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ}

PROCEDURE VesaBankPtr;assembler;
 asm dw 0,0;end;

PROCEDURE VesaBank;assembler;
 asm cmp viditelnychBanku,2;jc @bankend
     push ax
     push bx
     push dx
     mov ah,0
     div viditelnychBanku
     xor bx,bx
     xor dh,dh
     mov dl,ah
     db 2eh,0ffh,1eh;dw offset vesabankptr{call far ptr [cs:offset bankptr]}
     pop dx
     pop bx
     pop ax
     @bankend:
     end;

PROCEDURE VesaSetVis(visx,visy:word);assembler;
 asm mov ax,4f07h;xor bx,bx;mov cx,visx;mov dx,visy;int 10h
     end;

PROCEDURE VesaInit;assembler;
 asm {vesa here ?}
     mov ax,4f00h;push ds;pop es;lea di,pal;int 10h
     cmp ax,4fh;jnz @novesa
     {header ok ?}
     cmp word ptr [offset pal],'EV';jnz @novesa
     cmp word ptr [2+offset pal],'AS';jnz @novesa
     {read ptr to setbank}
     mov ax,4f01h;mov cx,101h;int 10h
     cmp ax,4fh;jnz @novesa
     mov ax,[es:12+offset pal];mov [cs:  offset vesabankptr],ax
     mov ax,[es:14+offset pal];mov [cs:2+offset vesabankptr],ax
     {get wrisir, is it 512 ?}
     mov ax,4f06h;mov bl,1;int 10h
     jmp @vesa
     @novesa:mov viditelnychBanku,0
     @vesa:
     end;


{ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ GRAPHIX ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ}
PROCEDURE SetColor(color,r,g,b:byte);assembler;
 asm mov dx,3c8h;mov al,color;out dx,al;inc dx;mov al,r;out dx,al;mov al,g;out dx,al;mov al,b;out dx,al;end;

PROCEDURE SetBright(n:byte);assembler;
 asm mov si,offset pal;mov dx,3c8h;mov al,0;out dx,al;inc dx;mov cx,300h;mov bl,n;mov nowbright,bl
     @1:lodsb;mul bl;{*test ah,0c0h;jz @nottoobright;mov ah,63;@nottoobright:}mov al,ah;out dx,al;loop @1;end;

PROCEDURE ShowPal(from,len:byte);assembler;
 asm mov al,3;mul from;mov si,ax;add si,offset pal;mov dx,3c8h;mov al,from;out dx,al;inc dx
     mov al,3;mul len;mov cx,ax
     rep outsb;end;

PROCEDURE SmoothSetVis(visx,visy:word);assembler;
 asm
     PUSHF
     CLI
    {bity 16-19}
     mov ax,visy
     shr ax,9
     call visbank
    {malej shift o 0-3 bity}
     mov dx,3dah;in al,dx;mov dx,3c0h;mov al,33h;out dx,al;
     mov ax,visx;and al,3;shl al,1;out dx,al
    {velkej shift}
     mov ax,visy;shl ax,7;mov bx,visx;shr bx,2;add bx,ax
     mov dx,3d4h;mov al,0ch;mov ah,bh;out dx,ax;inc al;mov ah,bl;out dx,ax
     POPF

     @end:
    end;

PROCEDURE Mode13x;assembler;
 asm    jmp @start

@vptbl:	dw	06b00h	{ horz total                      }
	dw	05901h	{ horz displayed                  }
	dw	05a02h	{ start horz blanking             }
	dw	08e03h	{ end horz blanking               }
	dw	05e04h	{ start h sync                    }
	dw	08a05h	{ end h sync                      }
	dw	00d06h	{ vertical total                  }
	dw	03e07h	{ overflow                        }
	dw	04009h	{ cell height                     }
	dw	0ea10h	{ v sync start                    }
	dw	02c11h	{ v sync end and protect cr0-cr7  }{ac11}
	dw	0cf12h	{ vertical displayed              }
	dw	04013h	{ offset                          }
	dw	00014h	{ turn off dword mode             }
	dw	0e715h	{ v blank start                   }
	dw	00616h	{ v blank end                     }
	dw	0e317h	{ turn on byte mode               }

@start:
	push	ds
	mov	ax,cs
	mov	ds,ax

	mov	ax,13h		{ start with standard mode 13h           }
	int	10h		{ let the bios set the mode              }

	mov	dx,3c4h		{ alter sequencer registers              }
	mov	ax,0604h	{ disable chain 4                        }
	out	dx,ax


	mov	ax,0f02h	{ set write plane mask to all bit planes }
	out	dx,ax
	push	di
	xor	di,di
	mov	ax,0a000h	{ screen starts at segment A000          }
	mov	es,ax
	mov	cx,32768	{ ((XSIZE*YSIZE)/(4 planes))/(2 bytes per word) }
	xor	ax,ax
	cld
	rep	stosw		{ clear the whole of the screen }
	pop	di


        {spusti CHAIN4 ale ne X}
        MOV     DX,3D4h
        MOV     AX,14h                  { Disable dword mode}
        OUT     DX,AX
        MOV     AX,0E317h               { Enable byte mode.}
        OUT     DX,AX                   {}

(**)
	mov	ax,0100h	{ synchronous reset     }
	out	dx,ax		{ asserted              }
	mov	dx,3c2h		{ misc output           }
	mov	al,0e7h		{ use 28 mHz dot clock  }
	out	dx,al		{ select it             }
	mov	dx,3c4h		{ sequencer again       }
	mov	ax,0300h	{ restart sequencer     }
	out	dx,ax		{ running again         }

	mov	dx,3d4h		{ alter crtc registers  }

	mov	al,11h		{ cr11                  }
	out	dx,al		{ current value         }
	inc	dx		{ point to data         }
	in	al,dx		{ get cr11 value        }
	and	al,7fh		{ remove cr0 -> cr7     }
	out	dx,al		{    write protect      }
	dec	dx		{ point to index        }
	cld
	mov	si,offset @vptbl
	mov	cx,17
@outlp:	lodsw
	out	dx,ax
	loop	@outlp(**)
	pop	ds

  end;

{ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ FILE ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ}
FUNCTION OpenDataFile(st:string):byte;
begin
 OpenDataFile:=0;
 st:='x\'+st+#0;
 asm
  {open st}
   mov ax,3d00h;mov dx,bp;sub dx,256-1
   push ds;mov bx,ss;mov ds,bx;int 21h;pop ds;
   mov datahandle,ax;jnc @ok;
  {open x\st}
   mov ax,3d00h;mov dx,bp;sub dx,256+1
   push ds;mov bx,ss;mov ds,bx;int 21h;pop ds;
   mov datahandle,ax;jc @bad
  {end}
   @ok:mov @result,1;@bad:
   end;
end;

FUNCTION LengthDataFile:longint;
var lo,hi:word;
begin
 asm
    {to konec}
     mov ax,4202h;mov bx,datahandle;mov cx,0;mov dx,0;int 21h;
     mov lo,ax{[ss:bp+offset @result],ax}
     mov hi,dx{[ss:bp+offset @result-2],dx}
    {to zacatek}
     mov ax,4200h;mov bx,datahandle;mov cx,0;mov dx,0;int 21h;
     end;
 LengthDataFile:=lo+longint(hi) shl 16;
end;

FUNCTION ReadDataFile(len,kamofs,kamseg:word):word;
begin
 asm
  {read data}
   push ds;mov bx,datahandle;mov cx,len;mov dx,kamofs;mov ds,kamseg;mov ah,3fh;int 21h;pop ds;mov @result,ax
   {*jnc @ouk;push 20;mov datahandle,ax;call errorhalt;@ouk:{}
   end;
end;

PROCEDURE CloseDataFile;assembler;
 asm mov bx,datahandle;mov ah,3eh;int 21h;end;

FUNCTION InteligentneHledejSoubor(hledej:string;var nalezeno:string):boolean;
var skupina_adresaru:byte;
begin
 {*}
 InteligentneHledejSoubor:=false;
(*
   asm
    mov skupina_adresaru,0
   {store old dta}
    call StoreOldDta

{-----prohleda dir kde je self-----}
   {get psp,environment,selfpath}
    push ds
    push ds
    mov ah,62h;int 21h;mov es,bx;mov ds,[es:02ch]
    mov di,65535;mov ax,0;
    @1:inc di;cmp [di],ax;jnz @1;add di,4
   {copy envir_selfpath to path(+0)}
    pop es
    mov si,di;mov di,offset edtextbody
    mov cx,1000;@nextbyte1:lodsb;stosb;or al,al;loopnz @nextbyte1
    pop ds
    cmp byte ptr [di-6],cislo;jnz @notfoundhere
    dec byte ptr [di-6]
   {try to open previous pareni.exe}
    mov ax,3d02h;mov dx,offset edtextbody;int 21h;jnc @found
    @notfoundhere:

{-----prohleda current dir-----}
   {try to open previous pareni.exe}
    mov ax,3d02h;mov dx,offset lastparfilename+2;int 21h;jnc @found

{-----prohleda current dir\..\par*.*\-----}
   {get current dir to (+0)}
    mov byte ptr [offset edtextbody],'\'
    mov ah,47h;mov dl,0;mov si,offset edtextbody+1;int 21h
    push ds;pop es;mov di,offset edtextbody;mov al,0;mov cx,1000;repne scasb;dec di
   {o lomitko zpatky}
    @nextbyte2:dec di;cmp di,offset edtextbody;jc @notfound;cmp byte ptr [di],'\';jnz @nextbyte2
    mov i,di{adresa znaku \ pred current adresarem}
   {set DTA}
    pusha
    mov ah,1ah;mov dx,offset edtextbody+1000;int 21h
    popa
   {vrazi tam '\3'#0    - musi byt bez hvezdicek }
    @first3:
    mov di,i;mov ax,256*minulycislo+'\';stosw;mov ax,0;stosw
    jmp @findfirstdir
   {vrazi tam '\03'#0   - musi byt bez hvezdicek }
    @first03:
    mov di,i;mov ax,'0\';stosw;mov ax,minulycislo;stosw
    jmp @findfirstdir
   {vrazi tam '\par*.*'#0  - mohou byt pouzity hvezdicky }
    @firstpar:
    mov di,i;mov ax,'p\';stosw;mov ax,'ra';stosw;mov ax,'.*';stosw;mov ax,'*';stosw;
   {findfirst dir (+0)}
    @findfirstdir:
    mov ah,4eh;mov dx,offset edtextbody;mov cx,0ffffh;int 21h;jc @skupina_prohledana;jmp @checkdir
   {findnext dir (+0)}
    @findnextdir:
    mov dx,offset edtextbody;mov ah,4fh;int 21h;jc @notfound
   {check if dir}
    @checkdir:
    mov al,10h;test [offset edtextbody+1000+15h],al;jz @findnextdir
   {copy path(+0) to fullstring(+2000)}
    mov si,offset edtextbody;mov di,offset edtextbody+2000
    @nextbyte4:lodsb;stosb;or al,al;loopnz @nextbyte4
   {copy dirname(+1015) to fullstring(+2000)}
    mov si,offset edtextbody+1000+1eh;mov di,i;add di,2001
    mov cx,13;@nextbyte5:lodsb;stosb;or al,al;loopnz @nextbyte5;dec di
   {copy previous pareni.exe to fullstring(+2000)}
    mov si,offset lastparfilename;lodsb;mov ah,0;mov cx,ax;rep movsb;
   {try to open fullstring(+2000)}
    mov ax,3d00h;mov dx,offset edtextbody+2000;int 21h;jnc @found
   {prohledal celej adresar a co ted ? To zalezi na skupine_adresaru}
    @skupina_prohledana:
    inc skupina_adresaru
    cmp skupina_adresaru,1;jz @first03
    cmp skupina_adresaru,2;jz @firstpar
    jmp @findnextdir

    @found:
    mov i,ax
   {read exe header}
    mov bx,i;mov cx,1ch;mov dx,offset header;mov ah,3fh;int 21h;
   {precte z headeru setup byte}
    mov ax,[offset header+1ah];mov setup,ax
   {close previous pareni.exe}
    mov bx,i;mov ah,3eh;int 21h;
    @notfound:
   {restore old dta}
    call RestoreOldDta
   {clrscr}
    mov ax,3;int 10h
   end;
  end;
  *)
end;


{ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ TEXT ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ}

PROCEDURE Store(x,y,sir,vys:word);assembler;
 asm dec x;dec y
     push ds
     mov ax,ds;mov es,ax;mov di,offset pal+123
     mov ax,txsir;mul y;add ax,x;add ax,nowvis;shl ax,1;mov si,ax;
     stosw;mov ax,vys;stosw;mov ax,sir;stosw{storne parametry}
     mov ds,segb800
     mov dx,vys
     @1:
     mov cx,ax;rep movsw;add si,2*txsir;sub si,ax;sub si,ax
     dec dx;jnz @1
     pop ds
     end;

PROCEDURE Restore;assembler;
 asm mov si,offset pal+123;mov es,segb800
     lodsw;mov di,ax;lodsw;mov dx,ax{vys};lodsw{sir}
     @1:
     mov cx,ax;rep movsw;add di,2*txsir;sub di,ax;sub di,ax
     dec dx;jnz @1
     end;

PROCEDURE SplitY(y:word);assembler;
 asm mov dx,3d4h;mov bx,y;mov al,18h;mov ah,bl;out dx,ax
     mov al,7;out dx,al;inc dx;in al,dx;and al,255-16;test bh,1;jz @no1;add al,16;@no1:out dx,al;dec dx
     mov al,9;out dx,al;inc dx;in al,dx;and al,255-64;test bh,2;jz @no2;add al,64;@no2:out dx,al
     end;

PROCEDURE SetVis(vis:word);assembler;
 asm mov bx,vis;mov nowvis,bx;mov dx,3d4h;mov al,0ch;out dx,al;inc dx;mov al,bh;out dx,al;
     dec dx;mov al,0dh;out dx,al;inc dx;mov al,bl;out dx,al;end;

PROCEDURE GotoXY(x:word;y:byte);assembler;
 asm mov ax,nowvis;add ax,x;mov bl,txsir;div bl;
     mov dl,ah;mov dh,y;add dh,al;dec dl;dec dh;
     mov ah,2;mov bh,0;int 10h
     end;

PROCEDURE GotoXYaVis(x,y:byte);assembler;
 asm xor ax,ax;mov es,ax
     mov ah,2;mov bh,0;mov dl,x;mov dh,y;dec dl;dec dh;int 10h;
     mov al,txsir;mul y;mov bx,lasttextvis;sub bx,shiftSetvis;add bx,2*txsir;cmp ax,bx;jc @set;
     mov bx,ax;mov al,txsir;mul [es:txvys];add ax,txsir;sub bx,ax;mov ax,bx
     jc @9;mov bx,lasttextvis;sub bx,shiftSetvis;cmp ax,bx;jc @9
     add ax,3*txsir
     @set:
     sub ax,2*txsir;jns @ok;mov ax,0;@ok:
     add ax,shiftSetvis;mov lasttextvis,ax;push ax;call setvis
     @9:
     end;

PROCEDURE WriXY(x,y:word;st:string);assembler;
 asm mov ax,txsir;mul y;add ax,x;sub ax,txsir+1;add ax,nowvis;shl ax,1;mov di,ax;mov es,segb800
     mov ah,textattr
     PUSH ds;
     lds si,[ss:bp+offset st+4]
     lodsb;or al,al;jz @nope;mov ch,0;mov cl,al
     @loop:lodsb;stosw;loop @loop
     @nope:
     POP ds;
     end;

PROCEDURE End28Msg(st:string);
type  Tend28=record c1,c2,c3:word;bo,sp:byte;end;
const endu28=3;
      end28:array[1..endu28] of Tend28=(
        (c1:(16*0+11)*256+ord('Û');c2:(16*4+15)*256+ord(' ');c3:(16*4+11)*256+ord('Ä');bo:0;sp:0),
        (c1:(16*2+10)*256+ord('Û');c2:(16*2+14)*256+ord(' ');c3:(16*2+ 0)*256+ord('Í');bo:0;sp:1),
        (c1:(16*2+10)*256+ord('ß');c2:(16*2+14)*256+ord(' ');c3:(16*2+10)*256+ord('Ä');bo:2;sp:0));
var   i:word;
      e28:byte;
begin
 e28:=random(endu28);
 i:=ofs(end28)+sizeof(Tend28)*e28;
 asm mov si,i
     {font size=15}
     mov dx,3d4h;mov al,9;out dx,al;inc dx;in al,dx;and al,240;add al,14;out dx,al
     {kurzor o pixel nahoru}
     mov ah,1;mov cx,0c0eh;int 10h
     {clr screen top}
     mov es,segb800;mov di,25*80*2
     mov cx,80;mov ax,[si  ];rep stosw{down line}
     mov cx,80;mov ax,[si+2];rep stosw{top text}
     mov cx,80;mov ax,[si+4];rep stosw{top line}
     {border=2}
     mov ax,1001h;mov bh,[si+6];int 10h
     {vertical panning}
     mov dx,3d4h;mov ax,0e08h;out dx,ax{}
     end;
 nowvis:=0;
 gotoxy((txsir-length(st)) shr 1,27);
 write(st);
 gotoxy(1,1);
 splitY(400-25*15-1-end28[e28].sp);
 setvis(80*25);
end;

FUNCTION AskExit:char;
const le=51;
      line:array[0..4] of string[le]=(
        '                                                   ',
        '   ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ Edit ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»   ',
        '   º  You''ve made changes since the last save. º   ',
        '   º    Save   Don''t save   Continue editing   º   ',
        '   ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼   ');
      x:array[0..2] of byte=(8,15,28);
      l:array[0..2] of byte=(6,12,18);
var   ch:char;
      x1,y1,a:byte;
      i:word;
begin
 a:=0;
 x1:=(txsir-le) div 2+2;
 y1:=(txvys-5) shr 1;
 store(x1,y1,le,6);
 textattr:=16*4+15;
 for i:=0 to 5 do wrixy(x1,y1+i,line[i mod 5]);
 gotoxy(0,62);
 repeat{28048}
   textattr:=16*7;   wrixy(x1+x[a]-1,y1+3,copy(line[3],x[a],l[a]));
   ch:=readkey;
   textattr:=16*4+15;wrixy(x1+x[a]-1,y1+3,copy(line[3],x[a],l[a]));
   case ch of 'S':ch:='s';
              'D':ch:='d';
              'C':ch:='c';
              #27:ch:='c';
              #75:a:=(a+2) mod 3;
              #77:a:=(a+1) mod 3;
              #13:case a of 0:ch:='s';1:ch:='d';2:ch:='c';end;
              end;
 until (ch='s') or (ch='d') or (ch='c');
 restore;
 AskExit:=ch;
end;

FUNCTION Ask(veta:string;maxlen:byte;def:string;first:char):string;
var i,x1,x2,le,le1,le2:word;
    path,veta2:string;
    ch:char;
begin
 path:=def;
 i:=pos(#13,veta);
 if i>0 then begin veta2:=copy(veta,i+1,255);veta[0]:=chr(i-1);end else veta2[0]:=#0;

 {sirka ramecku}
 le:=maxlen;
 le1:=length(veta);
 le2:=length(veta2);
 if le1>le then le:=le1;
 if le2>le then le:=le2;

 x1:=(txsir-le) div 2;
 x2:=(txsir-maxlen) div 2;
 store(x1,13,le,3);
 textattr:=16+11;
 for i:=1 to le do wrixy(x1+i-1,13,' ');wrixy(x1+(le-length(veta )) div 2,13,veta );
 for i:=1 to le do wrixy(x1+i-1,14,' ');wrixy(x1+(le-length(veta2)) div 2,14,veta2);
 for i:=1 to le do wrixy(x1+i-1,15,' ');
 i:=length(path)+1;
 while keypressed do readkey;

repeat
 wrixy(x2,15,path+' ');
 gotoxy(x2-1+i,15);
 ch:=readkey;
 case ch of
   ' '..'©':if (length(path)<maxlen) and (ch>=first) then begin
        path:=copy(path,1,i-1)+ch+copy(path,i,length(path));inc(i);end;
   #27:begin path:='';ch:=#13;end;
   #8:if i>1 then begin path:=copy(path,1,i-2)+copy(path,i,length(path));dec(i);end;
   #0:case readkey of
       'K':if i>1 then dec(i);
       'M':if i<length(path)+1 then inc(i);
       'S':if i<=length(path) then path:=copy(path,1,i-1)+copy(path,i+1,length(path));
       'G':i:=1;
       'O':i:=length(path)+1;
       end;
   end;
until ch=#13;

 textattr:=7;
 restore;
 ask:=path;
end;

{*
PROCEDURE DeleteFile0(st:string);assembler;
 asm push ds;mov ax,ss;mov ds,ax;mov ah,41h;
     mov dx,bp;add dx,9;
     int 21h;pop ds
     end;
}
PROCEDURE DeleteFile0(st:string);
var ofss,segs:word;
begin
 ofss:=ofs(st)+1;
 segs:=seg(st);
 asm push ds;mov ds,segs;mov dx,ofss;mov ah,41h;
     int 21h;pop ds
     end;
end;

FUNCTION FileSelect(veta,typ,preselect:string):string;
const maxfajlu=120;
var   str:array[0..maxfajlu] of string[14];
      i,j,fajlu:integer;
      t:searchrec;
      ch:char;
      st,st2:string[50];
      keyb:Boolean;
      x1:byte;

procedure FindAll(typ:string);
var j:word;
begin
 findfirst(typ,0,t);
 while doserror=0 do begin
  str[i]:=t.name;
  for j:=1 to length(str[i]) do case str[i,j] of 'A'..'Z':str[i,j]:=chr(ord(str[i,j])+ord('a')-ord('A'));end;
  if i<maxfajlu then inc(i);
  findnext(t);
  end;
end;

label 1,2,3,restart;
Begin
 st:='';
 keyb:=false;
 restart:
 i:=0;
 if typ='*.x' then findall('x\'+typ) else findall(typ);

 fajlu:=i-1;
 if fajlu=-1 then begin fileselect:=ask(veta,20,'','!');exit;end;

 {sort}
 repeat
  j:=0;
  for i:=0 to fajlu-1 do if str[i]>str[i+1] then begin inc(j);st2:=str[i];str[i]:=str[i+1];str[i+1]:=st2;end;
 until j=0;

 for i:=fajlu downto 0 do if preselect>=str[i] then goto 1;1:
 x1:=36-fajlu div 20*13 div 2;
 textattr:=7;
 {clrscr;}asm mov es,segb800;mov di,0;mov ax,7*16+32;mov cx,60*txsir;rep stosw;end;
 setvis(0);
 wrixy(18,1,veta);
 repeat
   if not keyb then st:=str[i];
   textattr:=7;
   for j:=0 to fajlu do wrixy(x1+j div 20*13,4+j mod 20,str[j]);
   textattr:=15;        wrixy(x1+i div 20*13,4+i mod 20,str[i]);
   wrixy(60,1,st+'         ');
   gotoxy(60+length(st),1);
   ch:=readkey;
   case ch of #0:case readkey of
                   #75:begin dec(i,20);keyb:=false;end;
                   #77:begin inc(i,20);keyb:=false;end;
                   #72:begin dec(i);   keyb:=false;end;
                   #80:begin inc(i);   keyb:=false;end;
                   'G':begin i:=0;     keyb:=false;end;
                   'O':begin i:=fajlu; keyb:=false;end;
                   'I':begin i:=i   -i mod 20;keyb:=false;end;
                   'Q':begin i:=i+19-i mod 20;if i>fajlu then i:=fajlu;keyb:=false;end;
{alt-d}            #32:if length(ask(#13' M m smazat soubor '+str[i]+' (ENTER=ano, ESC=ne) ? ',1,' ','þ'))>0
                        then begin DeleteFile0(str[i]+#0);keyb:=true;preselect:=st;goto restart;end;
                   end;
              '!'..'@','a'..'z'
                 :if keyb=true then st:=st+ch else begin keyb:=true;st:=ch;end;
               #8:if length(st)>0 then st[0]:=chr(length(st)-1);
               #9:begin ch:=#13;st:=str[i];goto 3;end;
              end;
   if keyb then begin
     for i:=0 to fajlu do if str[i]>=st then goto 2;
     end
    else begin
     while i<0 do inc(i,fajlu+1);
     while i>fajlu do dec(i,fajlu+1);
     end;
   2:
 until (ch=#27) or (ch=#13);
 3:
 if ch=#13 then fileselect:=st else fileselect:='';
 setvis(lasttextvis);
End;

var
kurzor:word;
radek:byte;

PROCEDURE Help;
var   f:text;
      st:string;
      ch:char;
      i,j,k,l:word;
      textbarva:byte;
const nowhelpvis:word=0;
begin
assign(f,'editor.hlp');reset(f);
if ioresult>0 then ask(#13' Chyb¡ helpfajl... Cos s nim proved ? ',0,'',' ') else
begin
asm{clrscr}mov di,0;mov es,segb800;db 66h;mov ax,7*256+32;dw 7*256+32;mov cx,16384/2;db 66h;rep stosw
   {move kurzor}mov ah,2;mov bh,0;mov dx,0ff01h;int 10h
   end;
setvis(txsir*nowhelpvis);
kurzor:=0;radek:=0;
i:=ofs(st);
while not eof(f) do begin
  inc(radek);
  readln(f,st);
  if st[1]='.' then begin textbarva:=10;st[1]:=' ';end else
  if radek>5 then textbarva:=7 else textbarva:=14;
  asm mov ax,0b800h;mov es,ax;mov si,i;mov di,kurzor;mov cl,[ss:si];cmp cl,0;jz @9;mov ch,0;inc si;mov ah,textbarva
      @nextchar:segss lodsb;cmp al,':';jnz @not;mov ah,7;@not:stosw;loop @nextchar;
      @9:add kurzor,2*txsir;
      end;
  end;
close(f);
asm
 {set mouse range}mov ax,8;mov cx,0;mov dh,0;mov dl,radek;dec dl;shl dx,3;int 33h;
 {mouseon}mov ax,1;int 33h
 {mov movemouse}mov ax,4;mov cx,320;mov dx,nowhelpvis;add dx,12;shl dx,3;int 33h;
 end;
ch:=' ';
repeat
 getmouse(i,j,k);
 if j shr 3<nowhelpvis then dec(nowhelpvis);
 if j shr 3>nowhelpvis+txvys then inc(nowhelpvis);
 if keypressed then begin
   l:=nowhelpvis;
   ch:=readkey;
   case ch of 'H':if nowhelpvis>0 then dec(nowhelpvis);
              'P':if nowhelpvis+txvys+1<radek then inc(nowhelpvis);
              'I':if nowhelpvis>txvys then dec(nowhelpvis,txvys) else nowhelpvis:=0;
              'Q':if nowhelpvis+txvys+txvys+1<radek then inc(nowhelpvis,txvys) else nowhelpvis:=radek-txvys-1;
              'G':nowhelpvis:=0;
              'O':nowhelpvis:=radek-txvys-1;
              end;
   moveTxtMouse(2*i,j+8*(nowhelpvis-l));
   end;
 setvis(txsir*nowhelpvis);
until (k>0) or (ch=#27);
asm {mouseoff}mov ax,2;int 33h;end;
end;
end;

{ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ INI ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ}

var   typprom:byte;
      adrprom:word;
      vars_ofs,vars_seg:word;
      vars_ptr:pointer absolute vars_ofs;

FUNCTION LoCase(st:string):string;
var i:byte;
    ch:char;
begin
 for i:=1 to length(st) do begin
   ch:=st[i];
   case ch of 'A'..'Z':inc(ch,ord('a')-ord('A'));
              end;
   st[i]:=ch;
   end;
 locase:=st;
end;

PROCEDURE ErrorMsg(st:string);
begin
 writeln(st);
 port[$21]:=0;
 halt;
end;

FUNCTION FindVariable(name:string):boolean;
begin
     asm mov @result,0
         mov typprom,100
         mov es,vars_seg;mov si,vars_ofs;dec si;dec si
         mov di,offset name;add di,bp
         @nextstring:
         add si,2
         mov ah,255{dylka stringu}
         mov bl,0{zatim neni zadny rozdil}
         @nextbyte:
         inc ah
         seges lodsb;cmp al,30;jc @endofstr
         inc di;cmp al,[ss:di];jz @stejny;mov bl,1;@stejny:
         jmp @nextbyte
         @endofstr:
         {v ES narazil na konec stringu}
          {neni uz konec seznamu vars ?}
          cmp ah,0;jz @badkonec
          {shodny dylky ?}
          mov di,offset name;add di,bp;cmp ah,[ss:di];jnz @nextstring
          {zadny rozdily ?}
          or bl,bl;jnz @nextstring
         {byla nalezena shoda}
         mov typprom,al{typ promenny}
         seges lodsw;mov adrprom,ax{adresa promenny}
         mov @result,1
         @badkonec:
         end;
end;

FUNCTION ReadIni(INIname:string;vars:pointer):Boolean;
var   f:text;
      uknastring:^string;
      st,name,udaj:string;
      someword,i,code:word;
      somebyte:byte;
Begin
 vars_ptr:=vars;
 assign(f,INIname);
 reset(f);
 if ioresult>0 then ReadIni:=false else begin
  ReadIni:=true;
  while not eof(f) do begin
   readln(f,st);
   if (st[0]>#0) and (st[1]<>';') then begin
     i:=pos('=',st);
     name:=locase(copy(st,1,i-1));
     udaj:=locase(copy(st,i+1,200));
     if FindVariable(name) then case typprom and 7 of
                   0,1:if udaj<>'' then begin
{                       if udaj='' then somebyte:=255 else}
                       if udaj='ne' then somebyte:=0 else
                       if udaj='ano' then somebyte:=1 else begin
                         val(udaj,somebyte,code);
                         if code>0 then errormsg('Chybny udaj v radce: '+st);
                         end;
                       byte(mem[dseg:adrprom]):=somebyte;
                       end;
                     2:if udaj<>'' then begin
{                       if udaj='' then someword:=65535 else} begin
                         val(udaj,someword,code);
                         if code>0 then errormsg('Chybne cislo v radce: '+st);
                         end;
                       word(memw[dseg:adrprom]):=someword;
                       end;
                     3:begin
                       uknastring:=ptr(dseg,adrprom);
                       uknastring^:=udaj;
                       end;
                     else errormsg('Interni chyba INI readeru, nahlas Dementovi...');
                     end(* else errormsg('{*} neznamy parametr v INI souboru: '+st)(**);
     end;
   end;
  close(f);
  end;
End;

PROCEDURE WriteIni(INIname:string;vars:pointer);
var   f,g:text;
      st,name,udaj:string;
      someword,i,code:word;
      somebyte:byte;
      uknastring:^string;
const bleble:string[10]='bleble';
Begin
 vars_ptr:=vars;
 code:=0;
 deleteFile0('bleble.'#0);
 assign(f,INIname);
 rename(f,'bleble');
 if ioresult<>0 then errormsg('Chyba p©i ukl d n¡ INI.');
 reset(f);
 assign(g,INIname);{*umi prejmenovat i v jinym adresari?}
 rewrite(g);
 while not eof(f) do begin
   readln(f,st);
   if (st[0]>#0) and (st[1]<>';') then begin
     i:=pos('=',st);
     name:=copy(st,1,i-1);
     if FindVariable(locase(name)) and (typprom>=8) then begin
       case typprom and 7 of
                     0:begin
                       somebyte:=byte(mem[dseg:adrprom]);
                       case somebyte of 0:udaj:='ne';
                                        1:udaj:='ano';
                                      255:udaj:='';
{                                      else udaj:='******************'+chr(somebyte);{}
                                      else errormsg('Chybna hodnota promenne pri ukladani INI.');{}
                                      end;
                       end;
                     1:begin
                       somebyte:=byte(mem[dseg:adrprom]);
                       if somebyte=255 then udaj:='' else str(somebyte,udaj);
                       end;
                     2:begin
                       someword:=byte(memw[dseg:adrprom]);
                       if someword=65535 then udaj:='' else str(someword,udaj);
                       end;
                     3:begin
                       uknastring:=@mem[dseg:adrprom];
                       udaj:=uknastring^;
                       end;
                     end;
       st:=name+'='+udaj;
       end;
     end;
   writeln(g,st);
   if ioresult<>0 then errormsg('Mozna je plny disk, mozna je INI nebo cely disk readonly.');
   end;
 erase(f);
 close(g);
End;


END.