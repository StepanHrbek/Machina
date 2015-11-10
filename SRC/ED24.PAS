{# - docasny veci, konkretni pro jedno cislo}
{$G+,R-,S-,I-,E-,N-,M 15000,0,0}

{$define parenist}
{$define together}
{$define safe}
{$define debug}
{$define setup}

{$ifdef pareniste}
 {$define textinside}
 {$define datainside}
 {$define midas}
 {$define lookforlastsetup}
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
 {$I bard.inc}

{$ifdef midas}
 const samplu=5;
       volume:byte=50;
       module:pointer=nil;
       modulu:byte=0;
       mSt:string[13]='*.s3m'#0;
       dylkamodname=13;
       sam_goon=1;
       sam_goback=5;
       sam_togl=1;
       sam_konec=4;
       sam_start=3;
       sam_blbce=2;
       sampleLoaded:array[1..samplu] of byte=(0,0,0,0,0);
 var   ModuleNames:array[1..10] of string[dylkamodname];
       sampleHandle:array[1..samplu] of byte;
       tmrScrSync:word;
 const PtmrScrSync:Pword=@tmrscrsync;
{$else}
 const kbport:word=$64;
       enabledlookingforlastsetup:Boolean=true;
{$endif}

{$ifdef lookforlastsetup}
 const lastparfilename:string[14]='\pareni02.exe'#0;
{$endif}

{$ifdef setup}
 const setupsize=90;
 var   OfsofFrameInSetupbitmap:array[0..setupsize] of word;
{$endif}

{$ifdef textinside}
{$else}
 var   f:text;
{$endif}

{$ifdef datainside}
 {$i data.inc}
 const nekdyhand:word=0;
 var   vzdyhand:word;
{$else}
{$endif}

{$ifdef editor}
 const verze='2.5';
       shiftSetvis=11;
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

CONST maxaskstringu=30;
      maxtogglu=60;
      maxbuttonu=20;
      maxobrazku=7;
      askmaxlen=24;

      headlen      =20;
      h_radek      =1;
      h_barvapozadi=4;
      h_textura    =5;
      h_visx       =6;
      h_visy       =9;
      h_svetlost   =12;
      h_flags      =13;
      h_unused     =14;{5 nul}
      h_endofline  =19;

      f_color_ram  =1;

      textur=2;
      texturhandle:word=0;
      setuphandle:word=0;
      texturyhotovy:byte=0;
      frameseg:word=0;
      edtextmaxlen=15000;
      pageStartup ='mainpage';
      menuStartup ='mainmenu';
      fileAnketa  ='anket';
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
      mramor='ß';
      tabulka='ì';
      togl='˛';
      askSymbol=':';
      rovnejLeft='@';
      rovnaLine='ƒ';
      svislaLine='≥';
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
      dotaznikkeypressed:byte=0;
      ramecekcolor:byte=24;
      keyoff:byte=0;
      setuping:Boolean=false;
      txtcols:array[1..6,0..2] of byte=(
        (30,30,63),
        (40,60,28),
        (63,35,35),
        (63,63,00),
        (63,63,63),
        (00,63,63));

      bx=21;
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
       (14,12,14,14,14,14,14,14),

       (255,0,0,0,0,0,0,0),
       (254,0,0,0,0,0,0,0),
       (253,0,0,0,0,0,0,0),
       (252,0,0,0,0,0,0,0),
       (251,4,3,2,0,0,0,0),
       (251,16,15,14,0,0,0,0),
       (3,4,3,2,1,1,1,1),
       (15,16,15,14,13,13,13,13)
       );
{$ifdef editor}
      bigcolstxt:array['A'..chr(ord('A')+bx)] of byte=(
        1,16*4+14, 9,10,12,14, 1*16+9,2*16+10,4*16+12,7*16+14, 16+7,16*2+15,4,6, 7,7,7,7,9,14,9,14);
{$endif}
      mx=7;
      mixcols:array[0..mx] of word=
        (257*8,256*16+12,
        257*16,257*20,
        257*19,257*4,
        257*12,257*24);
{$ifdef editor}
      mixcolstxt:array[0..mx] of byte=(10,16*4+14,14,15,7,9,12,11);
{      mxkey:array[0..mx] of string[5]=('F5','ShiF5','CtrF5','AltF5','CtrF6','AltF6','CtrF7','AltF7');}
{$endif}
      fxmapkasir4=12;
      fxmapkavys=80;
      fxmapka:byte=1{array[1..fxmapkavys,1..4*fxmapkasir4] of byte=()};


VAR   edtextofs,headerofs:word;
      header:array[1..headlen] of char;
      edtextbody:array[0..edtextmaxlen] of char;
      edtext:array[2..60000] of char absolute firstpoint;

      last_abs_x,last_abs_y,
      presx,presy,presz,
      workseg,bigfontseg,minifontseg,
      wriy,fileadr,datahandle,
      Wmezer, Wodsaz, Wodcentr, Wsirmez, Wtoedi, Wnewedi,
      pixStart,pixLen,pixMid,pixMinicharSir,pixOdsaz,
      ramecekStart,ramecekLen,
      ofsst,framewriseg,wordX,
      lastvisx,lastvisy,
      edtextlast,edi,
      mixword,minifnt,
      fntseg16,fntofs16,
      panelcentrx4,panelcentry,
      shadowvis                  :WORD;

      key                        :INTEGER;

      hlavapat,sloupcu           :SHORTINT;

      locks,oldscrollock,
      togglu,togglu2,buttonu2,
      askstringu,askstringu2,
      nowask,nowaskx,
      nowbright                  :BYTE;

      LastopenLength             :LONGINT;

      bokyRamecku,
      ref                        :BOOLEAN;

      TlustejPropSir,TenkejPropSir:array[' '..lastchar] of byte;
      sunx,suny:array[0..setrvacnost-1] of shortint;
      pal:array[0..767] of byte;
      hlavapata:array[-1..18] of record x1,y16,oedi,firstline:word;end;
      sloupce:array[0..9] of record x1,y16,firstedi,firstline,xx1,yy16,lastedi,lastline:word;end absolute hlavapata;
      toggle,toggle2:array[1..maxtogglu] of record y16:word;on:byte;end;
      askstring:array[1..maxaskstringu] of record y16:word;str:array[1..askmaxlen] of char;end;

      head:word absolute 0:$41a;
      tail:word absolute 0:$41c;

CONST lenfont=(ord(lastchar)+1-ord(' '))*16*8;
      offsetminifont=8;

{-----smooth scrolling------}
{$ifdef midas}
{$else}
CONST setup:word=0;
{$endif}

{----popis screenu----}
TYPE  TPopisScreenu=record
                      radek,handle,mousex,mousey:word;
                      visx,visy:integer;
                      buttonu:byte;
                   {p}palet:byte;
                   {p}nowpal:word;
                   {p}jakapaleta:array[1..maxobrazku] of byte;
                   {p}kdepaletaTop,kdepaletaBot:array[1..maxobrazku] of word;
                      bu:array[1..maxbuttonu] of record x1,y1,x2,y2:word;fi:string[13];end;
                      fl:string[13];
                      backgroundcolor,svetlost:byte;
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
  asm {dealloc texturhandle}mov ah,45h;mov dx,texturhandle;cmp dx,0;jz @ok;int 67h;@ok:end;
 {----CONV----}
  for i:=1 to fontu do
   for c:=' ' to lastchar do begin
    j:=charseg[i,c];
    if j>0 then asm {dealloc conv}mov ah,49h;mov es,j;int 21h;end;
    end;
  asm
   mov ah,49h;mov es,workseg;int 21h;
   mov ah,49h;mov es,minifontseg;int 21h;
   end;
end;

PROCEDURE SaveSetup;assembler;{zapise do EXE headeru vysledek setupu}
   asm
{$ifdef pareniste}
     {set pointer}
     mov ax,4200h;mov bx,vzdyhand;mov cx,0;mov dx,1ah;int 21h;
     {write 1 byte}
     mov ah,40h;mov bx,vzdyhand;mov cx,2;mov dx,offset setup;int 21h;
{$endif}
     end;

PROCEDURE Refresh(n:byte);assembler;
 asm mov ch,0;mov cl,n;@2:mov dx,3dah;in al,dx;test al,8;jnz @2; @5:in al,dx;test al,8;jz @5;loop @2;end;
PROCEDURE Refresh2(n:byte);assembler;
 asm mov ch,0;mov cl,n;@2:mov dx,3dah;in al,dx;test al,8;jz @2;  @5:in al,dx;test al,8;jnz @5;loop @2;end;

PROCEDURE UniversalRefresh;
begin
{$ifdef midas}
   repeat until ref;
   ref:=false;
{$else}
   refresh(1);
{$endif}
end;

PROCEDURE LightLocks;assembler;
 asm push 1;call refresh;mov dx,kbport;mov al,0edh;out dx,al
     push 1;call refresh;mov dx,kbport;mov al,locks;out dx,al;
     end;
PROCEDURE MidasLightLocks;assembler;
 asm mov ref,0;@1:cmp ref,0;jz @1;mov dx,kbport;mov al,0edh;out dx,al
     mov ref,0;@2:cmp ref,0;jz @2;mov dx,kbport;mov al,locks;out dx,al;
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
 {vrati locky do puvodniho stavu}
 locks:=(locks and 254)+oldscrollock;
 lightlocks;

 case n of 0:{$ifdef editor}
             write('Verze ',verze);
             {$else}
             write('Nezapome§ n†m poslat vòsledky ankety !!!');
             {$endif}
           1:write('Pot©ebuju v°c konvenán° pamàti.');
           2:write('Pot©ebuju EMS pamàü -> pouëij EMM, QEMM, 386MAX apod.');
           3:write('Pot©ebuju v°c EMS pamàti.');
          20:write('dos error ',datahandle);
        else write('Nezn†mò error á°slo ',n);
        end;
 saveSetup;
 memdone;
 port[$21]:=0;
 halt;
end;
(*
PROCEDURE DetectEms;assembler;
const emm:array[1..10] of char='EMMXXXX0'#0;
var   handle:word;
 asm
   {open emmxxxx}mov ax,3d00h;lea dx,emm;int 21h;jc @bad
   mov handle,ax;mov bx,ax;mov ax,4407h;int 21h;cmp al,0;jz @bad
   mov EMSdetected,1;@bad:
   {close}mov bx,handle;mov ah,3eh;int 21h;
  end;
*)
PROCEDURE Alloc;assembler;
 asm
   mov ah,48h;int 21h;jc @3;ret
   @3:push 1;call errorhalt
  end;

