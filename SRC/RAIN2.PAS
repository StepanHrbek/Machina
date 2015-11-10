Unit      Rain2; {$i define.inc}

{$define poll_} {zapina polling, volani rainpoll z int8 (=asynchronne)}
                {nepodarilo se dotahnout do fcniho stavu, asi nelze}

{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}
                             INTERFACE
{‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹}

Uses      Chyby,Memo,
          Dos,Objects,
          Rain,
          Stringy,Sys,Fajly,DMFile,Vga,Scrol,DMBitmap,Dialogy;

{$ifdef poll}
Function  Init:TError;
Procedure Done;{}
{$endif}

Const
      maxsounds=100;

Type
      Fce=function:TError;

      {SoundSystem level 1
        smpXXX - sampl, muze jich hrat moc naraz
        lonXXX - sampl s riditelnou hlasitosti, hraje jen jeden
        musXXX - muzika s riditelnou hlasitosti, hraje jen jedna
      }
      TSoundSystem1=object(TObject)
        constructor   Init;
        procedure     Sync;
        procedure     ReportEnd(handle:longint);
        destructor    Done;virtual;

        procedure     smpPlay(Dkod:TDkod;volume:word;looping:boolean);
        procedure     smpStop;

        procedure     lonPlay(Dkod:TDkod;volume:word;looping:boolean);
        function      lonPlaying:boolean;
        procedure     lonSetVolume(volume:word);
        procedure     lonStop;

        procedure     musPlay(Dkod:TDkod;volume:word;looping:boolean);
        function      musPlaying:boolean;
        procedure     musSetVolume(volume:word);
        procedure     musStop;

                      private
                       musHandle     :longint;
                       lonHandle     :longint;
                       smpHandle     :array[1..maxsounds] of longint;
                       smps          :word;
       end;

      {playlist}
      TPlayList=object(TSortedCollection)
        constructor   Init;
        function      Compare(Key1, Key2: Pointer): Integer; virtual;
        procedure     FreeItem(Item: Pointer); virtual;
        procedure     InsertDkod(Dkod:TDkod);
        procedure     InsertName(name:PathStr);
        function      GetRandomDkod(onlyfirst:shortint):TDkod;
        function      GetPrevDkod:TDkod;
        function      GetNextDkod:TDkod;
        procedure     Reset;

                     private
                      curNdx:integer;
       end;

      {SoundSystem level 2:
        - automaticke prepinani hudby
        - urovne hlasitosti
        - music volume slides
        - sleep/wake}
      TSoundSystem2=object(TObject)
        amp_real      :real;
        amp_long      :longint;
        smpVolume     :byte;
        musVolume     :byte;
        musMute       :boolean;
        musRandom     :boolean;
        musPlaylist   :TPlayList;  {switching se odehrava v ramci tohoto playlistu}
        musPlaylistDir:boolean;    {v playlistu je uzivatelem vybrany adresar - az do navratu k muzice z projektu}
        musPlayingUserOne:boolean; {prave hraje uzivatelem vybrany modul - forever}
        RainID        :string;
        lonPlayingDkod:TDkod;
        musPlayingDkod:TDkod;
        musMutedDkod  :TDkod;

        constructor   Init;
        procedure     Sync;
        procedure     Sleep(speed:integer;fadeout:boolean);
        procedure     Wake;
        destructor    Done;virtual;

        procedure     smpPlayVol(Dkod:TDkod;volume:word);
        procedure     smpPlay(Dkod:TDkod);
        procedure     smpStop;

        procedure     lonPlay(Dkod:TDkod;ztiseni:real);
        function      lonPlaying:boolean;
        procedure     lonStop;

        procedure     musPlay(speed:integer;fadeout:boolean;mujDkod:Tdkod);
        procedure     musPlayPrev;
        procedure     musPlayNext;
        procedure     musPlayRandom(onlyfirst:shortint);

        function      musGetSwitching:integer;
        procedure     musSetSwitching(i:integer);
        procedure     musSwitch;

        function      musIsOnPlaylist(onlyfirst:shortint):boolean;
        procedure     musLoadPlaylistFromDir(dir:DirStr);
        procedure     musLoadPlaylistFromPage(p:PDMBitmap);
        procedure     musLoadFirstsPlaylistFromPage(p:PDMBitmap);

        procedure     musStop(speed:integer;fadeout:boolean);

        function      GetDebugInfo:string;

                      private
                       base               :TSoundSystem1;
                       amp_set            :longint;
                       musSwitching       :integer;
                       musSleepedDkod     :TDkod;
                       musLongtimer       :longint;
                       syncDanger         :boolean;
                       musVolMultiply     :real;

                       musVolumeNow       :byte;
                       lonVolumeNow       :byte;
                       procedure          musSetVolume(volume:word);
                       procedure          lonSetVolume(volume:word);
       end;


