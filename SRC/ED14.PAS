{$R-,S+,I-,E-,N-,M 7000,30000,30000}  {*max S3M size}

{$define textinsid}
{$define datainsid}
{$define mida}
{$define editor}

{$ifdef editor}
 uses crt,dos;
{$endif}

{$ifdef midas}
 uses midas;
{$else}
{$endif}

CONST irq=2;
      edtextofs=5354;
      edtextmax=edtextofs+10000;
VAR   header:array[1..6] of char;
      edtext:array[edtextofs..edtextmax] of char;

 {$I nazvy.inc}
 {$i font.inc}
 {$i sipka.inc}
 {$I f:\-ostatn0\bigfont.inc}

{$ifdef midas}
 const module:pointer=nil;
{$else}
{$endif}

{$ifdef textinside}
 {$i text.inc}
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
 const maxlines=250;
       txsir=80;
       txvys:byte=25;
       txsirtxvys:word=80*25;
       mode:byte=0;
 var   edofs,scrx,scry:array[0..maxlines-1] of word;
       edfajl:string[13];
       ednowx,ednowy,ednowi:word;
       linetotal,linenow:word;
       lasttextvis:word;
       wlcha:char;
       wlcol,nowsloupec,edzmena,otec:byte;
{$else}
{$endif}

CONST startup='main.';
      wrisir=512;
      wrivys=512;
      vissir=360;
      visvys=464;
      mysiokraj=20;
      inspic='~';
      chgcol='`';
      insbigchar='|';
      insbutton='';
      newsloupec='^';
      mramor='ß';
      tabulka='ì';
      lastchar='©';
      mouseactive:byte=1;
      mouseflag:byte=0;
      setrvacnost=20;
      sunindex:byte=0;
      intree:byte=1;
      maxbuttonu=10;
      exeleng:longint=0;
      usedcols:byte=1;
      txtcols:array[1..6,0..2] of byte=(
        (30,30,63),
        (30,63,30),
        (63,30,30),
        (63,63,30),
        (63,30,63),
        (30,63,63));
      mixcols:array[0..3] of word=
        (256*7+8,256*16+12,
        256*15+16,256*19+20);


VAR   presx,presy,presz,
      workseg,frameseg,fogseg,bigfontseg,
      wriy,fileadr,datahandle,
      Wmezer, Wodsaz, Wodcentr, Wsirmez, Wtoedi, Wnewedi,
      pixStart,pixLen,pixMid,pixMinicharSir,pixOdsaz,
      ofsst,framewriseg,wordX,
      lastvisx,lastvisy,
      edtextlast,edi,
      mixword,minifnt,
      shadowvis                  :WORD;

      hlavapat,sloupcu           :SHORTINT;

      lowcol,hicol,key           :BYTE;

      st                         :STRING;

      minifont:array[' '..lastchar,0..15,0..7] of byte;
      PropSir:array[' '..lastchar] of byte;
      sunx,suny:array[0..setrvacnost-1] of shortint;
      pal:array[0..767] of byte;
      hlavapata:array[-1..18] of record x1,y16,oedi,firstline:word;end;
      sloupce:array[0..9] of record x1,y16,firstedi,firstline,xx1,yy16,lastedi,lastline:word;end absolute hlavapata;

      head:word absolute 0:$41a;
      tail:word absolute 0:$41c;

CONST lenfont=sizeof(minifont);

{----popis screenu----}
TYPE  TPopisScreenu=record
                      radek,handle,mousex,mousey:word;
                      visx,visy:integer;
                      buttonu:byte;
                      bu:array[1..maxbuttonu] of record x1,y1,x2,y2:word;fi:string[13];end;
                      fl:string[13];
                      end;
CONST FirstScreen:tpopisscreenu=
        (radek:0;handle:0;mousex:256;mousey:220;visx:(wrisir-vissir) div 2;visy:0;buttonu:0);
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

 case n of 1:write('Pot©ebuju v°c konvenán° pamàti.');
           2:write('Pot©ebuju EMM, QEMM nebo tak nàjak.');
           3:write('Pot©ebuju v°c EMS pamàti.');
           4:write('Pot©ebuju my® a driver.');
           6:write('Nena®el jsem nàjakò soubor...');
           7:write('Nena®el jsem s†m sebe. Spusü mne z mÇho adres†©e.');
           8:write('Nesouhlasi offset textu ! (interni chyba) ofs=',ofs(edtext));
           9:write('Nenalezen text, ktery mel byt inside ! (interni chyba)');
          10:write('Sorry, text je moc dlouhò.');
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
   {test if present}mov ax,4000h;int 67h;cmp ax,0;jz @2;push 2;call errorhalt;@2:
   {get emm frame}mov ax,4100h;int 67h;mov frameseg,bx
 {----CONV----}
   mov bx,65536/16;call alloc;mov fogseg,ax
   mov bx,65536/16;call alloc;mov workseg,ax
   end;


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
const low:array[0..3] of byte=(2,2,2,2);
      hi :array[0..3] of byte=(4,4,4,4);