PROCEDURE MemInit;assembler;
const emm:array[1..10] of char='EMMXXXX0'#0;
var   handle:word;
 asm
 {----EMS----}
   {open emmxxxx}mov ax,3d00h;lea dx,emm;int 21h;jc @emsend
   mov handle,ax;mov bx,ax;mov ax,4407h;int 21h;push ax
   {close}mov bx,handle;mov ah,3eh;int 21h;
   pop ax;cmp al,0;jz @emsend
   {get emm frame}mov ax,4100h;int 67h;mov frameseg,bx
   {alloc textur_ems}mov ax,4300h;mov bx,textur*4;int 67h;or ah,ah;jnz @emsend;mov texturhandle,dx
{$ifdef setup}
   {alloc setup_ems}mov ax,4300h;mov bx,4;int 67h;or ah,ah;jnz @emsend;mov setuphandle,dx
{$endif}
   @emsend:
 {----CONV----}
   mov bx,65536/16;call alloc;mov workseg,ax
   mov bx,lenfont/16+1;call alloc;mov minifontseg,ax
   end;


PROCEDURE Reframe(ii:word);assembler;
 asm
   {reframe}
   mov cx,frameseg
   mov bx,ii;shr bx,1;jnc @startseg;add ch,2;@startseg:
   mov framewriseg,cx
   mov ax,4400h;mov dx,now.handle;int 67h;
   end;

PROCEDURE Reframe32(ii:word);assembler;
 asm
   {reframe}
   mov cx,frameseg
   mov bx,ii;shr bx,1;jnc @startseg;add ch,2;@startseg:
   mov framewriseg,cx
   mov ax,4400h;mov dx,now.handle;int 67h;inc bx
   mov ax,4401h;mov dx,now.handle;int 67h;
   end;

PROCEDURE Reframe2setupems;assembler;
 asm
  {reframe to setup_ems}
   mov ax,4400h;mov dx,setuphandle;mov bx,0;int 67h
   mov ax,4401h;mov dx,setuphandle;mov bx,1;int 67h
   mov ax,4402h;mov dx,setuphandle;mov bx,2;int 67h
   mov ax,4403h;mov dx,setuphandle;mov bx,3;int 67h
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
      j:integer;
begin
 case n of 0:{grey} for i:=0 to 47 do pal[3*usedcols+i]:=9+i div 5;
           1:{red}  for i:=0 to 47 do pal[3*usedcols+i]:=(3+i div 3+((i+2) mod 3 shr 1)*abs(40-i));
           2:{green}for i:=0 to 47 do pal[3*usedcols+i]:=(3+i div 3+((i+1) mod 3 shr 1)*(40-i));
           3:{blue} for i:=0 to 47 do pal[3*usedcols+i]:=(3+i div 3+( i    mod 3 shr 1)*abs(40-i));
     4:{zelena-r}   for i:=0 to 47 do pal[3*usedcols+i]:=(3+((i+1) mod 3 shr 1)*(i div 3)+((i+2) mod 3 shr 1)*abs(35-i));
     5:{hnedo-r}    for i:=0 to 47 do pal[3*usedcols+i]:=(3+((i+1) mod 3 shr 1)*(i div 3)+((i+2) mod 3*2 shr 1)*abs(30-i));
     6:{fialova-r}  for i:=0 to 47 do pal[3*usedcols+i]:=(3+(i mod 3 shr 1)*(i div 3)+((i+2) mod 3*2 shr 1)*abs(30-i));
     7:{sedomodra-r}for i:=0 to 47 do pal[3*usedcols+i]:=(3+(i mod 3)*(i div 4)+((i+2) mod 3*3 shr 2)*abs(35-i));
           end;
 for i:=0 to 47 do begin
  j:=pal[3*usedcols+i]*(now.svetlost+5) div 7;
  if j>63 then j:=63;
  pal[3*usedcols+i]:=j;
  end;
end;


{ €€ €€ €€   FILE MANAGER   €€ €€ €€ }

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
   {precte z headeru setup byte}
    mov ax,[offset header+1ah];mov setup,ax
   {open pikcr fajl}
    mov ax,3d00h;mov dx,offset nekdyfile+1;int 21h;
    jc @nodatafajl;mov nekdyhand,ax;@nodatafajl:
{$endif}
    pushf;cli
   {sam zdetekuje kbport}
    push 1;call refresh;mov dx,kbport;mov al,0eeh;out dx,al
    push 1;call refresh;mov dx,kbport;in al,dx
    cmp al,0eeh;jz @kb64;xor kbport,4;@kb64:
   {nastavi promennou LOCKS}
    mov ah,2;int 16h;shr al,4;mov ah,al;and ah,1;mov oldscrollock,ah;and al,2+4
    test setup,16;jz @nolock;inc al;@nolock:mov locks,al
   {rozsviti locky}
    call lightLocks
    popf
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
{$ifdef together}
   if handle=0 then begin datahandle:=vzdyhand;inc(mypos,exeleng);end
               else begin if nekdyhand=0 then exit{kdyz chybi druhy datafajl}
                                         else datahandle:=nekdyhand;end;
{$else}
   datahandle:=nekdyhand;
{$endif}
   asm
    {set pointer}
    mov ax,4200h;mov bx,datahandle;mov cx,poslo;mov dx,poshi;int 21h;
    end;
   end;
 OpenDataFile:=1;
end;
{$else}
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

{$ifdef textinside}
{$else}
PROCEDURE PutStartinHeader(allheader:Boolean);
const startinheaderlen=headlen+14;
      startinheader:array[0..startinheaderlen] of char=
        '0037a0760003000000'#13#10'^0120000270'#13#10#13#10;
var i,j:word;
begin
 if allheader then begin i:=0;                  {raw file, new file}
                         j:=startinheaderlen+1;end
              else begin i:=4;                  {old file}
                         j:=headlen-2;end;
 move(mem[dseg:headerofs+i],mem[dseg:headerofs+j],edtextlast+1-headerofs);
 inc(edtextlast,j-i);
 for i:=i to j-1 do edtext[headerofs+i]:=startinheader[i];
 edzmena:=1;
end;
{$endif}

PROCEDURE MoveTextFile2EdText(st:string);
const dummylen=75;
      dummy:array[0..dummylen] of char=
        '0303a0760000000000'#13#10'^0100012310'#13#10'.........'#13#10#13#10'Tento text nebyl za©azen...'#13#10#0;
