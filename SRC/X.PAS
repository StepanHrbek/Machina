{$A+,B-,E-,F-,G+,I-,L-,N-,O-,Q-,R-,S-,M 4000,0,0}

VAR
      srcpal:array[1..1024] of byte;
      destpal:array[1..768] of byte;
      tab1:array[0..255] of word;{pocty vyskytu barev 0..255}
      tab2:array[0..255] of byte;{color xlat tabulka}
      src,dest:string;
      typ:string[4];
      f:file;
      nejmensirozdil                 :byte;
      i,sir,vys,col,colors0,
      OdstranovanaBarvaTab2,
      NejblizsiBarvaTab2,headsize    :word;
      raw_size,com_size              :longint;
      st:string[10];

CONST maxcolors=210;
      redukt:byte=0;
      transparent:byte=0;
      komprese:byte=1;
      viewer:byte=0;
      halvex:byte=0;
      halvey:byte=0;
      bmp:byte=0;
      oldx:byte=0;
      colors1:byte=maxcolors;
      BMPheader:array[0..53] of byte=(
         $42,$4d,$36,$fe,0,0,0,0,0,0,$36,4,0,0,$28,0,
         0,0,{totalsirW}0,0,0,0,{vysW}0,0,0,0,1,0,8,0,0,0,
         0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);

PROCEDURE Errorhalt(n:byte);
begin
 case n of 1:write('Tenhle pik‡r ti nese‘eru, asi nem  256 barev.');
           2:write('M lo konven‡n¡ pamˆti. Vypadni sakra z toho Volkova.');
           3:write('Obr zek ',src,' nenalezen.');
           4:write('Nem–‘u vytvo©it c¡lov˜ soubor ',dest);
           5:write('’eru jen obr zky typu PCX, BMP nebo X.');
           6:write('Obr zek evidentnˆ nen¡ fit, ‡ekni si ho.');
           7:write('Sorry, beru jen BMP bez intern¡ komprese.');
{           8:write('Velikost bitmapy nesouhlas¡ s £daji v hlavi‡ce souboru: zkus parametr oldx.'#13#10+
                   'Kdy‘ nepom–‘e, obr zek sma‘.');}
           end;
 halt;
end;

FUNCTION Kolik:integer;
const sir=5;
var   x,xy:word;
      i,j:integer;
      key:char;
      st:string[sir];
