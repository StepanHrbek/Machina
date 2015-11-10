Unit      Setup; {$i define.inc}

{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}
                             INTERFACE
{‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹}

Uses      Chyby,Memo,
          Dos,Objects,
          Mys,Ini,Vga,Scrol,Tools,Sys,Stringy,CS,Fajly,Cache,
          Atoms,DMAtoms,
          DMFile,DMBitmap,Writer2,Dialogy,DMExport,Supp,
          List,Spoj,
          {$ifdef rain}
          Rain2;
          {$else}
          Midas,Mconfig,Midas2;
          {$endif}

Function  Init:TError;
Procedure Done;


{---------------------------------------------------------------------------
 INI
 ---------------------------------------------------------------------------}

var
      IniVerze             :word;
      IniLanguage          :string;
      IniUkladat           :boolean;

function SecSelector(var sekce:openstring;var varstab:pointer):PathStr;far;

var   UsedIniName          :PathStr;{jmeno pouziteho (posledne nacteneho) ini souboru}

PROCEDURE GetIni;
PROCEDURE SaveIni;


{---------------------------------------------------------------------------
 CmdLine
 ---------------------------------------------------------------------------}

FUNCTION ZpracujParametry:boolean;


{---------------------------------------------------------------------------
 Vars...
 ---------------------------------------------------------------------------}

var   lastpage             :string;


{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}
                          IMPLEMENTATION
{‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹}

Uses NfDos;

{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ INI ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}

const IniName              ='DM.INI';

function IniVzor:FileStr;
begin
 IniVzor:='!DM_'+language+'.INI';
end;

var absoluteSS:TSoundSystem2 absolute SS;

var tmp_preciseClock:boolean;
    tmp_mouseHandler:boolean;
    tmp_musSwitching:integer;

procedure BeforeWriting;
begin
 tmp_preciseClock :=GetPreciseClock;
 tmp_mouseHandler :=mouseHandler;
 tmp_musSwitching :=SS.musGetSwitching;
end;

procedure AfterReading;
begin
 SetPreciseClock(tmp_preciseClock);
 mouseSetHandler(tmp_mouseHandler);
 SS.musSetSwitching(tmp_musSwitching);
end;

{---------------------------------------------------------------------------
 Seznam promennych v INI.
 SYNTAXE: nazev malymi pismeny,0,flags,typ,offset promenne v datasegmentu
 ---------------------------------------------------------------------------}
