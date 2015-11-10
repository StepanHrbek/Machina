Unit ScrSaver;

Interface

Uses Memo, Objects, Sys,Key,Mys,Vga;

Type {abstraktni screensaver}
     PSV=^TSV;
     TSV=object(TObject)
       s           :PScreen;
       oldmouse    :boolean;
       constructor Init(as:PScreen);
       procedure   Sync;virtual;
       destructor  Done;virtual;
      end;


FUNCTION RandomSaver:PSV;
{
 Vraci nahodne vybrany screensaver. Pak uz staci jen volat jeho Sync.
 Az budes mit saveru dost, killni ho. Tim se obnovi puvodni stav obrazovky.
}


Implementation

Type {ma schovanou originalni paletu}
     TSVpal=object(TSV)
       oldpal      :TPal;
       counter     :longint;
       constructor Init(as:PScreen);
       procedure   Sync;virtual;
       destructor  Done;virtual;
      end;

     {ma schovanou originalni obrazovku}
     TSVpalbtm=object(TSVpal)
       oldbtm      :TBitmap;
       oldpen      :byte;
       constructor Init(as:PScreen);
       destructor  Done;virtual;
      end;

     {ma schovanou originalni obrazovku, alokuje bitmapku 2x2}
     TSVpalbtm2=object(TSVpalbtm)
       b           :TBitmap;
       constructor Init(as:PScreen);
       destructor  Done;virtual;
      end;

     {ma schovanou originalni obrazovku, alokuje bitmapku 2x2
      a 64K tabulku, kterou pripravi na smoothing}
     TSVpalbtm2tab=object(TSVpalbtm2)
       tab         :pointer;
       constructor Init(as:PScreen);
       function    AvgColInB:longint;
       procedure   SmoothS(x,y:integer);
       destructor  Done;virtual;
      end;



     {textmodovy screensaver}
     PSVtextmod=^TSVtextmod;
     TSVtextmod=object(TSVpalbtm)
       procedure   Sync;virtual;
      end;

     {fullscreen smoothing}
     PSVsmooth1=^TSVsmooth1;
     TSVsmooth1=object(TSVpalbtm2tab)
       procedure   Sync;virtual;
      end;

     {ship smoothing}
     PSVpixelize=^TSVpixelize;
     TSVpixelize=object(TSVpalbtm2)
       now,cil,speed:TPoint;
       procedure   Sync;virtual;
      end;

     {falling pixels}
     PSVfallpix=^TSVfallpix;
     TSVfallpix=object(TSVpalbtm2tab)
       procedure   Sync;virtual;
      end;


{-----------------------------------------------------
 Najde v palete nejblizsi barvu k er,ge,be 0..63.
 Vraci ctyrnasobek.
 -----------------------------------------------------}
FUNCTION Nejblizsi_barva_k(pal:PPalBody;er,ge,be:byte):word;assembler;
 {Brute Force ASM}
 asm
     {bx=mindelta,cx=loop,di=result}
     xor ax,ax
     xor dx,dx
     mov bx,65535
     mov cx,256
     PUSH DS
     lds si,pal
     @1:
     mov dl,ge;sub dl,[si+TColor.g];jnc @nepretekG;neg dl;@nepretekG:
     mov ax,dx;add ax,dx;add ax,dx{mulG=3};cmp ax,bx;jnc @next
     mov dl,er;sub dl,[si+TColor.r];jnc @nepretekR;neg dl;@nepretekR:
     add ax,dx;add ax,dx{mulR=2};cmp ax,bx;jnc @next
     mov dl,be;sub dl,[si+TColor.b];jnc @nepretekB;neg dl;@nepretekB:
     add ax,dx{mulB=1};cmp ax,bx;jnc @next
     mov bx,ax
     mov di,si
     @next:
     add si,sizeofTcolor
     loop @1
     POP DS
     sub di,pal.word[0]
     mov ax,di
 end;


Constructor TSV.Init(as:PScreen);
begin
 inherited Init;
 s:=as;
 oldmouse:=s^.MouseHide;
end;

Procedure TSV.Sync;
begin
end;

Destructor TSV.Done;
begin
 if oldmouse then s^.MouseShow;
 inherited Done;
end;


Constructor TSVpal.Init(as:PScreen);
begin
 inherited Init(as);
 oldpal.Init;
 oldpal.ReadFromTo(0,255);
end;

Procedure TSVpal.Sync;
const slow=40;
begin
 inc(counter);
 if (counter<slow*160) and (counter mod slow=0) then oldpal.SetBright(255-counter div slow);
end;

Destructor TSVpal.Done;
begin
 oldpal.Show;
 inherited Done;
end;


Constructor TSVpalbtm.Init(as:PScreen);
begin
 inherited Init(as);
 if not oldbtm.Init(s^.MapModel,s^.Xres,s^.Yres) then Fail;
 oldpen:=s^.pen;
 s^.pen:=PEN_SCREEN;
 s^.Box2BtF(@oldbtm,0,0);
 s^.pen:=oldpen;
end;

Destructor TSVpalbtm.Done;
begin
 oldpen:=s^.pen;
 s^.pen:=PEN_SCREEN;
 s^.BtF2Box(@oldbtm,0,0);
 s^.pen:=oldpen;
 oldbtm.Done;
 inherited Done;
end;


Constructor TSVpalbtm2.Init(as:PScreen);
begin
 if not inherited Init(as) then Fail;
 if not b.Init(s^.MapModel,2,2) then begin inherited Done;Fail;end;
end;

Destructor TSVpalbtm2.Done;
begin
 b.Done;
 inherited Done;
end;