var      SS:TSoundSystem2;

FUNCTION RunShell(speed:integer;noisyshell:boolean;Shell:Fce):TError;
FUNCTION ExecCmd(speed:integer;noisyshell:boolean;cmd:string):TError;



{
poll:
 pravidelne stridat muziku
 slajdovat hlasitost samplu, tlumit pozadi kdyz hraje dlouhej smp
 hlasit errory
}


{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}
                          IMPLEMENTATION
{‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹}


{---------------------------------------------------------------------------
 TPlayList
 ---------------------------------------------------------------------------}

constructor TPlayList.Init;
begin
 inherited Init(30,100);
 curNdx:=-1;
end;

function TPlayList.Compare(Key1, Key2: Pointer): Integer;
var Dkod1:TDkod absolute Key1;
    Dkod2:TDkod absolute Key2;
    pname1:PString;
    pname2:PString;
begin
 pname1:=Data(Dkod1)^.name;
 pname2:=Data(Dkod2)^.name;
 if pname1^<pname2^ then Compare:=-1 else
 if pname1^>pname2^ then Compare:=1 else Compare:=0;
end;

procedure TPlayList.FreeItem(Item: Pointer);
begin
end;

procedure TPlayList.InsertDkod(Dkod:TDkod);
begin
 Insert(pointer(Dkod));
end;

procedure TPlayList.InsertName(name:PathStr);
begin
 Insert(pointer(GetDkod(name,true)));
end;

function TPlayList.GetRandomDkod(onlyfirst:shortint):TDkod;
var newNdx:word;
begin
 if onlyfirst<1 then onlyfirst:=count;
 if count=0 then begin GetRandomDkod:=0;exit;end;
 repeat
  newNdx:=random(onlyfirst);
 until (newNdx<>curNdx) or (onlyfirst<2);
 curNdx:=newNdx;
 GetRandomDkod:=TDkod(At(curNdx));
end;

function TPlayList.GetPrevDkod:TDkod;
begin
 if count=0 then begin GetPrevDkod:=0;exit;end;
 if (curNdx<=0) or (curNdx>count-1) then curNdx:=count-1 else dec(curNdx);
 GetPrevDkod:=TDkod(At(curNdx));
end;

function TPlayList.GetNextDkod:TDkod;
begin
 if count=0 then begin GetNextDkod:=0;exit;end;
 if (curNdx<0) or (curNdx>=count-1) then curNdx:=0 else inc(curNdx);
 GetNextDkod:=TDkod(At(curNdx));
end;

procedure TPlayList.Reset;
begin
 FreeAll;
 curNdx:=-1;
end;


{---------------------------------------------------------------------------
 TSoundSystem1
 ---------------------------------------------------------------------------}

Constructor TSoundSystem1.Init;
begin
 inherited Init;
end;

Procedure TSoundSystem1.smpPlay(Dkod:TDkod;volume:word;looping:boolean);
var   filename:PathStr;
      fileofs,filesize:longint;
      hh:longint;
