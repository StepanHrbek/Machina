verze 040/ par 11/ cd 22

PROGRAM Pareniste;

{% - co je treba opravit pri zmene stavby setupu}
{$G+,R-,S+,I-,E-,N-,M 30000,0,0}
        {*}
{$define pareniste}
{$define dostran_}
{$define setup}
{$define flipir_}
{$define toglyvsetupu}

                       {$ifdef pareniste}
                             {$define midas}
                       {$else}
                             {$define editor}
                       {$endif}
USES Sluzby,DM,timer,midas;

VAR   firstvar:byte;         {-------------prvni promenna-------------}
CONST firstconst:byte=0;
      mask=0;
      beta='';{b,c atd}

{$i data.inc}


{$ifdef midas}
 PROCEDURE FreeSamples;forward;
{$endif}

{$ifdef editor}
const maxlines=400;
var   edofs,scrx,scry:array[0..maxlines-1] of word;
      edfajl:string[13];
      ednowx,ednowy,ednowi:word;
      linetotal,linenow,prevF3visy:word;
      blokstart,blokend:word;
      wlcha:char;
      wlcol,nowsloupec,otec,altx:byte;
      blokon,pouzij_prevF3visy:boolean;
{$endif}


CONST
      headlen      =20;
      h_radek      =1;
      h_free1      =4;{1 nula}
      h_textura    =5;
      h_visx       =6;
      h_visy       =9;
      h_tabs       =12;
      h_flags      =13;
      h_unused     =14;{5 nul}
      h_endofline  =19;

      f_color_ram  =1;
      f_toglvpravo =2;
      f_vlastni_pal=4;
{      f_pirat      =64;}
{      f_animos     =128;}

      border=41;
      edtextmaxlen=12000;
      mysiokraj=40;
      askx4=170 div 4;
      inspic    ='~';
       zatimnic ='™';
      chgcol    ='`';
      insbigchar='|';
      insbutton ='';
      newsloupec='^';
      mramor    ='ß';
      tabulka   ='ì';
      togl      ='˛';
      askSymbol =':';
      rovnejLeft='@';
      tab       =#9;
      rovnaLine ='ƒ';
      drazka    ='Õ';
      svislaLine='≥';
      setrvacnost=20;
      sunindex          :byte=0;
      sipky             :byte=0;
      ramecekcolor      :byte=24;
      palmysozmena      :boolean=false;
      boss              :byte=0;
      txtpal:t40pal=(
        31,60,63,
        31,53,56,
        32,47,50,
        33,41,44,
        29,39,46,
        25,38,48,
        21,36,50,
        18,35,53,
        33,45,47,
        30,35,63,
        55,55,0,
        55,55,55,
        18,18,0,
        30,30,0,
        45,45,0,
        58,58,0,
        47,26,26,
        63,35,35,
        20,20,20,
        30,30,30,
        40,40,40,
        0,26,26,
        0,40,40,
        0,53,53,
        61,60,63,
        55,51,51,
        50,43,39,
        45,35,27,
        39,32,32,
        9,11,19,
        11,12,20,
        13,14,21,
        15,16,22,
        17,18,24,
        19,20,25,
        21,22,26,
        23,24,28,
        25,26,29,
        27,28,30,
        29,30,32);
(*
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
        47,26,26,{cervenej zaskrt v toglu  ..17}
        63,35,35,
        20,20,20,{sedivy soupadlo          ..19}
        30,30,30,
        40,40,40,
         0,26,26,{svetle modry ramecky, AltMlajny ..22}
         0,40,40,
         0,53,53,

       41,42,39, {25 - prvni barva pozadi}
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
       36,28,26  {40 - posledni barva pozadi}
                 {41 - border}
                 {42..44? - free}
                 {45?..255 - picypal}
                );
(**)
      {$ifdef editor}
      mixcolstxt:array[0..3] of byte=(7,11,14,15);
      {$endif}
      defaultfli     ='0,0,320,200,0,0'#13#10;


VAR
      pointer65:pointer absolute 0:4*$65;

      edtextofs,headerofs:word;
      header:array[1..headlen] of char;
      edtextbody:array[0..edtextmaxlen] of char;
      edtext:array[2..60000] of char absolute firstconst;
      ppp:record pp1,pp2,pp3:byte;palabsolute:t40pal;end absolute pal;
      palmysozmeny:t40pal;

      playingMusicSize           :LONGINT;

      tmrScrSync,
      playingMusicDkod,
      cislo_prepnuti_hudby,
      bh_seg,bh_hesla,
      fileadr,
      lastvisx,lastvisy,visx_shouldbe,visy_shouldbe,
      Wmezer, Wodsaz, Wodcentr, Wsirmez, Wtoedi, Wnewedi,
      pixStart,pixLen,pixMid,pixMinicharSir,pixOdsaz,
      ramecekStart,ramecekLen,
      ofsst,wordX,
      edtextlast,edi,
      minifnt,
      shouldbelen,readenlen,
      shadowvis,anox4            :WORD;

      key                        :INTEGER;

      hlavapat,sloupcu           :SHORTINT;

      edzmena,
      xcommand,mixbyte,
      global_maxfntheight        :BYTE;

      playingUserMusic,
      muteMusic,
      midasConfigured,
      disabletimerthingy,
      beziNahazovacRef,
      playing_localmusic,
      bokyRamecku                :BOOLEAN;

      hlavapata         :array[-1..18] of record x1,y16,oedi,firstline:word;end;
      sloupce           :array[0..9] of record x1,y16,firstedi,firstline,xx1,yy16,lastedi,lastline:word;end absolute hlavapata;
      sunx,suny         :array[0..setrvacnost-1] of shortint;
      keyoff            :byte;
      menuing           :Boolean;
      editingpal        :Boolean;
      musiclongtimer    :longint;
      dotaznikkeypressed:byte;
(*
      global_muzik      :word;
      global_muziky:array[1..maxgmuzik] of record
                                             Dkod            :word;
                                             {jakDavnoPlayed  :byte;}
                                           end;
*)



{------format.X-------}
VAR   xsir,xvys,barevw:word;
      barevb:byte absolute barevw;


{------------forwardy--------------}
procedure errorhalt(n:word);far;forward;{nemazat kvuli FAR !!!!!!!!}
procedure timerScrolling;far;forward;
procedure preVR;far;forward;

{---------------INI----------------}
VAR
      Stereo,
      mode816        :BYTE;

{$i vars.inc}

FUNCTION LocalReadINI(path,name:string):Boolean;{spoustet az po midasSetDefaults}
var boo:boolean;
begin
 if not ReadIni(path+name,@vars) then LocalReadINI:=false else begin
   LocalReadINI:=true;
   usedINIname:=path+name;
   workdir:=path
   {upcasestring(@jemnedoladeniscrolu);}
   end;
end;

PROCEDURE LocalWriteINI(name:string);
var   i:byte;
label save;
begin
 if ukladatsetup then
  if midasConfigured then WriteIni(name,@vars,16+8){sejvne midasy i normaly}
  else
{$ifdef dostran}
  if startupDrv<>vgaDriver then goto save
  else
{$endif}
  for i:=1 to sizeof(startupSetup) do
   if startupSetup[i]<>setupAbsolute[i] then begin
    save:
    WriteIni(name,@vars,8);{sejvne jen normaly}
    break;
    end;
end;


{ -----------------------------------------------}
{$ifndef midas}
procedure playsample(n:byte);assembler;asm end;
procedure playsamplefromdisk(n:byte);assembler;asm end;
{$endif}

{ -------------------timer-------------------------}

VAR   synced          :boolean;
      oldsyncroutine,
      nowsyncroutine  :pointer;

PROCEDURE tmrSyncScr(p3:pointer);{prebije stejne nazvanou proc z timer.tpu}
var   p1:pointer;
begin
 if synced then errorhalt(40);
 synced:=true;
 p1:=nil;
 if p3=@timerScrolling then begin
   beziNahazovacRef:=true;
   p1:=@preVR;
   end;
 timer.tmrSyncScr(tmrScrSync,p1,nil,p3);
 nowsyncroutine:=p3;
end;

PROCEDURE tmrStopScrSync;{prebije stejne nazvanou proc z timer.tpu}
begin
 if not synced then exit;{errorhalt(41);}
 synced:=false;
 beziNahazovacRef:=false;
 timer.tmrStopScrSync;
 if nowsyncroutine=@timerScrolling then preVR;{aby se srovnal now.visxy s visxy_shouldbe}
 nowsyncroutine:=nil;
 ref:=true;
end;

PROCEDURE DocasneVypniTimer;
begin
 if (nowsyncroutine<>nil) and (definetimer>0) then begin
   oldsyncroutine:=nowsyncroutine;
   nowsyncroutine:=nil;
   tmrStopScrSync;
   end;
end;

PROCEDURE ZapniDocasneVyplejTimer;
begin
 if oldsyncroutine<>nil then begin
   tmrSyncScr(oldsyncroutine);
   oldsyncroutine:=nil;
   end;
end;

{ --------------MEMORY--------------}

PROCEDURE AllMemDone;
begin
 {---EMS---}
  EMSvirtualpagesDone;
  deallocEMS(texturhandle);
  deallocEMS(skladhandle);
{$ifdef setup}
  deallocEMS( setuphandle);
{$endif}
 {----CONV----}
  CONVbigfontDone;
  deallocConv(workseg);
  deallocConv(paletseg);
end;

PROCEDURE TimerAndMidasClose;
begin
 tmrStopScrSync;
{$ifdef midas}
 freeSamples;
 midasClose;                            { uninitialize MIDAS }
{$else}
 myTmrClose;
{$endif}
end;

PROCEDURE ERRORHALT(n:word);
var   i:word;
const inside:boolean=false;
      firsterror:word=0;
label 1,unknown,e1;
begin
asm mov ax,seg firstconst;mov ds,ax;
    sti
    end;
port[$21]:=0;
if inside then begin
  writeln('ƒƒƒƒƒƒƒƒ> Mimo©†dn† situace: do®lo z†rove§ k chyb†m ',firsterror,' a ',n,'.');
  writeln('ƒƒƒƒƒƒƒƒ> Poznamenej si á°sla (',firsterror,',',n,'!!!) a nahla® Dementovi.');
  writeln('ƒƒƒƒƒƒƒƒ> Stiskni (T)erminate nebo (C)ontinue.');
  writeln('ƒƒƒƒƒƒƒƒ> ''T'' okamëità ukoná° program bez pokusñ o uvolnàn° pamàti apod.');
  writeln('ƒƒƒƒƒƒƒƒ> ''C'' pokraáuje v uvol§ov†n° zdrojñ p©i nebezpeá° zhroucen°.');
  writeln;
  1:
  case readkey of 't','T':halt;
                  'c','C':begin inside:=false;exit;end;
                  else goto 1;
                  end;
  end

else begin

 inside:=true;
 firsterror:=n;
 tmrStopScrSync;

 setTextMode;
 textattr:=7;
 i:=ioresult;
 if i<>0 then writeln('IOresult=',i);

 clearKeybBuffer;

 {$ifdef dostran}
 {vrati locky do puvodniho stavu}
 locks:=(locks and 254)+oldscrollock;
 lightlocks;
 {$endif}

 case n of 0:begin
             writeln('Verze ',verze,beta,'.');
             {$ifdef midas}
             saveanketa(midasSDnumber);
             {$else}
             saveanketa(-1);
             {$endif}
             end;
          99:begin
             writeln('F12 = n†hl† smrt.');
             {$ifdef midas}
             saveanketa(midasSDnumber);
             {$else}
             saveanketa(-1);
             {$endif}
             end;
           1:e1:writeln('Pot©ebuji v°c konvenán° pamàti. V nejhor®°m p©°padà zkus vypnout zvuk.');
           2:writeln('Pot©ebuji EMS pamàü. '+
                     'Doporuáuji pouë°t QEMM, do souboru CONFIG.SYS p©idej ©†dek DEVICE=QEMM386.SYS. '+
                     'Nelze-li jinak, zkus DEVICE=HIMEM.SYS a DEVICE=EMM386.EXE 2400.');
           3:writeln('Pot©ebuji v°c EMS pamàti. Omez velikost cache apod. Celkem vystaá°m s 2.3MB.');
           4:writeln('Chyba FLI playeru.');
           5:writeln('Chybn† operace se samplem.');
           6:begin
             writeln('Za norm†ln°ch okolnost° nechci kvñli moënòm problÇmñm se zpàtnou'#13#10+
                     'nekompatibilitou zpracov†vat INI soubor vytvo©enò vy®®° verz° programu.');
             writeln('Mñëe® - pouë°t novàj®° verzi DISKMAG.EXE, kterou evidentnà m†®,'#13#10+
                     '      - nebo pouë°t parametr C, uráenò ke spou®tàn° z CD-ROM,'#13#10+
                     '      - nebo smazat DISKMAG.INI a j† si vytvo©°m vlastn°.');
             end;
           7:writeln('Nem†m dost konvenán° pamàti na FLI...');
           8:writeln('Tak to prrrr, ál†nek m† p©es 252 ©†dek, uber !');
           9:writeln('Chybnò parametr u FLI.');
          10:writeln('FLI soubor nenalezen.');
          11:writeln('Chyba ve FLI souboru.');
          12:writeln('Editor pracuje jen s obrazovkou ®irokou 80 znakñ.');
          13:writeln('/me/');
          14:writeln('Soubor '+errorfile+' nenalezen v intern° fileb†zi ani na disku.');
          15:writeln('Soubor '+errorfile+' nen° kompletn°. Z poëadovanòch ',
                      shouldbelen,' bajtñ se poda©ilo p©eá°st ',readenlen,'.');
          17:writeln('Tvñj VESA BIOS nechce nahodit 512x480/256.');
          19:writeln('Nena®el jsem data, kter† màla bòt p©ipojena za EXE.');
          20:writeln('Dos error ',datahandle,' p©i áten° souboru.');
          21:begin writeln('Program se pokou®el spustit p©°li® velkò MOD/S3M.');goto e1;end;
          22:writeln('Pokus o otev©en° neexistuj°c°ho DM souboru.');
   23..23+16:writeln('Chyba ',n,' ve skladi®ti.');
          40:writeln('Sync na nespr†vnÇm m°stà.');
          41:writeln('Unsync na nespr†vnÇm m°stà.');
          {42:writeln('');}
          43:writeln('/fme/');
          44:writeln('Chyba nekde v driveru ke graficke karte.');
          45:writeln('Nelze upgradnout soubor ',workdir,IniName,' na vy®®° verzi, smaë ho.'#13#10,
                     '...A nejsi ty vyp†lenej na CD-ROM??? (se®kr†bat!)');
          46:writeln('/em/');
          47:writeln('Znama chyba: Soubor uvedeny ve filebazi vubec neexistuje.'#13#10+
                     'Stava se kdyz soubor smazes (AltD) a pak ho zkusis otevrit.');
          48:writeln('Tenhle PCX ti nesezeru.');
      50..70:begin
             write('P©ekroáen° maxim†ln°(ho poátu) ');
             case n-50 of 0:write(            'togglñ=',maxtogglu);
                          1:write(        'askstringñ=',maxaskstringu);
                          2:write(           'buttonñ=',maxbuttonu,' (teÉ ',now.local_buttonu,')');
                          3:write(        'now.Lmuzik=',maxLmuzik);
                          4:write(            'samplñ=',maxsamplu);
                          5:write(         'datafajlñ=',maxdatafajlu);
                          6:write(         'bighandlñ=',maxbighandlu);
                          7:write(      'filelistsize=',maxfilelistsize);
                          8:write(             'DM''s=',maxDMs);
                          9:write(  'palet na str†nce=',maxobrazku);
                         10:write('velikosti palet na str†nce=',sizeofpaletseg);
                         11:write(           'vno©en°=',maxvnoreni);
                         12:write('souborñ p©idruëenòch k jednomu DM=',maxaddons);
                         13:write(     'poloëek v INI=',maxudajuINI);
                         14:write('importovanòch muzik=',maxImuzik);
                         15:write(            'samplñ=',maxsamplu);
                         else goto unknown;
                         end;
             writeln('.');
             writeln('Tato chyba by p©i bàënÇm pouëit° nemàla nastat. Dej vàdàt, mñëu ji eliminovat.');
             end;
          94:writeln('Chyba p©i inicializaci TCP/IP');
          95:writeln('Nezn†m† verze X-Windows');
          96:writeln('Maxim†ln° poáet hr†áñ je omezen na 8.');
          96:writeln('Pozor pozor, uëivatel pr†và áum° kam nem† :)');
    100..110:writeln('Intern° chyba á°slo ',n,'.');
        else unknown:writeln('Nezn†m† chyba á°slo ',n,'!... nahla® Dementovi...');
        end;

 if usedininame>'' then LocalWriteINI(usedINIname);{nedela pri erroru jeste pred nactenim ini}
 if n<>43 then TimerAndMidasClose;{nedela pri midas uninit erroru}
 if debuginfo and (n<>23+8) then ScanSklad;{nedela pri chybe na skladu}
 AllMemDone;
 writeln;
 if debuginfo then begin
   writeln('togglu=',now.local_togglu);
   writeln('asku=',now.local_askstringu);
   writeln('buttonu=',now.local_buttonu);
   end;
 {pro jistotu jeste jednou :-|}
 port[$21]:=0;
 asm sti;end;
 halt;
 end;

