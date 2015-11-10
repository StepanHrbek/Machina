Unit      DMBitmap; {$i define.inc}

{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}
                             INTERFACE
{‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹}

Uses      Chyby,Memo,
          Objects,Dos,Strings,
          Cache,Vga,DMFile,Sys,Stringy,Fajly,
          Texty,DMText,Writer2,DMWriter,Textury,Loadery,DMScript,
          Atoms,DMAtoms,
          Tools,
          Scrol;

Function  Init:TError;
Procedure Done;

Const
      nam_goon      :string='!goon.wav';
      nam_goback    ='!zvon.iff';{ !tubell.iff';{'!goback.iff';}
      nam_naraz     ='!naraz.iff';
      nam_goodbye   ='!goodbye.wav';
      nam_rip       ='!meepmee.wav';
      nam_ne        ='!incorre.wav';
      nam_fade      ='!fade.wav';
      nam_menuon    ='!ting.iff';
      nam_menuout   ='!ting.iff';
      nam_dvere     ='!dvere.iff';
      nam_setup     ='!setup.iff';
      nam_palopen   ='!ting.iff';
      nam_palok     ='!pal-ok.iff';
      nam_palabort  ='!pal-abo.iff';
      nam_unknown   ='!honky2.iff';

VAR
      RychlostSlideshow :byte;

CONST
      max_lm_count  = 10;

TYPE
      TLMList = array[1..max_lm_count] of TDkod;

      PSleepRec = ^TSleepRec;
      TSleepRec = record
        _Dkod             :TDkod;
        _parent           :TDkod;
        _project          :TPrjs;
        _jumppagesback    :byte;
        _lm_count         :shortint;
        _lm_list          :TLMList;
      end;

      PDMBitmap = ^TDMBitmap;
      TDMBitmap = object(TBitmap)
                      {---uchovavat trvale v tree---}
                      Dkod                :TDkod;
                      parent              :TDkod;
                      project             :Tprjs;
                      jumppagesback       :byte;
                      {static_slide        :boolean;{*asi nutno nekde nastavit ze sem o bajt zvetsil tree}
                      lm_count            :shortint;
                      lm_list             :TLMList;
                      {---mazat zaroven s bitmapou---}
                      lm_firsts           :byte;
                      doporucModel        :word;
                      doporucXres,
                      doporucYres         :integer;
                      Dkods_inited        :boolean;
                      Dkods_samplkra,
                      Dkods_samplyes,
                      Dkods_samplgbk,
                      Dkods_samplin1,
                      Dkods_samplin2      :TDkods;
{                      titletimeout,               {konstantni hodnota}
                      titletimeoutcounter :word;  {citac, klesa k nule}
                      playlist            :PPlaylist;
                      mapKind             :TOK;
                      palchanged          :boolean;

                     {create}
                      constructor         InitEmpty(model:byte;var result:TError);
                      constructor         Init(aDkod,aparent:TDkod;flags:word;var result:TError);
                      constructor         InitW(aDkod:TDkod;w:PDMWriter;flags,addx,addy:word;var result:TError);
                     private
                      constructor         InitT(aDkod:TDkod;flags:word;var result:TError);
                      constructor         InitP(aDkod,aparent:TDkod;var result:TError);
                     public
                      destructor          Done;virtual;

                     {sleep}
                      procedure           UseGivenSleepBuf(p:pointer);
                      procedure           FillGivenSleepBuf(p:pointer);

                      procedure           lm_Unspecify;
                      function            lm_Unspecified:boolean;
                      procedure           lm_Silence;
                      procedure           lm_AddDkod(kod:TDkod);
                      procedure           lm_AddList(st:string);

                    end;

Function  GetDMBitmap(page,parent:TDkod;flags:word;sleepbuf:pointer):PDMBitmap;



{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}
                          IMPLEMENTATION
{‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹}

{---------------------------------------------------------------------------
 Vrati odpovidajici DMBitmapu nebo nil.
 ---------------------------------------------------------------------------}
Function GetDMBitmap(page,parent:TDkod;flags:word;sleepbuf:pointer):PDMBitmap;
var    result:TError;
       map:PDMBitmap;
begin
 flags:=flags or (dmtfForcePacked*byte(atom.aGet(cx(now_project,page,0),aForcepacked)<>nil));
 result:=erLowMem;
 map:=New(PDMBitmap,Init(page,parent,flags,result));
 if (result<>erOk) and (result<>_erBadFont) then ReportErr(_(result));
 if map<>nil then
  with map^ do begin
   if sleepbuf<>nil then UseGivenSleepBuf(sleepbuf);
   {skripty, ktere obvykle neco hazou do mapy}
{zda se ze vse funguje i kdyz prvne pustim skripty uz pri generovani stranky,
takze tento radek muzu zakomentit:
   aCallPxs(project,page,nil,map);
   {playery animacek neudelaj nic, protoze nemaj na screene svou mapu}
   {pozdejci jine playery by ale neco uzitecneho delat mohly}
   {if playlist<>nil then playlist^.Sync;}
{co takhle pustit skripty az po nastaveni modu?
bylo by to dobry aby mel skript pristup ke svy screene
ale zas je tu problem ze vykreslovani ani.scr je pak videt a otravuje}
   end;
 GetDMBitmap:=map;
end;


{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ SLEEP ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}

{---------------------------------------------------------------------------
 Bitmapa se nastavi podle tveho sleepbufu.
 ---------------------------------------------------------------------------}
Procedure TDMBitmap.UseGivenSleepBuf(p:pointer);
begin
 if p<>nil then
  with PSleepRec(p)^ do begin
    project          :=_project;
    Dkod             :=_Dkod;
    parent           :=_parent;
    jumppagesback    :=_jumppagesback;
    lm_count         :=_lm_count;
    lm_list          :=_lm_list;
    end;
end;

{---------------------------------------------------------------------------
 Bitmapa ti vyplni sleepbuf.
 ---------------------------------------------------------------------------}
Procedure TDMBitmap.FillGivenSleepBuf(p:pointer);
begin
 {$ifdef beta}
 if p=nil then erBetaMsg('fillgivensleepbuf');
 {$endif}
 with PSleepRec(p)^ do begin
    _project          :=project;
    _Dkod             :=Dkod;
    _parent           :=parent;
    _jumppagesback    :=jumppagesback;
    _lm_count         :=lm_count;
    _lm_list          :=lm_list;
    end;
end;





Procedure TDMBitmap.lm_Unspecify;
begin
 lm_count:=-1;
 lm_firsts:=0;
end;

Function TDMBitmap.lm_Unspecified:boolean;
begin
 lm_Unspecified:=lm_count<0;
end;

Procedure TDMBitmap.lm_Silence;
begin
 lm_count:=0;
end;

Procedure TDMBitmap.lm_AddDkod(kod:TDkod);
var   i:integer;
begin
 if lm_Unspecified then lm_Silence;
 if kod>0 then begin
   for i:=1 to lm_count do if kod=lm_list[i] then exit;{nezarazuje co uz tam je}
   if lm_count>=max_lm_count then begin
     ReportErr(_(_erMocModulu));
     end
    else begin
     inc(lm_count);
     lm_list[lm_count]:=kod;
     end;
   end;
end;

Procedure TDMBitmap.lm_AddList(st:string);
begin
 if lm_Unspecified then lm_Silence;
 while st<>'' do lm_AddDkod(GetDkod(cutName(st),true));
end;


{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ CREATE ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}

{---------------------------------------------------------------------------
 Vygeneruje prazdnou stranku.
 ---------------------------------------------------------------------------}
Constructor TDMBitmap.InitEmpty(model:byte;var result:TError);
begin
 {$ifdef beta}
 if result<>erLowMem then erBetaMsg('dmbitmap.initempty 1');
 {$endif}
 if not inherited Init(model,1,1) then Fail;
 mapKind:=okEmpty;
 result:=erOk;
end;

{---------------------------------------------------------------------------
 Vygeneruje stranku ze zadaneho dmtextu.
 ---------------------------------------------------------------------------}
Constructor TDMBitmap.InitT(aDkod:TDkod;flags:word;var result:TError);
var   w:PDMWriter;
begin
 {$ifdef beta}
 if result<>erLowMem then erBetaMsg('dmbitmap.initt 1');
 {$endif}
 new(w,Init(0,nil,Data(aDkod)^.name^,dmtfResizeNadp,result));
 if result=erOk then begin
   result:=erLowMem;
   InitW(aDkod,w,flags,0,0{add},result);
   KillObj(w);
   end;
 if result<>erOk then Fail;
end;

{---------------------------------------------------------------------------
 Vygeneruje stranku ze zadaneho obrazku.
 ---------------------------------------------------------------------------}
Constructor TDMBitmap.InitP(aDkod,aparent:TDkod;var result:TError);
type  PImage=^Image;
      Image = record
        Link: Word;
        Data: record end;
        end;
var   w:PDMWriter;
      uspech:boolean;
      b:PBitmap;
      p:PPal;
      pl:PPlayer;
      c:byte;
      i,j,zero:integer;
      m:word;
      gfxok:boolean;
      res:pchar;
begin
 {$ifdef beta}
 if result<>erLowMem then erBetaMsg('dmbitmap.initp 1');
 {$endif}
 {zjisti zda jde prohlizet v grafice}
 m:=model_scrol;
 i:=640;{fuk}
 j:=480;{fuk}
 zero:=0;
 gfxok:=ModeDoplnInfo(m,i,j,zero);
 {vygeneruje nopic variantu TBitmap
  plus naky atributy (samply) nad ramec TBitmap}
 if gfxok then begin
   if aparent<>0
    then InitT(aparent,dmtfNoBody,result)
    else InitEmpty(model_packed,result);
   doporucModel:=model_packed+model_scrol;
   doporucXres:=640;
   doporucYres:=480;
   mapKind:=okPic;
   end
 else begin
   if aparent<>0
    then InitT(aparent,dmtfNoBody,result)
    else InitEmpty(model_text,result);
   doporucModel:=model_text;
   doporucXres:=TxtRes.X;
   doporucYres:=TxtRes.Y;
   mapKind:=okPic;
   end;
 if result<>erOk then Fail;
 Clr2Ful;
 {Cim se lisi parent od empty?
   - pic ma nastaveny samply
   - a dal asi uz nic...
   - ma pic nastaveny i name a author parenta? (test ukazal ne)
 }
 {nastavi dalsi atributy nad ramec TBitmap}
 project:=now_project;
 Dkod:=aDkod;
 parent:=aparent;
 titletimeoutcounter:=70*RychlostSlideshow;
 {naloaduje TBitmap kdyz jde grafika}
 if gfxok and (Dkod<>0) then begin
   b:=picLoad(Data(Dkod)^.name^);
   if b<>nil then begin
     MarkColorsIn(b);
     xchg(PImage(b)^.Data,PImage(@self)^.Data,sizeof(TBitmap)-2);
     KillObj(b);
     doporucModel:=MapModel+model_scrol;{nejdriv zkusi nastavit tento, pak model_scrol}
     doporucXres:=sizeX;
     doporucYres:=sizeY;
     if MapModel=model_text then begin
       doporucModel:=model_text;
       doporucXres:=txtRes.X;
       doporucYres:=txtRes.Y;
       end;
     end;
   end;
 {pretizi resolution}
 aLoadPicDescriptions(project);
 res:=atom.aGet(cx(project,Dkod,0),aResolution);
 if (res<>nil) and (res^<>#0) then begin
   doporucXres:=StrCutNum(res);
   doporucYres:=StrCutNum(res);
   end;
end;

{---------------------------------------------------------------------------
 Vygeneruje stranku ze zadaneho souboru (obrazek nebo dmtext).
 ---------------------------------------------------------------------------}
Constructor TDMBitmap.Init(aDkod,aparent:TDkod;flags:word;var result:TError);
begin
 {$ifdef beta}
 if result<>erLowMem then erBetaMsg('dmbitmap.init 1');
 {$endif}
 if (DkodIs(aDkod) and isHypertext)=0
   then InitP(aDkod,aparent,result)
   else InitT(aDkod,flags,result);
 if result<>erOk then Fail;
end;

{---------------------------------------------------------------------------
 Vygeneruje stranku ze zadaneho writeru.
 ---------------------------------------------------------------------------}
Constructor TDMBitmap.InitW(aDkod:TDkod;w:PDMWriter;flags,addx,addy:word;var result:TError);
var st:string;

 procedure GetRgb(name,implicit:string11;var r,g,b:byte);
 var st11:string11;
 begin
  st11:=paramGet(st,name);
  if st11='' then st11:=implicit;
  paramGetRgb(st11,r,g,b);
 end;

 function GetColor(name,implicit:string11):longint;
 var r,g,b:byte;
 begin
  GetRgb(name,implicit,r,g,b);
  GetColor:=Color(r,g,b,255);
 end;

 function GetStr(name,implicit:string11):string11;
 begin
  GetStr:=stri(GetColor(name,implicit));
 end;

 function GetTextColors:string;
 begin
  st:=w^.GetHeader('tex:');
  case w^.OutputKind(flags) of
    okTxt,
    okGfx2Txt:GetTextColors:='7,11,14,15,13';
    ok256    :GetTextColors:='9,10,11,12';
    okDirect :GetTextColors:=
               GetStr('text','silver')+','+GetStr('cowriter','aqua')+','+
               GetStr('link','yellow')+','+GetStr('strong','white');
    end;
 end;

 procedure SetDirectColorToPackedCol(name,implicit:string11;col:byte);
 begin
  with pal^.pal[col] do begin
    GetRgb(name,implicit,r,g,b);
    r:=r shr 2;
    g:=g shr 2;
    b:=b shr 2;
    end;
 end;

 procedure SetDirectColorsToPackedPal;
 begin
  st:=w^.GetHeader('tex:');
  SetDirectColorToPackedCol('text'    ,'silver',9);
  SetDirectColorToPackedCol('cowriter','aqua'  ,10);
  SetDirectColorToPackedCol('link'    ,'yellow',11);
  SetDirectColorToPackedCol('strong'  ,'white' ,12);
  pal^.Setup(9,12,pifUsed);
 end;

 procedure SetPackedColorsToPackedPal;
 var j:word;
 begin
  with pal^ do begin
    st:=w^.GetHeader('pal:');
    for j:=1 to length(st) do
     case (j+2) mod 3 of
       0:pal[(j+2) div 3].r:=ord(st[j])-32;
       1:pal[(j+2) div 3].g:=ord(st[j])-32;
       2:pal[(j+2) div 3].b:=ord(st[j])-32;
       end;
    Setup(0,40,pifUsed);
    end;
 end;


 {pri uspesnem vygenerovani vraci overflows a result=erOk}
 function GenerateMap(tryModel,x,y:word):word;
 var  xmid,wid,ytop,heig:integer;
      bgcolor           :longint;
 begin
  if debug then BiosWriteln('GenerateMap: '+_(_msgZkousVel)+' '+stri(x)+'x'+stri(y)+'/'+modelstr[mapmodel]);
  {alokuje dmbitmapu}
  with w^ do
  if inherited Init(mapModel,x,y) then begin
    project:=now_project;
    Dkod:=aDkod;
    parent:=0;
    new(playlist,Init(0,5));
    if playlist<>nil then begin

      if debugW then BiosWriteln('DrawPage GetHeaders...');
      {---nacte z headeru paletu---}
      case OutputKind(flags) of
        ok256:
          if (flags and dmtfForcePacked)>0
           then SetDirectColorsToPackedPal
           else SetPackedColorsToPackedPal;
        end;
      {---nacte z headeru doporucene rozliseni---}
      st:=GetHeader('res:');
      doporucModel:=tryModel;
      {static_slide:=GetFlag(flagStaticSlide)<>0;}
       {pri pozdejcim nastavovani preferuje model bitmapy}
       if doporucModel=model_scrol then inc(doporucModel,MapModel);
      doporucXres:=CutNum(st);
      doporucYres:=CutNum(st);
      {---nacte z headeru jmeno stranky a autora---}
      if aDkod<>0 then begin
        {stranka aDkod prejme udaje z sablony, ovsem obrazek s sablonou ne
         protoze sem jde Dkod sablony a na Dkod obrazku se zmeni az pak,
         ovsem to uz jsou udaje ulozeny do kontextu sablony}
        aLoadPicDescriptions(project);
        aLoadPagDescription(project,aDkod,w);
        atom.aSet(cx(project,aDkod,0),aSizeX,StrNewNum(sizeX),forPagetime);
        atom.aSet(cx(project,aDkod,0),aSizeY,StrNewNum(sizeY),forPagetime);
        end;
      {---nacte z headeru samply---}
      Dkods_samplkra.Init;
      Dkods_samplyes.Init;
      Dkods_samplgbk.Init;
      Dkods_samplin1.Init;
      Dkods_samplin2.Init;
      Dkods_inited:=true;
      Dkods_samplkra.InsertList(GetHeader('skr:'));if Dkods_samplkra.count=0 then Dkods_samplkra.InsertList(nam_naraz);
      Dkods_samplyes.InsertList(GetHeader('sen:'));if Dkods_samplyes.count=0 then Dkods_samplyes.InsertList(nam_goon);
      Dkods_samplgbk.InsertList(GetHeader('sou:'));if Dkods_samplgbk.count=0 then Dkods_samplgbk.InsertList(nam_goback);
      Dkods_samplin1.InsertList(GetHeader('si1:'));if Dkods_samplin1.count=0 then Dkods_samplin1.InsertList(GetHeader('sin:'));
      Dkods_samplin2.InsertList(GetHeader('si2:'));if Dkods_samplin2.count=0 then Dkods_samplin2.InsertList(GetHeader('sin:'));
      {---nacte z headeru timeout---}
      titletimeoutcounter :=70*GetFlag(flagTimeout);
      {---nacte z headeru moduly---}
      lm_Unspecify;
      lm_firsts:=GetFlag(flagMusicFirsts);
      if ExistsHeader('mus:') then lm_AddList(GetHeader('mus:'));

      if ((flags and dmtfNoBody)=0) then begin

        if debugW then BiosWriteln('DrawPage Setup...');
        case OutputKind(flags) of
          ok256,
          okDirect:begin
            st:=GetHeader('tex:');
            texPlace(freeseg,@self,st);
            bgcolor:=GetColor('bgcolor','black');{volat jen kdyz je st=GetHeader(tex:)}
            st:=GetHeader('txa:');
            while st<>'' do begin
              xmid:=CutNum(st);
              ytop:=CutNum(st);
              wid :=CutNum(st);
              heig:=CutNum(st);
              Col2Box(xmid-wid div 2,ytop,wid,heig,bgcolor);
              {WhiteBorder(@self,xmid-wid div 2,ytop,wid,heig,128);}
              CastShadow(@self,xmid-wid div 2,ytop,wid,heig);
              end;
            SetupSimple(@self,GetHeader('fnt:'),GetTextColors,GetFlag(flagOldTabs));
            SetupMore(1{format},1{roztahovat ke krajum},0,0{proporc});
            end;
          okTxt:begin
            Clr2Ful;
            SetupSimple(@self,GetHeader('fnt:'),GetTextColors,GetFlag(flagOldTabs));
            SetupMore(1{format},1{roztahovat ke krajum},1,1{proporc});
            end;
          okGfx2Txt:begin
            Clr2Ful;
            SetupAdvanced(true{advanced},false,@self,GetHeader('fnt:'),
             'textmode.fn;textmode.fn;textmode.fn;textmode.fn',
             GetTextColors,GetFlag(flagOldTabs));
            SetupMore(1{format},1{roztahovat ke krajum},0,1{proporc});
            doporucXres:=sizeX;
            doporucYres:=sizeX div 2;
            end;
          end;
        if debugW then BiosWriteln('DrawPage InitWriter...');
        wrOutput^.reportOn:=true;
        wrOutput^.playlist:=playlist;
        wrOutput^.vyhExport:=(flags and dmtfVyhExport)>0;
        WriteInit;
        if debugW then BiosWriteln('DrawPage Writer...');
        GenerateMap:=Write;
        if debugW then BiosWriteln('DrawPage Writer OK');
        WriteDone;
        wrOutput^.reportOn:=false;
        end;

      if debugW then BiosWriteln('DrawPage ok.');
      result:=erOk;
      exit;
      end;
    {inherited}TBitmap.Done;
    end;
 end;

Var   i,j,zero          :integer;
      origXsize         :integer;
      origYsize         :integer;
      tryXsize          :integer;
      tryYsize          :integer;
      minXzoom          :real;
      maxXzoom          :real;
      tryModel          :word;
      overflows         :word;
Label try_direct,
      try_gfx2txt,
      try_fail,
      nexttry;
Begin
 {$ifdef beta}
 if result<>erLowMem then erBetaMsg('dmbitmap.initw 1');
 if w=nil then erBetaMsg('dmbitmap.initw 2');
 {$endif}
 with w^ do begin

  if debugW then BiosWriteln('DrawPage...');
  {zjisti v jakem modelu se bude prohlizet}
  st:=GetHeader('res:');
  i:=CutNum(st);
  j:=CutNum(st);
  st:=GetHeader('siz:');
  origXsize:=maxI(1,CutNum(st));
  origYsize:=maxI(1,CutNum(st));
  if (flags and dmtfNoBody)>0 then begin origXsize:=1;origYsize:=1;end;
  mapKind:=OutputKind(flags);
  case mapKind of
    ok256    :begin
              tryModel:=model_8;
              mapModel:=model_8;
              zero:=0;
              if not ModeDoplnInfo(mapModel,i,j,zero) then begin
                flags:=flags and not dmtfForcePacked;{zrusi forcepacked kdyz nejde}
                if OutputKind(flags)<>ok256 then goto try_direct;{zkusi direct kdyz tech 256 nevyzaduje tvrde}
                okForced:=okGfx2Txt;
                goto try_gfx2txt;
                end;
              GenerateMap(tryModel,origXsize+addx,origYsize+addy);
              if result<>erOk then Fail;
              end;
    okDirect :begin
              try_direct:
              tryModel:=model_scrol;
              mapModel:=model_scrol;
              zero:=0;
              {bylo: memavail-10000, ted je memavail-"800x600/24bit"}
              maxByPP:=Bounded((memavail-1500000) div (origXsize+addx) div (origYsize+addy),0,4);
              if not ModeDoplnInfo(mapModel,i,j,zero) then begin
                maxByPP:=4;{vraci glob.prom. na jeji standardni hodnotu}
                okForced:=okGfx2Txt;
                goto try_gfx2txt;
                end;
              maxByPP:=4;{vraci glob.prom. na jeji standardni hodnotu}
              GenerateMap(tryModel,origXsize+addx,origYsize+addy);
              if result<>erOk then Fail;
              end;
    okTxt    :begin
              tryModel:=model_text;
              mapModel:=model_text;
              zero:=0;
              if not ModeDoplnInfo(mapModel,i,j,zero) then goto try_fail;
              GenerateMap(tryModel,origXsize+addx,origYsize+addy);
              if result<>erOk then Fail;
              end;
    okGfx2Txt:begin
              try_gfx2txt:
              tryModel:=model_text;
              mapModel:=model_text;
              maxXzoom:=1;
              minXzoom:=0.01;
              Xzoom:=DetectXzoom;
              Yzoom:=DetectYzoom;
              zero:=0;
              if not ModeDoplnInfo(mapModel,i,j,zero) then goto try_fail;

              nexttry:
              tryXsize:=1000000-trunc(1000000-origXsize*Xzoom);
              tryYsize:=1000000-trunc(1000000-origYsize*Yzoom);
              overflows:=GenerateMap(tryModel,tryXsize+addx,tryYsize+addy);
              if result<>erOk then Fail;
              if (overflows<>0)
               then minXzoom:=Xzoom
               else maxXzoom:=Xzoom;
              if (overflows<>0) or (maxXzoom/minXzoom>1.02) then begin
                if maxXzoom/minXzoom<=1.02
                 then Xzoom:=maxXzoom
                 else Xzoom:=(minXzoom+maxXzoom)/2;
                atom.aSet(cx(now_project,aDkod,0),aObjects,nil,forDunno);
                TBitmap.Done;
                result:=erLowMem;
                goto nexttry;
                end;
              end;
    else      begin
              try_fail:
              result:=_erBadMode;
              Fail;
              end;
    end;

  end;
End;

Destructor TDMBitmap.Done;
begin
 if Dkods_inited then begin
   Dkods_samplkra.Done;
   Dkods_samplyes.Done;
   Dkods_samplgbk.Done;
   Dkods_samplin1.Done;
   Dkods_samplin2.Done;
   Dkods_inited:=false;
   end;
 KillObj(playlist);
 aLeavePage(project,Dkod);
 inherited Done;
end;


{∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞INIT/DONE∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞}

const unita='dmbitmap';
var result:TError;

procedure UserInit;
 begin
  RychlostSlideshow:=5;
 end;

procedure UserDone;
 begin
 end;

{$i initdone.inc}
{$ifdef autoinit}
BEGIN
 erCheck(Init);
{$endif}
END.