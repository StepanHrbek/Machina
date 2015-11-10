Unit      Midas2; {$i define.inc}

{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}
                             INTERFACE
{‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹}

Uses      Chyby,Memo,
          Dos,Objects,
          Midas,RawFile,MConfig,
          Stringy,Sys,Fajly,DMFile,Vga,Scrol,DMBitmap;

Type
      Fce=function:TError;

      {SoundSystem level 1:
        - longsamply
        - hudba
        - odfiltruje midasInited}
      TSoundSystem1=object(TObject)
        musVolCounter :byte;

        constructor   Init;
        procedure     Sync;
        destructor    Done;virtual;

        function      smpPlay(Dkod:TDkod;volume:word;looping:boolean;aclass,amusvolcoef:byte):boolean;
        procedure     smpSetVolume(volume:word;aclass:byte);
        procedure     smpStopClass(aclass:byte);
        procedure     smpStopAll;

        function      musPlay(mujDkod:Tdkod;volume:word):boolean;
        procedure     musStop;

                      private
                       musModule          :pointer;
                       channel            :array[0..31] of record
                                            stream:PSamplePlayer;
                                            class:byte;
                                            musVolCoef:byte;
                                            end;
                       procedure          smpStopOne(kan:byte);
                       procedure          smpForEach(something:byte;aclass:byte;volume:word);
       end;


      {SoundSystem level 2:
        - jako hudbu lze zadat i longsampl
        - automaticke prepinani hudby
        - urovne hlasitosti
        - music volume slides
        - sleep/wake}
      TSoundSystem2=object(TObject)
        smpVolume     :byte;
        musVolume     :byte;
        musSwitching  :byte;
        musMute       :boolean;

        constructor   Init;
        procedure     ReinitMidas;
        procedure     Sync;
        procedure     Sleep(speed:integer;fadeout:boolean);
        procedure     Wake;
        destructor    Done;virtual;

        procedure     smpPlayVol(Dkod:TDkod;volume:word);
        procedure     smpPlay(Dkod:TDkod);
{        procedure     smpPlay2(Dkod1,Dkod2:TDkod);
        procedure     smpPlayX(Dkods:PDkods);}
        procedure     smpStop;

        procedure     musPlay(speed:integer;fadeout:boolean;mujDkod:Tdkod);
        procedure     musPlayRandom;
        procedure     musPlayRandomIfNeeded;
        procedure     musPlayUser(n:word);
        procedure     musSetVolume(volume:word);
        procedure     musStop(speed:integer;fadeout:boolean);

        function      GetDebugInfo:string;

                      private
                       base               :TSoundSystem1;
                       musType            :byte;
                       musSleepedDkod     :TDkod;
                       musLongtimer       :longint;
                       musVolumeNow       :byte;
                       syncDanger         :boolean;
                      public{*}
                       musPlayingUser     :boolean;
                       musPlayingDkod     :TDkod;
       end;


var      SS:TSoundSystem2;
var      midasConfigured:boolean;{byl (od posledniho cteni ini) konfigurovan midas}
FUNCTION MyMidasConfig:TError;

FUNCTION RunShell(speed:integer;noisyshell:boolean;Shell:Fce):TError;
FUNCTION ExecCmd(speed:integer;noisyshell:boolean;cmd:string):TError;

Const
         midasMaxMusChannels:shortint=28;
         midasFxChannels:shortint=4;


{
poll:
 pravidelne stridat muziku
 slajdovat hlasitost samplu, tlumit pozadi kdyz hraje dlouhej smp
 hlasit errory
}

{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}
                          IMPLEMENTATION
{‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹}


FUNCTION MyMidasConfig:TError;
var   i:integer;
begin
 i:=mconfig.midasconfig;
 {kdyz uzivatel escapne config, v midasovych public promennych
  zustanou nuly a ty by se ulozily do INI. to ale nechci, takze
  pri escapnutem configu se to do INI neuklada.}
 midasConfigured:=midasConfigured or (i=1);
 MyMidasConfig:=TError(i);
end;

PROCEDURE MyMidasInit;
begin
 if (midasSDInit=0) and (swapsize=0) then begin
   if midasSDnumber=-1 then RunShell(-1,true,myMidasConfig);
   if midasSDNumber<>4 then begin
     midasInit;
     midasOpenChannels(midasFxChannels + midasMaxMusChannels);
     end;
   end;