begin
 if (volume>0) and (Dkod<>0) and (smps<maxsounds) then begin
   filename:=LoadDkodLocation(Dkod,fileofs,filesize);
   hh:=RainPlay(filename,fileofs,filesize,ord(looping),volume,0);
   {$ifdef beta}
    if smps=maxsounds then erBetaMsg('smpPlay: smps='+stri(smps+1)+' maxsounds='+stri(maxsounds));
   {$endif}
   {nasledujici 2 radky musi byt atomicka operace neprerusena reportendem}
   {to je splneno jen diky tomu ze stavajici rain chyby hlasi jen synchronne}
   inc(smps);
   smpHandle[smps]:=hh;{zde obcas po kliku na bye HLASIL "prekroceni mezi pole nebo typu" protoze smps=0}
   end;
end;

Procedure TSoundSystem1.smpStop;
var l:longint;
begin
 while smps>0 do begin
   {nutno sampl nejdriv smazat a pak volat RainStop,
    RainStop totiz muze volat ReportEnd na tentyz sampl a mazal by se 2x}
   dec(smps);
   RainStop(smpHandle[smps+1]);
   end;
end;

Procedure TSoundSystem1.lonPlay(Dkod:TDkod;volume:word;looping:boolean);
var   filename:PathStr;
      fileofs,filesize:longint;
begin
 if Dkod=0 then exit;
 if lonHandle<>0 then lonStop;
 filename:=LoadDkodLocation(Dkod,fileofs,filesize);
 lonHandle:=RainPlay(filename,fileofs,filesize,ord(looping),volume,0);
end;

Function TSoundSystem1.lonPlaying:boolean;
begin
 lonPlaying:=lonHandle<>0;
end;

Procedure TSoundSystem1.lonSetVolume(volume:word);
begin
 RainSetVolume(lonHandle,volume);
end;

Procedure TSoundSystem1.lonStop;
var h:longint;
begin
 {nutno sampl nejdriv smazat a pak volat RainStop,
  RainStop totiz muze volat ReportEnd na tentyz sampl a mazal by se 2x}
 h:=lonHandle;
 lonHandle:=0;
 RainStop(h);
end;

Procedure TSoundSystem1.musPlay(Dkod:Tdkod;volume:word;looping:boolean);
var   filename:PathStr;
      fileofs,filesize:longint;
begin
 if Dkod=0 then exit;
 if musHandle<>0 then musStop;
 filename:=LoadDkodLocation(Dkod,fileofs,filesize);
 musHandle:=RainPlay(filename,fileofs,filesize,ord(looping),volume,0);
end;

Function TSoundSystem1.musPlaying:boolean;
begin
 musPlaying:=musHandle<>0;
end;

Procedure TSoundSystem1.musSetVolume(volume:word);
begin
 RainSetVolume(musHandle,volume);
end;

Procedure TSoundSystem1.musStop;
var h:longint;
begin
 {nutno sampl nejdriv smazat a pak volat RainStop,
  RainStop totiz muze volat ReportEnd na tentyz sampl a mazal by se 2x}
 h:=musHandle;
 musHandle:=0;
 RainStop(h);
end;

Procedure TSoundSystem1.Sync;
begin
 RainPoll;
end;

Procedure TSoundSystem1.ReportEnd(handle:longint);
var i:word;
begin
 {konec samplu}
 for i:=smps downto 1 do
  if smpHandle[i]=handle then begin
    smpHandle[i]:=smpHandle[smps];
    dec(smps);
    end;
 {konec longsamplu}
 if handle=lonHandle then begin
   lonHandle:=0;
   SS.lonPlayingDkod:=0;
   SS.musVolMultiply:=1;
   end;
 {konec muziky}
 if handle=musHandle then begin
   musHandle:=0;
   SS.musPlayingUserOne:=false;
   SS.musLongtimer:=2+50;
   {playingDkod nechame nastaven a sync za chvili sam switchne}
   {SS.musPlayingDkod nesmime vynulovat at randomswitch nepusti znova totez}
   {podle musHandle=0 pozname ze uz nehraje a musi se restartnout}
   end;
