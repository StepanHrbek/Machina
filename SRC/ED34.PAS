{# - docasny veci, konkretni pro jedno cislo}
{$G+,R-,S-,I-,E-,N-,M 15000,0,0}

{$define parenist}
{$define together}{*}

{$ifdef pareniste}
 {$define minifont}
 {$define datainside}
 {$define midas}
 {$define setup}
{$else}
 {$define minifont}{*}
 {$define editor}
 {$define setup}
{$endif}

{$ifdef midas}
 uses sluzby,mids3m,timer;
{$endif}

{$ifdef editor}
 uses sluzby;
{$endif}

CONST firstpoint:byte=0;
      mask=0;
      irqon:boolean=true;
      verze='3.5';
      cislo='6';
      minulycislo=chr(ord(cislo)-1);

{$ifdef midas}
 const predsamplama=1;
       sam_goon=1;
       sam_goback=5;
       sam_togl=3;
       sam_konec=4;
       sam_blbce=2;
       sam_setupon=6;
       sam_shoot=7;
       playingiron:boolean=false;
 var   tmrScrSync:word;
       OutOf:byte;
 const PtmrScrSync:Pword=@tmrscrsync;
{$endif}

{$ifdef datainside}
 {$i data.inc}
 const nekdyhand:word=0;
       rip_det_ems=8;
       rip_speaker=9;
 var   f:text;
{$endif}

{$ifdef editor}
 const maxlines=250;
 var   edofs,scrx,scry:array[0..maxlines-1] of word;
       edfajl:string[13];
       ednowx,ednowy,ednowi:word;
       linetotal,linenow,prevF3visy:word;
       blokstart,blokend:word;
       wlcha:char;
       wlcol,nowsloupec,edzmena,otec:byte;
       blokon,pouzij_prevF3visy:boolean;
{$endif}

TYPE  t40pal=array[3..40*3+2] of byte;
      array8=array[1..40] of byte;

CONST maxaskstringu=30;
      maxtogglu=60;
      maxbuttonu=35;
      maxobrazku=5;
      askmaxlen=24;

      headlen      =20;
      h_radek      =1;
      h_free1      =4;
      h_textura    =5;
      h_visx       =6;
      h_visy       =9;
      h_free2      =12;
      h_flags      =13;
      h_unused     =14;{5 nul}
      h_endofline  =19;

      f_color_ram  =1;
      f_toglvpravo =2;
      f_vlastni_pal=4;
      f_animos     =128;

      textur=4;
      texturhandle:word=0;
      setuphandle:word=0;
      texturyhotovy:byte=0;
      frameseg:word=0;
      edtextmaxlen=15000;
      menu  ='menu';
      anketa='anketa';
      title ='title';
      wrisir=512;
      wrivys=512;
      vissir=360;
      visvys=464;
      mysiokraj=40;
      askx4=170 div 4;
      inspic='~';
       zatimnic='ª';
      chgcol='`';
      insbigchar='|';
      insbutton='';
      newsloupec='^';
      mramor='§';
      tabulka='“';
      togl='þ';
      askSymbol=':';
      rovnejLeft='@';
      rovnaLine='Ä';
      drazka='Í';
      svislaLine='³';
      xorcolor=17;
      mouseactive:byte=0;
      mouseflag:byte=0;
      setrvacnost=20;
      sunindex:byte=0;
      intree:byte=1;
      exeleng:longint=0;
      sipky:byte=0;
      numero:byte=0;
      stillNumero:word=0;
      dotaznikkeypressed:byte=0;
      ramecekcolor:byte=24;
      keyoff:byte=0;
      setuping:Boolean=false;
      palmysozmena:boolean=false;
      INIname='pareni.ini';
      txtpal:t40pal=(
{        (0,0,0),{cerna}
        20,20,00,{default bigfont color}
        28,28, 0,
        45,45,10,
        39,39, 0,
        44,44, 0,
        49,49, 0,
        54,54, 0,
        60,60, 0,
        40,40,40,{text: seda}
        30,35,63,{text: modra}
        55,55, 0,{text: zluta}
        55,55,55,{text: bila}
        18,18, 0,{zluta mys}
        30,30, 0,
        45,45, 0,
        58,58, 0,
        47,26,26,{cervenej zaskrt v toglu}
        63,35,35,
        20,20,20,{sedivy soupadlo}
        30,30,30,
        40,40,40,
         0,26,26,{svetle modry ramecky, AltMlajny}
         0,40,40,
         0,53,53,

       41,42,39,
       39,39,37,
       38,37,35,
       37,35,32,
       35,32,29,
       34,29,28,
       32,27,26,
       30,25,24,
       28,23,23,
       27,21,21,
       26,19,19,
       25,18,18,
       28,21,19,
       29,23,21,
       32,25,23,
       36,28,26
                );

      {$ifdef editor}
      mixcolstxt:array[0..3] of byte=(7,11,14,15);
      {$endif}
      setupsize=89;
      LastScreenCounter:word=0;
      defaultfli='0,0,320,200,0,0'#13#10;



VAR   startupSetup:array8;
      setupAbsolute:array8 absolute scrolllock;
      pointer65:pointer absolute 0:4*$65;

      edtextofs,headerofs:word;
      header:array[1..headlen] of char;
      edtextbody:array[0..edtextmaxlen] of char;
      edtext:array[2..60000] of char absolute firstpoint;
      ppp:record pp1,pp2,pp3:byte;palabsolute:t40pal;end absolute pal;
      palmysozmeny:t40pal;

      {musi byt za sebou kvuli fillcharu}
      cestaKank        :string[70];
      cestaKdrv        :string[70];
      cestaKexe        :string[70];
      cestaKminulymuINI:string[70];
      usedINIname      :string[70];

      last_abs_x,last_abs_y,
      presx,presy,presz,
      workseg,minifontseg,
      wriy,fileadr,vzdyhand,
      Wmezer, Wodsaz, Wodcentr, Wsirmez, Wtoedi, Wnewedi,
      pixStart,pixLen,pixMid,pixMinicharSir,pixOdsaz,
      ramecekStart,ramecekLen,
      ofsst,framewriseg,wordX,
      lastvisx,lastvisy,
      edtextlast,edi,
      minifnt,
      fntseg16,fntofs16,
      panelcentrx4,panelcentry,
      shadowvis,anox4            :WORD;

      key                        :INTEGER;

      hlavapat,sloupcu,method    :SHORTINT;

      xcommand,mixbyte,
      locks,oldscrollock,
      togglu,togglu2,buttonu2,
      askstringu,askstringu2,
      nowask,nowaskx             :BYTE;

      LastopenLength             :LONGINT;

      bokyRamecku,
      ref                        :BOOLEAN;

      TlustejPropSir,TenkejPropSir:array[' '..lastchar] of byte;
      sunx,suny:array[0..setrvacnost-1] of shortint;
      hlavapata:array[-1..18] of record x1,y16,oedi,firstline:word;end;
      sloupce:array[0..9] of record x1,y16,firstedi,firstline,xx1,yy16,lastedi,lastline:word;end absolute hlavapata;
      toggle,toggle2:array[1..maxtogglu] of record y1:word;on:byte;end;
      askstring:array[1..maxaskstringu] of record y16:word;str:array[1..askmaxlen] of char;end;

      head:word absolute 0:$41a;
      tail:word absolute 0:$41c;

CONST lenfont=(ord(lastchar)+1-ord(' '))*16*8;
      offsetminifont=8;

{$ifdef setup}
const soupatek=4-1;
      setuptogglu=2;
      soupatkosir=64;
      soupatkovys=16;
      sox0=170;soy0=160{-16};
      sox1=170;soy1=192{-16};
      sox2=170;soy2=240{-16};
      sox3=170;soy3=272{-16};
      soupatkox  :array[0..soupatek] of word=(sox0,sox1,sox2,sox3);
      soupatkoy  :array[0..soupatek] of word=(soy0,soy1,soy2,soy3);
      soupatkoxy4:array[0..soupatek] of word=(
        (sox0+wrisir*soy0) div 4,
        (sox1+wrisir*soy1) div 4,
        (sox2+wrisir*soy2) div 4,
        (sox3+wrisir*soy3) div 4);
var   soupatkopos:array[0..soupatek] of shortint absolute hlasitostHudby;
      OfsofFrameInSetupbitmap:array[0..setupsize] of word;
      soupatkobuffer:array[0..soupatek,1..12*soupatkovys] of byte;
{$endif}

{----popis screenu----}
TYPE  TPopisScreenu=record
                      radek,handle,mousex,mousey:word;
                      visx,visy:integer;
                      buttonu:byte;
                   {p}palet:byte;
                   {p}nowpal:word;
                   {p}kdepaletaTop,kdepaletaBot:array[1..maxobrazku] of word;
{$ifndef editor}
                   {p}jakapaleta:array[1..maxobrazku] of byte;
{$else}
                   {p}kdepaletaSeg:array[1..maxobrazku] of word;
                   {p}pocetbarev:array[1..maxobrazku] of byte;
{$endif}
                      bu:array[1..maxbuttonu] of record x1,y1,x2,y2:word;fi:string[13];end;
                      PIR:byte;
                      fl:string[13];
                      pal40:t40pal;
                      FLIinside:string[12];
                      FLIx,FLIy,inFLIx,inFLIy,inFLIsir,inFLIvys,FLIpozadi,FLIlet:word;
                      end;

VAR   now:tpopisscreenu;
      tree:array[1..8] of TPopisScreenu;

{------format.X-------}
VAR   xsir,xvys,barevw:word;
      barevb:byte absolute barevw;

{------big font-------}
CONST fontu=2;
VAR   charseg:array[1..fontu,' '..lastchar] of word;
      cetnost:array[1..fontu,' '..lastchar] of byte;
CONST charseglen=sizeof(charseg)+sizeof(cetnost);


{---------------INI----------------}
VAR
      Stereo,
      mode816        :BYTE;

PROCEDURE Vars;assembler;
 asm
  {0-boolean
   1-byte
   2-word                    ÚÄÄzda se ma na konci sejvovat
   3-string                  ³ ÚÄÄtyp promenny }
{$ifdef midas}
  db 'zvukovakarta'         ,  2;dw offset SDnum
  db 'stereo'               ,  0;dw offset stereo
  db '8/16'                 ,  2;dw offset mode816
  db 'irq'                  ,  1;dw offset IRQ
  db 'dma'                  ,  1;dw offset DMA
  db 'port'                 ,  2;dw offset ioPort
  db 'mixovacifrekvence'    ,  2;dw offset mixRate
{$endif}
  db 'hlasitosthudby'       ,8+1;dw offset hlasitosthudby
  db 'hlasitostefektu'      ,8+1;dw offset hlasitostefektu
  db 'citlivostmysi'        ,8+1;dw offset citlivostmysi
  db 'rychlostscrollingu'   ,8+1;dw offset rychlostscrollingu
  db 'scrolllock'           ,8+0;dw offset scrolllock
  db 'detekovatems'         ,  0;dw offset detekovatems
  db 'rozsvecetdiody'       ,  0;dw offset rozsvecetdiody
  db 'cukajiciscrol'        ,8+0;dw offset cukajiciscrol
  db 'uvodnihlaska'         ,8+0;dw offset uvodnihlaska
  db 'detekovatvga'         ,  0;dw offset detekovatvga
  db 'vgadriver'            ,8+3;dw offset vgadriver
  db 'pocetviditelnychbanku',8+1;dw offset viditelnychbanku
  db 'adresarnaankety'      ,  3;dw offset cestaKank
  db 'adresarnadrivery'     ,  3;dw offset cestaKdrv
  db 'hledatminulysetup'    ,8+0;dw offset hledatminulysetup
  db 'ukladatsetup'         ,  0;dw offset ukladatsetup
  db 0
  end;

FUNCTION LocalReadINI(name:string):Boolean;{spoustet az po midasSetDefaults}
var boo:boolean;
begin
 if not ReadIni(name,@vars) then LocalReadINI:=false else begin
   LocalReadINI:=true;
   usedINIname:=name;
   end;
{$ifdef midas}
 {z promennejch mode816 a stereo sestavi midasovskou promennou MODE}
 case mode816 of 8:mode:=mode or 4{sd8bit};
                16:mode:=mode or 8{sd16bit};
                end;
 case stereo of 0:mode:=mode or 1{sdMono};
                1:mode:=mode or 2{sdMono};
                end;
{$endif}
end;

PROCEDURE LocalWriteINI(name:string);
var i:byte;
label saveit,zasave;
begin
 for i:=1 to sizeof(startupSetup) do if startupSetup[i]<>setupAbsolute[i] then goto saveit;
 goto zasave;
 saveit:
 WriteIni(name,@vars);
 zasave:
end;


{ --------------nahrada FirstScreen--------------}

PROCEDURE ResetToDefaults(var a:tpopisscreenu);
begin
 fillchar(a,sizeof(a),0);
 with a do begin
   mousex:=256;
   mousey:=220;
   visx:=(wrisir-vissir) div 2;
   nowpal:=1;
   FLIinside:='';
   end;
end;

{ --------------MEMORY--------------}

PROCEDURE DeallocEMSpage(var kde:TPopisScreenu);
var i:word;
begin
 deallocEMS(kde.handle);
{$ifdef editor}
 for i:=1 to kde.palet do deallocConv(kde.kdepaletaSeg[i]);
 kde.palet:=0;
{$endif}
end;


PROCEDURE EMSvirtualpagesDone;
begin
 for intree:=intree downto 1 do DeallocEMSpage(tree[intree]);
end;

PROCEDURE CONVbigfontDone;
var i:word;
    c:char;
begin
 for i:=1 to fontu do for c:=' ' to lastchar do deallocConv(charseg[i,c]);
end;

PROCEDURE AllMemDone;
begin
 {---EMS---}
  EMSvirtualpagesDone;
  deallocEMS(texturhandle);
{$ifdef setup}
  deallocEMS( setuphandle);
{$endif}
 {----CONV----}
  CONVbigfontDone;
  deallocConv(workseg);
{$ifdef minifont}
  deallocConv(minifontseg);
{$endif}
end;

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
 asm cmp rozsvecetDiody,0;jz @end
     push 1;call refresh;mov dx,60h;mov al,0edh ;out dx,al
     push 1;call refresh;mov dx,60h;mov al,locks;out dx,al
     @end:
     end;
PROCEDURE MidasLightLocks;assembler;
 asm cmp rozsvecetDiody,0;jz @end
     mov ref,0;@1:cmp ref,0;jz @1;mov dx,60h;mov al,0edh ;out dx,al
     mov ref,0;@2:cmp ref,0;jz @2;mov dx,60h;mov al,locks;out dx,al
     @end:
     end;

PROCEDURE ERRORHALT(n:byte);
var i,mem1,mem2:word;
begin
asm mov ah,48h;mov bx,0ffffh;int 21h;mov mem1,bx;end;
{$ifdef midas}
if (n=0) or (not ignornemidas) then begin
 midasStopModule; { stop playing }
 midasClose;                                { uninitialize MIDAS }
{$endif}
 asm mov ax,3;int 10h;end;
 tail:=head;
 {pusti shifty}
 asm mov ax,0;mov es,ax;mov dx,417h;in al,dx;and al,$f0;out dx,al;end;
 {vrati locky do puvodniho stavu}
 locks:=(locks and 254)+oldscrollock;
 lightlocks;
 refresh(3);

 case n of 0:{$ifdef editor}
             writeln('Verze ',verze);
             {$else}
             writeln('Nezapome¤ n m poslat anketn¡ l¡stek.');
             {$endif}
          99:writeln('F12 = n hl  smrt.');
           1:writeln('Pot©ebuju v¡c konven‡n¡ pamˆti.');
           2:writeln('Pot©ebuju EMS pamˆŸ -> pou‘ij EMM, QEMM, 386MAX apod. (bez parametru NOEMM !)');
           3:writeln('Pot©ebuju v¡c EMS pamˆti.');
           4:writeln('Chyba FLI playeru.');
           5:writeln('Nena¨el jsem se na disku !?!');
           6:writeln('Nem m dost konven‡n¡ pamˆti na palety...');
           7:writeln('Nem m dost konven‡n¡ pamˆti na FLI...');
           8:writeln('Tak to prrrr, ‡l nek m  p©es 255 © dek, uber !');
           9:writeln('Chybn˜ parametr u FLI.');
          10:writeln('FLI soubor nenalezen.');
          11:writeln('Chyba ve FLI souboru.');
    100..200:begin
             writeln('Intern¡ chyba ‡¡slo ',n,', nahla¨ Dementovi...  NOW.FL=',now.fl,' INTREE.FL=',tree[intree].fl);
             for i:=0 to 79 do write(edtext[headerofs+i]);
             end;
          20:writeln('dos error ',datahandle);
        else writeln('Nezn m˜ error ‡¡slo ',n);
        end;

 if uvodniHlaska then begin
    writeln;
    if vgadriver>'' then begin
      writeln('Zdetekoval jsem grafickou kartu vyzadujici driver ',vgadriver);
      writeln;
      writeln('Mels-li problemy s grafikou, precti si PARENI.INI a vyzkousej');
      writeln('v nem nastaveni ruznych velikosti viditelne videopameti.');
      writeln('V urcitych pripadech muze pomoci i pouziti jineho driveru');
      writeln('nez vybrala autodetekcni rutina nebo spusteni vubec bez driveru.');
      end
    else begin
      writeln('Nezdetekoval jsem zadnou nestandardni grafickou kartu, ale presto:');
      writeln('Mels-li problemy s grafikou, precti si PARENI.INI a vyzkousej');
      writeln('prilozene graficke drivery *.DRV a nastaveni ruznych velikosti');
      writeln('viditelne videopameti.');
      end;
    writeln;
    writeln('O pripadnych problemech (napriklad chybne detekci) me prosim');
    writeln('informuj.                                                  Dement');
    writeln;
    uvodniHlaska:=false;
    end;

 LocalWriteINI(usedINIname);
 AllMemDone;
 port[$21]:=0;
 if (n<>0) and (n<>99) then{*} begin
  asm mov ah,48h;mov bx,0ffffh;int 21h;mov mem2,bx;end;
  writeln(#13#10'Voln  konven‡n¡ pamˆŸ p©ed shutdownem: ',mem1,' ¨unek.  Po shutdownu: ',mem2,' ¨unek.');
  end;
 halt;
{$ifdef midas}
 end;
{$endif}
end;

const EMSdetected:boolean=false;
PROCEDURE DetectEms;assembler;
const emmname:array[1..9] of char='EMMXXXX0'#0;
asm
   cmp detekovatems,0;jz @nedetek

   (*
   {open emmxxxx}mov ax,3d00h;lea dx,emmname;int 21h;jc @end
   push ax;mov bx,ax;mov ax,4407h;int 21h;cmp al,0;jz @bad;mov EMSdetected,1;@bad:
   {close}pop bx;mov ah,3eh;int 21h;
   @end:
     *)
(**)
	mov	ax,3567h		{get EMM interrupt vector}
	int	21h

	mov	bx,0Ah
	mov	cx,8    		{offset 0Ah of the interrupt vector}
        lea     si,emmname              {si = offset to EMM driver name str

        ; offset 0Ah in the EMM interrupt vector segment should contain the
        ; driver name, or else it does not point to a valid EMM}

@cmp:
        lodsb
        cmp     [es:bx],al              {compare it to EMM driver string}
        jne     @noemm                 {if different, there is no EMM}
	inc	bx
	loop	@cmp

        mov     EMSdetected,1
        @noemm:(**)
        jmp @detek
        @nedetek:
        mov EMSdetected,1
        @detek:
        end;

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
   call detectems;cmp emsdetected,0;jz @emsend
   {get emm frame}mov ax,4100h;int 67h;mov frameseg,bx
   {alloc textur_ems}mov ax,4300h;mov bx,textur*4;int 67h;or ah,ah;jnz @emsend;mov texturhandle,dx
{$ifdef setup}
   {alloc setup_ems}mov ax,4300h;mov bx,4;int 67h;or ah,ah;jnz @emsend;mov setuphandle,dx
{$endif}
   @emsend:
 {----CONV----}
   mov bx,65536/16;call alloc;mov workseg,ax
{$ifdef minifont}
   mov bx,lenfont/16+1;call alloc;mov minifontseg,ax
{$endif}
   end;


PROCEDURE Reframe(ii:word);assembler;
 asm
   {reframe}
   mov cx,frameseg
   mov bx,ii;shr bx,1;jnc @startseg;add ch,2;@startseg:
   mov framewriseg,cx
   mov ax,4400h;mov dx,now.handle;int 67h;
   end;

PROCEDURE Reframe48(ii:word);assembler;
 asm
   {reframe}
   mov cx,frameseg
   mov bx,ii;dec bx;jnc @nepretek;inc bx;@nepretek:
   shr bx,1;jnc @startseg;add ch,2;@startseg:
   mov framewriseg,cx
   mov ax,4400h;mov dx,now.handle;int 67h;inc bx
   mov ax,4401h;mov dx,now.handle;int 67h;inc bx
   mov ax,4402h;mov dx,now.handle;int 67h;
   end;

PROCEDURE Reframe2setupems;assembler;
 asm
  {reframe to setup_ems}
   mov ax,4400h;mov dx,setuphandle;mov bx,0;int 67h
   mov ax,4401h;mov dx,setuphandle;mov bx,1;int 67h
   mov ax,4402h;mov dx,setuphandle;mov bx,2;int 67h
   mov ax,4403h;mov dx,setuphandle;mov bx,3;int 67h
   end;


PROCEDURE SpeedyMOVS_dozadu_cld_inc;assembler;
 asm shr cx,1;jnc @nomovsb;movsb;@nomovsb:jz @end
     shr cx,1;jnc @nomovsw;movsw;jz @end;@nomovsw:
     db 66h;rep movsw
     @end:
     end;

PROCEDURE SpeedyMOVS_dopredu_std_dec;assembler;
 asm shr cx,1;jnc @nomovsb;movsb;@nomovsb:jz @end;dec si;dec di;
     shr cx,1;jnc @nomovsw;movsw;jz @end;@nomovsw:dec si;dec di;dec si;dec di;
     db 66h;rep movsw
     @end:
     end;

{ --------------VIDEO--------------}


{ ÛÛ ÛÛ ÛÛ   FILE MANAGER   ÛÛ ÛÛ ÛÛ }

PROCEDURE InitDataFile;assembler;
var pathstart,pathend,pathseg,realDS:word;
 asm
    mov realDS,DS
   {get psp,environment,selfpath}
    mov ah,62h;int 21h;mov es,bx;mov ds,[es:02ch];mov pathseg,DS
    mov di,65535;mov ax,0;
    @1:inc di;cmp [di],ax;jnz @1;add di,4
   {copy path to 'cestaKexe'}
    mov pathstart,di
    mov ES,realDS
    mov si,di
    lea di,cestaKexe+1
    mov ah,0;
    mov cl,0
   @12:lodsb;stosb;inc ah;
    cmp al,'\';jnz @nolom;mov cl,ah;@nolom:
    or al,al;jnz @12;
    mov pathend,si
    mov [es:offset cestaKexe],cl
   {open self}
    mov ax,3d00h;mov dx,pathstart;int 21h;jnc @openedRO
    push 5;call errorhalt;
    @openedRO:
    mov DS,realDS
    mov vzdyhand,ax
   {read exe header - 4 bytes}
    mov bx,vzdyhand;mov cx,4;mov dx,offset header;mov ah,3fh;int 21h;
{$ifdef datainside}
   {pocita dylku exe fajlu}
    cmp word ptr [offset header],'ZM';jnz @notexe
    mov ax,[offset header+4];dec ax;shl ax,1;mov bh,0;mov bl,ah;shl ax,8
    mov cx,[offset header+2];add ax,cx;or cx,cx;jnz @zz;add ax,512;@zz:
    mov [offset exeleng],ax;mov [offset exeleng+2],bx
    @notexe:
   {open pikcr fajl}
    mov DS,pathseg;mov si,pathend;dec si;dec si;mov byte ptr [si],'T';dec si;dec si;mov word ptr [si],'AD'
    mov ax,3d00h;mov dx,pathstart;int 21h;
    mov DS,realDS
    jc @nodatafajl;mov nekdyhand,ax;@nodatafajl:
{$endif}
    end;

PROCEDURE InitKeyb;assembler;
 asm
    pushf;cli
   {nastavi promennou LOCKS}
    mov ah,2;int 16h;shr al,4;mov ah,al;and ah,1;mov oldscrollock,ah;and al,2+4
    test scrolllock,1;jz @nolock;inc al;@nolock:mov locks,al
   {rozsviti locky}
    call lightLocks
    popf
    end;

{$ifdef datainside}
FUNCTION OpenDataFile(st:string):byte;
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

PROCEDURE CloseDataFile;assembler;
 asm end;
{$endif}

{$ifdef datainside}
{$else}
PROCEDURE PutStartinHeader(rozsah:byte);
const startinheaderlen=headlen+14;
      startinheader:array[0..startinheaderlen] of char=
        '0037a0760005000000'#13#10'^0120000270'#13#10#13#10;
var i,j:word;
begin
 i:=0;              {raw file or new file; put whole header}
 j:=startinheaderlen+1;
 move(mem[dseg:headerofs+i],mem[dseg:headerofs+j],edtextlast+1-headerofs);
 inc(edtextlast,j-i);
 for i:=i to j-1 do edtext[headerofs+i]:=startinheader[i];
 edzmena:=1;
end;
{$endif}

PROCEDURE MoveTextFile2EdText(st:string);
var   i:word;

procedure pridej(st:string);
var i:word;
begin
 for i:=1 to length(st) do edtext[edtextlast+i]:=st[i];
 inc(edtextlast,length(st));
end;

label nastavpaletu;
Begin
 edtextlast:=ofs(header)-1;
 if st='innerset' then begin
   for i:=0 to setuptextlen do edtext[headerofs+i]:=chr(setuptext[i]);
   edtextlast:=ofs(header)+i-1;
   goto nastavpaletu;
   end;
{$ifdef datainside}
 if st='rip' then begin
   pridej('0070a0760000000000'#13#10'^0146001132'#13#10'NAME'#13#10#13#10);
   for i:=1 to datafajlu do pridej('þ'+data[i].name+#13#10);
   pridej('^1113000072'#13#10'SIZE'#13#10#13#10);
   for i:=1 to datafajlu do begin
     str(data[i].len,st);
     pridej(st+#13#10);
     end;
   header[2]:=chr((datafajlu+6) div 10+48);
   header[3]:=chr((datafajlu+6) mod 10+48);
   goto nastavpaletu;
   end;
 if (OpenDataFile(st)=0) or (lastopenLength<>ReadDataFile(lastopenLength,ofs(header),seg(header))) then begin
   pridej('0300a0760000000000'#13#10'^0100012310'#13#10'.........'#13#10#13#10'Tento text nebyl za©azen...'#13#10);
   for i:=1 to length(st) do edtext[edtextofs+12+i]:=st[i];
   end
  else edtextlast:=ofs(header)+lastopenLength-1;
{$else}
 edzmena:=0;
 {precte textfajl pokud existuje, kdyztak mu vytvori i header}
 if OpenDataFile(st)=0 then begin {new file}
   edtextlast:=ofs(header)-1;
   putstartinheader(1);
   end
  else begin
   edtextlast:=ofs(header)-1+ReadDataFile(65535,ofs(header),seg(header));
   CloseDataFile;
   if  (((ord(header[h_flags]) and f_vlastni_pal)=0) and (edtext[edtextofs]<>newsloupec))
    or (((ord(header[h_flags]) and f_vlastni_pal)>0) and (edtext[edtextofs+122]<>newsloupec))
    then putstartinheader(1);
   end;
 {za header kdyztak vrazi paletu}
 if (ord(header[h_flags]) and f_vlastni_pal)=0 then begin
   header[h_flags]:=chr(ord(header[h_flags]) or f_vlastni_pal);
   move(mem[dseg:edtextofs],mem[dseg:edtextofs+122],edtextlast+1-edtextofs);
   inc(edtextlast,122);
   for i:=0 to 119 do edtext[edtextofs+i]:=chr(32+txtpal[3+i]);
   edtext[edtextofs+120]:=#13;
   edtext[edtextofs+121]:=#10;
   edzmena:=1;
   end;
 {na konec fajlu da CR/LF}
 if (edtext[edtextlast-1]<>#13) or (edtext[edtextlast]<>#10) then begin
   edtext[edtextlast+1]:=#13;
   edtext[edtextlast+2]:=#10;
   inc(edtextlast,2);
   end;
{$endif}

 nastavpaletu:
  {nastavi paletu barev 0..40}
  if (ord(header[h_flags]) and f_vlastni_pal)=0 then
    {vrazi tam default paletu}
    now.pal40:=txtpal
   else
    {precte z fajlu}
    for i:=0 to 119 do now.pal40[3+i]:=ord(edtext[edtextofs+i])-32;

End;



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

{$ifdef editor}
PROCEDURE BrightUp;var i:byte;begin for i:=1 to 15 do begin refresh(1);setbright(16*i);end;end;
PROCEDURE BrightDown;var i:byte;begin for i:=15 downto 0 do begin refresh(1);setbright(16*i);end;end;
{$else}
PROCEDURE BrightUp;var i:byte;begin for i:=1 to 31 do begin refresh(1);setbright(8*i);end;end;
PROCEDURE BrightDown;var i:byte;begin for i:=30 downto 0 do begin refresh(1);setbright(8*i);end;end;
{$endif}

(*
PROCEDURE SetUpperPal(n:word);assembler;
 asm mov bx,n;mov now.nowpal,bx;mov al,[bx+offset now.jakapaleta-1] {al=jakapaleta[n]}
     dec al;mov bl,sizeofdata;mul bl;add ax,offset data;mov bx,ax {bx=@data[jakapaleta[n]]}
     mov si,[bx+sizeofdata-2]{.ofss}
     mov bl,[bx+sizeofdata-3]{.colors};mov bh,0;mov cx,bx;add cx,bx;add cx,bx

     mov di,offset pal+3*256;sub di,cx
     mov ax,ds;mov es,ax
     rep segcs movsb
     end;
*)

PROCEDURE SetAndVisUpperPal(n:word;visualizeIt:byte);assembler;
{v editoru:  pocet barev=now.pocetbarev[n]
             segment    =now.kdepaletaSeg[n]
             offset     =0
v parenisti: pocet barev=data[jakapaleta[n]].colors
             segment    =CS
             offset     =data[jakapaleta[n]].palofs}
 asm
     {$ifdef editor}
     mov bx,n;add bx,bx;mov es,[bx+offset now.kdepaletaSeg-2]
     mov si,0
     mov bx,n;mov bl,[bx+offset now.pocetbarev-1]
     {$else}
     mov bx,n;mov now.nowpal,bx;mov al,[bx+offset now.jakapaleta-1] {al=jakapaleta[n]}
     dec al;mov bl,sizeofdata;mul bl;add ax,offset data;mov bx,ax {bx=@data[jakapaleta[n]]}
     mov si,[bx+sizeofdata-2]{.palofs}
     mov bl,[bx+sizeofdata-3]{.colors}
     {$endif}
     mov bh,0;mov cx,bx;add cx,bx;add cx,bx

     cmp visualizeIt,0;jz @novisualize
     mov dx,3c8h;mov al,0;sub ax,bx;out dx,al;inc dx
     push cx
     push si
     rep {$ifdef editor}seges{$else}segcs{$endif} outsb
     pop si{zacatek dat}
     pop cx{barev*3}
     @novisualize:

     mov di,offset pal+3*256;sub di,cx
     {$ifdef editor}
     PUSH DS;mov ax,es;mov bx,ds;mov ds,ax;mov es,bx
     rep movsb        {ds(jinej)->es(old_ds)}
     POP ds
     {$else}
     mov ax,ds;mov es,ax
     rep segcs movsb  {cs->es(old_ds)}
     {$endif}
     end;


   { ------------- T I M E R ------------ }

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


{------------ ostatni ---------------}

PROCEDURE Ems2Screen(line:word);assembler;var bit,workframseg:word;
 asm  mov ax,line;shr ax,5{wrisir/16};call bank
     {reframe, prepare ds}
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
      {mov cx,1024;rep movsw}
      mov cx,512;db 66h;rep movsw
     {loop 4 bits}
      dec bit;jns @nextbit
      pop ds
      mov mouseactive,1
     end;

PROCEDURE Ems2ScreenFromx4Sir8(line,fromx4,sir8:word);assembler;var bit,workframseg:word;
 asm  mov ax,line;shr ax,5{wrisir/16};call bank
     {reframe, prepare ds}
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

{ÛÛÛ_______________________FLI_____________________ÛÛÛ}

TYPE  TFliHead=record
        totalFLIlen:longint;
        magic,frames,width,height,depth,flags,speed:word;
        next,frit:longint;
        future:array[1..101] of byte;
        delaj:byte;
        end;
CONST longtimer:word=0;
      FLIseg:word=0;
      addtofli=0{*50};
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
       push 4;call errorhalt{*}

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

PROCEDURE FLIFrame2Screen(totalwidth,x1,y1,xwidth,yheight:word;pozadi:byte;destx,desty:word);assembler;
var oldDS,bit,line,currentx1,currentsir4,vyscounter:word;
 {fs:bx-pikcr ve workseg od 0/0 (WORKSEG 0,1,2,3,4,5..)
  es:di-skreen v destx/desty (SEGA000 0,4,8...1,5,9...  a 2xVIC radek)
  ds:si-background v destx/desty (EMS 0,4,8...1,5,9...  a 2xVIC radek)}
 asm
     mov al,pozadi;mov [cs:offset @zapozadi-1],al
     MOV oldDS,DS
     mov bit,0
     mov ax,workseg;db 8eh,0e0h{mov FS,ax}
     mov es,sega000
     {spocita alternativni (kratsi) height pri animaci v dolni pulce screenu}
     mov ax,wriy;shl ax,3;add ax,wrivys/2;sub ax,desty;jc @konec
     cmp ax,yheight;jnc @nezkracovat;mov yheight,ax;jmp @prepared;
     @nezkracovat:
     {zvetsi desty,srcy1 a zmensi height pri animaci v horni pulce screenu}
     mov ax,wriy;shl ax,3;sub ax,desty;jc @prepared
     cmp ax,yheight;jnc @konec
     add desty,ax;add y1,ax;sub yheight,ax
  @prepared:
     cmp yheight,0;jz @konec
  @nextbit:
     mov ax,102h;mov cx,bit;shl ah,cl;mov dx,3c4h;out dx,ax{...set write bit}
     mov ax,desty;mov line,ax
     mov ax,yheight;mov vyscounter,ax
     mov ax,destx;sub ax,bit;add ax,3;mov bx,ax;shr ax,2;mov currentx1,ax
     and bx,3;add bx,xwidth;shr bx,2;mov currentsir4,bx
     mov di,desty;shl di,8{7};add di,currentx1{...spocita DI}
     mov si,di;and si,2047;mov ax,3;sub ax,bit;shl ax,11;or si,ax{...spocita SI}
     mov bx,bit;sub bx,destx;and bx,3;mov ax,totalwidth;mul y1;add bx,ax;add bx,x1{...spocita BX}
  @next16lines:
     pusha;mov DS,oldDS
     mov ax,line;shr ax,3{4}
     push ax

     {nabankuje}
     shr ax,5;call bank

     call reframe
     popa;mov DS,framewriseg
  @nextline:
     push bx
     mov cx,currentsir4
     dec si;dec di;inc cx;jmp @background{zaridi vymazani 4 pixelu PRED}
  @nextpixel:
     db 64h{FS};mov al,[bx];add bx,4;cmp al,0;@zapozadi:{*flibackground};jnz @foreground
     @background:{}mov al,[si+wrisir/4];mov [es:di+wrisir/4],al;{}movsb;loop @nextpixel;jmp @zaloop
     @foreground:{$ifdef addtofli}add al,addtofli;{$endif}inc si;{}mov [es:di+wrisir/4],al;{}stosb;loop @nextpixel
    @zaloop:
     {}mov al,[si+wrisir/4];mov [es:di+wrisir/4],al;{}movsb;dec si;dec di;{zaridi vymazani 4 pixelu ZA}
     pop bx;add bx,totalwidth
     mov ax,wrisir/2{4};sub ax,currentsir4;add si,ax;add di,ax;
     dec vyscounter;jz @endofbit
     inc line;test line,7{15};jnz @nextline;sub si,2048;jmp @next16lines
  @endofbit:
     inc bit;cmp bit,4;jnz @nextbit{}
     @konec:
     MOV DS,oldDS
     end;{}

{ÛÛÛ_______________________end of FLI_____________________ÛÛÛ}

PROCEDURE Doprava(n:integer);var i:integer;
 begin for i:=0 to n do inc(sunx[(sunindex+i) mod setrvacnost],(n+1-i)*3 div (2*n+2));end;
PROCEDURE Doleva (n:integer);var i:integer;
 begin for i:=0 to n do dec(sunx[(sunindex+i) mod setrvacnost],(n+1-i)*3 div (2*n+2));end;
PROCEDURE Dolu   (n:integer);var i:integer;
 begin for i:=0 to n do inc(suny[(sunindex+i) mod setrvacnost],(n+1-i)*2 div (n+1));end;
PROCEDURE Nahoru (n:integer);var i:integer;
 begin for i:=0 to n do dec(suny[(sunindex+i) mod setrvacnost],(n+1-i)*2 div (n+1));end;

FUNCTION Osekej(n:integer):integer;
var max:byte;
begin
 n:=n * (rychlostScrollingu+1) div 100;
 max:=(rychlostScrollingu+1)*64 div 100;
 if n>max then n:=max;
 osekej:=n;
end;

PROCEDURE Mouse(on:byte);assembler;
var a:word;
    mylastbank:word;
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

     {nabankuje}
     mov ah,0;mov al,nowbank;PUSH AX
     mov ax,dx;shr ax,9;mov mylastbank,ax;call bank

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
     mov bx,[si];dec bh;jnz @skip1;xchg bl,[es:di  ];mov [si],bl;@skip1:add si,8
     mov bx,[si];dec bh;jnz @skip2;xchg bl,[es:di+1];mov [si],bl;@skip2:add si,8
     add di,wrisir/4;jnc @nonewpage;push ax;mov ax,mylastbank;inc ax;call bank;pop ax;@nonewpage:
     loop @1
     sub di,4*wrisir
     sub si,2*16*8-2

     shl ah,1;cmp ah,16;jnz @ok;mov ah,1;inc di;@ok:

     pop cx;loop @loop

    {restore last bank}
     POP AX;call bank


    {restore vga ports}
     pop bx;call bx2ports

     @99:
     popf
     end;

PROCEDURE Ano(y1:word;on:byte);assembler;
var bit:byte;
    mylastbank:word;
 asm

{$ifdef setup}
     cmp setuping,0;jnz @setupano
{$endif}

@NORMALANO:{nakresli togglik do EMS}
     mov ax,y1;shr ax,4;push ax;call reframe;mov es,framewriseg

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

{$ifdef setup}
     jmp @99

@SETUPANO: {nakresli togglik na screenu}

     {nabankuje}
     mov ax,y1;shr ax,9;mov mylastbank,ax;call bank

     mov es,sega000
     lea si,anobitmap;cmp on,0;jnz @22;lea si,nebitmap;@22:
     mov di,y1;shl di,7{wrisir/4};add di,panelcentrx4;sub di,14;mov bit,0
     mov dx,16
    @nextline:
     mov cx,12;
     push di
     @12:call @incbitsetbit;lodsb;mov [es:di],al;loop @12
     pop di;add di,wrisir/4;jnc @nonewpage;mov ax,mylastbank;inc ax;call bank;@nonewpage:
     dec dx;jnz @nextline
     jmp @99

{inc bit, set bit}
@incbitsetbit:
     push ax;push cx;push dx
     mov cl,bit;inc cx;cmp cl,4;jc @ouk;mov cl,0;inc di;@ouk:mov bit,cl
     mov ax,102h;shl ah,cl;mov dx,3c4h;out dx,ax
     pop dx;pop cx;pop ax
     ret
{$endif}

     @99:
     end;

{$ifdef setup}
PROCEDURE KresliSoupatko(KresliMaz:char;i:byte;pos:word);assembler;
var bit:byte;
    mylastbank:word;
 asm
     mov es,sega000
     lea si,soupadlobitmap
     mov bl,i;mov bh,0;add bx,bx;add bx,offset soupatkoxy4

     {nabankuje}
     mov ax,[bx];shr ax,7;add ax,now.visy;shr ax,9;mov mylastbank,ax;call bank

     mov di,now.visy;shl di,7{wrisir/4};add di,[bx];sub di,2
     mov ax,now.visx;and ax,65532;add ax,pos;add ax,2;mov bx,ax;shr ax,2;add di,ax;and bl,3;mov bit,bl
     lea bx,soupatkobuffer;mov al,12*16;mul i;add bx,ax
     mov dx,16
     cmp kreslimaz,'k';jnz @maz

    @kresli:
     @kresliline:
     mov cx,12;
     push di
     @12:call @incbitsetbit;mov al,[es:di];mov [bx],al;inc bx;lodsb;mov [es:di],al;loop @12
     pop di;add di,wrisir/4;jnc @nonewpage1;mov ax,mylastbank;inc ax;call bank;@nonewpage1:
     dec dx;jnz @kresliline
     jmp @99

    @maz:
     mov si,bx
     @mazline:
     mov cx,12;
     push di
     @13:call @incbitsetbit;lodsb;mov [es:di],al;loop @13
     pop di;add di,wrisir/4;jnc @nonewpage2;mov ax,mylastbank;inc ax;call bank;@nonewpage2:
     dec dx;jnz @mazline
     jmp @99

{inc bit, set bit}
@incbitsetbit:
     push ax;push cx;push dx
     mov cl,bit;inc cx;cmp cl,4;jc @ouk;mov cl,0;inc di;@ouk:mov bit,cl
     {write}
     mov ax,102h;shl ah,cl;mov dx,3c4h;out dx,ax
     {read}
     mov al,4;mov dx,3ceh;out dx,al;inc dx;in al,dx;dec dx
     mov ah,al;mov al,4;out dx,al;mov al,ah;and al,252;or al,cl;inc dx;out dx,al{}
     pop dx;pop cx;pop ax
     ret

     @99:
     end;
{$endif}

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
     mov ax,ds;mov [cs:offset @q-2],ax
     mov ax,0ch;mov cx,7fh;mov dx,cs;mov es,dx;mov dx,offset @mousehandler;mov bx,dx;mov di,dx;int 33h;
     jmp @9

@MOUSEHANDLER:
     pusha
     push ds
     push es
     mov si,0;@q:mov ds,si;shr cx,1

    {nastavi externi promenny - souradnice stisku}
     and ax,2+8+32 +4+16;jz @nopress
     mov presx,cx
     mov presy,dx
     mov presz,ax
     @nopress:

     cmp mouseactive,0;jz @8{je vypnuta -> nic nedelam}

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

PROCEDURE NastavCitlivostmysi;
var i:word;
begin
 i:=1+round(80/(citlivostMysi+1));
 asm mov cx,i;mov dx,cx;mov ax,0fh;int 33h;end;
end;

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
{$ifdef minifont}
 {cls minifont}
  mov es,minifontseg;mov di,offsetminifont;mov cx,lenfont/2;mov ax,0;rep stosw;

  mov ah,17;
  mov di,offsetminifont
  call @nextcolor
  mov di,offsetminifont-7
  call @nextcolor
  mov ah,17;
  mov di,offsetminifont+2
  call @nextcolor
  mov di,offsetminifont+9
  call @nextcolor
  mov ah,18;
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
{$endif}
  end;

PROCEDURE Naframuj(n:word);assembler;
 asm
      mov ax,4400h;mov dx,texturhandle;mov bx,n;shl bx,2;push bx;int 67h;pop bx
      mov ax,4401h;mov dx,texturhandle;inc bx           ;push bx;int 67h;pop bx
      mov ax,4402h;mov dx,texturhandle;inc bx           ;push bx;int 67h;pop bx
      mov ax,4403h;mov dx,texturhandle;inc bx                   ;int 67h
 end;

PROCEDURE FillEmsWorksegem;assembler;
 asm
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
      mov cx,128;db 66h;rep movsw;sub si,256
      dec dx;jnz @1

      pop ds
      pop bx;inc bx;cmp bx,260;@za:jnz @nextpage
      end;


PROCEDURE PlaceNopeTexture(n:byte);assembler;
  asm
      mov cx,now.radek;shr cx,1;mov bx,0;
      @nextpage:push cx
      mov ax,4400h;mov dx,now.handle;push bx;int 67h;pop bx;inc bx
      mov es,frameseg
      mov di,0;mov al,n;mov ah,al;mov cx,8*1024;rep stosw
      pop cx;loop @nextpage
      end;

PROCEDURE PlaceSetupTexture;assembler;
 asm
   PUSH DS
   mov es,workseg
   mov ds,workseg
   xor si,si
   mov di,si
   mov al,19
   mov ah,22
   mov cx,65536/2;rep stosw
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
   call fillemsworksegem;
end;

PROCEDURE PlaceHvezdyTexture;
var i:word;
begin
 asm
   mov es,workseg
   xor ax,ax
   xor di,di
   mov cx,65536/2;rep stosw
   end;
 for i:=1 to 3000 do byte(mem[workseg:random(65535)]):=25+random(16);
 fillemsworksegem;
end;

PROCEDURE PlaceNormalTexture(j:byte);
begin
 if ((j=2) or (j=3)) and ((texturyhotovy and (4+8))=0) then begin
   texturyhotovy:=texturyhotovy or (4+8);
   MakeTextureInSeg(2,workseg);
   Naframuj(2);
   CopySeg(workseg,frameseg);
   if j=2 then FillEmsWorksegem;
   MakeTextureInSeg(3,workseg);
   Naframuj(3);
   CopySeg(workseg,frameseg);
   if j=3 then FillEmsWorksegem;
   end
 else begin
   Naframuj(j);
   if texturyhotovy and (1 shl j)=0 then MakeTextureInSeg(j,frameseg);
   CopySeg(frameseg,workseg);
   FillEmsWorksegem;
   texturyhotovy:=texturyhotovy or (1 shl j);
   end;
end;


PROCEDURE InsertPicture(x1,y16,sirka,vyska,doublescan,doublex:word);assembler;var j,ha:word;
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

     {loop DOUBLE_X=1 - halvesize}
     cmp doublex,1;jnz @normalsize
      @miniloop2:{precte scanlajnu}
      mov bx,doublescan
      @nextscan2:{nekolikrat zakresli tutez scanlajnu}
      mov cx,sirka;shr cx,1;inc cx;push si;push di;dec di
      @42:inc di;@52:lodsw;or al,al;loopz @42;jcxz @62;stosb;jmp @52;@62:
      pop di;pop si;add di,wrisir
      dec bx;jz @lastscan2;jmp @nextscan2;@lastscan2:add si,sirka
      dec dx;jz @99
      test di,16384;jz @miniloop2
      and di,16383;jmp @wideloop

     {loop DOUBLE_X=2 - normalsize}
     @normalsize:
     cmp doublex,2;jnz @doublesize
      @miniloop1:{precte scanlajnu}
      mov bx,doublescan
      @nextscan1:{nekolikrat zakresli tutez scanlajnu}
      mov cx,sirka;inc cx;cmp cx,512;jc @under512;mov cx,512;@under512:
      push si;push di;dec di
      @41:inc di;@51:lodsb;or al,al;loopz @41;jcxz @61;stosb;jmp @51;@61:
      pop di;pop si;add di,wrisir
      dec bx;jnz @nextscan1
      add si,sirka
      dec dx;jz @99
      test di,16384;jz @miniloop1
      and di,16383;jmp @wideloop

     {loop DOUBLE_X=4 - doublesize}
     @doublesize:
      @miniloop3:{precte scanlajnu}
      mov bx,doublescan
      @nextscan3:{nekolikrat zakresli tutez scanlajnu}
      mov cx,sirka;inc cx;cmp cx,256;jc @under256;mov cx,256;@under256:
      push si;push di;dec di
      @43:inc di;inc di;@53:lodsb;or al,al;loopz @43;jcxz @63;stosb;stosb;jmp @53;@63:
      pop di;pop si;add di,wrisir
      dec bx;jnz @nextscan3
      add si,sirka
      dec dx;jz @99
      test di,16384;jz @miniloop3
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
    cislolajny:byte;
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

             {otestovat vsechny bigchary, jestli se tady nehaltnou}
             jnc @ok
             push 103;call errorhalt
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
      mov cislolajny,ah
      mov bl,method

      push ds
      mov ds,myseg


     {reframe}
    @NextLineAndReframe:
      pusha
      mov ax,4400h;mov bx,j;inc j;mov dx,ha;int 67h
      popa
    @NewLine:
      mov last,di
      inc cislolajny
    @ContinueLine:
      lodsb
      or al,al;jz @endofline
      cmp al,255;jz @99
      add di,ax{mezery}   {ah must be 0}
      lodsb
      mov cx,ax           {ah must be 0}
      mov al,bl{method}
      dec al;js @method1{full}
      dec al;js @method8{full zvlnenej}
      dec al;js @method7{full nahoru tmavnouci}
      dec al;js @method6{jen 3 obrysovy radky}
      dec al;js @method3
      dec al;js @method2
      dec al;js @method4
      @method1:rep movsb;jmp @continueline
      @method2:lodsb;sub al,5;add al,[es:di];cmp al,40;jc @ok2;mov al,40;@ok2:stosb;loop @method2;jmp @continueline
      @method3:lodsb;sub al,[es:di];neg al;cmp al,25;jnc @y;mov al,25;@y:mov [es:di],al;inc di;loop @method3;jmp @continueline
      @method4:lodsb;cmp al,5;jnc @vynech4;sub [es:di],al;@vynech4:inc di;loop @method4;jmp @continueline
      @method5:jmp @continueline
      @method6:lodsb;cmp al,4;jnc @vynech6;mov [es:di],al;@vynech6:inc di;loop @method6;jmp @continueline
      @method7:push bx;mov bl,cislolajny;and bl,7;cmp bl,4;jc @low;neg bl;add bl,8;@low:
               mov bh,0;add di,bx;rep movsb;sub di,bx;pop bx;jmp @continueline
      @method8:push ax;mov ah,cislolajny;shr ah,4;inc ah;
               @met8:lodsb;cmp al,ah;jc @nepret8;mov al,ah;@nepret8:stosb;loop @met8;
               pop ax;jmp @continueline

    @EndOfLine:
      mov di,last
      add di,wrisir
      test di,16384;jz @NewLine
      and di,16383;jmp @NextLineAndReframe

      @99:
      pop ds

      end;
end;

PROCEDURE InsertBardString2Ems(color:shortint;centrx1,y16,ofsst:word;var xstart,xsir:integer);{samo si to naframuje}
var   i,j,x,x1,x2,len,myofsb,myofsst,sir8,dxy1:word;
      vys,scanlajna:byte;
      tenhleznak,podznamenkem:char;
label full,core,konecradky;
begin
 reframe48(y16);

 len:=0;
 myofsst:=ofsst;
 while edtext[myofsst]<>#13 do begin
  if edtext[myofsst]<#128 then inc(len,bardhead[                 edtext[myofsst]         ].bdx2 div 4)
                          else inc(len,bardhead[chr(64+bardhacky[edtext[myofsst]] and 63)].bdx2 div 4);
  inc(myofsst);
  end;
 xsir:=len;
 x:=centrx1-len div 2;
 xstart:=x;
 myofsst:=ofsst;

 full:
 tenhleznak:=edtext[myofsst];
 podznamenkem:=#0;
 dxy1:=0;
 case tenhleznak of #13:goto konecradky;
             #127..#255:begin
                        podznamenkem:=chr(64+bardhacky[tenhleznak] and 63);
                        dxy1:=1+((bardhacky[tenhleznak] shr 8) and 31)
                               +wrisir*(bardhacky[tenhleznak] shr 13);
                        tenhleznak:=chr(ord('z')+bardhacky[tenhleznak] shr 6 and 3);
                        end;
                    end;
 core:
 with bardhead[tenhleznak] do begin
  if bsir>0 then begin
   myofsb:=bofs;
   sir8:=(bsir-1) div 8+1;
   vys:=bvys;
   if dxy1=0 then x1:=x+bdx-11+wrisir*(16+30-bdy)
             else x1:=x       +wrisir*(16+24-bardhead[podznamenkem].bdy)+dxy1;
   asm
     mov scanlajna,0
     mov es,framewriseg
     mov di,x1
     mov si,myofsb;add si,offset bardbody
     mov bl,vys
     mov ah,color
     mov bh,ah;inc bh
    @nextline:
     cmp bh,1;jnz @onecolor;inc scanlajna;mov ah,scanlajna;shr ah,2;inc ah;@onecolor:
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
  if podznamenkem=#0 then begin
    inc(x,bdx2 div 4);
    inc(myofsst);
    goto full;
    end
   else begin
    tenhleznak:=podznamenkem;
    podznamenkem:=#0;
    dxy1:=0;
    goto core;
    end;
  end;

 konecradky:
end;


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
      mov si,bit;mov dx,3;
{      mov cx,16*512/4
      @1:movsb;add si,dx;loop @1}
      mov cx,16*512/4/8
      @1:
      movsb;add si,dx;movsb;add si,dx;movsb;add si,dx;movsb;add si,dx;
      movsb;add si,dx;movsb;add si,dx;movsb;add si,dx;movsb;add si,dx;
      loop @1
      dec bit;jns @nextbit
      ret

      @9:
      end;


PROCEDURE NextEdiLine;assembler;
 asm mov si,edi;@1:lodsb;cmp al,13;jnz @1;inc si;mov edi,si;end;

FUNCTION ReadLine:string;
var q:^string;
    i:word;
    st:string;
begin
 st:='';
 i:=edi;
 while edtext[i]<>#13 do inc(i);
 dec(i,edi);
 move(edtext[edi],mem[seg(st):ofs(st)+1],i);
 st[0]:=chr(i);
 readline:=st;
end;
    (*
 q:=@edtext[edi-1];
 ReadLine:=q^;{aby to neprenaselo jen prvnich #10 az #13 charu !!!}
 while edtext[i]<>#13 do inc(i);
 ReadLine[0]:=chr(i);
{ asm mov si,edi;lea di,@result+1;jmp @1
     @loop:segss stosb;@1:lodsb;cmp al,13;jnz @loop
     mov ax,di;sub ax,offset @result;mov al,1;mov [ss:offset @result],al
     end;}
end;  *)

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
label ano,ne,za;
begin
 Wmezer:=0;
 Wodsaz:=0;
 Wodcentr:=0;
 Wsirmez:=0;
 asm mov bx,edi;mov ax,[bx-2];
     cmp ah,10;jz ano
     cmp ah,inspic;jz ano
     cmp ah,mramor;jz ano
     cmp ah,tabulka;jz ano
     cmp al,insbigchar;jz ano
     cmp al,insbutton;jz ano
     cmp ah,asksymbol;jnz za
     end;
 ne:
 Wodcentr:=4*askx4-25-pixStart;
 goto za;
 ano:
 i:=ReadPixLength(#13,ofs(tenkejPropsir)-32);
 if (i>pixLen) then Wodsaz:=pixOdsaz
               else Wodcentr:=(pixLen-i) div 2;
 za:

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
      mov bl,mixbyte

 @nextchar:
      lodsb
      cmp al,' ';jz @endword
      cmp al,13;jz @endword
      cmp al,chgcol;jnz @nochcol
      {zmena barvy}
      lodsb;sub al,'a'-9;mov bl,al;mov mixbyte,al
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
      @2:shl al,1;jnc @noput;mov [es:di],bl;@noput:inc di;loop @2
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
      @1:lodsb;or al,al;jz @notal;stosb;dec di;@notal:inc di;loop @1
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
      shr al,1;jnc @black1;mov bh,10;@black1:
      test al,8;jz @black2;mov bl,10;@black2:
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
var i,j,l:integer;
begin
{globalni parametry textu}
 pixMinicharSir:=5;
 pixOdsaz:=24;
 anox4:=170 div 4;
{pocatecni hodnoty promennych}
 with hlavapata[0] do begin x1:=0;y16:=1;oedi:=edtextofs;firstline:=65535;end;
 hlavapat:=-1;
 sloupcu:=0;
 mixbyte:=9;
 {$ifdef editor}wlcol:=mixcolstxt[0];{$endif}
 minifnt:=0;{mix font, ne shadow font}
 bokyRamecku:=false;
 ramecekColor:=24;
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
var i:word;
begin
 for i:=1 to intree-1 do if tree[i].handle>0 then begin
      deallocEMSpage(tree[i]);
      freeMoreEMS:=true;
      exit;
      end;
 freeMoreEMS:=false;
end;



PROCEDURE SaveAnketa;
var   i:byte;
      f:text;
      fajl:string;
label cantwrite;
begin
{$ifdef pareniste}
 if now.fl=anketa then begin
   if (length(cestaKank)>1) and (cestaKank[length(cestaKank)]<>'\') then cestaKank:=cestaKank+'\';
   fajl:=cestaKank+anketa+cislo+'.'+chr(48+random(10))+chr(48+random(10))+chr(48+random(10));
   {zapise vysledek ankety}
   assign(f,fajl);
   rewrite(f);
   if ioresult>0 then goto cantwrite;
   for i:=1 to togglu do write(f,chr(48+toggle[i].on));
   writeln(f);
   for i:=1 to askstringu do writeln(f,askstring[i].str);
   close(f);
   end;
 cantwrite:
 askstringu:=0;
 togglu:=0;
{$endif}
end;

PROCEDURE xorcursor(video:Boolean);{reframe ; xor cursor do ems i videopameti}
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
   if video and (y16>=wriy) and (y16<=wriy+31){neni mimo obraz} then asm
     {nakrasli ten samej kurzor i do videopameti}
      mov ax,y16;shr ax,5;call bank
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
     {xor Ä}
      mov al,[es:di];xchg al,[bx];stosb

     {set 3. bit       for writing}
      mov ax,0402h;mov dx,3c4h;out dx,ax
     {set 3. bit       for reading}
      mov ax,0204h;mov dx,3ceh;out dx,ax
     {xor Ä}
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

PROCEDURE FastMoveBack(src,dest,len:word);assembler;
 asm {ULTRA FAST MOVE (dword speed)}
     mov cx,len;or cx,cx;jz @end{nic kdyz se ma presunout 0 bajtu dlouhej kus}
     mov si,src;mov di,dest
     cmp si,di;jz @end{nic, kdyz je posun o 0 bajtu}
     PUSH DS;mov es,workseg;mov ds,workseg
     call speedyMOVS_dozadu_cld_inc
     POP DS
     @end:
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
 end;
end;

PROCEDURE initPIR(st:string);
begin
with flihead do begin
 if OpenDataFile(st)=0 then errorhalt(10);
 if ReadDataFile(5,ofs(xsir),dseg)<>5 then errorhalt(11);
 ReadDataFile(3*barevw,ofs(pal)+768-3*barevw,dseg);
 ReadDataFile(xsir*xvys,0,workseg);
 asm mov es,workseg;mov di,320*160;xor ax,ax;mov cx,320;rep stosw;end;
 nowFLIframe:=0;
 now.flix:=wrisir div 2;
 now.fliy:=wrivys div 2;
 flihead.speed:=3;
 delaj:=1;
 end;
end;

PROCEDURE GetVarFromString(var st:string;var prom:word);
var i,j:word;
begin
 i:=pos(',',st);if i=0 then i:=length(st)+1;
 val(copy(st,1,i-1),prom,j);
 if j>0 then errorhalt(9);
 st:=copy(st,i+1,250);
end;

PROCEDURE PrepareScreen(konvert:Boolean);
var   ii,j,k,k0,l,m,titlesir:integer;
      datafajl:word;
      font,size,doublescan,doublex:byte;
      ch:char;
      leftStart:word;
      st:string;
{      maxradek,
      zbyvaradek,}
      precist,{alias packedPacksize}
      packedStart,
      packedEnd,
      rawEnd,
      rawPacksize,
      rawPackradek,
      rawZbyvaradek      :word;
      packedZbyvasize    :longint;

const  chybi:string[60]=#13#10'`bTady chyb¡ obr zek.'#13#10'Se‘e¤ si datafajl s grafikou.'#13#10;

label 1,2,7,9,nexttry;
Begin
  SetDefaultTextAttribs;
  DeallocConv(fliseg);

  nowask:=0;

  MoveTextFile2EdText(now.fl);
  edi:=edtextofs;
  if (ord(header[h_flags]) and f_vlastni_pal)>0 then inc(edi,122);
  now.pir:=ord(header[h_flags]) and f_animos;

  now.visx :=readinteger(headerofs+h_visx-1);
  now.visy :=readinteger(headerofs+h_visy-1);
  now.radek:=readinteger(headerofs+h_radek-1);
  if now.radek<31 then now.radek:=31;
  if (ord(header[h_flags]) and f_toglvpravo)>0 then anox4:=195 div 4;

  1:
  if now.handle<>0 then errorhalt(101);
  if now.radek>254 then errorhalt(8);
  if not allocEMS16K((now.radek+1) shr 1,now.handle) then if FreeMoreEMS then goto 1 else ErrorHalt(3);

 {kresli stranku do ems}
  now.buttonu:=0;
  case header[h_textura] of 'z':;
                            'y':PlaceNopeTexture(0);
                            'x':PlaceSetupTexture;
                            'h':PlaceHvezdyTexture;
                           else PlaceNormalTexture(ord(header[h_textura])-ord('a'));
                           end;
  ii:=1;
  while edi<=edtextlast do case edtext[edi] of

        TOGL:begin
             inc(togglu);
             with toggle[togglu] do begin y1:=16*(ii-1);on:=0;end;
             asm push pixstart;push pixlen
                 mov ax,pixstart;add pixlen,ax
                 mov ax,anox4;shl ax,2;add ax,30;mov pixstart,ax
                 sub pixlen,ax
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
      DRAZKA:begin
             inc(edi);
             reframe(ii);
             asm
                {set all 4 bits}
                mov ax,0f02h;mov dx,3c4h;out dx,ax
                {draw it}
                mov es,framewriseg
                mov di,pixStart;add di,6*wrisir
                mov bx,pixlen
                mov dx,bx;shr bx,1
                mov dx,wrisir;sub dx,pixLen
                mov ax,257*20
                mov cx,bx;rep stosw;add di,dx
                mov ax,257*21
                mov cx,bx;rep stosw;add di,dx
                mov cx,bx;rep stosw;add di,dx
                mov ax,257*20
                mov cx,bx;rep stosw
                end;
             end;
  SVISLALINE:begin
             inc(edi);
             bokyRamecku:=not bokyRamecku;
             ramecekStart:=pixStart;
             ramecekLen:=pixLen;
             if (ord(header[h_flags]) and f_color_ram)>0 then ramecekColor:=mixbyte else ramecekColor:=24;
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
             asm push minifnt;end;
             minifnt:=2;
             DrawLine;
             asm pop minifnt;end;
             inc(ii);
             end;

      TABULKA:begin
             inc(edi);
             2:
             inc(ii);
             reframe(ii);
             j:=readpixlength(':',ofs(TenkejPropsir)-32);
             wordX:=pixMid-j;
             mixbyte:=24;
             while edi<edtextlast do case edtext[edi] of
                              #13:begin
                                  inc(edi,2);
                                  if edtext[edi]=INSBIGCHAR then goto 7;
                                  goto 2;
                                  end;
                              ' ':begin
                                  inc(wordX,pixMinicharSir);
                                  if wordX>pixMid then mixbyte:=16;
                                  inc(edi);
                                  end;
                             else OneMiniWord;
                             end;
             7:
             end;

      INSPIC:begin
        inc(edi);
        st:=ReadLine;
        if pos('.fli',st)>0 then with now do begin
          NextEdiLine;
          FLIinside:=st;
          FLIx:=pixMid;
          FLIy:=ii*16;
          st:=ReadLine;
          GetVarFromString(st,inFLIx);
          GetVarFromString(st,inFLIy);
          GetVarFromString(st,inFLIsir);
          GetVarFromString(st,inFLIvys);
          GetVarFromString(st,FLIpozadi);
          GetVarFromString(st,FLIlet);
          inc(ii,2);
          end
else begin
        case st[1] of '-':begin doublescan:=1;doublex:=2;end;
                      'Ý':begin doublescan:=4;doublex:=2;end;
                      '.':begin doublescan:=1;doublex:=1;end;
                      'Û':begin doublescan:=4;doublex:=4;end;
                      '|':begin doublescan:=2;doublex:=1;end;
                      'Ü':begin doublescan:=2;doublex:=4;end;
                     else begin doublescan:=2;doublex:=2;end;
                     end;
        case st[1] of '-','.','|','Û','Ü','Ý':st:=copy(st,2,200);end;
        if OpenDataFile(st)=0 then begin
          xsir:=320;xvys:=200;barevw:=1;
{$ifdef datainside}
          {kdyz je obazek v chybejicim pridavnym datafajlu,
           tak aspon nastavi spravnou velikost}
          j:=1;
          while st<>data[j].name do begin inc(j);if j>datafajlu then goto 9;end;
          xvys:=data[j].picy;
          9:
{$endif}
          asm push edi;mov al,mixbyte;push ax;end;
          edi:=ofs(chybi)+3;
          reframe(ii+xvys*doublescan div 32-2);
          drawline;
          reframe(ii+xvys*doublescan div 32);
          drawline;
          asm pop ax;mov mixbyte,al;pop edi;end;
          inc(ii,(xvys*doublescan div 2-1) div 8);
          end
         else begin              {----Loudovani headeru a palety----}
         {$IFDEF datainside}
          packedZbyvasize:=lastopenLength;
          j:=1;
          while st<>data[j].name do inc(j);
          with data[j] do begin
            xsir:=picx;
            xvys:=picy;
            barevb:=colors;
            inc(now.palet);
            now.jakapaleta  [now.palet]:=j;
            now.kdepaletaTop[now.palet]:=16*(ii-1)-visvys;
            now.kdepaletaBot[now.palet]:=16*(ii-1)+doublescan*xvys;
            {aby nowpal byla opravdu paleta od nehornejsiho obrazku nehlede na pomichany sloupce}
            if now.kdepaletaBot[now.palet]<now.kdepaletaBot[now.nowpal] then now.nowpal:=now.palet;{}
            end;
         {$ELSE}
          packedZbyvasize:=LengthDataFile;
          ReadDataFile(5,ofs(xsir),dseg);
{          ReadDataFile(3*barevw,ofs(pal)+768-3*barevw,dseg);{}
          {naalokuje pamet pro paletu}
          nexttry:
          asm mov ax,barevw;mov bx,ax;add bx,ax;add bx,ax
              add bx,15;shr bx,4
              mov ah,48h;int 21h
              jnc @ok;mov ax,0;@ok:mov j,ax;{j=segment adresy palety}end;
          if j<>0 then begin {podarilo se naalokovat pamet}
            inc(now.palet);
            {paletu z headeru precte do editorovskyho seznamu palet}
            ReadDataFile(3*barevw,0,j);
            now.kdepaletaSeg[now.palet]:=j;
            now.pocetbarev  [now.palet]:=barevb;
            now.kdepaletaTop[now.palet]:=16*(ii-1)-visvys;
            now.kdepaletaBot[now.palet]:=16*(ii-1)+doublescan*xvys;
            {aby nowpal byla opravdu paleta od nehornejsiho obrazku nehlede na pomichany sloupce}
            if now.kdepaletaBot[now.palet]<now.kdepaletaBot[now.nowpal] then now.nowpal:=now.palet;{}
            end
           else if freemoreconv then goto nexttry {tady ten errorhalt muzu smazat,
           misto nej to pouze bude ignorovat paletu jednoho pikcru} else errorhalt(6);
         {$ENDIF}            {------loudovani bitmapbody--------}
          if pixMid<xsir*doublex div 4 then leftStart:=0 else leftstart:=pixMid-xsir*doublex div 4;

          packedStart    :=32768;
          packedEnd      :=32768;
          rawEnd         :=0;
          rawPacksize    :=16*xsir; {kolik bajtu zobrazit v tomto zatahu}
          rawPackradek   :=16;      {kolik radek zobrazit v tomto zatahu}
          rawZbyvaradek  :=xvys;    {kolik radek jeste zbyva zobrazit}
          xcommand       :=20;{256-barevb;}

          repeat
            if rawPackradek>rawZbyvaradek then begin
              rawPackradek:=rawZbyvaradek;
              rawPacksize :=rawPackradek*xsir;
              end;
            {kdyz uz musi neco nacist, tak z disku precte co nejvic komprimatu}
            if packedEnd-packedStart<rawPacksize+2 then begin
              {nerozpakovanej zbytek presune na adr 32768}
              FastMoveBack(packedStart,32768,packedEnd-packedStart);
              dec(packedEnd,packedStart-32768);
              packedStart:=32768;
              {doplni to do 65534}
              precist:=65535-packedEnd;
              if precist>packedZbyvasize then precist:=packedZbyvasize;
              ReadDataFile(precist,packedEnd,workseg);
              inc(packedEnd,precist);
              dec(packedZbyvasize,precist);
              end;
            {NEW: rozpakuje asi tak 16 radek}
            asm mov si,packedStart;mov di,rawEnd
                mov ah,xcommand
                mov bx,rawPacksize
                PUSH DS;mov es,workseg;mov ds,workseg
                 @next:
                 lodsb
                 cmp al,1;jz @decom1
                 cmp al,2;jz @decom2
                 stosb
                 @zastos:cmp di,bx;jc @next;jmp @pop
                 @decom1:lodsb;mov ch,0;mov cl,al;lodsb;jmp @doit
                 @decom2:lodsw;mov cx,ax;lodsb;add di,cx;sub di,cx;jnc @doit
                 @napul:sub si,3;sub cx,5000;mov [si],cx;dec si;mov cx,5000;
                 @doit:rep stosb;
                 jmp @zastos
                @pop:
                POP DS
                mov packedStart,si
                mov rawEnd,di
                end;
            insertpicture(leftStart,ii,xsir,rawPackradek,doublescan,doublex);
            inc(ii,rawPackradek*doublescan div 16);
            FastMoveBack(rawPacksize,0,rawEnd-rawPacksize);
            dec(rawEnd,rawPacksize);
            dec(rawZbyvaradek,rawPackradek);
          until rawZbyvaradek=0;

(* nacteni a zobrazeni NEzkomprimovaneho obrazku

          maxradek:=(65535 div xsir) and $fff8;
          zbyvaradek:=xvys;
          repeat
            if maxradek>zbyvaradek then maxradek:=zbyvaradek;
            ReadDataFile(xsir*maxradek,0,workseg);
            insertpicture(leftStart,ii,xsir,maxradek,doublescan,halve_x);
            inc(ii,maxradek*doublescan div 16);
            dec(zbyvaradek,maxradek);
          until zbyvaradek=0;
*)
          CloseDataFile;
          end;
end;{of zpracovani .x}
        NextEdiLine;
        end;

      INSBIGCHAR,INSBUTTON:begin
        m:=edi;
        inc(edi);
        case edtext[edi] of 'a'..'z':begin font:=1;method:=ord(edtext[edi])-ord('a');size:=4;end;
                            'A'..'Z':begin font:=2;method:=ord(edtext[edi])-ord('A');size:=8;end;
                            end;
        case edtext[edi+1] of '-':size:=2;
                            end;

        if size=2 then InsertBardString2Ems(method,pixMid,ii,edi+2,k0,titlesir)
                  else begin

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

  if konvert then begin
    dec(now.radek,2);
    KonvertScreen;
    for j:=1 to togglu do ano(toggle[j].y1,0);
    for j:=1 to askstringu do oneaskstring(j);
    xorcursor(false);
    end;

End;




FUNCTION F1:Boolean;begin f1:=(now.visy>=16*wriy+24) and (wriy<now.radek);end;
FUNCTION F2:Boolean;begin f2:=(now.visy< 16*wriy+ 8) and (wriy>0        );end;


{$ifdef midas}
var visbottom:integer;
    reg7:byte;
const lastshoot:byte=0;
      shootlen=15;
PROCEDURE TimerLastScreen;far;
const delaytime:word=0;
var i:integer;
begin
  if delaytime>0 then begin
    dec(delaytime);
    exit;
    end;
  if LastScreenCounter<>129 then inc(LastScreenCounter);
  case LastScreenCounter of 1..128:begin
                                   setbright(256-2*LastScreenCounter);
                                   midasMastervolume(soupatkopos[0]*(331-LastScreenCounter) div 331);
                                   case LastScreenCounter of 1:begin
                                                               playsample(sam_konec);inc(samplerate[sam_konec],500);end;
                                                            33:stopsample;
                                                            49:playsample(sam_konec);
                                                            end;
                                   end;
                          131..331:begin
                                   i:=LastScreenCounter-231;
                                   now.visy:=round(i*i div 18);
                                   visbottom:=100*100 div 18-now.visy;
                                   if visbottom>479 then visbottom:=479;
                                   asm {bottom end}
                                    mov dx,3d4h;mov ax,visbottom;mov ah,al;mov al,12h;out dx,ax
                                    mov dx,3d4h;mov ah,reg7;test visbottom,256;jz @not8;or ah, 2;@not8:
                                    test visbottom,512;jz @not9;or ah,64;@not9:mov al,7;out dx,ax
                                    end;
                                   inc(now.visy,1024);
                                   SmoothSetvis(now.visx,now.visy);
                                   midasMastervolume(soupatkopos[0]*(331-LastScreenCounter) div 331);
                                   if lastshoot>0 then dec(lastshoot);
                                   if (lastshoot=0) and (i<100-shootlen) and (random(15)=0) then begin
                                     playsample(sam_shoot);
                                     lastshoot:=shootlen;
                                     i:=128*(160+random(512-2*160))
                                           +(40+random(128-2*40));
                                     asm
    {bank 0}
     mov al,0;call bank

    {save vga ports}
     call ports2ax;push ax

    {zaverecny strileni}
     mov es,sega000
     lea si,dira
     mov di,i
     mov dx,3c4h
     mov ah,1
     mov cx,4
    @loop:
     push cx

     mov al,2;out dx,ax{->write}
     shl ah,1

     mov al,0
     mov cx,16
    @1:
     cmp [si],al;jnz @skip1;mov [es:di],al;@skip1:add si,4;inc di;
     cmp [si],al;jnz @skip2;mov [es:di],al;@skip2:add si,4;add di,wrisir/4-1
     loop @1
     sub di,4*wrisir
     sub si,16*8-1

     pop cx;loop @loop

    {restore vga ports}
     pop bx;call bx2ports
     end;

                                     end;
                                   end;
                          end;
end;
{$endif}

PROCEDURE VygenerujHvezdnouPaletu(show:boolean);
const longstar:integer=0;
var   i:byte;
begin
 inc(longstar);
 for i:=0 to 3*12-1 do pal[75+i]:=abs((8*i+longstar) mod 256-128) shr 2;
 for i:=0 to    4-1 do begin
  pal[75+3*12+3*i+1]:=abs((64*i+longstar) mod 256-128)*3 shr 3;
  pal[75+3*12+3*i+2]:=abs((64*i+longstar) mod 256-128)*3 shr 3;
  end;
 if show then showpal(25,16);
end;

PROCEDURE TimerScrolling;far;
var   ii:byte;
      i,j,k,l,deltax,deltay,faktor:integer;
      poradi:array[1..5] of char;
const inside:byte=0;
      waittohvezdicky:word=300;
      hvxy:word=0;
      smerOdMysi:byte=0;
      pirs=8;
      pirX:array[0..pirs-1] of word=(0,80,160,240,0,80,160,240);
      pirY:array[0..pirs-1] of word=(1,1,1,1,81,81,81,81);
      pirVys=80;
      pirSir=80;


procedure StoreMouseAndEms;
begin
 asm {save emm status}mov ax,4700h;mov dx,now.handle;int 67h;end;
 l:=mouseactive;mouseactive:=0;k:=mouseflag;mouse(0);
end;

procedure RestoreMouseAndEms;
begin
 mouse(k);mouseactive:=l;
 asm {restore emm status}mov ax,4800h;mov dx,now.handle;int 67h;end;
end;

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

 if cukajiciScrol then poradi:='vkohf' else poradi:='kovhf';
{ 1=ovk,kov,okv
  2=vko,vok,kvo}
 for ii:=1 to sizeof(poradi) do case poradi[ii] of

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

     {palety}
     if suny[sunindex]>0 then begin
      for i:=1 to now.palet do
       if (now.kdepaletaTop[i]<now.visy)<>(now.kdepaletaTop[i]<j) then SetAndVisUpperPal(i,1{visualize});end else
     if suny[sunindex]<0 then
      for i:=1 to now.palet do
       if (now.kdepaletaBot[i]<now.visy)<>(now.kdepaletaBot[i]<j) then SetAndVisUpperPal(i,1{visualize});
     sunx[sunindex]:=0;
     suny[sunindex]:=0;
     end;

  if sunindex<setrvacnost-1 then inc(sunindex) else sunindex:=0;
  end;

  'v':
  {---ve spravny okamzik nastavi vis}
  if (now.visx<>lastvisx) or (now.visy<>lastvisy) then begin
     SmoothSetvis(now.visx,now.visy);
     lastvisx:=now.visx;
     lastvisy:=now.visy;
     end;

  'k':
  {---ve spravny okamzik kresli pozadi na obrazovku}
  if f1 or f2 then begin
    StoreMouseAndEms;
    while f1 or f2 do begin
      if f1 then begin inc(wriy);Ems2Screen(wriy+31);end;
      if f2 then begin dec(wriy);Ems2Screen(wriy   );end;
      end;
    RestoreMouseAndEms;
    end;

  'f':begin

   with flihead do if fliseg>0 then if delaj>1 then dec(delaj) else begin
    delaj:=speed+1;
    inc(longtimer);
    StoreMouseAndEms;
    with now do
     FLIframe2screen(width,inFLIx,inFLIy,inFLIsir,inFLIvys,FLIpozadi,
             now.FLIx-inFLIsir shr 1+round(40*(  sin(longtimer/15))),
             now.FLIy shr 1         +round(20*(1+sin(longtimer/20))));
    RestoreMouseAndEms;
    if nowFLIframe<frames then inc(nowFLIframe)
                          else begin nowFLIframe:=1;frame1seg:=frame2seg;frame1ofs:=frame2ofs;end;
    prepareFLIframe;
    end;

   with flihead do if now.pir>0 then if delaj>1 then dec(delaj) else with now do begin
    delaj:=speed+1;
    inc(longtimer);
    inc(smerodmysi);
    deltax:=round(-pirSir shr 1+now.mousex+now.visx+round(100*cos(smerodmysi/128*pi))-now.FLIx);
    deltay:=round(-pirVys shr 1+now.mousey+now.visy+round(100*sin(smerodmysi/128*pi))-now.FLIy);
    faktor:=abs(deltax)+abs(deltay);
    if faktor<50 then inc(faktor,7);
    inc(FLIx,deltax shl 1 div faktor);if FLIx>60000 then inc(FLIx,wrisir);
    inc(FLIy,deltay shl 1 div faktor);if FLIx>60000 then FLIx:=0;
    StoreMouseAndEms;
    FLIframe2screen(320,pirX[nowFLIframe],pirY[nowFLIframe],pirSir,pirVys,0,
                    FLIx,FLIy shr 1);
    RestoreMouseAndEms;
    nowFLIframe:=(nowFLIframe+1) mod pirs;
    end;

   end;

  'h':if header[h_textura]='h' then VygenerujHvezdnouPaletu(true);

  end;


 {# hvezdicky}
 if now.fl='credits' then begin
   dec(waittohvezdicky);
   case waittohvezdicky of 5:begin
                             hvxy:={hvx}(random(wrisir)) shr 2+{hvy}(random(visvys)) shl 7;
                             hvezdicky(hvxy);
                             end;
                           0:begin
                             hvezdicky(hvxy);
                             waittohvezdicky:=20+random(100);
                             end;
                           end;
   end;

 asm
    {restore vga ports}
     pop bx;call bx2ports
     end;

 dec(inside);
 end;
end;

{$ifdef pareniste}
FUNCTION Password:byte;
var   i:byte;
      ofss:word;
const a0=$a0;
      passw:array[1..18] of char=
       chr(a0 xor ord('R'))+chr(a0 xor ord('I'))+chr(a0 xor ord('P'))+chr(a0 xor ord('R'))+chr(a0 xor ord('I'))+
       chr(a0 xor ord('P'))+chr(a0 xor ord('R'))+chr(a0 xor ord('I'))+chr(a0 xor ord('P'))+
       chr(a0 xor ord('U'))+chr(a0 xor ord('F'))+chr(a0 xor ord('O'))+chr(a0 xor ord('N'))+chr(a0 xor ord('B'))+
       chr(a0 xor ord('E'))+chr(a0 xor ord('D'))+chr(a0 xor ord('L'))+chr(a0 xor ord('A'));
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
{$endif}

{$ifdef setup}
PROCEDURE CentralFrame(mysize:word;mycolor:byte);assembler;
var levohore,bit,paneldowny,paneltopy,oldDS:word;
    mybit:byte;
 asm
   mov oldDS,DS
   mov ax,mysize;inc ax;add ax,ax;
   mov bx,ax;add bx,panelcentry;mov paneldowny,bx
   neg ax;add ax,panelcentry;mov paneltopy,ax
  {si=adresa kousku bitmapy pozadi}
   mov si,mysize;shl si,1;add si,offset OfsofFrameInSetupbitmap;mov si,[si];

  {es:di=pocatecni adresa leveho horniho rohu panelu}
   mov di,panelcentry;shl di,7{wrisir};add di,panelcentrx4;
   mov ax,mysize;mov bx,ax;shr ax,2;sub di,ax;inc bx;neg bx;and bl,3;mov mybit,bl;
   mov ax,mysize;shl ax,8{wrisir};sub di,ax;mov levohore,di
   add ax,ax;mov bx,ax
   mov es,sega000

   PUSH DS;mov DS,frameseg

  {leva svisla cara}
   mov al,mybit;dec al;mov byte ptr bit,al
   call @incbitsetbit
   mov al,mycolor
   mov cx,mysize;shl cx,2;add cx,3
   mov di,levohore
   cmp mysize,0;jz @middle
   or al,al;jnz @nextpix2bBANK

   @nextpix2aBANK:call @svislejbanking;jmp @nobank2a
   @nextpix2a:lodsb;mov [es:di],al;add di,wrisir/4;jc @nextpix2aBANK;@nobank2a:loop @nextpix2a
   jmp @za2

   @nextpix2bBANK:call @svislejbanking;jmp @nobank2b
   @nextpix2b:      mov [es:di],al;add di,wrisir/4;jc @nextpix2bBANK;@nobank2b:loop @nextpix2b
   @za2:

  {vodorovny cary}
   mov al,mybit;mov byte ptr bit,al
   mov al,mycolor
   mov cx,mysize;shl cx,1;dec cx;
   mov di,levohore
   add di,bx;sub di,bx;jnc @1stranka
   cmp viditelnychBanku,2;jnc @2stranky

   {obe vodorovny v jedny strance}
   @1stranka:
   or al,al;jnz @nextpix1b
   @nextpix1a:
   call @incbitsetbit
   lodsw;mov [es:di            ],al
         mov [es:di   +wrisir/4],ah
   lodsw;mov [es:di+bx         ],al
         mov [es:di+bx+wrisir/4],ah
   loop @nextpix1a
   jmp @zavodorovny
   @nextpix1b:
   call @incbitsetbit
   mov [es:di            ],al
   mov [es:di   +wrisir/4],al
   mov [es:di+bx         ],al
   mov [es:di+bx+wrisir/4],al
   loop @nextpix1b
   jmp @zavodorovny

   {vodorovny v ruznejch strankach}
   @2stranky:
   push ax;mov ax,paneltopy ;add ax,2;shr ax,9;mov DS,oldDS;call bank;mov DS,frameseg;pop ax
   push bit
   push di
   push si
   push cx
   or al,al;jnz @jednobarevna

   call @vodorovnalajna_spozadim
   pop cx
   pop si;inc si;inc si
   pop di;add di,bx
   pop bit
   push ax;mov ax,paneldowny;dec ax;shr ax,9;mov DS,oldDS;call bank;mov DS,frameseg;pop ax
   call @vodorovnalajna_spozadim
   jmp @za0

   @jednobarevna:
   call @vodorovnalajna_jednobarevna
   pop cx
   pop si;inc si;inc si
   pop di;add di,bx
   pop bit
   push ax;mov ax,paneldowny;dec ax;shr ax,9;mov DS,oldDS;call bank;mov DS,frameseg;pop ax
   call @vodorovnalajna_jednobarevna

   @za0:
   sub di,bx
   dec si;dec si

   @zavodorovny:

  {prava svisla cara}
   mov cx,mysize;shl cx,2;inc cx
   mov di,levohore;mov ax,mysize;shr ax,1;add di,ax
   mov al,mycolor
   or al,al;jnz @nextpix3bBANK

   @nextpix3aBANK:call @svislejbanking;jmp @nobank3a
   @nextpix3a:lodsb;mov [es:di],al;add di,wrisir/4;jc @nextpix3aBANK;@nobank3a:loop @nextpix3a
   jmp @za3

   @nextpix3bBANK:call @svislejbanking;jmp @nobank3b
   @nextpix3b:      mov [es:di],al;add di,wrisir/4;jc @nextpix3bBANK;@nobank3b:loop @nextpix3b
   @za3:

   jmp @99

{inc bit, set bit}
@incbitsetbit:
   push ax;push cx;push dx
   mov cl,byte ptr bit;inc cx;cmp cl,4;jc @ouk;mov cl,0;inc di;@ouk:mov byte ptr bit,cl
   mov ax,102h;shl ah,cl;mov dx,3c4h;out dx,ax
   pop dx;pop cx;pop ax
   ret

{banking svislych car - souradnice se pocita podle CX}
@svislejbanking:
   push ax;mov ax,paneldowny;sub ax,cx;inc ax;shr ax,9;mov DS,oldDS;call bank;mov DS,frameseg;pop ax
   ret

{kresli jednu vodorovnou lajnu 2 pixely vysokou}
@vodorovnalajna_jednobarevna:
   call @incbitsetbit
   mov [es:di            ],al
   mov [es:di   +wrisir/4],al
   loop @vodorovnalajna_jednobarevna
   ret

{kresli jednu vodorovnou lajnu 2 pixely vysokou}
@vodorovnalajna_spozadim:
   call @incbitsetbit
   lodsw;mov [es:di            ],al
         mov [es:di   +wrisir/4],ah
   inc si;inc si
   loop @vodorovnalajna_spozadim
   ret


   @middle:
   or al,al;jnz @midb
   movsb;add di,wrisir/4-1;movsb;jmp @99
   @midb:mov [es:di],al;mov [es:di+wrisir/4],al

   @99:
   POP DS
   end;
{$endif}

{$ifdef pareniste}
var ripname0:string[13];
PROCEDURE Rip(n:byte);
var zbyvalen:longint;
    nowlen,hendl,saveofs1,saveofs2,colors3:word;
begin
with data[n] do begin
 ripname0:=name+#0;
 zbyvalen:=len;
 nowlen:=65535;
 opendatafile(Name);
 asm
 {open dest}
  mov ax,3c00h;mov cx,0;mov dx,offset ripname0+1;int 21h;mov hendl,ax
 end;
 {sejvnuti headeru a palety}
 if picx>0 then begin
   saveofs1:=ofs(picx);
   saveofs2:=palofs;
   colors3:=3*colors;
   asm
   {write header}
    mov bx,hendl;mov dx,saveofs1;mov cx,5
    mov ah,40h;int 21h;
   {write pal}
    mov bx,hendl;mov dx,saveofs2;mov cx,colors3
    push ds;mov ax,cs;mov ds,ax;mov ah,40h;int 21h;pop ds;
    end;
   end;
 {sejvnuti zbytku}
 repeat
   if nowlen>zbyvalen then nowlen:=zbyvalen;
   readdatafile(nowlen,0,workseg);
   asm
   {write data}
    mov bx,hendl;mov dx,0;mov cx,nowlen
    push ds;mov ds,workseg;mov ah,40h;int 21h;pop ds;
   end;
   dec(zbyvalen,nowlen);
 until zbyvalen=0;
 asm
 {close dest}
  mov bx,hendl;mov ah,3eh;int 21h;
 end;
end;end;
{$endif}


{$ifdef midas}
PROCEDURE LoadSample(i:byte);
begin
 if sampleLoaded[i]=0 then with data[i+predsamplama] do
  if opendatafile(name)>0 then begin
    readdatafile(len,0,workseg);
    midasLoadsample(@mem[workseg:0],len,i);
{    removesample(i);
    midasLoadsample(@mem[workseg:0],len,i);
    removesample(i);
    midasLoadsample(@mem[workseg:0],len,i);}
    {*if mpinit=true then begin
         playsample(i);
         stopsample;
         end;}
    end;
end;

PROCEDURE Music(n:byte);
label 6;
begin
                    if n=102 then playingiron:=true else playingiron:=false;
                    midasStopModule;{ stop playing }
                    6:
                    outof:=0;
                    midasPlayModule(n,outof); { load module and start playing }
                    if (outof=2) and FreeMoreConv then goto 6;
                    midasFXvolume(soupatkopos[1]);
                    midasMastervolume(soupatkopos[0]);
end;
{$endif}

PROCEDURE Show(name:string);
const decode:array[2..57] of char=(
        '1','2','3','4','5','6','7','8','9','0','-','=',#0,
        #0,'Q','W','E','R','T','Y','U','I','O','P','[',']',#0,
        #0,'A','S','D','F','G','H','J','K','L',';','''',
        #0,#0,'\','Z','X','C','V','B','N','M',',','.','/',
        #0,#0,#0,' ');
      keyadd=256;
      panelcolors=3;
      panelcolor:array[0..panelcolors] of byte=(0,0,0,21);
      lastpanelcolor:array[0..4] of byte=(19,20,21,20,19);
      setupdrawn:byte=0;
      souping:boolean=false;
      lastkey:integer=10000;
var   i,j,n,size,vistop:integer;
      k,l,m:word;
      nowfram8kpiece,topfram8kpiece,topsrc,downsrc:word;
      old_dotaznikkeypressed,panely16,panelx4,mustahlo,fxtahlo:integer;
      levohore,bit,panelsize:word;
{$ifdef editor}
const unstable:byte=0;
var   stable:byte;
      r1,r2,g1,g2,b1,b2:byte;
      delta:shortint;
label setcol,itisbadkey;
{$endif}
label 1,2,3,4,5,8,rightbutton,leftbutton,noglobal,pan
      {$ifdef setup},midbutton,closesetup{$endif};

procedure soupingend;
begin
 souping:=false;
 mouseactive:=0;mouse(0);
 getmouse(now.mousex,now.mousey,m);
 now.mousex:=now.mousex div 2;
 mouse(1);mouseactive:=1;
end;

Begin

  mode13x;
{$ifdef pareniste}
  Execute0('fix.com'#0);
{$endif}
  InitBank;

{  PortW[$3C4] := $EA06;
  asm
      mov dx,3c4h;mov al,0f6h;out dx,al;inc dx;in al,dx;mov ah,al
      mov dx,3c4h;mov al,0f6h;out dx,al;inc dx;mov al,ah;or al,64+128;out dx,al;
      end;
  PortW[$3C4] := $AE06;
  {}

  setbright(0);
  InstallMouse;
  NastavCitlivostmysi;
  lastkey:=0;

{$ifdef midas}
  scanS3Mfilenames;
  midasInit;                          { initialize MIDAS Sound System }
  tmrGetScrSync(PtmrScrSync);
{  midasInitEffectChan;}
  for i:=1 to samplu do {*if (i<>sam_konec) and (i<>sam_shoot) then} loadsample(i);
  OutOf:=1;
  midasPlayModule(1,OutOf); { load module and start playing }
  midasFXvolume(soupatkopos[1]);
  midasMastervolume(soupatkopos[0]);
{$endif}

  if irqon then port[$21]:=mask;

{$ifdef setup}
 if setupdrawn=0 then begin
  setupdrawn:=1;
  ResetToDefaults(now);now.fl:='innerset';
  PREPARESCREEN(false);
  i:=0;
  for size:=0 to setupsize do begin
    OfsofFrameInSetupbitmap[size]:=i;
    asm
      mov es,workseg;mov di,i
      mov ax,100;sub ax,size;mov si,ax;and si,7;shl si,10{2*wrisir};add si,wrisir/2+wrisir*16;sub si,size
      shr ax,3;mov nowfram8kpiece,ax;mov topfram8kpiece,ax;mov topsrc,si
      PUSH DS
{storne levou svislou caru}
      mov cx,size;shl cx,2;jz @middlepoint;add cx,2
     @nextbyte_reframe:
      POP DS;pusha;push nowfram8kpiece;call reframe;popa;inc nowfram8kpiece
      PUSH DS;mov ds,framewriseg;sub si,wrisir*16
     @nextbyte:
      movsb;add si,wrisir-1;test si,wrisir*16
      loopnz @nextbyte_reframe;jcxz @leftend;jmp @nextbyte
     @leftend:
{storne horni/dolni dve vodorovny cary}
      sub si,wrisir*2-1
      POP DS;pusha
        {reframe 2nd 16kb to the top 2 lines          topsrc=bx}
        {        1st 16kb uz je na dolnich 2 lines   downsrc=si}
         mov ax,frameseg;cmp ax,framewriseg;jz @ouk;sub topsrc,8*1024;@ouk:
         mov bx,topfram8kpiece;shr bx,1;jnc @startseg;add topsrc,8*1024;@startseg:
         mov ax,4401h;mov dx,now.handle;int 67h;
      popa
      PUSH DS;mov ds,framewriseg
      mov bx,topsrc;add bx,1+8*1024
      mov cx,size;shl cx,1;dec cx
     @nextbyte2:
      mov al,[bx];stosb;mov al,[bx+wrisir];stosb;inc bx
      movsb;mov al,[si+wrisir-1];stosb
      loop @nextbyte2
{storne pravou svislou caru}
      mov ax,topfram8kpiece;mov nowfram8kpiece,ax
      mov si,topsrc;add si,size;add si,size;dec si
      mov cx,size;shl cx,2
     @nextbyte_reframer:
      POP DS;pusha;mov ax,nowfram8kpiece
      push ax;call reframe;popa;inc nowfram8kpiece
      PUSH DS;mov ds,framewriseg;and si,wrisir*16-1
     @nextbyter:
      movsb;add si,wrisir-1;test si,wrisir*16
      loopnz @nextbyte_reframer;jcxz @99;jmp @nextbyter

@nowfram8kpiece: dw 0

@middlepoint:
      POP DS;pusha;push nowfram8kpiece;call reframe;popa
      PUSH DS;mov ds,framewriseg;sub si,wrisir*16
      movsb;add si,wrisir-1;movsb

@99:  mov i,di
      POP DS
      end;
    end;
  deallocEMSpage(now);
  Reframe2setupems;
  asm
     {copy workseg 2 setup_ems}
      mov es,frameseg;push ds;mov ds,workseg;mov si,0;mov di,0;mov cx,65536/4;db 66h;rep movsw;pop ds
      end;
  end;
{$endif}

  ResetToDefaults(tree[1]);
  tree[1].fl:=name;
  goto 2;


  1:
{$ifdef midas}
  tmrSyncScr(tmrScrSync,nil,nil,@timerBrightDown);
{$else}
  BrightDown;
{$endif}

  2:
  nowask:=0;
  nowaskx:=1;
  presz:=0;
  mouseactive:=0;mouse(0);
  for i:=0 to setrvacnost-1 do sunx[i]:=0;suny:=sunx;
  now:=tree[intree];
{$ifdef midas}
  if (now.fl='iron') and not playingiron then music(102);
{$endif}
  {kdyz neni pripravena screena tak ji pripravi}
  if now.handle=0 then begin PREPARESCREEN(true);tree[intree]:=now;end;
  {kdyz je na screene FLI, tak to pripravi}
  if now.FLIinside>'' then initFLI(now.FLIinside);
{$ifdef midas}
  {zrychleny stmivani}
  while nowbright>8 do begin
    i:=nowbright;
    repeat until nowbright<>i;
    case nowbright of 9..50:dec(nowbright,8);
                    51..100:dec(nowbright,6);
                   101..255:dec(nowbright,4);
                   end;
    end;
  tmrStopScrSync;
{$endif}
{$ifdef editor}
  if palmysozmena and (intree=1) then ppp.palabsolute:=palmysozmeny;
  if pouzij_prevF3visy then begin
    now.visy:=prevF3visy;
    pouzij_prevF3visy:=false;
    end;
  {vyhledani aktualni picture palety pri pocatecnim y<>0}
  for i:=1 to now.palet do
   if (now.kdepaletaTop[i]<now.visy)<>(now.kdepaletaTop[i]<j) then now.nowpal:=i;
{$endif}
  {nastaveni picture palety}
  if now.palet>0 then SetAndVisUpperPal(now.nowpal,0{not vis});
  {nastaveni background palety}
  ppp.palabsolute:=now.pal40;
  if header[h_textura]='h' then VygenerujHvezdnouPaletu(false);
  if now.pir>0 then initPIR('flag.x');
  {etc...}
  wriy:=now.visy shr 4;
  SmoothSetvis(now.visx,now.visy);
  for i:=0 to 31 do Ems2Screen(wriy+i);
  MoveMouse;
  mouse(1);mouseactive:=1;
  BrightUp;

{$ifdef midas}
  tmrSyncScr(tmrScrSync,nil,nil,@timerScrolling);
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

   case lastkey of keyadd+75,keyadd+77,71..73,75,77,79..81,14,83:lastkey:=0;
                   keyadd+72,keyadd+80:if askstringu<=1 then lastkey:=0;end;
   if i<>lastkey then begin lastkey:=i;key:=i;end else key:=0;


   if dotaznikkeypressed>0 then dec(dotaznikkeypressed);

   {GLOBAL KEYS}
   CASE KEY OF
               (*{*}
               {$ifdef pareniste}
               19{r}:removesample(sam_togl);
               30{a}:loadsample(sam_togl);
               20{r}:removesample(sam_konec);
               31{a}:loadsample(sam_konec);
               {$endif}
               *)
               88:errorhalt(99);
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
{$ifdef setup}
               53:begin presx:=now.mousex;presy:=now.mousey;goto midbutton;end;
{$endif}
               70:begin
                  if setuping then with toggle[{#}2] do begin
                    on:=1-on;
                    mouseactive:=0;mouse(0);
                    ano(y1,on);
                    mouse(1);mouseactive:=1;
                    end;
                  asm {prehodi svetylko scrollock}
                      xor locks,1;xor scrolllock,1
                      {$ifdef midas}
                      call midaslightlocks;
                      {$else}
                      call lightlocks;
                      {$endif}
                      end;
                  end;

{$ifdef editor}
                 32:if intree=1 then begin{full pal 2 defaults}
                    ppp.palabsolute:=txtpal;
                    palmysozmeny:=ppp.palabsolute;
                    palmysozmena:=true;
                    showpal(1,255);
                    end;
                 31:if intree=1 then begin{system pal 2 defaults}
                    for i:=3*13 to 3*24+2 do ppp.palabsolute[i]:=txtpal[i];
                    palmysozmeny:=ppp.palabsolute;
                    palmysozmena:=true;
                    showpal(1,255);
                    end;
              44,45:if intree=1 then begin
                    if key=44 then j:=17 else j:=15;
                    for i:=3*25 to 3*40+2 do begin
                      k:=ppp.palabsolute[i] shl 4 div j;
                      if k>63 then k:=63;
                      ppp.palabsolute[i]:=k;
                      end;
                    palmysozmeny:=ppp.palabsolute;
                    palmysozmena:=true;
                    showpal(1,255);
                    end;
             10..13:if intree=1 then begin
                    stable:=key-1;
                    unstable:=stable;
                    goto setcol;
                    end;
        2..9,15..30:if intree=1 then if unstable=0 then begin
                      setcolor(0,30,30,30);
                      if key<14 then unstable:=key-1
                                else unstable:=55-key{key+10};
                      end
                    else begin
                      if ((unstable<13) and (key>13)) or
                         ((unstable>12) and (key<14)) then goto ItIsBadKey;
                      setcol:
                      setcolor(0,0,0,0);
                      if key<14 then stable:=key-1
                                else stable:=55-key{key+10};
                      r1:=pal[3*stable  ];
                      g1:=pal[3*stable+1];
                      b1:=pal[3*stable+2];
                      b2:=32;
                      repeat
                        getmouse(k,l,m);
                        case m of 1:if b2>0 then dec(b2);
                                  2:if b2<63 then inc(b2);
                                  end;
                        r2:=k*31 div vissir;
                        g2:=l*63 div visvys;
                        i:=stable;
                        if stable<unstable then delta:=1 else delta:=-1;
                        repeat
                          if stable=unstable then n:=100
                                             else n:=100*(i-stable) div (unstable-stable);
                          pal[3*i  ]:=(n*r2+(100-n)*r1) div 100;
                          pal[3*i+1]:=(n*g2+(100-n)*g1) div 100;
                          pal[3*i+2]:=(n*b2+(100-n)*b1) div 100;
                          inc(i,delta);
                        until i=unstable+delta;
                        refresh(1);
                        showpal(1,255);
                      until m>=3;
                      presz:=0;
                      setcolor(0,0,0,63);refresh(1);setcolor(0,0,0,0);
                      unstable:=0;
                      palmysozmeny:=ppp.palabsolute;
                      palmysozmena:=true;
                      ItIsBadKey:
                      end;
{$endif}

{$ifdef midas}
              2..11:if (askstringu=0) and not setuping then begin
                    hlasitosthudby:=63*(key-2) div 9;
                    midasMastervolume(hlasitosthudby);
                    end else goto noglobal;
             59..68:begin
                    playingiron:=false;
                    midasStopModule;{ stop playing }
                    3:
                    outof:=0;
                    midasPlayModule(key-58,outof); { load module and start playing }
                    if (outof=2) and FreeMoreConv then goto 3;
                    midasFXvolume(hlasitostefektu);
                    midasMastervolume(hlasitosthudby);
                    end;
{$endif}
               ELSE BEGIN noglobal:

   {DOTAZNIK KEYS}
   if {kdyz je jen 1 askstring, nepotrebuje sipky up/down}not ( (askstringu=1) and ((key=keyadd+80) or (key=keyadd+72)) )
     and (askstringu>0) then begin
    if dotaznikkeypressed>0 then begin
     i:=askstring[nowask].y16;
     if (i<wriy+3) then nahoru(20) else if (i>wriy+31-5) then dolu(20) else dotaznikkeypressed:=0;
     end;
    if (key>0) then begin
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
              else goto 8;
            end;
     i:=askstring[nowask].y16;
     if (i<wriy+3) or (i>wriy+31-5) then dotaznikkeypressed:=150 else dotaznikkeypressed:=0;
     i:=askstring[nowask].y16;
     OneAskString(nowask);
     if (i>=wriy) and (i<=wriy+31){neni mimo obraz} then ems2screen(i);
     8:
     xorcursor(true);
     mouse(1);mouseactive:=1;
     case key of
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
                 0:if souping then goto leftbutton;
              4,16:if souping then soupingend;
{$ifdef setup}
                32:midbutton:if setuping then goto leftbutton else BEGIN
                     {---OPEN SETUP PANEL---}
{$ifdef midas}
                     playsample(sam_setupon);
{$endif}
                     setuping:=true;
                     mouseactive:=0;mouse(0);
                     panelcentrx4:=now.visx div 4+vissir div 8;
                     panelcentry:=(now.visy+visvys div 2) and $fffe;
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
                     for togglu:=1 to setuptogglu do with toggle[togglu] do begin
                       {#}
                       y1:=panelcentry+32+20*2*togglu;
                       case togglu of 1:on:=byte(cukajiciscrol);
                                      2:on:=byte(scrolllock);
                                      end;
                       ano(y1,on);
                       end;
                     for i:=0 to soupatek do kreslisoupatko('k',i,soupatkopos[i]);
                     getmouse(now.mousex,now.mousey,m);
                     now.mousex:=now.mousex div 2;
                     mouse(1);mouseactive:=1;
                     buttonu2:=now.buttonu;    now.buttonu:=0;
                     askstringu2:=askstringu;  askstringu:=0;
                     presz:=0;
                   END;
{$endif}
                 8:BEGIN
                   rightbutton:
{$ifdef setup}
                   if setuping then begin closesetup:
                     {---CLOSE SETUP PANEL---}
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
                     end else
{$endif}
                   if now.fl<>title then begin
{$ifdef midas}
                     Playsample(sam_goback);
{$endif}
                     {---MENU BACK---}
                     {$ifdef editor}
                     {tohle je tu kvuli moznosti ukoncit editorF3 rightem,
                      v parenisti to rightem nejde}
                     if intree=1 then key:=1 else{}
                     {$endif}
                     begin
{$ifdef midas}
                       tmrStopScrSync;
                       if playingiron then music(101);
{$endif}
                       SaveAnketa;
                       DeallocEMSpage(now);
                       dec(intree);
                       goto 1;
                       end;
                     end;
                   END;

                 2:BEGIN
                   leftbutton:
{$ifdef editor}
                   prevF3visy:=0;
{$endif}
                   presz:=0;
                   {---klik do togglu---}
                   j:=now.visy+presy;
                   for i:=1 to togglu do with toggle[i] do if (j>=y1) and (j<y1+16) then begin
{$ifdef datainside}   {sejvnuti editoru}
                      if now.fl='ed' then begin rip(1{kit});presz:=8;end;
                      {sejvnuti cehokoliv z ripscreeny}
                      if now.fl='rip' then rip(i);
                      {sejvnuti dalsich blbosti}{#}
                      if now.fl='triky' then case i of 1:rip(rip_det_ems);
                                                       2:rip(rip_speaker);
                                                       end;
                      {exit button na title page}
                      if now.fl=title then key:=1;
{$endif}
{$ifdef midas}
                      if (tree[intree].fl=anketa) and ((i=7) or (i=11) or (i=14) or (i=26)) then Playsample(sam_blbce)
                                                                         else Playsample(sam_togl);
{$endif}
                      on:=1-on;
                      mouseactive:=0;mouse(0);
                      ano(y1,on);
                      if not setuping then ems2screenFromx4Sir8(y1 div 16,anox4,2);
                      mouse(1);mouseactive:=1;
{$ifdef setup}
                      if setuping then case i of
                              {#}
                              1:cukajiciscrol:=not cukajiciscrol;
                              2:begin
                                scrolllock:=not scrolllock;
                                locks:=locks xor 1;
                                lightlocks;
                                end;
                              end;
{$endif}
                      goto 5;
                      end;

                   {---klik do askstringu---}
                   j:=(now.visy+presy) shr 4;
                   if (presx+now.visx>askx4*4) and (presx+now.visx<askx4*4+askmaxlen*8) then
                     for i:=1 to askstringu do with askstring[i] do if y16=j then begin
                      mouseactive:=0;mouse(0);
                      xorcursor(true);
                      nowask:=i;
                      nowaskx:=1+(presx+now.visx-askx4*4) div 8;
                      xorcursor(true);
                      mouse(1);mouseactive:=1;
                      goto 5;
                      end;
{$ifdef setup}
                   {---klik do soupatka---}
                   if setuping then begin
                     getmouse(k,l,m);k:=k div 2;
                     for i:=0 to soupatek do
                      if (k>soupatkox[i]-10) and (k<soupatkox[i]+soupatkosir+10) and
                         (l>soupatkoy[i]   ) and (l<soupatkoy[i]+soupatkovys) then begin
                           mouseactive:=0;mouse(0);
                           kreslisoupatko('m',i,soupatkopos[i]);{obnovi pozadi}
                           soupatkopos[i]:=k-soupatkox[i];
                           if soupatkopos[i]<0 then soupatkopos[i]:=0;
                           if soupatkopos[i]>63 then soupatkopos[i]:=63;
                           souping:=true;
                           kreslisoupatko('k',i,soupatkopos[i]);
                           mouse(1);mouseactive:=1;
                           universalrefresh;
                           case i of
{$ifdef midas}
                                     0:midasMASTERvolume(hlasitosthudby);
                                     1:midasFXvolume(hlasitostefektu);
{$endif}
                                     2:;{rychlostscrollingu}
                                     3:NastavCitlivostmysi;
                                     end;
                           end;
                     if m=0 then soupingend;
                     goto 5;
                     end;
{$endif}
                   {---MENU FORWARD---}
                   {klik na prvni strance=posun na dalsi stranku}
                   if now.fl=title then begin i:=0;goto 4;end;
{$ifdef pareniste}
                   if password>0 then goto 4;
{$endif}
                   for i:=1 to now.buttonu do with now.bu[i] do
                     if (now.visx+presx>x1) and (now.visx+presx<x2) and (now.visy+presy>y1) and (now.visy+presy<y2) then begin
                      4:
                      {$ifdef midas}playsample(sam_goon);{$endif}
                      tree[intree]:=now;
                      inc(intree);
                      ResetToDefaults(tree[intree]);
                      tree[intree].fl:=now.bu[i].fi;
                      if i=0 then tree[intree].fl:=menu;
{$ifdef pareniste}
                     {hidden part}
                      case password of 2:tree[intree].fl:='rip';
                                       1:tree[intree].fl:='s1';
                                       end;
{$endif}
{$ifdef midas}
                      tmrStopScrSync;
{$endif}
                      goto 1;
                      end;

                   END;
           END;

   5:
   UniversalRefresh;

  until key=1;
{$ifdef setup}
  if setuping then begin key:=0;goto closesetup;end;
{$endif}
  SaveAnketa;


{---SETMENI & KONEC SCREEN U PARENISTE---}
{$ifdef pareniste}
  tmrStopScrSync;
{  for i:=1 to samplu do if (i<>sam_konec) and (i<>sam_shoot) then removesample(i);{}
{  loadsample(sam_konec);
{  loadsample(sam_shoot);                 }
  asm {read reg7}
    cli;mov dx,3d4h;mov al,7;out dx,al;inc dx;in al,dx;and al,255-2-64;mov reg7,al;sti
    end;
  {free some conv memory, load sam_konec}
  CONVbigfontDone;
  RemoveMouse;
  EMSvirtualpagesDone;

  {start fading down}
  tmrSyncScr(tmrScrSync,nil,nil,@timerLastScreen);

  {na pozadi si zatim kresli lastscreenu}
  ResetToDefaults(now);now.fl:='konec';
  PREPARESCREEN(true);

  {wait until faded down}
  repeat until LastScreenCounter=129;
{  playsample(sam_shoot);}

  {nastaveni background palety}
  ppp.palabsolute:=now.pal40;
  {nastaveni picture palety}
  if now.palet>0 then SetAndVisUpperPal(now.nowpal,0{not vis});
  {zkopceni obrazku z ems na screenu}
  for i:=0 to 31 do Ems2Screen(i);

  {start lastscreen move}
  LastScreenCounter:=130;
  repeat until LastScreenCounter>131;
  showpal(1,255);

  {wait until lastscreen done}
  repeat until LastScreenCounter>331;
  tmrStopScrSync;
  setbright(0);

{$else}
{---SETMENI u EDITORU---}
  brightdown;
  RemoveMouse;
  EMSvirtualpagesDone;
{$endif}

  port[$21]:=0;
  ExitBank;
End;


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
   mov bx,edhandle;mov cx,edtextlast;sub cx,offset header-1;lea dx,header;mov ah,40h;
   int 21h
  {close}
   mov bx,edhandle;mov ah,3eh;int 21h;
  {}
   mov edzmena,0
   @9:
   end;

PROCEDURE InsertSpaces(adr,kolik:word);assembler;
 asm {uprava EdText}
     mov ax,ds;mov es,ax
     mov si,edtextlast
     mov di,edtextlast;add di,kolik
     mov cx,edtextlast;sub cx,adr;inc cx
     std
     call speedyMOVS_dopredu_std_dec
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
     call speedyMOVS_dozadu_cld_inc
     {uprava edtextlast}
     mov ax,adr
     mov bx,kolik
     sub edtextlast,bx
     cmp blokstart,ax;jc @no1;sub blokstart,bx;@no1:
     cmp blokend  ,ax;jc @no2;sub blokend  ,bx;@no2:
     end;


const picu=10;
var picsizes:array[1..picu] of record name:string[13];x,y:word;end;
PROCEDURE GetPicSize(nejm:string;var xx,yy:word);
var i,doublescan,doublex:byte;
    code1,code2:word;
    st:string;
    anylong:longint;
label ex,nezkracovat;
begin
 if pos('.fli',nejm)>0 then begin xx:=0;exit;end;
 case nejm[1] of      '-':begin doublescan:=1;doublex:=2;end;
                      'Ý':begin doublescan:=4;doublex:=2;end;
                      '.':begin doublescan:=1;doublex:=1;end;
                      'Û':begin doublescan:=4;doublex:=4;end;
                      '|':begin doublescan:=2;doublex:=1;end;
                      'Ü':begin doublescan:=2;doublex:=4;end;
                     else begin doublescan:=2;doublex:=2;goto nezkracovat;end;
                     end;
 nejm:=copy(nejm,2,200);
 nezkracovat:
 for i:=1 to picu do with picsizes[i] do if nejm=name then goto ex;
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
  ex:
  xx:=x*doublex div 2;
  yy:=y*doublescan;
  if xx<20 then xx:=20;
  if yy<20 then yy:=20;
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
 if (ord(header[h_flags]) and f_vlastni_pal)>0 then inc(edi,122);
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
        if i>0 then begin{-----X-----}
          TextBox((pixMid-i div 2) div pixMinicharsir,ii,i div pixMinicharsir,j div 16,ord('±')+256*7);
          inc(ii,j div 16);
          asm mov al,wlcol;push ax;mov wlcol,7;end;
          WriteLine(ii-j div 32-1);
          asm pop ax;mov wlcol,al;end;
          end
         else begin{-----FLI-----}
          i:=200;
          TextBox((pixMid-i div 2) div pixMinicharsir,ii,i div pixMinicharsir,2,ord('±')+256*11);
          asm mov al,wlcol;push ax;mov wlcol,7;end;
          WriteLine(ii);
          WriteLine(ii+1);
          asm pop ax;mov wlcol,al;end;
          inc(ii,2);
          end;
        end;
      INSBIGCHAR,INSBUTTON:begin
        ch:=edtext[edi];
        c2:=edtext[edi+1];
        inc(edi,2);
        case c2 of 'A'..'Z':begin size:=8;end;
                   'a'..'z':begin size:=4;c2:=chr(ord(c2)+ord('A')-ord('a'));end;
                   end;
        if edtext[edi]='-' then size:=2;
        k:=7;
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
 asm push ds;mov es,segb800;mov ds,workseg;mov si,0;mov di,0;mov cx,16384/2;db 66h;rep movsw;pop ds;end;

 if 1+iimax<>ReadInteger(headerofs) then edzmena:=1;
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
        #13#10#13#10'intelektu ln¡ £rove¤, estetick˜ z ‘itek'#13#10+insbigchar+'p-*****'+
        #13#10#13#10'napˆt¡, ‡tivost, Mark Stone index'#13#10+insbigchar+'p-*****'#13#10#13#10#0;
      hod2:array[0..185] of char=
        {hra}#20+
        #13#10#13#10+mramor+''#13#10+tabulka+'tv–rce: '#13#10'druh: '#13#10'status: '#13#10+'testov no na: '+
        #13#10'existuje je¨tˆ na: '#13#10'velikost: '#13#10'po‘adavky na po‡¡ta‡: '#13#10+'grafika: '+
        #13#10'zvuk: '#13#10#13#10+'grafika: %'#13#10'hudba: %'#13#10'atraktivita: %'+
        #13#10#13#10#13#10+insbigchar+'p-*****'#13#10#13#10#0
        ;
var   i,j:word;
      m,n:integer;
      special:byte;
      st:string;
      st8:string[8];
      searchstring:string[20];
   {help}
      f:text;
      ch:char;

label 0,1,2,3,4,5,6,7,8,10,newodst;
Begin
 searchstring:='';
 for i:=1 to picu do picsizes[i].x:=0;
 edfajl:='';
 0:{new file}
 prevF3visy:=0;
 if pos('.',edfajl)>0 then edfajl[0]:=chr(pos('.',edfajl)-1);
 edfajl:=fileselect('Zadej pracovn¡ jm‚no ‡l nku...','*.',edfajl);

 if length(edfajl)=0 then errorhalt(0);
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

 if (header[h_free1]<>'0') or (header[h_free2]<>'0') then begin
   header[h_free1]:='0';
   header[h_free2]:='0';
   edzmena:=1;
   end;

 if palmysozmena then begin
   palmysozmena:=false;
   ppp.palabsolute:=palmysozmeny;
   for i:=0 to 119 do edtext[edtextofs+i]:=chr(pal[3+i]+32);
   edzmena:=1;
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
       getmousechange(m,n);
       repeat
                   refresh(2);
                   getmousechange(m,n);
                   m:=m;
                   n:=n div 8;
                   if (integer(pixStart+m)>=0) and (integer(pixStart+pixLen+m)<wrisir) then begin
                     writeInteger(sloupce[nowsloupec].firstedi+2,readInteger(sloupce[nowsloupec].firstedi+2)+m);
                     end;
                   if integer(sloupce[nowsloupec].y16+n)>0 then begin
                     writeInteger(sloupce[nowsloupec].firstedi+5,readInteger(sloupce[nowsloupec].firstedi+5)+n);
                     end;
                   if (m<>0) or (n<>0) then begin
                     edzmena:=1;
                     RefreshTextScreen;
                     end;
                   asm mov i,0;mov ax,3;int 33h;cmp bx,2;jnz @noth;mov i,1;@noth:end;
       until i=0;
       end;
   until keypressed;
   ch:=readkey;
   case ch of
     '`':;
      #0:begin ch:=readkey;case ch of
{f1=help}     #59:begin
                  help;
                  setvis(lasttextvis);
                  goto 1;
                  end;
{f2=save}     #60:SaveEditorFile;
{f3=save&show}#61:if frameseg=0 then ask(#13' Sorry, nemas zadnou EMS ',0,'',' ') else
                  if (texturhandle=0) {$ifdef setup}or (setuphandle=0){$endif}
                    then ask(#13' Sorry, mas zatracene malo EMS ',0,'',' ') else
                  begin
                   SaveEditorFile;
                   pouzij_prevF3visy:=true;
                   palmysozmena:=false;
                   Show(edfajl);
                   txmode(txtmodenumber,0);
                   setvis(lasttextvis);
                   while keypressed do readkey;
                   prevF3visy:=now.visy;
                   refresh(14);
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
{f5=color}#63,#88,#98,#108:begin
                  if edtext[edi-2]=CHGCOL then dec(edi,2);
                  if edtext[edi ]<>CHGCOL then begin
                    InsertSpaces(edi,2);
                    edtext[edi]:=CHGCOL;
                    end;
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
                  if ch=#64 then edtext[ednowi+1]:='a' else edtext[ednowi+1]:='A';
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
                  if ch=#65 then edtext[ednowi+1]:='a' else edtext[ednowi+1]:='A';
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
{f8=pic}  #66,#91:begin
                  if ch=#66 then st:=fileselect('Zadej jm‚no obr zku *.X','*.x','')
                            else st:=fileselect('Zadej jm‚no animace *.FLI','*.fli','');
                  if length(st)=0 then goto 1;
                  if pos('.',st)=0 then if ch=#66 then st:=st+'.x' else st:=st+'.fli';
                  ednowi:=VeryStartLine;
                  st:=inspic+st+#13#10;
                  if ch=#91 then st:=st+defaultfli;
                  InsertSpaces(ednowi,length(st));
                  for i:=1 to length(st) do edtext[ednowi-1+i]:=st[i];
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
{alt-a}       #30:begin
                  ask(#13'Alt-A...  Grabbers allowed now.',0,'',' ');
                  irqon:=false;
                  end;
{alt-1}#120..#131:if ord(ch)-119<=sloupcu then begin
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
{alt-t,alt-k}#37,#20:begin
                  i:=0;while hod[i]<>ch do inc(i);inc(i);
                  while hod[i]<>#0 do begin inc(edtextlast);edtext[edtextlast]:=hod[i];inc(i);end;
                  edzmena:=1;
                  goto 1;
                  end;
{alt-m}       #50:begin
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
                    st:=ask('Jakou barvu ? (a,A,b,B,c...H)'#13'(velk˜ p¡smeno=vˆt¨¡ n pis)',1,edtext[edi+1],'A');
                    if st[0]=#1 then begin
                      edtext[edi+1]:=st[1];
                      edzmena:=1;
                      goto 1;
                      end;
                    end;
                  end;
{alt-p pozadi}#25:begin
                  st:=ask('Zadej typ backgroundov‚ textury (a,b,c,d,h,x,y,z)',1,header[h_textura],'a');
                  if (st[0]=#1) and (st[1]<>header[h_textura]) then begin
                    header[h_textura]:=st[1];
                    edzmena:=1;
                    end;
                  end;
{alt-s search}#31,#32:begin
                  if ch=#31 then searchstring:=ask(' Search string: ',20,searchstring,' ');
                  if searchstring<>'' then asm
                    mov si,offset searchstring;add si,bp
                    mov ax,ds;mov es,ax
                    segss lodsb;dec al;mov ah,al;segss lodsb
                    mov di,edi
                    mov cx,edtextlast;sub cx,edi
                    jmp @start
                    @continue:
                    popa
                    @start:
                    repne scasb
                    jcxz @notfound
                      {prvni pismeno ok, testuje zbytek}
                      pusha
                      mov ch,0;mov cl,ah
                      @next:
                      segss lodsb
                      scasb
                      jnz @continue
                      loop @next
                      popa
                    @found:dec di;mov ednowi,di
                    @notfound:
                    end;
                  for nowSloupec:=nowsloupec to sloupcu do
                   if ednowi<=sloupce[nowsloupec].lastedi then goto 1;
                  end;
                  {begin
                  assign(f,'pal.pas');rewrite(f);
                  for i:=25 to 40 do writeln(f,'        ',pal[i*3],',',pal[i*3+1],',',pal[i*3+2],',');
                  close(f);
                  end;}
{alt-f flags} #33:begin
                  j:=ord(header[h_flags]);
                  st8[0]:=#8;
                  for i:=1 to 8 do st8[i]:=chr((j shr (8-i)) mod 2+48);
                  st:=ask('Flags: 0,0,1,1,0,vlastn¡ paleta,togl v¡c vpravo,barevn‚ r me‡ky'#13+
                          ' Zat¡m jsou vyu‘ity pouze posledn¡ t©i bity, ostatn¡ nemˆ¤ ! ',8,st8,'0');
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
                  if (edi<edtextlast-1) and (edtext[edi+2]<>newsloupec) then begin
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
          txmode(txtmodenumber+1,0);
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
          if edi=sloupce[nowsloupec].lastedi then begin
            insertspaces(sloupce[nowsloupec].lastedi,2);
            edtext[sloupce[nowsloupec].lastedi]:=#13;
            edtext[sloupce[nowsloupec].lastedi+1]:=#10;
            end;
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


BEGIN
  fillchar(cestaKank,350,0);{vynuluje nekolik stringu}
  randomize;
  InitDataFile;{provadet co nejdriv - nastavuje string 'cestaKexe'}
{$ifdef midas}
  midasSetDefaults;       {nejnizsi priorita - set MIDAS defaults }
  midasParseEnvironment;  {druha nejnizsi priorita - parse MIDAS environment string }
{$endif}
  if not localReadINI(INIname) then localReadINI(cestaKexe+INIname);{cte vlastni INI}
  {*}if byte(scrolllock)<>0 then errorhalt(0);
  startupSetup:=setupAbsolute;
  if hledatMinulySetup then begin
    {pokusi se najit minuly INI}
    if InteligentneHledejSoubor(cestaKexe+INIname,cestaKminulymuINI)
      then localReadINI(cestaKminulymuINI);
    HledatMinulySetup:=false;
    end;
{$ifdef midas}
  midasParseOptions;  {nejvyssi priorita - let MIDAS parse all options }
{$endif}
  if DetekovatVGA then begin
    pointer65:=@viditelnychBanku;
    Execute0(cestaKdrv+'detekce.vga'#0);
    pointer65:=nil;
    if vgadriver>'' then vgadriver:=vgadriver+'.drv';
    end;
  loadVGAdriver(cestaKdrv+VgaDriver+#0);
  if rozsvecetDiody then InitKeyb else locks:=0;
  ResetMouse;


  pal[0]:=0;
  pal[1]:=0;
  pal[2]:=0;
  edtextofs:=ofs(edtextbody);
  headerofs:=ofs(header);
  asm
    {get fnt 9x16 adr}
     mov ah,11h;mov al,30h;mov bh,6;push bp;int 10h;mov fntseg16,es;mov fntofs16,bp;pop bp;
    {cls charseg}
     mov ax,ds;mov es,ax;mov ax,0;mov cx,charseglen/2;mov di,offset charseg;rep stosw;
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

  ResetMouse;
  MemInit;
  PrepareMiniFont;
{$ifdef pareniste}
  if frameseg=0 then errorhalt(2);
  if texturhandle=0 then errorhalt(3);
{$ifdef setup}
  if setuphandle=0 then errorhalt(3);
{$endif}
{$endif}

{$ifdef editor}
  editor;
{$else}
  Show(title);
{$endif}

  errorhalt(0);
END.

---TEXT HEADER---
ofs len meaning
 0   3  celkem radek v clanku
 3   1  -
 4   1  textura na pozadi
 5   3  starting visx
 8   3  starting visy
11   1  -
12   1  flags
13   5  -
18   2  CR/LF

---NEW SLOUPEC HEADER---
ofs len meaning
 0   1  ^
 1   1  cislo otcovskeho odstavce
 2   3  delta x
 5   3  delta y
 8   3  sirka odstavce

---FLAGS---
 0   1 - barevny ramecky
 1   2 - toggly posunuty kousek doprava kvuli setupu
 2   4 - stranka ma vlastni paletu prvnich 24 barev

---CONV MEMORY---
 310 zakladni nezbytnost
       70 kod
       20 palety k obrazkum
       15 stack
       57 dataseg
       64 workseg
       18 minifontseg
       60 FX samply
       15 patterny & other midas stuff
  50 prinejmensim tolik pro bigfont
 150 prinejmensim tolik pro modulovy samply

---EMS MEMORY---
  64 setup screen bitmap
 128 2 textury
2048 maximalni stranka


---TO DO---

dungeonovy hlasky:
 you have gained an experience level
 starfields wiped out, freaks jubilant
 6386 experience points added to stockpile
 warning warning, low stamina
 you have found a rotten fish, 25 hit points down
 warning, hit points depleted

v7 mirage & tseng
scrol na VGA XPRESSION VLB 1MB
nakej novej font na nadpisy, nakej "obycejnejsi"
alone engine + par.packer for ICM
MPG nebo MUJ podobnej player

zkusit spustit z jinyho adresare a testovat jak pri tom najde:
 INI,normalankdir,differentankdir,s3ms,dat
umi prejmenovat (pareni.ini -> ble) i v jinym adresari?
odstranit chybovou hlasku z readINI
detekce.vga <- detekce.com
nekam zamontovat heslo kvuli RIPu
vyzkouset ripping prilozenejch textu v tricich
zbalit a pripakovat zdrojaky.arj
exit v titulni strance
otestovat animos pri necache - tj pri malo pameti
haltstop v sluzbach musi callnout errorhalt
pri midbuttonu odskoci kurzor levohore pokud neni zadny mousedriver
nekdy se pta na [save/dont/continue] i kdyz sem nedelal zadnou zmenu
mouse ps/2

---PROCEDURY LEZOUCI NA SCREENU---
ems2screen                   done
ems2screenfromxtox           done
fliframe2screen              done
mouse                        done
ano                          done
kreslisoupatko               done
xorcursor                    done
hvezdicky                    na to kaslu
zaverecny strileni           done
centralframe                 done

---CONFIG---
HledatMinulySetup=ano
PocetViditelnychBanku=1