label 1,ex;
begin
 writeln(#13#10'Obr zek m  ',colors0,' barev. Pro pou‘it¡ v Pa©eni¨ti by mˆl m¡t maxim lnˆ ',maxcolors,' barev.');
 writeln('Teƒ stiskni buƒ ESC pro ponech n¡ star‚ palety nebo zadej nov˜ po‡et barev.');
 write('Po‡et barev = ');
 if colors0>maxcolors then str(maxcolors,st) else str(colors0,st);
 x:=ord(length(st));
 asm {read kursor xy}mov ah,3;mov bh,0;int 10h;mov xy,dx;end;
 1:
 asm {set kursor xy}mov ah,2;mov bh,0;mov dx,xy;int 10h;end;
 write(st,' ');
 asm {set kursor xy+x}mov ah,2;mov bh,0;mov dx,xy;add dx,x;int 10h;end;
 asm {readkey}mov ax,807h;int 21h;mov key,al;end;
 case key of '0'..'9':begin
                      st:=copy(st,1,x)+key+copy(st,x+1,200);
                      if x<sir then inc(x);
                      end;
                   #8:if x>0 then begin
                      st:=copy(st,1,x-1)+copy(st,x+1,200);
                      dec(x);
                      end;
                  #83:if x<sir then st:=copy(st,1,x)+copy(st,x+2,200);
                  #75:if x>0 then dec(x);
                  #77:if x<length(st) then inc(x);
                  #27:begin kolik:=0;goto ex;end;
                  #13:begin val(st,i,j);if i>=colors0 then kolik:=0 else kolik:=i;goto ex;end;
                  end;
 goto 1;
 ex:
 writeln;
end;


LABEL 1;

BEGIN
 for i:=paramcount downto 1 do begin
   st:=paramstr(i);
   if st='oldx' then oldx:=1 else
   if st='bmp'  then begin bmp:=1;komprese:=0;end else
   if st='.'    then begin halvex:=1;halvey:=1;end else
   if st='-'    then halvey:=1 else
   if st='l'    then halvex:=1 else
   if st='t'    then transparent:=1 else
   if st='r'    then redukt:=1 else
   if st='k'    then komprese:=0 else
   if st='v'    then viewer:=1 else
                     src:=paramstr(i);
   end;

 dest:=src;
 if src='' then begin
   writeln('ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
   writeln('³ Konvertor 256ti-barevn˜ch obr zk– z form tu BMP, PCX, X do form tu X, BMP ³');
   writeln('ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´');
   writeln('³ X filename[.ext] [v] [r] [t] [k] [.|-|l] [bmp] [oldx]    ³  Kdybys na¨el  ³');
   writeln('³    v - view picture               ^ ^ ^                  ³ nˆjakou chybu, ³');
   writeln('³    r - redukce palety            zmen¨en¡                ³  dej vˆdˆt...  ³');
   writeln('³    t - transparentn¡ pozad¡         ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´');
   writeln('³    k - c¡lov˜ X bez komprese        ³ just another sexy program by Dement ³');
   write  ('ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');
   halt;
   end;

 if pos('.',src)>0 then begin
   typ:=copy(src,pos('.',src)+1,255);
   src[0]:=chr(pos('.',src)-1);
   if (typ<>'pcx') and (typ<>'bmp') and (typ<>'x') then errorhalt(5);
   end
 else begin
   typ:='pcx';assign(f,src+'.'+typ);reset(f);if ioresult=0 then goto 1;
   typ:='bmp';assign(f,src+'.'+typ);reset(f);if ioresult=0 then goto 1;
   typ:='x'  ;assign(f,src+'.'+typ);reset(f);if ioresult=0 then goto 1;
   errorhalt(3);
   1:
   close(f);
   end;

 if bmp=0 then dest:=src+'.x'#0
          else dest:=src+'.bmp'#0;
 src:=src+'.'+typ+#0;

 asm
mov ax,ds;mov es,ax
         {clr all}
          mov di,offset srcpal;mov cx,offset src;sub cx,di;mov al,0;rep stosb
         {set flags}
          mov al,transparent;mov [cs:offset @cernatransparentni],al
          mov al,oldx;mov [cs:offset @oldx],al
         {open}
          mov ax,3d00h;mov dx,offset src+1;int 21h;jnc @noerror;push 3;call errorhalt;@noerror:mov [cs:offset @handle],ax
          cmp byte ptr [offset typ+1],'b';jz @BMP
          cmp byte ptr [offset typ+1],'x';jz @X
  {___________________READ PCX_________________}
  @PCX:
         {seek end, spocita srcsize}
          mov ax,4202h;mov bx,[cs:offset @handle];mov cx,0;mov dx,0;int 21h;sub ax,128+768+1-16;sbb dx,0
          mov [cs:offset @srcsizehi],dx;mov [cs:offset @srcsizelo],ax;
         {seek start}
          mov ax,4200h;mov bx,[cs:offset @handle];mov cx,0;mov dx,0;int 21h;
         {read header}
          mov bx,[cs:offset @handle];mov cx,128;mov dx,offset srcpal;mov ah,3fh;int 21h;
         {check number of color per plane}
          mov al,[offset srcpal+3];cmp al,8;jz @ok1;push 1;call errorhalt;@ok1:
         {check number of planes}
          mov al,[offset srcpal+65];cmp al,1;jz @ok2;push 1;call errorhalt;@ok2:
         {read sir,vys}
          mov ax,[offset srcpal+ 8];sub ax,[offset srcpal+4];inc ax;mov [cs:offset @sir],ax
          mov ax,[offset srcpal+10];sub ax,[offset srcpal+6];inc ax;mov [cs:offset @vys],ax
         {read totalsir}
          mov ax,[offset srcpal+66];mov [cs:offset @totalsir],ax

         {load}
          call @ALLOC_MEMORY_AND_LOAD

         {decompress PCX src(totalsir)->dest(sir)}
          PUSH DS
          mov ds,[cs:offset @srcseg]
          mov es,[cs:offset @destseg]
          mov si,0
          mov di,0
          mov bx,[cs:offset @vys]{zbyvajici pocet radek k dekodovani}
          mov dx,[cs:offset @totalsir]{zbyvajici kus radky k dekodovani}

          @DECODE_LOOP:
         {kdyztak posune dest seg}
          cmp di,60000
          jc @notnewdestseg
          sub di,60000
          mov ax,es
          add ax,60000/16
          mov es,ax
          @notnewdestseg:
         {kdyztak posune src seg}
          cmp si,60000
          jc @notnewsrcseg
          sub si,60000
          mov ax,ds
          add ax,60000/16
          mov ds,ax
          @notnewsrcseg:

          lodsb
          cmp al,128+64
          jnc @multi

         @single:
          dec dx
          stosb
          jmp @check_end_of_loop

         @multi:
          and al,63;mov cl,al;mov ch,0
          sub dx,cx
          lodsb
          rep stosb

         @check_end_of_loop:
          jnz @decode_loop
          mov dx,[cs:offset @totalsir]{zbyvajici kus radky k dekodovani}
          sub di,[cs:offset @totalsir]
          add di,[cs:offset @sir]
          dec bx
          jnz @decode_loop

          POP DS

         {totalsir:=sir}
          mov ax,[cs:offset @sir];mov [cs:offset @totalsir],ax


         {seek end}
          mov ax,4202h;mov bx,[cs:offset @handle];mov cx,0;mov dx,0;int 21h;
         {seek 768 back to pal}
          mov cx,dx;mov dx,ax;sub dx,768;sbb cx,0
          mov ax,4200h;mov bx,[cs:offset @handle];int 21h;
         {read palette}
          mov bx,[cs:offset @handle];mov cx,768;mov dx,offset srcpal;mov ah,3fh;int 21h;
         {pal shr 2}
          mov ax,ds;mov es,ax;lea si,srcpal;mov di,si;mov cx,768;@shrnextcol:lodsb;shr al,2;stosb;loop @shrnextcol

          jmp @CONT

  {___________________READ BMP_________________}
  @BMP:
         {read header}
          mov bx,[cs:offset @handle];mov cx,54;mov dx,offset srcpal;mov ah,3fh;int 21h;
         {check BM}
          mov ax,[offset srcpal];cmp ax,'MB';jz @ok5;push 6;call errorhalt;@ok5:
         {check number of color per plane}
          mov al,[offset srcpal+28];cmp al,8;jz @ok6;push 1;call errorhalt;@ok6:
         {check number of planes}
          mov al,[offset srcpal+26];cmp al,1;jz @ok7;push 1;call errorhalt;@ok7:
         {check no compression}
          mov al,[offset srcpal+30];cmp al,0;jz @ok8;push 7;call errorhalt;@ok8:
         {read sir,totalsir,vys}
          mov ax,[offset srcpal+18];mov [cs:offset @sir],ax;add ax,3;and ax,$fffc;mov [cs:offset @totalsir],ax
          mov ax,[offset srcpal+22];mov [cs:offset @vys],ax
         {spocita srcsize}
          mov ax,[cs:offset @totalsir];mul word ptr [cs:offset @vys]
          mov [cs:offset @srcsizehi],dx;mov [cs:offset @srcsizelo],ax

         {read palette}
          mov bx,[cs:offset @handle];mov cx,1024;mov dx,offset srcpal;mov ah,3fh;int 21h;
         {pal shr 2}
          mov ax,ds;mov es,ax;lea si,srcpal;mov di,si;mov cx,256;
          @shrnextcol2:
          lodsb;shr al,2;mov bh,al
          lodsb;shr al,2;mov bl,al
          lodsb;shr al,2;stosb;mov ax,bx;stosw
          inc si
          loop @shrnextcol2

         {load}
          call @ALLOC_MEMORY_AND_LOAD

         {VZHURU NOHAMA src(totalsir)->dest(sir)}
          PUSH DS
          mov ds,[cs:offset @srcseg]
          mov si,0
          mov ax,[cs:offset @destsizehi];shl ax,12
          add ax,[cs:offset @destseg];mov es,ax
          mov di,[cs:offset @destsizelo]

          mov cx,[cs:offset @vys]
          @NEXTLINE1:
          push cx

         {check preteceni dest segmentu}
          sub di,[cs:offset @sir]
          jnc @nepretek_destseg1
          mov ax,es;sub ax,64000/16;mov es,ax;add di,64000
          @nepretek_destseg1:
         {check preteceni src segmentu}
          cmp si,64000
          jc @nepretek_scrseg1
          mov ax,ds;add ax,64000/16;mov ds,ax;sub si,64000
          @nepretek_scrseg1:
         {zkopceni jedny lajny}
          mov cx,[cs:offset @sir]
          shr cx,1
          rep movsw
          jnc @notoddbyte1
          movsb
          @notoddbyte1:
          add si,[cs:offset @totalsir]
          sub si,[cs:offset @sir]
          sub di,[cs:offset @sir]

          pop cx
          loop @nextline1

         {totalsir:=sir}
          mov ax,[cs:offset @sir];mov [cs:offset @totalsir],ax

          POP DS

          jmp @CONT

  {___________________READ X_________________}
  @X:
         {read header}
          mov bx,[cs:offset @handle];mov cx,5;mov dx,offset srcpal;mov ah,3fh;int 21h;
         {get sir,totalsir,vys from header}
          mov ax,[offset srcpal];mov [cs:offset @sir],ax;mov [cs:offset @totalsir],ax
          mov ax,[offset srcpal+2];mov [cs:offset @vys],ax
         {xcommand:=256-B}{pro jistotu 255-B}
          mov al,[offset srcpal+4];neg al;{*}dec al;mov [cs:offset @xcommand],al;
         {clear start of palette & read palette}
          mov al,[offset srcpal+4];mov ah,0;mov cx,ax;add cx,ax;add cx,ax;mov headsize,cx;add headsize,5
          mov word ptr [offset srcpal],0;mov word ptr [offset srcpal+2],0;mov byte ptr [offset srcpal+4],0;
          mov bx,[cs:offset @handle];mov dx,offset srcpal+768;sub dx,cx;mov ah,3fh;int 21h;
         {seek end, spocita srcsize}
          mov ax,4202h;mov bx,[cs:offset @handle];mov cx,0;mov dx,0;int 21h;sub ax,headsize;sbb dx,0
          mov [cs:offset @srcsizehi],dx;mov [cs:offset @srcsizelo],ax;
         {seek start of bitmap}
          mov ax,4200h;mov bx,[cs:offset @handle];mov cx,0;mov dx,headsize;int 21h;

         {load}
          call @ALLOC_MEMORY_AND_LOAD

         {decompress X}
          PUSH DS
          mov ds,[cs:offset @srcseg]
          mov es,[cs:offset @destseg]
          mov si,0
          mov di,0
          mov bx,[cs:offset @srcsizelo]{citac kvuli detekci konce dekomprese}
          mov dx,[cs:offset @srcsizehi]

          @DECODE_X_LOOP:
         {kdyztak posune dest seg}
          cmp di,60000
          jc @notnewdestsegX
          sub di,60000
          mov ax,es
          add ax,60000/16
          mov es,ax
          @notnewdestsegX:
         {kdyztak posune src seg}
          cmp si,60000
          jc @notnewsrcsegX
          sub si,60000
          mov ax,ds
          add ax,60000/16
          mov ds,ax
          sub bx,60000
          jnc @neubylseg
          dec dx
          @neubylseg:
          @notnewsrcsegX:

          mov al,0;cmp [cs:offset @oldx],al;jz @newdecompr

         @olddecompr:
          lodsb
          cmp al,[cs:offset @xcommand]{commandy jsou barvy 1 a‘ 255-B};jnc @stosold;
          or al,al;jz @stosold
          mov ch,al;lodsb;mov cl,al;sub cx,102h;lodsb;rep stosb{fill}
          @stosold:stosb
          jmp @zanew

         @newdecompr:
          lodsb
          cmp al,1;jz @decom1
          cmp al,2;jz @decom2
          stosb
          jmp @zanew
          @decom1:lodsb;mov ch,0;mov cl,al;lodsb;jmp @doit
          @decom2:lodsw;mov cx,ax;lodsb;add di,cx;sub di,cx;jnc @doit
          @napul:sub si,3;sub cx,5000;mov [si],cx;dec si;mov cx,5000;
          @doit:rep stosb;
          @zanew:

          cmp si,bx;jnz @decode_X_loop
          or  dx,dx;jnz @decode_X_loop

          {kontrola, jestli je rozpakovana cast skutecne tak velka jak ma bejt}
          mov ax,es;sub ax,[cs:offset @destseg];mov bx,ax;shr ax,12{ax=hi};shl bx,4
          add bx,di{bx=lo};jnc @dontincax;inc ax;@dontincax:
          cmp ax,[cs:offset @destsizehi];jnz @notsamesize
          cmp bx,[cs:offset @destsizelo];jnz @notsamesize
          POP DS

          jmp @CONT

          @notsamesize:
          mov dx,offset @haltmsg8
          push ds;mov ax,cs;mov ds,ax;mov ah,9;int 21h;pop ds
          push 8;call errorhalt

@haltmsg8:db 'Velikost bitmapy nesouhlas¡ s £daji v hlavi‡ce souboru: zkus parametr oldx.',13,10
          db 'Kdy‘ nepom–‘e, obr zek sma‘.$'

  {___________________PROCEDURES ABOUT LOADING_________________}

@ALLOC_MEMORY_AND_LOAD:
         {spocita destsize}
          mov ax,[cs:offset @sir];mul word ptr [cs:offset @vys]
          mov [cs:offset @destsizehi],dx;mov [cs:offset @destsizelo],ax
         {check sizes if < 2000}
          mov ax,[cs:offset @totalsir];call @boundAX
          mov ax,[cs:offset @sir     ];call @boundAX
          mov ax,[cs:offset @vys     ];call @boundAX
         {if save as bmp: alloc max(srcsize,((sir+1) and 0fffeh)*vys)}
          cmp bmp,0;jz @noresize
          mov ax,[cs:offset @sir];inc ax;and ax,0fffeh;mul word ptr [cs:offset @vys]
          cmp dx,[cs:offset @srcsizehi];jc @noresize;jnz @resized
          cmp ax,[cs:offset @srcsizelo];jnc @resized
          @noresize:
          mov dx,[cs:offset @srcsizehi]
          mov ax,[cs:offset @srcsizelo]
          @resized:   {ted je v DX:AX velikost, kterou mam alokovat...}
         {alloc source memory podle doublewordu DX:AX}
          shr ax,4;inc ax;mov bx,dx;shl bx,12;add bx,ax
          mov ah,48h;int 21h;jnc @ok0;push 2;call errorhalt;@ok0:mov [cs:offset @srcseg],ax
         {alloc destination memory}
          mov ah,48h;mov bx,[cs:offset @destsizelo];shr bx,4;inc bx;mov cx,[cs:offset @destsizehi];shl cx,12;add bx,cx;
          int 21h;jnc @ok9;push 2;call errorhalt;@ok9:mov [cs:offset @destseg],ax
         {precte celou bitmapu}
          mov ax,[cs:offset @srcseg];mov [cs:offset @srcseg_i],ax
          mov ax,[cs:offset @srcsizehi];mov [cs:offset @toreadsegs],ax
         @readnextseg:
          dec word ptr [cs:offset @toreadsegs];js @readlast
         {read 65536 bytes}
          mov bx,[cs:offset @handle];mov cx,65535;mov dx,0;mov ah,3fh;push ds;mov ds,[cs:offset @srcseg_i];int 21h;pop ds
          mov bx,[cs:offset @handle];mov cx,1;mov dx,65535;mov ah,3fh;push ds;mov ds,[cs:offset @srcseg_i];int 21h;pop ds
          mov ax,[cs:offset @srcseg_i];add ax,65536/16;mov [cs:offset @srcseg_i],ax
          jmp @readnextseg
         {read srcsizelo bytes}
          @readlast:
          mov bx,[cs:offset @handle];mov cx,[cs:offset @srcsizelo];mov dx,0
          mov ah,3fh;push ds;mov ds,[cs:offset @srcseg_i];int 21h;pop ds
          RET

@boundAX: cmp ax,2000;jnc @toobig;ret;@toobig:push 6;call errorhalt

@checkSRCandDESToverflow:
          {kdyztak posune DS:SI o pul segmentu}
          cmp si,50000;jc @NotAddHalfSegSI
          push cx;mov cx,ds;add cx,800h;mov ds,cx;sub si,8000h;pop cx
          @NotAddHalfSegSI:
          {kdyztak posune ES:DI o pul segmentu}
          cmp di,50000;jc @NotAddHalfSegDI
          push cx;mov cx,es;add cx,800h;mov es,cx;sub di,8000h;pop cx
          @NotAddHalfSegDI:
          RET

@sir:        dw 0
@vys:        dw 0
@barev:      dw 0
@totalsir:   dw 0
@handle:     dw 0
@dataseg:    dw 0
@srcseg:     dw 0
@destseg:    dw 0
@srcseg_i:   dw 0
@toreadsegs: dw 0
@srcpos:     dw 0
@destpos:    dw 0
@destsizehi: dw 0
@destsizelo: dw 0
@srcsizehi:  dw 0
@srcsizelo:  dw 0
@tocompreshi:dw 0
@cernatransparentni: db 0
@xcommand:   db 0
@oldx:       db 0

  @CONT:
         {close}
          mov bx,[cs:offset @handle];mov ah,3eh;int 21h;

  {___________________PRESKUPENI BAREV_________________}
         {meri cetnosti jednotlivych barev = naplneni tab1}
mov es,[cs:offset @destseg]
          mov si,0
          mov di,0
          mov cx,0
          mov dx,[cs:offset @destsizehi]
         @nextpage1:
          or dx,dx
          jnz @loop1
          mov cx,[cs:offset @destsizelo]
          jcxz @lastsegempty
         @loop1:
          seges lodsb;mov ah,0;shl ax,1;mov bx,ax;inc word ptr [bx+offset tab1];loop @loop1
          mov ax,es;add ax,65536/16;mov es,ax
          dec dx
          jns @nextpage1
          @lastsegempty:

         {vytvoreni konverzni tabulky podle cetnosti barev = tab1 -> tab2}
          mov cx,255
          @l3:
          push cx
           mov dx,0
           mov cx,256
           mov si,offset tab1
           @l2:
           lodsw
           cmp dx,ax
           jnc @nomax
           mov dx,ax{dx=maximum vyskytu}
           mov bx,si{adresa nejcastejsi barvy v tab1}
           @nomax:
           loop @l2
          pop cx
          cmp dx,0;jz @redend
          sub bx,2
          mov word ptr [bx],0
          sub bx,offset tab1
          shr bx,1{bl=cislo nejcastejsi barvy}
          add bx,offset tab2
              {cerna barva nejcastejsi -> konvertit na 00}
              cmp cl,255;jnz @notNejcastejsiCerna
              mov al,[cs:offset @CernaTransparentni];cmp al,0;jz @notNejcastejsiCerna
              mov byte ptr [bx],0{bude transformovano na cernou}
              loop @l3
              @notNejcastejsiCerna:
          mov byte ptr [bx],cl{bude transformovano na 255,254...}
          loop @l3
          @redend:

         {trans srcpal -> destpal}
mov ax,ds;mov es,ax
          mov di,offset tab2
          mov si,offset srcpal
          mov cx,256
          @5:
          mov ah,0
          mov al,[di];inc di;mov bx,ax;add bx,ax;add bx,ax{};jnz @usedcol{}
          {not al;cmp al,colors1;jc @usedcol;{}add si,3;jmp @l
          @usedcol:add bx,offset destpal
          lodsb;mov [bx],al;inc bx
          lodsb;mov [bx],al;inc bx
          lodsb;mov [bx],al
          inc word ptr [cs:offset @barev]
          @l:loop @5

         {zjisti pocet pouzitych barev}
          mov si,offset tab2;mov cx,256;mov ah,0;mov bx,0
          @nextcol:lodsb;or ax,ax;jz @notused;inc bx;@notused:loop @nextcol
          mov colors0,bx
          mov colors1,bl


{------HALVE X------}
          cmp halvex,0;jz @zahalvex

push ds
mov ds,[cs:offset @destseg]
mov es,[cs:offset @destseg]
          mov dx,[cs:offset @destsizelo]
          mov ax,[cs:offset @destsizehi]
          mov si,0;mov di,0
          mov dx,[cs:offset @vys]
         @nextlinea:
          call @checkSRCandDESToverflow
          {zhalvuje jednu radku}
          mov cx,[cs:offset @sir];shr cx,1;{jz @zahalvex;}pushf
          @nexthalv:lodsw;stosb;loop @nexthalv;popf;jnc @noodd;inc si{|movsb};@noodd:
          {testuje jestli uz je konec bitmapy}
          dec dx
          jnz @nextlinea
          {zapise polovicni sir a destsize}
          mov ax,[cs:offset @sir];shr ax,1
          mov [cs:offset @totalsir],ax
          mov [cs:offset @sir],ax;mul word ptr [cs:offset @vys]
          mov [cs:offset @destsizelo],ax
          mov [cs:offset @destsizehi],dx
pop ds
         @zahalvex:

{------HALVE Y------}
          cmp halvey,0;jz @zahalvey

push ds
mov ds,[cs:offset @destseg]
mov es,[cs:offset @destseg]
          mov dx,[cs:offset @destsizelo]
          mov ax,[cs:offset @destsizehi]{*?;mov [cs:offset @tocompreshi],ax}
          mov si,0;mov di,0
          {zapise polovicni vys a destsize}
          mov ax,[cs:offset @vys];shr ax,1;
          mov [cs:offset @vys],ax;mul word ptr [cs:offset @sir]
          mov [cs:offset @destsizelo],ax
          mov [cs:offset @destsizehi],dx
          mov dx,[cs:offset @vys]
         @nextlineb:
          call @checkSRCandDESToverflow
          {zhalvuje jednu radku}
          mov cx,[cs:offset @sir];rep movsb
          add si,[cs:offset @sir]
          {testuje jestli uz je konec bitmapy}
          dec dx
          jnz @nextlineb
pop ds
         @zahalvey:

{------REDUKCE------ palety z COLORS0 na COLORS1 barev, uprava tab2}
         {dotaz na redukci palety}
          cmp redukt,0;jnz @dotaz
          cmp bx,maxcolors;jc @noredukce;jz @noredukce
          mov colors1,maxcolors;jmp @removeONEcolor
          @dotaz:
          call kolik
          or ax,ax;jz @noredukce;mov colors1,al
         {odstraneni jedny barvy}
       @removeONEcolor:
          mov si,offset tab2
          mov ah,255
          mov cx,256
          @nxcol:lodsb;or al,al;jz @skipc;cmp al,ah;jnc @skipc;mov ah,al;mov bx,si;dec bx;
          @skipc:loop @nxcol
          mov OdstranovanaBarvaTab2,bx;sub bx,offset tab2{bx=nejmin casta barva}
          {hleda nejpodobnejsi barvu v srcpal
            ALE: musi to byt barva casto pouzivana
                  proste jedna z hornich colors1 nejcastejsich barev}
          mov si,offset srcpal
          mov di,offset tab2
          mov ax,bx;add bx,ax;add bx,ax;mov dx,[bx+si];mov ch,[bx+si+2]
          mov cl,0
          mov nejmensirozdil,255
         @nextcolorcompare:{cl=druha porovnavana barva, di=jeji tab2}
          mov al,[di];not al;cmp al,colors1;jnc @notusefulcolor
          {toto provede jen kdyz je 257-[di]<colors1}
          {ve skutecnosti staci 257-[di]<colors1}
          mov ah,0;
          lodsb;cmp al,dl;jc @dlhigher;add ah,al;sub ah,dl;jmp @okr;@dlhigher:add ah,dl;sub ah,al;@okr:
          lodsb;cmp al,dh;jc @dhhigher;add ah,al;sub ah,dh;jmp @okg;@dhhigher:add ah,dh;sub ah,al;@okg:
          lodsb;cmp al,ch;jc @chhigher;add ah,al;sub ah,ch;jmp @okb;@chhigher:add ah,ch;sub ah,al;@okb:
          sub si,3
          cmp ah,nejmensirozdil;jnc @notnejblizsi;mov nejmensirozdil,ah;mov NejblizsiBarvaTab2,di;@notnejblizsi:
          @notusefulcolor:
          add si,3;inc di;inc cl;jnz @nextcolorcompare
         {vyznaci zmenu jedne barvy v tab2, zmensi pocet barev}
          mov bx,NejblizsiBarvaTab2;mov al,[bx]
          mov bx,OdstranovanaBarvaTab2;mov [bx],al
          dec word ptr [cs:offset @barev]
         {testuje, zda jeste odstranovat dalsi barvy}
          dec colors0;mov ax,colors0;cmp al,colors1;jnz @removeONEcolor
          @NOREDUKCE:

         {trans destmap -> destmap}
mov es,[cs:offset @destseg]
          mov di,0;mov cx,0;mov bx,offset tab2
          mov dx,[cs:offset @destsizehi]
         @nextpage2:
          or dx,dx
          jnz @4
          mov cx,[cs:offset @destsizelo]
          jcxz @lastsegempty2
          @4:mov al,[es:di];xlat;stosb;loop @4
          mov ax,es;add ax,65536/16;mov es,ax
          dec dx;jns @nextpage2
          @lastsegempty2:

  {___________________VIEWER_________________}
          cmp viewer,0;jz @zaviewer
          mov ax,13h;int 10h
          {paleta}
          lea si,destpal+768;mov dx,3c8h;mov al,255;sub ax,[cs:offset @barev];out dx,al;inc dx
          mov cx,[cs:offset @barev];inc cx;mov bx,cx;add cx,bx;add cx,bx;sub si,cx;
          rep outsb
          {paleta
          lea si,destpal;mov dx,3c8h;mov al,0;out dx,al;inc dx
          mov cx,300h
          rep outsb}
          {spocita CX=pocet zobrazovanych bajtu na sirku=min(sir,320)}
          mov si,0;mov di,0
          mov cx,[cs:offset @sir];cmp cx,320;jc @vejdese2
          {spocita Xovou souradnici SI=odkud zobrazovat}
          @nevejdese2:
          mov cx,320;mov si,[cs:offset @sir];sub si,320;shr si,1
          jmp @zavejdese2
          {upravi Xovou souradnici DI=kam zobrazovat}
          @vejdese2:
          mov di,320;sub di,[cs:offset @sir];shr di,1
          @zavejdese2:
          {spocita DX=pocet zobrazovanych radek=min(vys,200)}
          mov dx,[cs:offset @vys];cmp dx,200;jc @vejdese3
          {upravi DS:SI=Yovou souradnici odkud zobrazovat}
          {inc(ds:si,(dx-200)/2*sir}
          sub dx,200;shr dx,1;mov ax,[cs:offset @sir];mul dx
          add si,ax;jnc @nepretek;add dx,1000h;@nepretek:mov ax,ds;add ax,dx;mov ds,ax
          mov dx,200
          jmp @zachgdi;
          {upravi DI=Yovou souradnici kam zobrazovat}
          @vejdese3:
          mov ax,160*256+200;sub al,dl;and al,254;mul ah;add di,ax
          @zachgdi:
          {zobrazi to}
          PUSH DS
          mov es,sega000;mov ds,[cs:offset @destseg]
          @nextlajn:
          pusha;rep movsb;popa
          add si,[cs:offset @sir]
          add di,320
          cmp si,60000;jc @notnewseg;sub si,60000;mov ax,ds;add ax,60000/16;mov ds,ax;@notnewseg:
          dec dx;jnz @nextlajn
          POP DS
          {readkey}
          {*push ds;mov ax,cs;mov ds,ax;lea dx,@msg;mov ah,9;int 21h;pop ds}
          mov ax,0c08h;int 21h
          push ax
          mov ax,3;int 10h
          pop ax
          cmp al,'x';jnz @AFTER_WRITE
          mov viewer,0
          jmp @zaviewer

          @msg:db 'Press X to save .X or other key to quit.$'

          @zaviewer:

  {___________________PREPARE FOR SAVING AS BMP_________________}
          cmp bmp,0;jz @zasavebmp

         {VZHURU NOHAMA dest(sir)->src(totalsir)}

         {totalsir:=sir zaokrouhleny nahoru na sudy cislo}
          mov ax,[cs:offset @sir]
          inc ax;and ax,0fffeh
          mov [cs:offset @totalsir],ax

          PUSH DS
          mov es,[cs:offset @srcseg]
          mov di,0
          mov ax,[cs:offset @destsizehi];shl ax,12
          add ax,[cs:offset @destseg];mov ds,ax
          mov si,[cs:offset @destsizelo]

          mov cx,[cs:offset @vys]
          @NEXTLINE2:
          push cx

         {check preteceni dest segmentu}
          sub si,[cs:offset @sir]
          jnc @nepretek_destseg2
          mov ax,ds;sub ax,64000/16;mov ds,ax;add si,64000
          @nepretek_destseg2:
         {check preteceni src segmentu}
          cmp di,64000
          jc @nepretek_scrseg2
          mov ax,es;add ax,64000/16;mov es,ax;sub di,64000
          @nepretek_scrseg2:
         {zkopceni jedny lajny}
          mov cx,[cs:offset @sir]
          shr cx,1
          rep movsw
          jnc @notoddbyte2
          movsb
          stosb
          @notoddbyte2:
          sub si,[cs:offset @sir]

          pop cx
          loop @nextline2

          POP DS

         {spocita novou destsize podle totalsir}
          mov ax,[cs:offset @totalsir];mul word ptr [cs:offset @vys]
          mov [cs:offset @destsizehi],dx;mov [cs:offset @destsizelo],ax

  {___________________WRITE BMP_________________}
         {open dest}
          mov ah,3ch;mov cx,0;mov dx,offset dest+1;int 21h;mov [cs:offset @handle],ax
          jnc @okopen2;push 4;call errorhalt;@okopen2:
         {write sir,vys to header}
          mov ax,[cs:offset @sir];mov [offset BMPheader+18],ax
          mov ax,[cs:offset @vys];mov [offset BMPheader+22],ax
         {save BMP header}
          mov bx,[cs:offset @handle];mov cx,54;lea dx,BMPheader;mov ah,40h;int 21h
         {destpal->srcpal}
          mov ax,ds;mov es,ax
          lea si,destpal;lea di,srcpal;mov cx,100h;mov bh,0
          @nxc:lodsb;mov bl,al;lodsw;xchg al,ah;shl ax,2;stosw;mov ax,bx;shl ax,2;stosw;loop @nxc
         {save palette}
          mov bx,[cs:offset @handle];mov cx,1024;lea dx,srcpal;mov ah,40h;int 21h
         {save bitmap}
          mov ax,[cs:offset @destsizelo];mov [offset com_size  ],ax
          mov ax,[cs:offset @destsizehi];mov [offset com_size+2],ax
          PUSH DS
          mov ds,[cs:offset @srcseg]
         @nextpage4:
          mov bx,[cs:offset @handle]
          mov cx,0
          dec word ptr [cs:offset @destsizehi]
          jns @notlast4
          mov cx,[cs:offset @destsizelo]
          jcxz @lastsegempty3
         @notlast4:
          pushf;pusha
          push cx;mov cx,1;mov dx,0;mov ah,40h;int 21h;
          pop cx; dec cx;  mov dx,1;mov ah,40h;int 21h;
          mov ax,ds;add ax,65536/16;mov ds,ax
          popa;popf
          jns @nextpage4
          @lastsegempty3:
          POP DS
         {close}
          mov bx,[cs:offset @handle];mov ah,3eh;int 21h;

          jmp @after_write

          @zasavebmp:

  {___________________COMPRESS BITMAP X_________________}

         {trans destmap -> destmap
          AH je minuly bajt
          BX je pocet opakovani minuleho resp. prave cteneho bajtu
          DX je dolni word poctu jeste zbyvajicich bajtu ke cteni
                horni word je v cs:@tocompreshi
          }
          cmp komprese,0;jz @zakompresi

push ds
mov ds,[cs:offset @destseg]
mov es,[cs:offset @destseg]
          mov dx,[cs:offset @destsizelo]
          mov ax,[cs:offset @destsizehi];mov [cs:offset @tocompreshi],ax
          mov si,0;mov di,0
          lodsb
         @nextstring:
          call @checkSRCandDESToverflow
          {zacne cist novej string}
          mov ah,al{ah=to co se prave opakuje}
          mov bx,1{pocet opakovani}
         @nextbyte:
          {testuje jestli uz je konec bitmapy}
          dec dx{zmensi pocet ktery jeste zbyva}
          jnz @noend
          sub word ptr [cs:offset @tocompreshi],1
          jc @compressend
         @noend:
          lodsb
          cmp al,ah
          jnz @notsame
         @same:
          inc bx{pocet opakovani}
          jmp @nextbyte
         @notsame:
          call @writestring
          jmp @nextstring

     @writestring:
          cmp bx,6{komprimuje jen kdyz je pocet opakovani ò x }
          jnc @compr
          xchg al,ah
         @fill:
          stosb
          dec bx
          jnz @fill
          xchg al,ah
          ret
         @compr:
          or bh,bh;jz @comprbyte
         @comprword:
           push ax
           mov al,2;stosb{store 2}
           mov ax,bx;stosw{store number of repeatz}
           pop ax
           mov [es:di],ah;inc di{store repeated color}
           ret
         @comprbyte:
           push ax
           mov al,1;stosb{store 1}
           mov al,bl;stosb{store number of repeatz}
           pop ax
           mov [es:di],ah;inc di{store repeated color}
           ret

         @compressend:
          {zapise posledni string podle BX=repeatz AH=color}
          call @writestring
          {opravi destsizelo,hi podle ES:DI}
          mov ax,es;sub ax,[cs:offset @destseg];mov bx,di
          test ax,0800h;jz @newLOHIprepared
          test bx,8000h;jz @subAXaddBX
           @addAXsubBX:add ax,0800h;sub bx,8000h;jmp @newLOHIprepared
           @subAXaddBX:sub ax,0800h;add bx,8000h
         @newLOHIprepared:
          shr ax,12
          mov [cs:offset @destsizehi],ax
          mov [cs:offset @destsizelo],bx
pop ds
         @zakompresi:

  {___________________WRITE X_________________}
         {open dest}
          mov ah,3ch;mov cx,0;mov dx,offset dest+1;int 21h;mov [cs:offset @handle],ax
          jnc @okopen;push 4;call errorhalt;@okopen:
         {save X header}
          mov bx,[cs:offset @handle];mov cx,5;mov dx,offset [cs:offset @sir]
          push ds;mov ax,cs;mov ds,ax;mov ah,40h;int 21h;pop ds
         {save palette}
          mov bx,[cs:offset @handle];mov cx,[cs:offset @barev];shl cx,1;add cx,[cs:offset @barev];
          mov dx,offset destpal+768;sub dx,cx;mov ah,40h;int 21h;
         {save bitmap}
          mov ax,[cs:offset @destsizelo];mov [offset com_size  ],ax
          mov ax,[cs:offset @destsizehi];mov [offset com_size+2],ax
          PUSH DS
          mov ds,[cs:offset @destseg]
         @nextpage3:
          mov bx,[cs:offset @handle]
          mov cx,0
          dec word ptr [cs:offset @destsizehi]
          jns @notlast
          mov cx,[cs:offset @destsizelo]
          jcxz @lastsegempty4
         @notlast:
          pushf;pusha
          push cx;mov cx,1;mov dx,0;mov ah,40h;int 21h;
          pop cx; dec cx;  mov dx,1;mov ah,40h;int 21h;
          mov ax,ds;add ax,65536/16;mov ds,ax
          popa;popf
          jns @nextpage3
          @lastsegempty4:
          POP DS
         {close}
          mov bx,[cs:offset @handle];mov ah,3eh;int 21h;

     @AFTER_WRITE:
     {dealloc memory}
     mov ah,49h;mov es,[cs:offset @srcseg];int 21h
     mov ah,49h;mov es,[cs:offset @destseg];int 21h{}
     {set variables}
     mov ax,[cs:offset @totalsir];mov sir,ax
     mov ax,[cs:offset @vys];mov vys,ax
     mov ax,[cs:offset @barev];mov col,ax
     end;
 if bmp=0 then raw_size:=longint(sir)*vys+5+3*col
          else raw_size:=longint(sir)*vys+54+1024;
 inc(com_size,5+3*col);
 writeln;
 if viewer=0 then write(dest) else write(src);
 write('ÄÄÄÄ ',sir,'*',vys,'/',col,' ÄÄÄÄ raw size: ',raw_size);
 if (viewer=0) and (komprese=1) then write(' ÄÄÄÄ compressed: ',com_size,' (',100*com_size div raw_size,'%)');
 writeln;

END.

pri konverzi 'pcx' -> 'x' s parametrem 't' prevede jednu malo castou barvu na cernou
pri transparenci zacerni nejridsi barvu