end;

Destructor TSoundSystem1.Done;
begin
 musStop;
 lonStop;
 smpStop;
 inherited Done;
end;



{---------------------------------------------------------------------------
 Init.
 ---------------------------------------------------------------------------}
Procedure ReportEnd(handle:longint);far;
var snd:word;
begin
{ bioswriteln('end of '+stri(handle));}
 SS.base.ReportEnd(handle);
end;

Procedure ReportError(err:string);far;
begin
 ReportErr(err);
 {
 writeln(err);
 readkey;
 }
end;

Constructor TSoundSystem2.Init;
begin
 inherited Init;
 base.Init;
 musVolMultiply   :=1;
 musPlaylist.Init;
 musPlaylistDir   :=false;
 musPlayingUserOne:=false;
 musPlayingDkod   :=0;
 musMute          :=false;
 musRandom        :=true;
 musSwitching     :=-1;
 musVolume        :=25;
 smpVolume        :=64;
 amp_long:=100;
 amp_real:=amp_long;
 RainID:=RainInit;
 Rain.ReportError:=Rain2.ReportError;
 Rain.ReportEnd:=Rain2.ReportEnd;
 fileRegister('WAV',isPlayable+isSound+isSample);
 fileRegister('IFF',isPlayable+isSound+isSample);
 fileRegister('MP3',isPlayable+isSound+isSample);
 fileRegister('MOD',isPlayable+isSound+isModule);
 fileRegister('S3M',isPlayable+isSound+isModule);
 fileRegister('XM' ,isPlayable+isSound+isModule);
 fileRegister('IT' ,isPlayable+isSound+isModule);
end;

{---------------------------------------------------------------------------
 Sync. Kvuli reportum, streamum a stridani hudby.
 ---------------------------------------------------------------------------}
Procedure TSoundSystem2.Sync;
var musVolGoesTo:word;
    lonVolGoesTo:word;
begin
 {dlouhe samply a volume sliding}
 musVolGoesTo:=round(musVolume*musVolMultiply);
 lonVolGoesTo:=round(musVolume*2);
 base.Sync;
 if not syncDanger then begin
   {volume sliding}
   if musVolumeNow>musVolGoesTo then musSetVolume(musVolumeNow-1) else
   if musVolumeNow<musVolGoesTo then musSetVolume(musVolumeNow+1);
   if lonVolumeNow>lonVolGoesTo then lonSetVolume(lonVolumeNow-1) else
   if lonVolumeNow<lonVolGoesTo then lonSetVolume(lonVolumeNow+1);
   {music autoswitching}
   if (musPlayingDkod>0) and not musPlayingUserOne then dec(musLongtimer);
   if musLongtimer=1 then musSwitch;
   {amplification}
   if amp_long<>amp_set then begin
     RainAmplification(amp_long);
     amp_set:=amp_long;
     end;
   end;
end;

{---------------------------------------------------------------------------
 Docasne vypne zvukovy vystup.
 ---------------------------------------------------------------------------}
Procedure TSoundSystem2.Sleep(speed:integer;fadeout:boolean);
begin
end;

{---------------------------------------------------------------------------
 Opet zapne zvukovy vystup.
 Mezi Sleep a Wake nepouzivej zadne jine metody.
 ---------------------------------------------------------------------------}
Procedure TSoundSystem2.Wake;
begin
end;

{---------------------------------------------------------------------------
 Done.
 ---------------------------------------------------------------------------}
Destructor TSoundSystem2.Done;
begin
 base.Done;
 musPlaylist.Done;
 inherited Done;
end;

{---------------------------------------------------------------------------
 Zahraje sampl zadanou hlasitosti.
 Modul ci dlouhej sampl hraje jako hudebni ukazku.
 ---------------------------------------------------------------------------}
Procedure TSoundSystem2.smpPlayVol(Dkod:TDkod;volume:word);
var   c:char;
      flags:word;
