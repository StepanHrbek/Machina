{$R-,S-,I-,E-,N-,M 15000,0,0}

{$define parenist}

{$ifdef pareniste}
 {$define textinside}
 {$define datainside}
 {$define midas}
{$else}
 {$define editor}
{$endif}

{$ifdef midas}
 uses mids3m,timer;
{$endif}

{$ifdef editor}
 uses crt,dos;
{$endif}

CONST irq=2;
      firstpoint:byte=0;

 {$I nazvy.inc}
 {$I tenkej.inc}
 {$I tlustej.inc}
 {$I sipka.inc}
 {$I f:\-ostatn0\bigfont2.inc}


{$ifdef midas}
 const samplu=3;
       volume:byte=63;
       module:pointer=nil;
       modulu:byte=0;
       mSt:string[13]='*.s3m'#0;
       dylkamodname=13;
 var   ModuleNames:array[1..10] of string[dylkamodname];
       sampleHandle:array[1..samplu] of byte;
       tmrScrSync:word;
 const PtmrScrSync:Pword=@tmrscrsync;
{$endif}

{$ifdef textinside}
{$else}
 var f:text;
{$endif}

{$ifdef datainside}
 {$i data.inc}
 const nekdyhand:word=0;
 var   vzdyhand:word;
{$else}
{$endif}

{$ifdef editor}
 const shiftSetvis=11;
       maxlines=250;
       txsir=80;
       txvys:byte=25;
       txsirtxvys:word=80*25;
       mode:byte=0;
 var   edofs,scrx,scry:array[0..maxlines-1] of word;
       edfajl:string[13];
       ednowx,ednowy,ednowi:word;
       linetotal,linenow:word;
       lasttextvis,blokstart,blokend:word;
       wlcha:char;
       wlcol,nowsloupec,edzmena,otec:byte;
       blokon:boolean;
{$else}
 {$I page.inc}
{$endif}

CONST maxaskstringu=10;
      maxtogglu=40;
      maxbuttonu=20;
      askmaxlen=24;

      edtextmaxlen=10000;
      headlen=6;
      pageStartup='mainpage';
      menuStartup='mainmenu';
      setupStartup='setup';
      wrisir=512;
      wrivys=512;
      vissir=360;
      visvys=464;
      mysiokraj=40;
      askx4=170 div 4;
      anox4=170 div 4;
      inspic='~';
      chgcol='`';
      insbigchar='|';
      insbutton='';
      newsloupec='^';
      mramor='§';
      tabulka='“';
      togl='þ';
      askSymbol=':';
      rovnejLeft='@';
      lastchar='©';
      xorcolor=17;
      mouseactive:byte=1;
      mouseflag:byte=0;
      setrvacnost=20;
      sunindex:byte=0;
      intree:byte=1;
      inlist:byte=1;
      usedcols:byte=1;
      exeleng:longint=0;
      sipky:byte=0;
      numero:byte=0;
      stillNumero:word=0;
      txtcols:array[1..6,0..2] of byte=(
        (30,30,63),
        (30,63,30),
        (63,30,30),
        (63,63,00),
        (63,63,63),
        (00,63,63));

      bx=13;
      bigcols:array[0..bx,1..8] of byte=(
       (14,15,3,4,4,4,4,4),
       (14,15,11,12,12,12,12,12),

       (1,2,3,4,4,4,4,4),
       (5,6,7,8,8,8,8,8),
       (9,10,11,12,12,12,12,12),
       (13,14,15,16,16,16,16,16),

       (3,3,3,4,2,2,2,2),
       (7,7,7,8,6,6,6,6),
       (11,11,11,12,10,10,10,10),
       (15,15,15,16,14,14,14,14),

       (3,4,23,24,20,20,20,20),
       (20,20,5,7,7,7,7,7),
       (10,16,10,10,10,10,10,10),
       (14,12,14,14,14,14,14,14)
       );
{$ifdef editor}
      bigcolstxt:array['A'..chr(ord('A')+bx)] of byte=(1,4, 9,10,12,14, 1,2,4,6, 16+7,32+15,4,6);
{$endif}
      mx=7;
      mixcols:array[0..mx] of word=
        (256*8+8,256*16+12,
        256*15+16,256*19+20,
        256*24+20,257*4,
        257*12,257*24);
{$ifdef editor}
      mixcolstxt:array[0..mx] of byte=(10,16*4+14,14,15,16*7+11,9,12,11);
      mxkey:array[0..mx] of string[5]=('F5','ShiF5','CtrF5','AltF5','CtrF6','AltF6','CtrF7','AltF7');
{$endif}

VAR   edtextofs,headerofs:word;
      header:array[1..headlen] of char;
      edtextbody:array[0..edtextmaxlen] of char;
      edtext:array[2..60000] of char absolute firstpoint;

      last_abs_x,last_abs_y,
      presx,presy,presz,
      workseg,frameseg,fogseg,bigfontseg,
      wriy,fileadr,datahandle,
      Wmezer, Wodsaz, Wodcentr, Wsirmez, Wtoedi, Wnewedi,
      pixStart,pixLen,pixMid,pixMinicharSir,pixOdsaz,
      ofsst,framewriseg,wordX,
      lastvisx,lastvisy,
      edtextlast,edi,
      mixword,minifnt,
      fntseg16,fntofs16,
      shadowvis                  :WORD;

      hlavapat,sloupcu           :SHORTINT;

      togglu,askstringu,
      nowask,nowaskx,
      key,nowbright,setup        :BYTE;

      LastopenLength             :LONGINT;

      st                         :STRING;

      ref                        :BOOLEAN;

      predminifontem:array[1..8] of byte;
      minifont:array[' '..lastchar,0..15,0..7] of byte;
      zaminifontem:array[1..8] of byte;
      TlustejPropSir,TenkejPropSir:array[' '..lastchar] of byte;
      sunx,suny:array[0..setrvacnost-1] of shortint;
      pal:array[0..767] of byte;
      hlavapata:array[-1..18] of record x1,y16,oedi,firstline:word;end;
      sloupce:array[0..9] of record x1,y16,firstedi,firstline,xx1,yy16,lastedi,lastline:word;end absolute hlavapata;
      toggle:array[1..maxtogglu] of record y16:word;on:byte;end;
      askstring:array[1..maxaskstringu] of record y16:word;str:array[1..askmaxlen] of char;end;


      head:word absolute 0:$41a;
      tail:word absolute 0:$41c;

CONST lenfont=sizeof(minifont);

{-----smooth scrolling------}
{$ifdef midas}
{$else}
CONST poradi:array[1..3] of char='ovk';
{$endif}

{----popis screenu----}
TYPE  TPopisScreenu=record
                      radek,handle,mousex,mousey:word;
                      visx,visy:integer;
                      buttonu:byte;
                   {p}palet:byte;
                   {p}nowpal:word;
                   {p}jakapaleta:array[1..10] of byte;
                   {p}kdepaletaTop,kdepaletaBot:array[1..10] of word;
                      bu:array[1..maxbuttonu] of record x1,y1,x2,y2:word;fi:string[13];end;
                      fl:string[13];
                      backgroundcolor:byte;
                      end;
CONST FirstScreen:tpopisscreenu=
        (radek:0;handle:0;mousex:256;mousey:220;visx:(wrisir-vissir) div 2;visy:0;buttonu:0;palet:0;nowpal:1);
VAR   now:tpopisscreenu;
      tree:array[1..10] of TPopisScreenu;

{------format.X-------}
VAR   xsir,xvys,barevw:word;
      barevb:byte absolute barevw;

{------big font-------}
CONST fontu=2;
VAR   charseg:array[1..fontu,' '..lastchar] of word;
      cetnost:array[1..fontu,' '..lastchar] of byte;
CONST charseglen=sizeof(charseg)+sizeof(cetnost);

PROCEDURE BigFontXlat;assembler;asm dw 0,0,0,0,0;end;



{ --------------MEMORY--------------}

PROCEDURE EMSDone;
var i,j:word;
begin
 {---EMS---}
  for j:=1 to intree do if tree[j].handle>0 then begin
    i:=tree[j].handle;
    tree[j].handle:=0;
    asm {dealloc ems}mov ah,45h;mov dx,i;int 67h;end;
    end;
  intree:=1;
end;

PROCEDURE MemDone;
var i,j:word;
    c:char;
begin
 {---EMS---}
  emsdone;
 {----CONV----}
  for i:=1 to fontu do
   for c:=' ' to lastchar do begin
    j:=charseg[i,c];
    if j>0 then asm {dealloc conv}mov ah,49h;mov es,j;int 21h;end;
    end;
  asm
   mov ah,49h;mov es,workseg;int 21h;
   mov ah,49h;mov es,fogseg;int 21h;
   end;
end;

PROCEDURE ERRORHALT(n:byte);
begin
{$ifdef midas}
 if module<>nil then begin
    midasStopModule(module);            { stop playing }
    midasClose;                         { uninitialize MIDAS }
    end;
{$endif}
 asm mov ax,3;int 10h;end;
 tail:=head;
 {pusti shifty}
 asm mov ax,0;mov es,ax;mov dx,417h;in al,dx;and al,$f0;out dx,al;end;

 case n of 0:write('Nezapome¤ n m poslat v˜sledky ankety !!!');
           1:write('Pot©ebuju v¡c konven‡n¡ pamˆti.');
           2:write('Pot©ebuju EMM, QEMM nebo tak nˆjak.');
           3:write('Pot©ebuju v¡c EMS pamˆti.');
        else write('Nezn m˜ error ‡¡slo ',n);
        end;
 memdone;
 port[$21]:=0;
 halt;
end;

PROCEDURE Alloc;assembler;
 asm
   mov ah,48h;int 21h;jc @3;ret
   @3:push 1;call errorhalt
  end;

PROCEDURE MemInit;assembler;
 asm
 {----EMS----}
{$ifdef pareniste}
   {test if present}
    {mov ax,4000h;int 67h;cmp ax,0;jz @2;push 2;call errorhalt;@2:}
    mov ax,0;mov es,ax;mov si,[es:91ch];mov es,[es:91eh];add si,9;mov bx,si;
    mov ax,'EM';mov cx,8;@no:inc si;cmp [es:si],ax;jz @OK;loop @no;
    push 2;call errorhalt;@ok:
   {get emm frame}mov ax,4100h;int 67h;mov frameseg,bx
{$endif}
 {----CONV----}
   mov bx,65536/16;call alloc;mov fogseg,ax
   mov bx,65536/16;call alloc;mov workseg,ax
   end;


PROCEDURE Reframe(ii:word);assembler;
 asm
   {reframe}
   mov cx,frameseg
   mov bx,ii;shr bx,1;jnc @startseg;add ch,2;@startseg:
   mov framewriseg,cx
   mov ax,4400h;mov dx,now.handle;int 67h;
   end;

PROCEDURE DeallocNowhandle;assembler;
 asm mov ah,45h;mov dx,now.handle;mov now.handle,0;int 67h;end;


{ --------------VIDEO--------------}

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
	loop	@outlp
	pop	ds

(*
  mov	dx,3c4h		{ * prestane kazdy bajt psat 4krat za sebe }
  mov	ax,0e04h
  out	dx,ax

  Mov Dx,3d4h
  Mov Al,$14
  Out Dx,Al
  Inc Dx
  mov al,64
  Out Dx,AL
*)
  end;



PROCEDURE SetBackPal(n:byte);
var   i:byte;
begin
 case n of 0:{grey} for i:=0 to 47 do pal[3*usedcols+i]:=9+i div 5;
           1:{red}  for i:=0 to 47 do pal[3*usedcols+i]:=(3+i div 3+((i+2) mod 3 shr 1)*abs(40-i));
           2:{green}for i:=0 to 47 do pal[3*usedcols+i]:=(3+i div 3+((i+1) mod 3 shr 1)*(40-i));
           3:{blue} for i:=0 to 47 do pal[3*usedcols+i]:=(3+i div 3+( i    mod 3 shr 1)*abs(40-i));
       4:{zelena-r} for i:=0 to 47 do pal[3*usedcols+i]:=(3+((i+1) mod 3 shr 1)*(i div 3)+((i+2) mod 3 shr 1)*abs(35-i));
       5:{hnedo-r}  for i:=0 to 47 do pal[3*usedcols+i]:=(3+((i+1) mod 3 shr 1)*(i div 3)+((i+2) mod 3*2 shr 1)*abs(30-i));
       6:{fialova-r}for i:=0 to 47 do pal[3*usedcols+i]:=(3+(i mod 3 shr 1)*(i div 3)+((i+2) mod 3*2 shr 1)*abs(30-i));
       7:{sedomodra-r}for i:=0 to 47 do pal[3*usedcols+i]:=(3+(i mod 3)*(i div 4)+((i+2) mod 3*3 shr 2)*abs(35-i));
           end;
end;


{ ÛÛ ÛÛ ÛÛ   FILE MANAGER   ÛÛ ÛÛ ÛÛ }

PROCEDURE InitDataFile;assembler;
 asm
{$ifdef datainside}
   {get psp,environment,selfpath}
    push ds
    mov ah,62h;int 21h;mov es,bx;mov ds,[es:02ch]
    mov di,65535;mov ax,0;
    @1:inc di;cmp [di],ax;jnz @1;add di,4
   {open self}
    mov ax,3d02h;mov dx,di;int 21h
    pop ds
    mov vzdyhand,ax
   {read exe header}
    mov bx,vzdyhand;mov cx,1bh;mov dx,offset header;mov ah,3fh;int 21h;
   {pocita dylku exe fajlu}
    cmp word ptr [offset header],'ZM';jnz @notexe
    mov ax,[offset header+4];dec ax;shl ax,1;mov bl,ah;shl ax,8;add ax,[offset header+2]
    mov [offset exeleng],ax;mov [offset exeleng+2],bx
    @notexe:
   {koukne jestli ma jet na menu nebo page}
    mov al,[offset header+1ah];mov setup,al
   {open pikcr fajl}
    mov ax,3d00h;mov dx,offset nekdyfile+1;int 21h;
    jc @nodatafajl;mov nekdyhand,ax;@nodatafajl:
{$else}
{$endif}
    end;

PROCEDURE SaveSetup;assembler;{zapise do EXE headeru vysledek setupu}
   asm
{$ifdef pareniste}
     {set pointer}
     mov ax,4200h;mov bx,vzdyhand;mov cx,0;mov dx,1ah;int 21h;
     {write 1}
     mov ah,40h;mov bx,vzdyhand;mov cx,1;mov dx,offset setup;int 21h;
{$endif}
     end;

FUNCTION OpenDataFile(st:string):byte;
{$ifdef datainside}
var i:byte;
    poslo,poshi:word;
    mypos:longint absolute poshi;
label 1;
begin
 OpenDataFile:=0;
 for i:=1 to datafajlu do if data[i].name=st then goto 1;
 exit;
 1:
 with data[i] do begin
   mypos:=start;
   lastopenLength:=len;
   if handle=0 then begin datahandle:=vzdyhand;inc(mypos,exeleng);end
               else begin if nekdyhand=0 then exit{kdyz chybi druhy datafajl}
                                         else datahandle:=nekdyhand;end;
   asm
    {set pointer}
    mov ax,4200h;mov bx,datahandle;mov cx,poslo;mov dx,poshi;int 21h;
    end;
   end;
 OpenDataFile:=1;