end;


Const {tridy samplu v level 1}
      classNone=0;
      classSample=1;
      classMusic=2;

      {jakym systemem je tvorena hudba v level 2}
      musNone=0;
      musSample=1;
      musModule=2;

      {"for each" v level 1}
      feSetVolume=0;
      feStopClass=1;
      feStopAll=2;
      feSync=3;


Constructor TSoundSystem1.Init;
begin
 inherited Init;
end;

Function TSoundSystem1.smpPlay(Dkod:TDkod;volume:word;looping:boolean;aclass,amusvolcoef:byte):boolean;
var   bestkan,nowkan:integer;
      bestval,nowval:longint;
begin
 smpPlay:=false;
 if (volume>0) and (Dkod<>0) and (midasSDInit=1) and (midasSDnumber<>4) and (midasFxChannels>0) then begin
   {najde volny kanal ze stejne nebo nizsi tridy}
   bestval:=9999;
   bestkan:=-1;
   for nowkan:=0 to midasFxChannels-1 do
    with channel[nowkan] do
     if class<=aclass then begin
       if stream=nil then nowval:=0 else nowval:=stream^.GetLength;
       if nowval<=bestval then begin bestkan:=nowkan;bestval:=nowval;end;
       end;
   if bestkan<>-1 then
    with channel[bestkan] do begin
     {uvolni ho pokud je obsazen}
     smpStopOne(bestkan);
     {priradi mu stream a class samplu}
     New(stream,Init(bestkan,volume,New(PDMFileStream,Init(Dkod)),looping));
     if stream<>nil then begin
       class:=aclass;
       musVolCoef:=amusvolcoef;
       end;
     {uspech?}
     smpPlay:=stream<>nil;
     end;
   end;
end;

Procedure TSoundSystem1.smpSetVolume(volume:word;aclass:byte);
begin
 smpForEach(feSetVolume,aclass,volume);
end;

Procedure TSoundSystem1.smpStopOne(kan:byte);
begin
 with channel[kan] do begin
   KillObj(stream);
   class:=classNone;
   musVolCoef:=64;
   end;
end;

Procedure TSoundSystem1.smpStopClass(aclass:byte);
begin
 smpForEach(feStopClass,aclass,0);
end;

Procedure TSoundSystem1.smpStopAll;
begin
 smpForEach(feStopAll,0,0);
end;

Procedure TSoundSystem1.smpForEach(something:byte;aclass:byte;volume:word);
var   nowkan:word;
begin
 if (midasSDInit=1) and (midasFxChannels>0) and (midasSDnumber<>4) then
  for nowkan:=0 to midasFxChannels-1 do
   with channel[nowkan] do
    case something of
      feSync:
        {syncne vsechny}
        if stream<>nil then
         if stream^.Sync
          then smpStopOne(nowkan)
          else musVolCounter:=musVolCounter*musVolCoef div 64;
      feSetVolume:
        {nastavi hlasitost pouze u kanalu stejne tridy}
        if class=aclass then stream^.SetVolume(volume);
      feStopClass:
        {stopne pouze kanaly stejne tridy}
        if class=aclass then smpStopOne(nowkan);
      feStopAll:
        {stopne vsechny kanaly}
        smpStopOne(nowkan);
      end;
end;

Function TSoundSystem1.musPlay(mujDkod:Tdkod;volume:word):boolean;
var   i,j:integer;
      useMP:pointer;
      st:PathStr;
begin
 musPlay:=false;
 if mujDkod=0 then exit;
 myMidasInit;
 if midasSDnumber=4 then exit;

 with data(mujDkod)^ do begin
   {hleda vhodny player}
   useMP:=nil;
   for i:=0 to NUMMPLAYERS-1 do
    if PathSlice(name^,psExt)=midasExts[i] then useMP:=midasPlayers[i];
   if useMP<>nil then begin
     {loadne alone file}
     if HiWord(mujDkod)=nezkompDM then begin
       st:=LocateFile(name^);
       musModule:=midasLoadModule(Str2Pc(st),useMP,nil);
       end
     {loadne in dm file}
     else begin
       rfSuperStart:=start;
       rfSuperSize:=len;
       musModule:=midasLoadModule(Str2Pc(DM[HiWord(mujDkod)]^.fullfilename),useMP,nil);
       rfSuperStart:=0;
       rfSuperSize:=0;
       end;
     {playne}
     if musModule<>nil then begin
       midasPlayModule(musModule,midasFxChannels);
       midasMastervolume(volume);
       {uspech}
       musPlay:=true;
       end;
     end;
   if musModule=nil then ReportErr(_(_erNelzeHratModul)+' '+name^+'.');
   end;
