UNIT DM;
{$R-}
{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}
                             INTERFACE
{‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹}

{$define dostran_}
{$define setup}
{$define flipir_}

USES Sluzby,Dos;



PROCEDURE MemInit;
FUNCTION  FreeMoreEMS:Boolean;
PROCEDURE RestoreUnderLocalButtons;
PROCEDURE EMSvirtualpagesDone;
PROCEDURE Reframe(ii:word);
PROCEDURE Reframe32(ii:word);
PROCEDURE Reframe48(ii:word);
PROCEDURE Reframe2handle(handle:word);

PROCEDURE Vga28;
PROCEDURE Ripper(boss:byte);
FUNCTION  RipBmp:boolean;
FUNCTION  PasswordCoded(uncoded:string):string;
FUNCTION  PasswordDecoded(coded:string):string;
FUNCTION  PasswordFits:boolean;
FUNCTION  PasswordPage:string;

{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ TREE <-> NOW ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}
PROCEDURE ResetNowToDefaults;
PROCEDURE Tree2Now;
PROCEDURE NowAndPal2Tree;

{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ TEXTURY -> EMS ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}
PROCEDURE PlaceMixedTexture(st:string);

{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ BITMAPY(conv,ems) -> VIDEO ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}
PROCEDURE Ems2Screen(line:word);
PROCEDURE EMS2screenMouseoff(y16:word);
PROCEDURE Ems2ScreenFromx4Sir8(line,fromx4,sir8:word);
PROCEDURE InsertPicture(x1,y16,sirka,vyska:word;mydoublex,mydoublescan:byte);
PROCEDURE Bitmap2Screen2(totalwidth,srcseg,x1,y1,xwidth,yheight:word;pozadi:byte;destx,desty:word);
PROCEDURE Bitmap2Screen1(totalwidth,srcseg,x1,y1,xwidth,yheight:word;pozadi:byte;destx,desty:word);


PROCEDURE InsertBigChar2Ems(font:byte;c:char;x1,y16:word);
PROCEDURE KonvertScreen;
PROCEDURE OneAskString(adr:word);

{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ MOUSE ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}
PROCEDURE GetMouseXpul(var x,y,z:word);
PROCEDURE ScanLastMousePress;
PROCEDURE Mouse(on:byte);
PROCEDURE GfxMouseOn;
PROCEDURE GfxMouseOff;
PROCEDURE NastavCitlivostmysi;
PROCEDURE AdjustMouse;
PROCEDURE MoveMouse;
PROCEDURE MouseShift(dy,dx:shortint);

PROCEDURE OneToggle(adr:word);
PROCEDURE xorcursor(video:Boolean);
PROCEDURE Hvezdicky(xy:word);
PROCEDURE SetAndVisUpperPal(n:word;visualizeIt:byte);

{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ KLAVESNICE ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}
PROCEDURE LightLocks;
PROCEDURE InitKeyb;

{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ INCY ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}
PROCEDURE IncIntree;
PROCEDURE IncTogglu;
PROCEDURE IncAskstringu;
PROCEDURE IncButtonu;
PROCEDURE IncImuzik;
PROCEDURE IncLmuzik;
PROCEDURE IncDatafajlu;

{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ SETUP ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}
PROCEDURE ScanCentralFrames;
PROCEDURE CentralFrame(mysize:word;mycolor:byte);
PROCEDURE KresliSoupatko(KresliMaz:char;i:byte;pos:word);

{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ SKLAD ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}
FUNCTION  AddThing2Sklad(whattyp:byte):word;
FUNCTION  ReadThingFromSklad(whattyp,whatDM:byte;whatDkod:word):boolean;
PROCEDURE UlozKonecSkladu;
PROCEDURE ObnovKonecSkladu;
PROCEDURE ScanSklad;

{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ DM ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}
PROCEDURE InitDataFile;
FUNCTION  OpenDataFile(st:string):boolean;
FUNCTION  CloseDataFile:boolean;
PROCEDURE SaveAnketa(midasSDnumber:integer);
FUNCTION  Rip(ripDkod:word):boolean;
FUNCTION  GetDkod(filename:string;errorifnotfound:boolean):word;
PROCEDURE GetPicSize(truly,roznasobit:boolean;var st:string;var xx,yy:word);
PROCEDURE ScanAllDMs;
PROCEDURE FillFilebazeWith(n:byte);
PROCEDURE ShowButts;
{PROCEDURE ZapamatujsiAnkname(st:string;Dkod:word);}


CONST
      maxobrazku   =  6; {local}
      maxvnoreni   = 20;
      maxLmuzik    =  4;
      maxaskstringu= 50; {local}
      maxtogglu    =100; {local}
      maxbuttonu   = 50; {local}
      askmaxlen    = 24;

      {$ifdef dostran}
      dostrany     =0;
      {$else}
      dostrany     =(wrisir-vissir) div 2;
      {$endif}

      sizeofpaletseg    =maxobrazku*210*3;

      jsemVeditoru      :boolean=false;
      intree            :byte=1;
      mouseactive       :byte=0;
      mouseflag         :byte=0;

      typDatalist            =0;
      typAskyTogly           =1;
{      typMuzik               =2;}
      typDmInfo              =3;
      typSearchFirstAskytogly=10;
      typSearchNextAskytogly =11;


{----popis screenu----}
TYPE
      T40pal=array[3..40*3+2] of byte;

      Tbutton=record
                Dkod_kam     :word;
                x1,y1,x2,y2  :word;
              end;

      Ttoggle=record   {zachovat presne toto poradi kvuli onetogglu}
                x4,y1          :word;
                Dkod_sampl     :array[0..1] of byte;
                Dkod_ripu      :word;
                stav           :byte;
              end;

      Taskstring=record {zachovat presne toto poradi kvuli oneaskstringu}
                   x4,y16         :word;
                   znaku          :byte;
                   stav           :array[1..askmaxlen] of char;
                 end;

      Tmuziky=record
                Dkod              :word;
              end;

      TPopisScreenuSmall=object
                      {---uchovavat trvale v tree---}
                      TadyUzJsemByl                    :boolean;
                      nowask,nowaskx                   :byte;
                      Dkod                             :word;
                      handle,mousex,mousey,radek       :word;
                      visx,visy                        :integer;
                      whichDM                          :byte;
                      jumppagesback                    :byte;
                      Lmuzik                           :byte;
                      Lmuziky                          :array[1..maxLmuzik] of Tmuziky;
                     end;
      TPopisScreenuFull=object(TPopisScreenuSmall)
                      {---mazat zaroven s bitmapou---}
                      Dkod_samplen,Dkod_samplout,
                      Dkod_samplin1,Dkod_samplin2      :byte;
                      Dkod_lmusic,Dkod_pirat           :word;
                      starpal                          :boolean;
                      palet                            :byte;
                      paletofs                         :array[1..maxobrazku+1] of word;
                      kdepaletaTop,kdepaletaBot        :array[1..maxobrazku] of integer;
                      fl                               :string[13];
                      pal40                            :t40pal;
                      {$ifdef flipir}
                        PIR                            :byte;
                        FLIinside                      :string[12];
                        FLIx,FLIy,inFLIx,inFLIy,
                        inFLIsir,inFLIvys,
                        FLIpozadi,FLIlet               :word;
                      {$endif}
                      local_buttonu                    :byte;
                      button                           :array[1..maxbuttonu] of Tbutton;
                      password                         :string[120];
                      ank                              :string[12];

                      {toto je v now pouze kvuli undersetupu apod,
                       normalne by se to do emspageheaderu ukladat nemuselo kdyz uz je to na skladu}
                      local_togglu                     :word;
                      toggle                           :array[1..maxtogglu] of Ttoggle;
                      local_askstringu                 :byte;
                      askstring                        :array[1..maxaskstringu] of Taskstring;
                      end;

VAR   now             :TpopisscreenuFull;
      nowSmall        :TpopisscreenuSmall absolute now;
      tree            :array[1..maxvnoreni] of TPopisScreenuSmall;

{-----}
VAR
      stillNumero,
      presx,presy,presz,
      last_abs_x,last_abs_y,
      wriy,
      panelcentrx4,panelcentry,
      paletseg,fakeskladseg,
      framewriseg,
      texturhandle,
      skladhandle,
      setuphandle            :word;
      {$ifdef dostran}
      locks,oldscrollock,
      {$endif}
      numero                 :byte;
      method                 :shortint;
      ReadOnly,
      ref,
      setuping               :Boolean;

      workDir                :stringpath;
      usedINIname            :stringpath;

{$ifdef setup}
const setupsize=89;
      soupatek=4-1;
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
{$endif}



{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ SKLAD ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}
CONST                             {spotreba pameti}
      maxdatafajlu       =350;    {x23}
      maxfilelistsize    =2500;   {x1}
      maxDMs             =50;     {x2}
      maxbighandlu       =10;     {x2}   {soucet bigs k selfDM a jednomu rootu}
      maxaddons          =10;            {tyka se jednoho rootu}
      maxImuzik          =20;

      selfDM             =1;{v DMinfo[selfDM] je odkaz na interni DM}

      setup_fl           ='˙SETUP';
      setup_Dkod         =65535;
      {rip_fl             ='˙RIP';
      rip_Dkod           =65534;}
      butts_Dkod         =65533;


TYPE
      tdata =record
              name:string[12];
              handle:byte;
              start,len:longint;
{              status:byte;}
             end;

VAR
      datafajlu          :word;
      furtfajlu          :word;
      furtbighandlu      :word;
      data               :array[1..maxdatafajlu] of Tdata;
      LastopenLength     :LONGINT;
      cestaKexe          :stringpath;
      nowDMreal,
      doublescan,doublex :byte;
      errorfile          :stringpath;

      import_muzik       :word;
      import_muziky:array[1..maxImuzik] of record
                                             Dkod            :word;
                                             {jakDavnoPlayed  :byte;}
                                           end;



{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}
                          IMPLEMENTATION
{‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹}

CONST
      askbackgroundcolor=1;

VAR
      fntseg16,fntofs16 :word;


PROCEDURE ErrorHalt(n:word);assembler;
 asm push n;push n;xor ax,ax;mov es,ax;call [es:biosfree];end;


PROCEDURE MemInit;
begin
 DetectEms;
 if EmsDetected then begin
   AllocEms16k(textur*4,texturhandle);
   {$ifdef setup}
   AllocEms16k(4,setuphandle);
   {$endif}
   if AllocEms16k(4,skladhandle) then begin
     Reframe2handle(skladhandle);
     word(memw[frameseg:0]):=0;{nastavi prazdny sklad}
     end;
   end
 else begin
   AllocConv16(            65536 div 16,fakeskladseg);
   frameseg:=fakeskladseg;
   end;
 AllocConv16((sizeofpaletseg+15) div 16,paletseg);
 AllocConv16(              65536 div 16,workseg);
end;

FUNCTION FreeMoreEMS:Boolean;
var i:word;
begin
 for i:=1 to intree-1 do if tree[i].handle>0 then begin
      deallocEMS(tree[i].handle);
      freeMoreEMS:=true;
      exit;
      end;
 freeMoreEMS:=false;
end;
{
PROCEDURE KillDkodTogglesFromStaticlist(kod:word);
var i:word;
begin
 i:=1;
 while i<=static_togglu do with toggle[i] do if Dkod<>kod then inc(i) else begin
    toggle[i]:=toggle[static_togglu];
    dec(static_togglu);
    end;
end;
}
PROCEDURE RestoreUnderLocalButtons;
var i,b:word;
begin
 with now do for b:=1 to local_buttonu do with button[b] do
   for i:=y1 div 16 to y2 div 16 do ems2screenFromx4Sir8(i,x1 div 4,(x2-x1) div 8+1);
end;

{PROCEDURE KillPageBitmap(var somepage:TPopisScreenu2);
begin
 DeallocEms(somepage.handle);
end;}

PROCEDURE EMSvirtualpagesDone;
begin
 if now.handle<>tree[intree].handle then {KillPageBitmap(now);}deallocEMS(now.handle);
 for intree:=intree downto 1 do {KillPageBitmap(tree[intree]);}deallocEMS(tree[intree].handle);
end;

PROCEDURE Reframe(ii:word);assembler;
 asm
   {reframe ii,-,-,-}
   mov cx,frameseg
   mov bx,ii;shr bx,1;jnc @startseg;add ch,2;@startseg:
   mov framewriseg,cx
   mov ax,4400h;mov dx,now.handle;int 67h;
   end;

PROCEDURE Reframe32(ii:word);assembler;
 asm
   {reframe ii,ii+1,-,-}
   mov cx,frameseg
   mov bx,ii;shr bx,1;jnc @startseg;add ch,2;@startseg:
   mov framewriseg,cx
   mov ax,4400h;mov dx,now.handle;int 67h;inc bx
   mov ax,4401h;mov dx,now.handle;int 67h;
   end;