PROCEDURE Vars;assembler;
 asm
  {---AUDIO---}
  {$ifdef rain}
  db 'amplification'    ,0,i_use1       ,i_long;dw offset absoluteSS.amp_long
  db 'musicvolume'      ,0,i_use1       ,i_byte;dw offset absoluteSS.musVolume
  db 'fxvolume'         ,0,i_use1       ,i_byte;dw offset absoluteSS.smpVolume
  {$else}
  db 'soundcard'        ,0,i_use2+i_dwrf,i_word;dw offset midasSDnumber
  db 'cardtype'         ,0,i_use2+i_dwrf,i_word;dw offset midasSDcard
  db 'outputmode'       ,0,i_use2+i_dwrf,i_word;dw offset midasOutputMode
  db 'irq'              ,0,i_use2+i_dwrf,i_word;dw offset midasSDirq
  db 'dma'              ,0,i_use2+i_dwrf,i_word;dw offset midasSDdma
  db 'port'             ,0,i_use2+i_dwrf,i_hexw;dw offset midasSDport
  db 'mixrate'          ,0,i_use2       ,i_word;dw offset midasMixRate
  db 'musicchannels'    ,0,i_use1+i_neup,i_byte;dw offset midasMaxMusChannels
  db 'fxchannels'       ,0,i_use1+i_neup,i_byte;dw offset midasFxChannels
  db 'amplifier'        ,0,i_use1       ,i_word;dw offset midasAmplification
  db 'musicvolume'      ,0,i_use1       ,i_byte;dw offset absoluteSS.musVolume
  db 'fxvolume'         ,0,i_use1       ,i_byte;dw offset absoluteSS.smpVolume
  {$endif}
  {---MAIN---}
  db 'language'         ,0,       i_neup,i_stri;dw offset IniLanguage
  db 'keyboardcoding'   ,0,i_use1       ,i_byte;dw offset csPreferred
  db 'buttonpics'       ,0,i_use1       ,i_bool;dw offset ButtPics
  db 'showresolutions'  ,0,i_use1       ,i_bool;dw offset ShowResolutions
  db 'staticmode'       ,0,i_use1+i_renz,i_mode;dw offset staticMode
  db 'infobar'          ,0,i_use1       ,i_bool;dw offset infobar
  db 'interactivetests' ,0,i_use1       ,i_bool;dw offset t_interact
  db 'avoidbadgfx'      ,0,i_use1       ,i_bool;dw offset avoidBadGfx
  db 'irq2'             ,0,i_use1       ,i_bool;dw offset irq2_enabled
  db 'preciseclock'     ,0,i_use1       ,i_bool;dw offset tmp_preciseClock
  db 'mousehandler'     ,0,i_use1       ,i_bool;dw offset tmp_mouseHandler
  db 'shell'            ,0,i_use1       ,i_stri;dw offset Shell
  db 'musicchanger'     ,0,i_use1       ,i_intg;dw offset tmp_musSwitching
  db 'musicrandom'      ,0,i_use1       ,i_bool;dw offset absoluteSS.musRandom
  db 'musicdir'         ,0,i_use1       ,i_stri;dw offset dirBrowseMods
  db 'slideshow'        ,0,i_use1       ,i_byte;dw offset RychlostSlideshow
  db 'screensaver'      ,0,i_use1       ,i_byte;dw offset ScreenSaver
  db 'autoscrolspeed'   ,0,i_use1       ,i_byte;dw offset AutoscrolSpeed
  db 'arrowssensitivity',0,i_use1       ,i_byte;dw offset CitlivostSipek
  db 'numpadsensitivity',0,i_use1       ,i_byte;dw offset CitlivostNumpadu
  db 'mousesensitivity' ,0,i_use1       ,i_byte;dw offset mouseSpeed
  db 'mousesize'        ,0,i_use1       ,i_byte;dw offset mouseSize
  db 'mousecentering'   ,0,i_use1       ,i_byte;dw offset ChovaniMysi
  db 'fadein'           ,0,i_use1       ,i_byte;dw offset fadein
  db 'fadeout'          ,0,i_use1       ,i_byte;dw offset fadeout
  {$ifdef timer}
  db 'usetimer'         ,0,i_use1       ,i_bool;dw offset UseTimer
  {$endif}
  db 'cache'            ,0,i_use1       ,i_bool;dw offset caching
  db 'dumbmode'         ,0,i_use1       ,i_bool;dw offset Dumb
  db 'oldieswarnings'   ,0,i_use1       ,i_intg;dw offset oldiesWarnings
  db 'iniversion'       ,0,       i_neup,i_word;dw offset IniVerze
  db 'saveini'          ,0,i_use1       ,i_bool;dw offset IniUkladat
  db 'loadatoms'        ,0,i_use1       ,i_bool;dw offset NacitatAtomy
  db 'saveatoms'        ,0,i_use1       ,i_byte;dw offset UkladatAtomy
  {---EDITOR---}
  db 'resolution'       ,0,i_use1       ,i_2wor;dw offset TxtRes
  db 'common'           ,0,i_use1       ,i_stri;dw offset LibDir
  db 'switchyz'         ,0,i_use1       ,i_bool;dw offset switchYZ
  db 'lastpage'         ,0,i_use1       ,i_stri;dw offset lastpage
  {---2HTM---}
  db 'maxlen4emphasize'     ,0,i_use1,i_word;dw offset maxlen4emphasize
  db 'maxlen4centering'     ,0,i_use1,i_word;dw offset maxlen4centering
  db 'header'               ,0,i_use1,i_stri;dw offset webHeader
  db 'bodyhardparams'       ,0,i_use1,i_stri;dw offset webBodyHard
  db 'bodysoftparams'       ,0,i_use1,i_stri;dw offset webBodySoft
  db 'emphasizeon'          ,0,i_use1,i_stri;dw offset webEmphasizeOn
  db 'emphasizeoff'         ,0,i_use1,i_stri;dw offset webEmphasizeOff
  db 'break'                ,0,i_use1,i_stri;dw offset webBreak
  db 'paraleft'             ,0,i_use1,i_stri;dw offset webParaLeft
  db 'paracenter'           ,0,i_use1,i_stri;dw offset webParaCenter
  db 'title'                ,0,i_use1,i_stri;dw offset webtitle
  db 'author'               ,0,i_use1,i_stri;dw offset webauthor
  db 'generator'            ,0,i_use1,i_bool;dw offset webgenerator
  db 0
 end;