end;
{$else}
var ofsst:word;
begin
 OpenDataFile:=0;
 st:='x\'+st+#0;
 ofsst:=ofs(st);
 asm
  {open st}
   mov ax,3d00h;mov dx,ofsst;add dx,3
   push ds;mov bx,ss;mov ds,bx;int 21h;pop ds;
   mov datahandle,ax;jnc @ok;
  {open x\st}
   mov ax,3d00h;mov dx,ofsst;inc dx
   push ds;mov bx,ss;mov ds,bx;int 21h;pop ds;
   mov datahandle,ax;jc @bad
  {end}
   @ok:mov @result,1;@bad:
   end;
end;
{$endif}

{$ifdef editor}
FUNCTION LengthDataFile:word;
begin
 asm
    {to konec}
     mov ax,4202h;mov bx,datahandle;mov cx,0;mov dx,0;int 21h;
     mov @result,ax
    {to zacatek}
     mov ax,4200h;mov bx,datahandle;mov cx,0;mov dx,0;int 21h;
     end;
end;
{$endif}

FUNCTION ReadDataFile(len,kamofs,kamseg:word):word;
begin
 asm
  {read data}
   push ds;mov bx,datahandle;mov cx,len;mov dx,kamofs;mov ds,kamseg;mov ah,3fh;int 21h;pop ds;mov @result,ax
   end;
end;

PROCEDURE CloseDataFile;assembler;
{$ifdef datainside}
 asm end;
{$else}
 asm {close}mov bx,datahandle;mov ah,3eh;int 21h;end;
{$endif}

PROCEDURE MoveTextFile2EdText(st:string);
const dummylen=60;
      dummy:array[0..dummylen] of char=
        '0403'#13#10'^0100012310'#13#10'........'#13#10#13#10'Tento text nebyl za©azen...'#13#10#0;