PROCEDURE Reframe48(ii:word);assembler;
 asm
   {reframe ii-1,ii,ii+1,-}
   mov cx,frameseg
   mov bx,ii;dec bx;jnc @nepretek;inc bx;@nepretek:
   shr bx,1;jnc @startseg;add ch,2;@startseg:
   mov framewriseg,cx
   mov ax,4400h;mov dx,now.handle;int 67h;inc bx
   mov ax,4401h;mov dx,now.handle;int 67h;inc bx
   mov ax,4402h;mov dx,now.handle;int 67h;
   end;


PROCEDURE Reframe2handle(handle:word);assembler;
 asm
  {reframe to setup_ems}
   mov ax,4400h;mov dx,handle;mov bx,0;int 67h
   mov ax,4401h;mov dx,handle;mov bx,1;int 67h
   mov ax,4402h;mov dx,handle;mov bx,2;int 67h
   mov ax,4403h;mov dx,handle;mov bx,3;int 67h
   end;

PROCEDURE Vga28;
begin
 errorfile:='VGA28.FNT';
 if not DM.opendatafile(errorfile) then errorhalt(14);
 readdatafile(lastOpenLength,0,workseg);
 asm mov ax,3;int 10h
     push bp
     mov ax,1110h;mov bx,0e00h;mov cx,100h;mov bp,0;mov es,workseg;int 10h
     pop bp
     end;
 DM.closedatafile;
end;

PROCEDURE Ripper(boss:byte);
var   select,askvratil:string[40];
      selected:array[1..maxdatafajlu] of boolean;
      a:integer;

procedure higlight(c:byte);
var   i,j,x,y,col,sels,max:word;
      st:string[4];
      prest:string[2];
begin
 sels:=0;
 prest:='';
 if datafajlu<6*biostxvys then max:=datafajlu else max:=6*biostxvys;
 for i:=1 to max do with data[i] do begin
   j:=i-1;
   x:=13*(j div biostxvys);
   y:=1+(j mod biostxvys);
   col:=7;
   if selected[i] then begin inc(col,8);inc(sels);end;
   if a=i then inc(col,4*16);
   textattr:=col;
   if debuginfo then prest:=chr(48+handle)+' ';
   wrixy(x+1,y+1,prest+name);
   end;
 textattr:=16+11;
 str(sels:4,st);
 wrixy(61,1,st+' files selected');
end;

var   ch:char;
      i,muzakdatafajlu:word;

begin
 asm mov ax,3;int 10h;
     mov ax,1112h;mov bl,0;int 10h;
     end;

 {killne vsechno co by uzivatel nemel ripovat}
 if boss=0 then begin
   move(data,mem[workseg:0],sizeof(data));
   muzakdatafajlu:=0;
   for i:=1 to datafajlu do with data[i] do
    if pos('.MOD',name)+pos('.S3M',name)+pos('.MTM',name)>0 then begin
       inc(muzakdatafajlu);
       data[muzakdatafajlu]:=data[i];
       end;
   asm push datafajlu;end;
   datafajlu:=muzakdatafajlu;
   end;

 select:='*';
 fillchar(selected,sizeof(selected),0);
 a:=1;
 textattr:=16+11;
 for i:=1 to 80 do wrixy(i,1,' ');
 wrixy(2,1,'RIPPER... (+) (-) (*) (Insert) (R)ip (ESC)');
 repeat
   higlight(1);
   gotoxy(1,61);
   ch:=readkey;
   higlight(7);
   case ch of '+','-','*':begin
                          askvratil:=ask(2{EscVraciNic}+1{inserty},'Selector (rozsirena hvezdickova konvence)',40,select,'!');
                          if askvratil>'' then begin
                            select:=askvratil;
                            upcasestring(@select);
                            for i:=1 to datafajlu do if XjeprvkemY(data[i].name,select) then
                              case ch of '+':selected[i]:=true;
                                         '-':selected[i]:=false;
                                         '*':selected[i]:=not selected[i];
                                         end;
                            end;
                          end;
            #82:begin
                selected[a]:=not selected[a];
                if a<datafajlu then inc(a);
                end;
            'r':for i:=1 to datafajlu do if selected[i] then begin
                  selected[i]:=not rip(i);
                  higlight(1);
                  end;
            #72:if a>1 then dec(a);
            #80:if a<datafajlu then inc(a);
            #71:a:=1;
            #79:a:=datafajlu;
            #73:dec(a,(a-1) mod biostxvys);
            #81:begin
                inc(a,biostxvys-1-(a-1) mod biostxvys);
                if a>datafajlu then a:=datafajlu;
                end;
            #75:dec(a,biostxvys);
            #77:inc(a,biostxvys);
            end;
   while a<1 do inc(a,biostxvys);
   while a>datafajlu do dec(a,biostxvys);
 until ch=#27;

 {obnovi seznam data}
 if boss=0 then begin
   asm pop datafajlu;end;
   move(mem[workseg:0],data,sizeof(data));
   end;
end;

FUNCTION RipBmp:boolean;
type  TBmpHeader=record
                  identifier     :array[1..2] of char;
                  filesize       :longint;
                  free           :longint;
                  bitmapofs      :longint;
                  size           :longint;
                  width          :longint;
                  height         :longint;
                  planes         :word;
                  bitcount       :word;
                  compression    :longint;
                  sizeimage      :longint;
                  XPelsPerMeter  :longint;
                  YPelsPerMeter  :longint;
                  ColorsUsed     :longint;
                  ColorsImportant:longint;
                end;
const bmpheadersize=sizeof(tbmpheader);
      BmpHeader:TBmpHeader=(
                  identifier     :'BM';
                  filesize       :0{?};
                  free           :0;
                  bitmapofs      :$436;
                  size           :$28;
                  width          :0{?};
                  height         :0{?};
                  planes         :1;
                  bitcount       :8;
                  compression    :0;
                  sizeimage      :0;
                  XPelsPerMeter  :0;
                  YPelsPerMeter  :0;
                  ColorsUsed     :0;
                  ColorsImportant:0);
      savesir=vissir;
var   st:stringpath;
      ofsst,i,handle:word;
label bad;
begin
 ripbmp:=false;
 for i:=14 to 16 do begin pal[3*i+2]:=pal[3*i];pal[3*i]:=0;end;showpal(13,4);
 st:=workdir+now.fl+'.bmp'#0;
 ofsst:=ofs(st)+1;
 {prepare header}
 bmpheader.width:=savesir;
 bmpheader.height:=16*now.radek;
 bmpheader.filesize:=bmpheadersize+bmpheader.width*bmpheader.height+768;
 {prepare pal}
 for i:=0 to 255 do begin
   mem[workseg:4*i+0]:=pal[3*i+2] shl 2;
   mem[workseg:4*i+1]:=pal[3*i+1] shl 2;
   mem[workseg:4*i+2]:=pal[3*i+0] shl 2;
   mem[workseg:4*i+3]:=0;
   end;
 i:=now.radek;
 asm
    {open}
     mov ah,3ch;mov cx,0;mov dx,ofsst
     push ds;push ss;pop ds;int 21h;pop ds;mov handle,ax;jc bad;
    {save header}
     mov ah,40h;mov bx,handle;mov cx,bmpheadersize;lea dx,bmpheader;int 21h;jc bad;
    {save pal}
     mov ah,40h;mov bx,handle;mov cx,1024;mov dx,0;push ds;mov ds,workseg;int 21h;pop ds;jc bad;
    {--startloop}
     @3:
    {prepare 16 lines}
     dec i
     push i;call reframe;mov es,workseg;mov di,0;mov si,4*2048-wrisir/4
     push ds;mov ds,framewriseg
     mov dx,16{16 lines}
     @2:
     mov cx,savesir/4{wrisir bytes per line}
     @1:
     mov ah,[si-3*2048];mov al,[si-2*2048];db 66h;shl ax,16;mov ah,[si-1*2048];lodsb;db 66h;stosw;
     loop @1
     sub si,wrisir/4*2-(wrisir-savesir)/4
     dec dx;jnz @2
     pop ds
    {save 16 lines}
     mov ah,40h;mov bx,handle;mov cx,16*savesir;mov dx,0;push ds;mov ds,workseg;int 21h;pop ds;jc bad;
    {--endloop}
     cmp i,0;jnz @3
    {close}
     mov ah,3eh;mov bx,handle;int 21h;jc bad;
    end;
 ripbmp:=true;
 bad:
 for i:=14 to 16 do begin pal[3*i]:=pal[3*i+2];pal[3*i+2]:=0;end;showpal(13,4);
end;


FUNCTION PasswordCoded(uncoded:string):string;
var   st:string;
      bit,byt,onebit,i,j,k,c:byte;
begin
 for i:=length(uncoded) downto 1 do insert(chr(32+random(128)),uncoded,i);
 st:='';
 k:=0;
 c:=0;
 for bit:=0 to 6 do for byt:=length(uncoded) downto 1 do begin
   onebit:=1-((ord(uncoded[byt])-32) shr bit mod 2);
   c:=c shl 1+onebit;
   inc(k);
   if k=7 then begin
     st:=st+chr(32+c);
     k:=0;
     c:=0;
     end;
   end;
 PasswordCoded:=st;
end;

FUNCTION PasswordDecoded(coded:string):string;
var   st:string;
      bit,byt,onebit,i,j,k,c:byte;
begin
 st[0]:=coded[0];for i:=1 to length(st) do st[i]:=' ';
 k:=0;
 c:=0;
 byt:=length(coded);
 bit:=0;
 for i:=1 to length(coded) do begin
   c:=ord(coded[i])-32;
   for j:=6 downto 0 do begin
     onebit:=1-(c shr j mod 2);
     st[byt]:=chr(ord(st[byt]) + onebit shl bit);
     dec(byt);
     if byt=0 then begin
       byt:=length(coded);
       inc(bit);
       end;
     end;
   end;
 for i:=1 to length(st) do delete(st,i,1);
 PasswordDecoded:=st;
end;

var passwordPageFits:byte;{rika kolikatej password je OK}

FUNCTION PasswordFits:boolean;
var   st,pass:string;
      i:byte;
label bad;
begin
 PasswordFits:=false;
 passwordpagefits:=0;
 if now.local_askstringu<>1 then exit;
 if now.password='' then exit;
 pass:=passwordDecoded(now.password);
 while pass>'' do begin
   inc(passwordpagefits);
   st:=cutstringfromstring(',',pass);{cutne password}
   cutstringfromstring(',',pass);{cutne page}
   for i:=1 to length(st) do if now.askstring[1].stav[i]<>st[i] then goto bad;
   for i:=length(st)+1 to now.askstring[1].znaku do if now.askstring[1].stav[i]<>#0 then goto bad;
   PasswordFits:=true;
   exit;
   bad:
   end;
 passwordpagefits:=0;
end;

FUNCTION PasswordPage:string;
var   st:string;
      i:byte;
begin
 st:=passwordDecoded(now.password);
 for i:=1 to 2*passwordPageFits-1 do cutstringfromstring(',',st);
 PasswordPage:=cutstringfromstring(',',st);
end;

{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ TREE <-> NOW ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}

PROCEDURE ResetNowToDefaults;
begin
 fillchar(now,sizeof(now),0);
 with now do begin
   mousex:=256;
   mousey:=220;
   visx:=(wrisir-vissir) div 2;
   {$ifdef flipir}
   FLIinside:='';
   {$endif}
   nowaskx:=1;
   end;
end;


PROCEDURE Reframe2Pageheader(handle,radek:word);assembler;
 asm
   {reframe last8KBfram of that handle,-,-,-}
   mov cx,frameseg
   mov bx,radek;shr bx,1;jnc @startseg;add ch,2;@startseg:
   mov framewriseg,cx
   mov ax,4400h;mov dx,handle;int 67h;
   end;

PROCEDURE Tree2Now;
begin
 ResetNowToDefaults;
 nowSmall:=tree[intree];
 if now.handle>0 then begin
   Reframe2Pageheader(now.handle,now.radek);
   move( mem[framewriseg:0                      ], now            , sizeof(now));
   move( mem[framewriseg:sizeof(now)+sizeof(pal)], mem[paletseg:0], sizeofpaletseg);
   end;{
 else begin
   asm nop;end;
   end;}
end;
{
PROCEDURE Tree2Pal;
begin
 Reframe2Pageheader(now.handle,now.radek);
 move( mem[framewriseg:sizeof(now)            ], pal            , sizeof(pal));
end;
}
PROCEDURE NowAndPal2Tree;
begin
 Reframe2Pageheader(now.handle,now.radek);
 move( now            , mem[framewriseg:0                      ], sizeof(now));
{ move( pal            , mem[framewriseg:sizeof(now)            ], sizeof(pal));}
 move( mem[paletseg:0], mem[framewriseg:sizeof(now)+sizeof(pal)], sizeofpaletseg);
 tree[intree]:=nowSmall;
end;


{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ TEXTURY -> EMS ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}

PROCEDURE NaframujNaTexturu(n:word);assembler;
 asm
      mov ax,4400h;mov dx,texturhandle;mov bx,n;shl bx,2;push bx;int 67h;pop bx
      mov ax,4401h;mov dx,texturhandle;inc bx           ;push bx;int 67h;pop bx
      mov ax,4402h;mov dx,texturhandle;inc bx           ;push bx;int 67h;pop bx
      mov ax,4403h;mov dx,texturhandle;inc bx                   ;int 67h
 end;