begin
 case n of 0:{grey} for i:=0 to 47 do pal[3*usedcols+i]:=6+i div 5;
           1:{red}  for i:=0 to 47 do pal[3*usedcols+i]:=(3+i div 3+((i+2) mod 3 shr 1)*abs(40-i));
           2:{green}for i:=0 to 47 do pal[3*usedcols+i]:=(3+i div 3+((i+1) mod 3 shr 1)*(40-i));
           3:{blue} for i:=0 to 47 do pal[3*usedcols+i]:=(3+i div 3+( i    mod 3 shr 1)*abs(40-i));
           end;
 lowcol:=low[n];
 hicol:=hi[n];
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
    mov ax,3d00h;mov dx,di;int 21h
    pop ds
    mov vzdyhand,ax
    jnc @ok1;push 7;call errorhalt;@ok1:
   {read exe header}
    mov bx,vzdyhand;mov cx,6;mov dx,offset header;mov ah,3fh;int 21h;
   {pocita dylku exe fajlu}
    cmp word ptr [offset header],'ZM';jnz @notexe
    mov ax,[offset header+4];dec ax;shl ax,1;mov bl,ah;shl ax,8;add ax,[offset header+2]
    mov [offset exeleng],ax;mov [offset exeleng+2],bx
    @notexe:
   {open pikcr fajl}
    mov ax,3d00h;mov dx,offset nekdyfile+1;int 21h;
    jc @nodatafajl;mov nekdyhand,ax;@nodatafajl:
{$else}
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
var i:byte;
begin
{$ifdef textinside}
 if st[ord(st[0])]='.' then dec(st[0]);
 for i:=1 to textfajlu do if st=nazevtextu[i] then begin
   move(mem[cseg:adresatextu[i]],header,delkatextu[i]);
   edtextlast:=ofs(header)+delkatextu[i];
   SetBackPal(ord(header[4])-48);
   exit;
   end;
 errorhalt(9);
{$else} 
 {precte textfajl pokud existuje, kdyztak mu vytvori i header}
 if OpenDataFile(st)=0 then EdTextLast:=edtextofs else begin
   edtextlast:=ofs(header)+ReadDataFile(65535,ofs(header),seg(header));
   CloseDataFile;
   end;
 {na zacatek fajlu da header}
 if (header[5]<>#13) or (header[6]<>#10) then begin
   move(header,edtext,edtextlast-ofs(header));
   if edtextlast>edtextofs then inc(edtextlast,ofs(edtext)-ofs(header));
   header[4]:='0';
   header[5]:=#13;
   header[6]:=#10;
   end;
 {na konec fajlu da CR/LF}
 if (edtextlast=edtextofs) or (edtext[edtextlast-1]<>#10) then begin
   edtext[edtextlast]:=#13;
   edtext[edtextlast+1]:=#10;
   inc(edtextlast,2);
   end;
 SetBackPal(ord(header[4])-48);
{$endif}
end;



{   €€€ -------  BIG FONT ------- €€€ }


CONST vys=128;
      sir=64;
      obtahbase=1;
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
  q:=minifont[zn,y,x] div 3;
end;
Begin
 {clr chara}
 asm mov ax,ds;mov es,ax;lea di,chara;mov cx,sir*vys/8/2;mov ax,0;rep stosw;end;

 for j:=0 to vys shr 3-1 do for i:=0 to sir shr 3-1 do begin
   z:=tab[2*(2*(2*(2*(2*(2*(2*(2*
      q(i-1,j+1)+q(i,j+1))+q(i+1,j+1))+q(i-1,j))+q(i,j))+q(i+1,j))+q(i-1,j-1))+q(i,j-1))+q(i+1,j-1)];
   case size of 2:for k:=0 to 7 do chara[8*j+k,i]:=b[z-210,k];
                1:for k:=0 to 3 do begin
                   l:=b[z-210,2*k] or b[z-210,2*k+1];
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

PROCEDURE FillBigChar;
var i:word;

procedure zleva(n:byte);assembler;
 asm  mov al,sir;mul n;add ax,offset sha+16;mov si,ax;
      mov cx,64;mov ah,0
      @1:
      cmp byte ptr [si],0;jnz @neprazdny
      cmp byte ptr [si-1],fillbase;jz @fillit
      cmp byte ptr [si-1],obtahbase;jnz @neprazdny
      cmp byte ptr [si-2],0;jnz @neprazdny
      cmp byte ptr [si-3],0;jnz @neprazdny
      @fillit:
      mov di,si;@dolu:mov byte ptr [di],fillbase;add di,sir;cmp byte ptr [di],0;jz @dolu;
      mov di,si;@horu:mov byte ptr [di],fillbase;sub di,sir;cmp byte ptr [di],0;jz @horu;
      @neprazdny:
{mov byte ptr [si-1],4;{}
      inc si
      loop @1
      @9:
      end;

begin

 {shora dolu}
 for i:=0 to sir-1 do
  asm lea si,sha;add si,i;
      mov dx,vys-2;mov ah,0
      @1:
      cmp byte ptr [si],0;jz @bezezmeny
      cmp byte ptr [si+sir],obtahbase;jnz @zmena
      jmp @9{
      add si,sir
      cmp byte ptr [si+sir],obtahbase;jnz @zmena
      cmp byte ptr [si],obtahbase;jz @9}
      @zmena:
      xor ah,fillbase
      jmp @za
      @bezezmeny:
      mov [si],ah
      @za:
      add si,sir
      dec dx;jnz @1
      @9:
      end;

 {zdola nahoru}
 for i:=0 to sir-1 do
  asm lea si,sha+sir*(vys-1);add si,i;
      mov cx,vys-2;mov ah,0
      @1:
      cmp byte ptr [si],0;jz @bezezmeny
      cmp byte ptr [si],fillbase;jz @9
      cmp byte ptr [si-sir],obtahbase;jnz @zmena
      jmp @9{
      sub si,sir
      cmp byte ptr [si-sir],obtahbase;jz @9}
      @zmena:
      xor ah,fillbase
      jmp @za
      @bezezmeny:
      mov [si],ah
      @za:
      sub si,sir
      loop @1
      @9:
      end;

 {zleva doprava}
 for i:=3 to vys-3 do if i mod 2=0 then zleva(i);
{ zleva(2*26);
 zleva(2*31);
 zleva(2*36);
 zleva(2*43);}

end;

procedure OBTAH1;assembler;
 asm mov si,offset sha;mov di,offset b1;mov cx,sir*vys;mov al,obtahbase;mov bx,0
  @2:cmp [si],al;jnz @1;inc bx;mov [di],si;inc di;inc di;@1:inc si;loop @2;mov obtahu,bx;end;

procedure OBTAH2(cil:byte);assembler;
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

PROCEDURE ChgCols(inside,obtah:byte);assembler;
 asm lea si,sha
     mov cx,sir*vys
     mov ah,obtah
     @1:lodsb;cmp al,obtahbase;loopnz @1;jcxz @8;mov [si-1],ah;jmp @1
     @8:
     lea si,sha
     mov cx,sir*vys
     mov ah,inside
     @2:lodsb;cmp al,fillbase;loopnz @2;jcxz @9;mov [si-1],ah;jmp @2
     @9:
     end;


   { MMMMMMMMMM-------  other -------MMMMMMMMMMM }

PROCEDURE Refresh(n:byte);assembler;
 asm mov ch,0;mov cl,n;@2:mov dx,3dah;in al,dx;shr al,4;jc @2; @5:mov dx,3dah;in al,dx;shr al,4;jnc @5;loop @2;end;
PROCEDURE Refresh2(n:byte);assembler;
 asm mov ch,0;mov cl,n;@2:mov dx,3dah;in al,dx;shr al,4;jnc @2; @5:mov dx,3dah;in al,dx;shr al,4;jc @5;loop @2;end;
PROCEDURE SetColor(color,r,g,b:byte);assembler;
 asm mov dx,3c8h;mov al,color;out dx,al;inc dx;mov al,r;out dx,al;mov al,g;out dx,al;mov al,b;out dx,al;end;
PROCEDURE SetBright(n:byte);assembler;
 asm mov si,offset pal;mov dx,3c8h;mov al,0;out dx,al;inc dx;mov cx,300h;mov bl,n
     @1:lodsb;mul bl;mov al,ah;out dx,al;loop @1;end;
{$ifdef editor}
PROCEDURE BrightUp;var i:byte;begin for i:=1 to 15 do begin refresh(1);setbright(16*i);end;end;
PROCEDURE BrightDown;var i:byte;begin for i:=15 downto 0 do begin refresh(1);setbright(16*i);end;end;
{$else}
PROCEDURE BrightUp;var i:byte;begin for i:=1 to 31 do begin refresh(1);setbright(8*i);end;end;
PROCEDURE BrightDown;var i:byte;begin for i:=30 downto 0 do begin refresh(1);setbright(8*i);end;end;
{$endif}

PROCEDURE SmoothSetVis;assembler;
 asm
     cli
    {malej shift o 0-3 bity}
     mov dx,3dah;in al,dx;mov dx,3c0h;mov al,13h;out dx,al;
     mov ax,now.visx;and al,3;shl al,1;out dx,al;mov al,32;out dx,al
    {velkej shift}
     mov ax,now.visy;shl ax,7;mov bx,now.visx;shr bx,2;add bx,ax
     mov dx,3d4h;mov al,0ch;out dx,al;inc dx;mov al,bh;out dx,al;
     dec dx;mov al,0dh;out dx,al;inc dx;mov al,bl;out dx,al
     sti
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
{      mov si,bit;mov dx,3;mov cx,16*512/4;@1:movsb;add si,dx;loop @1{}
      mov cx,1024;rep movsw{}
     {loop 4 bits}
      dec bit;jns @nextbit
      pop ds
      mov mouseactive,1
     end;

PROCEDURE Doprava;var i:integer;
 begin for i:=0 to setrvacnost-1 do inc(sunx[(sunindex+i) mod setrvacnost],(setrvacnost-i)*2 div setrvacnost);end;
PROCEDURE Doleva; var i:integer;
 begin for i:=0 to setrvacnost-1 do dec(sunx[(sunindex+i) mod setrvacnost],(setrvacnost-i)*2 div setrvacnost);end;
PROCEDURE Dolu;   var i:integer;
 begin for i:=0 to setrvacnost-1 do inc(suny[(sunindex+i) mod setrvacnost],(setrvacnost-i)*3 div setrvacnost);end;
PROCEDURE Nahoru; var i:integer;
 begin for i:=0 to setrvacnost-1 do dec(suny[(sunindex+i) mod setrvacnost],(setrvacnost-i)*3 div setrvacnost);end;


PROCEDURE Mouse(on:byte);assembler;var a:word;
{write:3c4,2,0-15; read:3ce,4,0-3}
 asm pushf;cli
     mov al,on
     cmp al,mouseflag;jz @99
     cmp al,0;jz @doit{maze vzdycky}
     mov dx,now.mousey{kresli jen kdyz je on screen}
     mov ax,now.visy;cmp dx,ax;jc @99
     add ax,visvys;cmp dx,ax;jnc @99
     @doit:

     xor mouseflag,1
     mov es,sega000
     mov cx,now.mousex
     mov dx,now.mousey
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

     mov cx,16;@1:mov bx,[si];
     {xchg bx,[es:di];mov [si],bx;}xor [es:di],bx
     add si,2;add di,wrisir/4;loop @1
     sub di,4*wrisir

     shl ah,1;cmp ah,16;jnz @ok;mov ah,1;inc di;@ok:

     pop cx;loop @loop
     @99:
     popf
     end;


PROCEDURE InstallMouse;assembler;
 asm
    {zrychleni M}
     mov ax,0fh;mov cx,4;mov dx,cx;int 33h
    {nastaveni range M-x}
     mov ax,7;mov cx,0;mov dx,2*wrisir-17;int 33h
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

     push cx
     push dx
     push 0;call MOUSE
     pop now.mousey
     pop now.mousex
     push 1;call MOUSE

    {posune vis up/down}
     mov dx,now.mousey
     mov ax,now.visy;add ax,mysiokraj;cmp dx,ax;jnc @nosundown;{mov visy,dx;}call nahoru;@nosundown:
     add ax,visvys-16-2*mysiokraj;cmp dx,ax;jc @nosunup;{sub dx,visvys-1;mov visy,dx;}call dolu;@nosunup:
    {posune vis right/left}
     mov cx,now.mousex
     mov ax,now.visx;add ax,mysiokraj;cmp cx,ax;jnc @nosunright;{mov visx,cx;}call doleva;@nosunright:
     add ax,vissir-8-2*mysiokraj;cmp cx,ax;jc @nosunleft;{sub cx,vissir-1;mov visx,cx;}call doprava;@nosunleft:

     @8:
     retf

     @9:end;

PROCEDURE MoveMouse;assembler;{nastaveni polohy M-x-y}
 asm mov ax,4;mov cx,now.mousex;shl cx,1;mov dx,now.mousey;int 33h;end;
PROCEDURE RangeMouse;assembler;{nastaveni range M-y}
 asm mov ax,8;mov cx,0;mov dx,now.radek;dec dx;shl dx,4;dec dx;dec dx;int 33h;end;
PROCEDURE RemoveMouse;assembler;{----REMOVE MOUSE HANDLER----}
 asm {hide}push 0;call mouse;{remove}mov ax,0ch;mov cx,0;int 33h;end;


PROCEDURE PrepareMiniFont;assembler;
 asm
 {cls array:font}
  mov ax,ds;mov es,ax;mov di,offset minifont;mov cx,lenfont/2;mov ax,0;rep stosw;
  lea si,a
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
      mov cx,128;rep movsw;sub si,256;mov cx,128;rep movsw
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

PROCEDURE InsertBigChar2Ems(font:byte;c:char;x1,y16:word);
var last,cet,segx,j,ha,myseg:word;
    d:char;
label 1,2;
begin
 myseg:=charseg[font,c];
 if myseg=0 then begin
         2:
         asm mov ah,48h;mov bx,65535;int 21h;mov j,bx;end;
         if j<300 then begin
           ha:=10000;
           for j:=1 to fontu do for d:=' ' to lastchar do begin
             cet:=cetnost[j,d]-1;
             if cet<ha then begin
               ha:=cet;
               if ha=0 then goto 1;
               end;
             end;
           if ha=10000 then errorhalt(1);
           1:
           segx:=charseg[j,d];charseg[j,d]:=0;cetnost[j,d]:=0;
           asm mov ah,49h;mov es,segx;int 21h;end;
           goto 2;
           end;

         obrys(c,font);
         transto256bitmap;
         fillbigchar;
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

FUNCTION ReadLine:string;{*optimize}
var q:^string;
    i:word;
begin
 i:=edi;
 q:=@edtext[edi-1];
 ReadLine:=q^;{*aby to neprenaselo jen prvnich #10 az #13 charu !!!}
 while edtext[i]<>#13 do inc(i);
 ReadLine[0]:=chr(i-edi);
end;

FUNCTION ReadCharLength:word;{*optimize}
var i,j:word;
begin
 i:=edi;
 j:=0;
 while edtext[i]<>#13 do if edtext[i]=chgcol then inc(i,2) else begin inc(i);inc(j);end;
 ReadCharLength:=j;
end;

FUNCTION ReadPixLength(stop:char):word;{*optimize}
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
 ReadPixLength:=j;
end;

PROCEDURE GetLineParams;{nastavi Wmezer, Wodsaz, Wodcentr, Wsirmez, Wtoedi, Wnewedi}
var i,lastadr,lastsir,nowsirka:word;
label 1;
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
      i:=ReadPixLength(#13);
      if (i>pixLen) then Wodsaz:=pixOdsaz
                    else Wodcentr:=(pixLen-i) div 2;
      end;

 {cte radku dokud neni moc dlouha}
 lastadr:=0;
 i:=edi;
 nowsirka:=Wodsaz+Wodcentr;
 repeat
   1:
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
end;

PROCEDURE OneMiniWord;assembler;{pise slovo z edtext[edi] do x:framewriseg}
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
      add ax,offset a-16*' '
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
      push bx;mov bx,offset propsir-' ';xlat;add di,ax;add di,minifnt;pop bx
      jmp @nextchar

 @endword:
      dec si
      mov edi,si
      mov wordX,di
      end;

PROCEDURE SetDefaultTextAttribs;
begin
 {tohle delat pri otevreni textfajlu}
 pixMinicharSir:=6;
 pixOdsaz:=24;
{ pixStart:=0;}
 with hlavapata[0] do begin x1:=0;y16:=1;oedi:=edtextofs;firstline:=65535;end;
 hlavapat:=-1;
 sloupcu:=0;
 mixword:=mixcols[0];
 minifnt:=0;{mix font, ne shadow font}
end;

FUNCTION ReadInteger(odkud:word):integer;
begin
 ReadInteger:=(100*ord(edtext[odkud])+10*ord(edtext[odkud+1])+ord(edtext[odkud+2])-4800-480-48+500) mod 1000-500;
end;

PROCEDURE Reframe(ii:word);assembler;
 asm
   {reframe}
   mov cx,frameseg
   mov bx,ii;shr bx,1;jnc @startseg;add ch,2;@startseg:
   mov framewriseg,cx
   mov ax,4400h;mov dx,now.handle;int 67h;
   end;

PROCEDURE DrawLine;
var j:word;
begin
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

PROCEDURE PrepareScreen;
var   ii,j,k,k0,l,m,titlesir:integer;
      datafajl:word;
      pall,font,size:byte;
      ch:char;

const bigcols:array[0..8,1..8] of byte=(
       (1,2,3,4,3,2,1,0),
       (14,15,11,12,12,12,12,12),
       (1,2,3,4,4,4,4,4),
       (5,6,7,8,8,8,8,8),
       (9,10,11,12,12,12,12,12),
       (13,14,15,16,16,16,16,16),
       (17,18,19,20,20,20,20,20),
       (21,22,23,24,24,24,24,24),
       (14,15,3,4,4,4,4,4)
       );
      font2cols:array[0..1,1..16] of byte=(
       (3,3,3,3,3,9,9,9,12,12,12,12,12,12,12,12),
       (3,3,3,3,3,9,9,9,3,3,3,3,3,3,3,3)
       );
      chybi:string[60]=#13#10'`bTady chyb° obr†zek.'#13#10'Seëe§ si datafajl s grafikou.'#13#10;


label 1,2,9;
Begin
  SetDefaultTextAttribs;
  for k:=3*usedcols to 3*127 do pal[k]:=54+random(10);
  for k:=3*128 to 3*255 do pal[k]:=34+random(10);

  edi:=edtextofs;

  MoveTextFile2EdText(tree[intree].fl);
  now.radek:=readinteger(ofs(header));
  if now.radek<31 then now.radek:=31;

  1:
  asm {alloc ems}mov ax,4300h;mov bx,now.radek;shr bx,1;add bx,2;int 67h;or ah,ah;jnz @noems;mov now.handle,dx;@noems:end;
  if now.handle=0 then begin
    for k:=1 to intree-1 do if tree[k].handle>0 then begin
      j:=tree[k].handle;tree[k].handle:=0;
      asm {dealloc ems}mov ah,45h;mov dx,j;int 67h;end;
      goto 1;
      end;
    errorhalt(3);
    end;
  tree[intree].handle:=now.handle;

 {kresli stranku do ems}
  now.buttonu:=0;
  Background;
  ii:=1;
  while edi<edtextlast do case edtext[edi] of

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
             j:=readpixlength(':');
             wordX:=pixMid-j;
             mixword:=256*19+20;
             while edi<edtextlast do case edtext[edi] of
                              #13:begin
                                  inc(edi,2);
                                  goto 2;
                                  end;
                              ' ':begin
                                  inc(wordX,pixMinicharSir);
                                  if wordX>pixMid then mixword:=256*23+24;
                                  inc(edi);
                                  end;
                             else OneMiniWord;
                             end;
             end;

      INSPIC:begin
        inc(edi);
        if OpenDataFile(ReadLine)=0 then begin
          xsir:=320;xvys:=200;barevw:=1;
          asm push edi;push mixword;end;
          edi:=ofs(chybi)+3;
          reframe(ii+xvys div 16-2);
          drawline;
          reframe(ii+xvys div 16);
          drawline;
          asm pop mixword;pop edi;end;
          end
         else begin
          ReadDataFile(5,ofs(xsir),dseg);
          ReadDataFile(3*barevw,ofs(pal)+768-3*barevw,dseg);
          ReadDataFile(xsir*xvys,0,workseg);
          CloseDataFile;
          insertpicture(pixMid-xsir div 2,ii,xsir,xvys,2);
          end;
        inc(ii,(xvys-1{*}) div 8);
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
        l:=ReadCharLength;
        titlesir:=ReadPixLength(#13)*size;
        k:=pixMid-titlesir div 2-size*3 div 2{*};
        k0:=k;
        for j:=0 to l-1 do begin
          ch:=edtext[edi+j];
          InsertBigChar2Ems(font,ch,k,ii);
          inc(k,size*propsir[ch]);
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
End;



FUNCTION F1:Boolean;begin f1:=(now.visy>=16*wriy+24) and (wriy<now.radek);end;
FUNCTION F2:Boolean;begin f2:=(now.visy< 16*wriy+ 8) and (wriy>0        );end;

PROCEDURE Show(name:string);
var i,j:integer;
label 1,2;
begin
  port[$21]:=irq;
  tree[1].fl:=name;
  mode13x;
  InstallMouse;

{$ifdef midas}
    midasSetDefaults;                   { set MIDAS defaults }
    midasParseEnvironment;              { parse MIDAS environment string }
    midasParseOptions(1, ParamCount);   { let MIDAS parse all options }
    midasInit;                          { initialize MIDAS Sound System }
    module:=midasPlayModule('e:\classic1.s3m'); { load module and start playing }
{$endif}
  setbright(0);
  goto 2;

  1:
  BrightDown;
  2:
  presz:=0;
  mouseactive:=0;
  mouse(0);
  now:=tree[intree];
  if now.handle=0 then PrepareScreen;
  SmoothSetvis;
  wriy:=now.visy shr 4;for i:=0 to 31 do Ems2Screen(wriy+i);
  RangeMouse;
  MoveMouse;
  mouseactive:=1;
  BrightUp;
{  j:=10*now.visx-450;
  dec(now.mousey,100);
  for i:=0 to 800 do begin
    refresh(1);
    case i of 0..127:SetBright(2*i);
              end;
    case i of 0..600:begin inc(j,round((600-i) div 5*sin(i/10)));now.visx:=j div 20;end;
            600..700:inc(now.visy,round(exp(1.2*ln((i-600) div 10))));
            700..800:dec(now.visy,round(exp(1.2*ln((i-600) div 10))));
            end;
    SmoothSetvis;
    begin
      mouse(0);
      inc(now.mousex,round((600-i) div 20*cos(i/10)));
      inc(now.mousey,round((600-i) div 20*sin(i/10)));
      mouse(1);
      end;
    end;      {}

  repeat
   mouse(1);

   key:=port[$60];
   case key of 77:doprava;
               75:doleva;
               80:dolu;
               72:nahoru;
               end;

   if (sunx[sunindex]<>0) or (suny[sunindex]<>0) then begin
     refresh2(1);
{     mouse(0); }
     inc(now.visx,sunx[sunindex]);
     inc(now.visy,suny[sunindex]);
     if now.visx<0 then now.visx:=0 else if now.visx>=wrisir-vissir then now.visx:=wrisir-vissir-1;
     if now.visy<0 then now.visy:=0 else if now.visy>=16*now.radek-visvys then now.visy:=16*now.radek-visvys-1;
{     inc(now.mousex,sunx[sunindex]);
     inc(now.mousey,suny[sunindex]);
     if now.mousex<0 then now.mousex:=0 else if now.mousex>=wrisir-mysiokraj then now.mousex:=wrisir-mysiokraj-1;
     if now.mousey<0 then now.mousey:=0 else if now.mousey>=16*radek-mysiokraj then now.mousey:=16*radek-mysiokraj-1;}
     sunx[sunindex]:=0;
     suny[sunindex]:=0;
{     movemouse;
     mouse(1);}
     end;

   if sunindex<setrvacnost-1 then inc(sunindex) else sunindex:=0;

   while f1 or f2 do begin
     mouseactive:=0;mouse(0);
     if f1 then begin inc(wriy);Ems2Screen(wriy+31);end;
     if f2 then begin dec(wriy);Ems2Screen(wriy   );end;
     {mouse(1);}mouseactive:=1;
     end;

   if (now.visx<>lastvisx) or (now.visy<>lastvisy) then begin
     SmoothSetvis;
     lastvisx:=now.visx;
     lastvisy:=now.visy;
     end;

   case presz of 0:;
                 8:if intree=1 then key:=1 else begin
                      {dealloc ems}
                       asm mov ah,45h;mov dx,now.handle;mov now.handle,0;int 67h;end;
                      dec(intree);
                      goto 1;
                      end;
                 2:for i:=1 to now.buttonu do with now.bu[i] do
                    if (presx>x1) and (presx<x2) and (presy>y1) and (presy<y2) then begin
                      tree[intree]:=now;
                      inc(intree);
                      tree[intree]:=firstscreen;
                      tree[intree].fl:=now.bu[i].fi;
                      goto 1;
                      end;
                 end;

  until key=1;
  brightdown;
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
     mov al,txsir;mul y;mov bx,lasttextvis;add bx,2*txsir;cmp ax,bx;jc @set;
     sub ax,txsirtxvys;jc @9;cmp ax,lasttextvis;jc @9
     add ax,txsir*3
     @set:
     sub ax,txsir*2;jns @ok;mov ax,0;@ok:
     mov lasttextvis,ax;push ax;call setvis
     @9:
     end;

PROCEDURE Msg(veta:string);
var i:word;
    shdown,le,x1:byte;
    veta2:string;
begin
 shdown:=lasttextvis div txsir;
 i:=pos(#13,veta);
 if i>0 then begin veta2:=copy(veta,i+1,255);veta[0]:=chr(i-1);end else veta2[0]:=#0;
 le:=length(veta);
 x1:=(80-le) div 2;
 store(x1,13+shdown,le,2);
 textattr:=16+11;
 gotoxy(x1,13+shdown);write(veta);
 gotoxy(x1,14+shdown);for i:=1 to le do write(' ');
 gotoxy(x1+(length(veta)-length(veta2)) div 2,14+shdown);write(veta2);
 repeat until keypressed;
 restore(x1,13+shdown,le,2);
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
 x1:=(80-le) div 2;
 x2:=(80-maxlen) div 2;
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
     {uprava edtextlast}
     mov bx,kolik
     add edtextlast,bx
     end;

PROCEDURE DelSpaces(adr,kolik:word);assembler;
 asm {uprava EdText}
     mov ax,ds;mov es,ax
     mov si,adr;add si,kolik
     mov di,adr
     mov cx,edtextlast;sub cx,adr;inc cx
     rep movsb
     {uprava edtextlast}
     mov bx,kolik
     sub edtextlast,bx
     end;


const picu=20;
var picsizes:array[1..picu] of record name:string[13];x,y:word;end;
PROCEDURE GetPicSize(nejm:string;var xx,yy:word);
var i:byte;
    code1,code2:word;
    st:string;
begin
 for i:=1 to picu do with picsizes[i] do if nejm=name then begin xx:=x;yy:=y;exit;end;
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
   if wlcha=chgcol then begin inc(edi);wlcol:=7+8*(ord(edtext[edi])-ord('a'));end else
    asm mov es,workseg;mov di,xy;mov ax,[offset wlcha];stosw;mov xy,di;end;
   end;
 edi:=Wnewedi;
end;


PROCEDURE TextBox(kamx,kamy,sir,vys,barva:word);assembler;
 asm mov ax,2*txsir;mul kamy;mov di,kamx;shl di,1;add di,ax
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
 if i>edtextofs then
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
  str[i]:=t.name;
  for j:=1 to length(str[i]) do case str[i,j] of 'A'..'Z':str[i,j]:=chr(ord(str[i,j])+ord('a')-ord('A'));end;
  findnext(t);
  if i<maxfajlu then inc(i);
  end;
end;

label 1;
Begin
 i:=1;
 findall(typ);
 findall('x\'+typ);
 fajlu:=i-1;
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
 wlcol:=7;
 ii:=1;
 iimax:=0;

 {smaze screen}
{ asm mov es,segb800;mov di,0;mov ax,700h;mov cx,16384;rep stosw;end;}
 asm mov es,workseg;mov di,0;mov ax,700h;mov cx,16384;rep stosw;end;

 edi:=edtextofs;
 linetotal:=0;
 repeat
  case edtext[edi] of
      TABULKA:
      inc(edi);
      MRAMOR:begin
        textbox(pixStart div pixMinicharsir,ii,pixLen div pixMinicharsir,1,ord('€')+256*7);
        inc(edi);
        writeline(ii);
        inc(ii,2);
        end;
      INSPIC:begin
        inc(edi);
        st:=ReadLine;
        GetPicSize(st,i,j);
        TextBox((pixMid-i div 2) div pixMinicharsir,ii,i div pixMinicharsir,j div 8,ord('∞')+256*7);
        inc(ii,j div 8);
        WriteLine(ii-j div 16-1);
        end;
      INSBIGCHAR,INSBUTTON:begin
        ch:=edtext[edi];
        c2:=edtext[edi+1];
        inc(edi,2);
        case c2 of 'A'..'Z':size:=8;'a'..'z':size:=4;end;
        i:=size*ReadPixLength(#13);
        j:=size*8;
        if i=0 then i:=pixMinicharsir;
        TextBox((pixMid-i div 2) div pixMinicharsir,ii,i div pixMinicharsir,j div 8,ord('±')+256*7);
        inc(ii,j div 8);
        WriteLine(ii-j div 16-1);
        if ch=INSBUTTON then WriteLine(ii-j div 16);
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
const hodlen=200;
      hod:array[0..hodlen] of char=#13#10#13#10+mramor+'TECH STUFF'#13#10+tabulka+'tvñrce: '#13#10+
        'status:'#13#10+'testov†no na: '#13#10'existuje je®tà na: '#13#10'velikost: '#13#10'poëadavky na poá°taá: '#13#10+
        'grafika: '#13#10'zvuk: '#13#10#13#10+'grafika: %'#13#10'hudba: %'#13#10'z†bava: %'#13#10#13#10#0;
var   i,j:word;
      m,n:integer;
      special:byte;
      ch:char;
label 0,1,2,3,4,5,6,7,8,newodst;
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
 edzmena:=0;
 setvis(0);
 lasttextvis:=0;
 nowSloupec:=1;
 4:
 {precte text.soubor}
 MoveTextFile2EdText(edfajl);
 if edtextlast=edtextofs+2 then {*goto newodst;}begin
   edtext[edtextofs]:=newsloupec;
   edtext[edtextofs+1]:='0';
   WriteInteger(edtextofs+2,100);{pixstart}
   WriteInteger(edtextofs+5,0);{y0}
   WriteInteger(edtextofs+8,310);{pixlen}
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
      #0:begin ch:=readkey;case ch of
{f1=help}     #59:begin
                  setvis(0);
                  gotoxy(0,0);
                  textattr:=7;
                  clrscr;
                  writeln('ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ˚        Pa©eni®tn° editor (verze 1.4)           ¯Ï¯');
                  writeln;
                  writeln('F1 - huhly huhly');
                  writeln('F2 - uloëit');
                  writeln('F3 - uloëit a uk†zat v grafice !');
                  writeln('F4 - vloëen° textu z ASCII souboru');
                  writeln('F5 - z†kladn° barva textu                Shift+F5 - zvòraznàn† barva textu');
                  writeln('F6 - vloëen° velkÇho n†pisu              Shift+F6 - n†pis bude 2x vàt®°');
                  writeln('F7 - vloëen° my®okliknutelnÇho n†pisu    Shift+F7 - n†pis bude 2x vàt®°');
                  writeln('F8 - vloëen° obr†zku');
                  writeln('F9 - v m°stà kurzoru rozdàl° sloupec na dva nad sebou');
                  writeln('RightMouse - p©em°stàn° celÇho sloupce (stiskni pravÇ tlaá°tko, pohybuj my®°)');
                  writeln('Ctrl+®ipky - roz®°©en° nebo z£ëen° sloupce');
                  writeln('Alt+1..9   - skoá° na zaá†tek sloupce á°slo 1..9');
                  writeln('Alt+T      - na konec textu vraz° tabulku hodnocen° a zmàn° pozad° na modrou');
                  writeln('Insert     - vloë° ©†dku (kdyë m†® na prvn° ©†dce nadpis a chce® p©ed nàj)');
                  writeln('TAB        - p©ep°n† rozli®en° od 80x25 aë po 80x60 (jen na Trident VGA)');
                  writeln('Home, End, PgUp, PgDwn, Ctrl-Y');
                  writeln;
                  writeln('Nepi® ál†nky del®° neë 200 ©†dek nebo 10000 bajtñ.');
                  writeln;
                  writeln('Chyst†m automatickÇ dàlen° slov, bloky (cut, copy, paste).');
                  writeln;
                  writeln;
                  write  ('Baj u dal®° verze...         Stan2');
                  repeat readkey until not keypressed;
                  setvis(lasttextvis);
                  goto 1;
                  end;
{f2=save}     #60:SaveEditorFile;
{f3=save&show}#61:begin
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
{f5=color}#63,#88,#98,#108:begin
                  InsertSpaces(edi,2);
                  edtext[edi]:=CHGCOL;
                  case ch of #63:edtext[edi+1]:='a';
                             #88:edtext[edi+1]:='b';
                             #98:edtext[edi+1]:='c';
                            #108:edtext[edi+1]:='d';
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
                  if length(st)=0 then goto 2;
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
{f9=sloupec}  #67:begin
                  for i:=nowsloupec to sloupcu do begin
                    j:=ord(edtext[sloupce[i].firstedi+1])-48;
                    if j div 2>=nowsloupec then
                     edtext[sloupce[i].firstedi+1]:=chr(j+50);
                    end;
                  ednowi:=VeryStartLine;
                  insertspaces(ednowi,4+13+4);
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
{f9=sloupec}(*  #67:begin newodst:
                  i:=odstavcu;
                  if i>0 then begin
                    msg('TeÉ si ®ipkama vyber zaá†tek nebo konec nàkterÇho ze sloupcñ'+
                        #13'vñái nàmuë bude pozice novÇho sloupce relativn°.');
                    repeat
                      gotoxyavis(odstavec[i].x1 div 6+1,odstavec[i].y16+1);
                      ch:=readkey;
                      case ch of #72,#75:if i>0 then dec(i);
                                 #80,#77:if i<odstavcu then inc(i);
                                 #27:goto 6;
                                 end;
                    until ch=#13;
                    end;
                  msg('TeÉ najeÉ kurzorem do m°st, kde bude levò horn° roh novÇho sloupce.');
                  x:=odstavec[i].x1 div 6;
                  y:=odstavec[i].y16;
                  repeat
                      gotoxyavis(x+1,y+1);
                      ch:=readkey;
                      case ch of #72:if y>0 then dec(y);
                                 #80:inc(y);
                                 #75:if x>0 then dec(x);
                                 #77:if x<79 then inc(x);
                                 #27:goto 6;
                                 end;
                  until ch=#13;
                  SearchMyEdi;
                  edi:=VeryStartLine;
                  InsertSpaces(edi,13);
                  edtext[edi]:=NEWSLOUPEC;
                  edtext[edi+1]:=chr(48+i);{otec sloupce}
                  WriteInteger(edi+2,odstavec[i].x1-6*x);{delta x nebo pixstart}
                  WriteInteger(edi+5,odstavec[i].y16-y);{delta y}
                  WriteInteger(edi+8,30*6);{pixlen}
                  edtext[edi+11]:=#10;
                  edtext[edi+12]:=#13;
                  edzmena:=1;
                  goto 1;
                  6:
                  ch:=' ';
                  end;*)
{f10=move slp #68:begin
                  repeat
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
                   RefreshTextScreen;
                  until mousepress or keypressed;
                  while keypressed do readkey;
                  edzmena:=1;
                  goto 1;
                  end;}
{alt-b}
{alt-e}
{alt-c}
{alt-v}
{alt-n}#120..#128:if ord(ch)-119<=sloupcu then begin
                  nowSloupec:=ord(ch)-119;
                  ednowi:=sloupce[nowsloupec].firstedi+13;
                  goto 1;
                  end;
{zuzeni slp}  's':if pixLen>100 then begin
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
              #75:if ednowx>pixStart div pixMinicharsir then dec(ednowx);
              #77:if ednowx<(pixStart+pixLen) div pixMinicharsir+4 then inc(ednowx);
              #72:if linenow>sloupce[nowsloupec].firstline then begin dec(linenow);ednowy:=scry[linenow];end;
              #80:if linenow<sloupce[nowsloupec].lastline then begin inc(linenow);ednowy:=scry[linenow];end;
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
    {tabulka} #20:begin
                  header[4]:='3';
                  i:=edtextlast;
                  for edtextlast:=edtextlast to edtextlast+hodlen do
                    if hod[edtextlast-i]>#0 then edtext[edtextlast]:=hod[edtextlast-i] else goto 8;8:
                  edzmena:=1;
                  goto 1;
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
                  if (edi<edtextlast-2) and (edtext[edi+2{*nebo 3}]<>newsloupec) then begin
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

 if edzmena=1 then begin
   msg('Nem†® to uloëenò. Jestli to chce® sejvnout, stiskni ENTER,'+
       #13'jinak se ti na to pochopitelnà vyka®lu.');
   if readkey=#13 then SaveEditorFile;
   end;
 goto 0;
End;
{$endif}

var i,j,k,l:integer;
label 0,1;
BEGIN
  if edtextofs<>ofs(edtext) then errorhalt(8);
  InitDataFile;
  ofsst:=ofs(st);
  tree[intree]:=firstscreen;
  for i:=0 to setrvacnost-1 do sunx[i]:=0;suny:=sunx;
  {cls charseg}
   asm mov ax,ds;mov es,ax;mov ax,0;mov cx,charseglen/2;mov di,offset charseg;rep stosw;end;

  for j:=1 to 6 do
    for i:=1 to 4 do begin
     for l:=0 to 2 do pal[3*usedcols+l]:=txtcols[j,l]*i div 4;
     inc(usedcols);
     end;

 {zmeri sirky pismen}
  propsir[' ']:=6;
  asm
   lea si,a+16
   lea di,propsir+1
   mov dx,lastchar-' '
  @nextchar:
   mov ah,0
   mov cx,16
   @1:lodsb;or ah,al;loop @1
   mov al,9
   @2:dec al;shr ah,1;jnc @2
   stosb
   dec dx;jnz @nextchar
   end;

  MemInit;
  MakeFog;
  PrepareMiniFont;


{$ifdef editor}
  editor;
{$else}
  Show(startup);
{$endif}

  errorhalt(0);
END.

obcas sipka zanecha smouhu
setreni pameti: sha[] absolute ...
                font[] zkratit na [' '..lastchar]

hodne bigfontu

cary treba mezi sloupci textu apod...

irq=2
prace behem stmivani, stmivani na irqcku

barva sipky
barva prvnich nadpisu
$S-
titulni obrazovka (s hromadou joys)
zmeny palety pri vic obrazcich
anketa