begin
 if Dkod<>0 then
  with data(Dkod)^ do
   if (length(name^)>=5) and (name^[length(name^)-5]='_') and (name^[length(name^)-3]='.') then begin
     c:=name^[length(name^)-4];
     case c of
       's':base.smpPlay(Dkod,volume,false);
       '_':lonPlay(Dkod,0);
       '0'..'9':lonPlay(Dkod,(ord(c)-48)/10);
       else ReportErr(_i(_musNepovolSmpName,name^));
       end;
     end
   else begin
     flags:=DkodIs(Dkod);
     if (len>128*1024) or ((PathSlice(name^,psExt)='MP3') and (len>32*1024))
     or ((flags and isModule)>0)
      then lonPlay(Dkod,0)
      else base.smpPlay(Dkod,volume,false);
   end;
end;

{---------------------------------------------------------------------------
 Zahraje sampl.
 ---------------------------------------------------------------------------}
Procedure TSoundSystem2.smpPlay(Dkod:TDkod);
begin
 smpPlayVol(Dkod,smpVolume);
end;

{---------------------------------------------------------------------------
 Vypne vsechny samply.
 ---------------------------------------------------------------------------}
Procedure TSoundSystem2.smpStop;
begin
 base.smpStop;
end;


Procedure TSoundSystem2.lonPlay(Dkod:TDkod;ztiseni:real);
begin
 if lonPlaying
  then lonStop
  else lonVolumeNow:=round(musVolume*2);
 base.lonPlay(Dkod,lonVolumeNow,false);
 if base.lonPlaying then begin
   lonPlayingDkod:=Dkod;
   musVolMultiply:=ztiseni;
   end;
end;

Function TSoundSystem2.lonPlaying:boolean;
begin
 lonPlaying:=base.lonPlaying;
end;

Procedure TSoundSystem2.lonSetVolume(volume:word);
begin
 base.lonSetVolume(volume);
 lonVolumeNow:=volume;
end;

Procedure TSoundSystem2.lonStop;
begin
 base.lonStop;
 lonPlayingDkod:=0;
 musVolMultiply:=1;
end;

{---------------------------------------------------------------------------
 Pusti zadanou hudbu.
 Pri prvnim zavolani take inicializuje midas.
 ---------------------------------------------------------------------------}
Procedure TSoundSystem2.musPlay(speed:integer;fadeout:boolean;mujDkod:Tdkod);
var   i:integer;
begin
 {mute?}
 if musMute then mujDkod:=0;
 {nespousti znova tu samou muziku}
 if (mujDkod<>0) and (musPlayingDkod=mujDkod)
  and (base.musHandle<>0){restartni muziku kdyz dohrala a nechala playingDkod nastavenej ale musHandle je 0}
   then exit;
 {fade out}
 musStop(speed,fadeout);
 {playne to}
 base.musPlay(mujDkod,musVolume,musSwitching<>-1{loop});
 if base.musPlaying then begin
   musPlayingDkod:=mujDkod;
   musVolumeNow:=musVolume;
   end;
 musPlayingUserOne:=false;
 musLongtimer:=longint(3600)*musSwitching;
end;

Procedure TSoundSystem2.musPlayPrev;
begin
 if musPlayingUserOne and not musPlaylistDir then musLoadPlaylistFromPage(PDMBitmap(curscrolscreen^.map));
 musPlay(16,false,musPlaylist.GetPrevDkod);
end;

Procedure TSoundSystem2.musPlayNext;
begin
 if musPlayingUserOne and not musPlaylistDir then musLoadPlaylistFromPage(PDMBitmap(curscrolscreen^.map));
 musPlay(16,false,musPlaylist.GetNextDkod);
end;

Procedure TSoundSystem2.musPlayRandom(onlyfirst:shortint);
begin
 if musPlayingUserOne and not musPlaylistDir then musLoadPlaylistFromPage(PDMBitmap(curscrolscreen^.map));
 musPlay(16,false,musPlaylist.GetRandomDkod(onlyfirst));