end;

PROCEDURE UniversalRefresh;
begin
 if beziNahazovacRef then begin
   repeat until ref;
   ref:=false;
   end
  else
   refresh(1);
end;



FUNCTION ReadInteger(odkud:word):integer;
begin
 ReadInteger:=(100*ord(edtext[odkud])+10*ord(edtext[odkud+1])+ord(edtext[odkud+2])-4800-480-48+500) mod 1000-500;
end;

PROCEDURE WriteInteger(kam:word;kolik:integer);
begin
 if kolik<0 then inc(kolik,1000);
 edtext[kam  ]:=chr(48+kolik div 100);
 edtext[kam+1]:=chr(48+kolik div 10 mod 10);
 edtext[kam+2]:=chr(48+kolik mod 10);
end;





{ €€ €€ €€   FILE MANAGER   €€ €€ €€ }

PROCEDURE MoveTextFile2EdText(st:string);
var   i,j,le:word;

procedure pridej(st:string);
var i:word;
begin
 for i:=1 to length(st) do edtext[edtextlast+i]:=st[i];
 inc(edtextlast,length(st));
 edzmena:=1;
end;

procedure PutStartinHeader(rozsah:byte);
const startinheaderlen=headlen+14;
      startinheader:array[0..startinheaderlen] of char=
        '0037b0760005000000'#13#10'^0120000270'#13#10#13#10;
var i,j:word;
begin
 i:=0;              {raw file or new file; put whole header}
 j:=startinheaderlen+1;
 move(mem[dseg:headerofs+i],mem[dseg:headerofs+j],edtextlast+1-headerofs);
 inc(edtextlast,j-i);
 for i:=i to j-1 do edtext[headerofs+i]:=startinheader[i];
 edzmena:=1;
end;