end;

Procedure TSoundSystem1.musStop;
begin
 if musModule<>nil then begin
   smpStopAll;{*aby byl samplehandle 1 vzdy sampl z modulu}
   midasStopModule(musModule);
   midasFreeModule(musModule);
   musModule:=nil;
   end;
end;

Procedure TSoundSystem1.Sync;
begin
 smpForEach(feSync,0,0);
end;

Destructor TSoundSystem1.Done;
begin
 smpStopAll;
 musStop;
 midasClose;
 inherited Done;
end;



{---------------------------------------------------------------------------
 Init. Neinicializuje midas.
 ---------------------------------------------------------------------------}
Constructor TSoundSystem2.Init;
begin
 inherited Init;
 base.Init;
end;

Procedure TSoundSystem2.ReinitMidas;
begin
 if midasSDinit=1 then RunShell(0,false,nil) else begin
   SetHWcol(0,0,0,63);
   myMidasInit;
   SetHWcol(0,0,0,0);
   end;
end;

{---------------------------------------------------------------------------
 Sync. Kvuli dlouhym smaplum a stridani hudby.
 ---------------------------------------------------------------------------}
Procedure TSoundSystem2.Sync;
begin
 {dlouhe samply a volume sliding}
 base.musVolCounter:=musVolume;
 base.Sync;
 if not syncDanger then begin
   {volume sliding}
   if base.musVolCounter<musVolumeNow then musSetVolume(musVolumeNow-1) else
   if base.musVolCounter>musVolumeNow then musSetVolume(musVolumeNow+1);
   {music autoswitching}
   if (musPlayingDkod>0) and not musPlayingUser then dec(musLongtimer);
   if musLongtimer=1 then musPlayRandom;
   end;
end;

{---------------------------------------------------------------------------
 Docasne vypne zvukovy vystup.
 ---------------------------------------------------------------------------}
Procedure TSoundSystem2.Sleep(speed:integer;fadeout:boolean);
begin
 musSleepedDkod:=musPlayingDkod;
 musStop(speed,fadeout);
 base.Done;
end;

{---------------------------------------------------------------------------
 Opet zapne zvukovy vystup.
 Mezi Sleep a Wake nepouzivej zadne jine metody.
 ---------------------------------------------------------------------------}
Procedure TSoundSystem2.Wake;
begin
 base.Init;
 musPlay(0,false,musSleepedDkod);
end;

{---------------------------------------------------------------------------
 Done.
 ---------------------------------------------------------------------------}
Destructor TSoundSystem2.Done;
begin
 base.Done;
end;


{---------------------------------------------------------------------------
 Zahraje sampl zadanou hlasitosti.
 ---------------------------------------------------------------------------}
Procedure TSoundSystem2.smpPlayVol(Dkod:TDkod;volume:word);
var   c:char;
begin
 if Dkod<>0 then
  with data(Dkod)^ do
   if (length(name^)>=5) and (name^[length(name^)-5]='_') and (name^[length(name^)-3]='.') then begin
     c:=name^[length(name^)-4];
     case c of
       '0'..'9':base.smpPlay(Dkod,volume,false,classSample,(ord(c)-48)*64 div 10);
       '_':musPlay(16,false,Dkod);
       else ReportErr(_(_erNepovolSmpName)+': '+name^);
       end;
     end
   else
     base.smpPlay(Dkod,volume,false,classSample,64);
end;

{---------------------------------------------------------------------------
 Zahraje sampl.
 ---------------------------------------------------------------------------}
Procedure TSoundSystem2.smpPlay(Dkod:TDkod);
begin
 smpPlayVol(Dkod,smpVolume);
end;