var   i:word;
begin
{$ifdef textinside}
 if (OpenDataFile(st)=0) or (lastopenLength<>ReadDataFile(lastopenLength,ofs(header),seg(header))) then begin
   for i:=0 to dummylen do
    edtext[headerofs+i]:=dummy[i];
   edtextlast:=ofs(header)+i-1;
   for i:=1 to length(st) do edtext[edtextofs+12+i]:=st[i];
   end
  else edtextlast:=ofs(header)+lastopenLength;
{$else}
 {precte textfajl pokud existuje, kdyztak mu vytvori i header}
 if OpenDataFile(st)=0 then EdTextLast:=edtextofs else begin
   edtextlast:=ofs(header)+ReadDataFile(65535,ofs(header),seg(header));
   CloseDataFile;
   end;
 {na zacatek fajlu da header}
 if (header[5]<>#13) or (header[6]<>#10) then begin
   move(header,edtextbody,edtextlast-headerofs);
   if edtextlast>edtextofs then inc(edtextlast,headlen);
   header[4]:='7';
   header[5]:=#13;
   header[6]:=#10;
   end;
 {na konec fajlu da CR/LF}
 if (edtextlast=edtextofs) or (edtext[edtextlast-1]<>#10) then begin
   edtext[edtextlast]:=#13;
   edtext[edtextlast+1]:=#10;
   inc(edtextlast,2);
   end;
{$endif}
end;



{   ÛÛÛ -------  BIG FONT ------- ÛÛÛ }


CONST vys=128;
      sir=64;
      obtahbase=8;
      fillbase=8;
TYPE  tchara=array[0..vys-1,0..sir shr 3-1] of byte;
      mapa=array[1..vys,1..sir] of byte;
VAR   chara:tchara;
      freebyte:byte{musi byt pred sha};sha:mapa;
      obtahu:word;
      b1:array[0..999] of word;
      b2:array[0..999] of word;


PROCEDURE Obrys(zn:char;size:byte);
var i,j,k,l,z:integer;
function Q(x,y:byte):byte;
begin
 if (y>=vys shr 3) or (x>=sir shr 3) then q:=0 else
  {q:=minifont[zn,y,x] div 3;}
  q:=tlustej[zn,y] shr (8-x) mod 2;
end;
Begin
 {clr chara}
 asm mov ax,ds;mov es,ax;lea di,chara;mov cx,sir*vys/8/2;mov ax,0;rep stosw;end;

 for j:=0 to vys shr 3-1 do for i:=0 to sir shr 3-1 do begin
   z:=tab[2*(2*(2*(2*(2*(2*(2*(2*
      q(i-1,j+1)+q(i,j+1))+q(i+1,j+1))+q(i-1,j))+q(i,j))+q(i+1,j))+q(i-1,j-1))+q(i,j-1))+q(i+1,j-1)]
      -255+n;
   case size of 2:for k:=0 to 7 do chara[8*j+k,i]:=b[z,k];
                1:for k:=0 to 3 do begin
                   l:=b[z,2*k] or b[z,2*k+1];
                   l:=l or l shl 1;
                   l:=l and 128+l shl 1 and 64+l shl 2 and 32+l shl 3 and 16;
                   chara[4*j+k,i div 2]:=chara[4*j+k,i div 2] or (l shr (4*(i mod 2)));
                   end;
                end;
   end;
End;

PROCEDURE TransTo256Bitmap;assembler;
 asm mov ax,ds;mov es,ax;
     lea di,sha;mov cx,sir*vys/2;mov ax,0;rep stosw;{clear bitmap}
     lea si,chara;mov di,offset sha-1{+656}
     mov dh,vys{128 radek pod sebou}
     @1:
     mov dl,sir/8{8 bajtu vedle sebe}
     @2:
     lodsb;mov ah,al;mov al,obtahbase;mov cx,8;
     @3:shl ah,1;jc @bit;inc di;loop @3;jmp @9;
                     @bit:stosb;loop @3;@9:
     dec dl;jnz @2
     add di,sir-64
     dec dh;jnz @1
     end;

PROCEDURE OBTAH1;assembler;
 asm lea si,sha+sir+1
     lea di,b1
     mov ax,ds;mov es,ax
     mov bx,0
     mov dl,0
     mov cx,sir*(vys-2)-2
    @loop:inc si;cmp byte ptr [si],obtahbase;loopnz @loop;jcxz @end;
     cmp [si-1],dl;jz @okraj
     cmp [si+1],dl;jz @okraj
     cmp [si-sir+1],dl;jz @okraj
     cmp [si+sir-1],dl;jz @okraj
     jmp @loop
    @okraj:
     mov byte ptr [si],1
     mov ax,si;stosw
     inc bx
     jmp @loop
    @end:
     mov obtahu,bx
     end;

PROCEDURE OBTAH2(cil:byte);assembler;
 asm mov cx,obtahu;or cx,cx;jz @99;
     mov si,offset b1;mov di,offset b2;mov al,fillbase;mov ah,cil;mov dx,0
  @1:mov bx,[si];inc si;inc si
  @5:dec bx;      cmp [bx],al;jnz @6;mov [bx],ah;mov [di],bx;inc di;inc di;inc dx;
  @6:add bx,2;    cmp [bx],al;jnz @7;mov [bx],ah;mov [di],bx;inc di;inc di;inc dx;
  @7:sub bx,sir+1;cmp [bx],al;jnz @8;mov [bx],ah;mov [di],bx;inc di;inc di;inc dx;
  @8:add bx,2*sir;cmp [bx],al;jnz @9;mov [bx],ah;mov [di],bx;inc di;inc di;inc dx;
  @9:loop @1;mov obtahu,dx;mov di,offset b1;mov si,offset b2;mov cx,dx
     cld;mov ax,ds;mov es,ax;rep segds movsw
     @99:
     end;

   { MMMMMMMMMM-------  COLORZ  -------MMMMMMMMMMM }

PROCEDURE Refresh(n:byte);assembler;
 asm mov ch,0;mov cl,n;@2:mov dx,3dah;in al,dx;shr al,4;jc @2; @5:mov dx,3dah;in al,dx;shr al,4;jnc @5;loop @2;end;
PROCEDURE Refresh2(n:byte);assembler;
 asm mov ch,0;mov cl,n;@2:mov dx,3dah;in al,dx;shr al,4;jnc @2; @5:mov dx,3dah;in al,dx;shr al,4;jc @5;loop @2;end;
PROCEDURE SetColor(color,r,g,b:byte);assembler;
 asm mov dx,3c8h;mov al,color;out dx,al;inc dx;mov al,r;out dx,al;mov al,g;out dx,al;mov al,b;out dx,al;end;
PROCEDURE SetBright(n:byte);assembler;
 asm mov si,offset pal;mov dx,3c8h;mov al,0;out dx,al;inc dx;mov cx,300h;mov bl,n;mov nowbright,bl
     @1:lodsb;mul bl;test ah,0c0h;jz @nottoobright;mov ah,63;@nottoobright:mov al,ah;out dx,al;loop @1;end;
{$ifdef editor}
PROCEDURE BrightUp;var i:byte;begin for i:=1 to 15 do begin refresh(1);setbright(16*i);end;end;
PROCEDURE BrightDown;var i:byte;begin for i:=15 downto 0 do begin refresh(1);setbright(16*i);end;end;
{$else}
PROCEDURE BrightUp;var i:byte;begin for i:=1 to 31 do begin refresh(1);setbright(8*i);end;end;
PROCEDURE BrightDown;var i:byte;begin for i:=30 downto 0 do begin refresh(1);setbright(8*i);end;end;
{$endif}

{$ifdef datainside}
PROCEDURE SetUpperPal(n:word);assembler;
 asm mov bx,n;mov now.nowpal,bx;mov al,[bx+offset now.jakapaleta-1] {al=jakapaleta[n]}
     dec al;mov bl,sizeofdata;mul bl;add ax,offset data;mov bx,ax {bx=@data[jakapaleta[n]]}
     mov si,[bx+sizeofdata-2]{.ofss}
     mov bl,[bx+sizeofdata-3]{.colors};mov bh,0;mov cx,bx;add cx,bx;add cx,bx

     mov di,offset pal+3*256;sub di,cx
     mov ax,ds;mov es,ax
     @2:segcs lodsb;stosb;loop @2
     end;

PROCEDURE SetAndVisUpperPal(n:word);assembler;
 asm mov bx,n;mov now.nowpal,bx;mov al,[bx+offset now.jakapaleta-1] {al=jakapaleta[n]}
     dec al;mov bl,sizeofdata;mul bl;add ax,offset data;mov bx,ax {bx=@data[jakapaleta[n]]}
     mov si,[bx+sizeofdata-2]{.ofss}
     mov bl,[bx+sizeofdata-3]{.colors};mov bh,0
     mov dx,3c8h;mov al,0;sub ax,bx;out dx,al;inc dx;mov cx,bx;add cx,bx;add cx,bx
     push cx
     push si
     @1:segcs lodsb;out dx,al;loop @1;

     pop si{zacatek dat}
     pop cx{barev*3}
     mov di,offset pal+3*256;sub di,cx
     mov ax,ds;mov es,ax
     @2:segcs lodsb;stosb;loop @2
     end;
{$endif}

   { ------------- T I M E R ------------ }

PROCEDURE Nop;far;assembler;asm end;

PROCEDURE TimerBrightDown;far;assembler;
asm
 mov al,nowbright
 sub al,2
 jc @end
 mov ah,0
 push ax
 call setbright
 @end:
end;

PROCEDURE TimerBrightUpDown;far;assembler;
const long:word=0;
asm
 inc long
 mov bx,long
 mov al,nowbright
 mov ah,0
 cmp bx,63      ;jnc @notup ;add ax,4;@notup:
 cmp bx,63+100  ;jc @notdown;sub ax,4;@notdown:
 cmp ah,0;jnz @end
 push ax
 call setbright
 @end:
end;

{------------ ostatni ---------------}

PROCEDURE SmoothSetVis;assembler;
 asm
     PUSHF
     CLI
    {malej shift o 0-3 bity}
     mov dx,3dah;in al,dx;mov dx,3c0h;mov al,13h;out dx,al;
     mov ax,now.visx;and al,3;shl al,1;out dx,al;mov al,32;out dx,al
    {velkej shift}
     mov ax,now.visy;shl ax,7;mov bx,now.visx;shr bx,2;add bx,ax
     mov dx,3d4h;mov al,0ch;out dx,al;inc dx;mov al,bh;out dx,al;
     dec dx;mov al,0dh;out dx,al;inc dx;mov al,bl;out dx,al
     POPF
    end;


PROCEDURE Ems2Screen(line:word);assembler;var bit,workframseg:word;
 asm {reframe, prepare ds}
      push ds
      mov ax,4400h;mov bx,line;
      mov cx,frameseg;shr bx,1;jnc @segfr;add ch,2;@segfr:mov workframseg,cx;
      mov dx,now.handle;int 67h;
     {prepare ds,es}
      mov ax,line;shl ax,11;mov [cs:offset @za-2],ax
      mov mouseactive,0
      mov es,sega000;mov ds,workframseg
      mov si,0
      mov bit,3
     {set bit}
      @nextbit:
      mov ax,102h;mov cx,bit;shl ah,cl;mov dx,3c4h;out dx,ax
     {copy}
      mov di,0;@za:
      mov cx,1024;rep movsw
     {loop 4 bits}
      dec bit;jns @nextbit
      pop ds
      mov mouseactive,1
     end;

PROCEDURE Doprava(n:integer);var i:integer;
 begin for i:=0 to n do inc(sunx[(sunindex+i) mod setrvacnost],(n+1-i)*3 div (2*n+2));end;
PROCEDURE Doleva (n:integer);var i:integer;
 begin for i:=0 to n do dec(sunx[(sunindex+i) mod setrvacnost],(n+1-i)*3 div (2*n+2));end;
PROCEDURE Dolu   (n:integer);var i:integer;
 begin for i:=0 to n do inc(suny[(sunindex+i) mod setrvacnost],(n+1-i)*2 div (n+1));end;
PROCEDURE Nahoru (n:integer);var i:integer;
 begin for i:=0 to n do dec(suny[(sunindex+i) mod setrvacnost],(n+1-i)*2 div (n+1));end;

FUNCTION Osekej(n:integer):integer;
begin
 n:=n div 7;
 if n>8 then n:=8;
 osekej:=n;
end;

PROCEDURE Mouse(on:byte);assembler;var a:word;
{write:3c4,2,0-15; read:3ce,4,0-3}
 asm pushf;cli
     mov al,on
     cmp al,mouseflag;jz @99

     cmp al,0;jz @mazat_z_last_absolute_position
    {novy souradnice}
     mov cx,now.mousex;add cx,now.visx;mov last_abs_x,cx
     mov dx,now.mousey;add dx,now.visy;mov last_abs_y,dx
     jmp @joj
    {stary souradnice}
    @mazat_z_last_absolute_position:
     mov cx,last_abs_x
     mov dx,last_abs_y

    @joj:
     xor mouseflag,1
     mov es,sega000
     lea si,sipka
     shl dx,7{dx*wrisir/4};mov di,cx;shr di,2;add di,dx
     and cl,3;mov ah,cl;mov al,4;mov a,ax{read}
     mov ax,102h;shl ah,cl;mov dx,3c4h{write}
     mov cx,4
    @loop:
     push cx

     xchg a,ax{->read}
     add dl,10;out dx,ax
     inc ah;and ah,3
     xchg a,ax{->write}
     sub dl,10;out dx,ax

     mov cx,16;
    @1:{mov bx,[si];}
     {}
     mov bl,[si];cmp bl,0;jz @skip1;xchg bl,[es:di  ];@skip1:mov [si],bl;add si,4
     mov bl,[si];cmp bl,0;jz @skip2;xchg bl,[es:di+1];@skip2:mov [si],bl;add si,4
     {xor [es:di],bx}
     add di,wrisir/4;loop @1
     sub di,4*wrisir
     sub si,16*8-1

     shl ah,1;cmp ah,16;jnz @ok;mov ah,1;inc di;@ok:

     pop cx;loop @loop
     @99:
     popf
     end;


PROCEDURE Ano(y16:word;on:byte);assembler;
 asm
     push y16;call reframe;mov es,framewriseg

     lea si,anobitmap+3;cmp on,0;jnz @2;lea si,nebitmap+3;@2:
     mov di,anox4
     mov dx,4

    @loop:
     mov cx,16;
     push di
    @1:movsb;add si,3;movsb;add si,3;movsb;add si,3;add di,wrisir/4-3;loop @1
     pop di;add di,4*wrisir
     sub si,16*4*3+1
     dec dx;jnz @loop

     @99:
     end;

PROCEDURE EMS2screenMouseoff(y16:word);assembler;
asm
     mov mouseactive,0;push 0;call mouse
     push y16;call EMS2screen
     push 1;call mouse;mov mouseactive,1
     end;


PROCEDURE InstallMouse;assembler;
 asm
    {zrychleni M}
     mov ax,0fh;mov cx,4;mov dx,cx;int 33h
    {nastaveni range M-x}
     mov ax,7;mov cx,0;mov dx,2*vissir-16;int 33h
    {nastaveni range M-y}
     mov ax,8;mov cx,0;mov dx,visvys-16;int 33h;
    {nastaveni handleru M}
     mov ax,0ch;mov cx,7fh;mov dx,cs;mov es,dx;mov dx,offset @mousehandler;int 33h;
     mov ax,ds;mov [cs:offset @q-2],ax
     jmp @9

@MOUSEHANDLER:
     mov si,0;@q:mov ds,si;shr cx,1

    {nastavi externi promenny - souradnice stisku}
     and ax,2+8+32;jz @nopress
     mov presx,cx
     mov presy,dx
     mov presz,ax
     @nopress:

     cmp mouseactive,0;jz @8

     mov now.mousex,cx
     mov now.mousey,dx

     cmp mouseflag,0;jz @8{neni videt -> nic nedelam}

     push 0;call MOUSE
     push 1;call MOUSE

     @8:
     retf

     @9:end;

PROCEDURE MoveMouse;assembler;{nastaveni polohy M-x-y}
 asm mov ax,4;mov cx,now.mousex;shl cx,1;mov dx,now.mousey;int 33h;end;
PROCEDURE RemoveMouse;assembler;{----REMOVE MOUSE HANDLER----}
 asm {hide}push 0;call mouse;{remove}mov ax,0ch;mov cx,0;int 33h;end;

PROCEDURE MouseShift(dy,dx:shortint);
var shift:byte;
begin
 asm
     mov al,mouseactive;push ax;mov mouseactive,0
     mov al,mouseflag;mov ah,0;push ax
     push 0;call mouse
     end;
 if stillNumero<30 then shift:=1 else
 if stillNumero<60 then shift:=2 else
                        shift:=3;
 case dx of -1:if now.mousex>=shift then dec(now.mousex,shift);
             1:if now.mousex<vissir-8-shift then inc(now.mousex,shift);
             end;
 case dy of -1:if now.mousey>=2*shift then dec(now.mousey,2*shift);
             1:if now.mousey<visvys-16-2*shift then inc(now.mousey,2*shift);
             end;

 asm call movemouse
     call mouse;pop ax;mov mouseactive,al;end;
end;


PROCEDURE PrepareMiniFont;assembler;
 asm
 {cls array:font}
  mov ax,ds;mov es,ax;mov di,offset minifont;mov cx,lenfont/2;mov ax,0;rep stosw;

  mov ah,1;
  lea di,minifont
  call @nextcolor
  lea di,minifont-7
  call @nextcolor
  mov ah,2;
  lea di,minifont+2
  call @nextcolor
  lea di,minifont+9
  call @nextcolor
  mov ah,3;
  lea di,minifont+1
  call @nextcolor

  jmp @99

 @nextcolor:
  lea si,tenkej
  mov cx,lastchar+1-' '
 @nextchar:
  push cx
  mov dx,16
 @nextline:
  lodsb
  mov cl,8;
  @loop:shl al,1;jnc @not;mov [di],ah;@not:inc di;loop @loop
  dec dx;jnz @nextline
  pop cx;loop @nextchar
  ret

  @99:
  end;
 (*
 asm
 {cls array:font}
  mov ax,ds;mov es,ax;mov di,offset minifont;mov cx,lenfont/2;mov ax,0;rep stosw;
  lea si,tenkej
  lea di,minifont
  mov cx,lastchar+1-' '
 @nextchar:
  push cx
  mov dx,16
 @nextline:
  lodsb {mov bl,[es:si];inc si}
  mov bl,al;mov ah,2;mov cl,8;call @loop;sub di,6
  mov al,bl;mov ah,1;mov cl,6;call @loop;sub di,7
  mov al,bl;mov ah,3;mov cl,7;call @loop
  dec dx;jnz @nextline
  pop cx;loop @nextchar

  jmp @99

  {al-bitmapa,ah-barva}
  @loop:shl al,1;jnc @not;mov [di],ah;@not:inc di;loop @loop;ret

  @99:
  end;
  *)

PROCEDURE Background;assembler;
  asm
     {fill ems with picture from fogseg 256x256}
      mov ax,now.radek;shr ax,1;inc ax;mov [cs:offset @za-2],ax
      mov bx,0
      @nextpage:push bx;
      mov ax,4400h;mov dx,now.handle;push bx;int 67h;pop bx
      mov es,frameseg
      push ds;mov ds,fogseg

      mov si,bx;shl si,13
      mov di,0
      mov dx,32;@1:
      mov cx,256;rep movsw;sub si,256
      dec dx;jnz @1

      pop ds
      pop bx;inc bx;cmp bx,260;@za:jnz @nextpage
      end;


PROCEDURE InsertPicture(x1,y16,sirka,vyska,double:word);assembler;var j,ha:word;
  asm
     {picture from workseg to ems}
      mov ax,now.handle;mov ha,ax
      mov es,frameseg
      mov di,x1
      mov bx,y16;shr bx,1;jnc @zacatekframu;add di,16*512;@zacatekframu:mov j,bx
      mov si,0
      mov dx,vyska
      push ds;mov ds,workseg

     {reframe}
      @wideloop:
      pusha
      mov ax,4400h;mov bx,j;inc j;mov dx,ha;int 67h
      popa
     {loop}
      @miniloop:
{      mov cx,sirka;shr cx,1;rep movsw;add di,wrisir;sub di,sirka
      sub si,sirka
      mov cx,sirka;shr cx,1;rep movsw;add di,wrisir;sub di,sirka}
      mov cx,sirka;dec di
      @4:inc di;@5:lodsb;or al,al;loopz @4;jcxz @6;stosb;jmp @5;dec di;@6:inc di
      add di,wrisir;sub di,sirka
      cmp double,1;jz @nodouble;
      sub si,sirka
      mov cx,sirka;dec di
      @1:inc di;@2:lodsb;or al,al;loopz @1;jcxz @3;stosb;jmp @2;dec di;@3:inc di
      add di,wrisir;sub di,sirka
      @nodouble:

      dec dx;jz @99
      test di,16384;jz @miniloop
      and di,16383;jmp @wideloop

      @99:
      pop ds

      end;

FUNCTION FreeMoreConv:Boolean;
var cet,j,j2,ha,segx:word;
    d,d2:char;
label 1;
begin
 ha:=10000;
 for j:=1 to fontu do for d:=' ' to lastchar do begin
   cet:=cetnost[j,d]-1;
   if cet<ha then begin
     ha:=cet;
     j2:=j;d2:=d;
     if ha=0 then goto 1;
     end;
   end;
 if ha=10000 then begin FreeMoreConv:=false;exit;end;
 1:
 segx:=charseg[j2,d2];charseg[j2,d2]:=0;cetnost[j2,d2]:=0;
 asm mov ah,49h;mov es,segx;int 21h;end;
 FreeMoreConv:=true;
end;

PROCEDURE InsertBigChar2Ems(font:byte;c:char;x1,y16:word);
var last,j,ha,myseg:word;
label 2;
begin
 myseg:=charseg[font,c];
 if myseg=0 then begin
         2:
         asm mov ah,48h;mov bx,65535;int 21h;mov j,bx;end;
         if j<300 then if FreeMoreConv then goto 2 else errorhalt(1);

         obrys(c,font);
         transto256bitmap;
         {fillbigchar;}
         obtah1;
         for j:=2 to 7 do obtah2(j);
         asm {zapakovani sha}
             mov ax,ds;mov es,ax {es=ds}
             mov si,offset sha;mov di,si
             mov cx,vys
          @newline:
             push cx

             mov cx,sir          {meri pocet nul=bx}
          @continueline:
             mov bx,0
             @2:
             lodsb
             inc bx
             or al,al;loopz @2
             jcxz @endofline

             mov al,bl;dec al;stosb     {tolik nul}

             mov bx,0            {meri pocet dat=bx}
             @3:
             lodsb
             inc bx
             or al,al;jnz @3
             sub cx,bx

             {*otestovat vsechny bigchary, jestli se tady nehaltnou}
             jnc @ok
             nop
             @ok:

             mov al,bl;stosb     {tolik dat}
             sub si,bx           {ulozi data}
             dec si
             push cx;mov cx,bx;rep movsb;pop cx
             inc cx
             jmp @continueline

          @endofline:
             mov al,0;stosb

             pop cx
             loop @newline

             sub di,offset sha   {alloc conv mem}
            push di{size}
             mov bx,di{size}
             shr bx,4;inc bx;call alloc;mov myseg,ax;

             mov es,ax
             mov si,offset sha;mov di,0  {copy}
            pop cx{size}
             rep movsb
             mov al,255;stosb
            end;
         charseg[font,c]:=myseg;
         end;

 inc(cetnost[font,c]);

 asm
     {picture from workseg to ems}
      mov ax,now.handle;mov ha,ax
      mov es,frameseg
      mov di,x1
      mov bx,y16;shr bx,1;jnc @zacatekframu;add di,16*512;@zacatekframu:mov j,bx
      mov si,0
      mov ah,0
      mov bx,offset bigfontxlat-1

      push ds
      mov ds,myseg


     {reframe}
    @NextLineAndReframe:
      pusha
      mov ax,4400h;mov bx,j;inc j;mov dx,ha;int 67h
      popa
    @NewLine:
      mov last,di
    @ContinueLine:
      lodsb
      or al,al;jz @endofline
      cmp al,255;jz @99
      add di,ax{mezery}   {ah must be 0}
      lodsb
      mov cx,ax           {ah must be 0}
      @dat:lodsb;segcs xlat;stosb;loop @dat
      jmp @continueline

    @EndOfLine:
      mov di,last
      add di,wrisir
      test di,16384;jz @NewLine
      and di,16383;jmp @NextLineAndReframe

      @99:
      pop ds

      end;
end;


PROCEDURE MakeFog;
const bobu=9;
      sped=0;spee=21;mvel=15;soup=11;minsed=26{*usedcols};maxsed=minsed+14;
      fogsir=256;
var   cha:char;
      lastadr:array[0..2*bobu+1] of word;
      i,j:word;

procedure Zamlzit(adr:word);assembler;
asm mov es,fogseg;mov ax,256*(maxsed)+1;mov bl,maxsed-16;mov di,adr;mov dx,mvel;@2:mov cx,mvel
    @1:cmp [es:di],ah;jnc @nomlha;add [es:di],al;@nomlha:inc di;loop @1
    add di,fogsir-soup-2;dec dx;jnz @2;
    end;

procedure Odmlzit(adr:word);assembler;
asm mov es,fogseg;mov di,adr;mov dx,mvel;@2:mov cx,mvel
    @1:mov al,[es:di];cmp al,maxsed+1;jnc @nomlha;cmp al,minsed;jc @nomlha
    dec al;mov [es:di],al;@nomlha:inc di;loop @1
    add di,fogsir-soup;dec dx;jnz @2;
    end;

Begin
 asm
  {fill fogseg}
   mov es,fogseg;mov di,0;mov ax,257*(minsed+8);mov cx,32768;rep stosw;
   end;

 for i:=1 to 800 do zamlzit(random(65535));
 for i:=1 to 60 do for j:=0 to bobu do begin
   inc(lastadr[2*j  ],fogsir*(random(spee)-sped)+(random(spee)-sped));zamlzit(lastadr[2*j]);
   inc(lastadr[2*j+1],fogsir*(random(spee)-sped)+(random(spee)-sped));odmlzit(lastadr[2*j+1]);
   end;
End;


PROCEDURE KonvertScreen;assembler;var i,j,bit,ha:word;
 asm
      push ds
      mov ax,now.radek;inc ax;shr ax,1
      mov i,ax
      mov j,0
      mov ax,frameseg;mov es,ax
      mov ax,now.handle;  mov ha,ax

     @loop:
      mov bx,j;mov ax,4400h;mov dx,ha;int 67h;inc j
      mov bx,j;mov ax,4401h;mov dx,ha;int 67h

      mov di,0

      mov ax,es
      add ah,2
      mov ds,ax
      call @in

      mov ax,es
      add ah,4
      mov ds,ax
      call @in

      dec i;jns @loop

      pop ds
      jmp @9

  @in:mov bit,3
      @nextbit:
      mov si,bit;mov dx,3;mov cx,16*512/4
      @1:movsb;add si,dx;loop @1
      dec bit;jns @nextbit
      ret

      @9:
      end;


PROCEDURE NextEdiLine;assembler;
 asm mov si,edi;@1:lodsb;cmp al,13;jnz @1;inc si;mov edi,si;end;

FUNCTION ReadLine:string;
var q:^string;
    i:word;
begin
 i:=edi;
 q:=@edtext[edi-1];
 ReadLine:=q^;{aby to neprenaselo jen prvnich #10 az #13 charu !!!}
 while edtext[i]<>#13 do inc(i);
 ReadLine[0]:=chr(i-edi);
{ asm mov si,edi;lea di,@result+1;jmp @1
     @loop:segss stosb;@1:lodsb;cmp al,13;jnz @loop
     mov ax,di;sub ax,offset @result;mov al,1;mov [ss:offset @result],al
     end;}
end;

FUNCTION ReadCharLength:word;   (*
var i,j:word;
begin
 i:=edi;
 j:=0;
 while edtext[i]<>#13 do if edtext[i]=chgcol then inc(i,2) else begin inc(i);inc(j);end;
 ReadCharLength:=j;           *)
begin
 asm mov si,edi;mov cx,256
     @1:lodsb;cmp al,chgcol;jnz @notchgcol;inc si;jmp @1
     @notchgcol:cmp al,13;loopnz @1
     neg cx;mov ch,0;mov @result,cx
     end;
end;

FUNCTION ReadPixLength(stop:char;propsir:word):word;(*
var i,j:word;
    c:char;
begin
 i:=edi;
 j:=0;
 c:=edtext[i];
 while c<>stop do begin
   if c=chgcol then inc(i,2)
               else begin inc(j,propsir[c]+minifnt);inc(i);end;
   c:=edtext[i];
   end;
 ReadPixLength:=j;*)
begin
 asm mov si,edi;mov cx,0;mov bx,propsir;mov ah,0;mov dl,stop
     @1:lodsb;cmp al,chgcol;jnz @notchgcol;inc si;jmp @1
     @notchgcol:cmp al,dl;jz @end;xlat;add ax,minifnt;add cx,ax;jmp @1
     @end:mov @result,cx
     end;
end;

PROCEDURE GetLineParams;{nastavi Wmezer, Wodsaz, Wodcentr, Wsirmez, Wtoedi, Wnewedi}
var i,lastadr,lastsir,nowsirka:word;
begin
 Wmezer:=0;
 Wodsaz:=0;
 Wodcentr:=0;
 Wsirmez:=0;
 if (edtext[edi-1]=#10) or
    (edtext[edi-1]=inspic) or
    (edtext[edi-1]=mramor) or
    (edtext[edi-1]=tabulka) or
    (edtext[edi-2]=insbigchar) or
    (edtext[edi-2]=insbutton) or
    (edi=edtextofs) then begin
        i:=ReadPixLength(#13,ofs(tenkejPropsir)-32);
        if (i>pixLen) then Wodsaz:=pixOdsaz
                      else Wodcentr:=(pixLen-i) div 2;
        end else
 if edtext[edi-1]=togl then Wodcentr:=4*anox4+30-pixStart else
 if edtext[edi-1]=asksymbol then Wodcentr:=4*askx4-20-pixStart;

 {cte radku dokud neni moc dlouha}
 lastadr:=0;
 nowsirka:=Wodsaz+Wodcentr;
 (*
 i:=edi;
 repeat
   case edtext[i] of ' ':begin inc(Wmezer);lastadr:=i;lastsir:=nowsirka;inc(nowsirka,pixMinicharSir+minifnt);end;
                     '`':inc(i);
                 #10,#13:begin Wtoedi:=i-1;Wnewedi:=i+2;exit;end;
                    else inc(nowsirka,propsir[edtext[i]]+minifnt);
                    end;
   inc(i);
 until nowsirka>pixLen;

 if lastadr=0 then lastadr:=i-1;
 dec(Wmezer);
 Wtoedi:=lastadr-1;{pred mezerou}
 Wnewedi:=lastadr+1;{za mezerou}
 Wsirmez:=pixLen-lastsir;
 *)

 {cx=nowsirka}
 asm mov si,edi;mov cx,nowsirka;mov bx,offset tenkejPropsir-' ';mov ah,0
     @loop:lodsb;
     cmp al,' ';jz @mezera;cmp al,chgcol;jz @chgcol;cmp al,13;jz @char13;xlat;add ax,minifnt;add cx,ax;
     @testloop:
     cmp cx,pixLen;jc @loop

     cmp lastadr,0;jnz @notzero;mov lastadr,si;@notzero:
     dec Wmezer
     mov ax,lastadr;mov Wnewedi,ax;sub ax,2;mov Wtoedi,ax
     mov ax,pixLen;sub ax,lastsir;mov Wsirmez,ax
     jmp @end

     @mezera:inc Wmezer;mov lastadr,si;mov lastsir,cx;add cx,pixMinicharsir;add cx,minifnt;jmp @testloop
     @chgcol:inc si;jmp @loop
     @char13:sub si,2;mov Wtoedi,si;add si,3;mov Wnewedi,si

     @end:
     end;
end;

PROCEDURE OneMiniWord;assembler;{pise slovo z edtext[edi] do wordX:framewriseg}
 asm
      mov es,framewriseg
      mov si,edi
      mov di,wordX
      mov bx,mixword

 @nextchar:
      lodsb
      cmp al,' ';jz @endword
      cmp al,13;jz @endword
      cmp al,chgcol;jnz @nochcol
      {zmena barvy}
      lodsb;sub al,'a'
      mov bl,al;mov bh,0;shl bx,1;mov bx,[offset mixcols+bx];mov mixword,bx
      jmp @nextchar
      @nochcol:

      mov ah,0
      push si
      push ax
      cmp minifnt,0;jnz @minifnt1

@minifnt0:
      shl ax,4
      add ax,offset tenkej-16*' '
      mov si,ax
      mov dx,16
      mov ah,2
     @nextline0:
      lodsb
      mov cx,8
      @2:shl al,1;jnc @noput;
      test [es:di],ah;jz @8;mov [es:di],bl;jmp @7;@8:mov [es:di],bh;@7:
      @noput:inc di;loop @2
      add di,wrisir-8
      dec dx;jnz @nextline0
      jmp @same

@minifnt1:
      shl ax,7
      add ax,offset minifont-' '*16*8
      mov si,ax
      mov dx,16
     @nextline1:
      mov cx,8
      @1:lodsb;or al,al;jz @notal;add al,bl;stosb;dec di;@notal:inc di;loop @1
      add di,wrisir-8
      dec dx;jnz @nextline1

@same:
      pop ax
      pop si
      sub di,16*wrisir
      push bx;mov bx,offset tenkejPropsir-' ';xlat;add di,ax;add di,minifnt;pop bx
      jmp @nextchar

 @endword:
      dec si
      mov edi,si
      mov wordX,di
      end;

PROCEDURE OneAskString(n:byte);assembler;{reframuje;pise askstring[n].str do EMS ; ROM font}
 asm
      mov al,2+askmaxlen;mul n;add ax,offset askstring-askmaxlen-2;mov si,ax
      lodsw;push ax;call reframe;mov es,framewriseg
      mov di,askx4
      mov cx,askmaxlen
      mov ah,0

 @nextchar:
      lodsb{precte jedno pismeno}
      pusha
      push ds

@minifnt0:
      shl ax,4
      add ax,fntofs16
      mov si,ax
      mov ds,fntseg16
      mov dx,16
     @nextline0:
      lodsb
      mov cx,4
     @nextquarter:
      mov bx,1*257
      shr al,1;jnc @black1;mov bh,4;@black1:
      test al,8;jz @black2;mov bl,4;@black2:
      mov [es:di],bx
      add di,wrisir*4;loop @nextquarter

      sub di,wrisir*16-wrisir/4
      dec dx;jnz @nextline0

      pop ds
      popa
      add di,2
      loop @nextchar

 @endword:
      end;

PROCEDURE SetDefaultTextAttribs;
begin
 {tohle delat pri otevreni textfajlu}
 pixMinicharSir:=5;
 pixOdsaz:=24;
{ pixStart:=0;}
 with hlavapata[0] do begin x1:=0;y16:=1;oedi:=edtextofs;firstline:=65535;end;
 hlavapat:=-1;
 sloupcu:=0;
 mixword:=mixcols[0];
 wlcol:=mixcolstxt[0];
 minifnt:=0;{mix font, ne shadow font}
end;

FUNCTION ReadInteger(odkud:word):integer;
begin
 ReadInteger:=(100*ord(edtext[odkud])+10*ord(edtext[odkud+1])+ord(edtext[odkud+2])-4800-480-48+500) mod 1000-500;
end;

PROCEDURE DrawLine;
var j:word;
begin
 GetLineParams;
 wordX:=pixStart+Wodsaz+Wodcentr;
 if edtext[edi]=rovnejLeft then begin inc(edi);wordX:=pixStart;end;
 while edi<=Wtoedi do case edtext[edi] of
                              ' ':begin
                                  j:=Wsirmez div Wmezer;
                                  inc(wordX,pixMinicharSir+j+minifnt);
                                  dec(Wsirmez,j);
                                  dec(Wmezer);
                                  inc(edi);
                                  end;
                             else OneMiniWord;
                             end;
 edi:=Wnewedi;
end;

FUNCTION FreeMoreEMS:Boolean;
var j,k:word;
begin
 for k:=1 to intree-1 do if tree[k].handle>0 then begin
      j:=tree[k].handle;tree[k].handle:=0;
      asm {dealloc ems}mov ah,45h;mov dx,j;int 67h;end;
      freeMoreEMS:=true;
      exit;
      end;
 freeMoreEMS:=false;
end;



PROCEDURE SaveAnketa;
var i:byte;
    f:text;
begin
{$ifdef pareniste}
 if togglu>10 then begin
   {zapise vysledek ankety}
   assign(f,'anketa.'+chr(48+random(10))+chr(48+random(10))+chr(48+random(10)));rewrite(f);
   for i:=1 to togglu do write(f,chr(48+toggle[i].on));
   writeln(f);
   for i:=1 to askstringu do writeln(f,askstring[i].str);
   close(f);
   askstringu:=0;
   end;
 togglu:=0;
{$endif}
end;

PROCEDURE xorcursor(ems:Boolean);{reframe ; xor cursor in ems; ems2screen}
var x4,y16:word;
begin
 if nowask>0 then begin
   x4:=askx4+2*nowaskx-2;
   y16:=askstring[nowask].y16;
   asm
     PUSHF;CLI
     mov ah,0;mov al,mouseflag;push ax;push 0;call mouse;
     push y16;call reframe;mov es,framewriseg
     mov di,14*wrisir/4;add di,x4;mov ax,257*4;mov cx,4;@1:xor word ptr [es:di],257*xorcolor;add di,wrisir*4;loop @1
     end;
   if ems and (y16>=wriy) and (y16<=wriy+31){neni mimo obraz} then asm
     {nakrasli ten samej kurzor i do videopameti}{ems2screenMouseoff(y16);}
     {prepare es,di}
      mov es,sega000
      mov di,14*wrisir/4;add di,x4
      mov ax,4*wrisir;mul y16;add di,ax
     {set all 4 bits}
      mov ax,0f02h;mov dx,3c4h;out dx,ax
     {xor}
      xor word ptr [es:di],257*xorcolor;
     end;
   asm
     call mouse;
     POPF
     end;
   end;
end;

PROCEDURE PrepareScreen;
var   ii,j,k,k0,l,m,titlesir:integer;
      datafajl:word;
      pall,font,size:byte;
      ch:char;
      maxradek,zbyvaradek,leftStart:word;

const  chybi:string[60]=#13#10'`bTady chyb¡ obr zek.'#13#10'Se‘e¤ si datafajl s grafikou.'#13#10;


label 1,2,7,8,9;
Begin
  SetDefaultTextAttribs;

  togglu:=0;
  askstringu:=0;
  nowask:=0;
  edi:=edtextofs;

  MoveTextFile2EdText(tree[intree].fl);
  now.radek:=readinteger(ofs(header));
  if now.radek<31 then now.radek:=31;
  now.backgroundcolor:=ord(edtext[ofs(header)+3])-48;

  1:
  asm {alloc ems}mov ax,4300h;mov bx,now.radek;shr bx,1;add bx,2;int 67h;or ah,ah;jnz @noems;mov now.handle,dx;@noems:end;
  if now.handle=0 then if FreeMoreEMS then goto 1 else ErrorHalt(3);
  tree[intree].handle:=now.handle;

 {kresli stranku do ems}
  now.buttonu:=0;
  Background;
  ii:=1;
  while edi<edtextlast do case edtext[edi] of

        TOGL:begin
             inc(togglu);
             with toggle[togglu] do begin y16:=ii-1;on:=0;end;
             reframe(ii);
             inc(edi);
             DrawLine;
             inc(ii);
             end;
   ASKSYMBOL:begin
             inc(askstringu);
             with askstring[askstringu] do begin y16:=ii-1;for j:=1 to askmaxlen do str[j]:=#0;end;
             inc(edi);
             reframe(ii);
             DrawLine;
             nowask:=1;
             inc(ii);
             end;
{  ROVNEJLEFT:begin
             inc(edi);
             reframe(ii);
             DrawLine;
             inc(ii);
             end;}
      MRAMOR:begin
             reframe(ii);
             asm
               {kresli mramor}
                mov es,framewriseg
                mov si,pixStart
                mov di,si
                mov dx,16
                mov ah,2
                mov bx,256*23+24
                @1:
                mov cx,pixLen
                push di;
                @2:
                test [es:di],ah;jz @8;mov [es:di],bl;jmp @7;@8:mov [es:di],bh;@7:
                inc di
                loop @2
                pop di;add di,wrisir
                dec dx;jnz @1
                end;
             inc(edi);
             asm push minifnt;push mixword;end;
             minifnt:=2;
             mixword:=9;
             DrawLine;
             asm pop mixword;pop minifnt;end;
             inc(ii);
             end;

      TABULKA:begin
             inc(edi);
             2:
             inc(ii);
             reframe(ii);
             j:=readpixlength(':',ofs(TenkejPropsir)-32);
             wordX:=pixMid-j;
             mixword:=256*23+24;
             while edi<edtextlast do case edtext[edi] of
                              #13:begin
                                  inc(edi,2);
                                  if edtext[edi]=INSBIGCHAR then goto 7;
                                  goto 2;
                                  end;
                              ' ':begin
                                  inc(wordX,pixMinicharSir);
                                  if wordX>pixMid then mixword:=256*15+16;
                                  inc(edi);
                                  end;
                             else OneMiniWord;
                             end;
             7:
             end;

      INSPIC:begin
        inc(edi);
        st:=ReadLine;
        if OpenDataFile(st)=0 then begin
          8:
          xsir:=320;xvys:=200;barevw:=1;
          asm push edi;push mixword;end;
          edi:=ofs(chybi)+3;
          reframe(ii+xvys div 16-2);
          drawline;
          reframe(ii+xvys div 16);
          drawline;
          asm pop mixword;pop edi;end;
          inc(ii,(xvys-1) div 8);
          end
         else begin
          {$ifdef datainside}
          j:=1;
          while st<>data[j].name do begin inc(j);if j>datafajlu then goto 8;end;
          with data[j] do begin
            xsir:=picx;
            xvys:=picy;
            inc(now.palet);
            now.jakapaleta[now.palet]:=j;
            now.kdepaletaTop[now.palet]:=16*(ii-1)-visvys;
            now.kdepaletaBot[now.palet]:=16*(ii-1)+2*xvys;
            end;
          {$else}
          ReadDataFile(5,ofs(xsir),dseg);
          ReadDataFile(3*barevw,ofs(pal)+768-3*barevw,dseg);
          {$endif}
          maxradek:=(65535 div xsir) and $fff8;
          zbyvaradek:=xvys;
          if pixMid<xsir div 2 then leftStart:=0 else leftstart:=pixMid-xsir div 2;
          repeat
            if maxradek>zbyvaradek then maxradek:=zbyvaradek;
            ReadDataFile(xsir*maxradek,0,workseg);
            insertpicture(leftStart,ii,xsir,maxradek,2);
            inc(ii,maxradek div 8);
            dec(zbyvaradek,maxradek);
          until zbyvaradek=0;
          CloseDataFile;
          end;
        NextEdiLine;
        end;

      INSBIGCHAR,INSBUTTON:begin
        m:=edi;
        inc(edi);
        case edtext[edi] of 'a'..'z':begin font:=1;pall:=ord(edtext[edi])-ord('a');size:=4;end;
                            'A'..'Z':begin font:=2;pall:=ord(edtext[edi])-ord('A');size:=8;end;
                            end;
        {set bigfontxlat array}
         asm mov al,pall;mov ah,0;mov si,ax;shl si,3;add si,offset bigcols
             mov di,offset bigfontxlat;mov cx,4;mov ax,cs;mov es,ax;rep movsw;end;
        inc(edi);
        l:=ReadCharLength-1;
        titlesir:=(ReadPixLength(#13,ofs(tlustejPropsir)-32)-l)*size+l;
        k:=pixMid-titlesir div 2-size;
        k0:=k;
        for j:=0 to l-1 do begin
          ch:=edtext[edi+j];
          InsertBigChar2Ems(font,ch,k,ii);
          inc(k,size*tlustejPropsir[ch]-size+1);
          end;

        if edtext[m]=INSBUTTON then begin
          if now.buttonu<maxbuttonu then inc(now.buttonu);
          with now.bu[now.buttonu] do begin
            NextEdiLine;
            fi:=ReadLine;
            x1:=k0;
            y1:=16*ii-16;
            x2:=x1+titlesir;
            y2:=y1+16*size;
            end;
          end;

        inc(ii,size);
        NextEdiLine;
        end;

      NEWSLOUPEC:begin
        inc(hlavapat);{zapise konec minulyho odstavce}
        if hlavapat>0 then begin
          with hlavapata[hlavapat] do begin
            x1       :=pixStart;
            y16      :=ii;
            end;
          end;
        with hlavapata[ord(edtext[edi+1])-48] do begin{zjisti zacatek tohodle podle otcovskeho odstavce}
          pixStart :=x1+ReadInteger(edi+2);
          ii       :=y16+ReadInteger(edi+5);
          pixLen   :=ReadInteger(edi+8);
          pixMid   :=pixStart+pixLen div 2;
          end;
        inc(hlavapat);{zapise zacatek tohodle odstavce}
        with hlavapata[hlavapat] do begin
          x1       :=pixStart;
          y16      :=ii;
          end;
        NextEdiLine;
        end;

      ELSE begin
        Reframe(ii);
        DrawLine;
        inc(ii);
        end;
      END;

  KonvertScreen;
  for j:=1 to togglu do ano(toggle[j].y16,0);
  for j:=1 to askstringu do oneaskstring(j);
  xorcursor(false);
End;




FUNCTION F1:Boolean;begin f1:=(now.visy>=16*wriy+24) and (wriy<now.radek);end;
FUNCTION F2:Boolean;begin f2:=(now.visy< 16*wriy+ 8) and (wriy>0        );end;

PROCEDURE TimerScrolling;far;
var   i,j,k,l:integer;
const inside:boolean=false;
begin
 if inside then exit;

 ref:=true;

 for i:=1 to 3 do case poradi[i] of

  'o':begin
  {---upravi sunx,y}
  if now.mousey<       2*mysiokraj then nahoru (osekej(         2*mysiokraj-now.mousey)) else
  if now.mousey>visvys-2*mysiokraj then dolu   (osekej(-(visvys-2*mysiokraj-now.mousey)));
  if now.mousex<         mysiokraj then doleva (osekej(      -10+ mysiokraj-now.mousex)) else
  if now.mousex>vissir-  mysiokraj then doprava(osekej(-(vissir-  mysiokraj-now.mousex)));

  {---vypocitava novy vis podle sunx,y}
  if (sunx[sunindex]<>0) or (suny[sunindex]<>0) then begin
     j:=now.visy;
     mouseactive:=0;mouse(0);
     inc(now.visx,sunx[sunindex]);
     inc(now.visy,suny[sunindex]);
     if now.visx<0 then now.visx:=0 else if now.visx>=wrisir-vissir then now.visx:=wrisir-vissir-1;
     if now.visy<0 then now.visy:=0 else if now.visy>=16*now.radek-visvys then now.visy:=16*now.radek-visvys-1;
     movemouse;
     mouse(1);mouseactive:=1;

    {$ifdef datainside}
     {palety}
     if suny[sunindex]>0 then begin
      for i:=1 to now.palet do if (now.kdepaletaTop[i]<now.visy)<>(now.kdepaletaTop[i]<j) then SetAndVisUpperPal(i);end else
     if suny[sunindex]<0 then
      for i:=1 to now.palet do if (now.kdepaletaBot[i]<now.visy)<>(now.kdepaletaBot[i]<j) then SetAndVisUpperPal(i);
    {$endif}
     sunx[sunindex]:=0;
     suny[sunindex]:=0;
     end;

  if sunindex<setrvacnost-1 then inc(sunindex) else sunindex:=0;
  end;

  'v':
  {---ve spravny okamzik nastavi vis}
  if (now.visx<>lastvisx) or (now.visy<>lastvisy) then begin
     SmoothSetvis;
     lastvisx:=now.visx;
     lastvisy:=now.visy;
     end;

  'k':
  {---ve spravny okamzik kresli pozadi na obrazovku}
  if f1 or f2 then begin
   asm {save emm status}mov ax,4700h;mov dx,now.handle;int 67h;end;
   l:=mouseactive;mouseactive:=0;k:=mouseflag;mouse(0);
   while f1 or f2 do begin
     if f1 then begin inc(wriy);Ems2Screen(wriy+31);end;
     if f2 then begin dec(wriy);Ems2Screen(wriy   );end;
     end;
   mouse(k);mouseactive:=l;
   asm {restore emm status}mov ax,4800h;mov dx,now.handle;int 67h;end;
   end;

  end;

 inside:=false;
end;

PROCEDURE Show(name:string);
const decode:array[2..57] of char=(
        '1','2','3','4','5','6','7','8','9','0','-','=',#0,
        #0,'Q','W','E','R','T','Y','U','I','O','P','[',']',#0,
        #0,'A','S','D','F','G','H','J','K','L',';','''',
        #0,#0,'\','Z','X','C','V','B','N','M',',','.','/',
        #0,#0,#0,' ');
var   i,j:integer;
      psp:word;
      OutOf:byte;
      lastkey:byte;
label 1,2,3,8,choosePageOrMenu,rightbutton,leftbutton;
begin

{$ifdef midas}
  midasSetDefaults;                   { set MIDAS defaults }
  midasParseEnvironment;              { parse MIDAS environment string }
  midasParseOptions(1, ParamCount);   { let MIDAS parse all options }
 {hleda vsechny S3Mka}
  asm {get psp-dta}
        mov ah,62h;int 21h;mov psp,bx
        mov di,offset ModuleNames
        {findfirst}
        mov ah,4eh;mov cx,0;mov dx,offset mSt+1;int 21h;
        {store}
        @store:jc @end
        mov es,psp;mov si,$9e;mov ah,0;push di;inc di
        @1:seges lodsb;mov [di],al;inc di;inc ah;cmp al,0;jnz @1
        pop di;mov [di],ah;add di,dylkamodname+1
        inc modulu
        cmp modulu,10;jz @end
        {findnext}
        mov ah,4fh;mov dx,$80;push ds;mov ds,psp;int 21h;pop ds;jmp @store
        {end}
        @end:
        end;
{$endif}

  mode13x;
  setbright(0);
  InstallMouse;

{$ifdef midas}
  midasInit;                          { initialize MIDAS Sound System }
  tmrGetScrSync(PtmrScrSync);
  OutOf:=1;
  if modulu>0 then module:=midasPlayModule(ModuleNames[1],OutOf); { load module and start playing }
  midasInitEffectChan;
  for i:=1 to samplu do with data[1+i] do begin
    if opendatafile(name)>0 then readdatafile(len,0,workseg);
    samplehandle[i]:=midasLoadsample(@mem[workseg:0],len);
    end;
{$endif}

  port[$21]:=irq;
  tree[1]:=firstscreen;
  tree[1].fl:=name;
  if name<>'' then goto 2;

  choosePageOrMenu:
{$ifdef midas}
  if odd(setup) then name:=menuStartup else name:=pageStartup;
  tree[1]:=firstscreen;
  tree[1].fl:='presents';
  now:=tree[1];
  smoothSetvis;
  PREPARESCREEN;
  SetBackPal(now.backgroundcolor);
  for i:=0 to 31 do Ems2Screen(i);
  deallocNowhandle;
  nowbright:=9;
  tmrSyncScr(tmrScrSync,@nop,@nop,@timerBrightUpDown);
  tree[1]:=firstscreen;
  tree[1].fl:=name;
  goto 2;
{$endif}


  1:
{$ifdef midas}
  tmrSyncScr(tmrScrSync,@nop,@nop,@timerBrightDown);
{$else}
  BrightDown;
{$endif}

  2:
  nowask:=0;
  nowaskx:=1;
  presz:=0;
  mouseactive:=0;mouse(0);
  now:=tree[intree];
  for i:=0 to setrvacnost-1 do sunx[i]:=0;suny:=sunx;
  if now.handle=0 then PREPARESCREEN;
{$ifdef midas}
  repeat until nowbright<8;
  tmrStopScrSync;
{$endif}
  {nastaveni background palety}
  SetBackPal(now.backgroundcolor);
{$ifdef datainside}
  {nastaveni picture palety}
  if now.palet>0 then SetUpperPal(now.nowpal);
{$endif}
  SmoothSetvis;
  wriy:=now.visy shr 4;for i:=0 to 31 do Ems2Screen(wriy+i);
  MoveMouse;
  mouse(1);mouseactive:=1;
  BrightUp;

{$ifdef midas}
  tmrSyncScr(tmrScrSync,@nop,@nop,@timerScrolling);
{$endif}

  repeat

                   {............KEY PRESS............}
   i:=port[$60];
   case i{ and 127} of 71..73,75,77,79..81:else stillNumero:=0;end;
   if i=224 then begin
     repeat i:=port[$60] until i<>224;
     case i of 72,75,77,80:begin
                           inc(i,100);
                           sipky:=10;
                           end
                      else i:=0;
                      end;
     end
    else
     if sipky>0 then case i of 72,75,77,80:inc(i,100);end
                else case i of 71..73,75,77,79..81:inc(stillNumero);end;

   if sipky>0 then dec(sipky);

   case lastkey of 172,175,177,180,71..73,75,77,79..81,14,83:lastkey:=0;end;
   if i<>lastkey then begin lastkey:=i;key:=i;end else key:=0;


   {GLOBAL KEYS}
   CASE KEY OF
               71:MouseShift(-1,-1);
               72:MouseShift(-1, 0);
               73:MouseShift(-1, 1);
               75:MouseShift( 0,-1);
               77:MouseShift( 0, 1);
               79:MouseShift( 1,-1);
               80:MouseShift( 1, 0);
               81:MouseShift( 1, 1);
         82,69,76:begin presx:=now.mousex;presy:=now.mousey;goto leftbutton;end;
            83,55:begin presx:=now.mousex;presy:=now.mousey;goto rightbutton;end;

{$ifdef midas}
              2..11:begin
                    volume:=63*(key-2) div 9;
                    midasMastervolume(volume);
                    end;
             59..68:if key-58<=modulu then begin
                    if module<>nil then midasStopModule(module);{ stop playing }
                    3:
                    outof:=0;
                    module:=midasPlayModule(ModuleNames[key-58],outof); { load module and start playing }
                    if (outof=2) and FreeMoreConv then goto 3;
                    midasMastervolume(volume);
                    end;
{$endif}
               ELSE BEGIN


   {DOTAZNIK KEYS}
   if (nowask>0) and (key>0) then begin
     mouseactive:=0;mouse(0);
     xorcursor(true);
     case key of
               72:if nowask>1 then begin dec(nowask);nowaskx:=1;end;
            28,80:if nowask<askstringu then begin inc(nowask);nowaskx:=1;end;
               77:if nowaskx<askmaxlen then inc(nowaskx);
               75:if nowaskx>1 then dec(nowaskx);
               14:if nowaskx>1 then with askstring[nowask] do begin {backspace}
                    dec(nowaskx);
                    for j:=nowaskx to askmaxlen-1 do str[j]:=str[j+1];
                    str[askmaxlen]:=' ';
                    end;
               83:with askstring[nowask] do begin {delete}
                    for j:=nowaskx to askmaxlen-1 do str[j]:=str[j+1];
                    str[askmaxlen]:=' ';
                    end;
            2..57:if (nowask>0) and (decode[key]>#0) then with askstring[nowask] do begin
                    for j:=askmaxlen downto nowaskx+1 do str[j]:=str[j-1];
                    str[nowaskx]:=decode[key];
                    if nowaskx<askmaxlen then inc(nowaskx);
                    end;
              else goto 8;
            end;
     i:=askstring[nowask].y16;
     OneAskString(nowask);
     if (i>=wriy) and (i<=wriy+31){neni mimo obraz} then ems2screen(i);
     8:
     xorcursor(true);
     mouse(1);mouseactive:=1;
     case key of 72,75,77,80:refresh2(3);
                       14,83:refresh2(6);
                       end;
     end

   else

   {NO_DOTAZNIK KEYS}
   case key of
               180:dolu   (setrvacnost-1);
               172:nahoru (setrvacnost-1);
               177:doprava(setrvacnost-1);
               175:doleva (setrvacnost-1);
               {15:inc(inlist,25);}
               end;

               END;
               END;




{$ifdef midas}           {.......SCROLLING.......}
{$else}
  timerScrolling;
{$endif}




                   {............MOUSE PRESS............}
   case presz of 0:;
                 8:begin
                   rightbutton:
{$ifdef midas}
                   midasPlaysample(samplehandle[2],8000);
{$endif}
                   if odd(setup) then begin{--MENU BACK--}
                     if intree=1 then key:=1 else begin
{$ifdef midas}
                       tmrStopScrSync;
{$endif}
                       SaveAnketa;
                       DeallocNowhandle;
                       dec(intree);
                       goto 1;
                       end;
                     end
                   else begin{--LIST BACK--}
{$ifdef pareniste}
                     if inlist=1 then key:=1 else begin
{$ifdef midas}
                       tmrStopScrSync;
{$endif}
                       DeallocNowhandle;
                       dec(inlist);
                       tree[intree]:=firstscreen;
                       tree[intree].fl:=list[inlist];
                       goto 1;
                       end;
{$endif}
                     end;
                   end;
                 2:leftbutton:
                   begin
                   presz:=0;
                   {klik do togglu}
                   j:=(now.visy+presy) shr 4;
                   for i:=1 to togglu do with toggle[i] do if y16=j then
                     {netoglne kdyz neni setup correct}
                     if (name<>setupStartup) or (i<>5) or
                        ((toggle[1].on+toggle[2].on=1) and (toggle[3].on+toggle[4].on=1)) then begin
{$ifdef midas}
                            midasPlaysample(samplehandle[3],8000);
{$endif}
                            on:=1-on;
                            mouseactive:=0;mouse(0);
                            ano(j,on);
                            ems2screen(j);
                            {kdyz je setup hotov, skoci na next page}
                            if (name=setupStartup) and (i=5) then begin
                              setup:=toggle[2].on+2*toggle[4].on;
                              saveSetup;
{$ifdef midas}
                              tmrStopScrSync;
{$endif}
                              DeallocNowhandle;
                              brightdown;
                              goto choosePageOrMenu;
                              end;
                            mouse(1);mouseactive:=1;
                            end;
                   {klik do askstringu}
                   if (presx+now.visx>askx4*4) and (presx+now.visx<askx4*4+askmaxlen*8) then
                     for i:=1 to askstringu do with askstring[i] do if y16=j then begin
                      mouseactive:=0;mouse(0);
                      xorcursor(true);
                      nowask:=i;
                      nowaskx:=1+(presx+now.visx-askx4*4) div 8;
                      xorcursor(true);
                      mouse(1);mouseactive:=1;
                      end;
                   if odd(setup) then begin{--MENU FORWARD--}
                    for i:=1 to now.buttonu do with now.bu[i] do
                     if (now.visx+presx>x1) and (now.visx+presx<x2) and (now.visy+presy>y1) and (now.visy+presy<y2) then begin
{$ifdef midas}
                      midasPlaysample(samplehandle[1],8000);
{$endif}
                      tree[intree]:=now;
                      inc(intree);
                      tree[intree]:=firstscreen;
                      tree[intree].fl:=now.bu[i].fi;
{$ifdef pareniste}
                      if tree[intree].fl='editor' then begin
                        opendatafile(editorName);
                        readdatafile(editorLength,0,workseg);
                        asm
                        {open dest}
                         mov ax,3c00h;mov cx,0;mov dx,offset editorname+1;int 21h;mov i,ax;
                        {write data}
                         mov bx,i;mov dx,0;mov cx,editorLength
                         push ds;mov ds,workseg;mov ah,40h;int 21h;pop ds;
                        {close dest}
                         mov bx,i;mov ah,3eh;int 21h;
                         end;
                        end;
{$endif}
{$ifdef midas}
                      tmrStopScrSync;
{$endif}
                      goto 1;
                      end;
                   end
                 else if (name<>setupStartup) and (now.fl<>'anketa') then begin{--LIST FORWARD--}
{$ifdef midas}
                      midasPlaysample(samplehandle[1],8000);
{$endif}
{$ifdef midas}
                      tmrStopScrSync;
{$endif}
{$ifdef pareniste}
                      DeallocNowhandle;
                      inc(inlist);
                      tree[intree]:=firstscreen;
                      if inlist<=listu then tree[1].fl:=list[inlist]
                                       else key:=1;
                      goto 1;
{$endif}
                      end;
                 end;
           end;

{$ifdef midas}
   repeat until ref;
   ref:=false;
{$else}
   refresh(1);
{$endif}

  until key=1;
  SaveAnketa;
{$ifdef midas}
  tmrStopScrSync;
  for i:=63 downto 0 do begin
    setbright(4*i);
    midasMastervolume(volume*i div 64);
    refresh(1);
    end;
{$else}
  brightdown;
{$endif}
  RemoveMouse;
  EMSDone;
  port[$21]:=0;
end;


{ÛÛÛÞÞÞÝÞÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ E D I T O R ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ}
{$ifdef editor}

PROCEDURE SaveEditorFile;assembler;
var edhandle:word;
 asm
   cmp edzmena,0;jz @9
  {open}
   mov ah,3ch;mov dx,offset edfajl+1;mov cx,0;int 21h
   mov edhandle,ax
  {write data}
   mov bx,edhandle;mov cx,edtextlast;sub cx,offset header;lea dx,header;mov ah,40h;
   int 21h
  {close}
   mov bx,edhandle;mov ah,3eh;int 21h;
  {}
   mov edzmena,0
   @9:
   end;

PROCEDURE Store(x,y,sir,vys:word);assembler;
 asm dec x;dec y
     push ds
     mov ax,ds;mov es,ax;mov di,offset sha
     mov ax,txsir;mul y;add ax,x;shl ax,1;mov si,ax;mov ds,segb800
     mov dx,vys
     @1:
     mov cx,sir;rep movsw;add si,2*txsir;sub si,sir;sub si,sir
     dec dx;jnz @1
     pop ds
     end;

PROCEDURE Restore(x,y,sir,vys:word);assembler;
 asm dec x;dec y
     mov si,offset sha
     mov ax,txsir;mul y;add ax,x;shl ax,1;mov di,ax;mov es,segb800
     mov dx,vys
     @1:
     mov cx,sir;rep movsw;add di,2*txsir;sub di,sir;sub di,sir
     dec dx;jnz @1
     end;

PROCEDURE SetVis(vis:word);assembler;
 asm mov bx,vis;mov dx,3d4h;mov al,0ch;out dx,al;inc dx;mov al,bh;out dx,al;
     dec dx;mov al,0dh;out dx,al;inc dx;mov al,bl;out dx,al;end;

PROCEDURE GotoXY(x,y:byte);assembler;
 asm mov ah,2;mov bh,0;mov dl,x;mov dh,y;dec dl;dec dh;int 10h;end;

PROCEDURE GotoXYaVis(x,y:byte);assembler;
 asm mov ah,2;mov bh,0;mov dl,x;mov dh,y;dec dl;dec dh;int 10h;
     mov al,txsir;mul y;     mov bx,lasttextvis;sub bx,shiftSetvis;add bx,2*txsir;cmp ax,bx;jc @set;
     sub ax,txsirtxvys;jc @9;mov bx,lasttextvis;sub bx,shiftSetvis;cmp ax,bx;jc @9
     add ax,txsir*3
     @set:
     sub ax,txsir*2;jns @ok;mov ax,0;@ok:
     add ax,shiftSetvis;mov lasttextvis,ax;push ax;call setvis
     @9:
     end;
(*
PROCEDURE Msg(veta:string);
var i:word;
    shdown,le,x1:byte;
    veta2:string;
begin
 shdown:=lasttextvis div txsir;
 i:=pos(#13,veta);
 if i>0 then begin veta2:=copy(veta,i+1,255);veta[0]:=chr(i-1);end else veta2[0]:=#0;
 le:=length(veta);
 x1:=shiftSetvis+(80-le) div 2;
 store(x1,13+shdown,le,2);
 textattr:=16+11;
 gotoxy(x1,13+shdown);write(veta);
 gotoxy(x1,14+shdown);for i:=1 to le do write(' ');
 gotoxy(x1+(length(veta)-length(veta2)) div 2,14+shdown);write(veta2);
 repeat until keypressed;
 restore(x1,13+shdown,le,2);
end;
*)
FUNCTION AskExit:char;
const le=51;
      line1:string[le]='   ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ Edit ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»   ';
      line2:string[le]='   º  You''ve made changes since the last save. º   ';
      line3:string[le]='   º    Save   Don''t save   Continue editing   º   ';
      line4:string[le]='   ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼   ';
      x:array[0..2] of byte=(8,15,28);
      l:array[0..2] of byte=(13,26,45);
var   ch:char;
      x1,y1,a,i:byte;
begin
 a:=0;
 x1:=shiftSetvis+(80-le) div 2+2;
 y1:=lasttextvis div txsir+11;
 store(x1,y1,le,6);
 textattr:=16*4+15;
 gotoxy(x1,  y1);for i:=1 to le do write(' ');
 gotoxy(x1,1+y1);write(line1);
 gotoxy(x1,2+y1);write(line2);
 gotoxy(x1,3+y1);write(line3);
 gotoxy(x1,4+y1);write(line4);
 gotoxy(x1,5+y1);for i:=1 to le do write(' ');
 repeat
   textattr:=16*7;
   gotoxy(x1+x[a]-1,y1+3);for i:=x[a] to l[a] do write(line3[i]);
   gotoxy(0,y1+30);
   ch:=readkey;
   textattr:=16*4+15;
   gotoxy(x1+x[a]-1,y1+3);for i:=x[a] to l[a] do write(line3[i]);
   case ch of 'S':ch:='s';
              'D':ch:='d';
              'C':ch:='c';
              #27:ch:='c';
              #75:a:=(a+2) mod 3;
              #77:a:=(a+1) mod 3;
              #13:case a of 0:ch:='s';1:ch:='d';2:ch:='c';end;
              end;
 until (ch='s') or (ch='d') or (ch='c');
 restore(x1,y1,le,6);
 AskExit:=ch;
end;

FUNCTION Ask(veta:string;maxlen:byte;def:string;first:char):string;
var i,x1,x2,le:word;
    path,veta2:string;
    ch:char;
    shdown,y13,y14,y15:byte;
begin
 shdown:=lasttextvis div txsir;
 y13:=13+shdown;
 y14:=14+shdown;
 y15:=15+shdown;
 path:=def;
 i:=pos(#13,veta);
 if i>0 then begin veta2:=copy(veta,i+1,255);veta[0]:=chr(i-1);end else veta2[0]:=#0;
 le:=length(veta);
 x1:=shiftSetvis+(80-le) div 2;
 x2:=shiftSetvis+(80-maxlen) div 2;
 store(x1,y13,le,3);
 textattr:=16+11;
 gotoxy(x1,y13);write(veta);
 gotoxy(x1,y14);for i:=1 to le do write(' ');gotoxy(x1+(length(veta)-length(veta2)) div 2,y14);write(veta2);
 gotoxy(x1,y15);for i:=1 to le do write(' ');
 i:=length(path)+1;
 while keypressed do readkey;

repeat
 gotoxy(x2,y15);write(path+' ');gotoxy(x2-1+i,y15);
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
 restore(x1,y13,le,3);
 ask:=path;
end;

PROCEDURE InsertSpaces(adr,kolik:word);assembler;
 asm {uprava EdText}
     mov ax,ds;mov es,ax
     mov si,edtextlast
     mov di,edtextlast;add di,kolik
     mov cx,edtextlast;sub cx,adr;inc cx
     std
     rep movsb
     cld
     {uprava edtextlast,blok}
     mov ax,adr
     mov bx,kolik
     add edtextlast,bx
     cmp blokstart,ax;jc @no1;add blokstart,bx;@no1:
     cmp blokend  ,ax;jc @no2;add blokend  ,bx;@no2:
     end;

PROCEDURE DelSpaces(adr,kolik:word);assembler;
 asm {uprava EdText}
     mov ax,ds;mov es,ax
     mov si,adr;add si,kolik
     mov di,adr
     mov cx,edtextlast;sub cx,adr;inc cx
     rep movsb
     {uprava edtextlast}
     mov ax,adr
     mov bx,kolik
     sub edtextlast,bx
     cmp blokstart,ax;jc @no1;sub blokstart,bx;@no1:
     cmp blokend  ,ax;jc @no2;sub blokend  ,bx;@no2:
     end;


const picu=20;
var picsizes:array[1..picu] of record name:string[13];x,y:word;end;
PROCEDURE GetPicSize(nejm:string;var xx,yy:word);
var i:byte;
    code1,code2:word;
    st:string;
    anylong:longint;
begin
 for i:=1 to picu do with picsizes[i] do if nejm=name then begin xx:=x;yy:=y;exit;end;
 for i:=1 to picu do with picsizes[i] do if x=0 then begin
  name:=nejm;
  if opendatafile(nejm)=0 then
    repeat
     st:=ask('Obr zek '+nejm+' nenalezen. žekni mi aspo¤ p©ibli‘nˆ jak je velk˜.',8,'320x200','0');
     i:=pos('x',st);
     val(copy(st,1,i-1),x,code1);
     val(copy(st,i+1,255),y,code2);
    until code1+code2=0
   else begin
    ReadDataFile(4,ofs(x),seg(x));
    CloseDataFile;
    end;
  xx:=x;
  yy:=y;
  exit;
  end;
end;

PROCEDURE WriteLine(y:word);
var x,x2,xy,i,j,k,lastadr:word;
label 1,2;
begin

 {nastavi Wmezer, Wodsaz, Wodcentr, Wsirmez, Wtoedi, Wnewedi}
 GetLineParams;
 x:=pixStart+Wodsaz+Wodcentr;
 {nastavi naky promenny o tehle radce pro editor}
 if linetotal<maxlines-1 then begin
   edofs[linetotal]:=edi;
   scrx[linetotal]:=x;
   scry[linetotal]:=y;
   inc(linetotal);
   end;
 {pise text}
 xy:=(txsir*y+x div pixMinicharsir) shl 1;
 for edi:=edi to Wtoedi do begin
   wlcha:=edtext[edi];
   if wlcha=chgcol then begin inc(edi);wlcol:=mixcolstxt[(ord(edtext[edi])-ord('a'))];end else
   if (edi=blokstart) and blokon then asm mov es,workseg;mov di,xy;mov ax,256*14+'[';stosw;mov xy,di;end else
   if (edi=blokend)   and blokon then asm mov es,workseg;mov di,xy;mov ax,256*14+']';stosw;mov xy,di;end else
    asm mov es,workseg;mov di,xy;mov ax,[offset wlcha];stosw;mov xy,di;end;
   end;
 edi:=Wnewedi;
end;


PROCEDURE TextBox(kamx,kamy,sir,vys,barva:word);assembler;
 asm mov ax,2*txsir;mul kamy;mov di,kamx;test di,0f000h;jz @ok;mov di,0;@ok:shl di,1;add di,ax
     mov es,workseg
     mov ax,barva
     mov dx,vys
     @1:                {kresli box}
     push di;mov cx,sir;rep stosw;pop di;add di,2*txsir
     dec dx;jnz @1
     end;


PROCEDURE SearchMyEdi;
var x,y:word;
begin
 x:=scrx[linenow] div pixMinicharsir;
 y:=scry[linenow];
 for edi:=edofs[linenow] to edofs[linenow+1]-1 do
  if (x>=ednowx) or (edtext[edi]=#13) then begin if edtext[edi]=chgcol then inc(edi,2);exit;end else
   if edtext[edi]=chgcol then inc(edi) else inc(x);
end;

PROCEDURE SearchMyXYLinenow;
var i:word;
begin
 for linenow:=0 to linetotal do if ednowi<edofs[linenow+1] then begin
   ednowx:=scrx[linenow] div pixMinicharsir;
   ednowy:=scry[linenow];
   for i:=edofs[linenow] to edofs[linenow+1]-1 do
    if i>=ednowi then exit else
     if edtext[i]='`' then inc(i) else inc(ednowx);
   end;
end;

FUNCTION VeryStartLine:word;
var i:word;
begin
 i:=edofs[linenow];
 case edtext[i-1] of INSPIC,MRAMOR,TABULKA:dec(i);end;
 case edtext[i-2] of INSBIGCHAR,INSBUTTON:dec(i,2);end;
 VeryStartLine:=i;
end;

PROCEDURE WriteInteger(kam:word;kolik:integer);
begin
 if kolik<0 then inc(kolik,1000);
 edtext[kam  ]:=chr(48+kolik div 100);
 edtext[kam+1]:=chr(48+kolik div 10 mod 10);
 edtext[kam+2]:=chr(48+kolik mod 10);
end;

PROCEDURE TxMode(m,n:byte);
const modu=4;
      mo:array[0..modu-1] of byte=( 3,$50,$51,$52);
      li:array[0..modu-1] of byte=(25, 30, 43, 60);
var   i:byte;
begin
 mode:=m mod modu;
 txvys:=li[mode];
 txsirtxvys:=txsir*txvys;
 i:=mo[mode];
 asm mov ah,0;mov al,i;or al,n;int 10h;end;
end;

FUNCTION FileSelect(veta,typ,preselect:string):string;
const maxfajlu=150;
var   str:array[1..maxfajlu] of string[14];
      i,j,fajlu:integer;
      t:searchrec;
      ch:char;
      st:string;
      keyb:Boolean;
      x1:byte;

procedure FindAll(typ:string);
var j:word;
begin
 findfirst(typ,0,t);
 while doserror=0 do begin
  if i<maxfajlu then inc(i);
  str[i]:=t.name;
  for j:=1 to length(str[i]) do case str[i,j] of 'A'..'Z':str[i,j]:=chr(ord(str[i,j])+ord('a')-ord('A'));end;
  findnext(t);
  end;
end;

label 1;
Begin
 i:=0;
 findall(typ);
 findall('x\'+typ);
 fajlu:=i;
 if fajlu=0 then begin fileselect:=ask(veta,20,'','!');exit;end;

 {sort}
 repeat
  j:=0;
  for i:=1 to fajlu-1 do if str[i]>str[i+1] then begin inc(j);st:=str[i];str[i]:=str[i+1];str[i+1]:=st;end;
 until j=0;

 for i:=fajlu downto 1 do if preselect=str[i] then goto 1;1:
 x1:=40-fajlu div 20*13 div 2;
 textattr:=7;
 clrscr;
 setvis(0);
 gotoxy(18,1);write(veta);
 st:='';
 keyb:=false;
 repeat
   if not keyb then st:=str[i];
   textattr:=7;
   for j:=1 to fajlu do begin gotoxy(x1+j div 20*13,4+j mod 20);write(str[j]);end;
   textattr:=15;              gotoxy(x1+i div 20*13,4+i mod 20);write(str[i]);
   gotoxy(60,1);write(st,'         ');
   gotoxy(60+length(st),1);
   ch:=readkey;
   case ch of #75:begin dec(i,20);keyb:=false;end;
              #77:begin inc(i,20);keyb:=false;end;
              #72:begin dec(i);   keyb:=false;end;
              #80:begin inc(i);   keyb:=false;end;
              'I':begin i:=1;     keyb:=false;end;
              'Q':begin i:=fajlu; keyb:=false;end;
              'a'..'z','.','-','0'..'9'
                 :if keyb=true then st:=st+ch else begin keyb:=true;st:=ch;end;
               #8:if length(st)>0 then st[0]:=chr(length(st)-1);
              end;
   while i<1 do inc(i,fajlu);
   while i>fajlu do dec(i,fajlu);
 until (ch=#27) or (ch=#13);
 if ch=#13 then fileselect:=st else fileselect:='';
 setvis(lasttextvis);
End;

PROCEDURE MoveTxtMouse(x,y:word);assembler;{nastaveni polohy M-x-y}
 asm mov ax,4;mov cx,x;shl cx,1;mov dx,y;int 33h;end;

PROCEDURE GetMouseChange(var x,y:integer);
var i,j:integer;
begin
 asm mov ax,0bh;int 33h;mov i,cx;mov j,dx;end;
 x:=i div 2;
 y:=j;
end;

FUNCTION MousePress:Boolean;
begin
 asm mov ax,3;int 33h;mov @result,bl;end;
end;

PROCEDURE RefreshTextScreen;
var   ch,c2:char;
      st:string;
      size:byte;
      ii,iimax,i,j,k,
      qixStart,qixLen,qedi:word;


Procedure Hlavicka;{kresli hlavicku odstavce}
var j,k:word;
begin
 inc(hlavapat);{zapise zacatek tohodle odstavce}
 inc(sloupcu);
 with hlavapata[hlavapat] do begin
   oedi     :=edi-13;
   x1       :=pixStart;
   y16      :=ii;
   firstline:=linetotal;
   end;
 j:=(txsir*(ii-1)+pixStart div pixMinicharsir) shl 1;
 k:=pixLen div pixMinicharsir-8;
 asm mov es,workseg;mov di,j
     mov ax,13*256+'Ú';stosw
     mov al,'Ä';stosw
     mov al,sloupcu;add al,48;inc ah;stosw;dec ah
     mov al,'Ä';mov cx,k;rep stosw
    mov ah,1;
     mov bl,otec;and bl,1;mov al,'Ú';jnz @down1;mov al,'À';@down1:stosw
     mov al,otec;inc al;shr al,1;add al,48;stosw
     mov bl,otec;and bl,1;mov al,'¿';jnz @down2;mov al,'Ù';@down2:stosw
    mov ah,13
     mov al,'Ä';stosw
     mov al,'¿';stosw
     end;
end;

Procedure Patka;{kresli patku odstavce}
var j,k:word;
begin
 inc(hlavapat);{zapise konec minulyho odstavce}
 if hlavapat>0 then with hlavapata[hlavapat] do begin
   oedi     :=edi;
   x1       :=pixStart;
   y16      :=ii;
   firstline:=linetotal-1;
   j:=(txsir*ii+pixStart div pixMinicharsir) shl 1;
   k:=pixLen div pixMinicharsir-4;
   asm mov es,workseg;mov di,j
       mov ax,13*256+'À';stosw
       mov al,'Ä';stosw
       mov al,sloupcu;add al,48;inc ah;stosw;dec ah
       mov al,'Ä';mov cx,k;rep stosw
       mov al,'Ù';stosw
       end;
   end;
end;

Begin
 qixStart:=pixStart;
 qixLen  :=pixLen;
 qedi    :=edi;

 {nakresli na obrazovku cely fajl}
 SetDefaultTextAttribs;
 ii:=1;
 iimax:=0;

 {smaze screen}
 asm mov es,workseg;mov di,0;mov ax,700h;mov cx,16384;rep stosw;end;

 edi:=edtextofs;
 linetotal:=0;
 repeat
  case edtext[edi] of
      TABULKA:begin
        inc(edi);
        inc(ii);
        end;
      MRAMOR:begin
        textbox(pixStart div pixMinicharsir,ii,pixLen div pixMinicharsir,1,ord('Û')+256*7);
        inc(edi);
        asm mov al,wlcol;push ax;mov wlcol,7*16+4;end;
        writeline(ii);
        asm pop ax;mov wlcol,al;end;
        inc(ii);
        end;
      INSPIC:begin
        inc(edi);
        st:=ReadLine;
        GetPicSize(st,i,j);
        TextBox((pixMid-i div 2) div pixMinicharsir,ii,i div pixMinicharsir,j div 8,ord('±')+256*7);
        inc(ii,j div 8);
        asm mov al,wlcol;push ax;mov wlcol,7;end;
        WriteLine(ii-j div 16-1);
        asm pop ax;mov wlcol,al;end;
        end;
      INSBIGCHAR,INSBUTTON:begin
        ch:=edtext[edi];
        c2:=edtext[edi+1];
        inc(edi,2);
        case c2 of 'A'..'Z':begin size:=8;end;
                   'a'..'z':begin size:=4;c2:=chr(ord(c2)+ord('A')-ord('a'));end;
                   end;
        k:=bigcolstxt[c2];
        j:=ReadCharLength;
        i:=ReadPixLength(#13,ofs(tlustejPropsir)-32);
        if i=0 then i:=pixMinicharsir else i:=(i-j)*size+j;
        j:=size*8;
        TextBox((pixMid-i div 2) div pixMinicharsir,ii,i div pixMinicharsir,j div 8,ord('±')+256*k);
        inc(ii,j div 8);
        asm mov al,wlcol;push ax;mov ax,k;mov wlcol,al;end;
        WriteLine(ii-j div 16-1);
        if ch=INSBUTTON then WriteLine(ii-j div 16);
        asm pop ax;mov wlcol,al;end;
        end;
      NEWSLOUPEC:begin
        Patka;
        {spocita souradnice novyho odstavce podle relativne otcovskeho odstavce}
        otec:=ord(edtext[edi+1])-48;
        with hlavapata[otec] do begin
          pixStart :=x1+ReadInteger(edi+2);
          ii       :=y16+ReadInteger(edi+5);
          pixLen   :=ReadInteger(edi+8);
          pixMid   :=pixStart+pixLen div 2;
          end;
        inc(edi,13);
        Hlavicka;
        end;
      ELSE begin WriteLine(ii);inc(ii);end;
      END;

  if ii>iimax then iimax:=ii;
 until edi>=edtextlast;
 Patka;

 {zkopci to do screenu}
 asm push ds;mov es,segb800;mov ds,workseg;mov si,0;mov di,0;mov cx,16384;rep movsw;pop ds;end;

 WriteInteger(ofs(header),1+iimax);

 edofs[linetotal]:=edi;
 scrx[linetotal]:=pixMid;
 scry[linetotal]:=iimax;
 dec(linetotal);

 pixStart:=qixStart;
 pixLen  :=qixLen;
 pixMid  :=pixStart+pixLen div 2;
 edi     :=qedi;


 {prizpusobi promenny soucasny pozici kurzoru=ednowi}
 SearchMyXYLinenow;
 pixStart:=sloupce[nowsloupec].x1;
 pixLen  :=readInteger(sloupce[nowsloupec].firstedi+8);
 pixMid  :=pixStart+pixLen div 2;
 gotoxyavis(ednowx+1,ednowy+1);

End;


PROCEDURE EDITOR;
const hod:array[0..106] of char=
        {kniha}#37+
        #13#10#13#10'intelektu ln¡ £rove¤, estetick˜ z ‘itek'#13#10+insbigchar+'c*****#'+
        #13#10#13#10'napˆt¡, ‡tivost, Mark Stone index'#13#10+insbigchar+'c*****#'#13#10#13#10#0;
      hod2:array[0..170] of char=
        {hra}#20+
        #13#10#13#10+mramor+''#13#10+tabulka+'tv–rce: '#13#10+'status: '#13#10+'testov no na: '+
        #13#10'existuje je¨tˆ na: '#13#10'velikost: '#13#10'po‘adavky na po‡¡ta‡: '#13#10+'grafika: '+
        #13#10'zvuk: '#13#10#13#10+'grafika: %'#13#10'hudba: %'#13#10'z bava: %'#13#10#13#10+insbigchar+'c*****#'#13#10#13#10#0
        ;
var   i,j:word;
      m,n:integer;
      special:byte;
      ch:char;
label 0,1,2,3,4,5,6,7,8,10,newodst;
Begin
 for i:=1 to picu do picsizes[i].x:=0;
 edfajl:='';
 0:{new file}
 if pos('.',edfajl)>0 then edfajl[0]:=chr(pos('.',edfajl)-1);
 edfajl:=fileselect('Zadej pracovn¡ jm‚no ‡l nku...','*.',edfajl);

 if length(edfajl)=0 then errorhalt(0);
 if pos('.',edfajl)=0 then edfajl:=edfajl+'.';
 edfajl[length(edfajl)+1]:=#0;
 ednowi:=edtextofs;
 edzmena:=0;
 setvis(shiftsetvis);
 lasttextvis:=shiftsetvis;
 nowSloupec:=1;
 blokstart:=0;
 blokend:=0;
 blokon:=false;
 4:
 {precte text.soubor}
 MoveTextFile2EdText(edfajl);
 if edtextlast=edtextofs+2 then begin
   edtext[edtextofs]:=newsloupec;
   edtext[edtextofs+1]:='0';
   WriteInteger(edtextofs+2,120);{pixstart}
   WriteInteger(edtextofs+5,0);{y0}
   WriteInteger(edtextofs+8,270);{pixlen}
   edtext[edtextofs+11]:=#13;
   edtext[edtextofs+12]:=#10;
   edtext[edtextofs+13]:=#13;
   edtext[edtextofs+14]:=#10;
   edtextlast:=edtextofs+15;
   ednowi:=edtextofs+13;
   end;

 1:
 RefreshTextScreen;

 repeat
   10:
   gotoxyavis(ednowx+1,ednowy+1);
   SearchMyEdi;
   ednowi:=edi;

   repeat
     asm mov i,0;mov ax,3;int 33h;cmp bx,2;jnz @noth;mov i,1;@noth:end;
     if i=1 then begin
                   moveTxtMouse(100,100);
                   refresh(1);
                   getmousechange(m,n);
                   n:=n div 8;
                   if (integer(pixStart+m)>=0) and (integer(pixStart+pixLen+m)<wrisir) then begin
                     writeInteger(sloupce[nowsloupec].firstedi+2,readInteger(sloupce[nowsloupec].firstedi+2)+m);
                     end;
                   if integer(sloupce[nowsloupec].y16+n)>0 then begin
                     writeInteger(sloupce[nowsloupec].firstedi+5,readInteger(sloupce[nowsloupec].firstedi+5)+n);
                     end;
                   edzmena:=1;
                   RefreshTextScreen;
                   end;
   until keypressed;
   ch:=readkey;
   case ch of
     '`':;
      #0:begin ch:=readkey;case ch of
{f1=help}     #59:begin
                  setvis(0);
                  gotoxy(0,0);
                  textattr:=7;
                  clrscr;
                  textattr:=14;
                  writeln('ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄû        Pa©eni¨tn¡ editor (verze 2.0)           øìø');
                  textattr:=15;writeln('V¨echno mo‘n˜:');textattr:=7;
                  writeln('F1 - trnky brnky                         Home, End, PgUp, PgDwn, Ctrl-Y');
                  writeln('F2 - ulo‘it');
                  writeln('F3 - ulo‘it a uk zat v grafice !');
                  writeln('F4 - vlo‘en¡ textu z ASCII souboru');
                  write('barva textu:');for i:=0 to mx do begin
                    textattr:=7;
                    write(' ');
                    textattr:=mixcolstxt[i];
                    write(mxkey[i]);
                    end;
                  writeln;
                  textattr:=7;
                  writeln('F6 - vlo‘en¡ velk‚ho n pisu              Shift+F6 - n pis bude 2x vˆt¨¡');
                  writeln('F7 - vlo‘en¡ my¨okliknuteln‚ho n pisu    Shift+F7 - n pis bude 2x vˆt¨¡');
                  writeln('F8 - vlo‘en¡ obr zku');
                  writeln('Alt+T  - na konec textu vraz¡ tabulku hodnocen¡ hry');
                  writeln('Alt+K  - na konec textu vraz¡ tabulku hodnocen¡ knihy');
                  writeln('Alt+M  - zv˜raznˆn  © dka s b¡l˜m podkladem');
                  writeln('Alt+W  - zmˆna barvy velk˜ch p¡smen');
                  writeln('Alt+P  - zmˆna barvy pozad¡ (je vidˆt jen v grafice)');
                  writeln('Insert - vlo‘¡ © dku (kdy‘ m ¨ na prvn¡ © dce nadpis a chce¨ p©ed nˆj)');
                  writeln('TAB    - p©ep¡n  rozli¨en¡ od 80x25 a‘ po 80x60 (jen na Trident VGA)');
                  textattr:=15;writeln('Sloupce:');textattr:=7;
                  writeln('Alt+1..9      - sko‡¡ na za‡ tek sloupce ‡¡slo 1..9');
                  writeln('Ctrl+¨ipky    - roz¨¡©en¡ nebo z£‘en¡ sloupce');
                  writeln('RightMouse    - p©em¡stˆn¡ cel‚ho sloupce: stiskni prav‚ tla‡¡tko, pohybuj my¨¡');
                  writeln('Ctrl+Home/End - mˆn¡ zavˆ¨en¡ tohoto sloupce k jin‚mu sloupci');
                  writeln('F9            - v m¡stˆ kurzoru rozdˆl¡ sloupec na dva nad sebou');
                  textattr:=15;write('Bloky: ');textattr:=7;write('Alt+');textattr:=15;write('B');textattr:=7;
                   write('egin,');textattr:=15;write('E');textattr:=7;write('nd,');textattr:=15;
                   write('C');textattr:=7;write('opy,mo');textattr:=15;write('V');textattr:=7;write('e,');
                   textattr:=15;write('Z');textattr:=7;writeln('ap  (jako ve ScreamTrackeru a jinde)');
{                  writeln;}
                  write('Nepi¨ ‡l nky del¨¡ ne‘ 200 © dek nebo 10000 bajt–.  Baj u dal¨¡ verze, Stan.');
                  repeat readkey until not keypressed;
                  setvis(lasttextvis);
                  goto 1;
                  end;
{f2=save}     #60:SaveEditorFile;
{f3=save&show}#61:begin
                  SaveEditorFile;
                   asm
                   {test if present}mov ax,4000h;int 67h;cmp ax,0;jz @2;push 2;call errorhalt;@2:
                   {get emm frame}mov ax,4100h;int 67h;mov frameseg,bx
                   end;
                  tree[1]:=firstscreen;
                  Show(edfajl);
                  txmode(mode,0);
                  setvis(lasttextvis);
                  while keypressed do readkey;
                  delay(200);
                  goto 4;
                  end;
{f4=import}   #62:begin
                  st:=fileselect('Textov˜ soubor, kter˜ sem chce¨ vlo‘it','*.*','');
                  if (length(st)=0) or (opendatafile(st)=0) then goto 1;
                  i:=LengthDataFile;
                  InsertSpaces(edi,i);
                  ReadDataFile(i,edi,seg(edtext));
                  CloseDataFile;
                  edzmena:=1;
                  goto 1;
                  3:
                  end;
{f5=color}#63,#88,#98,#108,#99,#109,#100,#110:begin
                  if edtext[edi-2]=CHGCOL then dec(edi,2);
                  if edtext[edi ]<>CHGCOL then begin
                    InsertSpaces(edi,2);
                    edtext[edi]:=CHGCOL;
                    end;
                  case ch of #63:edtext[edi+1]:='a';
                             #88:edtext[edi+1]:='b';
                             #98:edtext[edi+1]:='c';
                            #108:edtext[edi+1]:='d';
                             #99:edtext[edi+1]:='e';
                            #109:edtext[edi+1]:='f';
                            #100:edtext[edi+1]:='g';
                            #110:edtext[edi+1]:='h';
                            end;
                  ednowi:=edi;
                  edzmena:=1;
                  goto 1;
                  end;
{f6=big}  #64,#89:begin
                  ednowi:=VeryStartLine;
                  InsertSpaces(ednowi,4);
                  edtext[ednowi]:=INSBIGCHAR;
                  if ch=#64 then edtext[ednowi+1]:='c' else edtext[ednowi+1]:='C';
                  edtext[ednowi+2]:=#13;
                  edtext[ednowi+3]:=#10;
                  inc(ednowi,2);
                  edzmena:=1;
                  goto 1;
                  end;
{f7=butto}#65,#90:begin
                  st:=fileselect('Jm‚no ‡l nku na kter˜ se odkazuje¨...','*.','');
                  if length(st)=0 then goto 1;
                  ednowi:=VeryStartLine;
                  InsertSpaces(ednowi,length(st)+6);
                  edtext[ednowi]:=INSBUTTON;
                  if ch=#65 then edtext[ednowi+1]:='c' else edtext[ednowi+1]:='C';
                  edtext[ednowi+2]:=#13;
                  edtext[ednowi+3]:=#10;
                  for i:=1 to length(st) do edtext[ednowi+3+i]:=st[i];
                  edtext[ednowi+length(st)+4]:=#13;
                  edtext[ednowi+length(st)+5]:=#10;
                  inc(ednowi,2);
                  edzmena:=1;
                  goto 1;
                  5:
                  end;
{f8=pic}      #66:begin
                  st:=fileselect('Zadej jm‚no obr zku *.X','*.x','');
                  if length(st)=0 then goto 1;
                  if pos('.',st)=0 then st:=st+'.x';
                  ednowi:=VeryStartLine;
                  InsertSpaces(ednowi,length(st)+3);
                  edtext[ednowi]:=INSPIC;
                  for i:=1 to length(st) do edtext[ednowi+i]:=st[i];
                  edtext[ednowi+length(st)+1]:=#13;
                  edtext[ednowi+length(st)+2]:=#10;
                  edzmena:=1;
                  goto 1;
                  2:
                  end;
{----------SLOUPCE-------------}
{f9=sloupec}  #67:begin
                  for i:=nowsloupec to sloupcu do begin
                    j:=ord(edtext[sloupce[i].firstedi+1])-48;
                    if j div 2>=nowsloupec then
                     edtext[sloupce[i].firstedi+1]:=chr(j+50);
                    end;
                  ednowi:=VeryStartLine;
                  insertspaces(ednowi,4+13+2);
                  edtext[ednowi  ]:=#13;
                  edtext[ednowi+1]:=#10;
                  edtext[ednowi+2]:=#13;
                  edtext[ednowi+3]:=#10;
                  edtext[ednowi+4]:=newsloupec;
                  edtext[ednowi+5]:=chr(48+2*nowsloupec);
                  writeInteger(ednowi+6,0);
                  writeInteger(ednowi+9,2);
                  writeInteger(ednowi+12,pixLen);
                  edtext[ednowi+15]:=#13;
                  edtext[ednowi+16]:=#10;
                  edtext[ednowi+17]:=#13;
                  edtext[ednowi+18]:=#10;
                  inc(ednowi,4+13);
                  inc(nowsloupec);
                  edzmena:=1;
                  goto 1;
                  end;
{CtrlHome}    'w':begin
                  i:=ord(edtext[sloupce[nowsloupec].firstedi+1])-48;
                  if i>0 then begin
                    writeInteger(sloupce[nowsloupec].firstedi+2,
                     readInteger(sloupce[nowsloupec].firstedi+2)-
                     hlavapata[i-1].x1+
                     hlavapata[i].x1);
                    writeInteger(sloupce[nowsloupec].firstedi+5,
                     readInteger(sloupce[nowsloupec].firstedi+5)-
                     hlavapata[i-1].y16+
                     hlavapata[i].y16);
                    dec(edtext[sloupce[nowsloupec].firstedi+1]);
                    edzmena:=1;
                    goto 1;
                    end;
                  end;
{CtrlEnd}     'u':begin
                  i:=ord(edtext[sloupce[nowsloupec].firstedi+1])-48;
                  if i<2*nowsloupec-2 then begin
                    writeInteger(sloupce[nowsloupec].firstedi+2,
                     readInteger(sloupce[nowsloupec].firstedi+2)-
                     hlavapata[i+1].x1+
                     hlavapata[i].x1);
                    writeInteger(sloupce[nowsloupec].firstedi+5,
                     readInteger(sloupce[nowsloupec].firstedi+5)-
                     hlavapata[i+1].y16+
                     hlavapata[i].y16);
                    inc(edtext[sloupce[nowsloupec].firstedi+1]);
                    edzmena:=1;
                    goto 1;
                    end;
                  end;
{f10=         #68:begin
                  edzmena:=1;
                  goto 1;
                  end;}
{alt-1}#120..#128:if ord(ch)-119<=sloupcu then begin
                  nowSloupec:=ord(ch)-119;
                  ednowi:=sloupce[nowsloupec].firstedi+13;
                  goto 1;
                  end;
{zuzeni slp}  's':if pixLen>50 then begin
                  writeInteger(sloupce[nowsloupec].firstedi+2,readInteger(sloupce[nowsloupec].firstedi+2)+3);
                  writeInteger(sloupce[nowsloupec].firstedi+8,pixLen-6);
                  edzmena:=1;
                  goto 1;
                  end;
{rozsiri slp} 't':if pixlen<500 then begin
                  writeInteger(sloupce[nowsloupec].firstedi+2,readInteger(sloupce[nowsloupec].firstedi+2)-3);
                  writeInteger(sloupce[nowsloupec].firstedi+8,pixLen+6);
                  edzmena:=1;
                  goto 1;
                  end;
{---------------BLOKY---------------}
{alt-b}       #48:begin
                  blokstart:=edi;
                  blokon:=(blokend>blokstart) and (blokstart>0);
                  goto 1;
                  end;
{alt-e}       #18:begin
                  blokend:=edi;
                  blokon:=(blokend>blokstart) and (blokstart>0);
                  goto 1;
                  end;
{alt-c}       #46:if blokon and ((edi<=blokstart) or (edi>blokend)) then begin
                  i:=blokend-blokstart+1;
                  InsertSpaces(edi,i);
                  Move(mem[dseg:blokstart],mem[dseg:edi],i);
                  blokstart:=0;
                  blokend:=0;
                  edzmena:=1;
                  goto 1;
                  end;
{alt-v}       #47:if blokon and ((edi<=blokstart) or (edi>blokend)) then begin
                  i:=blokend-blokstart+1;
                  InsertSpaces(edi,i);
                  Move(mem[dseg:blokstart],mem[dseg:edi],i);
                  DelSpaces(blokstart,i);
                  blokstart:=0;
                  blokend:=0;
                  edzmena:=1;
                  goto 1;
                  end;
{alt-z}       #44:if blokon then begin
                  i:=blokend-blokstart+1;
                  if edi>blokstart then if edi<blokend then ednowi:=blokstart else dec(ednowi,i);
                  DelSpaces(blokstart,i);
                  blokstart:=0;
                  blokend:=0;
                  edzmena:=1;
                  goto 1;
                  end;
              #75:if ednowx>pixStart div pixMinicharsir then dec(ednowx);
              #77:if ednowx<(pixStart+pixLen) div pixMinicharsir+4 then inc(ednowx);
              #72:if linenow>sloupce[nowsloupec].firstline then begin dec(linenow);ednowy:=scry[linenow];end;
              #80:if linenow<sloupce[nowsloupec].lastline then begin inc(linenow);ednowy:=scry[linenow];end;
{---------------CURSOR-----------------}
      {PgUp}  'I':begin
                  if linenow>sloupce[nowsloupec].firstline+10 then dec(linenow,11) else linenow:=sloupce[nowsloupec].firstline;
                  ednowy:=scry[linenow];
                  end;
      {PgDwn} 'Q':begin
                  if linenow+10<sloupce[nowsloupec].lastline then inc(linenow,11) else linenow:=sloupce[nowsloupec].lastline;
                  ednowy:=scry[linenow];
                  end;
      {Home}  'G':ednowx:=scrx[linenow] div pixMinicharsir;
      {End}   'O':begin
                  ednowx:=scrx[linenow] div pixMinicharsir;
                  i:=edofs[linenow];
                  while (i<edofs[linenow+1]) and (edtext[i]<>#13) do begin
                    if (edtext[i]='`') or (edtext[i]=#13) then inc(i) else inc(ednowx);
                    inc(i);
                    end;
                  if edtext[edi]=' ' then dec(ednowx);
                  end;
{---------------OSTATNI-----------------}
 {tabulka}#37,#20:begin
                  i:=0;while hod[i]<>ch do inc(i);inc(i);
                  while hod[i]<>#0 do begin edtext[edtextlast]:=hod[i];inc(edtextlast);inc(i);end;
                  edzmena:=1;
                  goto 1;
                  end;
    {mramor}  #50:begin
                  edi:=veryStartLine;
                  insertspaces(edi,3);
                  edtext[edi  ]:=#13;
                  edtext[edi+1]:=#10;
                  edtext[edi+2]:=mramor;
                  ednowi:=edi+3;
                  edzmena:=1;
                  goto 1;
                  end;
{alt-w chgcol}#17:begin
                  edi:=veryStartLine;
                  if (edtext[edi]=insbigchar) or (edtext[edi]=insbutton) then begin
                    if edtext[edi+1]<'a' then i:=ord('A') else i:=ord('a');
                    st:=ask('Jakou barvu ? (a,A,b,B...'+chr(ord('A')+bx)+') (velk˜ p¡smeno=vˆt¨¡ n pis)'#13+
                            'c,g=modr  d,h=zelen  e,i=‡erven  f,j=‘lut )',1,edtext[edi+1],'A');
                    if st[0]=#1 then begin
                      edtext[edi+1]:=st[1];
                      edzmena:=1;
                      goto 1;
                      end;
                    end;
                  end;
{alt-p pozadi}#25:begin
                  st:=ask('Jakou chce¨ m¡t barvu pozad¡ ? (0..7)'#13+
                          '0=¨ed ,1=‡erven ,2=zelen ,3=modr ..',1,header[4],'0');
                  if (st[0]=#1) and (st[1]<>header[4]) then begin
                    header[4]:=st[1];
                    edzmena:=1;
                    end;
                  end;
    {insert}  #82:begin
                  ednowi:=VeryStartLine;
                  insertspaces(ednowi,2);
                  edtext[ednowi]:=#13;
                  edtext[ednowi+1]:=#10;
                  edzmena:=1;
                  goto 1;
                  end;
    {delete}  'S':begin
                  if (edi<edtextlast-2) and (edtext[edi+2]<>newsloupec) then begin
                    if (edtext[edi]=#13) or
                       (edtext[edi]=INSBUTTON) or
                       (edtext[edi]=INSBIGCHAR) or
                       (edtext[edi]=CHGCOL) then j:=2 else j:=1;
                    DelSpaces(edi,j);
                    ednowi:=edi;
                    edzmena:=1;
                    goto 1;
                    end;
                  end;
              end;
              end;
       #9:begin
          txmode(mode+1,0);
          setvis(lasttextvis);
          goto 1;
          end;
       #8:{backspace}
          if (edi>edtextofs) and (edtext[edi-13]<>newsloupec) then begin
            if (edtext[edi-1]=#10) or
               (edtext[edi-2]=INSBUTTON) or
               (edtext[edi-2]=INSBIGCHAR) or
               (edtext[edi-2]=CHGCOL) then j:=2 else j:=1;
            DelSpaces(edi-j,j);
            ednowi:=edi-j;
            edzmena:=1;
            goto 1;
            end;
      #25:begin{Ctrl-Y}
          ednowi:=VeryStartLine;
          edi:=ednowi;
          {skonci za cr/lf}
          NextEdiLine;
          {kdyz maze posledni radek odstavce, nesmi smazat cr/lf}
          if (edtext[ednowi-2]<>#13) and (edtext[edi-2]=#13) then special:=2 else special:=0;
          {aby nesmazal posledni radek fajlu nebo sloupce}
          if edi>=sloupce[nowsloupec].lastedi then goto 7;
          {kdyztak se zase o kus vrati, aby nezrusil celej odstavec}
          if edi>edofs[linenow+1] then edi:=edofs[linenow+1];
          {do it}
          DelSpaces(ednowi,edi-ednowi-special);
          {uprava ednowi}
          case edtext[ednowi] of inspic,mramor,tabulka:inc(ednowi);
                                 insbigchar,insbutton:inc(ednowi,2);
                                 end;
          inc(ednowi,special);
          edzmena:=1;
          goto 1;
          7:
          end;
      #13:begin
          InsertSpaces(edi,2);
          edtext[edi]:=#13;
          edtext[edi+1]:=#10;
          ednowi:=edi+2;
          edzmena:=1;
          goto 1;
          end;
      #27:;
     else begin
          InsertSpaces(edi,1);
          edtext[edi]:=ch;
          ednowi:=edi+1;
          edzmena:=1;
          goto 1;
          end;
     end;
 until ch=#27;

 if edzmena=1 then case AskExit of 'c':goto 10;
                                   's':SaveEditorFile;
                                   end;
 goto 0;
End;
{$endif}

var i,j,k,l:integer;
BEGIN
  edtextofs:=ofs(edtextbody);
  headerofs:=ofs(header);
  ofsst:=ofs(st);
  randomize;
  InitDataFile;
  asm
    {get fnt 9x16 adr}
     mov ah,11h;mov al,30h;mov bh,6;push bp;int 10h;mov fntseg16,es;mov fntofs16,bp;pop bp;
    {cls charseg}
     mov ax,ds;mov es,ax;mov ax,0;mov cx,charseglen/2;mov di,offset charseg;rep stosw;
     end;

  for j:=1 to 6 do
    for i:=1 to 4 do begin
     for l:=0 to 2 do pal[3*usedcols+l]:=txtcols[j,l]*i div 4;
     inc(usedcols);
     end;

 {zmeri sirky pismen}
  asm
   mov ax,ds;mov es,ax
   lea si,tenkej+16
   lea di,tenkejPropsir
   call @zmerto
   lea si,tlustej+16
   lea di,tlustejPropsir
   call @zmerto
   jmp @end

  @zmerto:
   mov al,5;stosb
   mov dx,lastchar-' '
  @nextchar:
   mov ah,0
   mov cx,16
   @1:lodsb;or ah,al;loop @1
   mov al,10
   cmp ah,0;jnz @mer;mov al,0;jmp @zmereno
   @mer:dec al;shr ah,1;jnc @mer
   @zmereno:stosb
   dec dx;jnz @nextchar
   ret

   @end:
   end;

  MemInit;
  MakeFog;
  PrepareMiniFont;


{$ifdef editor}
  setup:=1;
  editor;
{$else}
  if setup<2 then Show(setupStartup) else Show('');
{$endif}

  errorhalt(0);
END.

irq=2
cary treba mezi sloupci textu apod...
deleni slov
mys se zasekava pri prudkym pohybu za okraj stranky
kdyz nenajde zadny sound, poskodi system a Pascal se haltne

zasmouhanej font
jiny smouhy na pozadi

tuhne pri scrollingu a zaroven prepinani hudby
nekdy nezdetekuje chybejici EMM
nekdy nehraje na SB hudba