Constructor TSVpalbtm2tab.Init(as:PScreen);
var w:word;
begin
 if not inherited Init(as) then Fail;
 if s^.MapModel in models_8 then
  if not GetMem(tab,65536) then begin inherited Done;Fail;end;
 if s^.MapModel in models_8 then
  for w:=0 to 65535 do mem[PtrRec(tab).Seg:w]:=Nejblizsi_barva_k(
   @oldpal.pal,
   (oldpal.pal[HiByte(w)].r+oldpal.pal[LoByte(w)].r) div 2,
   (oldpal.pal[HiByte(w)].g+oldpal.pal[LoByte(w)].g) div 2,
   (oldpal.pal[HiByte(w)].b+oldpal.pal[LoByte(w)].b) div 2
   ) div sizeofTcolor;
end;

Function TSVpalbtm2tab.AvgColInB:longint;
var r1,g1,b1,r2,g2,b2:byte;
begin
 if b.mapModel in models_8
  then AvgColInB:=mem[PtrRec(tab).Seg:MakeWord(b.tab^[0]^[0],b.tab^[1]^[1])]
  else begin
    b.Rgb(b.GetPixel(0,0),r1,g1,b1);
    b.Rgb(b.GetPixel(1,1),r2,g2,b2);
    AvgColInB:=b.Color((r1+r2)*5 div 11,(g1+g2)*5 div 11,(b1+b2)*5 div 11,255);
    end;
end;

Procedure TSVpalbtm2tab.SmoothS(x,y:integer);
begin
 s^.Box2BtF(@b,x,y);
 s^.Col2Box(x,y,2,2,AvgColInB);
end;

Destructor TSVpalbtm2tab.Done;
begin
 if s^.MapModel in models_8 then FreeMem(tab,65536);
 inherited Done;
end;



Procedure TSVtextmod.Sync;
var i,x,y:word;
    col:longint;
    byt:array[0..3] of byte absolute col;
begin
 inherited Sync;
 oldpen:=s^.pen;
 s^.pen:=PEN_SCREEN;
 for i:=1 to 8 do begin
   x:=random(s^.Xres);
   y:=random(s^.Yres);
   col:=s^.GetPixel(x,y);
   if byt[0]>32 then dec(byt[0]) else
    if byt[0]<32 then inc(byt[0]) else
     if byt[1]>0 then dec(byt[1]);
   s^.PutPixel(x,y,col);
   end;
 s^.pen:=oldpen;
end;

Procedure TSVsmooth1.Sync;
var i:integer;
begin
 inherited Sync;
 oldpen:=s^.pen;
 s^.pen:=PEN_SCREEN;
 for i:=1 to 50 do
  SmoothS(random(s^.Xres+1-b.sizeX),random(s^.Yres+1-b.sizeY));
 s^.pen:=oldpen;
end;

{
Procedure TSVsmooth2.Sync;
var i,j,crash:word;
const q=40;
      r=10;
begin
 inherited Sync;
 oldpen:=s^.pen;
 s^.pen:=PEN_SCREEN;
 for i:=1 to 3 do begin
   if abs(now.x-cil.x)+abs(now.y-cil.y)<40*q then begin
     cil.x:=q*random(s^.Xres+1-r-b.sizeX);
     cil.y:=q*random(s^.Yres+1-r-b.sizeY);
     end;
   crash:=0;
   Smoothin(now.x,cil.x,speed.x,0,q*(s^.Xres-r-b.sizeX),crash);
   Smoothin(now.y,cil.y,speed.y,0,q*(s^.Yres-r-b.sizeY),crash);
   for j:=1 to 10 do Smooth(now.x div q+random(r),now.y div q+random(r));
   end;
 s^.pen:=oldpen;
end;
}
Procedure TSVpixelize.Sync;
var i,x,y:word;
const r=10;
begin
 inherited Sync;
 oldpen:=s^.pen;
 s^.pen:=PEN_SCREEN;
 for i:=1 to 3 do begin
   x:=random(s^.Xres-r);
   y:=random(s^.Yres-r);
   s^.Box2BtF(@b,x,y);
   s^.Col2Box(x,y,r,r,b.tab^[0]^[0]);
   end;
 s^.pen:=oldpen;
end;


Procedure TSVfallpix.Sync;
var i,x,y:integer;
    p:pointer;
begin
 inherited Sync;
 oldpen:=s^.pen;
 s^.pen:=PEN_SCREEN;
 for i:=1 to 50 do begin
   x:=random(s^.Xres+1-b.sizeX-1);
   y:=random(s^.Yres+1-b.sizeY-3);
   s^.Box2BtF(@b,x,y);
   {tohle lze vynechat}
   {funguje to jen ve 256 barvach
   p:=b.tab^[0];
   asm
    les di,p
    mov ax,[es:di]
    mov bx,[es:di+2]
    cmp al,bl;jb @nic1;xchg al,bl;@nic1:
    cmp ah,bh;jb @nic2;xchg ah,bh;@nic2:
    mov [es:di],ax
    mov [es:di+2],bx
   end;}
   s^.BtF2Box(@b,x+1,y+3);
   end;
 s^.pen:=oldpen;
end;


Function RandomSaver:PSV;
begin
 if CurScreen^.MapModel=model_text
  then RandomSaver:=New(PSVtextmod,Init(CurScreen))
  else case random(2) of
   0:RandomSaver:=New(PSVsmooth1,Init(CurScreen));
   1:RandomSaver:=New(PSVfallpix,Init(CurScreen));
   {2:RandomSaver:=New(PSVpixelize,Init(CurScreen));}
   end;
end;


END.