const  tex_ramecekcolorLo=26;
       tex_ramecekcolorHi=25;
       pocet_starteru=10;
       putter_tab_size=32;
       w_ram=2;
       putter_put=1;
       putter_skip=2;


procedure putter_tabs;assembler;
const  L=tex_ramecekcolorLo;
       H=tex_ramecekcolorHi;
asm
 dw offset @starter0
 dw offset @starter1
 dw offset @starter2
 dw offset @starter3
 dw offset @starter4
 dw offset @starter5
 dw offset @starter6
 dw offset @starter7
 dw offset @starter8
 dw offset @starter9
 dw offset @ender0
 dw offset @ender1
 dw offset @ender2
 dw offset @ender3
 dw offset @ender4
 dw offset @ender5
 dw offset @ender6
 dw offset @ender7
 dw offset @ender8
 dw offset @ender9
{O kolik lines goback, kolik lines nasleduje v datech, data:
 0-mazat nulou
 1-vkladat texturu
 2-skipnout
 ?-stos ?}
 @starter0: db 0,  0
 @starter1: db 0,  1,  0
 @starter2: db 0,  2,  L,L
 @starter3: db 0,  3,  0,L,L
 @starter4: db 32, 32, 1,2,2,2,1,2,2,1,2,2,1,2,1,2,1,2,1,2,1,2,1,2,1,1,2,1,1,2,1,1,1,2,255{mix1}
 @starter5: db 32, 32, 0,1,0,0,2,2,2,2,2,2,0,1,1,1,0,0,2,2,2,2,0,1,1,1,1,1,1,0,0,2,2,0,255{mix2bot}
 @starter6: db 32, 32, 0,0,1,0,2,2,2,2,2,2,0,0,1,1,1,0,2,2,2,2,0,0,1,1,1,1,1,0,2,2,0,0,255{mix2top}
 @starter7:
 @starter8:
 @starter9:
{Kolik lines nasleduje v datech, data}
 @ender0: db 0
 @ender1: db 1, 0
 @ender2: db 2, H,H
 @ender3: db 3, H,H,0
 @ender4:
 @ender5:
 @ender6:
 @ender7:
 @ender8:
 @ender9:
 end;


PROCEDURE FillEmsPagesWorksegemRaw(fromofs,fromline,lines,x0,sir:word;writer:byte);assembler;
var nowhandle:word;
 asm
      mov ax,lines;cmp ax,0;jz @end
      cmp sir,0;jz @end
      mov ax,now.handle;mov nowhandle,ax
      {nastavi globalni registry}
      PUSH ds
      mov es,frameseg
      mov ds,workseg
      mov ah,putter_put

      {---WRITER---}
      @nextpage:
      {naframuje}
      pusha;mov ax,4400h;mov bx,fromline;shr bx,5;mov dx,nowhandle;int 67h;popa
      {nastavi offsety pro movs}
      mov si,fromline;shl si,8;add si,x0
      mov di,fromline;and di,31;shl di,9;add di,x0

      {writuje po linkach dokud neskonci nebo neopusti 32lines}
      @nextline:
       push si
       push di
       mov cx,sir
       {nacte do AH typ teto linky}
       mov bx,fromofs;or bx,bx;jz @nechAHbyt;mov ah,[cs:bx];inc fromofs;@nechAHbyt:
       {vetveni podle typu}
       cmp ah,putter_skip;jz @movsdone
       cmp ah,putter_put;jz @movsthingy

      @stosThingy:
       mov al,ah;push ax;push ax;db 66h;pop ax
       {zarovna DI na sudou}
       test di,1;jz @s1ok;stosb;dec cx;jz @movsdone;@s1ok:
       {zarovna DI na dablsudou}
       test di,2;jz @s2ok;stosw;sub cx,2;jz @movsdone;@s2ok:
       {dodela zbytek}
       push cx;shr cx,2;db 66h;rep stosw;pop cx;and cx,3;rep stosb
       {goto next}
       jmp @movsdone

      @movsThingy:
       {levej ramecek}
       test writer,w_ram;jz @mnedelat_ramecek1
         sub cx,2;jc @movsdone;mov al,tex_ramecekcolorLo;stosb;inc si
         @mnedelat_ramecek1:
       {zarovna DI na sudou}
       test di,1;jz @m1ok;movsb;dec cx;jz @movsdone;@m1ok:
       {zarovna DI na dablsudou}
       test di,2;jz @m2ok;movsw;sub cx,2;jz @movsdone;@m2ok:
       {dodela zbytek}
       push cx;shr cx,2;db 66h;rep movsw;pop cx;and cx,3;rep movsb
       {pravej ramecek}
       test writer,w_ram;jz @mnedelat_ramecek2
         mov al,tex_ramecekcolorHi;stosb
         @mnedelat_ramecek2:

      @movsdone:
       pop di
       pop si
       add di,wrisir
       add si,256

      dec lines;jz @end_popDS
      inc fromline;test fromline,31;jnz @nextline
      jmp @nextpage

      @end_popDS:
      POP ds

      @end:
      end;

FUNCTION FillEmsPagesWorksegemPro(lastline,fromline,lines,x0,sir:word;starter,ender,writer:byte):word;
var   RadekCounter:word;
      SIintexture:word;
      ofsstarter,ofsender,dest,ofsdest,starteru,filleru,enderu:word;
      i,j,k:word;
begin
 ofsstarter:=memw[cseg:ofs(putter_tabs)+2*starter];
 ofsender  :=memw[cseg:ofs(putter_tabs)+2*(pocet_starteru+ender)];
 {decne fromline}
 i:=mem[cseg:ofsstarter];          inc(ofsstarter);
 if i<fromline then dec(fromline,i) else fromline:=0;
 {zjisti kolik bude starteru, enderu}
 starteru  :=mem[cseg:ofsstarter]; inc(ofsstarter);
 enderu    :=mem[cseg:ofsender];   inc(ofsender);
 {zarovna pocty starteru, filleru, enderu aby se vesly pod lastline}
 if fromline+starteru             >lastline then starteru:=lastline-fromline;
 if fromline+starteru+enderu      >lastline then enderu  :=lastline-fromline-starteru;
 if fromline+starteru+enderu+lines>lastline then filleru :=lastline-fromline-starteru-enderu
                                            else filleru :=lines-starteru-enderu;
 {vykresli to}
 FillEmsPagesWorksegemRaw(ofsstarter,fromline,starteru ,x0,sir,writer);inc(fromline,starteru);
 FillEmsPagesWorksegemRaw(0         ,fromline,filleru  ,x0,sir,writer);inc(fromline,filleru);
 FillEmsPagesWorksegemRaw(ofsender  ,fromline,enderu   ,x0,sir,writer);inc(fromline,enderu);
 {vrati line kde skoncil+1}
 FillEmsPagesWorksegemPro:=fromline;
end;


PROCEDURE MakeTextureInSegWithCache(j:char;myseg:word);
const texturyhotovy:byte=0;
      poradiC=2;
      poradiD=3;
var   poradiVems:byte;
begin
 case j of 'a':poradiVems:=0;
           'b':poradiVems:=1;
           'c':poradiVems:=poradiC;
           'd':poradiVems:=poradiD;
          else poradiVems:=255;
          end;
 if ((j='c') or (j='d')) and ((texturyhotovy and (4+8))=0) then begin
   {specialni pripad textur c a d}
   texturyhotovy:=texturyhotovy or (1 shl poradiC+1 shl poradiD);
   MakeTextureInSeg('c',myseg);
   NaframujNaTexturu(poradiC);
   CopySeg(myseg,frameseg);
   if j='c' then begin
     NaframujNaTexturu(poradiD);
     CopySeg(myseg,frameseg);
     MakeTextureInSeg('d',frameseg);
     end
   else begin
     MakeTextureInSeg('d',myseg);
     NaframujNaTexturu(poradiD);
     CopySeg(myseg,frameseg);
     end;
   end
 else begin
   {bezny textury ukladany do ems}
   if poradiVems<textur then begin
     NaframujNaTexturu(poradiVems);
     if texturyhotovy and (1 shl poradiVems)=0 then MakeTextureInSeg(j,frameseg);
     CopySeg(frameseg,myseg);
     texturyhotovy:=texturyhotovy or (1 shl poradiVems);
     end
   else
     {bezny textury neukladany do ems}
     MakeTextureInSeg(j,myseg);
   end;
end;

PROCEDURE PlaceMixedTexture(st:string);
var   textureinworkseg,basetexture:char;
      sub:string;
      st1:string;
      modifikant:string[30];
      i,j,lastline,lines,nowline,wasline,code,x0,xsir:word;
      starter,ender,writer,filter:char;
      picc,picy,picx:word;picxy:longint;
      usepicypal:boolean;
label 1,nedelete11,putit,nextflag;
begin
 textureinworkseg:=#0;
 lastline:=now.radek shl 4;
 nowline:=0;
 1:
 wasline:=nowline;

 {odstrihne jedno slovo}
 sub:=CutStringFromString(' ',st);
 if sub='' then exit;

 {nastavi defaults}
 starter:='0';
 ender:='0';
 writer:='0';
 case VGA_MODE of 1:begin
                    x0:=(wrisir-vissir) div 2;
                    xsir:=vissir;
                    end;
                  2:begin
                    x0:=0;
                    xsir:=wrisir;
                    end;
                  end;
 {nacte flags}
 nextflag:
 case sub[1] of '-','=':begin
                    i:=pos('.',sub);
                    st1:=copy(sub,2,i-2);
                    val(st1,j,code);
                    if code>0 then errorhalt(49);
                    case sub[1] of '-':if nowline>=j then dec(nowline,j) else nowline:=0;
                                   '=':if j<lastline then nowline:=j else j:=lastline;
                                   end;
                    end;
                '(':begin
                    st1:=CutStringFromString(',',sub);delete(st1,1,1);
                    val(st1,x0,code);
                    if (x0>=512) or (code>0) then errorhalt(49);
                    st1:=CutStringFromString(')',sub);
                    val(st1,xsir,code);
                    if (x0+xsir>512) or (code>0) then errorhalt(49);
                    goto nextflag;{skipne delete(sub,1,1)}
                    end;
                else goto nedelete11;
                end;
 delete(sub,1,i);
 goto nextflag;
 nedelete11:

 {zjisti na kolik radek to bude}
 i:=1;while (length(sub)>=i) and (sub[i]>='0') and (sub[i]<='9') do inc(i);dec(i);
 if i=0 then lines:=32000 else val(copy(sub,1,i),lines,code);
 {if nowline+lines>lastline then lines:=lastline-nowline;}
 delete(sub,1,i);

 {zjisti jaka textura a vygeneruje ji}
 if sub='' then errorhalt(49);
 basetexture:=sub[1];
 delete(sub,1,1);
 case basetexture of '~':basetexture:=textureinworkseg;
                     '<':begin{nacte texturu z disku}
                         usepicypal:=sub[1]='*';
                         if usepicypal then delete(sub,1,1);
                         if not dm.opendatafile(cutstringfromstring('>',sub)) then errorhalt(49);
                         textureinworkseg:=basetexture;
                         picc:=0;
                         readdatafile(5,ofs(picx),seg(picx));
                         picxy:=longint(picx)*picy;
                         if (picc>16) or (picxy>65536) then errorhalt(49);
                         if usepicypal then
                           readdatafile(3*picc,ofs(now.pal40[3*25]),seg(now.pal40[3*25]));
                         if picxy=65536 then begin
                           readdatafile(1,0,workseg);
                           readdatafile(65535,1,workseg);
                           end
                         else
                           readdatafile(picxy,0,workseg);
                         closedatafile;
                         asm mov si,0;mov es,workseg;mov cx,word ptr picxy;
                             mov al,256-25;sub al,byte ptr picc
                             @1:sub [es:si],al;inc si;loop @1
                             end;
                         {rozplizne to pres celej seg}
                         if picx<256 then for i:=picy-1 downto 1 do begin
                           for j:=0 to (256 div picx)-1 do move(mem[workseg:i*picx],mem[workseg:i*256+j*picx],picx);
                           move(mem[workseg:i*picx],mem[workseg:i*256+(j+1)*picx],256-picx*j);
                           end;
                         for i:=picy to 255 do
                           move(mem[workseg:(i-picy)*256],mem[workseg:i*256],256);
                         end;
                    else if (basetexture<>textureinworkseg) or (modifikant<>'') then begin
                           MakeTextureInSegWithCache(basetexture,workseg);
                           textureinworkseg:=basetexture;
                           modifikant:='';
                           end;
                    end;

 {nacte a provede pozadovane upravy textury}
 if sub='' then goto putit;
 if sub[1]='(' then begin
   delete(sub,1,1);
   modifikant:=cutstringfromstring(')',sub);
   st1:=modifikant;
   while st1>'' do FiltrujTextureInSeg(cutstringfromstring(',',st1),workseg);
   end;

 {nacte starter,ender,writer}
 if sub='' then goto putit;
 starter:=sub[1];
 delete(sub,1,1);
 case starter of '-':starter:='0';
                 end;

 if sub='' then goto putit;
 ender:=sub[1];
 delete(sub,1,1);
 case ender of '-':ender:='0';
               end;

 if sub='' then goto putit;
 writer:=sub[1];
 delete(sub,1,1);
 case writer of '-':writer:='0';
                end;

 if sub>'' then errorhalt(49);

 {putne to a kdyz neni konec, zaloopuje k dalsimu slovu}
 putit:
 if basetexture<>'z' then nowline:=FillEmsPagesWorksegemPro(lastline,
        nowline,lines,x0,xsir,ord(starter)-48,ord(ender)-48,ord(writer)-48);
 goto 1;