end;

{---------------------------------------------------------------------------
 Je prave hrana hudba z musPlaylistu?
 ---------------------------------------------------------------------------}
Function TSoundSystem2.musIsOnPlaylist(onlyfirst:shortint):boolean;
var i:integer;
begin
 musIsOnPlaylist:=true;
 if musPlaylist.count>0 then begin
   if onlyfirst<1 then onlyfirst:=musPlaylist.count;
   for i:=0 to onlyfirst-1 do
    if musPlayingDkod=TDkod(musPlaylist.items^[i]) then exit;
   end;
 musIsOnPlaylist:=false;
end;

{---------------------------------------------------------------------------
 Pusti jinou muziku.
 ---------------------------------------------------------------------------}
Procedure TSoundSystem2.musSwitch;
begin
 if musRandom then musPlayRandom(0) else musPlayNext;
end;

Function TSoundSystem2.musGetSwitching:integer;
begin
 musGetSwitching:=musSwitching;
end;

Procedure TSoundSystem2.musSetSwitching(i:integer);
begin
 if (musSwitching<>-1) and (i=-1) then begin
   {switchne muziku, counter si uz nastavi sama}
   musSwitching:=i;{nutno nastavit pred switchem aby ten dobre nastavil neloopovani}
   musSwitch;
   end
 else begin
   musSwitching:=i;
   {seridi aktualni hodnotu counteru po zmene musSwitching}
   if musSwitching<=0 then musLongTimer:=0 else
    if musLongTimer<1
     then musLongTimer:=longint(3600)*musSwitching
     else musLongTimer:=minl(longint(3600)*musSwitching,musLongTimer);
   end;
end;

{---------------------------------------------------------------------------
 Nahraje z adresare playlist a pusti z nej muziku pokud uz nehraje.
 ---------------------------------------------------------------------------}
Procedure TSoundSystem2.musLoadPlaylistFromDir(dir:DirStr);

 procedure Load(mask:FileStr);
 var f:SearchRec;
 begin
  FindFirst(dir+mask,AnyFile-VolumeID-Directory,f);
  while DosError=0 do begin
    SS.musPlaylist.InsertName(dir+f.name);
    FindNext(f);
    end;
 end;

var mask:string[50];
begin
 musPlaylist.Reset;
 musPlaylistDir:=true;
 mask:=mods;
 while mask<>'' do Load(cutString(mask,';'));
 if musPlaylist.count=0 then
   dlgStr(_i(_musVDirNejsouModuly,dir))
  else begin
   musSwitch;
   dlgStr(_i(_musNactenoModulu,stri(SS.musPlaylist.count)));
   end;
end;

{---------------------------------------------------------------------------
 Nahraje ze stranky playlist a pusti z nej muziku pokud uz nehraje.
 ---------------------------------------------------------------------------}
Procedure TSoundSystem2.musLoadPlaylistFromPage(p:PDMBitmap);
var i,count:integer;
begin
 {$ifdef beta}
 if p=nil then erBetaMsg('musLoadPlaylistFromPage');
 {$endif}
 musPlaylist.Reset;
 musPlaylistDir:=false;
 count:=maxi(0,p^.lm_count);
 for i:=1 to count do
  musPlaylist.InsertDkod(p^.lm_list[i]);
 if not musPlayingUserOne and not musIsOnPlaylist(0) then musSwitch;
end;

{---------------------------------------------------------------------------
 Nahraje ze stranky playlist a pusti z nej muziku pokud uz nehraje.
 ---------------------------------------------------------------------------}
Procedure TSoundSystem2.musLoadFirstsPlaylistFromPage(p:PDMBitmap);
var i,count:integer;
begin
 {$ifdef beta}
 if p=nil then erBetaMsg('musLoadPlaylistFromPage');
 {$endif}
 musPlaylist.Reset;
 musPlaylistDir:=false;
 count:=p^.lm_firsts;if count<1 then count:=maxi(0,p^.lm_count);
 for i:=1 to count do
  musPlaylist.InsertDkod(p^.lm_list[i]);
 if not musPlayingUserOne and not musIsOnPlaylist(0) then musSwitch;