{---------------------------------------------------------------------------
 SecSelector (viz unita INI), ktery ze vsech [iniSvgasekce:???] sekci
 cte a meni pouze [iniSvgasekce:VesaID]. Neni-li takova nalezena,
 pri ukladani ji vytvori podle vzoroveho souboru iniVgaVzor.
 Na tuto vga sekci pouzije seznam promennych Vga.Vars, na ostatni sekce Vars.
 ---------------------------------------------------------------------------}
const iniSvgasekce  ='SVGA:';
      iniSvgaVzor   ='!SVGA.INI';

var   iniRightSvgaloaded:boolean;
      iniMode:char;

FUNCTION SecSelector(var sekce:openstring;var varstab:pointer):PathStr;
begin
 {Defaultne nastavi tabulku promennych na vars, protoze tam je vetsina promennych.
  V par pripadech ale nastaveni jeste zmeni, viz nize.}
 varstab:=@vars;

 case Str2Char(sekce) of
   {zpracovani signalu pro zmenu modu}
   iniModeR,
   iniModeU,
   iniModeA,
   iniModeC,
   iniModeD:iniMode:=sekce[1];
   iniModeW:begin iniMode:=sekce[1];iniRightSvgaloaded:=false;end;
   else
     {hlavni cinnost, vetveni podle modu}
     case iniMode of

       iniModeR,{cte a pise vse krome nespravnych svga sekci}
       iniModeW:
         begin
          SecSelector:='x';
          if copy(sekce,1,length(iniSvgasekce))=locased(iniSvgasekce) then
           if copy(sekce,length(iniSvgasekce)+1,255)=locased(VesaID)
            then begin iniRightSvgaloaded:=true;varstab:=@vgavars;end
            else SecSelector:='';
         end;

       iniModeA:{nebyl-li dosud zapsan spravny vgasetup, zapise ho}
         if iniRightSvgaloaded
          then SecSelector:=''
          else begin
           sekce:=iniSvgasekce+VesaID;
           SecSelector:=iniSvgaVzor;
           iniRightSvgaloaded:=true;
           varstab:=@vgavars;
           end;

       iniModeU:{upgraduje vse co ma nova verze}
         begin
          SecSelector:='x';
          {behem upgradu kontroluje atributy promenne, proto mu musim rict
           ve ktere tabulce hledat
          {*radsi ne jinak upgradne jen 1.var v sekci
          if copy(sekce,1,length(iniSvgasekce))=locased(iniSvgasekce)
           then varstab:=@vgavars;}
         end;

       {*dokud neopravim bug v ini (a to neopravim), jsou C a D prehozene}
       iniModeC:{nezname sekce ignoruje, do nove verze je neprenese}
         if copy(sekce,1,length(iniSvgasekce))=locased(iniSvgasekce)
          then SecSelector:=IniSvgaVzor
          else SecSelector:='';

       iniModeD:{prekopci do nove verze vsechny iniSvgasekce:*}
         SecSelector:='';

       end;
   end;
end;


{nacte ini, spoustet az po midasSetDefaults}
{nastavi inidir,usedininame}
FUNCTION LocalIniRead(path:DirStr):boolean;
var boo:boolean;
    f:file;
    attr:word;
begin
 LocalIniRead:=false;
 {existuje?}
 assign(f,path+IniName);
 reset(f);
 if IOResult<>0 then exit;
 close(f);
 GetFAttr(f,attr);
 {nema nevhodny atribut?}
 if (attr and (ReadOnly+Hidden+SysFile+VolumeID+Directory))<>0 then exit;
 if debug then BiosWriteln(_(_zkousim)+' '+path+IniName);
 {neni disk readonly?}
 if dirWriteable(path) then
  if iniRead(path+IniName) then begin
    AfterReading;
    LocalIniRead:=true;
    usedINIname:=path+IniName;
    inidir:=path;
    {$ifndef rain}
    midasConfigured:=false;
    {$endif}
    {presteluje aktualni language}
    if GetCmdlineLanguage<>'' then language:=GetCmdlineLanguage else
    if IniLanguage<>'' then language:=IniLanguage;
    end;
end;

{ripne ini, nastavi inidir}
FUNCTION LocalIniRip(path:DirStr):boolean;
var   someDkod:TDkod;
      f:file;
begin
 if debug then BiosWriteln(_(_instaluji)+' '+IniName+' '+_(_do)+' '+path+'...');
 LocalIniRip:=false;
 {existuje ve filebazi?}
 someDkod:=GetDkod(IniVzor,false);
 if someDkod=0 then exit;
 {neni disk readonly?}
 if not dirWriteable(path) then exit;
 {udela misto na disku}
 assign(f,path+IniName);
 setfattr(f,0);
 erase(f);
 if IOResult<>0 then;
 {ripne to}
 inidir:=path;
 LocalIniRip:=Rip(someDkod,IniDir+IniName);
end;

Function IniNeedsTranslation:boolean;
begin
 IniNeedsTranslation:=(language<>inilanguage) and ((fileIs('a.'+language) and isLanguage)>0);
end;

{zapise posledne cteny ini}
PROCEDURE SaveIni;
var   i:byte;
begin
 if ReadOnlyMod then exit;
 if IniUkladat and (usedIniName<>'') then begin
   BeforeWriting;
   {$ifndef rain}
   if midasConfigured
    then IniUkladat:=iniWrite(usedIniName,i_use1+i_use2){sejvne midasy i normaly}
    else {$endif}IniUkladat:=iniWrite(usedIniName,i_use1);{sejvne jen normaly}
   if IniNeedsTranslation then IniUpgrade({olda}usedIniName,{vzor}IniVzor,{news}usedIniName);
   end;
 {kdyz uklada INI, ulozi i atomy}
 StoreAtoms;
end;


{Najde a nacte ini, nastavi usedininame,inidir.}
PROCEDURE GetIniNoUpdate;

 function TryIniRead(dir:pstring):boolean;far;
 begin
  TryIniRead:=LocalIniRead(dir^);
 end;

begin
 UsedIniName:='';
 {zkusi nacist ini ze standardnich adresaru}
 Dirs.FirstThat(@TryIniRead);
 {fixne nepresne zadany hodnoty}
 if not (libdir[length(libdir)] in [#0,':','\']) then libdir:=libdir+'\';
end;

{Najde a nacte nebo i vytvori ini, nastavi usedininame,inidir,readonlymod.}
PROCEDURE GetIni;

 function TryIniRead(dir:pstring):boolean;far;
 begin
  TryIniRead:=LocalIniRead(dir^);
 end;

 function TryIniRip(dir:pstring):boolean;far;
 begin
  TryIniRip:=LocalIniRip(dir^);
 end;

 procedure CheckLinkedIni;
 begin
  if (IniVerze<>verzenum)
   then erMsg(_(_erBadLinkedIniVer)) else
{  if NeedsTranslation then erMsg(_(_erBadLinkedIniLang));}
 end;

 procedure my_dlgSelectLanguage;
 var s:PScrolScreen;
 begin
  if CurScrolScreen<>nil
   then
    dlgSelectLanguage
   else begin
    New(s,Init(model_packed+model_gfx,640,480,0));
    if s<>nil then begin
      s^.SetActivity(syncMouseOn+syncEmulMouseOn+syncKHandlerOn);
      dlgSelectLanguage;
      KillObj(s);
      end;
    end;
 end;

begin
 UsedIniName:='';
 {zkusi nacist ini ze standardnich adresaru}
 if Dirs.FirstThat(@TryIniRead)=nil then begin
   {zadny ini nenasel}
   if GetCmdlineLanguage='' then my_dlgSelectLanguage;
   if readonlymod{nechci zadny ini vytvaret}
    or (Dirs.FirstThat(@TryIniRip)=nil){chci vytvaret, ale nejde to}
     or not LocalIniRead(inidir){vytvoreny nelze nacist}
      {prepne do readonly modu}
      then begin
        if not readonlymod then begin
          BiosWriteln(_(_msgJduDoReadOnly));
          BiosWriteln(_(_msgAboutSET_DM));
          readonlymod:=true;
          end;
        end
      else
        CheckLinkedIni;
   end
 else
 {nasel existujici ini}
 {kdyz je o rad novejsi nez program, haltne}
 if (IniVerze>compatto) then begin
    BiosWriteln(_i(_msgNewerIni1,UsedIniName));
    BiosWriteln(_(_msgNewerIni2));
    Halt(_erWritten);
    end
 else
 {kdyz je starsi nez program, upgradne ho}
 begin
   if (IniVerze<verzenum)
    then begin
     readonlymod:=
      {...zkusi ho upgradnout}
      not IniUpgrade({olda}IniDir+IniName,{vzor}IniVzor,{news}IniDir+IniName) or
      {...a vysledek nacist}
      not LocalIniRead(IniDir);
     if not readonlymod then CheckLinkedIni;
     end;
 end;
 {kdyz cte INI, nacte i atomy}
 LoadAtoms;
 {fixne nepresne zadany hodnoty}
 if not (libdir[length(libdir)] in [#0,':','\']) then libdir:=libdir+'\';
 SS.amp_real:=SS.amp_long;
end;


{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ INSTALL ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}

const MessageFile='DM.$$$';

Procedure InstallTo(kam:PathStr;cmd:string);

 var buduinstalovat:boolean;
     buduupdatovat:boolean;
     ohlaseno:boolean;
     _dirExe:string;

 function WantUpdate(srcdir:pstring;subdir,name:FileStr;setflags:boolean):boolean;
 var fsrc,fdest:SearchRec;
     src,dest:PathStr;
     newexists:boolean;
 begin
  src:=srcdir^+subdir+name;
  dest:=kam+subdir+name;
  FindFirst(src,anyfile-directory-volumeid,fsrc);
  if doserror<>0 then erMsg(_(_erChybiSoub)+' '+src+'.');
  FindFirst(dest,anyfile-directory-volumeid,fdest);
  newexists:=doserror=0;
  if setflags then begin
    buduinstalovat:=not newexists;
    buduupdatovat:=newexists and (fsrc.time>fdest.time);
    end;
  WantUpdate:=not newexists or (fsrc.time>fdest.time);
 end;

 procedure Update(srcdir:pstring;subdir,name:FileStr);
 begin
  if not ohlaseno then begin
    if buduinstalovat then BiosWriteln(_(_msgInstMach)+' '+kam) else
     if buduupdatovat then BiosWriteln(_(_msgUpdatMach)+' '+kam) else
                           BiosWriteln(_(_msgUpdatMach)+' '+kam);
    ohlaseno:=true;
    end;
  BiosWriteln(' '+subdir+name);
  filesCopy(fileOverwrite+fileIgnoreRO,srcdir^+subdir+name,kam+subdir);
 end;

 procedure Message2NextRun(name:PathStr);
 var f:text;
  procedure WriteToF(dir:pstring);far;
  begin
   writeln(f,dir^);
  end;
 begin
  assign(f,name);
  rewrite(f);
  if ioresult<>0 then begin ReportErr(_(_erNelzeVytvSoub)+' '+name+'.');exit;end;
  Dirs.ForEach(@WriteToF);
  if ioresult<>0 then begin ReportErr(_(_erNelzePsatSoub)+' '+name+'.');exit;end;
  close(f);
  if ioresult<>0 then begin ReportErr(_(_erNelzeZavrSoub)+' '+name+'.');exit;end;
 end;

 procedure IfWantThenUpdate(srcdir:pstring;subdir,name:FileStr);
 begin
  if WantUpdate(srcdir,subdir,name,false) then Update(srcdir,subdir,name);
 end;

 procedure UpdateThumbsFrom(srcdir:pstring);far;
 var t:SearchRec;
     found:PathStr;
     ext:ExtStr;
 begin
  {skonci hned pokud by updatoval do stejneho adresare}
  if srcdir^=UpCased(dirIns) then exit;
  {kouka na vsechny thumby v srcdir}
  FindFirst(srcdir^+'THUMBS\*.*',anyfile-directory-volumeid,t);
  while doserror=0 do begin
    if (fileIs(t.name) and (isGraphics+isLoadable))=isGraphics+isLoadable then begin
      {je uz na disku thumb k temuz projektu?}
      found:=fileFind(dirIns+'THUMBS\'+PathSlice(t.name,psName),isGraphics+isLoadable);
      {jakou ma priponu?}
      ext:=PathSlice(found,psExt);
      {pokud neni, nainstaluj nas}
      if ext='' then Update(srcdir,'THUMBS\',t.name);
      {pokud je tga, nainstaluj nas}
      if ext='TGA' then begin
        IfWantThenUpdate(srcdir,'THUMBS\',t.name);
        {pokud bylo tga nahrazeno jinym formatem, smaz tga}
        if PathSlice(t.name,psExt)<>'TGA' then begin
          {BiosWriteln('mazu '+PathSlice(t.name,psName)+'.TGA');}
          fileDelete(fileIgnoreRO,dirIns+'THUMBS\'+PathSlice(t.name,psName)+'.TGA');
          end;
        end;
      end;
    FindNext(t);
    end;
 end;

begin
 _dirExe:=dirExe;
 ohlaseno:=false;
 if not dirMake(kam) then exit;
 if WantUpdate(@_dirExe,'','DM.EXE',true) then begin
   Update(@_dirExe,'','DM.EXE');
   Update(@_dirExe,'','DM.DM');
   {Update('LANG.*');..bylo pri Uses LangFile, obsoleted by Uses Lang2}
   end;
 if WantUpdate(@_dirExe,'','RAIN.EXE',false) then begin
   Update(@_dirExe,'','RAIN.EXE');
   Update(@_dirExe,'','RAIN.LE');
   IfWantThenUpdate(@_dirExe,'','DOS4GW.EXE');
   end;
 if fileExists(dirExe+'DM.PIF') then IfWantThenUpdate(@_dirExe,'','DM.PIF');
 IfWantThenUpdate(@_dirExe,'','DM.COM');
 IfWantThenUpdate(@_dirExe,'','RTM.EXE');
 IfWantThenUpdate(@_dirExe,'','DPMI16BI.OVL');
 Dirs.ForEach(@UpdateThumbsFrom);
 if cmd<>'' then CallCommand('/c'+cmd);
 Message2NextRun(kam+MessageFile);
 if not dirChange(kam) then exit;
 return2rundir:=false;
end;


Procedure ReadMessage(name:PathStr);
var f:text;
    t:SearchRec;
begin
 FindFirst(name,0{ignoruje readonly fajly},t);
 if doserror=0 then begin
   assign(f,name);
   reset(f);
   if ioresult=0 then begin
     while not eof(f) do begin
       readln(f,name);
       if name<>'' then Dirs.Insert(NewStr(UpCased(name)));
       end;
     close(f);
     erase(f);
     if ioresult<>0 then;
     end;
   end;
end;


{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ CMDLINE ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}

Procedure HelpMe;
 procedure wr1(e:TError);
 begin
  BiosWriteln(ToAscii(_(e)));
 end;
 procedure wr2(e:TError;st:string);
 begin
  BiosWriteln(ToAscii(_i(e,st)));
 end;
begin
 BiosWriteln('');
 BiosWriteln('DEUS EX MACHINA '+verzestr+rep(' ',32-length(verzestr))+' Stepan Hrbek, (c) 1994-2002');
 BiosWriteln('');
 wr1(_parametry);
 wr1(_h);
 wr1(_r);
 wr1(_s);
 wr1(_o);
 wr2(_ii,defaultHomeDir);
 wr1(_e);
 wr2(_11,datalist);
 wr2(_22,datalist);
 wr1(_d1);
 wr1(_d2);
 wr1(_vgavesa);
 wr1(_osarellimit1);
 wr1(_osarellimit2);
 wr1(_plus);
 wr1(_minus);
 wr1(_lang);
 wr1(_adr);
 wr1(_soub);
 wr1(_swap);
end;

{---------------------------------------------------------------------------
 Zpracuje parametry a vraci jestli se ma program pokracovat.
 ---------------------------------------------------------------------------}
FUNCTION ZpracujParametry:boolean;

 function CompleteAutorun(dir:pstring):boolean;far;
 var t:SearchRec;
 begin
  FindFirst(dir^+autorun_path,anyfile-directory-volumeid,t);
  CompleteAutorun:=doserror=0;
  if doserror=0 then autorun_path:=dir^+autorun_path;
 end;

var   i:word;
      st:string;
      t:SearchRec;
      c:char;
      quick:boolean;
      destdir:PathStr;
      list:boolean;
      spoj:boolean;
      help:boolean;
label notfound;
begin
 quick:=false;
 destdir:='';
 list:=false;
 spoj:=false;
 help:=false;
 for i:=1 to paramcount do
  if not paramUsed[i] then begin
    st:=upcased(paramstr(i));
    if st='' then {has no meaning} else
    (*if st[1]=':' then {language:=copy(st,2,255)} else
    if st[1] in ['X','Y'] then {done in vga.pas} else*)
    if (st='VGA') or (st='VESA') or (st='NOVGA') or (st='NOVESA') then {done in vga.pas} else
    if (valu(st)<0) or (valu(st)>2) then {done in vga.pas} else begin
        case st[1] of '/','-':delete(st,1,1);end;
        c:=Str2Char(st);
        if c in ['?','H','I','1','2'] then quick:=true;
        if c='8' then c:=#0;
        if st>'' then
         case c of '?','H':help:=true;
                       'R':ReadOnlyMod:=true;
                       'S':begin
                           SafeMode:=true;
                           DeviceExists:=true;
                           end;
                       'O':minVerze:=30;
                       'I':begin
                           st:='';
                           {for i:=i+1 to paramcount do st:=st+' '+paramstr(i);}
                           InstallTo(dirIns,st);
                           end;
                       'E':editmod:=true;
                       'D':debug:=true;
                       '1':list:=true;
                       '2':spoj:=true;
                      else if st='DP' then debugPal:=true else
                           if st='DM' then debugMem:=true else
                           if st='DW' then debugW:=true else
                           if st='DC' then debugC:=true else
                           if st='DA' then debugAto:=true else
                           if st='DS' then debugScr:=true else
                           begin
                             {st:=FExpand(st);...nechceme doplnit curdir ale vyzkouset vsechny mozny diry}
                             if st[length(st)]='\' then dec(st[0]);{goto dir;}
                             FindFirst(st,anyfile,t);
                             {if doserror<>0 then ReportErr(_(_erNeznamParam)+' "'+paramstr(i)+'".')
                             else}
                             if (doserror=0) and ((t.attr and directory)>0) then begin
                               {st:=st+'\';
                               dir:}
                               destdir:=UpCased(FExpand(st)+'\');
                               Dirs.Insert(NewStr(destdir));
                               end
                             else begin
                               {fajl:}
                               if ((fileIs(st) and isHypertext)=0){kdyz to neni .cz .eng .}
                                and (PathSlice(st,psExt)<>'DM'){ani .dm}
                                 then ReportErr(_(_erNeznamParam)+' "'+paramstr(i)+'".'){hlasi chybu}
                                 else autorun_path:=st;{jinak to je fajl ke spusteni}
                               end;
                           end;
                      end;
        end;
    end;
 if not quick then ReadMessage(dirIns+MessageFile);

 if help then begin
   GetIniNoUpdate;
   HelpMe;
   end;

 {pokud z commandlajny prisel soubor bez cesty, zjisti v jakem je adresari}
 if autorun_path<>'' then
  {absolutni cesty a cesty s diskem jen rozexpanduje}
  if PathAbsolute(autorun_path) or (PathSlice(autorun_path,psDisk)<>'') then begin
    autorun_path:=FExpand(autorun_path);
    FindFirst(autorun_path,anyfile-directory-volumeid,t);
    if doserror<>0 then goto notfound;
    end
  {relativni cesty bez disku zkousi napojit na absolutni cesty v dirlistu}
  else if Dirs.FirstThat(@CompleteAutorun)=nil then begin
    notfound:
    ReportErr(_(_erNeznamParam)+' "'+autorun_path+'".');
    autorun_path:='';
    end;

 if list then begin
   ScanDMs(false);
   GetIniNoUpdate;
   spoj:=MakeList and spoj;
   end;
 if spoj then begin
   if not list then begin
     ScanDMs(false);
     GetIniNoUpdate;
     end;
   SpojList(destdir);
   end;
 ZpracujParametry:=not quick;
end;



{∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞INIT/DONE∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞}

const unita='setup';
var result:TError;
    oldflag:byte;

procedure UserDone;
 begin
  mem[Seg0040:$f9]:=oldflag;
  if (TError(ExitCode)=erOk) then SaveIni;
 end;

procedure UserInit;
 var i:integer;
 begin
  iniSetup(SecSelector,nil);
  IniVerze        :=0;
  IniLanguage     :='';
  IniUkladat      :=true;
  oldflag         :=mem[Seg0040:$f9];
  if oldflag=42 then begin
    BiosWrite(ToAscii(_(_msgJizSpusten)));
    i:=pos(AskKey(_(_AnoNeKecas)),_(_AnoNeKecas));
    BiosWriteln('');
    case i of
      5,6:oldflag:=0;
      3,4:begin
           UserDone;
           Halt(_erWritten);
          end;
      end;
    end;
  mem[Seg0040:$f9] :=42;
 end;

{$i initdone.inc}
{$ifdef autoinit}
BEGIN
 erCheck(Init);
{$endif}
END.