{---------------------------------------------------------------------------
 Zahraje prvni nenulovy ze dvou samplu.
 ---------------------------------------------------------------------------}
{Procedure TSoundSystem2.smpPlay2(Dkod1,Dkod2:TDkod);
begin
 if Dkod1<>0 then smpPlay(Dkod1) else smpPlay(Dkod2);
end;

{---------------------------------------------------------------------------
 Zahraje nejaky nenulovy sampl ze seznamu.
 ---------------------------------------------------------------------------}
{Procedure TSoundSystem2.smpPlayX(Dkods:PDkods);
begin
 smpPlay(Dkods^.Random);
end;

{---------------------------------------------------------------------------
 Vypne vsechny samply.
 ---------------------------------------------------------------------------}
Procedure TSoundSystem2.smpStop;
begin
 base.smpStopClass(classSample);
end;


{---------------------------------------------------------------------------
 Pusti zadanou hudbu.
 Pri prvnim zavolani take inicializuje midas.
 ---------------------------------------------------------------------------}
Procedure TSoundSystem2.musPlay(speed:integer;fadeout:boolean;mujDkod:Tdkod);
var   i:integer;
      uspech:boolean;
begin
 {mute?}
 if musMute then mujDkod:=0;
 {nespousti znova tu samou muziku}
 if (mujDkod<>0) and (musPlayingDkod=mujDkod) then exit;
 {fade out}
 musStop(speed,fadeout);
 {je to sampl modul nebo nic?}
 if mujDkod=0 then musType:=musNone else
  if (DkodIs(mujDkod) and isSample)>0 then musType:=musSample else
   if (DkodIs(mujDkod) and isModule)>0 then musType:=musModule
    else musType:=musNone;
 {inicializuje midas}
 if (musType<>musNone) then myMidasInit;
 {playne to}
 case musType of
   musSample:uspech:=base.smpPlay(mujDkod,musVolume*2,true,classMusic,64);
   musModule:uspech:=base.musPlay(mujDkod,musVolume);
   else      uspech:=false;
   end;
 if uspech
  then begin
       musPlayingDkod:=mujDkod;
       musSetVolume(musVolume);
       end
  else musType:=musNone;
 musPlayingUser:=false;
 musLongtimer:=longint(3600)*musSwitching;
end;

{---------------------------------------------------------------------------
 Pusti nejakou hudbu ze seznamu.
 ---------------------------------------------------------------------------}
Procedure TSoundSystem2.musPlayRandom;
var   i:integer;
      mujDkod:TDkod;
begin
 {$ifdef beta}
 if CurScrolScreen=nil then erBetaMsg('musplayrandom 1');
 if CurScrolScreen^.map=nil then erBetaMsg('musplayrandom 2');
 {$endif}
 with PDMBitmap(CurScrolScreen^.Map)^ do
  if Lmuzik=0 then mujDkod:=0 else
   for i:=0 to 50 do begin
     mujDkod:=Lmuziky[1+random(Lmuzik)];
     if musPlayingDkod<>mujDkod then break;
     end;
 musPlay(16,false,mujDkod);
end;

{---------------------------------------------------------------------------
 Pokud soucasna hudba neni v seznamu, pusti nejakou ze seznamu.
 ---------------------------------------------------------------------------}
Procedure TSoundSystem2.musPlayRandomIfNeeded;
var   i:integer;
begin
 if musPlayingUser then exit;
 {$ifdef beta}
 if CurScrolScreen=nil then erBetaMsg('musplayrandomifneeded 1');
 if CurScrolScreen^.map=nil then erBetaMsg('musplayrandomifneeded 2');
 {$endif}
 with PDMBitmap(CurScrolScreen^.Map)^ do
  for i:=1 to Lmuzik do
   if musPlayingDkod=Lmuziky[i] then exit;
 musPlayRandom;
end;

{---------------------------------------------------------------------------
 Pusti n-tou hudbu ze seznamu (n jde od nuly).
 ---------------------------------------------------------------------------}
Procedure TSoundSystem2.musPlayUser(n:word);
begin
 {$ifdef beta}
 if CurScrolScreen=nil then erBetaMsg('musplayuser 1');
 if CurScrolScreen^.map=nil then erBetaMsg('musplayuser 2');
 {$endif}
 with PDMBitmap(CurScrolScreen^.Map)^ do
  if n<Lmuzik then begin
    musPlay(16,false,Lmuziky[n+1]);
    {musPlayingUser:=true;}
    {musLongtimer:=0;}
    end;
end;

{---------------------------------------------------------------------------
 Nastavi hlasitost hudby.
 ---------------------------------------------------------------------------}
Procedure TSoundSystem2.musSetVolume(volume:word);
begin
 case musType of
   musSample:base.smpSetVolume(2*volume,classMusic);
   musModule:midasMastervolume(volume);
   end;
 musVolumeNow:=volume;
end;

{---------------------------------------------------------------------------
 Plynule provede nejakou kombinaci tohoto:
  - zcernani obrazovky
  - vypnuti hudby
 ---------------------------------------------------------------------------}
Procedure TSoundSystem2.musStop(speed:integer;fadeout:boolean);
var   i,vol:integer;
begin
 {plynule faduje}
 if fadeout or (musType<>musNone) then begin
   {$ifdef beta}
   if CurScrolScreen=nil then erBetaMsg('musstop 1');
   {$endif}
   with CurScrolScreen^ do
    if mapModel<>model_text then begin
      syncDanger:=true;
      vol:=musVolumeNow;
      for i:=speed-1 downto 0 do begin
        Sync;
        if fadeout then setbright(255*i div speed);
        musSetVolume(vol*i div speed);
        end;
      syncDanger:=false;
      end;
   end;
 {definitivne to vypne}
 case musType of
   musSample:base.smpStopClass(classMusic);
   musModule:base.musStop;
   end;
 musType:=musNone;
 musPlayingDkod:=0;
end;


Function TSoundSystem2.GetDebugInfo:string;
var   st:string;
const stri_boolean:array[false..true] of string[3]=('no','yez');
begin
 st:='MUZAK INFOORMA'#13#10+
   #13#10'muzak=';
 if musPlayingDkod<>0 then st:=st+data(musPlayingDkod)^.name^;
 GetDebugInfo:=st+
   #13#10'userplay='+stri_boolean[musPlayingUser]+
   #13#10'MusicChanger='+stri(musSwitching)+'min'+
   #13#10'time2change='+stri(musLongtimer)+
   #13#10'Musicvolume='+stri(musVolume)+
   #13#10'FxVolume='+stri(smpVolume)+
   #13#10'MusicChannels='+stri(midasMaxMusChannels)+
   #13#10'FxChannels='+stri(midasFxChannels);
end;

FUNCTION RunShell(speed:integer;noisyshell:boolean;Shell:Fce):TError;
var oldactivity:TAct;

 procedure core;
 var curdir:DirStr;
 begin
   CurScreen:=nil;
   CurScrolScreen:=nil;
   asm mov ax,3;int 10h;end;
   curdir:=dirCur;
   FlushKey;
   RunShell:=Shell;
   dirChange(curdir);
 end;

begin
 if CurScreen=PScreen(CurScrolScreen) then
  with CurScrolScreen^ do begin
   oldactivity:=GetActivity;
   SetActivity(syncHolocaust);
   if not noisyshell then SS.Sleep(speed,true) else
    if speed>=0 then Fade(-speed);
   if @Shell=nil then RunShell:=erOk else Core;
   reinitSpeed:=speed;
   if @Shell<>nil then ReInit;
   if (oldactivity and syncMouseOn)<>0 then MouseShow;
   if not noisyshell then SS.Wake;
   SetActivity(oldactivity);
   mouseActions:=0;
   ResetEvents;
  end
 else if @Shell<>nil then
  with CurScreen^ do begin
   Core;  {vyniluje curscreen}
   ReInit;{zde se ale vola reinit curscreenu jeste pred vynilovanim}
  end;
 userDirty:=true;
end;

var   userexec:string;

FUNCTION FceUserExec:TError;far;
var i:integer;
begin
 if userexec='' then freeS:='' else freeS:='/c '+userexec;
 if CallCommand(freeS) then FceUserExec:=erOk else FceUserExec:=_erCallCommand;
end;

FUNCTION ExecCmd(speed:integer;noisyshell:boolean;cmd:string):TError;
begin
 userexec:=cmd;
 ExecCmd:=RunShell(speed,noisyshell,FceUserExec);
{ dlgMsg(Str2TempPc('ExitCode='+stri(DosExitCode)));}
end;


END.

