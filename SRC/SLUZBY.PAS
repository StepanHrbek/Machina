UNIT Sluzby;
{$R-}
{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}
                             INTERFACE
{‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹}


{$define dostran_}

TYPE  stringpath=string[80];
      string10=string[10];
      uknastring=^string;

PROCEDURE Pa(n:word);

{graphix}
PROCEDURE Wait250ns;
PROCEDURE EnableCrtc;
PROCEDURE ProtectCrtc;
PROCEDURE Mode13x(crtc5:word);
PROCEDURE ClearScreen13x;
PROCEDURE ReadPal;
PROCEDURE SetColor(color,r,g,b:byte);
PROCEDURE SetBright(n:byte);
PROCEDURE BrightUp(time:byte);
PROCEDURE BrightDown(time:byte);
PROCEDURE PrepareBrightDown(colorful:boolean);
PROCEDURE ShowPal(from,len:byte);
PROCEDURE SmoothSetVis(visx,visy:word);
PROCEDURE Ports2AX;
PROCEDURE BX2ports;
PROCEDURE Refresh(n:byte);
PROCEDURE Refresh2(n:byte);
{VGA driver}
PROCEDURE hereisVGAdriver;far;
{PROCEDURE loadVGAdriver0(st:string);{string zakonceny nulou}
PROCEDURE Bank;
PROCEDURE InitBank;
PROCEDURE ExitBank;
{VESA}
PROCEDURE VesaBanku;
PROCEDURE VesaInit;
FUNCTION  VesaInit512x464:Boolean;
FUNCTION  VesaInit640x480:Boolean;
PROCEDURE VesaSetVis(visy:word);
PROCEDURE VesaBank;
PROCEDURE IncVesaBank;
{keyboard}
FUNCTION  KeyPressed:Boolean;
FUNCTION  ReadKey:char;
PROCEDURE WaitKey;
PROCEDURE ClearKeybBuffer;
{mouse}
PROCEDURE ResetMouse;
PROCEDURE MouseOn;
PROCEDURE MouseOff;
FUNCTION  Ps2:boolean;
FUNCTION  MousePress:Boolean;
PROCEDURE GetMouseChange(var x,y:integer);
PROCEDURE GetMouseOrZero(var x,y,z:word);
PROCEDURE MoveMouse(x,y:word);
PROCEDURE MoveMouseXpul(x,y:word);
FUNCTION  Response(counter,timeoutlen:word):word;
{system}
FUNCTION  Dehexy(ch:char):byte;
FUNCTION  Long2Word(n:longint):word;
PROCEDURE Execute0(prg:stringpath);{string zakonceny nulou}
PROCEDURE RestoreOldDta;
PROCEDURE StoreOldDta;
PROCEDURE StopkyStart;
PROCEDURE StopkyStop;
{text}
PROCEDURE SetTextAttr(c:byte);
PROCEDURE SetTextMode;
PROCEDURE WriXY(x,y:word;st:string);
PROCEDURE SplitY(y:word);
PROCEDURE SetSmoothY(y:byte);
PROCEDURE SetVis(vis:word);
PROCEDURE SplitSetVis(y:word);
PROCEDURE RawGotoXY(x,y:byte);
FUNCTION  RawGetXY:word;
PROCEDURE GotoXY(x:word;y:byte);
PROCEDURE GotoXYaVis(x,y:word;forceCopy:byte);
PROCEDURE SetYinWorkseg(y:word);
PROCEDURE End28Msg(st:string);
PROCEDURE Mesidz(st:string;dy:shortint);
FUNCTION  AskExit:char;
FUNCTION  Ask({KurzorNaStart=4,EscVraciNic=2,inserty=1}flags:byte;veta:string;maxlen:byte;preselect:string;first:char):string;
FUNCTION  MenuSelect(polozek:byte;p:pointer;addy,preselect:word):byte;
FUNCTION  FileSelect(flags:byte;veta,typ,preselect:string):string;
PROCEDURE Help(helpfajl:string);
{big font}
FUNCTION  GetPackedBigCharSeg(font:byte;c:char):word;
FUNCTION  FreeMoreConv:Boolean;
PROCEDURE ConvBigfontDone;
PROCEDURE InsertBardString(color:shortint;destseg,centrx1,y1:word;st:string;var xstart,xsir:word);
PROCEDURE InsertMiniString(color:shortint;destseg,centrx1,y1:word;uknastr:pointer);
PROCEDURE ZmerProporceTenkyhoFontu;
{memory}
PROCEDURE SpeedyMOVS_dozadu_cld_inc;
PROCEDURE SpeedyMOVS_dopredu_std_dec;
PROCEDURE FastMoveBack(whatseg,src,dest,len:word);
PROCEDURE DetectEms;
FUNCTION  AllocConv16(size16:word;var segment:word):Boolean;
FUNCTION  AllocEMS16K(size16K:word;var handle:word):Boolean;
PROCEDURE DeallocConv(var segment:word);
PROCEDURE DeallocEMS(var handle:word);
PROCEDURE CopySeg(src,dest:word);
{textury}
PROCEDURE FiltrujTextureInSeg(st:string;myseg:word);
PROCEDURE MakeTextureInSeg(n:char;myseg:word);
{stringy}
{FUNCTION  toASCIIZ(dest : PChar; str : string) : PChar;}
FUNCTION  StringPtr(seg,ofs:word):string;
PROCEDURE UpCaseString(p:uknastring);
FUNCTION  LoCaseString(st:string):string;
FUNCTION  CutStringFromString(delic:char;var st:string):string;
PROCEDURE CutNumberFromString(delic:char;var st:string;var prom:word);
PROCEDURE ZalomPath(var st:stringpath);
{hvezdickova konvence}
PROCEDURE OdstranUvozovky(var st:string);
FUNCTION  OdpovidaKonvenci(st:string):boolean;
FUNCTION  XjeprvkemY(norm,hvezd:string):boolean;
{file}
PROCEDURE GetCurDir;
FUNCTION  SetDrive(path:stringpath):boolean;
FUNCTION  SetDriveAndZkratString(var path:stringpath):boolean;
FUNCTION  CD(dir:stringpath):boolean;
FUNCTION  MakeAndEnterDir(path:stringpath):boolean;
PROCEDURE ZavesFileHandler(handle:word;adr:longint);
PROCEDURE OdpojFileHandler;
FUNCTION  OpenDataFile(st:stringpath):boolean;
FUNCTION  LengthDataFile:longint;
FUNCTION  ReadDataFile(len,kamofs,kamseg:word):word;
PROCEDURE SeekDataFileFromCur(okolik:longint);
PROCEDURE SeekDataFileFromStart(kam:longint);
FUNCTION  CloseDataFile:boolean;
FUNCTION  InteligentneHledejSoubor(vychoziDir,hledanySoubor,musiobsahovat:stringpath;var nalezeno:stringpath):boolean;
FUNCTION  DeleteFile(st:stringpath):word;
FUNCTION  RenameFile(old,new:stringpath;hazeterror:boolean):word;
FUNCTION  CallCommand(st:stringpath):boolean;
PROCEDURE CopyFile(src,dest:stringpath);
FUNCTION  SetAttr(st:stringpath;attr:word):boolean;
{INI}
FUNCTION  ReadIni(INIname:stringpath;vars:pointer):Boolean;
PROCEDURE WriteIni(INIname:stringpath;vars:pointer;filtr:byte);
PROCEDURE ModifyIniPodleIni(NewIni,OldIni:stringpath);

{$I data.inc}
{$I tenkej.inc}
{$I tlustej.inc}
{$I sipka.inc}
{$I bigfont2.inc}
{$I bard.inc}
{$I setup.inc}
{$I const.inc}

CONST
      wrisir       =512;
      wrivys       =512;
      vissir       =360;
      visvys       =464;

      LB=256-1;
      RB=256-2;
      VGA_MODE:byte=0;{0-text;1-vga360;2-svga512;3-svga640}
      textur                       =4;
      maxudajuINI                  =35;
      maxscreenbutts               =30;
      mousepresent:boolean=false;
      EMSdetected:boolean=false;
      textattr:byte=7;
      lastchar     ='©';
      txsir        =80;
{*}   shiftSetvis  =11;
      skiplines    =3;
      infoline     =0;
      nowbank:byte =0;
      bardhacky:array[#128..lastchar] of word=(
        {nic,car,hac,kr[4] 'A'..'z'[64] dx[16] dy[16]}
        {Ä}2*64-64+ord('C')+256* 8+1*8192,
        {Å}0*64-64+ord('u')+256* 0+1*8192,
        {Ç}1*64-64+ord('e')+256* 4+1*8192,
        {É}2*64-64+ord('d')+256* 1+5*8192,
        {Ñ}0*64-64+ord('a')+256* 0+1*8192,
        {Ö}2*64-64+ord('D')+256*12+2*8192,
        {Ü}2*64-64+ord('T')+256* 9+1*8192,
        {á}2*64-64+ord('c')+256* 1+1*8192,
        {à}2*64-64+ord('e')+256* 1+1*8192,
        {â}2*64-64+ord('E')+256* 9+1*8192,
        {ä}1*64-64+ord('L')+256*10+0*8192,
        {ã}1*64-64+ord('I')+256*11+0*8192,
        {å}2*64-64+ord('l')+256* 0+1*8192,
        {ç}1*64-64+ord('l')+256* 2+1*8192,
        {é}0*64-64+ord('A')+256* 0+1*8192,
        {è}1*64-64+ord('A')+256*15+1*8192,
        {ê}1*64-64+ord('E')+256*12+1*8192,
        {ë}2*64-64+ord('z')+256* 0+1*8192,
        {í}2*64-64+ord('Z')+256* 6+1*8192,
        {ì}0*64-64+ord('o')+256* 0+1*8192,
        {î}0*64-64+ord('o')+256* 0+1*8192,
        {ï}1*64-64+ord('O')+256*10+0*8192,
        {ñ}3*64-64+ord('u')+256* 0+0*8192,
        {ó}1*64-64+ord('U')+256*17+1*8192,
        {ò}1*64-64+ord('y')+256* 5+1*8192,
        {ô}0*64-64+ord('O')+256* 0+1*8192,
        {ö}0*64-64+ord('U')+256* 0+1*8192,
        {õ}2*64-64+ord('S')+256* 7+1*8192,
        {ú}2*64-64+ord('L')+256*10+1*8192,
        {ù}1*64-64+ord('Y')+256*10+1*8192,
        {û}2*64-64+ord('R')+256*10+2*8192,
        {ü}2*64-64+ord('t')+256* 0+3*8192,
        {†}1*64-64+ord('a')+256* 5+1*8192,
        {°}1*64-64+ord('i')+256* 1+6*8192,
        {¢}1*64-64+ord('o')+256* 5+1*8192,
        {£}1*64-64+ord('u')+256* 4+1*8192,
        {§}2*64-64+ord('n')+256* 2+1*8192,
        {•}2*64-64+ord('N')+256*11+1*8192,
        {¶}3*64-64+ord('U')+256*12+0*8192,
        {ß}0*64-64+ord('O')+256*12+1*8192,
        {®}2*64-64+ord('s')+256* 0+1*8192,
        {©}2*64-64+ord('r')+256* 1+1*8192
        );

VAR   pal:array[0..767+768] of byte;
      darkcolor:array[0..2] of byte;
      nowbright,smoothYonScreen:byte;
      oldDTAofs,oldDTAseg:word;
      newDTA:array[1..43] of byte;
      lasttextvis,nowvis,datahandle,workseg:word;
      YinWorkseg,scroll2Y:integer;
      biosmode   :byte absolute 0:$449;
      biostxsir  :word absolute 0:$44a;
      biostxvys  :byte absolute 0:$484;
      bioscharvys:word absolute 0:$485;
      biosfree   :pointer absolute 0:$4f0;
{     fakePS2keyb:^byte absolute 0:$4f4;}
{     txsirtxvys :word absolute 0:$44c;}
      frameseg   :word;
      TlustejPropSir,TenkejPropSir:array[' '..lastchar] of byte;

      screenbutts                  :byte;
      screenbutt                   :array[1..maxscreenbutts] of record x1,y1,x2,y2,n:word;end;

      curdir                       :stringpath;
      color1forsetbright           :byte;
      black41                      :byte;
      Mbuttons                     :byte;

      stopkyCas                    :longint;

      LocalHelp                    :pointer;

{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}
                          IMPLEMENTATION
{‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹}

USES dos;

PROCEDURE ErrorHalt(n:word);assembler;
 asm push n;push n;xor ax,ax;mov es,ax;call [es:biosfree];end;

PROCEDURE ErrorMsg(st:string);
begin
 asm mov ax,3;int 10h;end;
 writeln(st);
 errorhalt(46);
end;


PROCEDURE Pa(n:word);
const hal:boolean=false;
begin
 if (pal[0]>0) or (pal[1]>0) or (pal[2]>0) then
  if hal then errorhalt(200+n);
end;

{€€€€€€€€€€€€€€€€ KEYBOARD €€€€€€€€€€€€€€€€}
FUNCTION  KeyPressed;begin asm mov ah,0bh;int 21h;mov @result,al;end;end;
FUNCTION  ReadKey;begin asm mov ah,8;int 21h;mov @result,al;end;end;
PROCEDURE WaitKey;assembler;asm mov ax,0c08h;int 21h;end;
PROCEDURE ClearKeybBuffer;
var   head:word absolute 0:$41a;
      tail:word absolute 0:$41c;
begin
 tail:=head;
end;



{€€€€€€€€€€€€€€€€ BIG FONT €€€€€€€€€€€€€€€€}

CONST fontu=2;
VAR   charseg:array[1..fontu,' '..lastchar] of word;
      cetnost:array[1..fontu,' '..lastchar] of byte;
CONST charseglen=sizeof(charseg)+sizeof(cetnost);

CONST vys=128+1;
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
function Q(x,y:shortint):byte;
begin
 if (y<0) or (y>=vys shr 3) or (x<0) or (x>=sir shr 3) then q:=0 else
  q:=tlustej[zn,y] shr (8-x) mod 2;
end;
Begin
 {clr chara}
 asm mov ax,ds;mov es,ax;lea di,chara;mov cx,sir*vys/8/2/2;db 66h;xor ax,ax;db 66h;rep stosw;end;

 for j:=0 to vys shr 3-1 do for i:=0 to sir shr 3-1 do begin
   z:=bigfont_tab[2*(2*(2*(2*(2*(2*(2*(2*
      q(i-1,j+1)+q(i,j+1))+q(i+1,j+1))+q(i-1,j))+q(i,j))+q(i+1,j))+q(i-1,j-1))+q(i,j-1))+q(i+1,j-1)]
      -255+n;
   case size of 2:for k:=0 to 7 do chara[8*j+k,i]:=bigfont_b[z,k];
                1:for k:=0 to 3 do begin
                   l:=bigfont_b[z,2*k] or bigfont_b[z,2*k+1];
                   l:=l or l shl 1;
                   l:=l and 128+l shl 1 and 64+l shl 2 and 32+l shl 3 and 16;
                   chara[4*j+k,i div 2]:=chara[4*j+k,i div 2] or (l shr (4*(i mod 2)));
                   end;
                end;
   end;
End;

PROCEDURE TransTo256Bitmap;assembler;
 asm mov ax,ds;mov es,ax;
     lea di,sha;mov cx,sir*vys/2/2;db 66h;xor ax,ax;db 66h;rep stosw;{clear bitmap}
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

PROCEDURE CONVbigfontDone;
var i:word;
    c:char;
begin
 for i:=1 to fontu do for c:=' ' to lastchar do deallocConv(charseg[i,c]);
end;

FUNCTION GetPackedBigCharSeg(font:byte;c:char):word;
var   j,myseg:word;
label 2,bad;
begin
 myseg:=charseg[font,c];
 if myseg=0 then begin
         2:
         asm mov ah,48h;mov bx,65535;int 21h;mov j,bx;end;
         if j<300 then if FreeMoreConv then goto 2 else goto bad;
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
             {push 103;call errorhalt {errorhalt(103)}
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
             shr bx,4;inc bx;mov ah,48h;int 21h;jc bad;mov myseg,ax;

             mov es,ax
             mov si,offset sha;mov di,0  {copy}
            pop cx{size}
             rep movsb
             mov al,255;stosb
            end;
         charseg[font,c]:=myseg;
         end;

 inc(cetnost[font,c]);
 GetPackedBigCharSeg:=myseg;
 exit;
bad:
 GetPackedBigCharSeg:=0;
end;


{kresli bardstring do zadanyho segmentu, sirka=wrisir}
PROCEDURE InsertBardString(color:shortint;destseg,centrx1,y1:word;st:string;var xstart,xsir:word);
var   i,j,x,x1,x2,len,myofsb,sir8,dxy1:word;
      vys,scanlajna:byte;
      tenhleznak,podznamenkem:char;
label full,core,konecradky;
begin

 len:=0;

 for i:=1 to length(st) do if st[i]<#128 then inc(len,bardhead[                 st[i]         ].bdx2 div 4)
                                         else inc(len,bardhead[chr(64+bardhacky[st[i]] and 63)].bdx2 div 4);
 xsir:=len;
 x:=centrx1+1-len div 2+wrisir*y1;
 xstart:=x;
 i:=1;

 full:
 if i>length(st) then goto konecradky;
 tenhleznak:=st[i];
 podznamenkem:=#0;
 dxy1:=0;
 if tenhleznak>#127 then begin
                         podznamenkem:=chr(64+bardhacky[tenhleznak] and 63);
                         dxy1:=1+((bardhacky[tenhleznak] shr 8) and 31)
                                +wrisir*(bardhacky[tenhleznak] shr 13);
                         tenhleznak:=chr(ord('z')+bardhacky[tenhleznak] shr 6 and 3);
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
     mov es,destseg
     mov di,x1
     mov si,myofsb;add si,offset bardbody
     mov bl,vys
     mov ah,color
     mov bh,ah;inc bh
    @nextline:
     cmp bh,1;jnz @onecolor;inc scanlajna;mov ah,scanlajna;shr ah,2;cmp ah,8;jnc @onecolor;inc ah;@onecolor:
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
    inc(i);
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

{pise centrovanej string do destsegu}
PROCEDURE InsertMiniString(color:shortint;destseg,centrx1,y1:word;uknastr:pointer);assembler;
 asm
      mov dx,0
      mov si,word ptr uknastr
      mov ax,word ptr uknastr+2
      db 8eh,0e0h{mov fs,ax}
      db 64h{fs};lodsb;or al,al;jz @end1;mov cl,al;mov ch,0
      mov bx,offset tenkejPropsir-' '
      mov ah,0
      @1:db 64h{fs};lodsb;
      xlat;add dx,ax;loop @1
      @end1:{mov @result,cx}
      shr dx,1
      mov bx,dx

      mov es,destseg
      mov si,word ptr uknastr
      mov ax,wrisir
      mul y1
      add ax,centrx1{k x pricte centrx1}
      inc ax
      sub ax,bx{od x odecte polovinu sirky stringu}
      mov di,ax
      mov bl,color

      db 64h{fs};lodsb
      or al,al
      jz @end
      mov bh,al{pocet pismen}
      mov ah,0{mezera mezi pismeny}
 @nextchar:
      db 64h{fs};lodsb

      push si
      push ax

      shl ax,4
      add ax,offset tenkej-16*' '
      mov si,ax
      mov dx,16
     @nextline0:
      lodsb
      mov cx,8
      @2:shl al,1;jnc @noput;mov [es:di],bl;@noput:inc di;loop @2
      add di,wrisir-8
      dec dx;jnz @nextline0

      pop ax
      pop si
      sub di,16*wrisir
      push bx;mov bx,offset tenkejPropsir-' ';xlat;add di,ax;pop bx

      dec bh
      jnz @nextchar

      @end:
      end;

PROCEDURE ZmerProporceTenkyhoFontu;assembler;
 {zmeri sirky pismen}
  asm
   mov ax,ds;mov es,ax
   lea si,tenkej+16
   lea di,tenkejPropsir
   call near ptr @zmerto
   lea si,tlustej+16
   lea di,tlustejPropsir
   call near ptr @zmerto
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
   retn

   @end:
   end;


{€€€€€€€€€€€€€€€€ MEMORY €€€€€€€€€€€€€€€€}

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

PROCEDURE FastMoveBack(whatseg,src,dest,len:word);assembler;
 asm {ULTRA FAST MOVE (dword speed)}
     mov cx,len;or cx,cx;jz @end{nic kdyz se ma presunout 0 bajtu dlouhej kus}
     mov si,src;mov di,dest
     cmp si,di;jz @end{nic, kdyz je posun o 0 bajtu}
     PUSH DS;mov es,whatseg;mov ds,whatseg
     call speedyMOVS_dozadu_cld_inc
     POP DS
     @end:
     end;

PROCEDURE DetectEms;assembler;
const emmname:array[1..9] of char='EMMXXXX0'#0;
(*asm
   {open emmxxxx}mov ax,3d00h;lea dx,emmname;int 21h;jc @end
   push ax;mov bx,ax;mov ax,4407h;int 21h;cmp al,0;jz @bad;mov EMSdetected,1;@bad:
   {close}pop bx;mov ah,3eh;int 21h;
   @end:
   end;*)
 asm
        cmp     detekovatems,0;jz @detected

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

        @detected:
        {get emm frame}
        mov ax,4100h;int 67h;cmp ah,0;jnz @noemm;mov frameseg,bx

        mov     EMSdetected,1
        @noemm:
        end;

FUNCTION  AllocConv16(size16:word;var segment:word):Boolean;
var i:word;
begin
 asm mov @result,1
     mov ah,48h;mov bx,size16;int 21h;
     jnc @ok;mov @result,0;xor ax,ax;@ok:
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
     mov word ptr [es:bx],0;mov ax,4500h;int 67h
     @end:end;

PROCEDURE CopySeg(src,dest:word);assembler;
 asm
      PUSH DS
      mov es,dest
      mov ds,src
      mov cx,16384;xor si,si;xor di,di;db 66h;rep movsw
      POP DS
      end;


{€€€€€€€€€€€€€€€€ TEXTURY €€€€€€€€€€€€€€€€}

PROCEDURE FiltrujTextureInSeg(st:string;myseg:word);
const sir=256;
      vys=256;
      min=25;
      max=40;

procedure Add_OsekniTop(delta,top:byte);assembler;
 asm
     push ds
     push es;pop ds
     xor si,si
     xor di,di
     mov bl,delta;mov bh,bl;push bx;push bx;db 66h;pop bx
     mov cx,16384
     mov dl,top
     @1:
     db 66h;lodsw
     db 66h;add ax,bx
     cmp al,dl;jbe @nepretek1;mov al,dl;@nepretek1:
     cmp ah,dl;jbe @nepretek2;mov ah,dl;@nepretek2:db 66h;rol ax,16
     cmp al,dl;jbe @nepretek3;mov al,dl;@nepretek3:
     cmp ah,dl;jbe @nepretek4;mov ah,dl;@nepretek4:db 66h;rol ax,16
     db 66h;stosw
     loop @1
     pop ds
 end;

procedure Sub_OsekniBot(delta,bot:byte);assembler;
 asm
     push ds
     push es;pop ds
     xor si,si
     xor di,di
     mov bl,delta;mov bh,bl;push bx;push bx;db 66h;pop bx
     mov cx,16384
     mov dl,bot
     @1:
     db 66h;lodsw
     db 66h;sub ax,bx
     cmp al,dl;jae @nepodtek1;mov al,dl;@nepodtek1:
     cmp ah,dl;jae @nepodtek2;mov ah,dl;@nepodtek2:db 66h;rol ax,16
     cmp al,dl;jae @nepodtek3;mov al,dl;@nepodtek3:
     cmp ah,dl;jae @nepodtek4;mov ah,dl;@nepodtek4:db 66h;rol ax,16
     db 66h;stosw
     loop @1
     pop ds
 end;

procedure OsekniAll(bot,top:byte);assembler;
 asm
     push ds
     push es;pop ds
     xor si,si
     xor di,di
     mov cx,16384
     mov dl,bot
     mov dh,top
     @1:
     db 66h;lodsw
     cmp al,dl;jae @nepodtek1;mov al,dl;@nepodtek1:
     cmp ah,dl;jae @nepodtek2;mov ah,dl;@nepodtek2:
     cmp al,dh;jbe @nepretek1;mov al,dh;@nepretek1:
     cmp ah,dh;jbe @nepretek2;mov ah,dh;@nepretek2:db 66h;rol ax,16
     cmp al,dl;jae @nepodtek3;mov al,dl;@nepodtek3:
     cmp ah,dl;jae @nepodtek4;mov ah,dl;@nepodtek4:
     cmp al,dh;jbe @nepretek3;mov al,dh;@nepretek3:
     cmp ah,dh;jbe @nepretek4;mov ah,dh;@nepretek4:db 66h;rol ax,16
     db 66h;stosw
     loop @1
     pop ds
 end;

procedure ShlSeg(a,b:byte);assembler;asm
     push ds
     push es;pop ds
     xor si,si
     xor di,di
     mov bl,a;mov bh,bl;push bx;push bx;db 66h;pop bx
     mov dl,b;mov dh,dl;push dx;push dx;db 66h;pop dx
     mov cx,32768/2
     @1:
     db 66h;lodsw
     db 66h;sub ax,bx
     db 66h;add ax,ax
     db 66h;add ax,dx
     db 66h;stosw
     loop @1
     pop ds
 end;


procedure RandomujPutcolorSeg(a,b:byte);assembler;asm
     push ds
     push es;pop ds
     xor si,si
     xor di,di
     mov ch,b;mov cl,0
     mov al,a
     @1:
     add di,[cs:si]
     add di,5555
     stosb
     add si,22
     loop @1
     pop ds
 end;

procedure RandomujSwapcolorSeg(b:byte);assembler;asm
     push ds
     push es;pop ds
     xor si,si
     xor di,di
     mov ch,b;mov cl,0
     @1:
     add di,[cs:si]
     add di,5555
     movsb
     add si,21
     loop @1
     pop ds
 end;

procedure Sesikmi1Seg;assembler;asm
     push ds
     push es;pop ds
     xor si,si
     xor di,di
     mov cx,0
     @1:
     movsb
     add di,sir
     loop @1
     pop ds
 end;

procedure SwapniOsySeg;assembler;asm
     push ds
     push es;pop ds
     xor si,si
     xor di,di
     mov dx,sir
     @2:
     mov cx,dx
     push si
     push di
     @1:
     lodsb;xchg al,[di];mov [si-1],al
     add di,sir
     loop @1
     pop di;add di,sir+1
     pop si;add si,sir+1
     dec dx
     jnz @2
     pop ds
 end;


procedure PrevalcujSeg;assembler;asm
     push ds
     push es;pop ds
     xor si,si
     xor di,di
     mov cx,0
     @1:
     lodsb
     xchg al,[di]
     mov [si-2],al
     inc di
     add si,sir+1
     loop @1
     pop ds
 end;


procedure ZamlzSeg1;assembler;asm
     push ds
     push es;pop ds
     mov di,0
     mov cx,0
     mov al,[di]
     @1:add al,[di];add al,[di+sir];add al,[di-sir];add al,1;shr al,2;stosb;loop @1
     pop ds
 end;

procedure ZamlzSeg2;assembler;asm{was:12+6,100,2312}{now:4+11,71,1357}
     push ds
     push es;pop ds
     mov di,-2

     {first line loop   DI=65534..sir-4}
     mov al,[di-sir+1];add al,[di+sir+1]
     mov ah,[di-sir+2];add ah,[di+sir+2]
     mov dx,[di]
     mov bx,[di+2]
     mov cx,sir/2;call near ptr @3

     {main loop   DI=sir-2..65536-sir-4}
     mov al,[di-sir+1];add al,[di+sir+1]
     mov ah,[di-sir+2];add ah,[di+sir+2]
     mov cx,32768-sir;call near ptr @2

     {last line loop   DI=65536-sir-2..65532}
     mov al,[di-sir+1];add al,[di+sir+1]
     mov ah,[di-sir+2];add ah,[di+sir+2]
     mov cx,sir/2;call near ptr @2

     jmp @end

     {-PROC-}
     @1:
     db 66h{eax};mov ax,[di-sir];
     db 66h{eax};add ax,[di+sir];
     db 66h{eax};shr ax,8
     @2:
     db 66h{ebx};mov bx,[di];
     mov dx,bx
     db 66h{ebx};shr bx,16
     @3:
     add ax,dx
     add ax,bx
     add ax,404h
     shr ah,2;shr al,2
     add al,dh
     add ah,bl
     shr ah,1;shr al,1
     stosw
     loop @1
     ret near

     @end:
     pop ds
 end;


procedure RozsypSeg;assembler;asm
push ds
push es;pop ds
xor si,si
xor di,di

mov bx,[si]

mov dx,sir
@mlznextslp:
mov cx,vys;cmp dx,1;jnz @fullvys;sub cx,2;@fullvys:
@mlznextline:
add si,sir
mov ax,bx
mov bx,[si]

;{testuje presyp AL,AH}
cmp al,ah
jz @same1
jnc @incAH
sub ax,2*0ffh
@incAH:
add ax,0ffh
@same1:

;{testuje presyp AL,BL}
cmp al,bl
jz @same2
jnc @incBL
dec bx;{bl}
inc ax;{al}
jmp @same2
@incBL:
inc bx;{bl}
dec ax;{al}
@same2:

mov [si-sir],ax

loop @mlznextline
sub si,vys*sir-1
dec dx
jnz @mlznextslp
pop ds
end;

procedure SubBox(xo:byte;adr,x,y:word);assembler;asm
     push ds
     push es;pop ds
     mov di,adr;add di,x
     mov dx,y
     mov al,xo
     @2:
     mov cx,x
     sub di,cx
     @1:
     sub [di],al
     inc di
     loop @1
     add di,sir
     dec dx
     jnz @2
     pop ds
     end;


Var   a,b:byte;
      i:word;
      code:word;
      c:char;
      x0,y0,tsir,tvys:byte;
      x,y:word;

Begin
 c:=st[1];
 delete(st,1,1);
 a:=0;
 b:=0;
 if st>'' then begin
   val(cutstringfromstring('/',st),a,code); if code>0 then errorhalt(49);
   if st>'' then val(st,b,code);            if code>0 then errorhalt(49);
   end;
 asm mov es,myseg;end;
 case c of '+':begin if b=0 then b:=max;Add_OsekniTop(a,b);end;
           '-':begin if b=0 then b:=min;Sub_OsekniBot(a,b);end;
           '*':begin
               if a=0 then a:=25;
               if b=0 then b:=10;
               ShlSeg(a,b);
               end;
           '\':SwapniOsySeg;
           'o':begin
               if a=0 then a:=min;
               if b=0 then b:=max;
               OsekniAll(a,b);
               end;
           'a':begin
               if b=0 then b:=100;
               case a of 0:RandomujSwapcolorSeg(b);
                         1:Sesikmi1Seg;
                         2:;
                         end;
               end;
           'r':begin
               if a=0 then a:=32;
               if b=0 then b:=20;
               RandomujPutcolorSeg(a,b);
               end;
           'p':begin
               PrevalcujSeg;
               RozsypSeg;
               end;
           'm':ZamlzSeg1;
           'n':ZamlzSeg2;
           's':RozsypSeg;
           'z':begin
               if a=0 then a:=5;
               y0:=0;
               y:=y0;
               repeat
                x0:=random(256);
                x:=x0;
                tvys:=30+random(15);
                if word(y)+word(tvys)+30>word(y0)+vys then tvys:=y0+vys-y;
                repeat
                 tsir:=30+random(30);
                 if word(x)+word(tsir)+30>word(x0)+sir then tsir:=x0+sir-x;
                 asm mov es,myseg;end;
                 SubBox(a,sir*(y+5)+x+3,tsir-6,tvys-10);
                 inc(x,tsir);
                until x=x0+sir;
                inc(y,tvys);
               until y=y0+vys;
               for i:=1 to 3 do RozsypSeg;
               end;
           end;
End;


{$i textury.inc}

PROCEDURE MakeTextureInSeg(n:char;myseg:word);
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

const min4=25;{nejnizsi barva pro texturu4}

Begin
 {nastavi ES pro vsechny dalsi procedury}
 asm mov es,myseg;end;

 case n of

 'a':{ ..........TEXTURA 0.......... }
   begin
   Foggy;
   for i:=1 to 60 do for j:=0 to bobu do begin
     {$R-}
     inc(lastadr[2*j+1],fogsir*(random(spee)-sped)+(random(spee)-sped));odmlzit(lastadr[2*j+1]);
     {$R-}{*}
     end;
   end;

 'b':{ ..........TEXTURA 1.......... }
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

 'c','d':{ ..........TEXTURA 2,3.......... }
   begin
   if n='c' then Foggy;
   for i:=0 to 200 do maxiryha(random(65535),4+random(4));
   end;

 'e':{ ..........na rychlost optimalizovana TEXTURA.......... }
   begin
   asm {fill seg}xor di,di;db 66h;mov ax,257*36;dw 257*36;mov cx,32768/2;db 66h;rep stosw;end;
   for i:=1 to 100 do zamlzit(random(65535));
   for i:=0 to 30 do maxiryha(random(65535),4+random(4));
   asm
    {sub seg}
    xor di,di;mov cx,0;mov ah,2+min4
    @4:mov al,[es:di];sub al,36-min4;cmp al,3+min4;jc @ok;mov al,ah;@ok:stosb;
    loop @4{}
    end;
   end;

 'h':{..................hvezdicky...............}
    begin
    asm
     mov es,myseg
     xor di,di
     mov cx,65536/2/2
     db 66h;xor ax,ax;db 66h;rep stosw
     end;
    for i:=1 to 3000 do byte(mem[myseg:random(65535)]):=25+random(16);
    end;

 'x':{..........bludiste z barev 19 a 22.........}
  asm
   PUSH DS
   mov es,myseg
   mov ds,myseg
   xor si,si
   mov di,si
   db 66h;mov ax,19+22*256;dw 19+22*256
   mov cx,65536/4;db 66h;rep stosw
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
   end;

 'y':{.............cerne nic...........}
  asm
   mov es,myseg
   xor si,si
   mov di,si
   db 66h;mov ax,0;dw 0
   mov cx,65536/4;db 66h;rep stosw
   end;

 't':testing;

 end;

End;

{€€€€€€€€€€€€€€€€ MOUSE €€€€€€€€€€€€€€€€}
PROCEDURE ResetMouse;assembler;asm mov ax,0;int 33h;inc ax;jnz @nomouse;mov mousepresent,1;mov Mbuttons,bl;@nomouse:end;
PROCEDURE MouseOn;assembler;   asm cmp mousepresent,0;jz @end;mov ax,1;int 33h;@end:end;
PROCEDURE MouseOff;assembler;  asm cmp mousepresent,0;jz @end;mov ax,2;int 33h;@end:end;

FUNCTION  Ps2:boolean;
begin
 asm mov ch,0
     cmp mousepresent,0;jz @end;
     mov ax,24h;int 33h;cmp ch,4;jz @ps2;mov ch,0;@ps2:
     @end:
     mov @result,ch;
     end;
end;

FUNCTION MousePress:Boolean;
begin
 asm mov bl,mousepresent;or bl,bl;jz @nomouse
     mov ax,3;int 33h
     @nomouse:
     mov @result,bl
     end;
end;

PROCEDURE GetMouseOrZero(var x,y,z:word);
var i,j,k:word;
begin;
 if mousepresent then begin
   asm mov ax,3;int 33h;mov k,bx;mov i,cx;mov j,dx;end;
   x:=i;y:=j;z:=k;
   end
 else begin
   x:=0;y:=0;z:=0;
   end
end;

PROCEDURE MoveMouse(x,y:word);assembler;{nastaveni polohy M-x-y}
 asm
     cmp mousepresent,0;jz @nomouse
     mov ax,4;mov cx,x;mov dx,y;int 33h;
     @nomouse:
     end;

PROCEDURE MoveMouseXpul(x,y:word);assembler;{nastaveni polohy M-x-y}
 asm
     cmp mousepresent,0;jz @nomouse
     mov ax,4;mov cx,x;shl cx,1;mov dx,y;int 33h
     @nomouse:
     end;

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

FUNCTION Response(counter,timeoutlen:word):word;
var   c,i,mousex,mousey,mousez,lastx,lasty,lastz,timer:word;
const kod_timeout=999;
begin
 c:=0;
 timer:=0;
 GetMouseOrZero(mousex,mousey,mousez);
 repeat
   if timeoutlen>0 then inc(timer);
   if timer>timeoutlen then c:=kod_timeout;

   if counter>1 then begin
     dec(counter);
     if counter=1 then c:=kod_timeout;{dobeh counter, sipka neni nad butt}
     end;
   if keypressed then c:=ord(readkey);

   lastx:=mousex;
   lasty:=mousey;
   lastz:=mousez;
   GetMouseOrZero(mousex,mousey,mousez);
   if (lastx<>mousex) or (lasty<>mousey) or (lastz<>mousez) then timer:=0;

   if (mousez>0) or (c=13) then begin
     c:=256-mousez;
     if (c=LB) then
      for i:=1 to screenbutts do with screenbutt[i] do
       if (mousex>=x1) and (mousex<=x2) and (mousey>=y1) and (mousey<=y2) then c:=n;
     end;
   refresh(1);
 until c>0;
 Response:=c;
end;

{€€€€€€€€€€€€€€€€ SYSTEM €€€€€€€€€€€€€€€€}
CONST hexy:array[0..15] of char='0123456789abcdef';

FUNCTION Dehexy(ch:char):byte;
begin
 case ch of '0'..'9':dehexy:=ord(ch)-ord('0');
            'a'..'f':dehexy:=ord(ch)-ord('a')+10;
            'A'..'F':dehexy:=ord(ch)-ord('A')+10;
                else dehexy:=255;
                end;
end;

FUNCTION Long2Word(n:longint):word;
begin
 if n>65535 then Long2Word:=65535 else if n<0 then Long2Word:=0 else Long2Word:=n;
end;

PROCEDURE Refresh(n:byte);assembler;
 asm mov ch,0;mov cl,n;
     mov dx,3dah;
     {cekat dokud neni na ceste dolu}
     @2:in al,dx;test al,8;jnz @2;
     {cekat dokud neni na navratu nahoru}
     @3:in al,dx;test al,8;jz @3
     {testovat ze jede pouze nahoru x krat za sebou, jinak skok na predchozi radek}
     mov bx,0;@5:inc bx;cmp bx,VadnejRetrace;jz @done;
                 in al,dx;test al,8;jnz @5;jmp @3
     @done:
     loop @2;
     end;

PROCEDURE Refresh2(n:byte);assembler;
 asm mov ch,0;mov cl,n;
     {cekat dokud neni na navratu nahoru}
     @5:in al,dx;test al,8;jz @5;
     {cekat dokud neni na ceste dolu}
     @2:mov dx,3dah;in al,dx;test al,8;jnz @2;
     loop @2;
     end;

PROCEDURE RestoreOldDta;assembler;
 asm mov ah,1ah;mov dx,oldDTAofs;push ds;mov ds,oldDTAseg;int 21h;pop ds;end;

PROCEDURE StoreOldDta;assembler;
 asm mov ah,2fh;int 21h;mov oldDTAseg,es;mov oldDTAofs,bx
     mov ah,1ah;mov dx,offset newDTA;int 21h;end;

PROCEDURE Ports2AX;assembler;
 asm
     push dx
    {vga ports 2 ax}
     {write:}mov dx,3c4h;mov al,2;out dx,al;inc dx;in al,dx;mov ah,al
     {read:}mov dx,3ceh;mov al,4;out dx,al;inc dx;in al,dx
     pop dx
     end;

PROCEDURE BX2ports;assembler;
 asm
     push dx
     push ax
    {restore vga ports from bx}
     {write:}mov dx,3c4h;mov al,2;mov ah,bh;out dx,ax
     {read:}mov dx,3ceh;mov al,4;mov ah,bl;out dx,ax
     pop ax
     pop dx
     end;

PROCEDURE Execute0(prg:stringpath);
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


var   hh0,mm0,ss0,tt0,hh1,mm1,ss1,tt1:word;
PROCEDURE StopkyStart;
begin
 GetTime(hh0,mm0,ss0,tt0);
end;

PROCEDURE StopkyStop;
begin
 GetTime(hh1,mm1,ss1,tt1);
 stopkyCas:=tt1-tt0+100*(ss1-ss0+60*(mm1-mm0+60*(hh1-hh0)));
end;


{€€€€€€€€€€€€€€€€ VGA driver €€€€€€€€€€€€€€€€}

PROCEDURE hereisVGAdriver;assembler;
 asm dw 10ah,10ah,10ah,10ah,10bh{bank,init,exit,setvis,info}
     retf
     db 'nic',0
     dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
     dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
     dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
     dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
     end;
(*
PROCEDURE loadVGAdriver0(st:stringpath);
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
*)
{$ifdef dostran}
PROCEDURE     Bank;    assembler;asm pusha;mov ah,0;div viditelnychbanku;mov nowbank,ah;mov al,ah
                                     mov bx,offset hereisVGAdriver-100h;add bx,[cs:bx+100h];push cs;call bx;
                                     popa;end;
PROCEDURE InitBank;    assembler;asm mov bx,offset hereisVGAdriver-100h;add bx,[cs:bx+102h];jmp bx;end;
PROCEDURE ExitBank;    assembler;asm mov bx,offset hereisVGAdriver-100h;add bx,[cs:bx+104h];jmp bx;end;
PROCEDURE  VisBank;far;assembler;asm mov ah,0;div viditelnychbanku;mov al,ah;
                                     mov bx,offset hereisVGAdriver-100h;add bx,[cs:bx+106h];jmp bx;end;
{$else}
PROCEDURE     Bank;    assembler;asm end;
PROCEDURE InitBank;    assembler;asm end;
PROCEDURE ExitBank;    assembler;asm end;
PROCEDURE  VisBank;far;assembler;asm end;
{$endif}


{€€€€€€€€€€€€€€€€ V E S A €€€€€€€€€€€€€€€€}

PROCEDURE VesaBankPtr;assembler;
 asm dw 0,0;end;

PROCEDURE VesaGranularity;assembler;
 asm dw 0;end;

PROCEDURE VesaNowBank;assembler;
 asm dw 0;end;

PROCEDURE VesaBanku;assembler;
 asm db 0;{0=none nebo dosud nedetekovano;other=size64K}end;

PROCEDURE VesaBank;assembler;
 asm xor ah,ah
     cmp ax,word ptr VesaNowBank;jz @bankend
     cmp byte ptr VesaBanku,2;jc @bankend
     mov word ptr VesaNowBank,ax
     push ax
     push bx
     push dx
     mov ah,0
     div byte ptr VesaBanku

     mov al,0{ah=zarovnanej 64k bank}
     {granul=64 .. ax=ax>8
      granul=4  .. ax=ax>4
      granul=?  .. ax=ax/granul>2}
     shr ax,2{*pri 4kb granul snese pouze banky 0..15}
     div byte ptr [cs:offset VesaGranularity]

     xor bx,bx
     xor dh,dh
     mov dl,al

{varianta fast,unsafe
     db 2eh,0ffh,1eh;dw offset vesabankptr{call far ptr [cs:offset bankptr]}
{varianta slow,safe}
     mov ax,4f05h
     int 10h{nabankuje window A}
     mov ax,4f05h
     inc bx
     int 10h{totez jeste jednou pro window B}

     pop dx
     pop bx
     pop ax
     @bankend:
     end;

PROCEDURE IncVesaBank;assembler;
 asm
      push ax
      mov ax,word ptr VesaNowBank
      inc ax
      call VesaBank
      pop ax
      end;

PROCEDURE VesaSetVis(visy:word);assembler;
 asm mov ax,4f07h;xor bx,bx;mov cx,(640+512)/2{wrisir};mov dx,visy;int 10h
     end;

PROCEDURE VesaInit;assembler;
 asm
	;{------------alloc 256B buffer----------}
	mov	ah,48h
	mov	bx,64{buffer 256B, pro jistotu 1024}
	int	21h
	jc	@nomem
	mov	es,ax
     {vesa here ? ... get info to buffer es:di}
     mov ax,4f00h;xor di,di;int 10h
     cmp ax,4fh;jnz @novesa
     {header ok ?}
     cmp word ptr [es:00],'EV';jnz @novesa
     cmp word ptr [es:02],'AS';jnz @novesa
     {version >= 1.2 ?}
     cmp word ptr [es:04],0102h;jl @novesa
     {read VESAviditelnychBanku}
     cmp byte ptr VesaBanku,0;jnz @forcedMemsize
     mov ax,[es:18];mov byte ptr VesaBanku,al
     @forcedMemsize:
     {end}
     jmp @end
     @novesa:
     mov byte ptr VesaBanku,0
     @end:
	;{-------------dealloc buffer--------------}
	mov	ah,49h
	int	21h
	@nomem:
     end;

FUNCTION VesaInit512x464:Boolean;
begin
 asm
     mov @result,0
	;{------------alloc 256B buffer----------}
	mov	ah,48h
	mov	bx,64{buffer 256B, pro jistotu 1024}
	int	21h
	jc	@nomem
	mov	es,ax
     {reset nowbank}
     mov word ptr [cs:offset VesaNowBank],0
     {set 640x480}
     mov ax,4f02h;mov bx,101h;int 10h;cmp ax,4fh;jnz @bad
     mov VGA_MODE,2{svga512}
     {get info about mode100 to es:di buffer}
     mov ax,4f01h;mov cx,101h;xor di,di;int 10h;cmp ax,4fh;jnz @bad
     {check granularity}
     mov ax,[es: 4];mov [cs:  offset VesaGranularity],ax
     {read ptr to setbank}
     mov ax,[es:12];mov [cs:  offset vesabankptr],ax
     mov ax,[es:14];mov [cs:2+offset vesabankptr],ax
     {set wrisir=512}
     mov ax,4f06h;mov bl,0;mov cx,512;int 10h;cmp ax,4fh;jnz @bad
     {do crazy thingy vith crtc regs}
     call enableCrtc
       {shorten displayed width: -16 clocks}
       mov dx,3d4h;mov al,1;out dx,al;inc dx;in al,dx;sub al,16;out dx,al
       {start retrace several clocks before}
       mov dx,3d4h;mov al,4;out dx,al;inc dx;in al,dx;sub al,10;out dx,al
       {start blanking several clocks before}
       mov dx,3d4h;mov al,2;out dx,al;inc dx;in al,dx;sub al,10;out dx,al
       {small display shift right
       mov dx,3d4h;mov al,5;out dx,al;inc dx;in al,dx;and al,128;out dx,al
       {small display shift right}
       mov dx,3d4h;mov al,3;out dx,al;inc dx;in al,dx;or al,64;out dx,al
       {shorten displayed height: -16 lines}
       mov dx,3d4h;mov al,12h;out dx,al;inc dx;in al,dx;sub al,16;out dx,al
     call protectCrtc
     {end}
     mov @result,1
     @bad:
	;{-------------dealloc buffer--------------}
	@novesa:
	mov	ah,49h
	int	21h
	@nomem:
     end;
end;

FUNCTION VesaInit640x480:Boolean;
begin
 asm
     mov @result,0
	;{------------alloc 256B buffer----------}
	mov	ah,48h
	mov	bx,64{buffer 256B, pro jistotu 1024}
	int	21h
	jc	@nomem
	mov	es,ax
     {reset nowbank}
     mov word ptr [cs:offset VesaNowBank],0
     {set 640x480}
     mov ax,4f02h;mov bx,101h;int 10h;cmp ax,4fh;jnz @bad
     mov VGA_MODE,3{svga640}
     {get info about mode100 to es:di buffer}
     mov ax,4f01h;mov cx,101h;xor di,di;int 10h;cmp ax,4fh;jnz @bad
     {check granularity}
     mov ax,[es: 4];mov [cs:  offset VesaGranularity],ax
     {read ptr to setbank}
     mov ax,[es:12];mov [cs:  offset vesabankptr],ax
     mov ax,[es:14];mov [cs:2+offset vesabankptr],ax
     {end}
     mov @result,1
     @bad:
	;{-------------dealloc buffer--------------}
	@novesa:
	mov	ah,49h
	int	21h
	@nomem:
     end;
end;


{€€€€€€€€€€€€€€€€ GRAPHIX €€€€€€€€€€€€€€€€}
PROCEDURE ReadPal;assembler;
 asm mov ax,ds;mov es,ax;lea di,pal
     mov dx,3c7h;mov al,0;out dx,al;add dx,2;mov cx,768;@1:in al,dx;stosb;loop @1;end;

FUNCTION PalIsBlack:boolean;
begin
 asm mov dx,3c7h;mov al,0;out dx,al;add dx,2;mov cx,256
     @1:
     in al,dx;or al,[offset darkcolor  ];jnz @color;
     in al,dx;or al,[offset darkcolor+1];jnz @color;
     in al,dx;or al,[offset darkcolor+2];jnz @color;
     loop @1
     @black:mov @result,1;jmp @end
     @color:mov @result,0
     @end:
     end;
end;

PROCEDURE SetColor(color,r,g,b:byte);assembler;
 asm mov dx,3c8h;mov al,color;out dx,al;inc dx;mov al,r;out dx,al;mov al,g;out dx,al;mov al,b;out dx,al;end;

(*
PROCEDURE SetBright(n:byte);assembler;
 asm mov si,offset pal;mov dx,3c8h;mov al,0;out dx,al;inc dx;mov cx,300h;mov bl,n;mov nowbright,bl
     @1:lodsb;mul bl;{test ah,0c0h;jz @nottoobright;mov ah,63;@nottoobright:}mov al,ah;out dx,al;loop @1;end;
*)

PROCEDURE SetBright(n:byte);assembler;
 asm mov cx,100h;mov bl,n;mov nowbright,bl;push ds;pop es;mov bh,255;sub bh,bl
     lea si,darkcolor
     lodsb;mul bh;mov dl,ah{r}
     lodsb;mul bh;mov dh,ah{g}
     lodsb;mul bh;mov bh,ah{b}
     {multiplikace smerem k darkcolor}
     mov si,offset pal;mov di,768+offset pal;
     @1:
     lodsb;mul bl;mov al,ah;add al,dl;stosb;{r}
     lodsb;mul bl;mov al,ah;add al,dh;stosb;{g}
     lodsb;mul bl;mov al,ah;add al,bh;stosb;{b}
     loop @1;
     {kdyztak zacerni barvu 41}
     cmp black41,0;jz @noblack;
     mov word ptr [offset pal+768+41*3],0;mov byte ptr [offset pal+768+41*3+2],0;
     @noblack:
     {outne to}
     mov dx,3c8h;mov ah,0;mov al,color1forsetbright;out dx,al;inc dx;
     mov cx,300h;sub cx,ax;sub cx,ax;sub cx,ax;
     mov si,768+offset pal;add si,ax;add si,ax;add si,ax;
     @2:lodsb;out dx,al;loop @2{rep outsb}
     end;

PROCEDURE BrightUp(time:byte);
var i:byte;
begin
 for i:=1 to time do begin refresh(1);setbright(255*i div time);end;
{ for i:=1 to time do begin refresh(1);setbright(round(255*sqrt(i/time)));end;}
end;

PROCEDURE BrightDown(time:byte);
var i:byte;
begin
 if not PalIsBlack then{}
  for i:=time-1 downto 0 do begin refresh(1);setbright(255*i div time);end;
{  for i:=time-1 downto 0 do begin refresh(1);setbright(round(255*sqrt(i/time)));end;}
end;

PROCEDURE PrepareBrightDown(colorful:boolean);
var i,j:byte;
    rgb:word;
begin
 for j:=0 to 2 do begin
   rgb:=0;
   if colorful then for i:=31 to 40 do inc(rgb,pal[3*i+j]);
   darkcolor[j]:=rgb div 10;
   end;
end;

PROCEDURE ShowPal(from,len:byte);assembler;
 asm mov al,3;mul from;mov si,ax;add si,offset pal;mov dx,3c8h;mov al,from;out dx,al;inc dx
     mov al,3;mul len;mov cx,ax
     @1:lodsb;out dx,al;loop @1{rep outsb};end;

PROCEDURE SmoothSetVis(visx,visy:word);assembler;
 asm
     cmp VGA_MODE,2;jz @mode3_svga640

     @mode1_vga360:
     PUSHF
     CLI
    {bity 16-19}
     mov ax,visy
     shr ax,9
     call visbank
    {malej shift o 0-3 bity}
     mov dx,3dah;in al,dx;mov dx,3c0h;mov al,33h;out dx,al;
     {call wait250ns}
     mov ax,visx;and al,3;shl al,1;out dx,al
    {velkej shift}
     mov ax,visy;shl ax,7;mov bx,visx;shr bx,2;add bx,ax
     mov dx,3d4h;mov al,0ch;mov ah,bh;out dx,ax;inc al;mov ah,bl;out dx,ax
     POPF
     jmp @end

     @mode3_svga640:
     push visy
     call VESAsetvis

     @end:
    end;

PROCEDURE Wait250ns;assembler;asm
 push cx;mov cx,250*100;@1:loop @1;pop cx;
 end;

PROCEDURE EnableCrtc;assembler;asm
 mov	dx,3d4h		{ alter crtc registers  }
 mov	al,11h		{ cr11                  }
 out	dx,al		{ current value         }
 inc	dx		{ point to data         }
 in	al,dx		{ get cr11 value        }
 and	al,7fh		{ remove cr0 -> cr7     }
 out	dx,al		{    write protect      }
 end;

PROCEDURE ProtectCrtc;assembler;asm
 mov	dx,3d4h		{ alter crtc registers  }
 mov	al,11h		{ cr11                  }
 out	dx,al		{ current value         }
 inc	dx		{ point to data         }
 in	al,dx		{ get cr11 value        }
 or	al,80h		{ set cr0 -> cr7        }
 out	dx,al		{    write protect      }
 end;
{
3d4h index  0  (r/W):  CRTC: Horizontal Total Register
bit 0-7  (VGA) Horizontal Total Character Clocks-5

3d4h index  1  (r/W):  CRTC: Horizontal Display End Register
bit 0-7  Number of Character Clocks Displayed -1

3d4h index  2  (r/W):  CRTC: Start Horizontal Blanking Register
bit 0-7  The count at which Horizontal Blanking starts

3d4h index  3  (r/W):  CRTC: End Horizontal Blanking Register
bit 0-4  Horizontal Blanking ends when the last 5 (6 for VGA) bits of the
         character counter equals this field.
         (VGA) The sixth bit is found in port 3d4h index 5 bit 7.
    5-6  Number of character clocks to delay start of display after Horizontal
         Total has been reached.
      7  (VGA Only) Access to Vertical Retrace registers if set. If clear
         reads to 3d4h index 10h and 11h access the Lightpen read back
         registers ??

3d4h index  4  (r/W):  CRTC: Start Horizontal Retrace Register
bit 0-7  Horizontal Retrace starts when the Character Counter reaches this
         value.

3d4h index  5  (r/W):  CRTC: End Horizontal Retrace Register
bit 0-4  Horizontal Retrace ends when the last 5 bits of the character counter
         equals this value.
    5-6  Number of character clocks to delay start of display after Horizontal
         Retrace.
      7  (VGA) bit 5 of the End Horizontal Blanking count (See 3d4h index 3
         bit 0-4).
}

PROCEDURE Mode13x(crtc5:word);assembler;
 asm    jmp @start

@vptbl:	db	0,06bh	{ horz total                      }
	db	1,059h	{ horz displayed is 4*(n+1)       }
	db	2,05ah	{ start horz blanking             }
	db	3,08eh	{ end horz blanking               }
	db	4,05eh	{ start h sync                    }
	db	5,08ah	{ end h sync                      }
	dw	00d06h	{ vertical total                  }
	dw	03e07h	{ overflow                        }
	dw	04009h	{ cell height                     }
	dw	0ea10h	{ v sync start                    }
	dw	00c11h	{ v sync end and protect cr0-cr7  }{ac11 > 2c11 > 0c11}
	dw	0cf12h	{ vertical displayed              }
	dw	04013h	{ offset                          }
	dw	00014h	{ turn off dword mode             }
	dw	0e715h	{ v blank start                   }
	dw	00616h	{ v blank end                     }
	dw	0e317h	{ turn on byte mode               }

@start:
	push	ds

       {detekce meho pocitace}
        mov ax,crtc5;cmp ax,-1;jnz @nastavAL{nastavi crtc5}
        push 0;pop ds
        mov ax,31415;cmp [4feh],ax;jnz @nenimuj{necha default}
        mov al,0b0h;{nastavi moje}
        @nastavAL:
        mov [cs:offset @vptbl+11],al
        @nenimuj:

       {common stuff}
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

(*
        {spusti CHAIN4 ale ne X}
        MOV     DX,3D4h
        MOV     AX,14h                  { Disable dword mode}
        OUT     DX,AX
        MOV     AX,0E317h               { Enable byte mode.}
        OUT     DX,AX                   {}
*)
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

        mov     VGA_MODE,1

  end;

PROCEDURE ClearScreen13x;assembler;
 asm
	mov	ax,0f02h	{ set write plane mask to all bit planes }
        mov     dx,3c4h
	out	dx,ax
	xor	di,di
	mov	es,sega000
	mov	cx,32768
	xor	ax,ax
	rep	stosw
        end;

{€€€€€€€€€€€€€€€€ STRINGY €€€€€€€€€€€€€€€€}

FUNCTION  StringPtr(seg,ofs:word):string;
var   p:^string;
begin
 p:=ptr(seg,ofs);
 StringPtr:=p^;
end;

FUNCTION CutStringFromString(delic:char;var st:string):string;
var i,j:word;
begin
 i:=pos(delic,st);if i=0 then i:=length(st)+1;
 CutStringFromString:=copy(st,1,i-1);
 delete(st,1,i);
end;

PROCEDURE CutNumberFromString(delic:char;var st:string;var prom:word);
var code:word;
begin
 val(CutStringFromString(delic,st),prom,code);
 if code>0 then errorhalt(9);
end;

PROCEDURE ZalomPath(var st:stringpath);
begin
 if (length(st)>0) and (st[length(st)]<>':') and (st[length(st)]<>'\') then st:=st+'\';
end;



{---------------------------------------------------------------------------
 Odstrani ze stringu pripadne uvozovky na okrajich.
 ---------------------------------------------------------------------------}

PROCEDURE OdstranUvozovky(var st:string);
begin
 if st[1]='"' then delete(st,1,1);
 if st[length(st)]='"' then dec(st[0]);
end;

{---------------------------------------------------------------------------
 Otestuje zda string odpovida rozsirene hvezdickove konvenci a vraci vysledek.
 ---------------------------------------------------------------------------}

FUNCTION  OdpovidaKonvenci(st:string):boolean;
var   zavorek:integer;
      i:word;
label bad;
begin
 OdpovidaKonvenci:=false;
 zavorek:=0;
 for i:=1 to length(st) do case st[i] of '"':goto bad;
                                         '[':inc(zavorek);
                                         ']':if zavorek>0 then dec(zavorek) else goto bad;
                                     #0..#31:goto bad;
                                         '|':if zavorek=0 then goto bad;
                                         end;
 if zavorek<>0 then goto bad;
 OdpovidaKonvenci:=true;
 bad:
end;

{---------------------------------------------------------------------------
 Zjisti zda je prvni parametr (normalni nazev) zahrnut ve druhem parametru
 (hvezdickovou konvenci zapsany nazev) a vysledek vrati. Funkce predpoklada
 ze druhy parametr odpovida konvenci, nesnazi se detekovat nejake syntakticke
 chyby.
 ---------------------------------------------------------------------------}

FUNCTION XjeprvkemY(norm,hvezd:string):boolean;
var   i,j,k,l,m:byte;
label ok;
begin
 XjeprvkemY:=false;
 if norm=hvezd then goto OK;
 if norm='' then begin
   if hvezd[1]='*' then if XjeprvkemY('',copy(hvezd,2,255)) then goto OK;
   exit;
   end;

 for i:=1 to length(norm) do
   if i>length(hvezd) then exit
   {---------------- obstara syntaxi * ---------------}
   else
   if hvezd[i]='*' then
     begin
     for j:=i to length(norm)+1 do if XjeprvkemY(copy(norm,j,255),copy(hvezd,i+1,255)) then goto OK;
     end
   {---------------- obstara syntaxi [|] ---------------}
   else
   if hvezd[i]='[' then
     begin
     {i <- pozice zacatku vyrazu: '['}
     {k <- pozice konce vyrazu: ']'}
     l:=0;
     for k:=i+1 to length(hvezd) do case hvezd[k] of '[':inc(l);
                                                     ']':if l>0 then dec(l) else break;
                                                     end;
     {j <- pozice zacatku substringu: '[' nebo '|'}
     j:=i;
     repeat
       {m <- pozice konce substringu: '|' nebo ']'}
       l:=0;
       for m:=j+1 to k do case hvezd[m] of '[':inc(l);
                                           ']':if l>0 then dec(l) else break;
                                           '|':if l=0 then break;
                                           end;
       if XjeprvkemY(copy(norm,i,200),copy(hvezd,j+1,m-j-1)+copy(hvezd,k+1,255)) then goto OK;
       j:=m;
     until hvezd[m]=']';
     exit;
     end
   {---------------- obstara syntaxi ? ---------------}
   else
   if (hvezd[i]<>norm[i]) and (hvezd[i]<>'?') then exit;

 if not XjeprvkemY('',copy(hvezd,length(norm)+1,255)) then exit;
 ok:
 XjeprvkemY:=true;
end;


{€€€€€€€€€€€€€€€€ FILE €€€€€€€€€€€€€€€€}

PROCEDURE GetCurDir;
begin
 asm mov ah,19h;int 21h;add al,'A';mov [1+offset curdir],al
     mov ax,'\:';mov [2+offset curdir],ax
     mov ah,47h;mov dl,0;lea si,3+1+curdir;mov di,si;int 21h
     push ds;pop es
     lea di,1+curdir;mov al,0;mov cx,100;repne scasb;sub cx,99;neg cx
     lea di,curdir;mov [di],cl
     end;
 ZalomPath(CurDir);
end;

FUNCTION SetDrive(path:stringpath):boolean;
var   c:char;
label quit;
begin
 SetDrive:=false;
 if (length(path)>1) and (path[2]=':') then begin
  c:=path[1];
  case c of 'a'..'z':asm mov ah,0eh;mov dh,0;mov dl,c;sub dl,'a';int 21h;jc quit;end;
            'A'..'Z':asm mov ah,0eh;mov dh,0;mov dl,c;sub dl,'A';int 21h;jc quit;end;
            else goto quit;
            end;
  end;
 SetDrive:=true;
 quit:
end;

FUNCTION SetDriveAndZkratString(var path:stringpath):boolean;{umaze zacatek stringu}
var   c:char;
label quit;
begin
 SetDriveAndZkratString:=false;
 if (length(path)>1) and (path[2]=':') then begin
  c:=path[1];
  case c of 'a'..'z':asm mov ah,0eh;mov dh,0;mov dl,c;sub dl,'a';int 21h;jc quit;end;
            'A'..'Z':asm mov ah,0eh;mov dh,0;mov dl,c;sub dl,'A';int 21h;jc quit;end;
            else goto quit;
            end;
  delete(path,1,2);
  end;
 SetDriveAndZkratString:=true;
 quit:
end;

FUNCTION CD(dir:stringpath):boolean;
var   i:word;
label quit;
begin
 cd:=false;
 i:=ofs(dir[1]);
 ZalomPath(dir);
{ if not SetDriveAndZkratString(dir) then goto quit;}
 SetDriveAndZkratString(dir);
 if (dir[length(dir)]='\') and (dir[length(dir)-1]<>':') and (length(dir)>1)
   then dir[length(dir)]:=#0
   else dir:=dir+#0;
 asm mov ax,3b00h;mov dx,i;push ds;mov bx,ss;mov ds,bx;int 21h;pop ds;jc quit;end;
{ if (length(dir)>=2) and (dir[2]=':') then asm mov }
 cd:=true;
 quit:
end;

FUNCTION MakeAndEnterDir(path:stringpath):boolean;
var   asciiz:stringpath;
      i,aofs:word;
      ch:char;
label quit;
begin
 MakeAndEnterDir:=false;
 aofs:=ofs(asciiz[1]);
 ZalomPath(path);

 {set drive}
 if not SetDriveAndZkratString(path) then goto quit;

 {cd,md}
 while length(path)>=1 do begin
  i:=pos('\',path);
  if i=1 then asciiz:='\'+#0 else asciiz:=copy(path,1,i-1)+#0;
  asm{cd}    mov ah,3bh;mov dx,aofs;push ds;push ss;pop ds;int 21h;pop ds;jnc @9;
     {md}    mov ah,39h;mov dx,aofs;push ds;push ss;pop ds;int 21h;pop ds;jc quit
     {cd}    mov ah,3bh;mov dx,aofs;push ds;push ss;pop ds;int 21h;pop ds;jc quit
          @9:end;
  delete(path,1,i);
  end;

 MakeAndEnterDir:=true;
 quit:
end;

PROCEDURE ZavesFileHandler(handle:word;adr:longint);assembler;
 asm
     mov ax,word ptr adr  ;mov [cs:offset @exelenglo],ax
     mov ax,word ptr adr+2;mov [cs:offset @exelenghi],ax
     mov ax,handle;mov [cs:offset @myhand],ax
    {seek to adr}
     mov ax,4200h;mov bx,handle;mov cx,word ptr adr+2;mov dx,word ptr adr;int 21h
    {ulozeni puvodniho INT21}
     mov ax,3521h;int 21h;mov [cs:offset @oldINT21],bx;mov [cs:offset @oldINT21+2],es
    {nastaveni noveho handleru}
     push ds
     mov ax,2521h;mov dx,cs;mov ds,dx;mov dx,offset @filehandler;int 21h
     pop ds
     jmp @9

@oldINT21: dw 0,0
@myhand:   dw 0
@exelenghi:dw 0
@exelenglo:dw 0

@FILEHANDLER:
     cmp ah,3dh;jz @open
     cmp ah,3eh;jz @close
     cmp ax,4200h;jz @seekFromStart
     cmp ax,0ffffh;jz @uninstall

    @puvodni:
     segcs;db 0ffh,2eh;dw offset @oldINT21{jmp far ptr [cs:offset @oldINT21]}

    @open:
     mov ax,[cs:offset @myhand]
     clc
     iret

    @close:
     clc
     iret

    @seekFromStart:
     add dx,[cs:offset @exelenglo];adc cx,[cs:offset @exelenghi]
     segcs;db 0ffh,2eh;dw offset @oldINT21{jmp far ptr [cs:offset @oldINT21]}

    @uninstall:
     push ds
     pusha
     mov ax,2521h;mov ds,[cs:offset @oldINT21+2];mov dx,[cs:offset @oldINT21];int 21h
     popa
     pop ds
     iret

     @9:
     end;

PROCEDURE OdpojFileHandler;assembler;asm mov ax,$ffff;int 21h;end;

FUNCTION OpenDataFile(st:stringpath):boolean;
var ofsst:word;
begin
 OpenDataFile:=false;
 st:='raw\'+st+#0;
 ofsst:=ofs(st);
 asm
  {open st}
   mov ax,3d00h;mov dx,ofsst;add dx,5
   push ds;mov bx,ss;mov ds,bx;int 21h;pop ds;
   mov datahandle,ax;jnc @ok;
  {open x\st}
   mov di,ofsst;mov byte ptr [ss:di+3],'x'
   mov ax,3d00h;mov dx,ofsst;add dx,3
   push ds;mov bx,ss;mov ds,bx;int 21h;pop ds;
   mov datahandle,ax;jnc @ok
  {open wav\st}
   mov di,ofsst;mov byte ptr [ss:di+3],'v';mov word ptr [ss:di+1],'aw'
   mov ax,3d00h;mov dx,ofsst;add dx,1
   push ds;mov bx,ss;mov ds,bx;int 21h;pop ds;
   mov datahandle,ax;jc @bad
  {end}
   @ok:mov @result,1;@bad:
   end;
end;

FUNCTION LengthDataFile:longint;
var   siz:longint;
begin
 asm
    {to konec}
     mov ax,4202h;mov bx,datahandle;mov cx,0;mov dx,0;int 21h;
     mov word ptr siz  ,ax
     mov word ptr siz+2,dx
    {to zacatek}
     mov ax,4200h;mov bx,datahandle;mov cx,0;mov dx,0;int 21h;
     end;
 LengthDataFile:=siz;
end;

FUNCTION ReadDataFile(len,kamofs,kamseg:word):word;
begin
 asm
{   mov cx,word ptr pal-2
   mov bx,word ptr pal+2*768;push bx
   mov ax,word ptr pal
   push cx
   push bx
   push ax}

   mov bx,datahandle;mov cx,len;mov dx,kamofs;mov ah,3fh;
   push ds;mov ds,kamseg;int 21h;pop ds
   mov @result,ax
   jnc @ouk;push 20;mov datahandle,ax;call errorhalt;@ouk:

{   pop ax
   pop bx
   pop cx
   mov dx,0
   cmp ax,word ptr pal;jz @ok
   cmp bx,word ptr pal+2*768;jz @ok1;or dx,2;@ok1:
   cmp cx,word ptr pal-2;jz @ok2;or dx,1;@ok2:
   push dx;call errorhalt;
   @ok:}

   end;
end;

PROCEDURE SeekDataFileFromCur(okolik:longint);assembler;
 asm mov ax,4201h;mov bx,datahandle;mov cx,word ptr okolik+2;mov dx,word ptr okolik;int 21h;end;

PROCEDURE SeekDataFileFromStart(kam:longint);assembler;
 asm mov ax,4200h;mov bx,datahandle;mov cx,word ptr kam+2;mov dx,word ptr kam;int 21h;end;

FUNCTION CloseDataFile:boolean;
begin
 asm mov bx,datahandle;mov ah,3eh;int 21h;mov al,0;adc al,0;mov @result,al;end;
end;
                  {
FUNCTION File0Exists(name:stringpath;attrib:byte):boolean;
var o:word;
begin
 o:=ofs(name);
 asm
   push ds;mov ax,cc;mov ds,ss
   mov ah,3dh;int 21h;pop ds;mov @result,ax
   pop ds
   end;
end;
                   }

FUNCTION  SetAttr(st:stringpath;attr:word):boolean;
var   i:word;
begin
 st[length(st)+1]:=#0;
 i:=ofs(st)+1;
 asm mov ax,4301h;mov cx,attr;mov dx,i;push ds;push ss;pop ds;int 21h;pop ds;
     mov al,255;adc al,0;mov @result,al
     end;
end;

FUNCTION DeleteFile(st:stringpath):word;
var ofss,segs:word;
begin
 setattr(st,0);{odstrani readonly flag}
 st[length(st)+1]:=#0;
 ofss:=ofs(st)+1;
 segs:=seg(st);
 asm push ds;mov ds,segs;mov dx,ofss;mov ah,41h;
     int 21h;pop ds;mov @result,ax
     end;
end;

FUNCTION  RenameFile(old,new:stringpath;hazeterror:boolean):word;
var   o,n:word;
label exit;
begin
 o:=ofs(old)+1;old[length(old)+1]:=#0;
 n:=ofs(new)+1;new[length(new)+1]:=#0;
 SetAttr(old,0);
 asm mov ah,56h;
     push ds;mov bx,ss;mov es,bx;mov ds,bx
     mov dx,o;mov di,n
     int 21h;jc @error;mov ax,0;@error:mov @result,ax
     pop ds
     or ax,ax;jz exit;
     end;
 if hazeterror then errormsg('Nelze prejmenovat '+old+' na '+new+'.');
 exit:
end;

FUNCTION CallCommand(st:stringpath):boolean;
begin
 swapvectors;
 exec(getenv('comspec'),st);
 CallCommand:=(doserror=0);
 swapvectors;
end;

PROCEDURE CopyFile(src,dest:stringpath);
begin
 CallCommand('/c copy '+src+' '+dest);
end;

FUNCTION InteligentneHledejSoubor(vychoziDir,hledanySoubor,musiobsahovat:stringpath;var nalezeno:stringpath):boolean;
var   skupina_adresaru:byte;
      direc,filec:searchrec;
      work,path:stringpath;
      f:file;
begin
 {hleda self\..\dir\file pokud neni v rootu}
 if vychozidir<>'' then begin
   path:=vychozidir+'\..\';
   findfirst(path+'*.*',directory,direc);
   while doserror=0 do begin
     if pos(musiobsahovat,direc.name)>0 then begin
       work:=path+direc.name+'\'+hledanysoubor;
       findfirst(work,anyfile-directory,filec);
       if doserror=0 then begin
         nalezeno:=work;
         InteligentneHledejSoubor:=true;
         exit;
         end;
       end;
     findnext(direc);
     end;
   end;
 nalezeno:='';
 InteligentneHledejSoubor:=false;
end;
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
end;
  *)


{€€€€€€€€€€€€€€€€ TEXT €€€€€€€€€€€€€€€€}

PROCEDURE SetTextAttr(c:byte);assembler;
 asm mov ax,921h;mov bh,0;mov bl,c;mov cx,1;int 10h;end;


PROCEDURE SetTextMode;
begin
 if biosmode=$13 then ClearScreen13x;
 if biosmode<>3 then begin
   asm mov ax,3;int 10h;end;
   refresh(3);
   end
 else begin
   if (rawGetXy div 256)>biostxvys then rawGotoXy(1,1) else writeln;
   asm mov ah,9;mov al,'>';mov bh,0;mov bl,7;mov cx,1;int 10h;end;
   end;
end;


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

PROCEDURE SetSmoothY(y:byte);assembler;
 asm {vertical panning}
     mov dx,3d4h;mov al,8;mov ah,y;out dx,ax;mov smoothYonScreen,ah
     end;

PROCEDURE SetVis(vis:word);assembler;
 asm mov bx,vis;mov nowvis,bx;mov dx,3d4h
     mov al,0ch;mov ah,bh;out dx,ax
     mov al,0dh;mov ah,bl;out dx,ax
     end;

PROCEDURE SplitSetVis(y:word);assembler;
 asm mov ax,wrisir/4;mul y;push ax;call setvis
     mov ax,y;mov dx,0;mov bx,wrivys;div bx
     mov bx,wrivys;sub bx,dx;dec bx
     cmp bx,visvys-1;jc @ok;mov bx,visvys-1;@ok:
     push bx;call splitY{}
     end;

PROCEDURE RawGotoXY(x,y:byte);assembler;
 asm mov dl,x;mov dh,y;dec dl;dec dh;
     mov ah,2;mov bh,0;int 10h
     end;

FUNCTION RawGetXY:word;
begin
 asm mov ah,3;mov bh,0;int 10h;mov @result,dx;end;
end;

PROCEDURE GotoXY(x:word;y:byte);assembler;
 asm mov ax,nowvis;{sub ax,shiftsetvis;}add ax,x;mov bl,txsir;div bl;
     mov dl,ah;mov dh,y;add dh,al;dec dl;dec dh;
     mov ah,2;mov bh,0;int 10h
     end;

PROCEDURE SetYinWorkseg(y:word);assembler;
 asm mov ax,y;mov YinWorkseg,ax
     xor ax,ax;mov es,ax
     mov ax,2*txsir;mul YinWorkseg;mov si,ax;mov di,txsir*skiplines*2
     mov al,txsir/2;mul byte ptr [es:biostxvys]{txvys+1};mov cx,ax
     mov es,segb800
{}   add si,2*shiftsetvis
     push ds;mov ds,workseg;db 66h;rep movsw;pop ds
     end;

PROCEDURE GotoXYaVis(x,y:word;forceCopy:byte);assembler;

{jen hejbu kurzorem:
  otestovat posun YinWorkseg
   ano: zmenit YinWorkseg a copy
  gotoxy (x,y-YinWorkseg)

 edituju:
  refreshtxtscreen (to si udela caller)
  otestovat posun YinWorkseg
   ano: zmenit YinWorkseg
  copy
  gotoxy (x,y-YinWorkseg)
  }

 asm xor ax,ax;mov es,ax
     mov ax,y;mov bx,YinWorkseg
     dec ax;dec ax;cmp ax,bx;jc @zmensiY
     inc ax;inc ax;sub al,[es:biostxvys];sbb ah,0;jc @topofpage;cmp ax,bx;jnc @zvetsiY
     @topofpage:
     cmp forcecopy,0;jz @gotoxy

    @bezezmen:
     mov ax,YinWorkseg
     jmp @copy
    @zvetsiY:
     inc ax
    @zmensiY:
     {push ax}
    @copy:
     push ax
     mov bh,0;mov bl,byte ptr [es:biostxvys]
     mul bx
     mov scroll2Y,ax
     call SetYinWorkseg{}

    @gotoxy:
     mov dl,byte ptr x;sub dl,shiftsetvis;mov dh,byte ptr y;add dh,skiplines;sub dh,byte ptr YinWorkseg;dec dl;dec dh;
     mov ah,2;mov bh,0;int 10h

     end;
(*
PROCEDURE WriXY(x,y:word;st:string);assembler;
 asm mov ax,txsir;mul y;add ax,x;sub ax,txsir+1;add ax,nowvis;shl ax,1;mov di,ax;mov es,segb800
     mov ah,textattr
     PUSH ds;
     lds si,[ss:bp+offset st+4]
     lodsb;or al,al;jz @nope;mov ch,0;mov cl,al
     @loop:lodsb;stosw;loop @loop
     @nope:
     POP ds;
     end;*)
PROCEDURE WriXY(x,y:word;st:string);
var   i:word;
begin
 i:=ofs(st);
 asm mov ax,txsir;mul y;add ax,x;sub ax,txsir+1;add ax,nowvis;shl ax,1;mov di,ax;mov es,segb800
     mov ah,textattr
     PUSH ds;
     mov bx,ss;mov ds,bx;mov si,i
     lodsb;or al,al;jz @nope;mov ch,0;mov cl,al
     @loop:lodsb;stosw;loop @loop
     @nope:
     POP ds;
     end;
end;

PROCEDURE UpCaseString(p:uknastring);
var i:byte;
begin
 for i:=1 to length(p^) do case p^[i] of 'a'..'z':dec(p^[i],32);end;
end;

FUNCTION LoCaseString(st:string):string;
var i:byte;
begin
 for i:=1 to length(st) do case st[i] of 'A'..'Z':inc(st[i],32);end;
 LoCaseString:=st;
end;

PROCEDURE End28Msg(st:string);
type  Tend28=record c1,c2,c3:word;bo,sp:byte;end;
const endu28=3;
      end28:array[1..endu28] of Tend28=(
        (c1:(16*0+11)*256+ord('€');c2:(16*4+15)*256+ord(' ');c3:(16*4+11)*256+ord('ƒ');bo:0;sp:0),
        (c1:(16*2+10)*256+ord('€');c2:(16*2+14)*256+ord(' ');c3:(16*2+ 0)*256+ord('Õ');bo:0;sp:1),
        (c1:(16*2+10)*256+ord('ﬂ');c2:(16*2+14)*256+ord(' ');c3:(16*2+10)*256+ord('ƒ');bo:2;sp:0));
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

PROCEDURE Mesidz(st:string;dy:shortint);
var   a:array[1..4] of string[80];
      i,j,x1,y1,le,polozek:byte;
begin
 polozek:=0;
 le:=0;
 fillchar(a,sizeof(a),32);
 while st>'' do begin
  inc(polozek);
  a[polozek]:=cutStringFromString(#13,st);
  if length(a[polozek])>le then le:=length(a[polozek]);
  end;
 for i:=1 to polozek do a[i,0]:=chr(le);
 x1:=(txsir-le) div 2;
 y1:=(biostxvys-polozek) shr 1+dy;
{ store(x1,y1,le+4,polozek+2);}
 textattr:=1;
 for i:=0 to le+3 do begin wrixy(x1+i,y1,'‹');wrixy(x1+i,y1+polozek+1,'ﬂ');end;
 for i:=1 to polozek do begin wrixy(x1,y1+i,'€');wrixy(x1+le+3,y1+i,'€');end;
 textattr:=3*16+11;
 for j:=1 to polozek do begin
   {for i:=1 to le do wrixy(x1+i,y1+j,a[i]);}
   wrixy(x1+1,y1+j,' '+a[j]+' ');
   end;

end;

FUNCTION AskExit:char;
const le=51;
      line:array[0..4] of string[le]=(
        '                                                   ',
        '   …ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ Edit ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕª   ',
        '   ∫  You''ve made changes since the last save. ∫   ',
        '   ∫    Save   Don''t save   Continue editing   ∫   ',
        '   »ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº   ');
      x:array[0..2] of byte=(8,15,28);
      l:array[0..2] of byte=(6,12,18);
var   ch:char;
      x1,y1,a:byte;
      i:word;
begin
 a:=0;
 x1:=(txsir-le) div 2+2;
 y1:=(biostxvys-5) shr 1;
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

FUNCTION  Ask({KurzorNaStart=4,EscVraciNic=2,inserty=1}flags:byte;veta:string;maxlen:byte;preselect:string;first:char):string;
var   i,j,x1,x2,le,le1,le2:word;
      path,veta2:string;
      ch:char;
label redraw;
begin
 path:=preselect;
 i:=pos(#13,veta);
 if i>0 then begin veta2:=copy(veta,i+1,255);veta[0]:=chr(i-1);end else veta2[0]:=#0;

 {sirka ramecku}
 le:=maxlen;
 le1:=length(veta);
 le2:=length(veta2);
 if le1>le then le:=le1;
 if le2>le then le:=le2;

 x1:=(txsir-le) div 2+1;
 x2:=(txsir-maxlen) div 2+1;
 store(x1,13,le,3);
 i:=length(path)+(flags and 1);if flags and 4>0 then i:=1;

 redraw:
 textattr:=16+11;
 for j:=1 to le do wrixy(x1+j-1,13,' ');wrixy(x1+(le-length(veta )) div 2,13,veta );
 for j:=1 to le do wrixy(x1+j-1,14,' ');wrixy(x1+(le-length(veta2)) div 2,14,veta2);
 for j:=1 to le do wrixy(x1+j-1,15,' ');
 while keypressed do readkey;

repeat
 wrixy(x2,15,path+' ');
 gotoxy(x2-1+i,15);
 ch:=readkey;
 case ch of
   ' '..'©':if (ch>=first) then
             if (flags and 1)=0 then begin path[i]:=ch;if i<length(path) then inc(i);end
                                else if (length(path)<maxlen) then
                                 begin path:=copy(path,1,i-1)+ch+copy(path,i,length(path));inc(i);end;
   #27:begin if (flags and 2)=0 then path:=preselect else path:='';ch:=#13;end;
   #8:if ((flags and 1)=1) and (i>1) then begin path:=copy(path,1,i-2)+copy(path,i,length(path));dec(i);end;
   #0:case readkey of
       'K':if i>1 then dec(i);
       'M':if i<length(path)+(flags and 1) then inc(i);
       'S':if ((flags and 1)=1) and (i<=length(path)) then path:=copy(path,1,i-1)+copy(path,i+1,length(path));
       'G':i:=1;
       'O':i:=length(path)+(flags and 1);
       #59:if LocalHelp<>nil then begin
             asm call [LocalHelp];end;
             goto redraw;
             end;
       end;
   end;
until ch=#13;

 textattr:=7;
 restore;
 ask:=path;
end;

FUNCTION MenuSelect(polozek:byte;p:pointer;addy,preselect:word):byte;
var   a,i,j,x1,y1,le:word;
      ch:char;
const hic=3*16+15;
      loc=3*16+8;

procedure wriline(n,c:byte);
var s:^string;
    i:byte;
begin
 s:=p;
 for i:=1 to n do inc(word(s),addy);
 textattr:=c;
 wrixy(x1+1,y1+1+n,' '+s^+' ');
end;

label quit;
begin
 a:=preselect;if a>0 then dec(a);
 le:=byte(p^);
 x1:=(txsir-le) div 2;
 y1:=(biostxvys-polozek) shr 1;
 store(x1,y1,le+4,polozek+2);
 textattr:=1;
 for i:=0 to le+3 do begin wrixy(x1+i,y1,'‹');wrixy(x1+i,y1+polozek+1,'ﬂ');end;
 for i:=1 to polozek do begin wrixy(x1,y1+i,'€');wrixy(x1+le+3,y1+i,'€');end;
 for i:=0 to polozek-1 do wriline(i,loc);
 gotoxy(0,62);
 repeat{28048}
   wriline(a,hic);
   ch:=readkey;
   wriline(a,loc);
   case ch of #27:begin MenuSelect:=0;goto quit;end;
              #72:a:=(a+polozek-1) mod polozek;
              #80:a:=(a+1) mod polozek;
              #13:begin MenuSelect:=a+1;goto quit;end;
              end;
 until false;
 quit:
 restore;
end;

FUNCTION FileSelect(flags:byte;veta,typ,preselect:string):string;
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

label 2,3,restart;
Begin
 st:='';
 keyb:=false;
 restart:
 i:=0;
 if typ='*.mod' then begin
   findall('*.mod');
   findall('*.s3m');
   findall('*.mtm');
   end
{ else
 if typ='*.raw' then begin
   findall('raw\*.wav');
   findall('raw\*.raw');
   end}
 else
   findall(typ);

 fajlu:=i-1;
 if fajlu=-1 then begin fileselect:=ask(flags or 1{inserty},veta,20,preselect,'!');exit;end;

 {sort}
 repeat
  j:=0;
  for i:=0 to fajlu-1 do if str[i]>str[i+1] then begin inc(j);st2:=str[i];str[i]:=str[i+1];str[i+1]:=st2;end;
 until j=0;

 for i:=fajlu downto 0 do if preselect>=str[i] then break;
 x1:=36-fajlu div 20*13 div 2;
 textattr:=7;
 {clrscr;}asm mov es,segb800;mov di,nowvis;add di,di;mov ax,7*256+32;mov cx,60*txsir;rep stosw;end;
{ setvis(0);}
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
{alt-d}            #32:if length(ask(2{escvracinic}+1{inserty},#13' M†m smazat soubor '+str[i]+' (ENTER=ano, ESC=ne) ? ',
                          1,' ','˛'))>0 then begin DeleteFile(str[i]);keyb:=true;preselect:=st;goto restart;end;
                   end;
              '!'..'@','_'..'z'
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
{ setvis(lasttextvis);}
End;

var
kurzor:word;
radek:byte;

PROCEDURE Help(helpfajl:string);
var   f:text;
      st:string;
      ch:char;
      i,j,k,l:word;
      textbarva:byte;
      nowhelpvis:word;
      slot:byte;
const slotu=2;
      memory:array[1..slotu,1..2] of word=((0,0),(0,0));
label 1;

begin
assign(f,helpfajl);reset(f);
if ioresult>0 then ask(1{inserty},#13' Chyb° helpfajl... Cos s nim proved ? ',0,'',' ') else
begin
asm{clrscr}mov di,0;mov es,segb800;db 66h;mov ax,7*256+32;dw 7*256+32;mov cx,16384/2;db 66h;rep stosw
   {move kurzor}mov ah,2;mov bh,0;mov dx,0ff01h;int 10h
   end;
setvis(txsir*(200-biostxvys));
kurzor:=0;radek:=0;
i:=ofs(st);
while not eof(f) do begin
  inc(radek);
  readln(f,st);
  if st=#27 then break;{nasimulovanej konec fajlu}
  if st[1]='.' then begin textbarva:=10;st[1]:=' ';end else
  if radek>5 then textbarva:=7 else textbarva:=14;
  asm mov ax,0b800h;mov es,ax;mov si,i;mov di,kurzor;mov cl,[ss:si];cmp cl,0;jz @9;mov ch,0;inc si;mov ah,textbarva
      @nextchar:segss lodsb;cmp al,':';jnz @not;mov ah,7;@not:stosw;loop @nextchar;
      @9:add kurzor,2*txsir;
      end;
  end;
close(f);

{pamatuje si radku}
nowhelpvis:=0;
for slot:=1 to slotu do if memory[slot,1]=radek then begin nowhelpvis:=memory[slot,2];goto 1;end;
for slot:=1 to slotu do if memory[slot,1]=0 then begin memory[slot,1]:=radek;goto 1;end;
1:

asm
 cmp MousePresent,0;jz @9
 {set mouse range}mov ax,8;mov cx,0;mov dh,0;mov dl,radek;dec dl;shl dx,3;int 33h;
 {mouseon}mov ax,1;int 33h
 {mov movemouse}mov ax,4;mov cx,320;mov dx,nowhelpvis;add dx,12;shl dx,3;int 33h;
 @9:
 end;
ch:=' ';
repeat
 GetMouseOrZero(i,j,k);
 if j shr 3<nowhelpvis then dec(nowhelpvis);
 if j shr 3>nowhelpvis+biostxvys then inc(nowhelpvis);
 if keypressed then begin
   l:=nowhelpvis;
   ch:=readkey;
   case ch of 'H':if nowhelpvis>0 then dec(nowhelpvis);
              'P':if nowhelpvis+biostxvys+1<radek then inc(nowhelpvis);
              'I':if nowhelpvis>biostxvys then dec(nowhelpvis,biostxvys) else nowhelpvis:=0;
              'Q':if nowhelpvis+biostxvys+biostxvys+1<radek then inc(nowhelpvis,biostxvys) else nowhelpvis:=radek-biostxvys-1;
              'G':nowhelpvis:=0;
              'O':nowhelpvis:=radek-biostxvys-1;
              end;
   MoveMouseXpul(2*i,j+8*(nowhelpvis-l));
   end;
 setvis(txsir*nowhelpvis);
until (k>0) or (ch=#27);
MouseOff;
memory[slot,2]:=nowhelpvis;
end;
end;

{€€€€€€€€€€€€€€€€ INI €€€€€€€€€€€€€€€€}

var   typprom:byte;
      adrprom:word;
      vars_ofs,vars_seg:word;
      vars_ptr:pointer absolute vars_ofs;

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
         seges lodsb{nacte flags}
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

const msg_diskfull='Mozna je plny disk, nelze zapisovat.';

{var=    ..neudela nic, ponecha puvodni udaje (u booleanu 255)
 var=ano ..nastavi 1
 var=ne  ..nastavi 0}
FUNCTION ReadIni(INIname:stringpath;vars:pointer):Boolean;
var   f:text;
      uknastring:^string;
      st,name,udaj:string;
      someword,i,code:word;
      udajuvIni,somebyte,j:byte;

Begin
 if debuginfo then writeln('Hledam ',INIname);
 vars_ptr:=vars;
 assign(f,INIname);
 reset(f);
 if ioresult>0 then ReadIni:=false else begin
  ReadIni:=true;
  udajuvIni:=0;
  while not eof(f) do begin
   readln(f,st);
   if (st[0]>#0) and (st[1]<>';') then begin
     i:=pos('=',st);
     name:=locasestring(copy(st,1,i-1));
     udaj:=locasestring(copy(st,i+1,200));
     if FindVariable(name) then case typprom and 7 of
                   0,1:if udaj<>'' then begin
                         if udaj='ne' then somebyte:=0 else
                         if udaj='ano' then somebyte:=1 else begin
                           val(udaj,somebyte,code);
                           if code>0 then errormsg('Chybny udaj v radce: '+st);
                          end;
                         byte(mem[dseg:adrprom]):=somebyte;
                         end;
                     2:if udaj<>'' then begin
                         val(udaj,someword,code);
                         if code>0 then errormsg('Chybne cislo v radce: '+st);
                         word(memw[dseg:adrprom]):=someword;
                         end;
                     4:if udaj<>'' then begin
                         someword:=0;
                         for i:=1 to length(udaj) do begin
                           j:=dehexy(udaj[i]);
                           if j>15 then errormsg('Chybne hexadecimalni cislo v radce: '+st);
                           someword:=someword shl 4+j;
                           end;
                         word(memw[dseg:adrprom]):=someword;
                         end;
                   3,5:if udaj<>'' then begin
                         uknastring:=ptr(dseg,adrprom);
                         if typprom and 7=3 then upcasestring(@udaj){stringy prevede na upcase}
                                            else udaj:=copy(st,i+1,200);{nacte puvodni zneni stringu}
                         uknastring^:=udaj;
                         end;
                     else errormsg('Interni chyba INI readeru.');
                     end{ else errormsg('Neznamy parametr v INI souboru: '+st){};
     end;
   end;
  close(f);
  end;
End;

PROCEDURE delFakenew_New2Fakenew_openFakenew_createNew(var f,g:text;INI:stringpath);
const bleble='old.ini';
var fakeINI:stringpath;
begin
 fakeINI:=copy(INI,1,pos('\',INI))+bleble;
 DeleteFile(fakeINI);
 RenameFile(INI,fakeINI,true);
 assign(f,fakeINI);
 reset(f);
 assign(g,INI);
 rewrite(g);
end;


PROCEDURE WriteIni(INIname:stringpath;vars:pointer;filtr:byte);
var   f,g:text;
      st,name,udaj:string;
      someword,i,code:word;
      somebyte:byte;
      uknastring:^string;
Begin
 vars_ptr:=vars;
 code:=0;
 delFakenew_New2Fakenew_openFakenew_createNew(f,g,INIname);
 while not eof(f) do begin
   readln(f,st);
   if (st[0]>#0) and (st[1]<>';') then begin
     i:=pos('=',st);
     if i=0 then errormsg('Chybna syntaxe v INI na radce: '+st);
     name:=copy(st,1,i-1);
     if FindVariable(locasestring(name)) and ((typprom and filtr)>0) then begin
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
                       someword:=word(memw[dseg:adrprom]);
                       if someword=65535 then udaj:='' else str(someword,udaj);
                       end;
                     4:begin
                       someword:=word(memw[dseg:adrprom]);
                       udaj:='';
                       if someword<>65535 then repeat
                                                 udaj:=hexy[someword mod 16]+udaj;
                                                 someword:=someword shr 4;
                                               until someword=0;
                       end;
                   3,5:begin
                       uknastring:=@mem[dseg:adrprom];
                       udaj:=uknastring^;
                       end;
                     end;
       st:=name+'='+udaj;
       end;
     end;
   writeln(g,st);
   if ioresult<>0 then errormsg(msg_diskfull);
   end;
 close(f);
 erase(f);
 close(g);
End;

PROCEDURE ModifyIniPodleIni(NewIni,OldIni:stringpath);
var   f,g:text;
      st,name:string;
      i,j:word;
      udaju:byte;
      a:array[1..maxudajuINI] of string[80];
Begin
 {precte vyznamny radky z puvodniho INI}
 assign(f,OldIni);
 reset(f);
 udaju:=0;
 while not eof(f) do begin
   readln(f,st);
   if (st[0]>#0) and (st[1]<>';') then begin
     name:=copy(st,1,pos('=',st)-1);
     typprom:=32;
     if (not FindVariable(locasestring(name))){updatuje nenalezeny veci}
     or ((typprom and 32)=0){updatuje nalezeny bez flagu 32} then begin
       if udaju>=maxudajuINI then errorhalt(50+13) else inc(udaju);
       a[udaju]:=st;
       end;
     end;
   end;
 close(f);

 {modifikuje novej INI podle staryho}
 delFakenew_New2Fakenew_openFakenew_createNew(f,g,newini);
 while not eof(f) do begin
   readln(f,st);
   if (st[0]>#0) and (st[1]<>';') then begin
     j:=pos('=',st);
     for i:=1 to udaju do if copy(st,1,j-1)=copy(a[i],1,j-1) then st:=a[i];
     end;
   writeln(g,st);
   if ioresult<>0 then errormsg(msg_diskfull);
   end;
 close(f);
 erase(f);
 close(g);
End;

END.