end;

{---------------------------------------------------------------------------
 Nastavi hlasitost hudby.
 ---------------------------------------------------------------------------}
Procedure TSoundSystem2.musSetVolume(volume:word);
begin
 base.musSetVolume(volume);
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
 if fadeout or (base.musPlaying) then begin
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
 base.musStop;
 musPlayingDkod:=0;
end;


Function TSoundSystem2.GetDebugInfo:string;
var   st:string;
const stri_boolean:array[false..true] of string[3]=('no','yez');
begin
 st:='MUZAK INFOORMA'#13#10+
   #13#10'RAIN='+stri_boolean[RainID<>'']+
   #13#10'muzak=';
 if musPlayingDkod<>0 then st:=st+data(musPlayingDkod)^.name^;
 GetDebugInfo:=st+
   #13#10'user1='+stri_boolean[musPlayingUserOne]+
   #13#10'userDir='+stri_boolean[musPlaylistDir]+
   #13#10'lon='+stri_boolean[lonPlayingDkod<>0]+
   #13#10'MusicChanger='+stri(musSwitching)+'min'+
   #13#10'time2change='+stri(musLongtimer div 60)+'sec'+
   #13#10'Amp='+stri(amp_long)+'%'+
   #13#10'MusicVol='+stri(musVolume)+
   #13#10'FxVol='+stri(smpVolume)+
   #13#10'musVolMul='+stri(round(musvolmultiply*100))+
   #13#10'Mute='+stri_boolean[musMute]+
   #13#10'dang='+stri_boolean[syncDanger];
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


{∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞INIT/DONE∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞}
{$ifdef poll}

const unita='rain2';
var result:TError;

const int=8;
var   oldint:pointer;
      backstack:pointer;
      oldstack:pointer;
      nowstack:pointer;

procedure prnt(p:pointer;line:word);
var l:longint absolute p;
    s:string8;
begin
 s:=hexed(l);
 for l:=1 to length(s) do
  memw[segb800:160*line+2*l]:=256*(16+14)+ord(s[l]);
end;

procedure poll;interrupt;
 begin
  asm db 66h;pusha;db 0fh,0a0h,0fh,0a8h{push fs;push gs} end;
  asm {sti;mov al,20h;out 20h,al} end;
  inc(async);
  if async=1 then begin
    asm mov oldstack.word[0],sp;mov oldstack.word[2],ss;db 0fh,0b2h,26h;dw offset backstack;end;{}
    sethwcol(0,33,0,0);
    asm {sti};pushf;call dword ptr oldint end;
    sethwcol(0,0,33,33);
    RainPoll;
    sethwcol(0,0,63,63);
    asm db 0fh,0b2h,26h;dw offset oldstack;end;{}
    end
  else begin
    asm mov nowstack.word[0],sp;mov nowstack.word[2],ss end;
    prnt(backstack,1);
    prnt(oldstack,2);
    prnt(nowstack,3);
{    asm sti;pushf;call dword ptr oldint end;{}
    asm mov al,20h;out 20h,al end;{}
    sethwcol(0,63,63,63);
    end;
  dec(async);
  asm db 0fh,0a9h,0fh,0a1h{pop gs;pop fs};db 66h;popa end;
 end;
 {pri vnoreni byl stack o 370h bajtu niz}

procedure UserInit;
 begin
  asm mov ax,sp;sub ax,30000;mov backstack.word[0],ax;mov backstack.word[2],ss;end;
  GetIntVec(int,oldint);
  SetIntVec(int,@poll);
 end;

procedure UserDone;
 begin
  SetIntVec(int,oldint);
 end;

{$i initdone.inc}
{$ifdef autoinit}
BEGIN
 erCheck(Init);
{$endif}
{$endif}
END.