label nastavpaletu;
Begin
 edtextlast:=ofs(header)-1;
 edzmena:=0;

 {vygeneruje setup page}
 if st=setup_fl then begin
   for i:=0 to setuptextlen do edtext[headerofs+i]:=chr(setuptext[i]);
   edtextlast:=ofs(header)+i-1;
   goto nastavpaletu;
   end;

 {vygeneruje rip page
 if st=rip_fl then begin
   pridej('0070b0760000000000'#13#10'^0146001132'#13#10'NAME'#13#10#13#10);
   for i:=1 to datafajlu do pridej('˛('+data[i].name+')'+data[i].name+#13#10);
   pridej('^1113000072'#13#10'SIZE'#13#10#13#10);
   for i:=1 to datafajlu do begin
     str(data[i].len,st);
     pridej(st+#13#10);
     end;
   WriteInteger(headerofs-1+h_radek,datafajlu+6);
   goto nastavpaletu;
   end;{}

 if not DM.OpenDataFile(st) then
   {$ifdef editor}
   putstartinheader(1){new file}
   {$else}
   pridej('0300b0760000000000'#13#10'^0100012310'#13#10'`bStr†nka `c'+st+'`b nebyla nalezena ve fileb†zi...'#13#10)
   {$endif}
  else begin
   le:=ReadDataFile(lastopenLength,ofs(header),seg(header));
   DM.CloseDataFile;
   {$ifdef editor}
   edtextlast:=ofs(header)+lastopenLength-1;
   j:=0;for i:=1 to 18 do case header[i] of '0'..'9':inc(j);end;
   if (j<17) or (header[19]<>#13) or (header[20]<>#10) then putstartinheader(1);
   {$else}
   if lastopenLength=le then edtextlast:=ofs(header)+lastopenLength-1 else
      pridej('0300b0760000000000'#13#10'^0100012310'#13#10'`bNekompletn° text `c'+st+'`b. DÇlka: '+
             chr(le div 1000+48)+chr(le div 100 mod 10+48)+chr(le div 10 mod 10+48)+chr(le mod 10+48)+#13#10);
   {$endif}
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
   edzmena:=1;
   end;

 nastavpaletu:
  {nastavi paletu barev 0..40}
  if (ord(header[h_flags]) and f_vlastni_pal)=0 then
    {vrazi tam default paletu}
    now.pal40:=txtpal
   else
    {precte z fajlu}
    for i:=0 to 119 do now.pal40[3+i]:=ord(edtext[edtextofs+i])-32;

End;




   { ------------- T I M E R ------------ }
{
PROCEDURE TimerBrightDown;far;assembler;
asm
 pusha
 push ds
 mov ax,seg firstconst;mov ds,ax
 mov al,nowbright
 sub al,3
 jc @end
 mov ah,0
 push ax
 call setbright
 @end:
 pop ds
 popa
end;
}
PROCEDURE BrightDownWithSound(time:byte);
var i:word;
begin
 PrepareBrightDown(false);
 for i:=time-1 downto 0 do begin
   UniversalRefresh;
   setbright(255*i div time);
   {$ifdef midas}
   midasMastervolume(hlasitostHudby*i div time);
   {$endif}
   end;
end;


{------------ ostatni ---------------}



{$ifdef flipir}
{$i fli.inc}
{$endif}



PROCEDURE Doprava(n:word);var i:word;
 begin for i:=0 to n-1 do inc(sunx[(sunindex+i) mod setrvacnost],(3*(n-i) shr 1) div n);end;
PROCEDURE Doleva (n:word);var i:word;
 begin for i:=0 to n-1 do dec(sunx[(sunindex+i) mod setrvacnost],(3*(n-i) shr 1) div n);end;
PROCEDURE Dolu   (n:word);var i:word;
 begin for i:=0 to n-1 do inc(suny[(sunindex+i) mod setrvacnost],(  (n-i) shl 1) div n);end;
PROCEDURE Nahoru (n:word);var i:word;
 begin for i:=0 to n-1 do dec(suny[(sunindex+i) mod setrvacnost],(  (n-i) shl 1) div n);end;

FUNCTION Osekej(n:word):word;
begin
 if n>64 then n:=64;
 osekej:=1+(rychlostScrollingu+1)*n div 100;
end;



PROCEDURE NextEdiLine;assembler;{skoci s edi na dalsi radku}
 asm mov si,edi;@1:lodsb;cmp al,13;jnz @1;inc si;mov edi,si;end;

FUNCTION ReadLine:string;{precte string od edi, edi nemeni}
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
 asm push minifnt
     mov si,edi;mov cx,0;mov bx,propsir;mov ah,0;mov dl,stop
     @1:lodsb;
     cmp al,chgcol;jz @chgcol
     cmp al,tab       ;jz @1
     cmp al,rovnejleft;jz @1
     cmp al,dl        ;jz @end
     cmp al,13        ;jz @end
     xlat;add ax,minifnt;add cx,ax;jmp @1
     @chgcol:lodsb;cmp al,'e';jnz @1;xor minifnt,1;jmp @1
     @end:mov @result,cx
     pop minifnt
     end;
end;
{
FUNCTION ReadStringPixLength(st:string):word;
begin
 asm mov cx,0
     lea si,st;lodsb;or al,al;jz @end;mov cl,al;mov ch,0
     mov bx,offset tenkejPropsir-' '
     mov ah,0
     @1:lodsb;xlat;add ax,minifnt;add cx,ax;loop @1
     @end:mov @result,cx
     end;
end;
}
PROCEDURE GetLineParams;{nastavi Wmezer, Wodsaz, Wodcentr, Wsirmez, Wtoedi, Wnewedi}
var i,lastadr,lastsir,nowsirka:word;
label ano,ne,odsaz,za;
begin
 Wmezer:=0;
 Wodsaz:=0;
 Wodcentr:=0;
 Wsirmez:=0;
 asm mov bx,edi;mov ax,[bx-2];mov cx,[bx]

     cmp cl,rovnejleft;jnz @notrovnejleft    {@ -> zarovna doleva}
     inc edi{}
     jmp za
     @notrovnejleft:

     cmp cl,tab       ;jnz @nottab
     inc edi{}
     cmp ch,tab       ;jnz za   {#9 -> zarovna doleva}
     inc edi{}          ;jmp odsaz{#9#9 -> odsadi odstavec}
     @nottab:

     cmp ah,10        ;jz ano
     cmp ah,inspic    ;jz ano
     cmp ah,mramor    ;jz ano
     cmp ah,tabulka   ;jz ano
     cmp al,insbigchar;jz ano
     cmp al,insbutton ;jz ano
     cmp ah,asksymbol ;jnz za
     end;
 ne:
 Wodcentr:=4*askx4-25-pixStart;
 goto za;
 ano:
 i:=ReadPixLength(#13,ofs(tenkejPropsir)-32);
 if (i<pixLen) then Wodcentr:=(pixLen-i) div 2
               else odsaz:Wodsaz:=pixOdsaz;
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
 asm push minifnt
     mov si,edi;mov cx,nowsirka;mov bx,offset tenkejPropsir-' ';mov ah,0
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
     @chgcol:lodsb;cmp al,'e';jnz @loop;xor minifnt,1;jmp @loop
     @char13:sub si,2;mov Wtoedi,si;add si,3;mov Wnewedi,si

     @end:
     cmp bokyramecku,0;jz @no;add pixLen,10;@no:
     pop minifnt
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
      lodsb;
      cmp al,'e';jnz @zmena_barvy;xor minifnt,1;jmp @nextchar{zmena na doublefont}
      @zmena_barvy:
      sub al,'a'-9;mov bl,al;mov mixbyte,al
      jmp @nextchar
      @nochcol:

      mov ah,0
      push si
      push ax
      cmp minifnt,1;jz @double_minifnt1
      cmp minifnt,2;jz @mramor_minifnt2

@common_minifnt0:
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

@double_minifnt1:
      mov global_maxfntheight,2
      shl ax,4
      add ax,offset tenkej-16*' '
      mov si,ax
      mov dx,16
      mov ah,2
     @nextline2:
      lodsb
      mov cx,8
      @22:shl al,1;jnc @noput2;mov [es:di],bl;mov [es:di+wrisir],bl;@noput2:inc di;loop @22
      add di,2*wrisir-8
      dec dx;jnz @nextline2
      sub di,16*wrisir
      jmp @same

@mramor_minifnt2:
      mov bx,17+18*256
      shl ax,4
      add ax,offset tenkej-16*' '
      mov si,ax
      mov dx,16
      mov ah,2
     @nextline1:
      lodsb
      mov cx,8
      @1:shl al,1;jnc @noput1;mov [es:di],bx;mov [es:di+wrisir],bx;@noput1:inc di;loop @1
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



PROCEDURE SetDefaultTextAttribs;{tohle delat pri otevreni textfajlu}
var i,j,l:integer;
begin
{globalni parametry textu}
 pixMinicharSir:=5;
 pixOdsaz:=24;
 anox4:=(170-dostrany) div 4;
{pocatecni hodnoty promennych}
 with hlavapata[0] do begin x1:=0;y16:=1;oedi:=edtextofs;firstline:=65535;end;
 hlavapat:=-1;
 sloupcu:=0;
 mixbyte:=9;
 {$ifdef editor}wlcol:=mixcolstxt[0];{$endif}
 minifnt:=0;{mix font, ne shadow font}
 bokyRamecku:=false;
 ramecekColor:=24;
{ostatni}
 dotaznikkeypressed:=0;
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
 {predpokladam ze se pracuje s minifnt=0 o vysce 1}
 global_maxfntheight:=1;
 {atd}
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
                              tab:begin
                                  wordX:=pixStart+
                                  ((wordX-pixStart+1)*(ord(header[h_tabs])-48) div pixLen+1)
                                  *pixlen div (ord(header[h_tabs])-48);
                                  inc(edi);
                                  end;
                             else OneMiniWord;
                             end;
 edi:=Wnewedi;
end;


{$ifdef midas}
PROCEDURE LoadSample(st:string;copysample:byte);
var i,rate:word;
    wav:array[0..21] of word;
{*docasny reseni}
const sampleRate:array[1..maxsamplu] of word=(11000,15500,9000,11000,11000,11000,8000,11000,11000);
begin
  if midasSDnumber=4 then exit;
  errorfile:=st;
  if not DM.opendatafile(errorfile) then errorhalt(14);
  if pos('.raw',LoCaseString(st))>0 then begin
    shouldbelen:=lastOpenLength;
    rate:=samplerate[sampluloaded+1];
    end
   else begin
    readdatafile(44,ofs(wav),seg(wav));
    shouldbelen:=wav[20];
    rate:=wav[12];
    end;
  readenlen:=readdatafile(shouldbelen,0,workseg);
  if readenlen<>shouldbelen then errorhalt(15);
  midas.LoadSample(@mem[workseg:0],shouldbelen,rate,copysample);
  DM.CloseDataFile;
end;

PROCEDURE PlaySampleFromDisk(Dkod:word);
var i,j:word;
begin
 if (not midasinited) or (midasSDnumber=4) then exit;

 if Dkod>0 then with data[Dkod] do begin
   DocasneVypniTimer;
   PlaySample(sam_nope);{}
   LoadSample(name,0);
   midas.PlaySample(sam_local);
{   midas.RemoveSample;}
   ZapniDocasneVyplejTimer;
   end;
end;

PROCEDURE FreeSamples;
var i:byte;
begin
 if midasSDnumber=4 then exit;
 for i:=1 to sampluloaded do midas.RemoveSample;
end;

PROCEDURE myMidasInit;
var   i:word;
begin
 {napoprvy inicializuje midas}
 if not midasInited then begin
   midasInit;                          { initialize MIDAS Sound System }
   { Get Sound Device default amplification value: }
   {*error := SD^.GetAmplification(@defAmplify);
   if error <> OK then
     midasError(error);
   amplification := defAmplify;}
   for i:=1 to exesamplu do loadsample(exesamply[i],1);
   midasInit2;{rozbehne timerplaying}
   end;
end;

FUNCTION TheSameMusic(mujDkod:word):boolean;
begin
 TheSameMusic:={((mujDkod=0) and (playing))
            or} ((mujDkod<=furtfajlu) and (mujDkod=playingmusicDkod)) {importy poznava podle Dkodu}
            or ((mujDkod>furtfajlu) and (data[mujDkod].len=playingmusicSize));{localy poznava podle size}
end;

PROCEDURE Music(mujDkod:word);{mujDkod=2000 -> vybrat nahodne z gmuziky+import}
const module:pointer=nil;
      fadetime=10;
var   i,j:word;
      useMP:pointer;
label 6,closefile,quit;
begin
  playing_localmusic:=false;

  {vybere nejdele nehranou hudbu z main_muzik}
  if (mujDkod=2000) and (now.Lmuzik>0) then begin
    {
    j:=65535;
    for i:=1 to now.Lmuzik do with now.Lmuziky[i] do if (j>data[Dkod].status) then begin
      j:=data[Dkod].status;
      mujDkod:=Dkod;
      end;
    {
    for i:=1 to import_muzik do with import_muziky[i] do if (j>data[Dkod].status) then begin
      j:=data[Dkod].status;
      mujDkod:=Dkod;
      end;}
    if {playingusermusic or
{       (now.Lmuzik=0) or}
       ((now.Lmuzik=1) and TheSameMusic(now.Lmuziky[1].Dkod)) then exit;
    i:=0;
    repeat
      mujDkod:=now.Lmuziky[1+random(now.Lmuzik)].Dkod;
      inc(i);
    until (not TheSameMusic(mujDkod)) or (i=100);
    if i=100 then errorhalt(100);
    end;

  {obslouzi prilis vysoky F? jako silence}
  if (mujDkod>datafajlu) or mutemusic then mujDkod:=0;

  {nespousti znova tu samou muziku}
  if TheSameMusic(mujDkod) then goto quit;

  {vykope prave hranej modul}
  if module<>nil then begin
    for i:=fadetime-1 downto 0 do begin
      UniversalRefresh;
      midasMastervolume(hlasitostHudby*i div fadetime);
      end;
    midasStopModule(module);
    midasFreeModule(module);
    module:=nil;
    playingMusicDkod:=0;
    playingMusicSize:=0;
    end;


  if mujDkod>0 then begin
    myMidasInit;
    if midasSDnumber=4 then exit;
    {nahodi selektnutej novej modul}
    with data[mujDkod] do begin
        errorfile:=name;
        if not DM.opendatafile(errorfile) then errorhalt(14);
        useMP:=nil;
        for i:=0 to NUMMPLAYERS-1 do if copy(name,length(name)-2,3)=moduleKoncovka[i] then useMP:=modulePlayers[i];
        if useMP=nil then errorhalt(103);
        DocasneVypniTimer;
        6:
        zavesfilehandler(handle,start);
        module:=midasLoadModule(nil,useMP,nil);
        odpojfilehandler;
        if module<>nil then midasPlayModule(module,FXchannels)
                       else if FreeMoreConv then goto 6
                                            else begin
                                                   mujDkod:=0;
                                                   goto closefile;
                                                   end;
        end;
    {je potreba to tady nastavovat?}
    midasFXvolume(hlasitostEfektu);
    midasMastervolume(hlasitostHudby);{}
    {poznamena si ze tato hudba je nejpozdeji hrana
    inc(cislo_prepnuti_hudby);
    data[mujDkod].status:=cislo_prepnuti_hudby;{}
    {close file}
    closefile:
    ZapniDocasneVyplejTimer;
    DM.CloseDatafile;
    musiclongtimer:=0;
    end;

  {quit}
  quit:
  playingUserMusic:=false;
  playingMusicDkod:=mujDkod;
  if mujDkod>0 then playingMusicSize:=data[mujDkod].len;
end;

PROCEDURE ChooseMusic(n:word);
var   i,j,k:word;
label 1,quit;
begin
 k:=0;
 1:
 for i:=1 to datafajlu do
  for j:=0 to nummplayers-1 do
   if pos('.'+modulekoncovka[j],data[i].name)>0 then
     case n of 0:begin music(i);goto quit;end;
            2000:inc(k);
            else dec(n);
            end;
 if n=2000 then begin n:=random(k);goto 1;end;
 music(0);
 {
 if n<=global_muzik then Music(global_muziky[n].Dkod) else begin
   dec(n,global_muzik);
   if n<=import_muzik then Music(import_muziky[n].Dkod) else Music(0);
   end;}
 quit:
 playingusermusic:=true;
end;

{$endif}



{$ifdef editor}
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

PROCEDURE SetHeaderString(what,value:string);
var   i,j,oldedi:word;
      chg:integer;
      st,newvalue:string;
begin
 newvalue:=what+value+#13+#10;
 oldedi:=edi;
 chg:=0;
 edi:=headerofs;
 repeat
  NextEdiLine;
  st:=ReadLine;
  if copy(st,1,length(what))=what then begin
    DelSpaces(edi,length(st)+2);
    dec(chg      ,length(st)+2);
    end;
 until edtext[edi]=newsloupec;
 if value>'' then begin
   InsertSpaces(edi,length(newvalue));
   inc(chg         ,length(newvalue));
   for i:=1 to length(newvalue) do edtext[edi-1+i]:=newvalue[i];{PutString(edi,value);}
   end;
 edi:=oldedi+chg;
 inc(ednowi,chg);
end;
{$endif}

FUNCTION GetHeaderString(what:string):string;
var   i,j,oldedi:word;
      st:string;
label found;
begin
 oldedi:=edi;
 GetHeaderString:='';
 edi:=headerofs;
 repeat
  NextEdiLine;
  st:=ReadLine;
  if copy(st,1,length(what))=what then begin GetHeaderString:=copy(st,length(what)+1,200);goto found;end;
 until edtext[edi]=newsloupec;
 found:
 edi:=oldedi;
end;


PROCEDURE PrepareScreen(konvert:Boolean);
var   ii,j,k,l,m,
      code               :integer;
      font,size          :byte;
      uz_byl_zobrazen    :boolean;
      ch                 :char;
      st                 :string;
      packedZbyvasize    :longint;
      k0,titlesir,
      leftStart,
      datafajl,
      precist,{alias packedPacksize}
      packedStart,
      packedEnd,
      rawEnd,
      rawPacksize,
      rawPackradek,
      rawZbyvaradek      :word;

const  chybi:string[60]=#13#10'`bTady chyb° obr†zek.'#13#10'Seëe§ si datafajl s grafikou.'#13#10;

label 1,2,7,9,nexttry,ToglyAsky;
Begin
  if now.handle>0 then goto ToglyAsky;

  if now.Dkod=0 then now.Dkod:=getDkod(now.fl,true)
                else now.fl  :=data[now.Dkod].name;
  now.local_askstringu       :=0;
  now.local_togglu           :=0;
  now.whichDM                :=nowDMreal;
  uz_byl_zobrazen            :=false;

  SetDefaultTextAttribs;

  {$ifdef flipir}
  DeallocConv(fliseg);

  if pos('.fli',now.fl)>0 then begin
    initFLI(now.fl);
    exit;
    end;
  {$endif}

  MoveTextFile2EdText(now.fl);
  edi:=edtextofs;
  repeat NextEdiLine until edtext[edi]=newsloupec;
  {if (ord(header[h_flags]) and f_vlastni_pal)>0 then inc(edi,122);}
  if header[h_textura]='h' then now.starpal:=true;


  {---nacte z headeru samply, piraty---}
  now.Dkod_samplin :=GetDkod(GetHeaderString(hdrinserty[hdr_sin].txt),true);
  now.Dkod_samplout:=GetDkod(GetHeaderString(hdrinserty[hdr_sou].txt),true);
  now.Dkod_pirat   :=GetDkod(GetHeaderString(hdrinserty[hdr_pir].txt),true);
  {---nacte z headeru nazev ank.listku, heslo---}
  now.ank:=GetHeaderString(hdrinserty[hdr_ank].txt);
{  zapamatujsiankname(GetHeaderString(hdrinserty[hdr_ank].txt),now.Dkod);}
  now.password:=GetHeaderString(hdrinserty[hdr_hes].txt);
  {---nacte z headeru moduly---}
  if intree>1 then begin
    now.Lmuzik:=tree[intree-1].Lmuzik;
    now.Lmuziky:=tree[intree-1].Lmuziky;
    if now.fl=title then now.Lmuzik:=0;
    end;
  st:=GetHeaderString(hdrinserty[hdr_mus].txt);
  j:=now.Lmuzik;
  while st>'' do begin
    incLmuzik;
    now.Lmuziky[now.Lmuzik].Dkod:=getDkod(CutStringFromString(' ',st),true);
    end;

  {$ifdef midas}
  {nahodi prvni z pridanejch muzik}
  if j<now.Lmuzik then music(now.Lmuziky[j+1].Dkod);
  {$endif}

  {$ifdef flipir}
  if now.pir=0 then begin
    now.pir:=ord(header[h_flags]) shr 6;
    now.flix:=wrisir div 2*16;
    now.fliy:=wrivys*2*16;
    end;
  {$endif}

  if now.radek=0 then begin
    {nacitat souradnice jen pri prvnim preparescreenu, ne pri goback}
    {$ifdef dostran}
    now.visx :=readinteger(headerofs+h_visx-1);
    {$else}
    now.visx :=0;
    {$endif}
    now.visy :=readinteger(headerofs+h_visy-1);
    end;
  now.radek:=readinteger(headerofs+h_radek-1);
  if now.radek<31 then now.radek:=31;
  {*zatim musi zustat dokud neudelam v preparescreen/togl pocitani pixStart zavisly na x4 misto anox4}
  if (ord(header[h_flags]) and f_toglvpravo)>0 then anox4:=(195-dostrany) div 4;

  1:
  if now.handle<>0 then errorhalt(100+1);
  if now.radek>254 then errorhalt(8);
  if not allocEMS16K((now.radek+1+1{na palety etc}) shr 1,now.handle) then if FreeMoreEMS then goto 1 else ErrorHalt(3);

 {kresli stranku do ems}
  PlaceTexture(header[h_textura]);
  ii:=1;
  while edi<=edtextlast do case edtext[edi] of

        TOGL:begin
             inc(edi);
             {---obstara naplneni polozky toggle---}
             if not uz_byl_zobrazen then begin
               incTogglu;
               with now.toggle[now.local_togglu] do begin
                 x4           :=anox4;
                 y1           :=16*(ii-1);
                 Dkod_sampl[0]:=0;
                 Dkod_sampl[1]:=0;
                 Dkod_ripu    :=0;
                 stav         :=0;
                 {---zpracuje syntaxi radky ˛(samplon,samploff,rip)bleble---}
                 if edtext[edi]='(' then begin
                   inc(edi);
                   st:=readline;
                   for j:=0 to 1 do Dkod_sampl[j]:=getDkod(CutStringFromString(',',st),false);
                   Dkod_ripu:=getDkod(CutStringFromString(')',st),true);
                   while edtext[edi]<>')' do inc(edi);
                   inc(edi);
                   end;
                 {
                 if Dkod_ripu=0 then begin
                   for j:=0 to 1 do if Dkod_sampl[j]=0 then Dkod_sampl[j]:=sam_togl;
                   end
                  else begin
                   if Dkod_sampl[0]=0 then Dkod_sampl[0]:=sam_rip;
                   if Dkod_sampl[1]=0 then Dkod_sampl[1]:=sam_ne;
                   end;
                  }
                 end;
               end
              else
               {---pouze preskoci parametry (sampl|rip)---}
               if edtext[edi]='(' then begin
                 while edtext[edi]<>')' do inc(edi);
                 inc(edi);
                 end;

             {---vytiskne text za togglem---}
             asm push pixstart;push pixlen
                 mov ax,pixstart;add pixlen,ax
                 mov ax,anox4;shl ax,2;add ax,30+dostrany;mov pixstart,ax
                 sub pixlen,ax
                 end;
             repeat
               reframe(ii);
               DrawLine;
               inc(ii);
             until edtext[edi-2]=#13;
             asm pop pixlen;pop pixstart;end;
             end;
   ASKSYMBOL:begin
             {---obstara naplneni polozky askstring---}
             if not uz_byl_zobrazen then begin
               incAskstringu;
               with now.askstring[now.local_askstringu] do begin
                 x4           :=anox4;
                 y16          :=ii-1;
                 znaku        :=askmaxlen;
                 {---zpracuje syntaxi radky :(x4,znaku)bleble---}
                 if edtext[edi]='(' then begin
                   st:='';
                   j:=0;
                   repeat
                     inc(edi);
                     case edtext[edi] of '0'..'9':st:=st+edtext[edi];
                                          ',',')':begin
                                                  val(st,k,code);
                                                  inc(j);
                                                  case j of 1:x4:=k;
                                                            2:znaku:=k;
                                                            end;
                                                  end;
                                          end;
                   until edtext[edi]<>')';
                   end;
                 end;
               end
              else
               {---pouze preskoci parametry (sampl|rip)---}
               if edtext[edi]='(' then while edtext[edi]<>')' do inc(edi);

             {---vytiskne ramecek a text---}
             inc(edi);
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
                push ax;push ax;db 66h;pop ax
                mov di,pixStart;              mov cx,pixLen;shr cx,2;jnc @noodd1;stosw;@noodd1:db 66h;rep stosw
                mov di,pixStart;add di,wrisir;mov cx,pixLen;shr cx,2;jnc @noodd2;stosw;@noodd2:db 66h;rep stosw
                end;
             end;
      DRAZKA:begin
             inc(edi);
             reframe(ii);
             asm
                {set all 4 bits
                mov ax,0f02h;mov dx,3c4h;out dx,ax}
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

        {$ifdef flipir}
        if pos('.fli',st)>0 then with now do begin
          NextEdiLine;
          FLIinside:=st;
          FLIx:=pixMid;
          FLIy:=ii*16;
          st:=ReadLine;
          CutNumberFromString(',',st,inFLIx);
          CutNumberFromString(',',st,inFLIy);
          CutNumberFromString(',',st,inFLIsir);
          CutNumberFromString(',',st,inFLIvys);
          CutNumberFromString(',',st,FLIpozadi);
          CutNumberFromString(',',st,FLIlet);
          inc(ii,2);
          end
         else
        {$endif}
begin

        GetPicSize(false{falsovat velikost,nehrabat po disku},false{neroznasobovat dably},st,xsir,xvys);

        if not DM.OpenDataFile(st) then begin
          asm push edi;mov al,mixbyte;push ax;end;
          edi:=ofs(chybi)+3;
          reframe(ii+xvys*doublescan div 32-2);
          drawline;
          reframe(ii+xvys*doublescan div 32);
          drawline;
          asm pop ax;mov mixbyte,al;pop edi;end;
          inc(ii,(xvys*doublescan div 2) div 8);
          end
         else
          begin
          {----Loudovani headeru a palety----}
          packedZbyvasize:=lastopenLength;
          ReadDataFile(5,ofs(xsir),seg(xsir));

          if now.palet=maxobrazku then errorhalt(50+9) else inc(now.palet);
          now.paletofs[now.palet+1]:=now.paletofs[now.palet]+3*barevw;
          if now.paletofs[now.palet+1]>=sizeofpaletseg then errorhalt(50+10);
          ReadDataFile(3*barevw,now.paletofs[now.palet],paletseg);
          now.kdepaletaTop[now.palet]:=16*(ii-1)-visvys;
          now.kdepaletaBot[now.palet]:=16*(ii-1)+doublescan*xvys;

          {------loudovani bitmapbody--------}
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
              FastMoveBack(workseg,packedStart,32768,packedEnd-packedStart);
              dec(packedEnd,packedStart-32768);
              packedStart:=32768;
              {doplni to do 65534}
              precist:=65535-packedEnd;
              if precist>packedZbyvasize then precist:=packedZbyvasize;
              ReadDataFile(precist,packedEnd,workseg);
{pa(1);}
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
            insertpicture(leftStart,ii,xsir,rawPackradek,doublex,doublescan);
            inc(ii,rawPackradek*doublescan div 16);
            FastMoveBack(workseg,rawPacksize,0,rawEnd-rawPacksize);
            dec(rawEnd,rawPacksize);
            dec(rawZbyvaradek,rawPackradek);
          until rawZbyvaradek=0;

(* nacteni a zobrazeni NEzkomprimovaneho obrazku

          maxradek:=(65535 div xsir) and $fff8;
          zbyvaradek:=xvys;
          repeat
            if maxradek>zbyvaradek then maxradek:=zbyvaradek;
            ReadDataFile(xsir*maxradek,0,workseg);
            insertpicture(leftStart,ii,xsir,maxradek);
            inc(ii,maxradek*doublescan div 16);
            dec(zbyvaradek,maxradek);
          until zbyvaradek=0;
*)
          DM.CloseDataFile;
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

        if size=2 then begin
                        reframe48(ii);
                        inc(edi,2);
                        InsertBardString(method,framewriseg,pixMid,0,readline{string od edi+2},k0,titlesir);
                        dec(edi,2);
                       end
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
          incButtonu;
          with now.button[now.local_buttonu] do begin
            NextEdiLine;
            Dkod_kam:=getDkod(ReadLine,true);
            x1      :=k0-dostrany;    if x1>10000 then x1:=0;
            y1      :=16*ii-16;       if size=2{bard} then inc(y1,19-16);
            x2      :=x1+titlesir;
            y2      :=y1+16*size;
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
        Reframe32(ii);
        DrawLine;
        inc(ii,global_maxfntheight);
        end;
      END;

  if (now.nowask=0) and (now.local_askstringu>0) then now.nowask:=1;

  if konvert then begin
    dec(now.radek,2);
    KonvertScreen;
    end;

  ToglyAsky:
  ReadThingFromSklad(typAskyTogly,now.whichDM,now.Dkod);
  if konvert then begin
    for j:=1 to now.local_togglu     do OneToggle   (ofs(now.toggle[j]));
    for j:=1 to now.local_askstringu do OneAskstring(ofs(now.askstring[j]));
    xorcursor(false);
    end;

  visx_shouldbe:=now.visx;
  visy_shouldbe:=now.visy;
End;


PROCEDURE DoMouseMoveCheck;
var   mi,mj,mk:word;
begin
 {---nahrada za vlastnihandler mysi---}
 if (not vlastnihandler) then begin
     ScanLastMousePress;
     if mouseactive>0 then begin
       DM.GetMouse(mi,mj,mk);
       if (mi<>now.mousex) or (mj<>now.mousey) then
         asm
          mov al,mouseactive;push ax;mov mouseactive,0
          mov al,mouseflag;mov ah,0;push ax
          push 0;call mouse
          mov ax,mi;mov now.mousex,ax
          mov ax,mj;mov now.mousey,ax
          call mouse;pop ax;mov mouseactive,al;
          end;
       end;
     end;
end;

FUNCTION F1:Boolean;begin f1:=(now.visy>=16*wriy+32) and (wriy<now.radek);end;
FUNCTION F2:Boolean;begin f2:=(now.visy< 16*wriy+16) and (wriy>0        );end;


PROCEDURE VygenerujHvezdnouPaletu(shou:boolean);
const longstar:longint=0;
var   i:byte;
begin
 inc(longstar);
 for i:=0 to 3*12-1 do pal[75+i]:=abs((8*i+longstar) mod 256-128) shr 2;
 for i:=0 to    4-1 do begin
  pal[75+3*12+3*i+1]:=abs((64*i+longstar) mod 256-128)*3 shr 3;
  pal[75+3*12+3*i+2]:=abs((64*i+longstar) mod 256-128)*3 shr 3;
  end;
 if shou then showpal(25,16);
end;

PROCEDURE PreVR;
begin
 asm cmp disabletimerthingy,0;jnz @end
     mov ax,visx_shouldbe
     mov bx,visy_shouldbe
     mov cx,lastvisx
     mov dx,lastvisy
     mov now.visx,ax
     mov now.visy,bx
     cmp ax,cx;jnz @budesetvis
     cmp bx,dx;jz @end
     @budesetvis:
     mov lastvisx,ax
     mov lastvisy,bx
     {$ifdef dostran}
     push ax;push bx..nebo naopak?;call SmoothSetvis
     {$else}
     push bx;call SplitSetvis
     {$endif}
     @end:
     end;
 (*
 if disabletimerthingy then exit;
 now.visx:=visx_shouldbe;
 now.visy:=visy_shouldbe;
 if (now.visx<>lastvisx) or (now.visy<>lastvisy) then begin
     {$ifdef dostran}
     SmoothSetvis(now.visx,now.visy);
     {$else}
     SplitSetvis(now.visy);
     {$endif}
     lastvisx:=now.visx;
     lastvisy:=now.visy;
     end;
 *)
end;

PROCEDURE TimerScrolling;
var   ii:byte;
      i,j,k,l,deltax,deltay,faktor:integer;
      poradi:string[6];
const inside:byte=0;
      waittohvezdicky:word=300;
      hvxy:word=0;
      smerOdMysi:byte=0;
      maxspd=4;

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

Begin
{if definetimer>0 then}ref:=true;
if disabletimerthingy then exit;
if playingmusicDkod>0 then inc(musiclongtimer);
if keyoff>0 then dec(keyoff);
if inside>0 then exit;
inc(inside);
{*ok?}asm db 66h;pusha;end;

 asm
   {save vga ports, bank}
    call ports2ax;push ax
    mov al,nowbank;push ax
    end;

 clearKeybBuffer;

 if setuping or menuing or editingpal then begin
          if vlastnihandler then poradi:=''
                            else poradi:='M';
          end else               poradi:=jemnedoladeniscrolu;

 for ii:=1 to length(poradi) do case poradi[ii] of

  'O','o':begin
  {---upravi sunx,y}
  if now.mousey<       2*mysiokraj then nahoru (osekej(        2*mysiokraj-now.mousey)) else
  if now.mousey>visvys-2*mysiokraj then dolu   (osekej(-visvys+2*mysiokraj+now.mousey));

  {$ifdef dostran}
  if not scrolllock then begin
   if (now.visx>0              ) and (now.mousex<         mysiokraj  ) then doleva (osekej(     -1+mysiokraj  -now.mousex))
    else
   if (now.visx<wrisir-vissir-1) and (now.mousex>vissir-1-mysiokraj-5) then doprava(osekej(-vissir+mysiokraj+5+now.mousex));
   end;
  {$endif}


  {---vypocitava novy vis podle sunx,y}
  if (sunx[sunindex]<>0) or (suny[sunindex]<>0) then begin
     j:=now.visy;
     asm
      mov al,mouseactive;push ax;mov mouseactive,0
      mov al,mouseflag;mov ah,0;push ax
      push 0;call mouse
      end;
     {$ifdef dostran}
     asm push now.visx;end;
     inc(now.visx,sunx[sunindex]);
     if now.visx<0 then now.visx:=0 else if now.visx>=wrisir-vissir then now.visx:=wrisir-vissir-1;
     asm mov ax,now.visx;mov visx_shouldbe,ax;pop now.visx;end;
     {$endif}
     asm push now.visy;end;
     inc(now.visy,suny[sunindex]);
     if now.visy<0 then now.visy:=0 else if now.visy>=16*now.radek-visvys then now.visy:=16*now.radek-visvys;
     asm mov ax,now.visy;mov visy_shouldbe,ax;pop now.visy;end;
     asm
      call movemouse
      call mouse;pop ax;mov mouseactive,al;
      end;

     {palety}
     {j:=now.visy pred posunem};
     if suny[sunindex]>0 then
     begin
      for i:=1 to now.palet do
       if (now.kdepaletaTop[i]<visy_shouldbe)<>(now.kdepaletaTop[i]<j) then SetAndVisUpperPal(i,1{visualize});
     end
     else
     if suny[sunindex]<0 then
      for i:=1 to now.palet do
       if (now.kdepaletaBot[i]<visy_shouldbe)<>(now.kdepaletaBot[i]<j) then SetAndVisUpperPal(i,1{visualize});
     sunx[sunindex]:=0;
     suny[sunindex]:=0;
     end;

  if sunindex<setrvacnost-1 then inc(sunindex) else sunindex:=0;
  end;

  'K','k':
  {---ve spravny okamzik kresli pozadi na obrazovku}
  if f1 or f2 then begin
    StoreMouseAndEms;
    while f1 or f2 do begin
      if f1 then begin inc(wriy);Ems2Screen(wriy+31);end;
      if f2 then begin dec(wriy);Ems2Screen(wriy   );end;
      end;
    RestoreMouseAndEms;
    end;

  'A','a':begin
{$ifdef flipir}
   with flihead do if fliseg>0 then if delaj>1 then dec(delaj) else begin
    delaj:=speed+1;
    inc(longtimer);
    StoreMouseAndEms;
    with now do
     Bitmap2Screen2(width,workseg,inFLIx,inFLIy,inFLIsir,inFLIvys,FLIpozadi,
             now.FLIx-inFLIsir shr 1+round(40*(  sin(longtimer/15))),
             now.FLIy shr 1         +round(20*(1+sin(longtimer/20))));
    RestoreMouseAndEms;
    if nowFLIframe<frames then inc(nowFLIframe)
                          else begin nowFLIframe:=1;frame1seg:=frame2seg;frame1ofs:=frame2ofs;end;
    prepareFLIframe;
    end;

   with now do if pir>0 then
   with flihead do with Xanimos[pir] do
    if delaj>1 then dec(delaj) else begin
     delaj:=speed+1;
     inc(longtimer);
     inc(smerodmysi,2);
     deltax:=(now.mousex+now.visx+round( 50*cos(smerodmysi/128*pi)))*16 -pirSir*8  -now.FLIx;
     deltay:=(now.mousey+now.visy+round(100*sin(smerodmysi/128*pi)))*16 -pirVys*16 -now.FLIy;
     faktor:=(abs(deltax)+abs(deltay))+3;
     faktor:=1;
     deltax:=deltax div faktor;if abs(deltax)>maxspd*16 then deltax:=maxspd*16*(deltax div abs(deltax));
     deltay:=deltay div faktor;if abs(deltay)>maxspd*16 then deltay:=maxspd*16*(deltay div abs(deltay));
     if faktor<>0 then begin
       inc(FLIx,deltax);if FLIx>60000 then FLIx:=0 else if FLIx>(wrisir-pirSir) shl 4 then FLIx:=(wrisir-pirSir) shl 4;
       inc(FLIy,deltay);if FLIy>60000 then FLIy:=0;
       end;
     StoreMouseAndEms;
     Bitmap2Screen(width,workseg,InPirX[nowFLIframe],InPirY[nowFLIframe],pirSir,pirVys,0,
                     FLIx shr 4,FLIy shr 5);
     RestoreMouseAndEms;
     nowFLIframe:=(nowFLIframe+1) mod pirs;
     end;
{$endif}
   end;

  'P','p':if now.starpal{header[h_textura]='h'} then VygenerujHvezdnouPaletu(true);

  'M','m':DoMouseMoveCheck;
     {*nejak zredukovat pocet mouseon/off v celym timeru}

  end;


 {hvezdicky}
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
    {restore vga ports, bank}
     pop ax;call bank
     pop bx;call bx2ports
     end;

 dec(inside);
{*ok?}asm db 66h;popa;end;
end;


{PROCEDURE Switch2mode(extend:boolean);
const current_extend:boolean=false;
begin
if extend<>current_extend then begin
  current_extend:=extend;
  if not extend then asm mov ax,13h;int 10h;end else begin
    ...
    end;
  setbright(0);
  end;}
PROCEDURE modeX_init;
begin
    mode13x;
    InitBank;
    asm mov ax,1010h;mov bx,41;mov dx,0;mov cx,0;int 10h{zacerni barvu 41}
        mov ax,1001h;mov bh,41{prvni volna barva};int 10h;{setne border}end;
    black41:=1;
end;

PROCEDURE CleanShell;far;
begin
 CallCommand('');
end;


{$ifdef dostran}
 {$i drivers.inc}
{$endif}



const setupnamelen=37;
{$ifdef dostran}
      menupolozek=4;
{$else}
      menupolozek=3;
{$endif}
procedure setupdata;assembler;
 asm
  db setupnamelen,'Nastaven° zvukovÇ karty              '
{$ifdef dostran}
  db setupnamelen,'Nastaven° driveru pro grafickou kartu'
{$endif}
  db setupnamelen,'Hotovo                               '
  db setupnamelen,'Ripper                               '
 end;

PROCEDURE FullSetup;far;
var   ch:char;
      choosen:byte;
label 0;
begin
 choosen:=0;
 0:
 choosen:=menuselect(menupolozek,ptr(seg(setupdata),ofs(setupdata){*+3}),setupnamelen+1,choosen);
 case choosen of
              1:begin
                {$ifdef midas}
                midasconfig;
                midasConfigured:=true;
                {$endif}
                Vga28;
                goto 0;
                end;
              {$ifdef dostran}
              2:begin
                setupdrv;
                goto 0;
                end;
              {$endif}
    menupolozek:begin
                ripper(boss);
                Vga28;
                goto 0;
                end;
            end;
end;

PROCEDURE RunShell(noisyshell:boolean;p:pointer);
var mus:word;
    loc,use:boolean;
begin
 GfxmouseOff;
 RemoveMouse;
 PrepareBrightDown(false);

 if not noisyshell then begin
   brightdownWithsound(14);
   {$ifdef midas}
   loc:=playing_localmusic;
   use:=playingUserMusic;
   mus:=playingmusicDkod;
   music(0);
   TimerAndMidasClose;
   {$endif}
   end
 else
   brightdown(14);

 ClearScreen13x;
 Vga28;
 rawGotoXy(1,61);
 ReadPal;
 brightup(20);
 clearKeybBuffer;
 port[$21]:=0;
 asm call [p];end;
 port[$21]:=mask;
 modeX_init;
 setbright(0);
 InstallMouse(vlastnihandler);

 if not noisyshell then begin
   {$ifdef midas}
{   myTmrInit; }
   myMidasInit;
   music(mus);
   playing_localmusic:=loc;
   playingUserMusic:=use;
   {$endif}
   end;
end;



var   hwsir:word;
      hwvys:word;

function Mode(n:word):boolean;
begin
 mode:=true;
 if n<$100 then asm mov ax,n;int 10h;end
           else mode:=VesaInit640x480;{asm mov ax,4f02h;mov bx,n;int 10h;cmp ax,4fh;jz @ok;mov @result,0;@ok:end;}
 refresh(10);
end;

procedure ClearScreen;assembler;
 asm mov es,sega000;mov cx,32000;mov di,0;mov ax,0;rep stosw;end;

{$i \-cd\x.inc}

FUNCTION SlideShow(userspeed:word):byte;{0-no slide,1-goback,2-goon,27-esc,68-f10}

function RipNameFromNowfl:string;
const n=6;
var   st:string;
      i:word;
begin
 st:=now.fl;
 if length(st)>n then st[0]:=chr(n);
 i:=pos('.',st);
 if i>0 then st[0]:=chr(i-1);
 RipNameFromNowfl:=st;
end;

const speeds=10;
      picformat='.PCX';
      kod_prev   =75;
      kod_timeout=999;
var   i,j,pics,olddatafajlu:word;
      st:string;
label quit,exit;
begin
 asm mov al,black41;push ax;mov black41,0;end;
 olddatafajlu:=datafajlu;
 st:=RipNameFromNowfl;
 for i:=0 to 99 do if DM.opendatafile(st+chr(48+i div 10)+chr(48+i mod 10)+picformat) then DM.closedatafile else break;
 pics:=i;
 if pics=0 then begin SlideShow:=0;goto exit;end;
 PlaySample(sam_slide);
 GfxMouseOff;
 RemoveMouse;
 tmrStopScrSync;
 port[$21]:=0;
 PrepareBrightDown(false);
 BrightDown(speeds);
 for i:=0 to pics-1 do begin
   ScanLastMousePress;
   presz:=0;
   LoadPCX(st+chr(48+i div 10)+chr(48+i mod 10)+picformat);
   BrightUp(speeds);
   j:=response(userspeed,0);
   BrightDown(speeds);
   PlaySample(sam_cvak);
   case j of 68{f10}:begin SlideShow:=68;goto quit;end;
             27{esc}:begin SlideShow:=27;goto quit;end;
             256-2,kod_prev:begin
                     if i=0 then begin SlideShow:=1;goto quit;end
                            else begin dec(i,2);end;
                     end;
             end;
   end;
 SlideShow:=2;
 quit:
 port[$21]:=mask;
 modeX_init;
 fillchar(pal,sizeof(pal),0);
 setbright(0);
 InstallMouse(vlastnihandler);
 MoveMouse;
 datafajlu:=olddatafajlu;{killne pikcry z datalistu}
 exit:
 ScanLastMousePress;
 presz:=0;
 asm pop ax;mov black41,al;end;
end;



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
      souping:boolean=false;
      lastkey:integer=10000;
      setupdrawn:boolean=false;
var   i,j,n,vistop:integer;
      k,l,m:word;
      old_dotaznikkeypressed,panely16,panelx4,mustahlo,fxtahlo:integer;
      levohore,bit,panelsize:word;
      multigoback:boolean;
      st12:string[12];
{$ifdef editor}
const unstable:byte=0;
var   stable:byte;
      r1,r2,g1,g2,b1,b2:byte;
      delta:shortint;
{$endif}
label 1,2,3,4,5,8,rightbutton,leftbutton,noglobal,pan,ending,forw,
      playingok,zaprepbright,midbutton,setcol,itisbadkey,gouback,
      redraw,f10,gobackfromlastpage;

procedure soupingend;
begin
 souping:=false;
 asm
      mov al,mouseactive;push ax;mov mouseactive,0
      mov al,mouseflag;mov ah,0;push ax
      push 0;call mouse
      end;
 DM.getmouse(now.mousex,now.mousey,m);
 asm
      call mouse;pop ax;mov mouseactive,al;
      end;
end;

procedure ProcOpenButts;
begin
 disabletimerthingy:=true;
 menuing:=true;
 playsample(sam_menuon);
 GfxMouseOff;
 AddThing2Sklad(typAskyTogly);
 nowandpal2tree;
 now.Dkod:=butts_Dkod;
 now.local_buttonu:=0;
 now.local_togglu:=0;
 now.local_askstringu:=0;
 ShowButts;
 GfxMouseOn;
 presz:=0;
 key:=0;
 disabletimerthingy:=false;
end;

procedure ProcCloseButts(sam:word);
begin
 disabletimerthingy:=true;
 playsample(sam);
 GfxMouseOff;
 RestoreUnderLocalButtons;
 asm push now.mousex;push now.mousey;end;
 tree2now;
 asm pop now.mousey;pop now.mousex;end;
 ReadThingFromSklad(typAskyTogly,now.whichDM,now.Dkod);
 GfxMouseOn;
 menuing:=false;
 presz:=0;
 key:=0;
 disabletimerthingy:=false;
end;

procedure ProcOpenSetup;
var i,j:word;
begin
 disabletimerthingy:=true;
 setuping:=true;
 Playsample(sam_setupon);
 GfxMouseOff;
 AddThing2Sklad(typAskyTogly);
 NowAndPal2Tree;
 now.Dkod        :=setup_Dkod;
 {$ifdef toglyvsetupu}
 if not ReadThingFromSklad(typAskyTogly,0,setup_Dkod) then errorhalt(23+7);
 {$endif}
 panelcentrx4:=now.visx div 4+vissir div 8;
 panelcentry:=(now.visy+visvys div 2) and $fffe;
 panelsize:=0;
 Reframe2handle(setuphandle);
 for i:=1 to setupsize div 3 do begin
   UniversalRefresh;
   for j:=panelcolors downto 0 do CentralFrame(panelsize+j,panelcolor[j]);
   inc(panelsize,3);
   end;
 for i:=4 downto 0 do CentralFrame(panelsize+i,lastpanelcolor[i]);

 {$ifdef toglyvsetupu}
 for i:=1 to now.local_togglu do with now.toggle[i] do begin
   x4:=panelcentrx4-14;
   y1:=panelcentry+40+16*2*i;

   case i of 1:stav:=0;
             2:stav:=definetimer;
             3:stav:={$ifdef dostran}byte(scrolllock){$else}0{$endif};
             end;
   OneToggle(ofs(x4));
   end;
 {$endif}

 for i:=0 to soupatek do kreslisoupatko('k',i,soupatkopos[i]);
 DM.getmouse(now.mousex,now.mousey,m);
 GfxMouseOn;
 presz:=0;
 key:=0;
 disabletimerthingy:=false;
end;

procedure ProcCloseSetup;
var i:word;
begin
 Playsample(sam_setupout);
 GfxMouseOff;
 AddThing2Sklad(typAskyTogly);
 Tree2now;
 ReadThingFromSklad(typAskyTogly,now.whichDM,now.Dkod);
 for i:=(panelcentry-2*panelsize) div 16-1 to (panelcentry+2*panelsize) div 16+1 do
   ems2screenFromx4Sir8(i,panelcentrx4-panelsize div 4-1,panelsize div 4+2);
 GfxMouseOn;
 setuping:=false;
 presz:=0;
 key:=0;
end;

procedure PushPageIncPage;
begin
 NowAndPal2Tree;
 AddThing2Sklad(typAskyTogly);
 incIntree;
 ResetNowToDefaults;
end;



Begin
  if debuginfo then writeln('StartShow...');
  FillFilebazeWith(selfDM);
  if not debuginfo then modeX_init;
  lastkey:=0;

  port[$21]:=mask;

  playing_localmusic:=false;{true -> tim prinutim prvni play aby zacal hrat}
  playingmusicDkod:=0;


{$ifdef setup}
 if not setupdrawn then begin
  if debuginfo then writeln('DrawSetup...');
  setupdrawn:=true;
  ResetNowToDefaults;
  now.fl:=setup_fl;
  PREPARESCREEN(false);
  if debuginfo then write('StoreSetup...');
  ScanCentralFrames;
  deallocEMS(now.handle);
  Reframe2handle(setuphandle);
  CopySeg(workseg,frameseg);
  {$ifdef toglyvsetupu}
  AddThing2Sklad(typAskyTogly);
  {$endif}
  UlozKonecSkladu;
  end
 else
  ObnovKonecSkladu;
{$endif}

{$ifdef editor}
  nowDMreal:=1;{*bude vse ok?}
{$endif}
  ResetNowToDefaults;
  now.fl:=name;

  if debuginfo then writeln('X-Mode...');
  if debuginfo then modeX_init;
  InstallMouse(vlastnihandler);
  setbright(0);
  tmrGetScrSync(@tmrScrSync);
  goto 2;


  1:
  PrepareBrightDown(true);
  zaprepbright:
  GfxMouseOff;
{ifdef timer
  if not vypinattimer then tmrSyncScr(@timerBrightDown)
   else
{endif}
    BrightDown(16);

  2:

  presz:=0;
  GfxMouseOff;
  {kdyz neni pripravena screena tak ji pripravi}
  PREPARESCREEN(true);
  MoveMouse;
{$ifdef flipir}
  {kdyz je na screene FLI, tak to pripravi}
  if now.FLIinside>'' then initFLI(now.FLIinside);
{$endif}

{$ifdef midas}
  if playingusermusic then goto playingok;
  {zmeni hudbu pokud se hraje neco co na tuto stranku nepatri}
  for i:=1 to now.Lmuzik do if TheSameMusic(now.Lmuziky[i].Dkod) then goto playingok;
  Music(2000);
  playingok:
{$endif}

(*
{ifdef timer}
  if synced then begin
   {zrychleny stmivani}
   while nowbright>8 do begin
    i:=nowbright;
    repeat until nowbright<>i;
    case nowbright of 9..50:dec(nowbright,8);
                    51..100:dec(nowbright,6);
                   101..255:dec(nowbright,5);
                   end;
    end;
   tmrStopScrSync;
   end;
{endif}
*)
 (*
  if pos('.fli',now.fl)>0 then begin {-----------play fli------------}
    asm mov ax,13h;int 10h;end;
    repeat
    until (port[$60]=55) or (presz>0);
    modeX_init;
    goto rightbutton;
    end;
  setbright(0);
  *)

  redraw:

  setbright(0);
  fillchar(sunx,2*sizeof(sunx),0);

{$ifdef editor}
  if palmysozmena and (intree=1) then ppp.palabsolute:=palmysozmeny;
  if pouzij_prevF3visy then begin
    now.visy:=prevF3visy;
    visy_shouldbe:=prevF3visy;
    pouzij_prevF3visy:=false;
    end;
{$endif}
  {vyhledani a nastaveni aktualni picture palet}
  for i:=now.palet downto 1 do if (now.visy>=now.kdepaletaTop[i]) and (now.visy<=now.kdepaletaBot[i]) then begin
    SetAndVisUpperPal(i,0{not vis});
    break;
    end;
  {nastaveni background palety}
  ppp.palabsolute:=now.pal40;
  if now.starpal then VygenerujHvezdnouPaletu(false);
{$ifdef flipir}
  if now.pir>0 then initPIR(Xanimos[now.pir].filename+'.pir');
{$endif}
  {etc...}
  wriy:=now.visy shr 4;
  {$ifdef dostran}
  SmoothSetvis(now.visx,now.visy);
  {$else}
  SplitSetvis(now.visy);
  {$endif}
  for i:=0 to 31 do Ems2Screen(wriy+i);

{$ifdef editor}
  BrightUp(16);
{$else}
  BrightUp(30);
{$endif}
  mouseactive:=1;
  DoMouseMoveCheck;
  GfxMouseOn;

  playsamplefromdisk(now.Dkod_samplin);

{$ifdef midas}
  if intree=1 then ProcOpenButts;
{$endif}

  if definetimer>0 then tmrSyncScr(@timerScrolling);
  key:=0;

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
                   keyadd+72,keyadd+80:if now.local_askstringu<=1 then lastkey:=0;end;
   if i<>lastkey then begin lastkey:=i;key:=i;end else key:=0;


   if dotaznikkeypressed>0 then dec(dotaznikkeypressed);

{$ifdef midas}
   {spusteni druhy hudby}
   if (not playingusermusic) and (stridanihudby>0) and (musiclongtimer>3600*stridanihudby) then begin
     musiclongtimer:=0;
     music(2000);
     end;
{$endif}

   {GLOBAL KEYS}
   CASE KEY OF
               88:begin
                  f10:
                  AddThing2Sklad(typAskyTogly);
                  errorhalt(99);
                  end;
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
                1:begin{---------ESC---------}
                  if setuping then ProcCloseSetup else
                  if menuing then ProcCloseButts(sam_menuout) else
                   {$ifdef pareniste}
                   ProcOpenButts;
                   {$else}
                   goto ending;
                   {$endif}
                  end;

               {$ifdef dostran}
               70:begin
                  if setuping then with now.toggle[{%}2] do begin
                    if stav=0 then stav:=1 else stav:=0;{stav:=1-stav;}
                    GfxMouseOff;
                    OneToggle(ofs(x4));
                    GfxMouseOn;
                    end;
                  asm {prehodi svetylko scrollock}
                      xor locks,1;xor scrolllock,1
                      call lightlocks;
                      end;
                  end;
               {$endif}

(*               15:begin
                  if VGA_MODE=2 then mode13x else
                  if VESAviditelnychBanku>0 then {allow vesa stuff...}
                   if not VesaInit512x480 then errorhalt(17{'Tvñj VESA BIOS nechce nahodit 512x480/256.'})
                    else begin

                      end;
                  setbright(255);
                  end;*)
{$ifdef editor}
                 32:if intree=1 then begin{full pal 2 defaults}
                    ppp.palabsolute:=txtpal;
                    palmysozmeny:=ppp.palabsolute;
                    palmysozmena:=true;
                    showpal(1,40);{(1,255);}
                    end;
                 31:if intree=1 then begin{system pal 2 defaults}
                    for i:=3*13 to 3*24+2 do ppp.palabsolute[i]:=txtpal[i];
                    palmysozmeny:=ppp.palabsolute;
                    palmysozmena:=true;
                    showpal(1,40);{(1,255);}
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
                    showpal(1,40);{(1,255);}
                    end;
             10..13:if intree=1 then begin
                    stable:=key-1;
                    unstable:=stable;
                    goto setcol;
                    end;
        2..9,15..30:if intree=1 then if unstable=0 then begin
                      setcolor(border,30,30,30);
                      if key<14 then unstable:=key-1
                                else unstable:=55-key{key+10};
                      end
                    else begin
                      if ((unstable<13) and (key>13)) or
                         ((unstable>12) and (key<14)) then goto ItIsBadKey;
                      setcol:
                      setcolor(border,0,0,0);
                      if key<14 then stable:=key-1
                                else stable:=55-key{key+10};
                      r1:=pal[3*stable  ];
                      g1:=pal[3*stable+1];
                      b1:=pal[3*stable+2];
                      b2:=32;
                      editingpal:=true;
                      repeat
                        DM.getmouse(k,l,m);
                        case m of 1:if b2>0 then dec(b2);
                                  2:if b2<63 then inc(b2);
                                  end;
                        r2:=k*63 div vissir;
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
                        universalrefresh;
                        showpal(1,40);
                      until m>=3;
                      setcolor(border,0,0,63);UniversalRefresh;setcolor(border,0,0,0);
                      editingpal:=false;
                      unstable:=0;
                      palmysozmeny:=ppp.palabsolute;
                      palmysozmena:=true;
                      ItIsBadKey:
                      repeat DM.getmouse(k,l,m) until m=0;
                      repeat presz:=0;ScanLastMousePress;until presz=0;
                      key:=0;
                      end;
{$endif}

{$ifdef midas}
              2..11:if (now.nowask=0) and not setuping then begin
                    hlasitosthudby:=63*(key-2) div 9;
                    midasMastervolume(hlasitosthudby);
                    end else goto noglobal;
             59..67:begin
                    mutemusic:=false;
                    choosemusic(key-59);
                    end;
                 68:begin
                    mutemusic:=false;
                    choosemusic(2000);
                    end;
                 87:begin
                    mutemusic:=not mutemusic;
                    if mutemusic then music(0)
                                 else music(2000);
                    end;
{$endif}
               ELSE BEGIN noglobal:

   {DOTAZNIK KEYS}
   if not (setuping or menuing) then{killuje askstring keys v setuping}
   {kdyz je jen 1 askstring, nepotrebuje sipky up/down}
   if (now.nowask>0) and not ( (now.local_askstringu=1) and ((key=keyadd+80) or (key=keyadd+72)) ) then begin
    {reakce na stisk sipek v ankete}
    if dotaznikkeypressed>0 then begin
     i:=now.askstring[now.nowask].y16;
     if (i<wriy+3) then nahoru(20) else if (i>wriy+31-5) then dolu(20) else dotaznikkeypressed:=0;
     end;
    if (key>0) then begin
     GfxMouseOff;
     xorcursor(true);
     case key of
        keyadd+72:if now.nowask>1 then begin dec(now.nowask);now.nowaskx:=1;end;
     28,keyadd+80:if now.nowask<now.local_askstringu then begin inc(now.nowask);now.nowaskx:=1;end;
        keyadd+77:if now.nowaskx<now.askstring[now.nowask].znaku then inc(now.nowaskx);
        keyadd+75:if now.nowaskx>1 then dec(now.nowaskx);
               14:if now.nowaskx>1 then with now.askstring[now.nowask] do begin {backspace}
                    dec(now.nowaskx);
                    for j:=now.nowaskx to znaku-1 do stav[j]:=stav[j+1];
                    stav[znaku]:=#0;
                    end;
               83:with now.askstring[now.nowask] do begin {delete}
                    for j:=now.nowaskx to znaku-1 do stav[j]:=stav[j+1];
                    stav[znaku]:=#0;
                    end;
            2..57:if (now.nowask>0) and (decode[key]>#0) then with now.askstring[now.nowask] do begin
                    for j:=znaku downto now.nowaskx+1 do stav[j]:=stav[j-1];
                    stav[now.nowaskx]:=decode[key];
                    if now.nowaskx<znaku then inc(now.nowaskx);
                    end;
              else goto 8;
            end;
     i:=now.askstring[now.nowask].y16;
     if (i<wriy+3) or (i>wriy+31-5) then dotaznikkeypressed:=150 else dotaznikkeypressed:=0;
     OneAskString(ofs(now.askstring[now.nowask]));
     if (i>=wriy) and (i<=wriy+31){neni mimo obraz} then ems2screen(i);
     8:
     xorcursor(true);
     GfxMouseOn;
     case key of
         keyadd+72,keyadd+75,keyadd+77,keyadd+80:keyoff:=5;{sipky v askstringu}
                                           14,83:keyoff:=8;{back/delete v askstringu}
                                             end;
     end
    end

   else

   {NO_DOTAZNIK KEYS}
   if not (setuping or menuing) then case key of
               keyadd+80:dolu   (setrvacnost);
               keyadd+72:nahoru (setrvacnost);
               {$ifdef dostran}
               keyadd+77:if not odd(locks) then doprava(setrvacnost);
               keyadd+75:if not odd(locks) then doleva (setrvacnost);
               {$endif}
               end;

               END;
               END;


  {---------keyoff}END;


                          {.......SCROLLING.......}
  if definetimer=0 then begin
    PreVR;
    timerScrolling;
    end;




                   {............MOUSE PRESS............}

   case presz of
                 0:if souping then goto leftbutton;
              4,16:if souping then soupingend;
{$ifdef setup}
                32:BEGIN
                   midbutton:
                   {---OPEN SETUP PANEL---}
                   if setuping or menuing then else ProcOpenSetup;
                   END;
{$endif}
                 8:BEGIN
                   rightbutton:
{$ifdef setup}
                   {---CLOSE SETUP PANEL---}
                   if setuping then ProcCloseSetup else
{$endif}
                   {---CLOSE MENU BUTTs---}
                   if menuing then ProcCloseButts(sam_menuout) else
                   if intree=1 then ProcOpenButts else begin
                     {---MENU BACK---}
                     multigoback:=false;
                     gouback:
                     GfxMouseOff;
                     tmrStopScrSync;
                     if now.Dkod_samplout>0 then playsamplefromdisk(now.Dkod_samplout) else playsample(sam_goback);
                     AddThing2Sklad(typAskyTogly);
                     {---Kill CurPage---}
                     DeallocEMS(now.handle);
                     dec(intree);
                     {---Kill Multiple Pages If Any---}
                     if multigoback then
                      for j:=1 to now.jumppagesback do if intree>1{kvuli multi_backu v editoru} then begin
                       DeallocEMS(tree[intree].handle);
                       dec(intree);
                       end;
                     tree2now;
                     FillFilebazeWith(now.whichDM);
                     goto 1;
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
                   k:=now.visx+presx;
                   for i:=1 to now.local_togglu do with now.toggle[i] do
                    if (k>=x4 shl 2) and (k<x4 shl 2+14) and (j>=y1) and (j<y1+16) then begin

                      {obycejnej togl bez ripu}
                      if Dkod_ripu=0 then begin
                        if Dkod_sampl[stav]=0 then Playsample(sam_togl)
                                              else Playsamplefromdisk(Dkod_sampl[stav]);
                        stav:=1-stav;
                        end
                      {$ifdef pareniste}
                      {togl s ripem, uz ripnuto}
                      else if stav=1 then begin
                        if Dkod_sampl[1]=0 then PlaySampleFromDisk(getDkod(sam_ne,true))
                                           else PlaySampleFromDisk(Dkod_sampl[1]);
                        end
                      {togl s ripem, ted ripnuto}
                      else if rip(Dkod_ripu) then begin
                        if Dkod_sampl[0]=0 then PlaySampleFromDisk(getDkod(sam_rip,true))
                                           else PlaySampleFromDisk(Dkod_sampl[0]);
                        stav:=1;
                        end
                      {togl s ripem, nepodarilo se ripnout}
                      else begin
                        if Dkod_sampl[1]=0 then PlaySampleFromDisk(getDkod(sam_ne,true))
                                           else PlaySampleFromDisk(Dkod_sampl[1]);
                        end
                      {$endif};

                      GfxMouseOff;
                      OneToggle(ofs(x4));
                      if not setuping then ems2screenFromx4Sir8(y1 div 16,x4,2);
                      GfxMouseOn;
{$ifdef setup}
                      if setuping then case i of
                              {%}
                              1:begin
                                {$ifdef pareniste}
                                if not RipBmp then PlaySampleFromDisk(getDkod(sam_ne,true))
                                              else PlaySampleFromDisk(getDkod(sam_rip,true));
                                {$endif}
                                GfxMouseOff;
                                stav:=1-stav;
                                OneToggle(ofs(x4));
                                GfxMouseOn;
                                end;
                              2:begin
                                if definetimer=0 then begin
                                  definetimer:=1;
                                  tmrSyncScr(@timerScrolling);
                                  end
                                else begin
                                  definetimer:=0;
                                  tmrStopScrSync;
                                  end;
                                end;
{$ifdef dostran}
                              3:begin
                                scrolllock:=not scrolllock;
                                locks:=locks xor 1;
                                lightlocks;
                                end;
{$endif}
                              end;
{$endif}

                      goto 5;
                      end;

                   {---klik do askstringu---}
                   j:=(now.visy+presy) shr 4;
                   for i:=1 to now.local_askstringu do with now.askstring[i] do
                    if (y16=j) and (presx+now.visx>x4*4) and (presx+now.visx<x4*4+znaku*8) then begin
                      GfxMouseOff;
                      xorcursor(true);
                      now.nowask:=i;
                      now.nowaskx:=1+(presx+now.visx-x4*4) div 8;
                      xorcursor(true);
                      GfxMouseOn;
                      goto 5;
                      end;
{$ifdef setup}
                   {---klik do soupatka---}
                   if setuping then begin
                     DM.getmouse(k,l,m);
                     for i:=0 to soupatek do
                      if (k>soupatkox[i]-10) and (k<soupatkox[i]+soupatkosir+10) and
                         (l>soupatkoy[i]   ) and (l<soupatkoy[i]+soupatkovys) then begin
                           GfxMouseOff;
                           kreslisoupatko('m',i,soupatkopos[i]);{obnovi pozadi}
                           soupatkopos[i]:=shortint(k-soupatkox[i]);
                           if soupatkopos[i]<0 then soupatkopos[i]:=0;
                           if soupatkopos[i]>63 then soupatkopos[i]:=63;
                           souping:=true;
                           kreslisoupatko('k',i,soupatkopos[i]);
                           GfxMouseOn;
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
                   {i...cislo presslyho buttonu}
                   {j...cilovej Dkod}
                   {k...jumppagesback}
                   k:=0;
                   if passwordFits then goto 4;
                   for i:=1 to now.local_buttonu do with now.button[i] do
                     if (now.visx+presx>x1) and (now.visx+presx<x2) and
                        (now.visy+presy>y1) and (now.visy+presy<y2) then begin

                      j:=Dkod_kam;

                      4:
                      GfxMouseOff;
                      tmrStopScrSync;

                      if menuing then begin
                        ProcCloseButts(sam_goon);
                        case    i     of 2:RunShell(false,@fullsetup);
                                         3:begin
                                           {$ifdef pareniste}
                                           PlaySampleFromDisk(getDkod(sam_goodbye,true));
                                           {$endif}
                                           goto ending;
                                           end;
                                         {
                                         1:RunShell(false,@usershell);
                                         1:RunShell(false,@cleanshell);
                                         1:RunShell(true,@cleanshell);
                                         }
                                      else begin
                                           PushPageIncPage;
                                           FillFilebazeWith(j);
                                           now.fl:=title;
                                           if j=selfDM then now.fl:='!'+{$ifdef editor}'ed'+{$endif}menu;
                                           PrepareBrightDown(false);
                                           goto zaprepbright;
                                           end;
                                      end;
                        goto 2;
                        end;

                      if pos('.PCX',data[j].name)>0 then begin
                        now.fl:=copy(data[j].name,1,pos('.',data[j].name)-3);
                        l:=SlideShow(0);
                        now.fl:=data[now.Dkod].name;
                        goto 1;
                        end;

                      forw:
                      if now.Dkod_samplout>0 then playsamplefromdisk(now.Dkod_samplout) else playsample(sam_goon);
                      if passwordFits then j:=GetDkod(passwordPage,true);
                      PushPageIncPage;
                      now.fl:=data[j].name;
                      now.jumppagesback:=k;
                      goto 1;
                      end;

                   if now.Dkod<=datafajlu then begin
                     l:=SlideShow(350);
                     case l of        1:goto redraw;
                                     68:goto f10;
                                 0,2,27:begin
                                        st12:=data[now.Dkod].name;
                                        inc(st12[length(st12)]);
                                        j:=GetDkod(st12,false);
                                        {skok z bleble_i na bleble_i+1}
                                        if j>0 then begin
                                          k:=now.jumppagesback+1;
                                          goto 4;
                                          end;
                                        {skok z title na menu}
                                        if now.fl=title then begin
                                          j:=GetDkod(menu,false);
                                          if j>0 then goto 4;
                                          end;
                                        {skok z bleble_last na menu}
                                        if now.jumppagesback>0 then begin
                                          gobackfromlastpage:
                                          multigoback:=true;
                                          goto gouback;
                                          end;
                                        {zadnej skok}
                                        if l<>0 then
                                         if intree=1 then goto redraw
                                                     else goto gouback;
                                        {goback pri 1strankovym clanku}
                                        if (intree>1) and (l=0) and
                                           (now.local_buttonu=0) and
                                           (now.local_togglu=0) and
                                           (now.local_askstringu=0) then goto gouback;{}
                                        end;
                                   else errorhalt(100+3);
                                   end;
                     {PlaySample(sam_ne);{*tady ne}
                     end;

                   END;
           END;

   5:
   UniversalRefresh;

  until false;


  ending:
  PrepareBrightDown(false);
  tmrStopScrSync;
{$ifdef pareniste}
  brightdownWithsound(28);
  CONVbigfontDone;
{$else}
  brightdown(8);
{$endif}

  RemoveMouse;
  EMSvirtualpagesDone;
  port[$21]:=0;
  ExitBank;

End;


{€€€ﬁﬁﬁ›ﬁ‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹ E D I T O R ‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹}
{$ifdef editor}

PROCEDURE Adjustedfajlindata;
var   i:word;
      st:string;
begin
 datafajlu:=furtfajlu;{resetglobals}
 {
 st:=edfajl;
 upcasestring(st);
 for i:=1 to datafajlu do with data[i] do if name=st then
  len:=edtextlast+1-headerofs;
 }
end;

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
  {adjust data.len}
   call adjustedfajlindata
  {}
   mov edzmena,0
   @9:
   end;

PROCEDURE WriteLine(var y:word);
var x,x2,xy,i,j,k,lastadr,maxheight:word;
label 1,2;
begin
 {predpokladam ze se pracuje s minifnt=0 o vysce 1}
 maxheight:=1;
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
   if wlcha=chgcol then begin
     inc(edi);
     if edtext[edi]='e' then minifnt:=minifnt xor 1
                        else wlcol:=mixcolstxt[(ord(edtext[edi])-ord('a'))];
     end
   else
   if (edi=blokstart) and blokon then asm mov es,workseg;mov di,xy;mov ax,256*14+'[';stosw;mov xy,di;end else
   if (edi=blokend)   and blokon then asm mov es,workseg;mov di,xy;mov ax,256*14+']';stosw;mov xy,di;end else
    asm mov es,workseg;mov di,xy;mov ax,[offset wlcha];stosw;mov xy,di;
        cmp minifnt,1;jnz @end;mov maxheight,2;mov al,'ﬂ';mov [es:di+2*txsir-2],ax
        @end:
        end;
   end;
 edi:=Wnewedi;
 inc(y,maxheight);
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
     if edtext[i]=chgcol then inc(i) else inc(ednowx);
   end;
{*  kurzor na prvni radce (prazdny) odstavce
    na druhy je napis
    zmacknu delete a searchxylinenow najde blbou polohu}
end;

FUNCTION VeryStartLine:word;
var i:word;
begin
 i:=edofs[linenow];
 while edtext[i-1]=TAB do dec(i);
 case edtext[i-1] of INSPIC,MRAMOR,TABULKA:dec(i);end;
 case edtext[i-2] of INSBIGCHAR,INSBUTTON:dec(i,2);end;
 VeryStartLine:=i;
end;

const infocolor_normal=16*2+11;
      infocolor_higher=16*2+10;
      infocolor_wrong =16*2+12;

PROCEDURE Info_Cls;assembler;
 asm mov es,segb800;mov di,0;mov ax,infocolor_normal*256+32;mov cx,160;rep stosw;
     end;

PROCEDURE Info_ClsAttr(first,leng:word);assembler;
 asm mov es,segb800;mov di,first;add di,di;mov ax,infocolor_normal;mov cx,leng;@1:inc di;stosb;loop @1
     end;

PROCEDURE Info_File;
begin
 textattr:=infocolor_normal;
{ rawgotoxy(2,1+infoline);write(edfajl,'       ');}
 asm push nowvis;mov nowvis,0;end;
 wrixy(2,1+infoline,edfajl+'       ');
 asm pop nowvis;end;
end;

PROCEDURE Info_XY;
begin
 asm mov ah,3;mov bh,0;int 10h;PUSH DX;end;
 rawgotoxy(55,1+infoline);write('sloupec:',nowsloupec,' ');
 rawgotoxy(68,1+infoline);write('x:',ednowx,'  ');
 rawgotoxy(74,1+infoline);write('y:',ednowy,'  ');
 asm mov ah,2;mov bh,0;POP DX;int 10h;end;
 Info_ClsAttr(54,80-55);
end;

PROCEDURE Info_Size;
var   i:word;
      c:byte;
const x1=17;
      x2=36;
begin
 i:=ReadInteger(headerofs)-2;
 case i of 0..199:c:=infocolor_normal;
         200..252:c:=infocolor_higher;
             else c:=infocolor_wrong;
             end;
 rawgotoxy(x1,1+infoline);write(i,' lines');
 asm mov es,segb800;
     mov di,2*x1-1;mov al,c;mov cx,11{xxxxx lines};@1:stosb;inc di;loop @1;end;

 i:=edtextlast-headerofs+1;
 case i of 0..9999:            c:=infocolor_normal;
           10000..edtextmaxlen:c:=infocolor_higher;
           else                c:=infocolor_wrong;
           end;
 rawgotoxy(x2,1+infoline);write(i,' bytes');
 asm mov es,segb800;
     mov di,2*x2-1;mov al,c;mov cx,11{xxxxx bytes};@1:stosb;inc di;loop @1;end;
end;

PROCEDURE Info_Msg(st:string);
begin
 info_cls;
{ rawgotoxy(1+(txsir-length(st)) shr 1,1+infoline);write(st);}
 textattr:=infocolor_normal;
 asm push nowvis;mov nowvis,0;end;
 wrixy(1+(txsir-length(st)) shr 1,1+infoline,st);
 asm pop nowvis;end;
end;

FUNCTION FileSelectPro(flags:byte;veta,typ,preselect:string):string;
begin
 info_msg('FILE SELECTOR '+typ);
 FileSelectPro:=FileSelect(flags,veta,typ,preselect);
 info_cls;
 info_file;
end;

PROCEDURE RefreshTextScreen(checkpicsizes:boolean);
var   ch,c2:char;
      st:string;
      oldst:string[30];
      st4:string[4];
      size:byte;
      ii,ii_fake,iimax,i,j,k,l,
      qixStart,qixLen,qedi:word;
      hedr4:array[1..2] of word;

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
 asm mov es,workseg;mov di,2*shiftsetvis;db 66h;mov ax,720h;dw 720h;mov cx,253*80/2;db 66h;rep stosw;
     mov cx,80;mov ax,256*0fh+'!';rep stosw
 end;

 edi:=edtextofs;
 repeat NextEdiLine until edtext[edi]=newsloupec;
{ if (ord(header[h_flags]) and f_vlastni_pal)>0 then inc(edi,122);}
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
        end;
      INSPIC:begin
        inc(edi);
        oldst:=ReadLine;
        st:=oldst;
        if checkpicsizes then begin
          GetPicSize(false,false,st,i,j);{oseka kraje st, necha jen fajlnejm}
          if DM.opendatafile(st) then begin
            ReadDataFile(4,ofs(hedr4),seg(hedr4));
            DM.CloseDataFile;
            st:=oldst;
            DelSpaces(edi,length(st));
            k:=pos('(',st);if k>0 then st[0]:=chr(k-1);
            str(hedr4[1],st4);st:=st+'('+st4+',';
            str(hedr4[2],st4);st:=st+st4+')';
            InsertSpaces(edi,length(st));
            move(st[1],edtext[edi],length(st));
            if st<>oldst then edzmena:=1;
            end
           else
            st:=oldst;
          end;
        GetPicSize(false{falsovat},true{roznasobit dably},st,i,j);
        if i>0 then begin{-----X-----}
          TextBox((pixMid-i div 2) div pixMinicharsir,ii,i div pixMinicharsir,j div 16,ord('∞')+256*7);
          inc(ii,j div 16);
          asm mov al,wlcol;push ax;mov wlcol,7;end;
          ii_fake:=ii-j div 32-1;
          WriteLine(ii_fake);
          asm pop ax;mov wlcol,al;end;
          end
         else begin{-----FLI-----}
          i:=200;
          TextBox((pixMid-i div 2) div pixMinicharsir,ii,i div pixMinicharsir,2,ord('±')+256*11);
          asm mov al,wlcol;push ax;mov wlcol,7;end;
          WriteLine(ii);
          WriteLine(ii);
          asm pop ax;mov wlcol,al;end;
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
        ii_fake:=ii-j div 16-1;
        WriteLine(ii_fake);
        if ch=INSBUTTON then WriteLine(ii_fake);
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
      ELSE begin WriteLine(ii);end;
      END;

  if ii>iimax then iimax:=ii;
 until edi>edtextlast;
 Patka;

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
 info_size;
 gotoxyavis(ednowx+1,ednowy+1,1{forceCopy});
End;


PROCEDURE CheckScrol;
const speed:shortint=0;
      maxspeed:byte=10;
var   nowY,i,zbyva:integer;
begin
(* nowY:=smoothYonScreen+(bioscharvys+1)*YinWorkseg;
 zbyva:=scroll2Y-nowY;
 if zbyva<>0 then begin
   if (speed< maxspeed)
       {INC kdyz jedu dolu moc pomalu}
     and (((zbyva>0) and ((speed<0) or  (speed*speed<zbyva)))
       {INC kdyz jedu nahoru moc rychle}
       or ((zbyva<0) and  (speed<0) and (speed*speed>-2*zbyva))) then inc(speed) else
   if (speed>-maxspeed)
       {DEC kdyz jedu nahoru moc pomalu}
     and (((zbyva<0) and ((speed>0) or  (speed*speed<-zbyva)))
       {DEC kdyz jedu dolu moc rychle}
       or ((zbyva>0) and  (speed>0) and (speed*speed>2*zbyva))) then dec(speed);
   if abs(speed)>abs(zbyva) then nowY:=scroll2Y else inc(nowY,speed);
   i:=nowY mod (bioscharvys+1);if i<>smoothYonScreen then setSmoothY(i);
   i:=nowY div (bioscharvys+1);if i<>YinWorkseg then setYinWorkseg(i);
   refresh(1);
   end;(**)
end;

{
FUNCTION WhereToSplit:word;
const i:word=0;
var code:word;
begin
 if i=0 then
  val(ask('M†® podivnò poáet ©†dek cizináe...'#13' Na kolik†tou scanlajnu m†m hodit infolajnu ? ',3,'380','0'),i,code);
 wheretosplit:=i;
end;
}
PROCEDURE SplittedTextmode;
begin
 asm
     push 0;call setbright
     mov es,sega000;mov di,0;db 66h;xor ax,ax;mov cx,32768/2;db 66h;rep stosw
     mov ax,3;int 10h
     mov es,segb800;mov di,0;db 66h;mov ax,720h;dw 720h;mov cx,32768/4;db 66h;rep stosw
     end;
 case biostxvys of 24:splitY(384);
                   27:splitY(375);
                 else splitY((400 div (biostxvys+1))*biostxvys);{wheretosplit);}
                 end;
 setvis(skiplines*txsir);
end;


PROCEDURE DbThingy;assembler;
asm
db hdr_kni-5
db 13,10,13,10,'intelektu†ln° £rove§, estetickò z†ëitek',13,10,insbigchar,'p-*****'
db 13,10,13,10,'napàt°, átivost, Mark Stone index',13,10,insbigchar,'p-*****'
db 13,10,13,10,0

db hdr_hra-5
db 13,10,13,10,mramor,13,10,tabulka,'tvñrce: '
db 13,10,'druh: '
db 13,10,'status: '
db 13,10,'hodnocen°: '
db 13,10,'testov†no na: '
db 13,10,'existuje je®tà na: '
db 13,10,'velikost: '
db 13,10,'poëadavky na poá°taá: '
db 13,10,'grafika: '
db 13,10,'zvuk: '
db 13,10
db 13,10,'grafika: %'
db 13,10,'hudba: %'
db 13,10,'atraktivita: %'
db 13,10,13,10,13,10,insbigchar,'p-*****',13,10,13,10,0
end;


PROCEDURE EDITOR;
var   i,j                 :word;
      m,n                 :integer;
      special             :byte;
      st                  :string;
      st8                 :string[8];
      pre                 :string;
      searchstring        :string[20];
      suckpicsizesfromdisk:boolean;
   {help}
      f                   :text;
      ch                  :char;

label 0,1,2,4,5,6,7,8,10,newodst;
Begin
 if biostxsir<>txsir then errorhalt(12);
 SplittedTextmode;
 info_cls;
 searchstring:='';
 edfajl:='';
 0:{new file}
 YinWorkseg:=0;
 smoothYonScreen:=0;
 scroll2Y:=0;
 prevF3visy:=0;
 if pos('.',edfajl)>0 then edfajl[0]:=chr(pos('.',edfajl)-1);
 edfajl:=fileselectpro(2{EscVraciNic},'Zadej pracovn° jmÇno ál†nku...','*.',edfajl);

 if length(edfajl)=0 then begin asm mov ax,3;int 10h;end;errorhalt(0);end;
 edfajl[length(edfajl)+1]:=#0;
 ednowi:=edtextofs;
 nowSloupec:=1;
 blokstart:=0;
 blokend:=0;
 blokon:=false;
 4:
 {precte text.soubor}
 MoveTextFile2EdText(edfajl);
 info_file;

 if header[h_free1]<>'0' then begin
   header[h_free1]:='0';
   edzmena:=1;
   end;

 if header[h_tabs]='0' then begin
   header[h_tabs]:='5';
   edzmena:=1;
   end;

 if palmysozmena then begin
   palmysozmena:=false;
   ppp.palabsolute:=palmysozmeny;
   for i:=0 to 119 do edtext[edtextofs+i]:=chr(pal[3+i]+32);
   edzmena:=1;
   end;

 suckpicsizesfromdisk:=true;
 1:
 RefreshTextScreen(suckpicsizesfromdisk);
 suckpicsizesfromdisk:=false;

 repeat
   10:
   gotoxyavis(ednowx+1,ednowy+1,0{no forcecopy});
   info_xy;
   SearchMyEdi;
   ednowi:=edi;


   repeat

     CheckScrol;

     asm mov i,0;mov ax,3;int 33h;cmp bx,2;jnz @noth;mov i,1;@noth:end;
     if i=1 then begin
       moveTxtMouse(100,100);
       getmousechange(m,n);
       repeat
                   refresh(4);
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
                     RefreshTextScreen(false);
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
                  splitY(500);
                  errorfile:='editor.hlp';
                  if not DM.opendatafile(errorfile) then errorhalt(14);
                  with data[getDkod(errorfile,true)] do ZavesFileHandler(handle,start);
                  help('editor.hlp');
                  OdpojFileHandler;
                  DM.closedatafile;
                  splittedtextmode;
                  info_cls;
                  info_file;
                  goto 1;
                  end;
{f2=save}     #60:SaveEditorFile;
{f3=save&show}#61:if frameseg=0 then ask(1{fuk},#13' Sorry, nemas zadnou EMS ',0,'',' ') else
                  if (texturhandle=0) or (skladhandle=0) {$ifdef setup}or (setuphandle=0){$endif}
                    then ask(1{fuk},#13' Sorry, mas zatracene malo EMS ',0,'',' ') else
                  begin
                   SaveEditorFile;
                   pouzij_prevF3visy:=true;
                   palmysozmena:=false;
                   Show(edfajl);
                   ClearScreen13x;
                   while keypressed do readkey;
                   prevF3visy:=now.visy;
                   SplittedTextmode;
                   refresh(14);
                   info_cls;
                   goto 4;
                  end;
{f5=color}#63,#88,#98,#108,#99:begin
                  if edtext[edi-2]=CHGCOL then dec(edi,2);
                  if edtext[edi ]<>CHGCOL then begin
                    InsertSpaces(edi,2);
                    edtext[edi]:=CHGCOL;
                    end;
                  case ch of #63:edtext[edi+1]:='a';
                             #88:edtext[edi+1]:='b';
                             #98:edtext[edi+1]:='c';
                            #108:edtext[edi+1]:='d';
                             #99:edtext[edi+1]:='e';{doublefont}
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
                  st:=fileselectpro(2{EscVraciNic},'JmÇno ál†nku na kterò se odkazuje®...','*.','');
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
                  if ch=#66 then st:=fileselectpro(2{EscVraciNic},'Zadej jmÇno obr†zku *.X','x\*.x','')
                            else st:=fileselectpro(2{EscVraciNic},'Zadej jmÇno animace *.FLI','*.fli','');
                  if length(st)=0 then goto 1;
                  if pos('.',st)=0 then if ch=#66 then st:=st+'.x' else st:=st+'.fli';
                  ednowi:=VeryStartLine;
                  st:=inspic+st;
                  if ch=#91 then st:=st+defaultfli;
                  InsertSpaces(ednowi,length(st));
                  for i:=1 to length(st) do edtext[ednowi-1+i]:=st[i];
                  edzmena:=1;
                  suckpicsizesfromdisk:=true;{prihodi velikost pikcru}
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
                    if (edtext[i]=chgcol) or (edtext[i]=#13) then inc(i) else inc(ednowx);
                    inc(i);
                    end;
                  {if edtext[edi]=' ' then inc(edi);}
                  end;
{---------------OSTATNI-----------------}
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
                    st:=ask(0{no ins},'Jakou barvu ? (a,A,b,B,c...H)'#13'(velkò p°smeno=vàt®° n†pis)',1,edtext[edi+1],'A');
                    if st[0]=#1 then begin
                      edtext[edi+1]:=st[1];
                      edzmena:=1;
                      goto 1;
                      end;
                    end;
                  end;
{alt-p pozadi}#25:begin
                  st:=ask(0{no insert},'Zadej typ backgroundovÇ textury (a,b,c,d,e,h,x,y,z)',1,header[h_textura],'a');
                  if (st[0]=#1) and (st[1]<>header[h_textura]) then begin
                    header[h_textura]:=st[1];
                    edzmena:=1;
                    end;
                  end;
{alt-s search}#31,#32:begin
                  if ch=#31 then searchstring:=ask(1{inserty},' Search string: ',20,searchstring,' ');
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
                  st:=ask(0{no insert},
                          'Flags: 0,0,1,1,doublefont,vlastn° paleta,togl v°c vpravo,barevnÇ r†meáky'#13+
                          ' Zat°m jsou vyuëity pouze posledn° t©i bity, ostatn° nemà§ ! ',8,st8,'0');
                  if (st[0]=#8) and (st<>st8) then begin
                    j:=0;
                    for i:=1 to 8 do j:=2*j+ord(st[i])-48;
                    header[h_flags]:=chr(j);
                    edzmena:=1;
                    end;
                  end;
{alt-x}       #45:begin
                  altx:=menuselect(hdrinsertu,@hdrinserty[1].popis,sizeof(hdrinserty) div hdrinsertu,altx);
                  if altx>0 then with hdrinserty[altx] do case altx of
                      hdr_mus,hdr_sin,hdr_sou,hdr_pir,hdr_ank,hdr_hes:begin
                           if (altx=hdr_hes) and (boss=0) then begin
                             ask(1{fuk},#13' Sorry, to sm° jen boss. ',0,'',' ');
                             goto 1;
                             end;
                           pre:=GetHeaderString(txt);
                           if altx=hdr_hes then begin
                             pre:=PasswordDecoded(pre);
                             st:=ask(1{inserty},'HESLO1,str†nka1,HESLO2,str†nka2...',60,pre,' ');
                             end
                           else
                             st:=FileSelectPro(0{EscVraciPre},popis,typ,pre);
                           if (st<>pre) then begin
                             if altx=hdr_hes then st:=PasswordCoded(st);
                             SetHeaderString(txt,st);
                             edzmena:=1;
                             end;
                           goto 1;
                           end;
                      hdr_tab:begin
                           st:=ask(0{no insert},'Zadej kolik tabel†torñ se m† vej°t do ®°©ky jednoho sloupce',
                               1,header[h_tabs],'1');
                           if (st[0]=#1) and (st[1]<>header[h_tabs]) then begin
                             header[h_tabs]:=st[1];
                             edzmena:=1;
                             goto 1;
                             end;
                           end;
                      hdr_imp:begin
                           st:=fileselectpro(2{EscVraciNic},'Textovò soubor, kterò sem chce® vloëit','*.*','');
                           if sluzby.opendatafile(st) then begin
                             i:=LengthDatafile;
                             InsertSpaces(edi,i);
                             ReadDataFile(i,edi,dseg);
                             sluzby.CloseDataFile;
                             edzmena:=1;
                             end;
                           goto 1;
                           end;
                      hdr_kni..hdr_hra:begin
                           i:=ofs(DbThingy);
                           while mem[cseg:i]<>altx-5 do inc(i);inc(i);
                           while mem[cseg:i]<>0 do begin inc(edtextlast);edtext[edtextlast]:=chr(mem[cseg:i]);inc(i);end;
                           edzmena:=1;
                           goto 1;
                           end;
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
{'s' 's':begin
          assign(f,'pal.inc');
          rewrite(f);
          for i:=1 to 40 do begin
            write(f,'        ',pal[3*i],',',pal[3*i+1],',',pal[3*i+2]);
            if i=40 then writeln(f,');') else writeln(f,',');
            end;
          close(f);
          end;}
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
          {kdyz maze posledni radek odstavce...}
          if (edtext[ednowi-2]<>#13) and (edtext[edi-2]=#13)
            {...a zaroven to neni kvuli tabum...
            and (edtext[ednowi-3]<>#9)...
            {...nesmi pritom smazat cr/lf na konci one radky}
            then special:=2 else special:=0;
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


const FakeIniName='work.$$$';
FUNCTION delFake_renMy2Fake_ripMy(My:stringpath):boolean;
label quit;
begin
 delFake_renMy2Fake_ripMy:=false;
 case DeleteFile(workdir+FakeIniName) of 0,2:else goto quit;end;
 if RenameFile(workDir+My,workDir+FakeIniName,false)>0 then goto quit;
 if not rip(getdkod(My,true)) then goto quit;
 delFake_renMy2Fake_ripMy:=true;
 quit:
end;


const setupnamelen2=28;
procedure setupdata2;assembler;
 asm
  db setupnamelen2,'Bàëet v ReadOnly m¢du       '
  db setupnamelen2,'Pouë°t C:\DISKMAGS\PARENIST\'{curworkdir}
  db setupnamelen2,'Zadat jinò pracovn° adres†© '
 end;

PROCEDURE AskWorkDir;
var   ch:char;
      choosen:word;
      ok:boolean;

label 1,start;
begin
 mesidz('Program pot©ebuje pracovn° adres†© pro konfiguraán° soubor apod.',-9);
 choosen:=2;
 start:
 choosen:=menuselect(3,ptr(cseg,ofs(setupdata2){*+3}),setupnamelen2+1,choosen);
 case choosen of 0:workdir:='';
                 1:readonly:=true;
                 2:workdir:=curworkdir;
                 3:begin
                   workdir:=ask(2{EscVraciNic}+1{inserty},'Zadej cestu do pracovn°ho adres†©e.',40,curworkdir,'!');
                   if workdir='' then goto start;
                   end;
                 end;
 ZalomPath(workDir);
 UpCaseString(@workDir);
 ok:=MakeAndEnterDir(workdir);
 CD(curdir);
end;

PROCEDURE GetIni;
var   i:word;
      opet,forced:boolean;
label done,poslednipokus,noini;
begin
 opet:=false;
 forced:=false;
 if not localReadIni(curdir,INIname) then
  if not localReadIni(cestaKexe,INIname) then
   if not localReadIni(curWorkDir,INIname) then
    poslednipokus:localReadIni(workDir,INIname);{cte INI}
 if (verzeIni>verzenum) and (not forcecurworkdir) then errorhalt(6);
 if readonly then goto done;
 if usedIniName='' then begin
   noini:
   if (not forced) and forcecurworkdir then begin
     forced:=true;
     workdir:=curworkdir;
     MakeAndEnterDir(workdir);
     CD(curdir);
     end;
   if rip(getDkod(IniName,true)) then goto poslednipokus else begin
     if opet then mesidz('Tento adres†© nelze pouë°t, zadej jinò.',-6);
     opet:=true;
     AskWorkDir;
     if ReadOnly then goto done;
     if workdir='' then errorhalt(0);
     goto poslednipokus;
     end;
   end
 else if (verzeIni<verzenum) then begin
   if not delFake_renMy2Fake_ripMy(IniName) then errorhalt(45);
   VerzeIni:=VerzeNum;
   ModifyIniPodleIni(workdir+IniName,workdir+FakeIniName);
   DeleteFile(workdir+FakeIniName);
   localReadIni(workdir,IniName);
   end;
 startupSetup:=setupAbsolute;
 {$ifdef dostran}
 startupDrv:=vgaDriver;
 {$endif}
 done:
end;

PROCEDURE ZpracujParametry;
var  i:word;
     st:string;
begin
 for i:=1 to paramcount do begin
   st:=paramstr(i);
   case st[1] of '/','-':delete(st,1,1);end;
   upcasestring(@st);
   if st>'' then
    case st[1] of '?','H':begin
                      writeln('?,H    - seznam parametrñ');
                      writeln('C      - CD m¢d: Je-li t©eba, pouëije adres†© ',curworkdir,'.');
                      writeln('         TÇë snese DISKMAG.INI vytvo©enò novàj®° verz° DISKMAG.EXE.');
                      writeln('D      - vypisuje debuginfo (pouëij kdyë na zaá†tku tuhne)');
                      writeln('R      - readonly (nezapisuje INI ani anketn° l°stky)');
{                      writeln('#cesta - pro INI a anketn° l°stky bude pouëit zadanò adres†©');}
{                      writeln('Sn†zev - spust° rovnou zadanò DM soubor');}
                      errorhalt(0);
                      end;
                  'C':forcecurworkdir:=true;
                  'D':debuginfo:=true;
                  'R':readonly:=true;
{                  '#':workdir:=copy(st,2,255);}
                  'B':boss:=1;
                 else begin
                      writeln('Nezn†mò parametr "',paramstr(i),'".');
                      errorhalt(0);
                      end;
                 end;
   end;
end;

VAR lastvar:byte;{-------------posledni promenna-------------}

BEGIN
  fillchar(firstvar,ofs(lastvar)-ofs(firstvar),0);{vynuluje vsechno}
  biosfree:=@errorhalt;
  edtextofs:=ofs(edtextbody);
  headerofs:=ofs(header);
  randomize;
  ZpracujParametry;
  if debuginfo then begin
    asm mov ax,3;int 10h;end;
    writeln('Start...');
    writeln('Zabijim zle demony...');
    end;
  {$ifdef midas}
  midasSetDefaults;
  {$endif}
  InitDataFile;{provadet co nejdriv - nastavuje string 'cestaKexe'}
  GetCurDir;   {provadet co nejdriv - nastavuje string 'curdir'}
  if workdir='' then workdir:=curdir;
  if cestaKexe='' then cestaKexe:=curdir;

  if debuginfo then writeln('Memory...');
  MemInit;{provadet driv nez neco loaduju skrz workseg}

{$ifdef pareniste}
  if frameseg=0 then errorhalt(2);
  if texturhandle=0 then errorhalt(3);
  if skladhandle=0 then errorhalt(3);
  {$ifdef setup}
  if setuphandle=0 then errorhalt(3);
  {$endif}
{$endif}

  if debuginfo then writeln('DMs...');
  ScanAllDMs;

  if debuginfo then writeln('FillFilebase...');
  FillFilebazeWith(selfDM);

  if debuginfo then writeln('INI...');
  GetIni;

  {$ifdef dostran}
  if VgaDriver='' then DetekceVga;
  if VgaDriver>'' then loadVGAdriver;
  {$endif}

  if debuginfo then writeln('Keyboard...');
  InitKeyb;

  if debuginfo then writeln('VESA...');
  VESAinit;{ve VESAviditelnychbanku je 255, tahle proc tam vrazi spravny cislo}
  ZmerProporceTenkyhoFontu;

  if debuginfo then writeln('Mouse...');
  (*
  if byte(vlastnihandler)=255 then{autodetekuje ps/2 a nastavi vlastnihandler}
    asm mov ax,24h;int 33h;cmp cl,0;jnz @nechathandler;mov vlastnihandler,0;@nechathandler:end;
  *)
  ResetMouse;

  if debuginfo then writeln('Timer...');
  myTmrInit;

{$ifdef pareniste}
  Show('!'+title+chr(ord('a')+boss));
{$else}
  editor;
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
6,7    - cislo Xanimose: 1,2,3

---CONV MEMORY---
 131 editor (cseg,dseg,sseg)
 1?? pareni (cseg,dseg,sseg)
  64 workseg
  60 FX samply
  15 patterny & other midas stuff
  50 prinejmensim tolik pro bigfont
 150 prinejmensim tolik pro modulovy samply

---EMS MEMORY---
  64 setup screen bitmap
 192 3 textury
2048 maximalni stranka

---PROCEDURY LEZOUCI NA SCREENU---
ems2screen                   done
ems2screenfromxtox           done
bitmap2screen                done
mouse                        done
ano                          done
kreslisoupatko               done
xorcursor                    done
hvezdicky                    na to kaslu
zaverecny strileni           done
centralframe                 done

---dungeonovy hlasky:---
 you have gained an experience level
 starfields wiped out, freaks jubilant
 6386 experience points added to stockpile
 warning warning, low stamina
 you have found a rotten fish, 25 hit points down
 warning, hit points depleted

---FAR FUTURE---
ed:	skok na zacatek odstavce... zacina-li odstavec tabem, skoci to jinam
ed:	ctrlY+tab
ed:	radka zacinajici ˛ se v textvieweru objevi pokazdy v jiny x position
pri fillfbaze vybirat novejsi verze souboru pokud jsou na disku mimo DM
pred reloadem samplesetu killnout vsechny bigchary
zkusit enablovat v midasu EMS
shell
uzivatelsky doladeni palety
nejak chytrejc switchovat paletu
animos/pirat
sejv BMP=sloucit palety pikcru do jedny

---TO DO---
pred releasem nastavit optimalni INI
pred releasem nastavit mask=2
$S-
na posledni chvili updatnout !news

?slide nekdy jede bez pauzy!!!
?pri f1 v [...] zatuhne
?nekdy pada pri vstupu do lideshow kdyz je $S+
?jump par10/title, esc, setup -> dos(ehalt(0)??) nebo blby znaky v menuselectoru
?zatuhne uprostred vyplnovani ankety
?soubor titlea/b nenalezen (diskmag.exe) i kdyz evidentne diskmag.dm OK
?pauza pred naskocenim editoru???
?neuvolni gus memory/loaduje mod se zaplym timrem
chyba 25 ve skladisti pri prvnim spusteni ppo delsich upravach, podruhy ok

-togl s dkodem>0 nekonvertovat 1->0, pouze 0->1
-na konci playsamplefromdisk(goodbye.wav)
-tabhry=tabknihy
-nastavit v DMku verzi na 040 kvuli ze starej EXE nezvlada multiple ank.
-ed: po alt-d a enter se pokusi otevrit nesmysl a ceka na par stisku klaves
-jen kdyz askutoglu=0 a butts=0
-nezacyklit se kdyz je save=0 a ono to neoznaci done pages
-pri sejvu ank.listku umazat #0
-sejvit anketu z vice stranek
-na strance inzerce ihned skok do slideshow

druhej togl v setupu=bosskey
zmrsi paletu u posledniho pikcru ze slideshow??
clanek o (s)vga rozlisenich pro recenzenty
ed: pri f8 zacistit radku aby nebyl pic.xbleble(size)
setridit DMka za behu diskmag.exe aby byly v menu po sobe
diskmag /r abc.dm
font z score.exe
2 kanaly na samply
je 16kanalu i se samplkanalem?
editovanej fajl radit do stejnyho DM jako "..." fajly
zlepsit dekoder na novy anketni listky

