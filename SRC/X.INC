(*
PROCEDURE PushVesaBank(n:word);assembler;
 asm push ax
     mov ax,n;
     call VesaBank
     pop ax
     end;


              (*
PROCEDURE nowVesaBank;assembler;
 asm dw 0 end;

PROCEDURE SlowVesaBank(n:word);assembler;
 asm
      push ds
      mov ax,seg VesaBanku
      mov ds,ax

      call VesaBank
      {
      cmp VesaViditelnychBanku,0;jz @end2
      cmp VesaViditelnychBanku,255;jz @end2
      push dx
      mov dx,n
      cmp word ptr nowVesaBank,dx;jz @end1
      mov word ptr nowVesaBank,dx
      push ax
      push bx
      push es
      push ds
      mov ax,4f05h
      mov bx,0
      int 10h
      pop ds
      pop es
      pop bx
      pop ax
      @end1:
      pop dx
      @end2:
       }
      pop ds
      end;
{
PROCEDURE IncVesaBank;assembler;
 asm
      push ax
      mov ax,word ptr nowVesaBank
      inc ax
      push ax
      call SlowVesaBank
      pop ax
      end;
}               *)
PROCEDURE InsertPicture(x1,y1,showsirka,sirka,vyska:word;mydoublex,mydoublescan:byte);assembler;var j,ha:word;
var   myhwsir:word;
      myhwbezshow:word;
 asm
      mov ax,hwsir;mov myhwsir,ax
      sub ax,showsirka;mov myhwbezshow,ax
      push ds
      mov ax,hwsir;mul y1;add ax,x1;adc dx,0;mov di,ax
      mov ax,dx;call VesaBank
      mov si,0
      mov es,sega000
      mov ds,workseg

      mov dx,vyska
      cmp mydoublescan,2;jz @sca2;shr dx,1;@sca2:
      @1:mov cx,showsirka
         push si
            mov bx,di;not bx;cmp bx,cx;jnc @secondpart
            inc bx
            sub cx,bx;push cx
            mov cx,bx;rep movsb
            call incVesaBank
            pop cx
            @secondpart:

{         cmp mydoublex,2;jz @dx2;
         @dx1:test cx,1;jz @loo;dec cx;jz @movsdone;
              @loo:movsb;inc si;dec cx;loop @loo;jmp @movsdone;
         @dx2:rep movsb
         @movsdone:}
         rep movsb

         pop si;add si,sirka;cmp mydoublescan,2;jz @sc2;add si,sirka;@sc2:

         add di,myhwbezshow
           jnc @nobank
           call incVesaBank
         @nobank:

      dec dx;jnz @1

      pop ds
      end;

(*
PROCEDURE LoadX(st:string);
var   leng,now:longint;
      ii,j,k,k0,l,m,titlesir:integer;
      doublescan,doublex:byte;
      leftStart:word;
      precist,
      packedStart,
      packedEnd,
      rawEnd,
      rawPacksize,
      rawPackradek,
      rawZbyvaradek      :word;
      packedZbyvasize    :longint;
      redukovanasirka    :word;
const pixmid=160;
      xcommand=20;

begin
          doublescan     :=1;
          doublex        :=2;

          openfile(st);
          packedZbyvasize:=LengthDataFile;
          ReadDataFile(5,ofs(xsir),dseg);
          ReadDataFile(3*barevw,ofs(pal)+768-3*barevw,dseg);

          if xvys<=200 then ii:=(200-xvys) div 32 else ii:=0;
          redukovanasirka:=320;if xsir<redukovanasirka then redukovanasirka:=xsir;
          if pixMid<xsir*doublex div 4 then leftStart:=0 else leftstart:=pixMid-xsir*doublex div 4;

          packedStart    :=32768;
          packedEnd      :=32768;
          rawEnd         :=0;
          rawPacksize    :=16*xsir; {kolik bajtu zobrazit v tomto zatahu}
          rawPackradek   :=16;      {kolik radek zobrazit v tomto zatahu}
          rawZbyvaradek  :=xvys;    {kolik radek jeste zbyva zobrazit}

          repeat
            if rawPackradek>rawZbyvaradek then begin
              rawPackradek:=rawZbyvaradek;
              rawPacksize :=rawPackradek*xsir;
              end;
            {kdyz uz musi neco nacist, tak z disku precte co nejvic komprimatu}
            if packedEnd-packedStart<rawPacksize+2 then begin
              {nerozpakovanej zbytek presune na adr 32768}
              FastMoveBack(workseg,packedStart,32768,packedEnd-packedStart);
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
            insertpicture(leftStart,ii,redukovanasirka,xsir,rawPackradek,doublescan,doublex);
            inc(ii,rawPackradek*doublescan div 16);
            FastMoveBack(workseg,rawPacksize,0,rawEnd-rawPacksize);
            dec(rawEnd,rawPacksize);
            dec(rawZbyvaradek,rawPackradek);
          until (rawZbyvaradek=0) or (ii>=200 div 16);

          sluzby.CloseDataFile;

end;
*)


PROCEDURE LoadPCX(st:string);
var   leng,now:longint;
      ii,j,k,k0,l,m,titlesir:integer;
      doublescan,doublex:byte;
      leftStart:word;
      precist,
      packedStart,
      packedEnd,
      rawEnd,
      rawPacksize,
      rawPackradek,
      rawZbyvaradek      :word;
      packedZbyvasize    :longint;
      redukovanasirka    :word;
      pcxheader:array[0..127] of byte;
      xsirinss:word;
      fsize:longint;
label mode13,svgato13,modedone;
begin
          doublescan     :=2;
          doublex        :=2;

          {nacte header}
         {$ifdef score}
         fajl:=st;
         if not sluzby.opendatafile(st) then errorhalt(3);
          packedZbyvasize:=LengthDataFile;
         {$else}
          DM.opendatafile(st);
          packedZbyvasize:=LastOpenLength;
          ZavesFileHandler(datahandle,data[getdkod(st,true)].start);
         {$endif}

          fsize:=packedZbyvasize;

          ReadDataFile(128,ofs(pcxheader),seg(pcxheader));
          dec(packedZbyvasize,128);

          if (pcxheader[3]<>8) or (pcxheader[65]<>1) then
            {$ifdef score}
            errorhalt(6);
            {$else}
            errorhalt(48);
            {$endif}
          asm
            mov ax,word ptr pcxheader+ 8;sub ax,word ptr pcxheader+4;inc ax;mov xsir,ax
            mov ax,word ptr pcxheader+10;sub ax,word ptr pcxheader+6;inc ax;mov xvys,ax
            mov ax,word ptr pcxheader+66;mov xsir,ax{totalsir,ax}
            end;

   {nastavi odpovidajici grf.mod}
   if (xsir<=320) and (xvys<=240) then goto mode13;
   if mem[seg(VesaBanku):ofs(VesaBanku)]=255 then VesaInit;{}
   if (mem[seg(VesaBanku):ofs(VesaBanku)]=255) or
      (mem[seg(VesaBanku):ofs(VesaBanku)]=0) then goto svgato13;
   if not mode($101) then  goto svgato13;
   hwsir:=640;
   hwvys:=480;
   goto modedone;

   svgato13:
   doublescan:=1;
   mode13:
{SCORE:   if biosmode<>$13 then mode($13);}
{PARENI:} mode($13);
   hwsir:=320;
   hwvys:=200;

   modedone:
   setbright(0);
{SCORE:   ClearScreen;}


          if xvys<=hwvys then ii:=(hwvys-xvys) div 2 else ii:=0;
          if xsir<=hwsir then redukovanasirka:=xsir else redukovanasirka:=hwsir;
          if hwsir div 2<xsir*doublex div 4 then leftStart:=0 else leftstart:=hwsir div 2-xsir*doublex div 4;

          xsirinss       :=xsir;

          packedStart    :=32768;
          packedEnd      :=32768;
          rawEnd         :=0;
{          rawPackradek   :=10000 div xsir;    {kolik radek zobrazit v tomto zatahu}
{          rawPacksize    :=rawPackradek*xsir; {kolik bajtu zobrazit v tomto zatahu}
          rawPackradek   :=16;    {kolik radek zobrazit v tomto zatahu}
          rawPacksize    :=16*xsir; {kolik bajtu zobrazit v tomto zatahu}
          rawZbyvaradek  :=xvys;    {kolik radek jeste zbyva zobrazit}


          repeat
            if rawPackradek>rawZbyvaradek then begin
              rawPackradek:=rawZbyvaradek;
              rawPacksize :=rawPackradek*xsir;
              end;
            {kdyz uz musi neco nacist, tak z disku precte co nejvic komprimatu}
            if (packedEnd-packedStart<rawPacksize*2+2){krat 2 kvuli PCX vetsim nez raw} then begin
              {nerozpakovanej zbytek presune na adr 32768}
              FastMoveBack(workseg,packedStart,32768,packedEnd-packedStart);
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
                {mov bx,rawPacksize}
                PUSH DS;mov es,workseg;mov ds,workseg

                mov bx,rawPackradek
                mov dx,0

                @nextline:
                add dx,xsirinss

                @next:
                lodsb

                 cmp al,128+64
                 jae @multi

                 @single:
                 dec dx
                 stosb
                 jnz @next
                 jmp @check_end_of_loop

                 @multi:
                 and al,63;mov cl,al;mov ch,0
                 sub dx,cx
                 lodsb
                 rep stosb
                 ja @next

                 @check_end_of_loop:

                dec bx;jnz @nextline

                POP DS
                mov packedStart,si
                mov rawEnd,di
                end;
            if ii+rawPackradek*doublescan div 2>hwvys then rawPackradek:=(hwvys-ii)*2 div doublescan;
            insertpicture(leftStart,ii,redukovanasirka,xsir,rawPackradek,doublex,doublescan);
            inc(ii,rawPackradek*doublescan div 2);
            FastMoveBack(workseg,rawPacksize,0,rawEnd-rawPacksize);
            dec(rawEnd,rawPacksize);
            dec(rawZbyvaradek,rawPackradek);
          until (rawZbyvaradek=0) or (ii>=hwvys);


          {nacte paletu}
          SeekDataFileFromStart(fsize-768);
          ReadDataFile(768,ofs(pal),seg(pal));
          for j:=0 to 767 do pal[j]:=pal[j] shr 2;

         {$ifdef score}
          sluzby.CloseDataFile;
         {$else}
          OdpojFileHandler;
          DM.CloseDataFile;
         {$endif}

end;