var   i:word;
begin
{$ifdef textinside}
 if (OpenDataFile(st)=0) or (lastopenLength<>ReadDataFile(lastopenLength,ofs(header),seg(header))) then begin
   for i:=0 to dummylen do edtext[headerofs+i]:=dummy[i];
   edtextlast:=ofs(header)+i-1;
   for i:=1 to length(st) do edtext[edtextofs+12+i]:=st[i];
   end
  else edtextlast:=ofs(header)+lastopenLength;
{$else}
 edzmena:=0;
 {precte textfajl pokud existuje, kdyztak mu vytvori i header}
 if OpenDataFile(st)=0 then begin {new file}
   edtextlast:=ofs(header)-1;
   putstartinheader(true);
   end
  else begin
   edtextlast:=ofs(header)-1+ReadDataFile(65535,ofs(header),seg(header));
   CloseDataFile;
   if header[h_textura+2]=newsloupec {old format} then putstartinheader(false) else
   if edtext[edtextofs]<>newsloupec {raw format} then putstartinheader(true);
   end;
 {na konec fajlu da CR/LF}
 if (edtext[edtextlast-1]<>#13) or (edtext[edtextlast]<>#10) then begin
   edtext[edtextlast+1]:=#13;
   edtext[edtextlast+2]:=#10;
   inc(edtextlast,2);
   end;
{$endif}
end;


{ €€ €€ €€   S O U N D   €€ €€ €€ }

{$ifdef midas}
PROCEDURE LoadSample(i:byte);
begin
 if sampleLoaded[i]=0 then with data[i+1] do begin
    if opendatafile(name)>0 then readdatafile(len,0,workseg);
    samplehandle[i]:=midasLoadsample(@mem[workseg:0],len);
    sampleLoaded[i]:=1;
    end;
end;
{
PROCEDURE RemoveSample(i:byte);
begin
 if sampleLoaded[i]>0 then begin;
   midasRemovesample(i);
   sampleLoaded[i]:=0;
   end;
end;
}
PROCEDURE PlaySample(i:byte);
{var j:byte;}
begin
{ removesample(sam_start);
 case i of sam_konec:begin
                     for j:=1 to samplu do removesample(j);
                     Loadsample(i);
                     end;
                else begin
                     loadsample(i);
                     end;
                end;}
 midasPlaySample(sampleHandle[i],8000);
end;
{$endif}


{   €€€ -------  BIG FONT ------- €€€ }


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

PROCEDURE Ems2ScreenFromx4Sir8(line,fromx4,sir8:word);assembler;var bit,workframseg:word;
 asm {reframe, prepare ds}
      push ds
      mov ax,4400h;mov bx,line;
      mov cx,frameseg;shr bx,1;jnc @segfr;add ch,2;@segfr:mov workframseg,cx;
      mov dx,now.handle;int 67h;
     {prepare ds,es}
      mov ax,line;shl ax,11;mov [cs:offset @za-2],ax
      mov mouseactive,0
      mov es,sega000;mov ds,workframseg
      mov si,fromx4
      mov bit,3
     {set bit}
      @nextbit:
      mov ax,102h;mov cx,bit;shl ah,cl;mov dx,3c4h;out dx,ax
     {copy}
      mov di,1024;@za:add di,fromx4
      mov dx,16
      @nextline:
      push di;push si
      mov cx,sir8;rep movsw
      pop si;pop di;add di,wrisir/4;add si,wrisir/4
      dec dx;jnz @nextline
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
 if setup and 32>0 then begin n:=n div 4;if n>16 then n:=16;end
                   else begin n:=n div 7;if n>8 then n:=8;end;
 osekej:=n;
end;

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

PROCEDURE Mouse(on:byte);assembler;var a:word;
{write:3c4,2,0-15; read:3ce,4,0-3}
 asm pushf;cli
     mov al,on
     cmp al,mouseflag;jz @99

    {save vga ports}
     call ports2ax;push ax

     mov al,on
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
    @1:
     mov bl,[si];cmp bl,0;jz @skip1;xchg bl,[es:di  ];@skip1:mov [si],bl;add si,4
     mov bl,[si];cmp bl,0;jz @skip2;xchg bl,[es:di+1];@skip2:mov [si],bl;add si,4
     add di,wrisir/4;loop @1
     sub di,4*wrisir
     sub si,16*8-1

     shl ah,1;cmp ah,16;jnz @ok;mov ah,1;inc di;@ok:

     pop cx;loop @loop

    {restore vga ports}
     pop bx;call bx2ports

     @99:
     popf
     end;

FUNCTION MousePress:Boolean;
begin
 asm mov ax,3;int 33h;mov @result,bl;end;
end;

PROCEDURE GetMouse(var x,y,z:word);
var i,j,k:word;
begin;
 asm mov ax,3;int 33h;mov k,bx;mov i,cx;mov j,dx;end;
 x:=i;y:=j;z:=k;
end;

PROCEDURE Ano(y16:word;on:byte);assembler;
var bit:byte;
 asm
     cmp setuping,0;jnz @setupano

@NORMALANO:{nakresli togglik do EMS}
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
     jmp @99

@SETUPANO: {nakresli togglik na screenu}
     mov es,sega000

     lea si,anobitmap;cmp on,0;jnz @22;lea si,nebitmap;@22:
     mov di,y16;shl di,11{wrisir};add di,panelcentrx4;sub di,20;mov bit,0
     mov dx,16
    @nextline:
     mov cx,12;
     push di
     @12:call @incbitsetbit;lodsb;mov [es:di],al;loop @12
     pop di;add di,wrisir/4
     dec dx;jnz @nextline
     jmp @99

{inc bit, set bit}
@incbitsetbit:
     push ax;push cx;push dx
     mov cl,bit;inc cx;cmp cl,4;jc @ouk;mov cl,0;inc di;@ouk:mov bit,cl
     mov ax,102h;shl ah,cl;mov dx,3c4h;out dx,ax
     pop dx;pop cx;pop ax
     ret

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
    {nastaveni range M-x}
     mov ax,7;mov cx,0;mov dx,2*vissir-16;int 33h
    {nastaveni range M-y}
     mov ax,8;mov cx,0;mov dx,visvys-16;int 33h;
    {nastaveni handleru M}
     mov ax,0ch;mov cx,7fh;mov dx,cs;mov es,dx;mov dx,offset @mousehandler;int 33h;
     mov ax,ds;mov [cs:offset @q-2],ax
     jmp @9

@MOUSEHANDLER:
     pusha
     push ds
     push es
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
     pop es
     pop ds
     popa
     retf

     @9:end;

PROCEDURE MoveMouse;assembler;{nastaveni polohy M-x-y}
 asm mov ax,4;mov cx,now.mousex;shl cx,1;mov dx,now.mousey;int 33h;end;
PROCEDURE RemoveMouse;assembler;{----REMOVE MOUSE HANDLER----}
 asm {hide}push 0;call mouse;{remove}mov ax,0ch;mov cx,0;int 33h;end;
PROCEDURE SetspeedofMouse;assembler;{citlivost M}
 asm mov ax,setup;and ax,64;shr ax,5;mov cx,5;sub cx,ax;mov dx,cx;mov ax,0fh;int 33h;end;

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
 {cls minifont}
  mov es,minifontseg;mov di,offsetminifont;mov cx,lenfont/2;mov ax,0;rep stosw;

  mov ah,2;
  mov di,offsetminifont
  call @nextcolor
  mov di,offsetminifont-7
  call @nextcolor
  mov ah,1;
  mov di,offsetminifont+2
  call @nextcolor
  mov di,offsetminifont+9
  call @nextcolor
  mov ah,3;
  mov di,offsetminifont+1
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
  @loop:shl al,1;jnc @not;mov [es:di],ah;@not:inc di;loop @loop
  dec dx;jnz @nextline
  pop cx;loop @nextchar
  ret

  @99:
  end;

PROCEDURE Naframuj(n:word);assembler;
 asm
      mov ax,4400h;mov dx,texturhandle;mov bx,n;shl bx,2;push bx;int 67h;pop bx
      mov ax,4401h;mov dx,texturhandle;inc bx           ;push bx;int 67h;pop bx
      mov ax,4402h;mov dx,texturhandle;inc bx           ;push bx;int 67h;pop bx
      mov ax,4403h;mov dx,texturhandle;inc bx                   ;int 67h
 end;

PROCEDURE PlaceTexture(n:word);assembler;
  asm
     {copy textur from EMS to workseg}
      push n;call naframuj
      PUSH DS
      mov es,workseg
      mov ds,frameseg
      mov cx,32768;mov si,0;mov di,si;rep movsw
      POP DS

     {fill ems with texture 256x256}
      mov ax,now.radek;shr ax,1;mov [cs:offset @za-2],ax
      mov bx,0
      @nextpage:push bx;
      mov ax,4400h;mov dx,now.handle;push bx;int 67h;pop bx
      mov es,frameseg
      push ds;mov ds,workseg

      mov si,bx;shl si,13
      mov di,0
      mov dx,32;@1:
      mov cx,256;rep movsw;sub si,256
      dec dx;jnz @1

      pop ds
      pop bx;inc bx;cmp bx,260;@za:jnz @nextpage
      end;


PROCEDURE InsertPicture(x1,y16,sirka,vyska,doublescan,halve_x:word);assembler;var j,ha:word;
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

      cmp halve_x,1;jz @halve1
     {loop HALVE_X=2}
     @halve2:
      @miniloop2:{precte scanlajnu}
      mov bx,doublescan
      @nextscan2:{nekolikrat zakresli tutez scanlajnu}
      mov cx,sirka;shr cx,1;push si;push di;dec di
      @42:inc di;@52:lodsw;or al,al;loopz @42;jcxz @62;stosb;jmp @52;@62:inc di
      pop di;pop si;add di,wrisir
      dec bx;jz @lastscan2;jmp @nextscan2;@lastscan2:add si,sirka
      dec dx;jz @99
      test di,16384;jz @miniloop2
      and di,16383;jmp @wideloop
      jmp @99

     {loop HALVE_X=1}
     @halve1:
      @miniloop1:{precte scanlajnu}
      mov bx,doublescan
      @nextscan1:{nekolikrat zakresli tutez scanlajnu}
      mov cx,sirka;push si;push di;dec di
      @41:inc di;@51:lodsb;or al,al;loopz @41;jcxz @61;stosb;jmp @51;@61:inc di
      pop di;pop si;add di,wrisir
      dec bx;jnz @nextscan1
      add si,sirka
      dec dx;jz @99
      test di,16384;jz @miniloop1
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

PROCEDURE InsertBigChar2Ems(font:byte;c:char;x1,y16:word);{samo si to naframuje}
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
      mov al,[cs:bx+1];inc al;jz @method2;inc al;jz @method3;inc al;jz @method4;inc al;jz @method5;inc al;jz @method6
      @method1:lodsb;segcs xlat;stosb;loop @method1;jmp @continueline
      @method2:lodsb;sub al,6;add [es:di],al;inc di;loop @method2;jmp @continueline
      @method3:lodsb;sub al,[es:di];neg al;cmp al,25;jnc @y;mov al,25;@y:mov [es:di],al;inc di;loop @method3;jmp @continueline
      @method4:lodsb;cmp al,5;jnc @vynech4;sub [es:di],al;@vynech4:inc di;loop @method4;jmp @continueline
      @method5:lodsb;cmp al,5;jnc @vynech5;sub [es:di],al;inc di;loop @method5;jmp @continueline
                                  @vynech5:mov al,34;stosb;loop @method5;jmp @continueline
      @method6:lodsb;segcs xlat;or al,al;jz @vynech6;mov [es:di],al;@vynech6:inc di;loop @method6;jmp @continueline

    @EndOfLine:
      mov di,last
      add di,wrisir
      test di,16384;jz @NewLine
      and di,16383;jmp @NextLineAndReframe

      @99:
      pop ds

      end;
end;

PROCEDURE InsertBardString2Ems(color:byte;centrx1,y16,ofsst:word;var xstart,xsir:integer);{samo si to naframuje}
var i,j,x,x1,x2,len,myofsb,myofsst,sir8:word;
    vys:byte;
begin
 reframe32(y16);

 len:=0;
 myofsst:=ofsst;
 while edtext[myofsst]<>#13 do begin inc(len,bardhead[edtext[myofsst]].bdx2);inc(myofsst);end;
 xsir:=len div 4;
 x:=centrx1-len div 8;
 xstart:=x;
 myofsst:=ofsst;
 while edtext[myofsst]<>#13 do with bardhead[edtext[myofsst]] do begin
  if bsir>0 then begin
   myofsb:=bofs;
   sir8:=(bsir-1) div 8+1;
   vys:=bvys;
   x1:=x+bdx-11+wrisir*(30-bdy);
   asm
     mov es,framewriseg
     mov di,x1
     mov si,myofsb;add si,offset bardbody
     mov bl,vys
     mov ah,color
     mov bh,ah;inc bh
    @nextline:
{     inc ah              }
     mov dx,sir8
     push di
    @nextbyte:
     lodsb;
     mov cx,8;@nextbit:shl al,1;jnc @skip;mov [es:di],ah;mov [es:di+wrisir],bh;@skip:inc di;loop @nextbit
     dec dx;jnz @nextbyte
     pop di;add di,wrisir
     dec bl;jnz @nextline
     end;
   end;
  inc(x,bdx2 div 4);
  inc(myofsst);
  end;

end;



PROCEDURE MakeTexture(n:byte);
const bobu=9;
      sped=0;spee=21;mvel=15;soup=11;minsed=26{*usedcols};maxsed=minsed+14;
      fogsir=256;
var   cha:char;
      lastadr:array[0..2*bobu+1] of word;
      i,j:word;
      alfa:real;

procedure Zamlzit(adr:word);assembler;
asm mov es,frameseg;mov ax,256*(maxsed)+1;mov bl,maxsed-16;mov di,adr;mov dx,mvel;@2:mov cx,mvel
    @1:cmp [es:di],ah;jnc @nomlha;add [es:di],al;@nomlha:inc di;loop @1
    add di,fogsir-soup-2;dec dx;jnz @2;
    end;

procedure Odmlzit(adr:word);assembler;
asm mov es,frameseg;mov di,adr;mov dx,mvel;@2:mov cx,mvel
    @1:mov al,[es:di];cmp al,maxsed+1;jnc @nomlha;cmp al,minsed;jc @nomlha
    dec al;mov [es:di],al;@nomlha:inc di;loop @1
    add di,fogsir-soup;dec dx;jnz @2;
    end;

Begin
 asm mov al,1;mov cl,n;shl al,cl;test texturyhotovy,al;
     mov i,0;jnz @end;mov i,1;or texturyhotovy,al;@end:
     end;
 if i=0 then exit;

 naframuj(n);
 case n of

 0:begin{ ..........TEXTURA 0.......... }
   asm
    {fill frameseg}
     mov es,frameseg;mov di,0;mov ax,257*(minsed+8);mov cx,32768;rep stosw;
     end;
   for i:=1 to 800 do zamlzit(random(65535));
   for i:=1 to 60 do for j:=0 to bobu do begin
     alfa:=alfa+0.2;
     inc(lastadr[2*j  ],fogsir*round(random(2)+30*sin(alfa))+round(random(2)+40*cos(alfa)));zamlzit(lastadr[2*j]);
     inc(lastadr[2*j+1],fogsir*(random(spee)-sped)+(random(spee)-sped));odmlzit(lastadr[2*j+1]);
     end;
   end;

 1:{ ..........TEXTURA 1.......... }
   asm
   PUSH DS

   {fill frameseg}
   mov es,frameseg;mov di,0;mov ax,257*(minsed+4);mov cx,32768;rep stosw;

   {main loop}
   mov ds,frameseg
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
   inc al
   shr al,1
   stosb
   mov ah,bl
   loop @10
   dec dx
   jnz @11

   POP DS
   end;

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
 if edtext[edi-1]=asksymbol then Wodcentr:=4*askx4-25-pixStart;
 asm cmp bokyramecku,0;jz @no;add Wodsaz,10;sub pixLen,10;@no:end;

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
     cmp bokyramecku,0;jz @no;add pixLen,10;@no:
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
      PUSH DS;mov ds,minifontseg
      shl ax,7
      add ax,offsetminifont-' '*16*8
      mov si,ax
      mov dx,16
     @nextline1:
      mov cx,8
      @1:lodsb;or al,al;jz @notal;add al,bl;stosb;dec di;@notal:inc di;loop @1
      add di,wrisir-8
      dec dx;jnz @nextline1
      POP DS

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

PROCEDURE SetDefaultTextAttribs;{tohle delat pri otevreni textfajlu}
begin
{globalni parametry textu}
 pixMinicharSir:=5;
 pixOdsaz:=24;
{pocatecni hodnoty promennych}
 with hlavapata[0] do begin x1:=0;y16:=1;oedi:=edtextofs;firstline:=65535;end;
 hlavapat:=-1;
 sloupcu:=0;
 mixword:=mixcols[0];
 {$ifdef editor}wlcol:=mixcolstxt[0];{$endif}
 minifnt:=0;{mix font, ne shadow font}
 bokyRamecku:=false;
 togglu:=0;
 askstringu:=0;
{ostatni}
 dotaznikkeypressed:=0;
end;

FUNCTION ReadInteger(odkud:word):integer;
begin
 ReadInteger:=(100*ord(edtext[odkud])+10*ord(edtext[odkud+1])+ord(edtext[odkud+2])-4800-480-48+500) mod 1000-500;
end;

PROCEDURE kresliBokyRamecku;assembler;
 asm mov es,framewriseg
     mov al,ramecekcolor
     mov di,ramecekStart
     call @strana
     mov di,ramecekStart
     add di,ramecekLen
     dec di
     call @strana
     jmp @9

     @strana:mov cx,16;@1:stosb;add di,wrisir-1;loop @1;ret
     @9:
     end;

PROCEDURE DrawLine;
var j:word;
begin
 if bokyRamecku then kresliBokyRamecku;
 GetLineParams;
 wordX:=pixStart+Wodsaz+Wodcentr;
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
   assign(f,'anketa2.'+chr(48+random(10))+chr(48+random(10))+chr(48+random(10)));
   rewrite(f);
   for i:=1 to togglu do write(f,chr(48+toggle[i].on));
   writeln(f);
   for i:=1 to askstringu do writeln(f,askstring[i].str);
   close(f);
   askstringu:=0;
   end;
 togglu:=0;
{$endif}
end;

PROCEDURE xorcursor(ems:Boolean);{reframe ; xor cursor do ems i videopameti}
var x4,y16:word;
begin
 if askstringu{nowask}>0 then begin
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

PROCEDURE Hvezdicky(xy:word);assembler;{kresli hvezdicky do video}
const xorcolor2=32;
      swap:array[1..7] of byte=(20,20,20,20,20,20,20);
   asm
      PUSHF;CLI
     {save vga ports
      call ports2ax;push ax}
     {mouse}
      mov ah,0;mov al,mouseflag;push ax;push 0;call mouse;
     {prepare es,di}
      mov es,sega000
      mov bx,xy
      lea di,swap

push ds;mov ax,ds;mov es,ax;mov ds,sega000

     {set 1. bit       for writing}
      mov ax,0102h;mov dx,3c4h;out dx,ax
     {set 1. bit       for reading}
      mov ax,0004h;mov dx,3ceh;out dx,ax
     {xor ƒ}
      mov al,[es:di];xchg al,[bx];stosb

     {set 3. bit       for writing}
      mov ax,0402h;mov dx,3c4h;out dx,ax
     {set 3. bit       for reading}
      mov ax,0204h;mov dx,3ceh;out dx,ax
     {xor ƒ}
      mov al,[es:di];xchg al,[bx];stosb

     {set 2. bit       for writing}
      mov ax,0202h;mov dx,3c4h;out dx,ax
     {set 2. bit       for reading}
      mov ax,0104h;mov dx,3ceh;out dx,ax
     {xor |}
      mov al,[es:di];xchg al,[bx-wrisir/2];stosb
      mov al,[es:di];xchg al,[bx-wrisir/4];stosb
      mov al,[es:di];xchg al,[bx         ];stosb
      mov al,[es:di];xchg al,[bx+wrisir/4];stosb
      mov al,[es:di];xchg al,[bx+wrisir/2];stosb

pop ds

     {mouse}
      call mouse;
     {restore vga ports
      pop bx;call bx2ports}

      POPF
      end;

PROCEDURE PrepareScreen;
var   ii,j,k,k0,l,m,titlesir:integer;
      datafajl:word;
      pall,font,size,doublescan,halve_x:byte;
      ch:char;
      maxradek,zbyvaradek,leftStart:word;
      st:string;

const  chybi:string[60]=#13#10'`bTady chyb° obr†zek.'#13#10'Seëe§ si datafajl s grafikou.'#13#10;


label 1,2,7,8,9;
Begin
  SetDefaultTextAttribs;

  nowask:=0;
  edi:=edtextofs;

  MoveTextFile2EdText(tree[intree].fl);
  now.radek:=readinteger(ofs(header));
  if now.radek<31 then now.radek:=31;
  now.backgroundcolor:=ord(edtext[ofs(header)+3])-48;
  now.svetlost:=ord(header[h_svetlost])-48;

  1:
  asm {alloc ems}mov ax,4300h;mov bx,now.radek;inc bx{*};shr bx,1;int 67h;or ah,ah;jnz @noems;mov now.handle,dx;@noems:end;
  if now.handle=0 then if FreeMoreEMS then goto 1 else ErrorHalt(3);
  tree[intree].handle:=now.handle;

 {kresli stranku do ems}
  now.buttonu:=0;
  MakeTexture (ord(header[h_textura])-ord('a'));
  PlaceTexture(ord(header[h_textura])-ord('a'));
  ii:=1;
  while edi<=edtextlast do case edtext[edi] of

        TOGL:begin
             inc(togglu);
             with toggle[togglu] do begin y16:=ii-1;on:=0;end;
             asm push pixstart;push pixlen;
                 mov ax,pixstart;add pixlen,ax;
                 sub pixlen,4*anox4+30;
                 mov pixstart,4*anox4+30;
                 end;
             inc(edi);
             repeat
               reframe(ii);
               DrawLine;
               inc(ii);
             until edtext[edi-2]=#13;
             asm pop pixlen;pop pixstart;end;
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
  ROVNEJLEFT:begin
             inc(edi);
             edtext[edi-2]:=' ';
             reframe(ii);
             DrawLine;
             inc(ii);
             end;
   ROVNALINE:begin
             inc(edi);
             reframe(ii);
             asm
                {set all 4 bits}
                mov ax,0f02h;mov dx,3c4h;out dx,ax
                {draw it}
                mov es,framewriseg
                mov al,ramecekcolor
                mov ah,ramecekcolor
                mov di,pixStart;              mov cx,pixLen;shr cx,1;rep stosw
                mov di,pixStart;add di,wrisir;mov cx,pixLen;shr cx,1;rep stosw
                end;
             end;
  SVISLALINE:begin
             inc(edi);
             bokyRamecku:=not bokyRamecku;
             ramecekStart:=pixStart;
             ramecekLen:=pixLen;
             if (ord(header[h_flags]) and f_color_ram)>0 then ramecekColor:=mixword else ramecekColor:=24;
             end;
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
        doublescan:=2;halve_x:=1;
        if st[1]='.' then halve_x:=2;
        case st[1] of '-','.':begin doublescan:=1;st:=copy(st,2,200);end;end;
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
            {aby nowpal byla opravdu paleta od nehornejsiho obrazku nehlede na pomichany sloupce}
            if now.kdepaletaBot[now.palet]<now.kdepaletaBot[now.nowpal] then now.nowpal:=now.palet;{}
            end;
          {$else}
          ReadDataFile(5,ofs(xsir),dseg);
          ReadDataFile(3*barevw,ofs(pal)+768-3*barevw,dseg);
          {$endif}
          maxradek:=(65535 div xsir) and $fff8;
          zbyvaradek:=xvys;
          if pixMid<xsir div halve_x div 2 then leftStart:=0 else leftstart:=pixMid-xsir div halve_x div 2;
          repeat
            if maxradek>zbyvaradek then maxradek:=zbyvaradek;
            ReadDataFile(xsir*maxradek,0,workseg);
            insertpicture(leftStart,ii,xsir,maxradek,doublescan,halve_x);
            inc(ii,maxradek*doublescan div 16);
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
        case edtext[edi+1] of '-':size:=2;
                            end;

        if size=2 then InsertBardString2Ems(pall+1,pixMid,ii,edi+2,k0,titlesir)
                  else begin

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
                       end;

        if edtext[m]=INSBUTTON then begin
          if now.buttonu<maxbuttonu then inc(now.buttonu);
          with now.bu[now.buttonu] do begin
            NextEdiLine;
            fi:=ReadLine;
            x1:=k0;
            y1:=16*ii-16;       if size=2 then inc(y1,3);
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

  if now.fl<>'setup' then begin
    dec(now.radek,2);
    KonvertScreen;
    for j:=1 to togglu do ano(toggle[j].y16,0);
    for j:=1 to askstringu do oneaskstring(j);
    xorcursor(false);
    end;
End;




FUNCTION F1:Boolean;begin f1:=(now.visy>=16*wriy+24) and (wriy<now.radek);end;
FUNCTION F2:Boolean;begin f2:=(now.visy< 16*wriy+ 8) and (wriy>0        );end;

PROCEDURE TimerScrolling;far;
var   ii:byte;
      i,j,k,l:integer;
      poradi:array[1..3] of char;
const inside:byte=0;
      waittohvezdicky:word=300;
      hvxy:word=0;
begin
ref:=true;
if not setuping then begin

 if keyoff>0 then dec(keyoff);
 if inside>0 then exit;
 inc(inside);

 asm
   {save vga ports}
    call ports2ax;push ax
    end;

 if setup and 4=0 then poradi:='ovk' else poradi:='vko';
{ 1=ovk,kov,okv
  2=vko,vok,kvo}
 for ii:=1 to 3 do case poradi[ii] of

  'o':begin
  {---upravi sunx,y}
  if now.mousey<       2*mysiokraj then nahoru (osekej(         2*mysiokraj-now.mousey)) else
  if now.mousey>visvys-2*mysiokraj then dolu   (osekej(-(visvys-2*mysiokraj-now.mousey)));
  if not odd(locks) then begin
   if (now.visx>0              ) and (now.mousex<        mysiokraj) then doleva (osekej(      -6+ mysiokraj-now.mousex)) else
   if (now.visx<wrisir-vissir-1) and (now.mousex>vissir- mysiokraj) then doprava(osekej(-(vissir-  mysiokraj-now.mousex)));
   end;

  {---vypocitava novy vis podle sunx,y}
  if (sunx[sunindex]<>0) or (suny[sunindex]<>0) then begin
     j:=now.visy;
     mouseactive:=0;mouse(0);
     inc(now.visx,sunx[sunindex]);
     inc(now.visy,suny[sunindex]);
     if now.visx<0 then now.visx:=0 else if now.visx>=wrisir-vissir then now.visx:=wrisir-vissir-1;
     if now.visy<0 then now.visy:=0 else if now.visy>=16*now.radek-visvys then now.visy:=16*now.radek-visvys;
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
   {$ifdef safe}
   asm {save emm status}mov ax,4700h;mov dx,now.handle;int 67h;end;
   {$endif}
   l:=mouseactive;mouseactive:=0;k:=mouseflag;mouse(0);
   while f1 or f2 do begin
     if f1 then begin inc(wriy);Ems2Screen(wriy+31);end;
     if f2 then begin dec(wriy);Ems2Screen(wriy   );end;
     end;
   mouse(k);mouseactive:=l;
   {$ifdef safe}
   asm {restore emm status}mov ax,4800h;mov dx,now.handle;int 67h;end;
   {$endif}
   end;

  end;

(*
 {# hvezdicky}
 if now.fl='credits' then begin
   dec(waittohvezdicky);
   case waittohvezdicky of 5:begin
                             hvxy:={hvx}(260+random(33)) shr 2+{hvy}(147+random(11)) shl 7;
                             hvezdicky(hvxy);
                             end;
                           0:begin
                             hvezdicky(hvxy);
                             waittohvezdicky:=20+random(50);
                             end;
                           end;
   end;
*)
 asm
    {restore vga ports}
     pop bx;call bx2ports
     end;

 dec(inside);
 end;
end;

FUNCTION Password:byte;
var   i:byte;
      ofss:word;
const a0=$a0;
      passw:array[1..18] of char=
       chr(a0 xor ord('H'))+chr(a0 xor ord('O'))+chr(a0 xor ord('M'))+chr(a0 xor ord('I'))+
       chr(a0 xor ord('N'))+chr(a0 xor ord('I'))+chr(a0 xor ord('D'))+chr(a0 xor ord('A'))+chr(a0 xor ord('E'))+
       chr(a0 xor ord('R'))+chr(a0 xor ord('E'))+chr(a0 xor ord('D'))+chr(a0 xor ord('A'))+chr(a0 xor ord('C'))+
       chr(a0 xor ord('K'))+chr(a0 xor ord('T'))+chr(a0 xor ord('O'))+chr(a0 xor ord('R'));
begin
 password:=0;
 if askstringu<>1 then exit;
 ofss:=ofs(askstring[1].str);
 asm mov cx,9;mov si,ofss;mov di,offset passw
     @nextbyte1:lodsb;xor al,a0;cmp al,[di];jnz @bad1;inc di;loop @nextbyte1;mov @result,2;jmp @end;@bad1:
     mov cx,9;mov si,ofss;mov di,offset passw+9
     @nextbyte2:lodsb;xor al,a0;cmp al,[di];jnz @bad2;inc di;loop @nextbyte2;mov @result,1;jmp @end;@bad2:
     @end:
     end;
end;

PROCEDURE CentralFrame(_mysize:word;_mycolor:byte);assembler;
 asm
   mov ax,_mysize;mov [cs:offset @mysize],ax
   push ds;mov ds,frameseg

{$ifdef setup}
  {si=adresa kousku bitmapy pozadi}
   mov si,[cs:offset @mysize];shl si,1;add si,offset OfsofFrameInSetupbitmap;mov si,[si];
{$endif}

  {es:di=pocatecni adresa leveho horniho rohu panelu}
   mov di,panelcentry;shl di,7{wrisir};add di,panelcentrx4;
   mov ax,[cs:offset @mysize];mov bx,ax;shr ax,2;sub di,ax;inc bx;neg bx;and bl,3;mov [cs:offset @mybit],bl;
   mov ax,[cs:offset @mysize];shl ax,8{wrisir};sub di,ax;mov [cs:offset @levohore],di
   add ax,ax;mov bx,ax
   mov es,sega000

  {leva svisla cara}
   mov al,[cs:offset @mybit];dec al;mov [cs:offset @bit],al
   call @incbitsetbit
   mov al,[cs:offset @mycolor]
   mov cx,[cs:offset @mysize];shl cx,2;add cx,2
   mov di,[cs:offset @levohore]
   cmp word ptr [cs:offset @mysize],0;jnz @nextpix2;mov [es:di],al;mov [es:di+wrisir/4],al;jmp @99;
   or al,al;jnz @nextpix2b
   @nextpix2:{$ifdef setup}lodsb;{$endif}mov [es:di],al;add di,wrisir/4;loop @nextpix2
   jmp @za2
   @nextpix2b:mov [es:di],al;add di,wrisir/4;loop @nextpix2b
   @za2:

  {vodorovny cary}
   mov al,[cs:offset @mybit];mov [cs:offset @bit],al
   mov al,[cs:offset @mycolor]
   mov cx,[cs:offset @mysize];shl cx,1
   mov di,[cs:offset @levohore]
   or al,al;jnz @nextpix1b
   @nextpix1:
   call @incbitsetbit
   {$ifdef setup}lodsb;{$endif}mov [es:di            ],al
   {$ifdef setup}lodsb;{$endif}mov [es:di   +wrisir/4],al
   {$ifdef setup}lodsb;{$endif}mov [es:di+bx         ],al
   {$ifdef setup}lodsb;{$endif}mov [es:di+bx+wrisir/4],al
   loop @nextpix1
   jmp @za1
   @nextpix1b:
   call @incbitsetbit
   mov [es:di            ],al
   mov [es:di   +wrisir/4],al
   mov [es:di+bx         ],al
   mov [es:di+bx+wrisir/4],al
   loop @nextpix1b
   @za1:

  {prava svisla cara}
   mov cx,[cs:offset @mysize];shl cx,2;add cx,2
   mov di,[cs:offset @levohore];mov ax,[cs:offset @mysize];shr ax,1;add di,ax;
   and word ptr [cs:offset @mysize],3;cmp word ptr [cs:offset @mysize],1;jnz @noinc;inc di;@noinc:
   mov al,[cs:offset @mycolor]
   or al,al;jnz @nextpix3b
   @nextpix3:{$ifdef setup}lodsb;{$endif}mov [es:di],al;add di,wrisir/4;loop @nextpix3
   jmp @za3
   @nextpix3b:mov [es:di],al;add di,wrisir/4;loop @nextpix3b
   @za3:

   jmp @99

{inc bit, set bit}
@incbitsetbit:
   push ax;push cx;push dx
   mov cl,[cs:offset @bit];inc cx;cmp cl,4;jc @ouk;mov cl,0;inc di;@ouk:mov [cs:offset @bit],cl
   mov ax,102h;shl ah,cl;mov dx,3c4h;out dx,ax
   pop dx;pop cx;pop ax
   ret

@bit:      db 0
@mybit:    db 0
@levohore: dw 0
@mysize:   dw 0
@mycolor:  db 0

   @99:
   pop ds
   end;


PROCEDURE Show(name:string);
const decode:array[2..57] of char=(
        '1','2','3','4','5','6','7','8','9','0','-','=',#0,
        #0,'Q','W','E','R','T','Y','U','I','O','P','[',']',#0,
        #0,'A','S','D','F','G','H','J','K','L',';','''',
        #0,#0,'\','Z','X','C','V','B','N','M',',','.','/',
        #0,#0,#0,' ');
      keyadd=256;
      panelvys16=10;
      panelsir4=40;
      tahlosir=20;
      tahlovys=20;
      tahlax=50;
      tahloy1=30;
      tahloy2=70;
      panelcolors=3;
      panelcolor:array[0..panelcolors] of byte=(0,0,0,20);
      lastpanelcolor:array[0..4] of byte=(18,19,20,19,18);
var   i,j,size:integer;
      psp:word;
      OutOf:byte;
      old_dotaznikkeypressed,lastkey,panely16,panelx4,mustahlo,fxtahlo:integer;
      levohore,bit,panelsize:word;
label 1,2,3,4,8,choosePageOrMenu,midbutton,rightbutton,leftbutton,noglobal,pan,closesetup;
begin

  mode13x;
  setbright(0);
  InstallMouse;
  setspeedofmouse;
  lastkey:=0;

{$ifdef midas}
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
  midasInit;                          { initialize MIDAS Sound System }
  tmrGetScrSync(PtmrScrSync);
  OutOf:=1;
  midasInitEffectChan;
  for i:=1 to samplu do loadsample(i);
  if modulu>0 then module:=midasPlayModule(ModuleNames[1],OutOf); { load module and start playing }
  midasMastervolume(volume);
{$endif}

{$ifndef debug}
  port[$21]:=irq;
{$endif}

{$ifdef setup}
  tree[1]:=firstscreen;
  tree[1].fl:='setup';
  now:=tree[1];
  PREPARESCREEN;
  i:=0;
  for size:=0 to setupsize do begin
    OfsofFrameInSetupbitmap[size]:=i;
    asm
      mov es,workseg;mov di,i
      mov ax,100;sub ax,size;mov si,ax;and si,7;shl si,10{2*wrisir};add si,wrisir/2;sub si,size
      shr ax,3;mov [cs:offset @nowfram8kpiece],ax;pusha;push ax;call reframe;popa
{storne levou svislou caru}
      mov cx,size;shl cx,2;jz @middlepoint
push ds;mov ds,framewriseg
     @nextbyte:
      movsb;add si,wrisir-1;test si,wrisir*8;jz @ouk;sub si,wrisir*8
      inc word ptr [cs:offset @nowfram8kpiece];pusha;push word ptr [cs:offset @nowfram8kpiece];call reframe;popa
      @ouk:loop @nextbyte
pop ds
{storne horni dve vodorovny cary}

{storne pravou svislou caru}

      jmp @99

@middlepoint:
      mov ax,0;stosw
      jmp @99

@nowfram8kpiece: dw 0

      @99:
      mov i,di
      end;
    end;
  deallocNowhandle;
  Reframe2setupems;
  asm
     {copy workseg 2 setup_ems}
      mov es,frameseg;push ds;mov ds,workseg;mov si,0;mov di,0;mov cx,32768;rep movsw;pop ds
      end;
{$endif}

  tree[1]:=firstscreen;
  tree[1].fl:=name;
  if name<>'' then goto 2;

  choosePageOrMenu:
{$ifdef midas}
  if odd(setup) then name:=pageStartup else name:=menuStartup;
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
{$ifdef debug}
  port[$21]:=irq;
{$endif}

{$ifdef midas}
  tmrSyncScr(tmrScrSync,@nop,@nop,@timerScrolling);
{$endif}

  repeat

  {----------keyof}if keyoff=0 then BEGIN

                   {............KEY PRESS............}
   i:=port[$60];
   case i of 71..73,75,77,79..81:else stillNumero:=0;end;
   if i=224 then begin
     repeat i:=port[$60] until i<>224;
     case i of 72,75,77,80:begin
                           inc(i,keyadd);
                           sipky:=10;
                           end
                      else i:=0;
                      end;
     end
    else
     if sipky>0 then case i of 72,75,77,80:inc(i,keyadd);end
                else case i of 71..73,75,77,79..81:inc(stillNumero);end;

   if sipky>0 then dec(sipky);

   case lastkey of keyadd+72,keyadd+75,keyadd+77,keyadd+80,71..73,75,77,79..81,14,83:lastkey:=0;end;
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
            69,76:begin presx:=now.mousex;presy:=now.mousey;goto leftbutton;end;
               55:begin presx:=now.mousex;presy:=now.mousey;goto rightbutton;end;
               53:begin presx:=now.mousex;presy:=now.mousey;goto midbutton;end;
               70:begin
                  if setuping then with toggle[{#}3] do begin
                    on:=1-on;
                    ano(y16,on);
                    if not setuping then ems2screenmouseoff(y16);
                    end;
                  asm {prehodi svetylko scrollock}
                      xor locks,1;xor setup,16;
                      {$ifdef midas}
                      call midaslightlocks;
                      {$else}
                      call lightlocks;
                      {$endif}
                      end;
                  end;

{$ifdef midas}
              2..11:if askstringu{nowask}=0 then begin
                    volume:=63*(key-2) div 9;
                    midasMastervolume(volume);
                    end else goto noglobal;
             59..68:if key-58<=modulu then begin
                    if module<>nil then midasStopModule(module);{ stop playing }
                    midasInitEffectChan;
                    3:
                    outof:=0;
                    module:=midasPlayModule(ModuleNames[key-58],outof); { load module and start playing }
                    if (outof=2) and FreeMoreConv then goto 3;
                    midasMastervolume(volume);
                    end;
{$endif}
               ELSE BEGIN noglobal:


   {DOTAZNIK KEYS}
   if {kdyz je jen 1 askstring, nepotrebuje sipky up/down}not ( (askstringu=1) and ((key=keyadd+80) or (key=keyadd+72)) )
     and (askstringu{nowask}>0) then begin
    if dotaznikkeypressed>0 then begin
      dec(dotaznikkeypressed);
      i:=askstring[nowask].y16;
      if (i<wriy+3) then nahoru(20) else if (i>wriy+31-5) then dolu(20) else dotaznikkeypressed:=0;
      end;
    if (key>0) then begin
     old_dotaznikkeypressed:=dotaznikkeypressed;
     dotaznikkeypressed:=250;
     mouseactive:=0;mouse(0);
     xorcursor(true);
     case key of
        keyadd+72:if nowask>1 then begin dec(nowask);nowaskx:=1;end;
     28,keyadd+80:if nowask<askstringu then begin inc(nowask);nowaskx:=1;end;
        keyadd+77:if nowaskx<askmaxlen then inc(nowaskx);
        keyadd+75:if nowaskx>1 then dec(nowaskx);
               14:if nowaskx>1 then with askstring[nowask] do begin {backspace}
                    dec(nowaskx);
                    for j:=nowaskx to askmaxlen-1 do str[j]:=str[j+1];
                    str[askmaxlen]:=' ';
                    end;
               83:with askstring[nowask] do begin {delete}
                    for j:=nowaskx to askmaxlen-1 do str[j]:=str[j+1];
                    str[askmaxlen]:=' ';
                    end;
            2..57:if (askstringu{nowask}>0) and (decode[key]>#0) then with askstring[nowask] do begin
                    for j:=askmaxlen downto nowaskx+1 do str[j]:=str[j-1];
                    str[nowaskx]:=decode[key];
                    if nowaskx<askmaxlen then inc(nowaskx);
                    end;
              else begin
                   dotaznikkeypressed:=old_dotaznikkeypressed;
                   goto 8;
                   end;
            end;
     i:=askstring[nowask].y16;
     OneAskString(nowask);
     if (i>=wriy) and (i<=wriy+31){neni mimo obraz} then ems2screen(i);
     8:
     xorcursor(true);
     mouse(1);mouseactive:=1;
     if old_dotaznikkeypressed=0 then case key of
         keyadd+72,keyadd+75,keyadd+77,keyadd+80:keyoff:=5;{sipky v askstringu}
                                           14,83:keyoff:=8;{back/delete v askstringu}
                                             end;
     end
    end

   else

   {NO_DOTAZNIK KEYS}
   if not setuping then case key of
               keyadd+80:dolu   (setrvacnost-1);
               keyadd+72:nahoru (setrvacnost-1);
               keyadd+77:if not odd(locks) then doprava(setrvacnost-1);
               keyadd+75:if not odd(locks) then doleva (setrvacnost-1);
               {15:inc(inlist,25);}
               end;

               END;
               END;


  {---------keyoff}END;


{$ifdef midas}           {.......SCROLLING.......}
{$else}
  timerScrolling;
{$endif}




                   {............MOUSE PRESS............}
   case presz of
                 0:;
                32:midbutton:if not setuping then begin
                     {OPEN SETUP PANEL}
                     {playsample}
                     setuping:=true;
                     mouseactive:=0;mouse(0);
                     panelcentrx4:=now.visx div 4+vissir div 8;
                     panelcentry:=now.visy+visvys div 2;
                     panelsize:=0;
                     Reframe2setupems;
                     for i:=1 to setupsize div 3 do begin
                       UniversalRefresh;
                       for j:=panelcolors downto 0 do CentralFrame(panelsize+j,panelcolor[j]);
                       inc(panelsize,3);
                       end;
                     for j:=4 downto 0 do CentralFrame(panelsize+j,lastpanelcolor[j]);
                     toggle2:=toggle;
                     togglu2:=togglu;
                     for togglu:=1 to 5 do with toggle[togglu] do begin
                       y16:=panelcentry div 16+2*togglu;
                       case togglu of 1:on:=setup shr 2 mod 2;{vga 1/2}
                                      2:on:=setup shr 3 mod 2;{keyboard 1/2}
                                      3:on:=setup shr 4 mod 2;{scrollock}
                                      4:on:=setup shr 5 mod 2;{fast scrolling}
                                      5:on:=setup shr 6 mod 2;{fast mouse}
                                      end;
                       ano(y16,on);
                       end;
                     getmouse(now.mousex,now.mousey,bit);
                     now.mousex:=now.mousex div 2;
                     mouse(1);mouseactive:=1;
                     buttonu2:=now.buttonu;    now.buttonu:=0;
                     askstringu2:=askstringu;  askstringu:=0;
                     presz:=0;
                     end
                   else begin closesetup:
                     {CLOSE SETUP PANEL}
                     mouseactive:=0;mouse(0);
                     for i:=(panelcentry-2*panelsize) div 16-1 to (panelcentry+2*panelsize) div 16+1 do
                       ems2screenFromx4Sir8(i,panelcentrx4-panelsize div 4-1,panelsize div 4+2);
                     mouse(1);mouseactive:=1;
                     toggle:=toggle2;
                     togglu:=togglu2;
                     now.buttonu:=buttonu2;
                     askstringu:=askstringu2;
                     setuping:=false;
                     presz:=0;
                     repeat until port[$60]<>1;
                     end;
(*
                   asm
                    {es:di=pocatecni adresa leveho horniho rohu panelu}
                     mov di,panely16;shl di,11{wrisir};add di,panelx4;mov levohore,di
                     mov es,sega000

                    {set all bits}
                     mov ax,0f02h;mov dx,3c4h;out dx,ax
                    {clr panel}
                     mov dx,panelvys16;shl dx,4
                     @nextline1:
                     push di
                     mov ax,257*19;mov cx,panelsir4;shr cx,1;rep stosw
                     pop di;add di,wrisir/4
                     dec dx;jnz @nextline1

                    {grafika fx & mus}
                     mov di,levohore
                     mov bit,3
                    {set bit}
                     @nextbit:
                     mov ax,102h;mov cx,bit;shl ah,cl;mov dx,3c4h;out dx,ax
                     lea si,3+fxmapka;sub si,bit
                    {copy one bitplane}
                     mov dx,fxmapkavys
                     mov di,levohore
                     @nextline2:
                     push di
                     mov cx,fxmapkasir4;@nextpix:movsb;add si,3;loop @nextpix
                     pop di;add di,wrisir/4
                     dec dx;jnz @nextline2
                    {loop 4 bits}
                     dec bit;jns @nextbit
                     end;*)
(*
                   {ovladani panelu}
                   pan:
                   presz:=0;
                   repeat until presz>0;
                   if (presz and 2)>0 then begin
                     if (presx>=panelx4*4+tahlax+mustahlo) and (presx<panelx4*4+tahlax+mustahlo+tahlosir) and
                        (presy>=panely16*16+tahloy1) and (presy<panely16*16+tahloy1+tahlovys) then begin
                          {touch mustahlo}
                          repeat
                           {smaz old tahlo}

                           mustahlo:=presx-panelx4*4-tahlax;
                           if mustahlo<0 then mustahlo:=0 else
                           if mustahlo>63 then mustahlo:=63;
                           {$ifdef midas}
                           midasMastervolume(mustahlo);
                           {$endif}
                           {kresli new tahlo}

                          until (presz and 4)>0;
                          end;
                     end;
                   if presz<4 then goto pan;
  *)
                 8:begin
                   rightbutton:
                   if setuping then goto closesetup;
{$ifdef midas}
                   Playsample(sam_goback);
{$endif}
                   if not odd(setup) then begin{--MENU BACK--}
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
                       SaveAnketa;
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
                   for i:=1 to togglu do with toggle[i] do if y16=j then begin
{$ifdef midas}
                            case i of {#}18,19,23,27,34:Playsample(sam_blbce);
                                       else Playsample(sam_togl);
                                       end;
{$endif}
                            on:=1-on;
                            mouseactive:=0;mouse(0);
                            ano(y16,on);
                            if not setuping then ems2screen(y16);
                            mouse(1);mouseactive:=1;
                            if setuping then case i of
                              {#}
                              1:setup:=setup xor 4;{vga 0/1}
                              2:begin
                                setup:=setup xor 8;{keyb 0/1}
                                kbport:=kbport xor 4;
                                end;
                              3:begin
                                setup:=setup xor 16;{scrollock}
                                locks:=locks xor 1;
                                lightlocks;
                                end;
                              4:setup:=setup xor 32;{fast scrolling}
                              5:begin
                                setup:=setup xor 64;{fast mouse}
                                setspeedofmouse;
                                end;
                              end;
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
                   if not odd(setup) then begin{--MENU FORWARD--}
                    if password>0 then goto 4;
                    for i:=1 to now.buttonu do with now.bu[i] do
                     if (now.visx+presx>x1) and (now.visx+presx<x2) and (now.visy+presy>y1) and (now.visy+presy<y2) then begin
                      4:
                      {$ifdef midas}playsample(sam_goon);{$endif}
                      tree[intree]:=now;
                      inc(intree);
                      tree[intree]:=firstscreen;
                      tree[intree].fl:=now.bu[i].fi;
                     {hidden part}
                      case password of 2:tree[intree].fl:='hidden';
                                       1:tree[intree].fl:='redakce';
                                       end;
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
                 else if {*(name<>setupStartup) and} (now.fl<>fileAnketa) then begin{--LIST FORWARD--}
{$ifdef midas}
                      tmrStopScrSync;
                      playsample(sam_goon);
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

   UniversalRefresh;

  until key=1;
  if setuping then begin key:=0;goto closesetup;end;
  SaveAnketa;
{$ifdef midas}
  tmrStopScrSync;
  playsample(sam_konec);
  for i:=63 downto 0 do begin
    setbright(4*i);
    midasMastervolume(volume*i div 64);
    refresh(2);
    end;
{$else}
  brightdown;
{$endif}
  RemoveMouse;
  EMSDone;
  port[$21]:=0;
end;


{€€€ﬁﬁﬁ›ﬁ‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹ E D I T O R ‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹}
{$ifdef editor}

PROCEDURE SaveEditorFile;assembler;
var edhandle:word;
 asm
   cmp edzmena,0;jz @9
  {open}
   mov ah,3ch;mov dx,offset edfajl+1;mov cx,0;int 21h
   mov edhandle,ax
  {write data}
   mov bx,edhandle;mov cx,edtextlast;sub cx,offset header-1;lea dx,header;mov ah,40h;
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
      line1:string[le]='   …ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ Edit ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕª   ';
      line2:string[le]='   ∫  You''ve made changes since the last save. ∫   ';
      line3:string[le]='   ∫    Save   Don''t save   Continue editing   ∫   ';
      line4:string[le]='   »ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº   ';
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
var i,x1,x2,le,le1,le2:word;
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

 {sirka ramecku}
 le:=maxlen;
 le1:=length(veta);
 le2:=length(veta2);
 if le1>le then le:=le1;
 if le2>le then le:=le2;

 x1:=shiftSetvis+(80-le) div 2;
 x2:=shiftSetvis+(80-maxlen) div 2;
 store(x1,y13,le,3);
 textattr:=16+11;
 gotoxy(x1,y13);for i:=1 to le do write(' ');gotoxy(x1+(le-length(veta )) div 2,y13);write(veta);
 gotoxy(x1,y14);for i:=1 to le do write(' ');gotoxy(x1+(le-length(veta2)) div 2,y14);write(veta2);
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
var i,doublescan,halve_x:byte;
    code1,code2:word;
    st:string;
    anylong:longint;
label ex;
begin
 doublescan:=2;halve_x:=1;
 if nejm[1]='.' then halve_x:=2;
 case nejm[1] of '.','-':begin doublescan:=1;nejm:=copy(nejm,2,200);end;end;
 for i:=1 to picu do with picsizes[i] do if nejm=name then goto ex;
 for i:=1 to picu do with picsizes[i] do if x=0 then begin
  name:=nejm;
  if opendatafile(nejm)=0 then
    repeat
     st:=ask('Obr†zek '+nejm+' nenalezen. ûekni mi aspo§ p©ibliënà jak je velkò.',8,'320x200','0');
     i:=pos('x',st);
     val(copy(st,1,i-1),x,code1);
     val(copy(st,i+1,255),y,code2);
    until code1+code2=0
   else begin
    ReadDataFile(4,ofs(x),seg(x));
    CloseDataFile;
    end;
  ex:
  xx:=x div halve_x;
  yy:=y*doublescan;
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
 if edtext[edi]=' ' then inc(edi);
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
var   str:array[0..maxfajlu] of string[14];
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
  str[i]:=t.name;
  for j:=1 to length(str[i]) do case str[i,j] of 'A'..'Z':str[i,j]:=chr(ord(str[i,j])+ord('a')-ord('A'));end;
  if i<maxfajlu then inc(i);
  findnext(t);
  end;
end;

label 1,2,3;
Begin
 i:=0;
 findall(typ);
 findall('x\'+typ);
 fajlu:=i-1;
 if fajlu=-1 then begin fileselect:=ask(veta,20,'','!');exit;end;

 {sort}
 repeat
  j:=0;
  for i:=0 to fajlu-1 do if str[i]>str[i+1] then begin inc(j);st:=str[i];str[i]:=str[i+1];str[i+1]:=st;end;
 until j=0;

 for i:=fajlu downto 0 do if preselect=str[i] then goto 1;1:
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
   for j:=0 to fajlu do begin gotoxy(x1+j div 20*13,4+j mod 20);write(str[j]);end;
   textattr:=15;              gotoxy(x1+i div 20*13,4+i mod 20);write(str[i]);
   gotoxy(60,1);write(st,'         ');
   gotoxy(60+length(st),1);
   ch:=readkey;
   case ch of #75:begin dec(i,20);keyb:=false;end;
              #77:begin inc(i,20);keyb:=false;end;
              #72:begin dec(i);   keyb:=false;end;
              #80:begin inc(i);   keyb:=false;end;
              'G':begin i:=0;     keyb:=false;end;
              'O':begin i:=fajlu; keyb:=false;end;
              'I':begin i:=i   -i mod 20;keyb:=false;end;
              'Q':begin i:=i+19-i mod 20;if i>fajlu then i:=fajlu;keyb:=false;end;
              '!'..'z'{,'.','-','_','!','0'..'9'}
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

PROCEDURE MoveTxtMouse(x,y:word);assembler;{nastaveni polohy M-x-y}
 asm mov ax,4;mov cx,x;shl cx,1;mov dx,y;int 33h;end;

PROCEDURE GetMouseChange(var x,y:integer);
var i,j:integer;
begin
 asm mov ax,0bh;int 33h;mov i,cx;mov j,dx;end;
 x:=i div 2;
 y:=j;
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
     mov ax,13*256+'⁄';stosw
     mov al,'ƒ';stosw
     mov al,sloupcu;add al,48;inc ah;stosw;dec ah
     mov al,'ƒ';mov cx,k;rep stosw
    mov ah,1;
     mov bl,otec;and bl,1;mov al,'⁄';jnz @down1;mov al,'¿';@down1:stosw
     mov al,otec;inc al;shr al,1;add al,48;stosw
     mov bl,otec;and bl,1;mov al,'ø';jnz @down2;mov al,'Ÿ';@down2:stosw
    mov ah,13
     mov al,'ƒ';stosw
     mov al,'ø';stosw
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
       mov ax,13*256+'¿';stosw
       mov al,'ƒ';stosw
       mov al,sloupcu;add al,48;inc ah;stosw;dec ah
       mov al,'ƒ';mov cx,k;rep stosw
       mov al,'Ÿ';stosw
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
        textbox(pixStart div pixMinicharsir,ii,pixLen div pixMinicharsir,1,ord('€')+256*7);
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
        TextBox((pixMid-i div 2) div pixMinicharsir,ii,i div pixMinicharsir,j div 16,ord('±')+256*7);
        inc(ii,j div 16);
        asm mov al,wlcol;push ax;mov wlcol,7;end;
        WriteLine(ii-j div 32-1);
        asm pop ax;mov wlcol,al;end;
        end;
      INSBIGCHAR,INSBUTTON:begin
        ch:=edtext[edi];
        c2:=edtext[edi+1];
        inc(edi,2);
        case c2 of 'A'..'Z':begin size:=8;end;
                   'a'..'z':begin size:=4;c2:=chr(ord(c2)+ord('A')-ord('a'));end;
                   end;
        if edtext[edi]='-' then size:=2;
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
 until edi>edtextlast;
 Patka;

 {zkopci to do screenu}
 asm push ds;mov es,segb800;mov ds,workseg;mov si,0;mov di,0;mov cx,16384;rep movsw;pop ds;end;

 if 1+iimax<>ReadInteger(ofs(header)) then edzmena:=1;
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

PROCEDURE MoovMouse(x,y:word);assembler;asm mov ax,4;mov cx,x;mov dx,y;int 33h;end;

PROCEDURE EDITOR;
const hod:array[0..106] of char=
        {kniha}#37+
        #13#10#13#10'intelektu†ln° £rove§, estetickò z†ëitek'#13#10+insbigchar+'c*****#'+
        #13#10#13#10'napàt°, átivost, Mark Stone index'#13#10+insbigchar+'c*****#'#13#10#13#10#0;
      hod2:array[0..170] of char=
        {hra}#20+
        #13#10#13#10+mramor+''#13#10+tabulka+'tvñrce: '#13#10+'status: '#13#10+'testov†no na: '+
        #13#10'existuje je®tà na: '#13#10'velikost: '#13#10'poëadavky na poá°taá: '#13#10+'grafika: '+
        #13#10'zvuk: '#13#10#13#10+'grafika: %'#13#10'hudba: %'#13#10'z†bava: %'#13#10#13#10+insbigchar+'c*****#'#13#10#13#10#0
        ;
var   i,j:word;
      m,n:integer;
      special:byte;
      ch:char;
      st:string;
      st8:string[8];
   {help}
      f:text;
      kurzor,k,l:word;
      radek,textbarva:byte;
const nowhelpvis:word=0;

label 0,1,2,3,4,5,6,7,8,10,newodst;
Begin
 for i:=1 to picu do picsizes[i].x:=0;
 edfajl:='';
 0:{new file}
 if pos('.',edfajl)>0 then edfajl[0]:=chr(pos('.',edfajl)-1);
 edfajl:=fileselect('Zadej pracovn° jmÇno ál†nku...','*.',edfajl);

 if length(edfajl)=0 then errorhalt(0);
 if pos('.',edfajl)=0 then edfajl:=edfajl+'.';
 edfajl[length(edfajl)+1]:=#0;
 ednowi:=edtextofs;
 setvis(shiftsetvis);
 lasttextvis:=shiftsetvis;
 nowSloupec:=1;
 blokstart:=0;
 blokend:=0;
 blokon:=false;
 4:
 {precte text.soubor}
 MoveTextFile2EdText(edfajl);

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

{---------START HELP--------}
assign(f,'editor.hlp');reset(f);
if ioresult>0 then ask(#13' Chyb° helpfajl... Cos s nim proved ? ',0,'',' ') else
begin
asm{clrscr}mov di,0;mov es,segb800;mov ax,7*256+32;mov cx,16384;rep stosw
   {move kurzor}mov ah,2;mov bh,0;mov dx,0ff01h;int 10h
   end;
setvis(80*150);
kurzor:=0;radek:=0;
i:=ofs(st);
while not eof(f) do begin
  inc(radek);
  readln(f,st);
  if st[1]='.' then begin textbarva:=10;st[1]:=' ';end else
  if radek>5 then textbarva:=7 else textbarva:=14;
  asm mov ax,0b800h;mov es,ax;mov si,i;mov di,kurzor;mov cl,[ss:si];cmp cl,0;jz @9;mov ch,0;inc si;mov ah,textbarva
      @nextchar:segss lodsb;cmp al,':';jnz @not;mov ah,7;@not:stosw;loop @nextchar;
      @9:add kurzor,2*80;
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
 if j shr 3>nowhelpvis+24 then inc(nowhelpvis);
 if keypressed then begin
   l:=nowhelpvis;
   ch:=readkey;
   case ch of 'H':if nowhelpvis>0 then dec(nowhelpvis);
              'P':if nowhelpvis+25<radek then inc(nowhelpvis);
              'I':if nowhelpvis>24 then dec(nowhelpvis,24) else nowhelpvis:=0;
              'Q':if nowhelpvis+24+25<radek then inc(nowhelpvis,24) else nowhelpvis:=radek-25;
              'G':nowhelpvis:=0;
              'O':nowhelpvis:=radek-25;
              end;
   moovmouse(i,j+8*(nowhelpvis-l));
   end;
 setvis(80*nowhelpvis);
until (k>0) or (ch=#27);
asm {mouseoff}mov ax,2;int 33h;end;
end;
{---------END HELP---------}
                  setvis(lasttextvis);
                  goto 1;
                  end;
{f2=save}     #60:SaveEditorFile;
{f3=save&show}#61:if frameseg=0 then ask(#13' Sorry, nemas zadnou EMS ',0,'',' ') else
                  if texturhandle=0 then ask(#13' Sorry, mas zatracene malo EMS ',0,'',' ') else
                  begin
                   SaveEditorFile;
                   Show(edfajl);
                   txmode(mode,0);
                   setvis(lasttextvis);
                   while keypressed do readkey;
                   delay(200);
                   goto 4;
                  end;
{f4=import}   #62:begin
                  st:=fileselect('Textovò soubor, kterò sem chce® vloëit','*.*','');
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
                  st:=fileselect('JmÇno ál†nku na kterò se odkazuje®...','*.','');
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
                  st:=fileselect('Zadej jmÇno obr†zku *.X','*.x','');
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
                 {uprava ednowi}
                  case edtext[ednowi] of inspic,mramor,tabulka:inc(ednowi);
                                          insbigchar,insbutton:inc(ednowi,2);
                                         end;
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
                  {if edtext[edi]=' ' then inc(edi);}
                  end;
{---------------OSTATNI-----------------}
 {tabulka}#37,#20:begin
                  i:=0;while hod[i]<>ch do inc(i);inc(i);
                  while hod[i]<>#0 do begin inc(edtextlast);edtext[edtextlast]:=hod[i];inc(i);end;
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
{alt-w chgcol}#17,#16:begin
                  edi:=veryStartLine;
                  if (edtext[edi]=insbigchar) or (edtext[edi]=insbutton) then begin
                    if edtext[edi+1]<'a' then i:=ord('A') else i:=ord('a');
                    st:=ask('Jakou barvu ? (a,A,b,B...'+chr(ord('A')+bx)+') (velkò p°smeno=vàt®° n†pis)'#13+
                            'c,g=modr† d,h=zelen† e,i=áerven† f,j=ëlut†)',1,edtext[edi+1],'A');
                    if st[0]=#1 then begin
                      edtext[edi+1]:=st[1];
                      edzmena:=1;
                      goto 1;
                      end;
                    end;
                  end;
{alt-p pozadi}#25:begin
                  st:=ask('Zadej typ backgroundovÇ textury (a..b)'#13+
                          'a jej° barvu (0..7)',2,header[h_textura]+header[h_barvapozadi],'0');
                  if (st[0]=#2) and ((st[1]<>header[h_textura]) or (st[2]<>header[h_barvapozadi])) then begin
                    header[h_textura    ]:=st[1];
                    header[h_barvapozadi]:=st[2];
                    edzmena:=1;
                    end;
                  end;
{alt-s svetlost}#31:begin
                  st:=ask('Zadej svàtlost pozad° (0..9)'#13+
                          '0 - nejtmav®°, 9 - nejsvetlej®°',1,header[h_svetlost],'0');
                  if (st[0]=#1) and (st[1]<>header[h_svetlost]) then begin
                    header[h_svetlost]:=st[1];
                    edzmena:=1;
                    end;
                  end;
{alt-f flags} #33:begin
                  j:=ord(header[h_flags]);
                  st8[0]:=#8;
                  for i:=1 to 8 do st8[i]:=chr((j shr (8-i)) mod 2+48);
                  st:=ask('Flags: -,-,-,-,-,-,-,barevnÇ r†meáky'#13+
                          ' Zat°m je vyuëit pouze posledn° bit, ostatn° nemà§ ! ',8,st8,'0');
                  if (st[0]=#8) and (st<>st8) then begin
                    j:=0;
                    for i:=1 to 8 do j:=2*j+ord(st[i])-48;
                    header[h_flags]:=chr(j);
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
  InitDataFile;

{$ifdef midas}
  midasSetDefaults;                   { set MIDAS defaults }
  midasParseEnvironment;              { parse MIDAS environment string }
  midasParseOptions(1, ParamCount);   { let MIDAS parse all options }
{$endif}

{$ifdef lookforlastsetup}
  if (setup=0) and enabledlookingforlastsetup then begin
   writeln(#13#10#13#10#13#10'Hledam Pareniste 2, abych si z nej vycuc tvuj setup. Dobry, ne ?');
   writeln('A sem natolik inteligentni rutina, ze tohle ani nestihnes precist');
   writeln('a uz to najdu... Hej, vo co ti gou, tohles prece nemoh stihnout');
   writeln('precist... Nesahej mi na pause nebo ti ho v pristim cisle disabluju...');
   writeln('A ty, co to ctes ve Volkovu, taky necti, nebo to priste zaDIETim...');
   writeln('To uz by stacilo, vypadni... a uzij si to tam... sak sme se snazili... baj.');
   writeln(#13#10'A propo, jestli ti to ted uplne nahodou zatuhlo :), spust pareni03 -x');
   asm

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
    cmp byte ptr [di-6],'3';jnz @notfoundhere
    mov byte ptr [di-6],'2'
   {try to open pareni02.exe}
    mov ax,3d02h;mov dx,offset edtextbody;int 21h;jnc @found
    @notfoundhere:

{-----prohleda current dir-----}
   {try to open pareni02.exe}
    mov ax,3d02h;mov dx,offset lastparfilename+2;int 21h;jnc @found

{-----prohleda current dir\..\par*.*\-----}
   {get current dir to (+0)}
    mov byte ptr [offset edtextbody],'\'
    mov ah,47h;mov dl,0;mov si,offset edtextbody+1;int 21h
    push ds;pop es;mov di,offset edtextbody;mov al,0;mov cx,1000;repne scasb;dec di
   {o lomitko zpatky}
    @nextbyte2:dec di;cmp di,offset edtextbody;jc @notfound;cmp byte ptr [di],'\';jnz @nextbyte2
    mov j,di{adresa znaku \ pred current adresarem}
   {vrazi tam 'par*'#0}
    mov ax,'p\';stosw;mov ax,'ra';stosw;mov ax,'.*';stosw;mov ax,'*';stosw;
   {set DTA}
    mov ah,1ah;mov dx,offset edtextbody+1000;int 21h
   {findfirst dir (+0)}
    mov ah,4eh;mov dx,offset edtextbody;mov cx,0ffffh;int 21h;jc @notfound;jmp @checkdir
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
    mov si,offset edtextbody+1000+1eh;mov di,j;add di,2001
    mov cx,13;@nextbyte5:lodsb;stosb;or al,al;loopnz @nextbyte5;dec di
   {copy pareni02.exe to fullstring(+2000)}
    mov si,offset lastparfilename;lodsb;mov ah,0;mov cx,ax;rep movsb;
   {try to open fullstring(+2000)}
    mov ax,3d00h;mov dx,offset edtextbody+2000;int 21h;jnc @found
    jmp @findnextdir

    @found:
    mov i,ax
   {read exe header}
    mov bx,i;mov cx,1bh;mov dx,offset header;mov ah,3fh;int 21h;
   {precte z headeru setup byte}
    mov al,[offset header+1ah];mov setup,al
   {close pareni02.exe}
    mov bx,i;mov ah,3eh;int 21h;
    @notfound:
   end;
  end;
{$endif}




  edtextofs:=ofs(edtextbody);
  headerofs:=ofs(header);
  randomize;
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
  PrepareMiniFont;
{$ifdef pareniste}
  if frameseg=0 then errorhalt(2);
  if texturhandle=0 then errorhalt(3);
{$endif}

{$ifdef setup}
  if setuphandle=0 then errorhalt(3);
{$endif}

{$ifdef editor}
  editor;
{$else}
  {if setup and 2=0 then Show(setupStartup) else }Show('');
{$endif}

  errorhalt(0);
END.

SETUP BITS
 0  1 - menu
 1  2 - preskocit setup page
 2  4 - vga type 2
 3  8 - keyboard type 2
 4 16 - scrollock
 5 32 - fast scrolling
 6 64 - fast mouse

TEXT HEADER
ofs len meaning
 0   3  celkem radek v clanku
 3   1  barva pozadi
 4   1  textura na pozadi
 5   3  starting visx
 8   3  starting visy
12   1  jas pozadi
13   1  flags
14   5  unused
19   2  CR/LF

FLAGS
bit  meaning if set


mys se zasekava pri prudkym pohybu za okraj stranky
kdyz nenajde zadny sound, poskodi system a Pascal se haltne

quick jump - vyber stranky ze seznamu
           - zrusit tree, intree

clickable words - vyhodi ramecek s textem k zvyraznenymu slovu

cukani pri scrollingu a pohybu mysi


quick setup (mid but):
  nota vol
  FX vol
  background bright
  text bright
  picture bright
