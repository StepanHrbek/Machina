{$R-,S-,I-,E-,N-,M 4000,20000,20000}  {*max S3M size}

{$define textinsid}
{$define datainsid}
{$define mida}
{$define editor}

{$ifdef editor}
 uses crt;
{$endif}

{$ifdef midas}
 uses midas;
 const module:pointer=nil;
{$else}
{$endif}

 {$I nazvy.inc}
 {$i font.inc}
 {$i sipka.inc}
 {$I f:\-ostatn0\bigfont.inc}

{$ifdef textinside}
 {$i text.inc}
{$else}
 var f:text;
{$endif}

{$ifdef datainside}
 {$i data.inc}
 var vzdyhand,nekdyhand:word;
{$else}
{$endif}

{$ifdef editor}
 const maxlines=250;
       txsir=80;
       txvys:byte=25;
       txsirtxvys:word=80*25;
       mode:byte=0;
 var   edofs,scrofs:array[0..maxlines-1] of word;
       edfajl:string[13];
       edtextlast:word;
       ednowx,ednowy,ednowi,edi,scri:word;
       linetotal,linenow:word;
       lasttextvis:word;
{$else}
{$endif}



{TYPE  trip=array[0..2] of byte;}

CONST startup='head.';
      irq=2;
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
      blablabla='\';
      lastchar='©';
      mouseactive:byte=1;
      mouseflag:byte=0;
      setrvacnost=20;
      sunindex:byte=0;
      intree:byte=1;
      maxbuttonu=10;
      usedcols:byte=1;
      txtcols:array[1..6,0..2] of byte=(
        (30,30,63),
        (30,63,30),
        (63,30,30),
        (63,63,30),
        (63,30,63),
        (30,63,63));
      mixcols:array[0..12] of word=
        (256*7+7,256*16+12,
        256*3+4,256*7+8,256*11+12,256*15+16,256*19+20,256*23+24,
        256*4+8,256*4+12,256*4+16,256*4+20,256*4+24);

      edtextofs=6432{-296{};
      edtextmax=edtextofs+5000;
VAR   header:array[1..6] of char;
      edtext:array[edtextofs..edtextmax] of char;
      presx,presy,presz,
      workseg,frameseg,fogseg,bigfontseg,
      wriy,fileadr,datahandle,
      Wmezer, Wodsaz, Wodcentr, Wsirmez, Wtoedi, Wnewedi,
      edxstart,edxlen,{*casem zrusit a prejit na pixStart...}
      pixstart,pixlen,pixMinicharSir,pixOdsaz,
      ofsst,framewriseg,wordX,
      lastvisx,lastvisy,
      mixword,
      shadowvis                  :WORD;

      eotf                       :Boolean;

      odstavcu,
      lowcol,hicol,
      key,textcolo,edzmena       :BYTE;

      st                         :STRING;

      minifont:array[' '..lastchar,0..15,0..7] of byte;
      sunx,suny:array[0..setrvacnost-1] of shortint;
      pal:array[0..767] of byte;
      odstavec:array[0..10] of record x1,y16,oedi,firstline:word;end;

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

 case n of 1:write('I need more conv mem');
           2:write('I need EMM, QEMM or something similar');
           3:write('I need more EMS memory');
           4:write('I need mouse & driver');
           5:write('You hit ESC, don''t you ?'#10#10);
           6:write('File not found...');
           7:write('Asi nemam dost konvencni pameti...   (???)');
           8:write('Nesouhlasi offset textu ! (interni chyba) ofs=',ofs(edtext));
           9:write('SearchMyEdi ! (interni chyba)');
          10:write('Sorry, text je moc dlouh˜.');
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
           1:{red}  for i:=0 to 47 do pal[3*usedcols+i]:=(3+i div 3+((i+2) mod 3 shr 1)*(47-i));
           2:{green}for i:=0 to 47 do pal[3*usedcols+i]:=(3+i div 3+((i+1) mod 3 shr 1)*(47-i));
           3:{blue} for i:=0 to 47 do pal[3*usedcols+i]:=(3+i div 3+(i mod 3 shr 1)*abs(30-i))*2 div 3;
           end;
 lowcol:=low[n];
 hicol:=hi[n];
end;


{ ÛÛ ÛÛ ÛÛ   FILE MANAGER   ÛÛ ÛÛ ÛÛ }

PROCEDURE OpenTextFile(st:string);
var i:byte;
begin
 eotf:=false;
{$ifdef textinside}
 if st[ord(st[0])]='.' then dec(st[0]);
 for i:=1 to textfajlu do if st=nazevtextu[i] then fileadr:=adresatextu[i];
{$else}
 assign(f,st);reset(f);if ioresult>0 then eotf:=true;
{$endif}
end;

PROCEDURE ReadTextFile(var st:string);
var c:char;
label 1;
begin
{$ifdef textinside}
 st[0]:=#0;
 1:
 asm mov si,fileadr;mov al,[cs:si];mov c,al;end;
 case c of #10,#13:inc(fileadr,2);
              #255:eotf:=true;
              else begin inc(st[0]);st[ord(st[0])]:=c;inc(fileadr);goto 1;end;
              end;
{$else}
 readln(f,st);
 if eof(f) then eotf:=true;
{$endif}
end;

PROCEDURE InitDataFile;assembler;
 asm
{$ifdef datainside}
   {open}
    mov ax,3d00h;mov dx,offset vzdyfile+1;int 21h;mov vzdyhand,ax
    jnc @ok1;push 6;call errorhalt;@ok1:
   {open}
    mov ax,3d00h;mov dx,offset nekdyfile+1;int 21h;mov nekdyhand,ax
    jnc @ok2;push 6;call errorhalt;@ok2:
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
   if handle=0 then datahandle:=vzdyhand else datahandle:=nekdyhand;
   mypos:=start;
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
 st[ord(st[0])+1]:=#0;
 ofsst:=ofs(st);
 asm
  {open}
   mov ax,3d00h;mov dx,ofsst;inc dx
   push ds;mov bx,ss;mov ds,bx;int 21h;pop ds;
   mov datahandle,ax;jc @bad;mov @result,1;@bad:
   end;
end;
{$endif}

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
 {*funguje to ?}
 if st[ord(st[0])]='.' then dec(st[0]);
 for i:=1 to textfajlu do if st=nazevtextu[i] then begin
   move(mem[cseg:adresatextu[i]],header,delkatextu[i]);
   edtextlast:=ofs(header)+delkatextu[i];
   exit;
   end;
{$else}
 {precte textfajl pokud existuje, kdyztak mu vytvori i header}
 if OpenDataFile(st)=0 then EdTextLast:=edtextofs else begin
   edtextlast:=ofs(header)+ReadDataFile(65535,ofs(header),seg(header));
   CloseDataFile;
   if (header[5]<>#13) or (header[6]<>#10) then begin
     move(header,edtext,edtextlast-ofs(header));
     inc(edtextlast,ofs(edtext)-ofs(header));
     end;
   end;
 {na konec fajlu da CR/LF}
 if (edtextlast=edtextofs) or (edtext[edtextlast-1]<>#10) then begin
   edtext[edtextlast]:=#13;
   edtext[edtextlast+1]:=#10;
   inc(edtextlast,2);
   end;
{$endif}
 SetBackPal(ord(header[4])-48);
end;

(*
PROCEDURE DoneDataFile;assembler;
 asm
{$ifdef datainside}
     {close}mov bx,vzdyfile;mov ah,3eh;int 21h;
     {close}mov bx,nekdyfile;mov ah,3eh;int 21h;
{$endif}
     end;
*)



{   ÛÛÛ -------  BIG FONT ------- ÛÛÛ }


CONST vys=128;
      sir=64;
      obtahbase=1;
      fillbase=8;
TYPE  tchara=array[0..vys-1,0..sir shr 3-1] of byte;
      mapa=array[1..vys,1..sir] of byte;
VAR   chara:tchara;
      sha:mapa;
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
     lea si,chara;mov di,offset sha{+656}
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

PROCEDURE FillChar;
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
{PROCEDURE BrightUp;var i:byte;begin for i:=1 to 31 do begin refresh(1);setbright(8*i);end;end;
PROCEDURE BrightDown;var i:byte;begin for i:=30 downto 0 do begin refresh(1);setbright(8*i);end;end;
}PROCEDURE BrightUp;var i:byte;begin for i:=1 to 15 do begin refresh(1);setbright(16*i);end;end;
PROCEDURE BrightDown;var i:byte;begin for i:=15 downto 0 do begin refresh(1);setbright(16*i);end;end;

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
         fillchar;
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

FUNCTION ReadLength:word;{*optimize}
var i,j:word;
begin
 i:=edi;
 j:=0;
 while edtext[i]<>#13 do if edtext[i]=chgcol then inc(i,2) else begin inc(i);inc(j);end;
 readlength:=j;
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
    (edtext[edi-2]=insbigchar) or
    (edtext[edi-2]=insbutton) or
    (edi=edtextofs) then begin
      i:=ReadLength;
      if (pixMinicharSir*i>pixLen) then Wodsaz:=pixOdsaz
                                   else Wodcentr:=(pixLen-pixMinicharSir*i) div 2;
      end;

 {cte radku dokud neni moc dlouha}
 i:=edi;
 nowsirka:=Wodsaz+Wodcentr;
 repeat
   1:
   case edtext[i] of ' ':begin inc(Wmezer);lastadr:=i;lastsir:=nowsirka;inc(nowsirka,pixMinicharSir);end;
                     '`':inc(i);
                 #10,#13:begin Wtoedi:=i-1;Wnewedi:=i+2;exit;end;
                    else inc(nowsirka,pixMinicharSir);
                    end;
   inc(i);
 until nowsirka>pixLen;
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
      mov bl,textcolo

 @nextchar:
      lodsb
      cmp al,' ';jz @endword
      cmp al,13;jz @endword
      cmp al,chgcol;jnz @nochcol
      {zmena barvy}
      lodsb;sub al,'a';mov textcolo,al
      mov bl,al;mov bh,0;shl bx,1;mov bx,[offset mixcols+bx];mov mixword,bx
      jmp @nextchar
      @nochcol:

      push si

{      cmp bl,10;jnc @font1}

@font2:
      mov ah,0
      shl ax,4
      add ax,offset a-16*' '
      mov si,ax
      mov dx,16
      mov ah,2
      mov bx,mixword
     @nextline2:
      lodsb
      mov cx,8
      @2:shl al,1;jnc @noput;
      test [es:di],ah;jz @8;mov [es:di],bl;jmp @7;@8:mov [es:di],bh;@7:
      @noput:inc di;loop @2
      add di,wrisir-8
      dec dx;jnz @nextline2
      jmp @same

@font1:
      mov ah,0
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
      sub di,16*wrisir
      add di,pixMinicharSir
      pop si
      jmp @nextchar

 @endword:
      dec si
      mov edi,si
      mov wordX,di
      end;

PROCEDURE SetDefaultTextAttribs;
begin
 {tohle delat pri otevreni textfajlu}
{ edxStart:=20;
 edxLen:=30;}
 pixMinicharSir:=6;
 pixOdsaz:=24;
{ pixStart:=pixMinicharSir*edxStart;
 pixLen:=pixMinicharSir*edxLen;}
 textColo:=0;
 pixstart:=0;
 with odstavec[0] do begin x1:=0;y16:=0;oedi:=edtextofs;firstline:=65535;end;
 odstavcu:=255;
 mixword:=mixcols[0];
end;

FUNCTION ReadInteger(odkud:word):integer;
begin
 ReadInteger:=(100*ord(edtext[odkud])+10*ord(edtext[odkud+1])+ord(edtext[odkud+2])-4800-480-48+500) mod 1000-500;
end;

PROCEDURE PrepareScreen;
var   i,j,k,l,m,titlesir:integer;
      datafajl:word;
      pall,font:byte;
      mysir,myvys:word;

const bigcols:array[0..8,1..8] of byte=(
       (2,0,0,0,0,0,0,0),
       (3,2,0,0,0,0,0,0),
       (1,2,3,4,4,4,4,4),
       (4,5,11,12,12,12,12,12),
       (7,8,14,15,15,15,15,15),
       (1,2,2,3,10,11,11,11),
       (1,2,3,1,2,2,2,2),
       (27,28,29,30,31,32,33,34),
       (11,10,12,12,12,12,12,12)
       );
      font2cols:array[0..1,1..16] of byte=(
       (3,3,3,3,3,9,9,9,12,12,12,12,12,12,12,12),
       (3,3,3,3,3,9,9,9,3,3,3,3,3,3,3,3)
       );
label 1,9;
begin
  SetDefaultTextAttribs;
  edi:=edtextofs;

  MoveTextFile2EdText(tree[intree].fl);
  now.radek:=100*ord(header[1])+10*ord(header[2])+ord(header[3])-4800-480-48;
  if now.radek<31 then now.radek:=31;

  1:
  asm {alloc ems}mov ax,4300h;mov bx,now.radek;shr bx,1;add bx,2;int 67h;or ah,ah;jnz @noems;mov now.handle,dx;@noems:end;
  if now.handle=0 then begin
    for i:=1 to intree-1 do if tree[i].handle>0 then begin
      j:=tree[i].handle;tree[i].handle:=0;
      asm {dealloc ems}mov ah,45h;mov dx,j;int 67h;end;
      goto 1;
      end;
    errorhalt(3);
    end;
  tree[intree].handle:=now.handle;

 {kresli stranku do ems}
  now.buttonu:=0;
  Background;
  i:=1;
  while edi<edtextlast do case edtext[edi] of

      INSPIC:begin
        inc(edi);
        if OpenDataFile(ReadLine)=0 then errorhalt(6);
        ReadDataFile(5,ofs(xsir),dseg);
        ReadDataFile(3*barevw,ofs(pal)+768-3*barevw,dseg);
        ReadDataFile(xsir*xvys,0,workseg);
        CloseDataFile;
        insertpicture(pixStart+(pixLen-xsir) div 2,i,xsir,xvys,2);
        inc(i,(xvys-1{*}) div 8);
        NextEdiLine;
        end;

      INSBIGCHAR,INSBUTTON:begin
        m:=edi;
        inc(edi);
        case edtext[edi] of 'a'..'z':begin font:=1;pall:=ord(edtext[edi])-ord('a');mysir:=32-4;myvys:=64;end;
                            'A'..'Z':begin font:=2;pall:=ord(edtext[edi])-ord('A');mysir:=64-8;myvys:=128;end;
                            end;
        {set bigfontxlat array}
         asm mov al,pall;mov ah,0;mov si,ax;shl si,3;add si,offset bigcols
             mov di,offset bigfontxlat;mov cx,4;mov ax,cs;mov es,ax;rep movsw;end;
        inc(edi);
        l:=ReadLength;
        titlesir:=mysir*l;
        k:=pixStart+(pixLen-titlesir) div 2-4;
        for j:=0 to l-1 do
          InsertBigChar2Ems(font,edtext[edi+j],k+mysir*j,i);

        if edtext[m]=INSBUTTON then begin
          if now.buttonu<maxbuttonu then inc(now.buttonu);
          with now.bu[now.buttonu] do begin
            NextEdiLine;
            fi:=ReadLine;
            x1:=k;
            y1:=16*i-16;
            x2:=x1+titlesir;
            y2:=y1+myvys;
            end;
          end;

        inc(i,myvys div 16);
        NextEdiLine;
        end;

      NEWSLOUPEC:begin
        inc(odstavcu);{konec minulyho odstavce}
        with odstavec[odstavcu] do begin
          x1       :=pixStart;
          y16      :=scri div (2*txsir);
          end;
        with odstavec[ord(edtext[edi+1])-48] do begin{otcovsky odstavec}
          pixStart :=x1+ReadInteger(edi+2);
          inc(i,ReadInteger(edi+5));
          pixLen   :=ReadInteger(edi+8);
          end;
        inc(odstavcu);{zacatek tohodle odstavce}
        with odstavec[odstavcu] do begin
          x1       :=pixStart;
          y16      :=scri div (2*txsir);
          end;
        NextEdiLine;
        end;

      ELSE begin
        asm
         {reframe}
          mov cx,frameseg
          mov bx,i;shr bx,1;jnc @startseg;add ch,2;@startseg:
          mov framewriseg,cx
          mov ax,4400h;mov dx,now.handle;int 67h;
          end;
        GetLineParams;
        wordX:=pixStart+Wodsaz+Wodcentr;
        while edi<=Wtoedi do case edtext[edi] of
                              ' ':begin
                                  j:=Wsirmez div Wmezer;
                                  inc(wordX,pixMinicharSir+j);
                                  dec(Wsirmez,j);
                                  dec(Wmezer);
                                  inc(edi);
                                  end;
                             else OneMiniWord;
                             end;
        edi:=Wnewedi;
        inc(i);
        end;
      END;

  KonvertScreen;
end;



FUNCTION F1:Boolean;begin f1:=(now.visy>=16*wriy+24) and (wriy<now.radek);end;
FUNCTION F2:Boolean;begin f2:=(now.visy< 16*wriy+ 8) and (wriy>0        );end;

PROCEDURE Show(name:string);
var i:integer;
label 1,2;
begin
  port[$21]:=irq;
  tree[1].fl:=name;
  mode13x;
  InstallMouse;

{$ifdef midas}
    midasSetDefaults;                   { set MIDAS defaults }
{    midasParseEnvironment;              { parse MIDAS environment string }
{    midasParseOptions(2, ParamCount-1); { let MIDAS parse all options }
    midasInit;                          { initialize MIDAS Sound System }
    module:=midasPlayModule('e:\matkamie.mod'); { load module and start playing }
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

PROCEDURE WriteLine;
var i,j,k,oldscri,lastadr:word;
    nowsirka,b:byte;
    textscreen:array[0..16383] of word absolute $b800:0;
label 1,2;
begin
        j:=0;
        if (edtext[edi-1]=#10) or
           (edtext[edi-1]=inspic) or
           (edtext[edi-2]=insbigchar) or
           (edtext[edi-2]=insbutton) or
           (edi=edtextofs) then begin
             i:=ReadLength;
             if (i>edxlen) then j:=6 else j:=(edxlen-i) div 2*2;
             end;
        scri:=scri-scri mod (2*txsir)+2*edxstart+j;

 if linetotal<maxlines-1 then begin
   edofs[linetotal]:=edi;
   scrofs[linetotal]:=scri;
   inc(linetotal);
   end;

 {cte radku dokud neni moc dlouha}
 oldscri:=scri;
 i:=edi;
 nowsirka:=0;
 repeat
   1:
   case edtext[i] of ' ':begin lastadr:=i;inc(nowsirka);end;
                     '`':inc(i);
                     #13:goto 2;
                    else inc(nowsirka);
                    end;
   inc(i);
 until j div 2+nowsirka>edxlen;
 i:=lastadr;
 2:
 {pise radku na obrazovku}
 for j:=edi to i-1 do if edtext[j]='`' then begin
   textcolo:=ord(edtext[j+1])-ord('a');inc(j);
   end
  else begin
   {textscreen[scri div 2]}
   k:=ord(edtext[j])+256*(7+8*textcolo);
   asm mov es,workseg;mov di,scri;mov ax,k;stosw;mov scri,di;end;
   {inc(scri,2);}
   end;
 scri:=oldscri+2*txsir;
 case edtext[i] of ' ':edi:=i+1;
                   #13:edi:=i+2;
                   end;
end;


PROCEDURE TextBox(i:word;j:word;barva:word);assembler;
 asm mov di,scri
     mov es,workseg{segb800}
     mov ax,barva
     mov dx,j
     @1:                {kresli box}
     mov cx,i;rep stosw;add di,2*txsir;sub di,i;sub di,i
     dec dx;jnz @1
     mov ax,txsir*2;mul j;add scri,ax{opravi scri}
     end;


PROCEDURE SearchMyEdi;
var x,y:word;
begin
 x:=scrofs[linenow] mod (2*txsir) div 2;
 y:=scrofs[linenow] div (2*txsir);
 for edi:=edofs[linenow] to edofs[linenow+1]-1 do
  if (x>=ednowx) or (edtext[edi]=#13) then begin if edtext[edi]=chgcol then inc(edi,2);exit;end else
   if edtext[edi]=chgcol then inc(edi) else inc(x);
end;

PROCEDURE SearchMyXYLinenow;
var i:word;
begin
 for linenow:=0 to linetotal do if ednowi<edofs[linenow+1] then begin
   ednowx:=scrofs[linenow] mod (2*txsir) div 2;
   ednowy:=scrofs[linenow] div (2*txsir);
   for i:=edofs[linenow] to edofs[linenow+1]-1 do
    if i>=ednowi then exit else
     if edtext[i]='`' then inc(i) else inc(ednowx);
   end;
end;

FUNCTION StartLine:word;
var i:word;
begin
 i:=edofs[linenow];
 if i>edtextofs then
  if (edtext[i-1]=INSPIC) then dec(i) else
  if (edtext[i-2]=INSBIGCHAR) or (edtext[i-2]=INSBUTTON) then dec(i,2);
 StartLine:=i;
end;

PROCEDURE WriteInteger(kam:word;kolik:integer);
begin
 if kolik<0 then inc(kolik,1000);
 edtext[kam  ]:=chr(48+kolik div 100);
 edtext[kam+1]:=chr(48+kolik div 10 mod 10);
 edtext[kam+2]:=chr(48+kolik mod 10);
end;

PROCEDURE TxMode(m:byte);
const modu=4;
      mo:array[0..modu-1] of byte=( 3,$50,$51,$52);
      li:array[0..modu-1] of byte=(25, 30, 43, 60);
var   i:byte;
begin
 mode:=m mod modu;
 txvys:=li[mode];
 txsirtxvys:=txsir*txvys;
 i:=mo[mode];
 asm mov ah,0;mov al,i;int 10h;end;
end;

PROCEDURE Editor;
var ch:char;
    st:string;
    size,nowodstavec:byte;
    i,j,k,x,y:word;
label 0,1,2,3,4,5,6,newodst;
Begin
 for i:=1 to picu do picsizes[i].x:=0;
 0:{new file}
 {edfajl:='uvod';}
 write('...v editoru je k dispozici F1 = HELP...');
 edfajl:=ask('Zadej pracovn¡ jm‚no ‡l nku (max 8 p¡smen)',8,'','!');{}
 if length(edfajl)=0 then errorhalt(0);
 if pos('.',edfajl)=0 then edfajl:=edfajl+'.';
 ednowi:=edtextofs;
 edzmena:=0;
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

 lasttextvis:=0;
 1:
 {nakresli na obrazovku cely fajl}
 SetDefaultTextAttribs;

 {smaze screen}
{ asm mov es,segb800;mov di,0;mov ax,700h;mov cx,16384;rep stosw;end;}
 asm mov es,workseg;mov di,0;mov ax,700h;mov cx,16384;rep stosw;end;

 edi:=edtextofs;
 scri:=0;
 linetotal:=0;
 repeat
  case edtext[edi] of
      INSPIC:begin
        inc(edi);
        st:=ReadLine;
        GetPicSize(st,i,j);
        scri:=scri-scri mod (2*txsir)+2*edxstart+(edxlen-i div 8) and 254;
        TextBox(i div 8,j div 8,ord('°')+256*7);
        k:=scri;
        dec(scri,j div 16*2*txsir);
        WriteLine;
        scri:=k;
        dec(scri,edxlen-i div 8);
        end;
      INSBIGCHAR,INSBUTTON:begin
        j:=edi;
        inc(edi);
        case edtext[edi] of 'A'..'Z':size:=8;'a'..'z':size:=4;end;
        inc(edi);
        i:=ReadLength;
        if i=0 then i:=1;
        scri:=scri-scri mod (2*txsir)+2*edxStart+edxLen and 254-i*size;
        TextBox(size*i,size,ord('±')+256*7);
        k:=scri;
        dec(scri,(size+2)*txsir);
        WriteLine;
        if edtext[j]=INSBUTTON then WriteLine;
        scri:=k;
        end;
      NEWSLOUPEC:begin
        inc(odstavcu);{konec minulyho odstavce}
        with odstavec[odstavcu] do begin
          oedi     :=edi;
          x1       :=pixStart;
          y16      :=scri div (2*txsir);
          firstline:=65535;
          end;
        i:=ord(edtext[edi+1])-48;{relativne otcovsky odstavec}
        with odstavec[i] do begin
          pixStart :=x1+ReadInteger(edi+2);
          scri     :=(y16+ReadInteger(edi+5))*2*txsir;
          pixLen   :=ReadInteger(edi+8);
          edxstart :=pixStart div 6;
          edxlen   :=pixLen div 6;
          inc(edi,13);
          end;
        inc(odstavcu);{zacatek tohodle odstavce}
        with odstavec[odstavcu] do begin
          oedi     :=edi-13;
          x1       :=pixStart;
          y16      :=scri div (2*txsir);
          firstline:=linetotal;
          end;
        end;
      ELSE WriteLine;
      END;

 until edi>=edtextlast;

 {zkopci to do screenu}
 asm push ds;mov es,segb800;mov ds,workseg;mov si,0;mov di,0;mov cx,16384;rep movsw;pop ds;end;

 i:=1+scri div (2*txsir);
 WriteInteger(ofs(header),i);
 header[4]:='0';
 header[5]:=#13;
 header[6]:=#10;

        inc(odstavcu);{konec posledniho odstavce}
        with odstavec[odstavcu] do begin
          oedi     :=edi;
          x1       :=pixStart;
          y16      :=scri div (2*txsir);
          firstline:=65535;
          end;

 edofs[linetotal]:=edi;
 scrofs[linetotal]:=scri;
 dec(linetotal);
 SearchMyXYLinenow;
 repeat
   gotoxyavis(ednowx+1,ednowy+1);

   {hleda ve kterym je odstavci
   j:=0;
   for nowodstavec:=1 to odstavcu do if odd(nowodstavec) then with odstavec[nowodstavec] do
    if (firstline<=linenow) and (firstline>j) then begin
      j:=firstline;
      pixStart :=;
      pixLen   :=;
      edxstart :=pixStart div 6;
      edxlen   :=pixLen div 6;
      end;                     }

   ch:=readkey;
   case ch of
      #0:begin ch:=readkey;case ch of
{f1=help}     #59:begin
                  gotoxy(0,0);
                  textattr:=7;
                  clrscr;
                  writeln('ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄû   Pa©eni¨tn¡ editor (verze 1.1)             øìø');
                  writeln;
                  writeln('F1 - huhly huhly');
                  writeln('F2 - ulo‘it');
                  writeln('F3 - ulo‘it a uk zat v grafice !');
                  writeln('F4 - vlo‘en¡ textu z ASCII souboru');
                  writeln('F5 - z kladn¡ barva textu                Shift+F5 - zv˜raznˆn  barva textu');
                  writeln('F6 - vlo‘en¡ velk‚ho n pisu              Shift+F6 - n pis bude 2x vˆt¨¡');
                  writeln('F7 - vlo‘en¡ my¨okliknuteln‚ho n pisu    Shift+F7 - n pis bude 2x vˆt¨¡');
                  writeln('F8 - vlo‘en¡ obr zku');
{                  writeln('F9 - vytvo©en¡ nov‚ho sloupce');}
                  writeln('TAB- p©ep¡n  rozli¨en¡ od 80x25 a‘ po 80x60 (jen na Trident VGA)');
                  writeln;
                  writeln('Na ru¨en¡ obr zk– a velk˜ch n pis– rad¨i nepou‘¡vej Del a Backspace, ale CTRL-Y.');
                  writeln('Nepi¨ ‡l nky del¨¡ ne‘ 250 © dek nebo 5000 bajt–.');
                  writeln;
                  writeln('Asi se to bude ob‡as hroutit, tak si pr ci pr–bˆ‘nˆ ukl dej na disk.');
{                  writeln('V grafick‚m m¢du se ob‡as zasekne shift...');
                  writeln('Nev¡m pro‡ to dˆl  a nem–‘u se toho zbavit.');
                  writeln('Tak‘e kdy‘ ti to najednou za‡ne ps t velk˜mi p¡smeny, sta‡¡ stisknout shift.');
}                  writeln;
                  writeln('Brzo bude k dispozici vylep¨en  verze,');
                  writeln('ve kter‚ p–jdou udˆlat t©eba dva sloupce textu vedle sebe apod.');
                  writeln('Chyst m proporcion ln¡ font a automatick‚ dˆlen¡ slov.');
                  writeln;
                  write  ('Baj u dal¨¡ verze...         Stan2');

                  repeat readkey until not keypressed;
                  SearchMyEdi;
                  ednowi:=edi;
                  goto 1;
                  end;
{f2=save}     #60:SaveEditorFile;
{f3=save&show}#61:begin
                  SearchMyEdi;
                  ednowi:=edi;
                  SaveEditorFile;
                  Show(edfajl);
                  txmode(mode);
                  while keypressed do readkey;
                  delay(200);
                  goto 4;
                  end;
{f4=import}   #62:begin
                  st:=ask('Zadej jm‚no textov‚ho souboru, jeho‘ obsah sem chce¨ vlo‘it',8,'','!');
                  if (length(st)=0) or (opendatafile(st)=0) then goto 3;
                  SearchMyEdi;
                  ednowi:=edi;
                  i:=LengthDataFile;
                  InsertSpaces(edi,i);
                  ReadDataFile(i,edi,seg(edtext));
                  CloseDataFile;
                  edzmena:=1;
                  goto 1;
                  3:
                  end;
{f5=color}#63,#88:begin
                  SearchMyEdi;
                  InsertSpaces(edi,2);
                  edtext[edi]:=CHGCOL;
                  if ch=#63 then edtext[edi+1]:='a' else edtext[edi+1]:='b';
                  ednowi:=edi;
                  edzmena:=1;
                  goto 1;
                  end;
{f6=big}  #64,#89:begin
                  ednowi:=StartLine;
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
                  st:=ask('Tady bude n pis. Kliknut¡m na nˆj p©ejde¨ na jinou str nku Pa©eni¨tˆ.'+
                       #13'Jak se m  jmenovat ona str nka=soubor ?',8,'','!');
                  if length(st)=0 then goto 5;
                  ednowi:=StartLine;
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
                  st:=ask('Jak se jmenuje obr zek=soubor, kter˜ sem chce¨ vlo‘it ?',8,'','!');
                  if length(st)=0 then goto 2;
                  if pos('.',st)=0 then st:=st+'.x';
                  ednowi:=StartLine;
                  InsertSpaces(ednowi,length(st)+3);
                  edtext[ednowi]:=INSPIC;
                  for i:=1 to length(st) do edtext[ednowi+i]:=st[i];
                  edtext[ednowi+length(st)+1]:=#13;
                  edtext[ednowi+length(st)+2]:=#10;
                  edzmena:=1;
                  goto 1;
                  2:
                  end;
{f9=sloupec}(*  #67:begin newodst:
                  i:=odstavcu;
                  if i>0 then begin
                    msg('Teƒ si ¨ipkama vyber za‡ tek nebo konec nˆkter‚ho ze sloupc–'+
                        #13'v–‡i nˆmu‘ bude pozice nov‚ho sloupce relativn¡.');
                    repeat
                      gotoxyavis(odstavec[i].x1 div 6+1,odstavec[i].y16+1);
                      ch:=readkey;
                      case ch of #72,#75:if i>0 then dec(i);
                                 #80,#77:if i<odstavcu then inc(i);
                                 #27:goto 6;
                                 end;
                    until ch=#13;
                    end;
                  msg('Teƒ najeƒ kurzorem do m¡st, kde bude lev˜ horn¡ roh nov‚ho sloupce.');
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
                  edi:=StartLine;
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
              #75:if ednowx>EdXStart then dec(ednowx);
              #77:if ednowx<EdXStart+EdXLen-1 then inc(ednowx);
              #72:if linenow>0 then begin dec(linenow);ednowy:=scrofs[linenow] div (2*txsir);end;
              #80:if linenow<linetotal then begin inc(linenow);ednowy:=scrofs[linenow] div (2*txsir);end;
      {PgUp}  'I':begin
                  if linenow>10 then dec(linenow,11) else linenow:=0;
                  ednowy:=scrofs[linenow] div (2*txsir);
                  end;
      {PgDwn} 'Q':begin
                  if linenow+10<linetotal then inc(linenow,11) else linenow:=linetotal;
                  ednowy:=scrofs[linenow] div (2*txsir);
                  end;
      {Home}  'G':ednowx:=scrofs[linenow] mod (2*txsir) div 2;
      {End}   'O':begin
                  ednowx:=scrofs[linenow] mod (2*txsir) div 2;
                  i:=edofs[linenow];
                  while (i<edofs[linenow+1]) and (edtext[i]<>#13) do begin
                    if (edtext[i]='`') or (edtext[i]=#13) then inc(i) else inc(ednowx);
                    inc(i);
                    end;
                  searchmyedi;
                  if edtext[edi]=' ' then dec(ednowx);
                  end;
              'S':begin{delete}
                  edzmena:=1;
                  SearchMyEdi;
                  if (edi<edtextlast-2) and (edtext[edi+2{*nebo 3}]<>newsloupec) then begin
                    if (edtext[edi]=#13) or
                       (edtext[edi]=INSBUTTON) or
                       (edtext[edi]=INSBIGCHAR) or
                       (edtext[edi]=CHGCOL) then j:=2 else j:=1;
                    DelSpaces(edi,j);
                    ednowi:=edi;
                    goto 1;
                    end;
                  end;
              end;
              end;
      #27:;
       #9:begin
          txmode(mode+1);
          SearchMyEdi;
          ednowi:=edi;
          goto 1;
          end;
       #8:begin{backspace}
          edzmena:=1;
          SearchMyEdi;
          if (edi>edtextofs) and (edtext[edi-13]<>newsloupec) then begin
            if (edtext[edi-1]=#10) or
               (edtext[edi-2]=INSBUTTON) or
               (edtext[edi-2]=INSBIGCHAR) or
               (edtext[edi-2]=CHGCOL) then j:=2 else j:=1;
            DelSpaces(edi-j,j);
            ednowi:=edi-j;
            goto 1;
            end;
          end;
      #25:begin{Ctrl-Y}
          edzmena:=1;
          ednowi:=StartLine;
          edi:=ednowi;
          NextEdiLine;
          if edi>edofs[linenow+1] then edi:=edofs[linenow+1];
          {aby se nevracel o radek zpet}
          if (edtext[ednowi-1]<>#10) and (edtext[edi-1]=#10) then begin
            edtext[ednowi]:=#13;
            edtext[ednowi+1]:=#10;
            inc(ednowi,2);
            end;
          DelSpaces(ednowi,edi-ednowi);
          {aby nezrusil zaverecny CR/LF}
          if ednowi>=edtextlast then begin
            edtext[ednowi]:=#13;
            edtext[ednowi+1]:=#10;
            inc(edtextlast,2);
            end;
          goto 1;
          end;
      #13:begin
          edzmena:=1;
          SearchMyEdi;
          InsertSpaces(edi,2);
          edtext[edi]:=#13;
          edtext[edi+1]:=#10;
          ednowi:=edi+2;
          goto 1;
          end;
     else begin
          edzmena:=1;
          SearchMyEdi;
          InsertSpaces(edi,1);
          edtext[edi]:=ch;
          ednowi:=edi+1;
          goto 1;
          end;
     end;
 until ch=#27;

 if edzmena=1 then begin
   msg('Nem ¨ to ulo‘en˜. Jestli to chce¨ sejvnout, stiskni ENTER,'+
       #13'jinak se ti na to pochopitelnˆ vyka¨lu.');
   if readkey=#13 then SaveEditorFile;
   end;
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
vyresetovat shift
setreni pameti: sha[] absolute ...
                font[] zkratit na [' '..lastchar]
otestovat dynamickou (de)alokaci charsegu

sladit barvy v txt a gr
hodne bigfontu

cary treba mezi sloupci textu apod...

`nevyrazna
`vyrazna
`titulni veta s mramorovym podkladem
`shadowfont
`mixfont