end;


{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ BITMAPY(conv,ems) -> VIDEO ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}

PROCEDURE Ems2Screen(line:word);assembler;var bit,workframseg:word;
 var  fake_vga_mode:byte;
 asm  mov al,vga_mode;mov fake_vga_mode,al

      mov ax,line;shr ax,5{wrisir/16};call bank
     {reframe, prepare ds}
      push ds
      mov ax,4400h;mov bx,line;
      mov cx,frameseg;shr bx,1;jnc @segfr;add ch,2;@segfr:mov workframseg,cx;
      mov dx,now.handle;int 67h;
     {prepare ds,es}
 {     mov ax,line;shl ax,11;mov [cs:offset @za-2],ax}
      mov es,sega000;mov ds,workframseg
      mov si,0

     {vetveni}
      cmp fake_VGA_MODE,2;jz @svga512   {...pozor nejsem v datasegmentu!}

      @VGA360:
      mov bit,3
     {set bit}
      @nextbit:
      mov ax,102h;mov cx,bit;shl ah,cl;mov dx,3c4h;out dx,ax
     {copy}
      mov di,line;shl di,11

{512: mov cx,512;db 66h;rep movsw
{360:}mov cx,16;@line:push cx
      mov cx,(vissir+8)/4/4;db 66h;rep movsw
      add si,(wrisir-(vissir+8))/4
      add di,(wrisir-(vissir+8))/4
      pop cx;loop @line

     {loop 4 bits}
      dec bit;jns @nextbit
      jmp @done

      @SVGA512:
     {nabankuje}
      mov ax,line;shr ax,3;and ax,3;call vesabank
     {zkopci 8 kilo}
      mov di,line;shl di,13
      mov cx,2048;db 66h;rep movsw

      @done:

      pop ds
     end;

PROCEDURE EMS2screenMouseoff(y16:word);assembler;
 asm
     mov al,mouseactive;push ax;mov mouseactive,0
     mov al,mouseflag;mov ah,0;push ax
     push 0;call mouse
     push y16;call EMS2screen
     call mouse;pop ax;mov mouseactive,al
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
     end;


PROCEDURE InsertPicture(x1,y16,sirka,vyska:word;mydoublex,mydoublescan:byte);assembler;var j,ha:word;
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
     cmp mydoublex,1;jnz @normalsize
      @miniloop2:{precte scanlajnu}
      mov bl,mydoublescan
      @nextscan2:{nekolikrat zakresli tutez scanlajnu}
      mov cx,sirka;shr cx,1;inc cx;push si;push di;dec di
      @42:inc di;@52:lodsw;or al,al;loopz @42;jcxz @62;stosb;jmp @52;@62:
      pop di;pop si;add di,wrisir
      dec bl;jz @lastscan2;jmp @nextscan2;@lastscan2:add si,sirka
      dec dx;jz @99
      test di,16384;jz @miniloop2
      and di,16383;jmp @wideloop

     {loop DOUBLE_X=2 - normalsize}
     @normalsize:
     cmp mydoublex,2;jnz @doublesize
      @miniloop1:{precte scanlajnu}
      mov bl,mydoublescan
      @nextscan1:{nekolikrat zakresli tutez scanlajnu}
      mov cx,sirka;inc cx;cmp cx,513-0;jc @under513;mov cx,513-0;@under513:
      push si;push di;dec di
      @41:inc di;@51:lodsb;or al,al;loopz @41;jcxz @61;stosb;jmp @51;@61:
      pop di;pop si;add di,wrisir
      dec bl;jnz @nextscan1
      add si,sirka
      dec dx;jz @99
      test di,16384;jz @miniloop1
      and di,16383;jmp @wideloop

     {loop DOUBLE_X=4 - doublesize}
     @doublesize:
      @miniloop3:{precte scanlajnu}
      mov bl,mydoublescan
      @nextscan3:{nekolikrat zakresli tutez scanlajnu}
      mov cx,sirka;inc cx;cmp cx,256;jc @under256;mov cx,256;@under256:
      push si;push di;dec di
      @43:inc di;inc di;@53:lodsb;or al,al;loopz @43;jcxz @63;stosb;stosb;jmp @53;@63:
      pop di;pop si;add di,wrisir
      dec bl;jnz @nextscan3
      add si,sirka
      dec dx;jz @99
      test di,16384;jz @miniloop3
      and di,16383;jmp @wideloop

      @99:
      pop ds

      end;

{$i bitblt.inc}
{$define pix2}
{$i bitblt.inc}


PROCEDURE InsertBigChar2Ems(font:byte;c:char;x1,y16:word);{samo si to naframuje}
var last,j,ha,myseg:word;
    cislolajny:byte;
label 2;
begin
 myseg:=GetPackedBigCharSeg(font,c);
 if myseg=0 then errorhalt(1);
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


{konvertuje 16KBframy 1..(radek+1)/2+1 do 0..(radek+1)/2
 posune text z prostredku k levyu kraji}
PROCEDURE KonvertScreen;assembler;
var i,j,bit,ha:word;
 asm
      cmp VGA_MODE,1;jnz @no_konverze

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
      call near ptr @in

      mov ax,es
      add ah,4
      mov ds,ax
      call near ptr @in

      dec i;jns @loop

      pop ds
      jmp @9

  @in:mov bit,3
      @nextbit:
      mov si,bit;mov dx,3;{$ifndef dostran}add si,(wrisir-vissir)/2{$endif}
      mov cx,16*512/4/8
      @1:
      movsb;add si,dx;movsb;add si,dx;movsb;add si,dx;movsb;add si,dx;
      movsb;add si,dx;movsb;add si,dx;movsb;add si,dx;movsb;add si,dx;
      loop @1
      dec bit;jns @nextbit
      retn

      @9:
      @no_konverze:
      end;

PROCEDURE OneAskString(adr:word);assembler;{reframuje;pise askstring[n].str do EMS ; ROM font}
 asm
      cmp fntseg16,0;jnz @znamadresu
     {get fnt 9x16 adr}
      mov ah,11h;mov al,30h;mov bh,6;push bp;int 10h;mov fntseg16,es;mov fntofs16,bp;pop bp;
      @znamadresu:

      mov si,adr
      {inc si;inc si;{preskoci Dkod}
      lodsw;mov di,ax{nacte x4}
      lodsw;pusha;push ax;{nacte y16}call reframe;popa;mov es,framewriseg
      lodsb;mov ah,0;mov cx,ax{nacte pocet znaku na radce}
      mov dl,0{prvni pismeno nezmensovat}

 @nextchar:
      lodsb{precte jedno pismeno}

      {zkonvertuje case}
      cmp dl,0;jz @nechat
      cmp al,'A';jl @nechat
      cmp al,'Z';jg @nechat
      add al,'a'-'A'
      @nechat:
      mov dl,0
      cmp al,0;jz @dl0
      cmp al,' ';jz @dl0
      mov dl,1
      @dl0:

      pusha
      push ds

      shl ax,4
      add ax,fntofs16
      mov si,ax
      mov ds,fntseg16
      mov dx,16
     @nextline0:
      lodsb
      mov cx,4
     @nextquarter:
      mov bx,257*askbackgroundcolor
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


{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ MOUSE ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}

PROCEDURE GetMouseXpul(var x,y,z:word);
var i,j,k:word;
begin;
 if mousepresent then begin
   Sluzby.GetMouseOrZero(x,y,z);
   x:=x div 2;
   end
 else begin
  x:=now.mousex;
  y:=now.mousey;
  z:=0;
  end;

{ asm cmp mousepresent,0;jz @nomouse
     mov ax,3;int 33h;jmp @ismouse
     @nomouse:mov bx,0;mov cx,now.mousex;add cx,cx;mov dx,now.mousey
     @ismouse:mov k,bx;shr cx,1;mov i,cx;mov j,dx
     end;
 x:=i;y:=j;z:=k;}
end;

PROCEDURE ScanLastMousePress;assembler;
 {push:left=2,right=8,mid=32,  release:left=4,right=16,mid=64}
 asm cmp mousepresent,0;jz @nomouse
     mov ax,5;mov bx,0;int 33h;mov ax, 2;cmp bx,0;jnz @found
     mov ax,5;mov bx,1;int 33h;mov ax, 8;cmp bx,0;jnz @found
     cmp Mbuttons,3;jnz @skip3
     mov ax,5;mov bx,2;int 33h;mov ax,32;cmp bx,0;jnz @found
     @skip3:
     jmp @notfound
     @found:
     shr cx,1
     mov presx,cx
     mov presy,dx
     mov presz,ax
     @notfound:
     @nomouse:
     end;

PROCEDURE Mouse(on:byte);assembler;
var a:word;
    mouseUPbank:word;
{write:3c4,2,0-15; read:3ce,4,0-3}
 asm pushf;cli
     mov al,on
     cmp al,mouseflag;jz @99_done

     mov al,on
     cmp al,0;jz @mazat_z_last_absolute_position
    {novy souradnice}
     mov cx,now.mousex;add cx,now.visx;mov last_abs_x,cx
     mov dx,now.mousey;add dx,now.visy;mov last_abs_y,dx
     jmp @kresli
    {stary souradnice}
    @mazat_z_last_absolute_position:
     mov cx,last_abs_x
     mov dx,last_abs_y
    @kresli:
     mov es,sega000
     cmp VGA_MODE,2;jz @mod_512

@MOD_360:
    {save vga ports}
     call ports2ax;PUSH AX
    {save bank}
     mov ah,0;mov al,nowbank;PUSH AX

    {nabankuje}
     mov ax,dx;shr ax,9;mov mouseUPbank,ax;call bank

     xor mouseflag,1
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
     add di,wrisir/4;jnc @nonewpage1;push ax;mov ax,mouseUPbank;inc ax;call bank;pop ax;@nonewpage1:
     loop @1
     sub si,2*16*8-2
     sub di,4*wrisir;jnc @nonewpage2;push ax;mov ax,mouseUPbank;       call bank;pop ax;@nonewpage2:

     shl ah,1;cmp ah,16;jnz @ok;mov ah,1;inc di;@ok:

     pop cx;loop @loop

    {restore last bank}
     POP AX;call bank
    {restore vga ports}
     POP BX;call bx2ports
     jmp @99_done

@MOD_512:
    {save bank}
     PUSH word ptr nowbank

    {nabankuje poprvy}
     mov ax,dx;shr ax,7;and ax,3;mov mouseUPbank,ax;call VesaBank

     lea si,sipka
     lea bx,sipkabuf
     xor mouseflag,1
     jnz @budu_kreslit;mov si,bx;@budu_kreslit:
     shl dx,9{dx*wrisir/4};mov di,cx;add di,dx

     mov dx,16;
    @nextline:
       push di
       mov cx,8
       cmp mouseflag,0;jz @maz512
       {kresli 1 caru sipky}
       @kresli512:
        mov ax,[es:di]
        mov [bx],ax;add bx,2
        lodsw
        or al,al;jz @skip3;stosb;stosb;jmp @l;@skip3:add di,2;@l:
        loop @kresli512
        jmp @hotovo
       {maze 1 caru sipky}
       @maz512:
        rep movsw
       @hotovo:
       {kdyztak nahodi dalsi bank}
       pop di
       add di,wrisir;jnc @nonewpage3;
         mov ax,mouseUPbank;inc ax;and ax,3;call VesaBank
         @nonewpage3:
     dec dx
     jnz @nextline

    {restore last bank}
     POP AX;call VesaBank


@99_DONE:
     popf
     end;

PROCEDURE GfxMouseOn; assembler;asm push 1;call mouse;mov mouseactive,1;end;
PROCEDURE GfxMouseOff;assembler;asm mov mouseactive,0;push 0;call mouse;end;

PROCEDURE AdjustMouse;assembler;
 asm
     cmp MousePresent,0;jz @9
    {nastaveni range M-x}
     mov ax,7;mov cx,0;
     mov dx,2*vissir-16;
     cmp VGA_MODE,1;jz @ok
     mov dx,2*wrisir-32;
     @ok:
     int 33h
    {nastaveni range M-y}
     mov ax,8;mov cx,0;mov dx,visvys-16;int 33h;
    {nastaveni citlivosti}
     call NastavCitlivostmysi

     @9:end;

PROCEDURE MoveMouse;
begin
 MoveMouseXpul(now.mousex,now.mousey);
end;

PROCEDURE NastavCitlivostmysi;
var i:word;
begin
 i:=1+round(80/(citlivostMysi+1));
 asm cmp MousePresent,0;jz @9
     mov cx,i;mov dx,cx;mov ax,0fh;int 33h;
     @9:end;
end;

PROCEDURE MouseShift(dy,dx:shortint);
var shift:byte;
begin
 asm
     mov al,mouseactive;push ax;mov mouseactive,0
     mov al,mouseflag;mov ah,0;push ax
     push 0;call mouse
     end;
 shift:=2+stillnumero div 10;
 if shift>6 then shift:=6;
 case dx of -1:if now.mousex>=shift then dec(now.mousex,shift);
             1:if now.mousex<vissir-8-shift then inc(now.mousex,shift);
             end;
 case dy of -1:if now.mousey>=2*shift then dec(now.mousey,2*shift);
             1:if now.mousey<visvys-16-2*shift then inc(now.mousey,2*shift);
             end;

 asm call movemouse
     call mouse;pop ax;mov mouseactive,al;end;
end;

PROCEDURE OneToggle(adr:word);assembler;
var bit:byte;
    mylastbank:word;
 asm
     mov si,adr
     mov di,[si]{nacte x4}
     mov ax,[si+2]{nacte y1}
     lea bx,anobitmap;cmp byte ptr [si+8],0{nacte stav};jnz @2;lea bx,nebitmap;@2:mov si,bx

{$ifdef setup}
     cmp setuping,0;jnz @setupano
{$endif}

@NORMALANO:{nakresli togglik do EMS}

     {naframuje podle ax=y1}
     shr ax,4;pusha;push ax;call reframe;popa;mov es,framewriseg

     add si,3
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

     {nabankuje podle ax=y1}
     push ax;shr ax,9;mov mylastbank,ax;call bank;pop ax

{     shl ax,7{wrisir/4;add di,ax;sub di,panelcentrx4;add di,wrisir/8{}
     shl ax,7{wrisir/4};mov di,ax;add di,panelcentrx4;sub di,14
     mov bit,0
     mov es,sega000
     mov dx,16
    @nextline:
     mov cx,12;
     push di
     @12:call near ptr @incbitsetbit;lodsb;mov [es:di],al;loop @12
     pop di;add di,wrisir/4;jnc @nonewpage;mov ax,mylastbank;inc ax;call bank;@nonewpage:
     dec dx;jnz @nextline
     jmp @99

{inc bit, set bit}
@incbitsetbit:
     push ax;push cx;push dx
     mov cl,bit;inc cx;cmp cl,4;jc @ouk;mov cl,0;inc di;@ouk:mov bit,cl
     mov ax,102h;shl ah,cl;mov dx,3c4h;out dx,ax
     pop dx;pop cx;pop ax
     retn
{$endif}

     @99:
     end;


PROCEDURE xorcursor(video:Boolean);{reframe ; xor cursor do ems i videopameti}
const xorcolor=askbackgroundcolor xor 16;
var i,local_x4,local_y16:word;
begin
 if now.nowask>0 then with now.askstring[now.nowask] do begin
   local_x4:=x4+2*now.nowaskx-2;
   local_y16:=y16;
   asm
     PUSHF;CLI
     mov ah,0;mov al,mouseflag;push ax;push 0;call mouse;
     push local_y16;call reframe;mov es,framewriseg
     mov di,15*wrisir/4;add di,local_x4;mov ax,257*4;mov cx,4;@1:xor word ptr [es:di],257*xorcolor;add di,wrisir*4;loop @1
     end;
   if video and (local_y16>=wriy) and (local_y16<=wriy+31){neni mimo obraz} then asm
     {nakrasli ten samej kurzor i do videopameti}
      mov ax,local_y16;shr ax,5;call bank
     {prepare es,di}
      mov es,sega000
      mov di,15*wrisir/4;add di,local_x4
      mov ax,4*wrisir;mul local_y16;add di,ax
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



PROCEDURE SetAndVisUpperPal(n:word;visualizeIt:byte);assembler;
 asm
     {cx=pocet bajtu k outu
      si=source}
     mov ax,n
     add ax,ax;add ax,offset now.paletofs-2;
     mov si,ax;lodsw;mov bx,ax;lodsw;sub ax,bx;mov cx,ax;mov si,bx
     mov es,paletseg

     cmp visualizeIt,0;jz @novisualize
     mov ax,cx;mov bl,3;div bl;neg al
     mov dx,3c8h;{mov al,0;sub ax,bx;}out dx,al;inc dx
     push cx
     push si
     @1:seges lodsb;out dx,al;loop @1{rep seges outsb}
     pop si{zacatek dat}
     pop cx{barev*3}
     @novisualize:

     mov di,offset pal+3*256;sub di,cx
     PUSH DS;mov ax,es;mov bx,ds;mov ds,ax;mov es,bx
     rep movsb        {ds(jinej)->es(old_ds)}
     POP ds
     end;


{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ KLAVESNICE ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}
PROCEDURE LightLocks;assembler;
 asm
{$ifdef dostran}
     cmp rozsvecetDiody,0;jz @end
     push 1;call refresh;mov dx,60h;mov al,0edh ;out dx,al
     push 1;call refresh;mov dx,60h;mov al,locks;out dx,al
     @end:
{$endif}
     end;

PROCEDURE InitKeyb;assembler;
 asm
{$ifdef dostran}
    cmp rozsvecetDiody,0;jz @skipit
    pushf;cli
   {nastavi promennou LOCKS}
    mov ah,2;int 16h;shr al,4;mov ah,al;and ah,1;mov oldscrollock,ah;and al,2+4
    test scrolllock,1;jz @nolock;inc al;@nolock:mov locks,al
   {rozsviti locky}
    call lightLocks
    popf
    @skipit:
{$endif}
    end;


{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ INCY ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}
PROCEDURE IncIntree;
begin
 if intree>=maxvnoreni then errorhalt(50+11);
 inc(intree);
end;

PROCEDURE IncTogglu;
begin
 with now do begin
   if local_togglu>=maxtogglu then errorhalt(50+0);
   inc(local_togglu);
   end;
end;

PROCEDURE IncAskstringu;
begin
 with now do begin
   if local_askstringu>=maxaskstringu then errorhalt(50+1);
   inc(local_askstringu);
   end;
end;

PROCEDURE IncButtonu;
begin
 with now do begin
   if local_buttonu>=maxbuttonu then errorhalt(50+2);
   inc(local_buttonu);
   end;
end;

PROCEDURE IncImuzik;
begin
 if import_muzik>=maxImuzik then errorhalt(50+14);
 inc(import_muzik);
end;

PROCEDURE IncLmuzik;
begin
 with now do begin
   if Lmuzik>=maxLmuzik then errorhalt(50+3);
   inc(Lmuzik);
   end;
end;

PROCEDURE IncDatafajlu;
begin
 if datafajlu>=maxdatafajlu then errorhalt(50+5);
 inc(datafajlu);
 fillchar(data[datafajlu],sizeof(Tdata),0);
end;



{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ SETUP ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}
{$ifdef setup}
VAR
      OfsofFrameInSetupbitmap:array[0..setupsize] of word;
      soupatkobuffer:array[0..soupatek,1..12*soupatkovys] of byte;


PROCEDURE ScanCentralFrames;
var   i,size:word;
      nowfram8kpiece,topfram8kpiece,topsrc,downsrc:word;
begin
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
end;

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

{$ifdef dostran}
   cmp viditelnychBanku,2;jnc @2stranky
{$endif}

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
   retn

{banking svislych car - souradnice se pocita podle CX}
@svislejbanking:
   push ax;mov ax,paneldowny;sub ax,cx;inc ax;shr ax,9;mov DS,oldDS;call bank;mov DS,frameseg;pop ax
   retn

{kresli jednu vodorovnou lajnu 2 pixely vysokou}
@vodorovnalajna_jednobarevna:
   call @incbitsetbit
   mov [es:di            ],al
   mov [es:di   +wrisir/4],al
   loop @vodorovnalajna_jednobarevna
   retn

{kresli jednu vodorovnou lajnu 2 pixely vysokou}
@vodorovnalajna_spozadim:
   call @incbitsetbit
   lodsw;mov [es:di            ],al
         mov [es:di   +wrisir/4],ah
   inc si;inc si
   loop @vodorovnalajna_spozadim
   retn


   @middle:
   or al,al;jnz @midb
   movsb;add di,wrisir/4-1;movsb;jmp @99
   @midb:mov [es:di],al;mov [es:di+wrisir/4],al

   @99:
   POP DS
   end;

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
     @12:call near ptr @incbitsetbit;mov al,[es:di];mov [bx],al;inc bx;lodsb;mov [es:di],al;loop @12
     pop di;add di,wrisir/4;jnc @nonewpage1;mov ax,mylastbank;inc ax;call bank;@nonewpage1:
     dec dx;jnz @kresliline
     jmp @99

    @maz:
     mov si,bx
     @mazline:
     mov cx,12;
     push di
     @13:call near ptr @incbitsetbit;lodsb;mov [es:di],al;loop @13
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
     retn

     @99:
     end;
{$endif}





{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ SKLAD ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}

TYPE
     TSkladDatalist=record
                        size                 :word;
                        typ                  :byte;{prvni vec pri porovnavani}
                        dm                   :byte;{druha vec pri porovnavani}
                        check_datafajlufilled:word;
                        dat                  :word;
                     end;

     TSkladAskyTogly=record
                        size                 :word;
                        typ                  :byte;{prvni vec pri porovnavani}
                        dm                   :byte;{druha vec pri porovnavani}
                        Dkod                 :word;{treti vec pri porovnavani}
                        asku                 :byte;
                        toglu                :byte;
                      end;

     TSkladMuzik=record
                        size                 :word;
                        typ                  :byte;{prvni vec pri porovnavani}
                        dm                   :byte;{druha vec pri porovnavani}
                        muzik                :word;
                 end;

     TSkladDminfo=record
                        size                 :word;
                        typ                  :byte;{prvni vec pri porovnavani}
                        dm                   :byte;{druha vec pri porovnavani}
                        filename             :stringpath;
                        datetime             :longint;
                        projekt              :string[30];
                        addonfor             :string[40];
                        flags                :word;
                        fajlu                :word;
                        popisek              :string[5];
                        filebazeofs          :longint;
                        firstfileofs         :longint;
                        addons               :byte;
                        addon                :array[0..maxaddons] of byte;
              end;

      PTSkladDatalist =^TSkladDatalist;
      PTSkladAskyTogly=^TSkladAskyTogly;
      PTSkladMuzik    =^TSkladMuzik;
      PTSkladDminfo   =^TSkladDminfo;

VAR   SkladOfs,SkladSeg  :word;
      SkladDatalist      :PTSkladDataList  absolute SkladOfs;
      SkladAskyTogly     :PTSkladAskyTogly absolute SkladOfs;
      SkladMuzik         :PTSkladMuzik     absolute SkladOfs;
      SkladDminfo        :PTSkladDminfo    absolute SkladOfs;
      SkladDminfo2       :PTSkladDminfo;
      KonecSkladu        :word;
      SkladSize          :word;
      datafajlufilled    :word;
      DmInfo             :TSkladDminfo;


PROCEDURE GotoEndOfSklad;
begin
 SkladDatalist:=ptr(frameseg,0);
 while SkladDatalist^.size>0 do inc(SkladOfs,SkladDatalist^.size);
end;

{do SkladOfs da offset hledane polozky}
FUNCTION SearchThingInSklad(whattyp,whatDM:byte;whatDkod:word):boolean;
var   hledanejtyp:byte;
      a:TSkladDatalist;{*}
      b:TSkladAskyTogly;
{      c:TSkladMuzik;}
label 1;
begin
 case whattyp of typSearchFirstAskytogly,typSearchNextAskytogly:hledanejtyp:=typAskytogly;
                 else hledanejtyp:=whattyp;
                 end;
 if whattyp<>typSearchNextAskytogly then SkladDatalist:=ptr(frameseg,0);
 1:
 with SkladAskyTogly^ do with SkladDatalist^ {do with SkladMuzik^} do begin
   a:=SkladDatalist^;{*}
   b:=SkladAskyTogly^;
{   c:=SkladMuzik^;}
   if size=0 then begin
     SearchThingInSklad:=false;exit;end;
   if (typ<>hledanejtyp) {neshoduje se typ}
    or ((dm<>whatDM) and (Dkod<>setup_Dkod)){neshoduje se DM (ignorovat pro setup)}
    or ((Dkod<>whatDkod) and (whattyp=typAskyTogly)){neshoduje se Dkod (delat jen pro askytogly)}
    then begin
     inc(SkladOfs,size);
     goto 1;
     end;
   if (whattyp=typDatalist) and (check_datafajlufilled<>datafajlufilled) then
     {asm nop;end;{*}errorhalt(23+1);{}
   end;
 SearchThingInSklad:=true;
end;

PROCEDURE CheckSkladSize(addsize:word);
begin
 if longint(SkladOfs)+addsize>65534 then errorhalt(23+2);
end;

{prida polozku na sklad pripadne prepise existujici,
 funkce vraci ofs zacatku teto polozky, skladofs nastavi na dalsi polozku}
FUNCTION AddThing2Sklad(whattyp:byte):word;
var   a:TSkladAskyTogly;{*}
var   izlast:boolean;
      firstofs:word;
begin
 Reframe2handle(skladhandle);
 if ((whattyp=typDatalist)  and (datafajlu=datafajlufilled))
 or ((whattyp=typAskyTogly) and (now.local_askstringu+now.local_togglu=0) {and (now.ank='')
                                                                          ..je zbytecny schovavat page bez asku/toglu})
{ or ((whattyp=typMuzik)     and (now.muzik=0)){*}
                                                 then exit;
 izlast:=not SearchThingInSklad(whattyp,nowDMreal{*was now.whichDM},now.Dkod);{kdyz nenajde, dojede na konec}
 firstofs:=SkladOfs;
 AddThing2Sklad:=SkladOfs;

 case whattyp of
 typDatalist:with SkladDatalist^ do begin
   {prihodi header, nejdriv checkne if dost mista}
   size:=sizeof(TSkladDatalist);
   CheckSkladSize(size);
   typ:=whattyp;
   dm:=nowDMreal;
   check_datafajlufilled:=datafajlufilled;
   dat:=datafajlu-datafajlufilled;
   inc(SkladOfs,size);
   {prihodi data, nejdriv checkne if dost mista}
   size:=dat*sizeof(tdata);
   CheckSkladSize(size);
   move(data[datafajlufilled+1],SkladDatalist^,size);
   inc(SkladOfs,size);
   {nastavi vlastni size, pripadne resetne nasledujici size}
   size:=SkladOfs-firstofs;
   if izlast then SkladDatalist^.size:=0;
   end;
 typAskyTogly:with SkladAskyTogly^ do begin
   a:=SkladAskyTogly^;{*}
   {prihodi header, nejdriv checkne if dost mista}
   size:=sizeof(TSkladAskyTogly);
   CheckSkladSize(size);
   typ:=whattyp;
   {if now.Dkod=setup_Dkod then dm:=0 else} dm:=nowDMreal;
   Dkod:=now.Dkod;
   asku:=now.local_askstringu;
   toglu:=now.local_togglu;
   inc(SkladOfs,size);

   {prihodi ankname, nejdriv checkne if dost mista}
   size:=length(now.ank)+1;
   CheckSkladSize(size);
   move(now.ank,SkladAskyTogly^,size);
   inc(SkladOfs,size);

   {prihodi asky, nejdriv checkne if dost mista}
   size:=asku*sizeof(Taskstring);
   CheckSkladSize(size);
   move(now.askstring,SkladAskyTogly^,size);
   inc(SkladOfs,size);
   {prihodi togly, nejdriv checkne if dost mista}
   size:=toglu*sizeof(Ttoggle);
   CheckSkladSize(size);
   move(now.toggle,SkladAskyTogly^,size);
   inc(SkladOfs,size);
   {nastavi vlastni size, pripadne resetne nasledujici size}
   size:=SkladOfs-firstofs;
   if izlast then SkladAskyTogly^.size:=0;
   end;
 typDminfo:with SkladDminfo^ do begin
   {prihodi se na sklad, nejdriv checkne if dost mista}
   size:=sizeof(TSkladDminfo);
   CheckSkladSize(size);
   move(Dminfo,SkladDminfo^,size);
   inc(SkladOfs,size);
   {pripadne resetne nasledujici size}
   if izlast then SkladAskyTogly^.size:=0;
   end;
 else
   errorhalt(23+3);
 end;
end;

FUNCTION ReadThingFromSklad(whattyp,whatDM:byte;whatDkod:word):boolean;
var   i:word;
label 1;
begin
 ReadThingFromSklad:=false;
 Reframe2handle(skladhandle);
 if not SearchThingInSklad(whattyp,whatDM,whatDkod) then exit;
 ReadThingFromSklad:=true;

 case whattyp of
 typDatalist:with SkladDatalist^ do begin
   {nacte header a poskoci}
   inc(datafajlu,dat);
   inc(SkladDatalist);{preskoci z headeru na zacatek dat}
   {nacte data a poskoci}
   move(SkladDatalist^{zacatek dat},data[datafajlu+1-dat],dat*sizeof(tdata));
   inc(SkladOfs,dat*sizeof(tdata));
   {delete it from sklad}
   move(SkladDatalist^{nasledujici polozka},size{tato polozka},65535-SkladOfs-Size);
   end;
 typAskyTogly:with SkladAskyTogly^ do begin
   {nacte header a poskoci}
   now.local_askstringu:=asku;
   now.local_togglu    :=toglu;
   inc(SkladAskyTogly);{preskoci z headeru na zacatek dat}

   {nacte now.ank a poskoci}
   move(SkladAskyTogly^{zacatek dat},now.ank,13);
   inc(SkladOfs,length(now.ank)+1);

   {nacte togly a poskoci}
   move(SkladAskyTogly^{zacatek dat},now.askstring,asku*sizeof(Taskstring));
   inc(SkladOfs,asku*sizeof(Taskstring));
   {nacte asky a poskoci}
   move(SkladAskyTogly^{zacatek dat},now.toggle,toglu*sizeof(Ttoggle));
   inc(SkladOfs,toglu*sizeof(Ttoggle));
   end;
 (*
 typMuziky:with SkladMuzik^ do begin
   {nacte header a poskoci}
   now.muzik:=muzik;
   inc(SkladMuzik);{preskoci z headeru na zacatek dat}
   {nacte togly a poskoci}
   move(SkladMuzik^{zacatek dat},now.muziky,muzik*sizeof(Tmuzika));
   inc(SkladOfs,asku*sizeof(Taskstring));
   {delete it from sklad}
   move(mem[frameseg:SkladOfs+Size]{nasledujici polozka},size{zacatek teto polozky},65535-SkladOfs-Size);
   end;
 *)
 typDminfo:Dminfo:=SkladDminfo^;
 else
   errorhalt(23+0);
 end;
end;

PROCEDURE UlozKonecSkladu;
begin
 Reframe2handle(skladhandle);
 GotoEndOfSklad;
 KonecSkladu:=SkladOfs;
end;

PROCEDURE ObnovKonecSkladu;
begin
 Reframe2handle(skladhandle);
 SkladOfs:=KonecSkladu;
 SkladSize:=KonecSkladu;
 SkladDatalist^.size:=0;
end;

PROCEDURE ScanSklad;
var   i:word;
begin
writeln;
if skladhandle=0 then writeln('sklad neotevren') else begin
 writeln('---SKLAD---');
 Reframe2handle(skladhandle);
 SkladDatalist:=ptr(frameseg,0);
 while SkladDatalist^.size>0 do with SkladDatalist^ do begin
   case typ of
   typDatalist:writeln('Datalist: ofs=',skladofs,' size=',size,' dm=',dm,' check_datafajlufilled=',check_datafajlufilled,
                  ' dat=',dat);
   typAskyTogly:with SkladAskyTogly^ do
          writeln('AskyTogly: ofs=',skladofs,' size=',size,' dm=',dm,' Dkod=',Dkod,' asku=',asku,' toglu=',toglu,
               ' ank=',StringPtr(SkladSeg,SkladOfs+sizeof(TSkladAskyTogly)));
{   typMuziky:with SkladMuzik^ do
       writeln('AskyTogly: ofs=',skladofs,' size=',size,' dm=',dm,' muzik=',muzik);}
   typDminfo:with SkladDminfo^ do
             writeln('Dminfo: ofs=',skladofs,' size=',size,' dm=',dm,' file=',filename,' name=',projekt{,
                    ' ank=',ankname,' ankDkod=',ankDkod});
   else
     errorhalt(23+6);
   end;
   inc(SkladOfs,size);
   end;
 end;
end;



{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ DM ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}
CONST
      buttsir      =65;
      buttvys      =56;


VAR
      DMs                :byte;
      DMroots            :byte;
      DmRoot             :array[1..maxDMs] of byte;

      bighandlu          :word;
      bighandl           :array[1..maxbighandlu] of word;

      exehand            :word;
      exeleng            :longint;

      firstrealDM        :byte;

PROCEDURE InitDataFile;assembler;{nastavi cestaKexe; pokusi se zjistit handle a offset common.dm}
var   pathstart,pathend,pathseg,realDS:word;
      freespace:array[1..3] of word;
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
    mov ax,3d00h;mov dx,pathstart;int 21h{;jnc @openedRO
    push 5;call errorhalt;
    @openedRO:                            }
    mov DS,realDS
    mov exehand,ax
   {read exe header - 6 bytes}
    mov bx,exehand;mov cx,6;lea dx,freespace;mov ah,3fh;push ss;pop ds;int 21h;mov DS,realDS
   {pocita dylku exe fajlu}
    mov ax,word ptr freespace+4;dec ax;shl ax,1;mov bh,0;mov bl,ah;shl ax,8
    mov cx,word ptr freespace+2;add ax,cx;or cx,cx;jnz @zz;add ax,512;adc bx,0;@zz:
    mov word ptr exeleng,ax;mov word ptr exeleng+2,bx
(*
   {seek and read form exeend+6 to check appended data}
    mov cx,bx;mov dx,ax;mov ax,4201h{relative};mov bx,exehand;
    int 21h;jc @no_exedata_found{kdyz seek uz dal nejede}
    mov bx,exehand;mov cx,1;lea dx,freespace;mov ah,3fh;
    int 21h;jc @no_exedata_found{kdyz read uz nereadne}
    or ax,ax;jnz @exedata_found;{kdyz read precet 0}

     {close exe, no data found}
     @no_exedata_found:
     mov ah,3eh;mov bx,exehand;int 21h
     xor ax,ax;mov word ptr exeleng,ax;mov word ptr exeleng+2,ax;mov exehand,ax
    {open data fajl self.DM}
     mov DS,pathseg;mov si,pathend;dec si;dec si;mov byte ptr [si],0;dec si;dec si;mov word ptr [si],'MD'
     mov ax,3d00h;mov dx,pathstart;int 21h
     jnc @ok
     push 19;call errorhalt
     @ok:
     mov DS,realDS
     jc @opened
     mov exehand,ax
     @opened:

    @exedata_found:        (**)
    end;


FUNCTION OpenDataFile(st:string):boolean;
var i:word;
label foundInData;
begin
 OpenDataFile:=true;
 upcasestring(@st);
 for i:=1 to datafajlu do if data[i].name=st then goto foundInData;

 {neni-li soubor nalezen ani ve filebazi ani na disku -> exit}
 if not sluzby.openDataFile(st) then begin OpenDataFile:=false;exit;end;

 {jednotlivy soubor nalezen na disku -> zalozeni nove polozky data}
 incDatafajlu;
 with data[datafajlu] do begin
   name:=st;
   handle:=datahandle;
   start:=0;
   len:=LengthDataFile;
{   status:=0;}
   lastopenLength:=len;
   end;
 exit;

 {soubor nalezen ve filebazi}
 foundInData:
 with data[i] do begin
   {je ve filebazi ale neni otevren -> otevru ho}
   if handle=0 then begin
      if not sluzby.openDataFile(st) then begin asm mov ax,3;int 10h;end;errorhalt(47);end;
      handle:=datahandle;
      end
    {je ve filebazi a je otevren -> seeknu}
    else begin
      datahandle:=handle;
      Sluzby.SeekDataFileFromStart(start);
      end;
   lastopenLength:=len;
   end;
end;


FUNCTION CloseDataFile:boolean;
var i:word;
begin
 for i:=1 to bighandlu do if datahandle=bighandl[i] then begin
   CloseDataFile:=true;
   exit;
   end;
 CloseDataFile:=sluzby.CloseDataFile;
 for i:=1 to datafajlu do with data[i] do if handle=datahandle then handle:=0;
end;

PROCEDURE SaveAnketa(midasSDnumber:integer);
var   i,j:byte;
      found:boolean;
      save,save_full,ank_Dkod,w,DMw,SkladOfsBak:word;
      fajl:stringpath;
      now_ank:string[12];
      st:string;
      f:text;
label zaCloseThis,cantwrite,cantwritelocal;
begin
 if readonly then goto cantwrite;
 for w:=1 to DMroots do begin
  DMw:=DMroot[w];
  ReadThingFromSklad(typDminfo,DMw,0{cokoliv});
  with DMinfo do repeat

   now_ank:='';
   save_full:=0;
   save:=0;
   {zkusi najit prvni page s asktoglama v tomhle DM}
   found:=SearchThingInSklad(typSearchFirstAskyTogly,DMw,0{cokoliv});
   while found do begin
    ank_Dkod:=SkladAskyTogly^.Dkod;
    {nareaduje jednu page tohoto anklistku}
    ReadThingFromSklad(typAskyTogly,DMw,ank_Dkod);
    if (now.ank>'') and (now.ank[1]<>' ') and ((now_ank='') or (now_ank=now.ank)) then begin
      now_ank:=now.ank;
      {spocita kolik procent z askutoglu bylo zaskrtano}
      for i:=1 to now.local_togglu     do with now.toggle[i]    do begin
        if stav<>0 then inc(save,7);
        inc(save_full,7);
        end;
      for i:=1 to now.local_askstringu do with now.askstring[i] do begin
        for j:=1 to znaku do if stav[j]>#0 then inc(save);
        inc(save_full,znaku);
        end;
      end;
    {zkusi najit dalsi page s asktoglama v tomhle DM}
    found:=SearchThingInSklad(typSearchNextAskyTogly,DMw,0{cokoliv});
    end;


   if save>0{(save>20) or (save>save_full div 4)} then save:=1 else save:=0;

   if save=1 then begin
     {otevre ank.listek a zapise header}
     fajl:=workDir+now_ank;
     for i:=1 to length(fajl) do if fajl[i]='?' then fajl[i]:=chr(48+random(10));
     write('Ukl†d†m anketn° l°stek ',fajl,' ... ');
     if readonly then begin
       writeln('Z†pis na disk potlaáen £vodn°m nastaven°m!');
       goto zaCloseThis;
       end;
     assign(f,fajl);
     rewrite(f);
     if ioresult>0 then goto cantwritelocal;
     writeln(f,'Anketn° l°stek*',verze,'*',projekt,'*',fajl,'*',
             chr(48+mem[seg(VesaBanku):ofs(VesaBanku)]),
             '*',chr(48+midasSDnumber)
             {$ifdef dostran},'*',chr(48+viditelnychbanku),'*',vgadriver{$endif});
     end;

   {zkusi najit prvni page s asktoglama v tomhle DM}
   found:=SearchThingInSklad(typSearchFirstAskyTogly,DMw,0{cokoliv});

   while found do begin
     ank_Dkod:=SkladAskyTogly^.Dkod;
     SkladOfsBak:=SkladOfs;
     {nareaduje jednu page tohoto anklistku}
     ReadThingFromSklad(typAskyTogly,DMw,ank_Dkod);
     if now.ank=now_ank then begin
       {oznaci page na sklade za sejvnutou... ank[1]:=' '}
       mem[SkladSeg:SkladOfsBak+sizeof(TSkladAskyTogly)+1]:=32;
       {kdyz ma, sejvne data z tyhle page}
       if save=1 then begin
         writeln(f,'[PAGE=',data[ank_Dkod].name,']');
         for i:=1 to now.local_togglu     do with now.toggle[i]    do write(f,chr(48+stav));writeln(f);
         for i:=1 to now.local_askstringu do with now.askstring[i] do begin
           st[0]:=chr(znaku);
           move(stav,st[1],znaku);
           while (st>'') and ((st[1]=#0) or (st[1]=' ')) do delete(st,1,1);
           while (st>'') and ((st[length(st)]=#0) or (st[1]=' ')) do dec(st[0]);
           writeln(f,st);
           end;
         end;
       end;
     {zkusi najit dalse page s asktoglama v tomhle DM}
     found:=SearchThingInSklad(typSearchNextAskyTogly,DMw,0{cokoliv});
     end;

   if save=1 then begin
     if ioresult>0 then goto cantwritelocal;
     close(f);
     if ioresult>0 then goto cantwritelocal;
     writeln('OK');
     goto zaCloseThis;
     cantwritelocal:
     writeln('Nelze ps†t na disk!');
     zaCloseThis:
     end;

   until now_ank='';
  end;
 cantwrite:
(*
  with DMinfo do if ankname>'' then begin
   ReadThingFromSklad(typAskyTogly,DMw,ankDkod);
   {spocita kolik procent z askutoglu bylo zaskrtano}
   save_full:=0;
   save:=0;
   for i:=1 to now.local_togglu     do with now.toggle[i]    do begin
     if stav<>0 then inc(save,7);
     inc(save_full,7);
     end;
   for i:=1 to now.local_askstringu do with now.askstring[i] do begin
     for j:=1 to znaku do if stav[j]>#0 then inc(save);
     inc(save_full,znaku);
     end;
   {kdyz dost, sejvne to}
   if (save>20) or (save>save_full div 4) then begin
     fajl:=workDir+ankname;
     for i:=1 to length(fajl) do if fajl[i]='?' then fajl[i]:=chr(48+random(10));
     write('Ukl†d†m anketn° l°stek ',fajl,' ... ');
     if readonly then writeln('Z†pis na disk potlaáen £vodn°m nastaven°m!') else begin
       assign(f,fajl);
       rewrite(f);
       if ioresult>0 then goto cantwritelocal;
       writeln(f,'Anketn° l°stek*',verze,'*',projekt,'*',fajl,'*',
               chr(48+mem[seg(VesaBanku):ofs(VesaBanku)]),
               '*',chr(48+midasSDnumber)
               {$ifdef dostran},'*',chr(48+viditelnychbanku),'*',vgadriver{$endif});
       for i:=1 to now.local_togglu     do with now.toggle[i]    do write(f,chr(48+stav));writeln(f);
       for i:=1 to now.local_askstringu do with now.askstring[i] do begin
         st[0]:=chr(znaku);
         move(stav,st[1],znaku);
         while (st>'') and ((st[1]=#0) or (st[1]=' ')) do delete(st,1,1);
         while (st>'') and ((st[length(st)]=#0) or (st[1]=' ')) do dec(st[0]);
         writeln(f,st);
         end;
       if ioresult>0 then goto cantwritelocal;
       close(f);
       if ioresult>0 then goto cantwritelocal;
       writeln('OK');
       goto 1;
       cantwritelocal:
       writeln('Nelze ps†t na disk!');
       1:
       end;
     end;
   end;
  end;
 cantwrite:
*)
end;

FUNCTION  Rip(ripDkod:word):boolean;
var   zbyvalen:longint;
      nowlen,hendl,saveofs1,saveofs2,colors3,i:word;
      ripname0:string;
      p:pointer;
label inbig,quit,quitbezclose;
begin
 rip:=false;
 if readonly then goto quitbezclose;
 with data[ripDkod] do begin
  ripname0:=workdir+name+#0;
  zbyvalen:=len;
  nowlen:=65535;
  if not DM.opendatafile(Name) then goto quitbezclose;
  for i:=1 to bighandlu do if bighandl[i]=datahandle then goto inbig;
  goto quit;
  inbig:
  p:=@ripname0[1];
  asm
  {open dest}
   push ds
   mov ax,3c00h;mov cx,0;mov dx,word ptr p;mov ds,word ptr p+2;int 21h;mov hendl,ax;
   pop ds
   jc quit
  end;
  {sejvnuti}
  repeat
    if nowlen>zbyvalen then nowlen:=zbyvalen;
    readdatafile(nowlen,0,workseg);
    asm
    {write data}
     mov bx,hendl;mov dx,0;mov cx,nowlen
     push ds;mov ds,workseg;mov ah,40h;int 21h;pop ds;jc quit
    end;
    dec(zbyvalen,nowlen);
  until zbyvalen=0;
  asm
  {close dest}
   mov bx,hendl;mov ah,3eh;int 21h;jc quit
  end;
  rip:=true;
  end;
 quit:
 DM.CloseDataFile;
 quitbezclose:
end;


FUNCTION GetDkod(filename:string;errorifnotfound:boolean):word;
var i:word;
begin
 UpCaseString(@filename);
 if filename=''       then begin getDkod:=0;exit;end;
 if filename=setup_fl then begin getDkod:=setup_Dkod;exit;end;
 {if filename=rip_fl   then begin getDkod:=rip_Dkod;exit;end;}
 for i:=1 to datafajlu do if data[i].name=filename then begin getDkod:=i;exit;end;
 DM.opendatafile(filename);
 DM.closedatafile;
 for i:=1 to datafajlu do if data[i].name=filename then begin getDkod:=i;exit;end;
 if errorifnotfound then begin errorfile:=filename;errorhalt(14);end else getDkod:=0;
end;


{ze syntaxe typu nejm='.bleble.x(150,95)' vykope
  nejm='bleble.x'
  xx=75
  yy=47
  doublescan=1
  doublex=1
 if truly=true -> koukne i na disk a vrati presny cislo jinak to falsuje na 320x200
  }
PROCEDURE GetPicSize(truly,roznasobit:boolean;var st:string;var xx,yy:word);
var i,j:word;
    siz:string;
    hedr4:array[1..2] of word;
label ex,nezkracovat;
begin
 {$ifdef flipir}
 if pos('.fli',nejm)>0 then begin xx:=0;exit;end;
 {$endif}

 case st[1] of '-':begin doublescan:=1;doublex:=2;end;
               '›':begin doublescan:=4;doublex:=2;end;
               '.':begin doublescan:=1;doublex:=1;end;
               '€':begin doublescan:=4;doublex:=4;end;
               '|':begin doublescan:=2;doublex:=1;end;
               '‹':begin doublescan:=2;doublex:=4;end;
              else begin doublescan:=2;doublex:=2;goto nezkracovat;end;
              end;
 delete(st,1,1);
 nezkracovat:

 j:=pos('(',st);
 if j=0 then begin
   xx:=320;
   yy:=200;
   if truly then if DM.opendatafile(st) then begin
     ReadDataFile(4,ofs(hedr4),seg(hedr4));
     DM.CloseDataFile;
     xx:=hedr4[1];
     yy:=hedr4[2];
     end;
   end
  else begin
   siz:=copy(st,j+1,length(st)-j-1);
   st:=copy(st,1,j-1);
   CutNumberFromString(',',siz,xx);
   CutNumberFromString(')',siz,yy);
   end;

{tohle jen na pozadani}
 if roznasobit then begin
   xx:=xx*doublex div 2;
   yy:=yy*doublescan;
   end;

 if not truly then begin
   if xx<20 then xx:=20;
   if yy<20 then yy:=20;
   end;
end;



PROCEDURE ScanAllDMs;
var
      DmSkladOfs:array[1..maxDMs] of word;
      dirinfo   :SearchRec;

procedure incDMs;
begin
 {if DMs<maxDMs then inc(DMs) else errorhalt(50+8);
 fillchar(DMinfo[DMs],sizeof(TDMinfo),0);
 }
 if DMs>0 then DmSkladOfs[DMs]:=AddThing2Sklad(typDminfo);{sejvne predchozi DMinfo}
 inc(DMs);
 fillchar(Dminfo,sizeof(TSkladDminfo),0);
 with DMinfo do begin
   size:=sizeof(TSkladDminfo);
   typ:=typDminfo;
   DM:=DMs;
   end;
end;

procedure incDMroots;
begin
 inc(DMroots);
 DMroot[DMroots]:=DMs;
end;

procedure GetInfoFromDMstring(st:string);
var   i,j      :word;
      root     :boolean;
      uvozovky :array[1..4] of byte;
label badDM,goodDM;
begin
 if copy(st,1,length(headfirst))<>headfirst then goto badDM;
 if copy(st,1+length(headfirst),3)>verze then goto badDM;
 if copy(st,1+length(headfirst)+length(verze)+length(headbreak),length(headroot ))=headroot  then root:=true
 else
 if copy(st,1+length(headfirst)+length(verze)+length(headbreak),length(headaddon))=headaddon then root:=false
 else
 goto badDM;
 j:=0;
 for i:=1 to 255 do case st[i] of #0:break;
                                 '"':begin inc(j);uvozovky[j]:=i;end;
                                 end;
 if (root and (j<>2)) or (not root and (j<>4)) then goto badDM;
 incDMs;
 with dminfo do begin
   projekt:=                  copy(st,uvozovky[1]+1,uvozovky[2]-uvozovky[1]-1);
   if not root then addonfor:=copy(st,uvozovky[3]+1,uvozovky[4]-uvozovky[3]-1);
   i:=0;repeat inc(i) until st[i]=#0;inc(i);
   firstfileofs:=word(memw[seg(st):ofs(st[i])]);inc(i,2);
   flags       :=word(memw[seg(st):ofs(st[i])]);inc(i,2);
   fajlu       :=word(memw[seg(st):ofs(st[i])]);inc(i,2);
   popisek[0]:=st[i];for j:=1 to length(popisek) do popisek[j]:=st[i+j];inc(i,length(popisek)+1);
   filebazeofs:=i;
   if root then incDMroots;
   end;
 badDM:
end;

procedure DoItWithDirinfo(path:stringpath);
var   st:string;
begin
 with dirinfo do begin
   sluzby.opendatafile(path+name);
   readdatafile(255,ofs(st)+1,seg(st));
   sluzby.closedatafile;
   st[0]:=#255;
   GetInfoFromDMstring(st);
   with dminfo do begin
     filename:=path+name;
     datetime:=time;
     end;
   end;
end;

var   i,j       :word;
      st        :string;
label skip;

Begin
 st[0]:=#255;
 DMs:=0;
 if debuginfo then writeln('ExeLeng=',dm.exeleng);

 {prihodi butt doc - interni DM za exe}
 datahandle:=exehand;
 sluzby.seekdatafileFromStart(exeleng);
 if readdatafile(255,ofs(st)+1,seg(st))=255 then begin
   GetInfoFromDMstring(st);
   inc(dminfo.filebazeofs,exeleng);
   inc(dminfo.firstfileofs,exeleng);
   end
  else begin
   {nenasel nic pripojeny za exe, zkusi najit samotnej diskmag.dm}
   sluzby.closedatafile;
   exehand:=0;
   if jsemVeditoru then findfirst(commonEdDM,anyfile-directory,dirinfo)
                   else findfirst(commonDM  ,anyfile-directory,dirinfo);
   if doserror>0 then errorhalt(19);
   DoItWithDirinfo(curdir);
   end;

 {prihodi butt setup}
 incDMs;
 incDMroots;
 with Dminfo do begin
{   filename    :='';
   datetime    :=0;
   addonfor    :='';
   flags       :=0;}
   projekt     :='Setup';
   popisek     :='?';
   end;

 {prihodi butt quit}
 incDMs;
 incDMroots;
 with Dminfo do begin
{   filename    :='';
   datetime    :=0;
   addonfor    :='';
   flags       :=0;}
   if jsemVeditoru then begin
     projekt     :='do Editoru';
     popisek     :='Ed';
     end
   else begin
     projekt     :='N†vrat do OS';
     popisek     :='OS';
     end;
   end;


 {prihodi nezkompilovanej projekt}
 findfirst(title,anyfile-directory,dirinfo);
 if doserror=0 then begin
   incDMs;
   incDMroots;
   with dminfo do with dirinfo do begin
     filename    :=name;
     datetime    :=time;
     projekt     :='Nezkompilov†no';
{     addonfor    :='';
     flags       :=0;}
     popisek     :='...';
     end;
   end;

 firstrealDM   :=DMs+1;

 for i:=1 to 4 do begin
   case i of 1:begin st:=curdir;end;
             2:begin st:=cestaKexe;if st=curdir then goto skip;end;
             3:begin st:=curworkdir;if (st=curdir) or (st=cestaKexe) then goto skip;end;
             4:begin st:=workdir;if (st=curdir) or (st=cestaKexe) or (st=curworkdir) then goto skip;end;
             end;
   if debuginfo then writeln('Hledam DMs v ',st);
   {dalsi polozky - zkompilovany veci}
   findfirst(st+'*.dm',anyfile-directory,dirinfo);
   while doserror=0 do with dirinfo do begin
     if (name<>commonDM) and (name<>commonEdDM) then DoItWithDirinfo(st);
     findnext(dirinfo);
     end;
   skip:
   end;

 incDMs;{ulozi posledni dosud nesejvnuty DMinfo}
 dec(DMs);

 {zjisti co k cemu patri}
 for i:=1 to DMs do begin
   SkladOfs:=DmSkladOfs[i];
   for j:=1 to DMs do begin
     SkladDminfo2:=ptr(frameseg,DmSkladOfs[j]);
     with SkladDminfo2^ do if XjeprvkemY(projekt,SkladDminfo^.addonfor) then begin
       if addons>=maxaddons then errorhalt(50+12);
       inc(addons);
       addon[addons]:=i;
       end;
     end;
   end;
End;



PROCEDURE FillFilebazeWith(n:byte);
var   inbuf       :word;
      buffer      :array[0..maxfilelistsize] of byte;

function GetByte:byte;
begin
 if inbuf=maxfilelistsize then errorhalt(100+2);
 getbyte:=(byte(buffer[inbuf]+256-39)) xor buffer[inbuf-1];
 inc(inbuf);
end;

procedure AddMod2Filebaze(what:string);
var   dirinfo  :SearchRec;
      i:word;
begin
 findfirst(what,anyfile-directory,dirinfo);
 while doserror=0 do begin
   IncDatafajlu;
   with data[datafajlu] do begin
     fillchar(data[datafajlu],sizeof(tdata),0);
     name:=dirinfo.name;
     for i:=1 to datafajlu-1 do if data[i].name=name then begin
       data[i]:=data[datafajlu];
       dec(datafajlu);
       end;
     end;
   incImuzik;
   import_muziky[import_muzik].Dkod:=datafajlu;
   findnext(dirinfo);
   end;
end;

var   dmold,dmold1:byte;
      i,j         :word;
      ofsinDM     :longint;
      dm          :byte;

label adds,yetloaded,delThatNew,foundThatDm;
begin
 dmold:=nowDMreal;
 if (n=0) or (n>DMs) then errorhalt(22);
 if nowDMreal=n then exit;
 AddThing2Sklad(typDatalist);
 nowDMreal:=n;

 {----releasne filebazi (a bighandly) krome furtfajlu (zaexe & moduly)-------}
 datafajlu:=furtfajlu;
 for i:=furtbighandlu+1 to bighandlu do begin datahandle:=bighandl[i];sluzby.closedatafile;bighandlu:=furtbighandlu;end;

 if ((n<>1) and (n<firstrealDM)) or ((n=1) and (furtfajlu>0)) then goto adds;

 {--------nacist filelisty ze vsech aktualnich *.DM---------}
 {do SkladDminfo2 si pripravi offset zakladniho DM zaexe}
 if not SearchThingInSklad(typDminfo,selfDM,0{cokoliv}) then errorhalt(23+4);
 SkladDminfo2:=SkladDminfo;
 {do dminfo nacte prave loadovanej root}
 ReadThingFromSklad(typDminfo,n,0{cokoliv});
 DMinfo.addon[0]:=n;
 for dm:=0 to DMinfo.addons do begin
  {do SkladDminfo da loadovanej addon}
  SearchThingInSklad(typDminfo,DMinfo.addon[dm],0{cokoliv});
  with SkladDminfo^ do begin
   {otestuje jestli addon k loadovanymu rootu neni taky addon k selfDM}
   for i:=1 to SkladDminfo2^.addons do if SkladDminfo2^.addon[i]=DMinfo.addon[dm] then goto yetloaded;

   if (n=1) and (exehand>0) then datahandle:=exehand else sluzby.opendatafile(filename);
   if bighandlu<maxbighandlu then begin inc(bighandlu);bighandl[bighandlu]:=datahandle;end else errorhalt(50+6);
   seekdatafileFromStart(filebazeofs-1);{skip headstuff}
   i:=word(firstfileofs-filebazeofs+3){bez +3 to pada};
   if i>maxfilelistsize then errorhalt(50+7);
   readdatafile(i,ofs(buffer),seg(buffer));{read filelist}
   ofsinDM:=firstfileofs;
   inbuf:=1;
   for i:=1 to fajlu do begin
     IncDatafajlu;
     with data[datafajlu] do begin
       fillchar(data[datafajlu],sizeof(tdata),0);
       name[0]:=chr(getbyte);
       for j:=1 to ord(name[0]) do name[j]:=chr(getbyte);
       start:=ofsinDM;
       len:=longint(getbyte)+longint(getbyte) shl 8+longint(getbyte) shl 16;
       inc(ofsinDM,len);
       handle:=datahandle;
       {kdyz je vse nacteno, vykilluje starsi verze duplicitnich fajlu}
       for j:=1 to datafajlu-1 do if data[j].name=name then begin
         {najde v seznamu aktualnich dm kolikatej tam je balik s oldfile}
         for dmold1:=1 to bighandlu do if bighandl[dmold1]=data[j].handle then goto foundThatDm;
         goto delThatNew;{kdyz je starej fajl alonefile, smaze novej z DM}
         foundThatDm:
         {vezme globalni cislo dm ze seznamu aktualnich dm}
         dmold:=dminfo.addon[dmold];
         {porovna casy dminfo[dmold].datetime a datetime}
         asm push SkladOfs;end;
         SearchThingInSklad(typDminfo,dmold,0{cokoliv});
         if SkladDminfo^.datetime<=datetime then data[j]:=data[datafajlu];
         asm pop SkladOfs;end;
         {posledni data umazne v kazdym pripade, jeden ze dvou fajlu zmizi}
         delThatNew:
         fillchar(data[datafajlu],sizeof(tdata),0);
         dec(datafajlu);
         end;
       end;
     end;
   yetloaded:
   end;
  end;
 {*----hledat novejsi soubory, prohledavat i pridruzeny adresare, moznost vypnout vyhledavani----}
                       (*
 {----naplnit DMinfo.Dkodysamplu----}
 with newsample do begin
  for j:=1 to exesamplu do
   for i:=datafajlu downto 1 do with data[i].name do if name=exesampl[j] then begin
     leng:=len;
     Dkod:=i;
     break;
     end;
  for j:=1 to exesamplu do
    DM.opendatafile(exe


 {*----otestovat zda se s timto DM meni zakladni sada samplu----}
 for j:=1 to exesamplu do
  for i:=furtfajlu+1 to datafajlu do with data[i].name do

   if exesampl[j]=name then begin{kdyz je nalezena novejsi verze samplu}

     if sampluloaded=exesamplu then begin{kdyz jsou vsechny naloudeny a tenhle se ma menit}
       {releasne convmem}
       CONVbigfontDone;
       {releasne vrchni samply, spodni necha original}
       for k:=exesamplu downto j do releasesample(k);
       {loadne zmeneny sampl podle jeho Dkodu}
       loadsample(i);
       end
     else
     if sampluloaded then begin{kdyz je loadnuta jen cast a tenhle se ma menit}
       end
     end

   else{kdyz se sampl nema menit}

     {kdyz je potreba loadnout original}
     if sampluloaded<exesamplu then loadsample(exesampl[j]);
                         *)

 {----hledat pridanou hudbu, prohledavat i pridruzeny adresare, moznost vypnout vyhledavani----}
 if (n=1) and (furtfajlu=0) then begin
   addmod2filebaze('*.mtm');
   addmod2filebaze('*.s3m');
   addmod2filebaze('*.mod');
   addmod2filebaze('*.drv');
   furtfajlu:=datafajlu;
   furtbighandlu:=bighandlu;
   end;


 {natahne pripadnou prubezne objevenou drobotinu ze skladu}
 adds:
 datafajlufilled:=datafajlu;
 ReadThingFromSklad(typDatalist,n,0{cokoliv});
end;


PROCEDURE ShowButts;
const mez=10;
      vedle=4;
      dol=19;
      tmavejkraj=22;
      svetlejkraj=24;

procedure putbutt(dm:shortint;x,y:word);
var   i,j,k,l:word;
begin
 l:=23;
 if not SearchThingInSklad(typDminfo,dm,0{cokoliv}) then
  errorhalt(23+5);
 with SkladDminfo^ do begin
   if (dm=nowDMreal) and (intree>1) then k:=18 else k:=20;
   for j:=0 to buttvys-1 do begin
     if (j<=2) or (j>=buttvys-2-15) then i:=l else i:=k;
     fillchar(mem[workseg:wrisir*(j+dol)],buttsir,i);
     mem[workseg:wrisir*(j+dol)          ]:=l;
     mem[workseg:wrisir*(j+dol)+buttsir-1]:=l;
     end;
   fillchar(mem[workseg:wrisir*(dol-1        )-1],buttsir+2,tmavejkraj);
   fillchar(mem[workseg:wrisir*(dol+buttvys  )-1],buttsir+2,tmavejkraj);
   fillchar(mem[workseg:wrisir*(dol+buttvys+1)-1],buttsir+2,tmavejkraj);
   InsertBardString(15,workseg,buttsir div 2,0             ,popisek,j,j);
   InsertMiniString(24,workseg,buttsir div 2,dol+buttvys-16,@projekt);
   for j:=0 to buttvys-1 do begin
     mem[workseg:wrisir*(j+dol)-1      ]:=tmavejkraj;
     mem[workseg:wrisir*(j+dol)+buttsir]:=svetlejkraj;
     end;
   Bitmap2Screen1(wrisir,workseg,65536-1,dol-1{start},buttsir+2,buttvys+3,0{pozadi},x,y{dest});
   {*udelat bitblt kterej nepreframuje} Reframe2handle(skladhandle);
   incButtonu;
   with now.button[now.local_buttonu] do begin
     {Dkod    :=now.Dkod;}
     Dkod_kam:=dm;
     x1      :=x;
     y1      :=y;
     x2      :=x+buttsir+2;
     y2      :=y+buttvys+3;
     end;
   end;
end;

procedure putbutts(but1,buts:byte;y:word);
var   i,j:word;
begin
 j:=now.visx+(vissir-(buts*buttsir+(buts-1)*mez)) div 2;
 for i:=0 to buts-1 do putbutt(DMroot[i+but1],j+(buttsir+mez)*i,y+now.visy);
end;

var   i,j,k,l,m:integer;

Begin
 Reframe2handle(skladhandle);
 putbutts(1,3,50);
 k:=(DMroots-3-1+vedle) div vedle;
 j:=DMroots-3;
 m:=4;
 for i:=1 to k do begin
   l:=j div (k+1-i);
   putbutts(m,l,(visvys-(k-2*i)*(buttvys+10)) div 2);
   dec(j,l);
   inc(m,l);
   end;
End;

END.

(*

PROCEDURE ZapamatujsiAnkname(st:string;Dkod:word);
begin
 if st>'' then begin
   Reframe2handle(skladhandle);
   SearchThingInSklad(typDminfo,nowDMreal,0{cokoliv});
   with SkladDminfo^ do begin
     ankname:=st;
     ankDkod:=Dkod;
     end;
   end;
end;



     cmp realhandler,0;jz @9
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

