PROGRAM Machina;

{$i define.inc}
{$define TVED}
{$E-,N-,M 40000}
USES  Chyby,Memo,Lang2,
      Dos,Objects,Strings,
      {$ifdef TVED}Drivers,Ed2,{$endif}                         {TV editor}
      Mys,Key,Cache,Sys,Stringy,CS,Texty,Fajly,Streamy,         {zaklad}
      Vga,Scrol,Fonty,Textury,                                  {grafika}
      Writer2,DMText,DMWriter,DMBitmap,DMFile,DMExport,DMScript,{dmXXX}
      Setup,Supp,Dialogy,Tools,                                 {setup+stuff}
      Loadery,LdJpg,LdPng,LdGif,LdX,LdPcx,LdTga,LdFlc,LdTxt,    {loadery}
      Atoms,DMAtoms,                                            {atomy}
      NFDos,FlcPlay;{jen kvuli shift f3}


{---------------------------------------------------------------------------
 Nainstaluje cesky fonty do textmodu.
 ---------------------------------------------------------------------------}
procedure myUserFont(var name:PathStr;var p:pointer;var vyska:byte);far;
 begin
  vyska:=Bounded(vyska,5,16);
  case vyska of
        5:name:='!05.fn';
    6.. 7:name:='!06.fn';
    8..10:name:='!08.fn';
   11..13:name:='!11.fn';
   14..15:name:='!14.fn';
       16:name:='!16.fn';
   end;
 end;

var OldShutDown:TProc;

procedure ShutDown;far;
 begin
  UserFont:=nil;
  if @OldShutDown<>nil then OldShutDown;
  {ShutDown se zavola jeste pred s.Done, takze s.Done uz nenastavi cesky font
   odpovidajici velikosti. to je schvalne aby to lidem nekazilo jejich
   rezidentni cestinu.}
 end;

Procedure InstallCzFonts;
 begin
  UserFont    :=myUserFont;
  OldShutDown :=ShutDownInts;
  ShutDownInts:=ShutDown;
 end;


{ÛÛÛÞÞÞÝÞÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ E D I T O R ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ}


var   e               :TDMWriter;
      s               :TScrolScreen;
      ednowx,ednowy   :integer;
      linenow         :integer;

      pixStart,
      pixLen,
      pixMid          :integer;{udaje o sloupci podle wrOrig}

      edfajl          :PathStr;

      wlcha           :char;
      nowsloupec      :byte;
      prevF3vis       :TPoint;

      fixcoords       :boolean;
      overflows       :word;

const
      textattr:byte     =7;

PROCEDURE listaWriXY(x:word;st:string);
var   i:word;
      p:pointer;
begin
 i:=ofs(st);
 p:=s.lista^.tab^[0];
 st[0]:=chr(minI(ord(st[0]),s.lista^.sizeX-x));
 asm les di,p;add di,x;add di,x
     mov ah,textattr
     PUSH ds;
     mov bx,ss;mov ds,bx;mov si,i
     lodsb;or al,al;jz @nope;mov ch,0;mov cl,al
     @loop:lodsb;stosw;loop @loop
     @nope:
     POP ds;
     end;
end;

const infocolor_normal=16*2+11;
      infocolor_higher=16*2+10;
      infocolor_wrong =16*2+12;

Function X80(x:word):word;
begin
 x80:=x*s.Xres div 80;
end;

PROCEDURE Info_Cls;
begin
 s.lista^.Col2Ful(infocolor_normal*256+32);
end;

PROCEDURE Info_File;
begin
 textattr:=infocolor_normal;
 listawrixy(1,PathSlice(edfajl,psFile)+'       ');
end;

PROCEDURE Info_XY;
begin
 textattr:=infocolor_normal;
 listawrixy(X80(54),_(_sloupec)+':'+stri(nowsloupec)+' ');
 listawrixy(X80(67),'x:'+stri(ednowx)+'  ');
 listawrixy(X80(73),'y:'+stri(ednowy)+'  ');
end;

PROCEDURE Info_Size;
var   i:word;
      c:byte;
      st:string[10];
      x,y:word;
      l:longint;
begin
 textattr:=infocolor_normal;
 st:=e.GetHeader('siz:');
 x:=GetNum(st,1);
 y:=GetNum(st,2);
 l:=longint(x)*y;
 listawrixy(X80(15),st+'='+stri(l shr 20)+'.'+chr(48+10*l shr 20 mod 10)+'M    ');
 i:=e.FileSize;
 listawrixy(X80(35),stri(i)+' '+_(_bajtu)+'  ');
end;

PROCEDURE Info_Msg(st:string);
begin
 info_cls;
 textattr:=infocolor_normal;
 listawrixy((s.Xres-length(st)) shr 1,st);
end;


PROCEDURE mySetupMore;
begin
 case e.OutputKind(dmtfForcePacked) of
   okTxt:e.SetupMore(1{format},0{levy kraj},1,1{stay noproporc});
   else  e.SetupMore(1{format},0{levy kraj},0,1{xlat proporc 2 noproporc});
   end;
end;

PROCEDURE pixSlpGo;
begin
 pixMid  :=e.SlpX(2*nowsloupec-1);
 pixLen  :=e.SlpGetNum(nowsloupec,4);
 pixStart:=pixMid-pixLen div 2;
end;

PROCEDURE RefreshTextScreen(updatexy:boolean);
var   guessedSizeY,usedSizeY:integer;
      oprava:boolean;
      st:string;
label oprav_se;
Begin
 oprava:=false;

oprav_se:

 guessedSizeY:=round(GetNum(e.GetHeader('siz:'),2)*e.Yzoom)+20;

 with s.map^ do
  Col2Box(0,0,sizeX,minW(s.map^.sizeY,guessedSizeY),$8700+ord(' '));

 mySetupMore;
 e.WriteInit;
 overflows:=e.Write;
 e.WriteDone;

 {predcasne ukonci kdyz vi ze to bude stejne prekreslovat s jinym zoomem}
 if overflows>0 then exit;

 {zacerni nepouzity zbytek mapy pod dolni hranici stranky}
 usedSizeY:=round(GetNum(e.GetHeader('siz:'),2)*e.Yzoom);
 with s.map^ do
  if usedSizeY+6<=s.map^.sizeY then
   Clr2Box(0,usedSizeY+2,sizeX,maxI(4,s.topYres-usedSizeY));

 {vesel se text do odhadnuty velikosti?}
 if usedSizeY>guessedSizeY then begin
   if oprava then erMsg(_(_erSpatOdhVelStr));
   oprava:=true;
   goto oprav_se;
   end;

 {pripadne oprava po F4 a po otevreni stranky s blbym pos:}
 st:=e.GetHeader('pos:');
 if fixcoords and (st<>'') then begin
   nowSloupec:=Bounded(valu(paramGet(st,'slp')),1,e.SlpMax);
   if e.SlpFirstLine(nowSloupec)>e.SlpLastLine(nowSloupec)
    then begin
      linenow:=-1;
      ednowx:=-1;
      ednowy:=-1;
      e.SlpGo(nowSloupec);
      end
    else begin
      linenow:=maxI(0,valu(paramGet(st,'slpline')));
      linenow:=minI(e.SlpFirstLine(nowSloupec)+linenow,e.SlpLastLine(nowSloupec));
      ednowx:=valu(paramGet(st,'x'));
      if ednowx=-1 then ednowx:=scrx^[linenow];
      ednowy:=scry^[linenow];
      e.GotoCoords(ednowx,linenow);
      end;
   fixcoords:=false;
   end
 else
 {prizpusobi promenny soucasny pozici kurzoru=pos}
 if updatexy then
   e.SearchCoordsIn(nowsloupec,ednowx,ednowy,linenow);

 pixSlpGo;
 info_size;
 s.MapRedraw;
End;



PROCEDURE AdjustMode;
begin
 vga_ShowCursor;
end;

Procedure SpocitejToXY(s:PScrolScreen);far;

 procedure zpracuj(var co:integer;charres,res,ednow:integer);
 const kraj=50;
 var   i:integer;
 begin
   i:=charres*ednow+charres div 2;
   co:=Bounded(co,i-charres*res+kraj,i-kraj);
 end;

begin
 with s^ do begin
   zpracuj(posCil.X,charXres,   Xres,ednowX);
   zpracuj(posCil.Y,charYres,topYres,ednowY);
   end;
end;

var   hlpLocal:TError;
const hlpMenu:byte=1;

PROCEDURE Call_help;far;
var   st:PathStr;
      b:PBitmap;
      zero:TPoint;
begin
{ info_cls;
 info_msg('HELP');
{ Viewer(picLoad('dm\'+_(hlpLocal)));}
 zero.x:=0;
 zero.y:=0;
 Show(_(hlpLocal),sfEditmod+sfDontChangeTextMode,zero.x,zero.y);
 now_project:=GetNezkompPrj;
 FlushKey;
 AdjustMode;
 info_cls;
 info_file;
 info_xy;
 info_size;
end;


PROCEDURE EDITOR;
const hdr_lines=20;
      hdr:array[1..hdr_lines]
       of record txt:string[4]; typ:pchar; code:TError; end=(
          (txt:'siz:';typ:''  ;code:_menuEd1),
          (txt:'tem:';typ:''  ;code:_menuEd2),
          (txt:'nam:';typ:''  ;code:_menuEd3),
          (txt:'aut:';typ:''  ;code:_menuEd4),
          (txt:'res:';typ:''  ;code:_menuEd5),
          (txt:'tex:';typ:''  ;code:_menuEd6),
          (txt:'tex:';typ:''  ;code:_menuEd7),
          (txt:'fnt:';typ:fnts;code:_menuEd8),
          (txt:'si1:';typ:wavs;code:_menuEd9),
          (txt:'si2:';typ:wavs;code:_menuEd10),
          (txt:'sen:';typ:wavs;code:_menuEd11),
          (txt:'sou:';typ:wavs;code:_menuEd12),
          (txt:'skr:';typ:wavs;code:_menuEd13),
          (txt:'mus:';typ:mods;code:_menuEd14),
          (txt:'fla:';typ:''  ;code:_menuEd15),
          (txt:'***:';typ:''  ;code:_menuEd16),
          (txt:'***:';typ:''  ;code:_menuEd17),
          (txt:'***:';typ:''  ;code:_menuRozliseniEdu),
          (txt:'***:';typ:''  ;code:_menuSwitchYZ),
          (txt:'***:';typ:''  ;code:_menuPomLang));
type  hdr_code=(hdr_nop,hdr_siz,hdr_tem,
                hdr_nam,hdr_aut,hdr_res,hdr_bkg,hdr_tex,hdr_fnt,
                hdr_si1,hdr_si2,hdr_sen,hdr_sou,hdr_skr,hdr_mus,
                hdr_fla,hdr_ali,hdr_cen,hdr_edr,hdr_syz,hdr_lan);
var   i,j                 :word;
      m,n,acum            :integer;
      precol              :byte;
      prefnt              :byte;
      orim,orix,oriy      :word;
      st                  :string;
      st8                 :string[8];
      pre                 :string;
      event               :TEvent;
      poss                :TPoint;
      c                   :char;
      FakeDMBitmap        :PDMBitmap;
      mode_for_tv         :PScreen;
      oldHeapError        :pointer;
      p1,p2               :pchar;
      someResult          :TError;
      emptyfile           :boolean;
      menulist            :TMenuCollection;
      altx                :hdr_code;
      lastalign           :byte;
      edSpace             :pointer;
      onlyM               :boolean;
      possib_in_empty     :boolean;
      myXzoom             :real;
      cil                 :TPoint;
      old_mouseHandler    :boolean;
      holdcodes           :integer;
const holdcodes2run       =13;
      edSize              =65520;

 procedure NastaveniEPodleTextu;
 begin
  with e do
  {provadet po kazdym alt-x a load}
  SetupAdvanced(true{advanced},true{edit},s.map,GetHeader('fnt:'),GetHeader('fnt:'),
    '7,11,14,15,13',GetFlag(flagOldTabs));
  if myXzoom=0 then begin
    {Xzoom detekuje jen na pozadani, jinak adjustuje(zvysuje) minulou hodnotu}
    mySetupMore;
    myXzoom:=e.DetectXzoom;
    end;
  e.Xzoom:=myXzoom;
  e.Yzoom:=e.DetectYzoom;
 end;

 procedure ZfalsovaniMapy;
 begin
  {$ifdef beta}
  if s.map<>nil then erBetaMsg('editor 1');
  {$endif}
  new(s.map,Init(model_text,1,1));
  if s.map=nil then Halt(erLowMem);
  s.lista^.Clr2Ful;
  s.MapInit(s.map,s.lista,cil.x,cil.y);
 end;

 procedure NastaveniMapyPodleE;
 var sirka:word;
 begin
  {$ifdef beta}
  if s.map<>nil then erBetaMsg('editor 2');
  {$endif}
  sirka:=trunc(GetNum(e.GetHeader('siz:'),1)*myXzoom+0.9999);
  new(s.map,Init(model_text,sirka,MinW(16380,400000 div (2*sirka))));
  if s.map=nil then Halt(erLowMem);
  s.MapInit(s.map,s.lista,cil.x,cil.y);
  e.WrOutput^.SetBitmap(s.map);
 end;

 procedure ZruseniMapy;
 begin
  {$ifdef beta}
  if s.map=nil then erBetaMsg('editor 3');
  {$endif}
  cil.x:=s.posCil.x div s.charXres;
  cil.y:=s.posCil.y div s.charYres;
  KillObj(s.map);
 end;

 procedure EPreSave;
 var st:string[80];
     slpline:integer;
     tstart:word;
 begin
  tstart:=e.textStart;
  if linenow=-1 then slpline:=0 else slpline:=linenow-e.SlpFirstLine(nowSloupec);
  st:={'ofs='+stri(word(e.pos)-tstart)+' '}
     'slp='+stri(nowSloupec)+
     ' x='+stri(ednowx)+
     ' line='+stri(linenow)+
     ' slpline='+stri(slpline);
  if e.blkEnd>e.blkStart then st:=st+
     ' blkStart='+stri(e.blkStart-tstart)+
     ' blkEnd='+stri(e.blkEnd-tstart);
  if e.GetFlag(flagDontSavePos)<>0 then st:='';
  if e.GetHeader('pos:')<>st then begin
    e.SetHeader('pos:',st);
    e.modified:=true;
    end;
 end;

 procedure ESave;
 begin
  EPreSave;
  if e.Save(edfajl)<>erOk then begin
    while e.Save(edfajl)<>erOk do
     edfajl:=dlgLine(0,_(_msgStranNejdeUloz1)+' '+dirCur+edfajl+' '+_(_msgStranNejdeUloz2),edfajl);
    end;
 end;

 function ERawLine:word;
 var i:integer;
     oldpos:pchar;
 begin
  oldpos:=e.pos;
  e.Reset;
  i:=-1;
  repeat e.nlGoto(+1);inc(i);until e.pos>oldpos;
  ERawLine:=i;
  e.pos:=oldpos;
 end;

 function moveCursorTo(pos:TPoint):boolean;
 var i,j:integer;
     somerect:TRect;
 begin
  with e do
   for i:=SlpMax downto 1 do begin
    SlpRect(i,somerect);
    with somerect do begin
      a.x:=round(a.x*Xzoom);
      b.x:=round(b.x*Xzoom);
      a.y:=round(a.y*Yzoom)+1;
      b.y:=round(b.y*Yzoom)+1;
      if Contains(poss) then begin
        nowsloupec:=i;
        ednowx:=poss.X;
        ednowy:=poss.Y;
        j:=-1;
        for j:=SlpFirstLine(i) to SlpLastLine(i) do
         if scry^[j]>=poss.Y then break;
        linenow:=j;
        if linenow=-1 then begin
          ednowx:=-1;
          ednowy:=-1;
          end;
        moveCursorTo:=true;
        pixSlpGo;
        exit;
        end;
      end;
    end;
  moveCursorTo:=false;
 end;

 procedure GotoLineStart;
 begin
  ednowx:=scrx^[linenow];
 end;

 procedure GotoLineEnd;
 begin
  ednowx:=scrx^[linenow]+minW(e.nlAdr(+1)-2,edofs^[linenow+1])-edofs^[linenow];
 end;

 procedure GotoSlpStart;
 begin
  linenow:=e.SlpFirstLine(nowsloupec);
  word(e.pos):=edofs^[linenow];
  ednowy:=scry^[linenow];
  GotoLineStart;
 end;

 procedure GotoSlpEnd;
 begin
  linenow:=e.SlpLastLine(nowsloupec);
  word(e.pos):=edofs^[linenow];
  ednowy:=scry^[linenow];
  GotoLineEnd;
 end;

 function ShowModifiedPal:boolean;
 var pagecx:pchar;
     forcepacked:boolean;
     st:string[120];
     oldtex,newtex:string;

  procedure SetColInTex(colname:string11;col:byte);
  begin
   newtex:=paramSet(newtex,colname,
     paramSetRgb((ord(st[3*col-2])-32) shl 2,(ord(st[3*col-1])-32) shl 2,(ord(st[3*col])-32) shl 2));
  end;

 begin
  with e do begin
    ShowModifiedPal:=false;
    dlgHelp:=nil;
    ESave;
    while caMakeRoom do;
    pagecx:=StrNew(cx(now_project,GetDkod(edfajl,true),0));
    forcepacked:=texType(GetHeader('tex:')) in ['p','n'];
    if forcepacked then
     atom.aSet(pagecx,aForcepacked,StrNew('yes'),forRuntime);
    Show(edfajl,sfEditmod+sfForcePacked*ord(e.OutputKind(0)=okDirect),prevF3vis.x,prevF3vis.y);
    atom.aSet(pagecx,aForcepacked,nil,forRuntime);
    now_project:=GetNezkompPrj;
    FlushKey;
    {s.map^.Clr2Ful;}
    {s.ReInit;}
    AdjustMode;
    info_cls;
    info_file;
    st:=Pc2Str(atom.aGet(pagecx,aUserPal));
    atom.aSet(pagecx,aUserPal,nil,forDunno);
    {byla editovana paleta?}
    if st<>'' then
     {jsme v oldstyle palete?}
     if not forcepacked then begin
       if GetHeader('pal:')<>st then begin
         SetHeader('pal:',st);
         ShowModifiedPal:=true;
         end;
       end
     {jsme v directu s naforcovanou paletou}
     else begin
       oldtex:=GetHeader('tex:');
       newtex:=oldtex;
       SetColInTex('text',9);
       SetColInTex('cowriter',10);
       SetColInTex('link',11);
       SetColInTex('strong',12);
       if newtex<>oldtex then begin
         SetHeader('tex:',newtex);
         ShowModifiedPal:=true;
         end;
       end;
    StrDispose(pagecx);
    end;
 end;

 function InitDir:boolean;
 var ex:boolean;
 begin
  InitDir:=false;
  if (autorun_path='') and (dirExe=dirCur) and not fileExists('template') then begin
    ex:=dirExists('edit');
    if not ex and not dirMake('edit') then exit;
    if not dirChange('edit') then exit;
    if not ex and not Rip(GetDkod('!templat',false),'template') then exit;
    end;
  InitDir:=true;
 end;

 procedure InsertPalIfNeeded;
 begin
  if (texType(e.GetHeader('tex:'))='t') and (e.GetHeader('pal:')='') then begin
    e.SetHeader('pal:',']\_WVZRPVMKRHENC?J>:F95C^]_^C ]\ ]\_22 >> MM ZZ O::'+
      '_CC444>>>HHH :: HH UU NJ JG GD DA A> >< ;9 86 53 20 /. ,+ )( &% #"');
    e.modified:=true;
    end;
 end;

 function Shifted:boolean;
 begin
  Shifted:=kPressed[kLShift] or kPressed[kRShift];
 end;

 procedure CtrlT;
 var p:pchar;
 begin
  p:=e.pos;
  while p^ in ['a'..'z','A'..'Z','_','0'..'9','ˆ','¨','‡','©','‘','˜',' ','¡',
   '‚','£','–','Ÿ','¤','ƒ','¢','‰','›','€','ž','’','','','‹','','—','¦','†','¥','…','•'] do inc(p);
  if p=e.pos then
   if p^ in [CR,chgINIT] then inc(p,2) else inc(p);
  while p^=' ' do inc(p);
  e.DelSpaces(word(e.pos),word(p)-word(e.pos));
 end;

var do_autorun:boolean;
    latin2:shortint;
    edited:boolean;
label 0,4,6,7,8,10,newodst,znova,insertni,useit,rezoom,redraw,modif,alt_x,menucase,ed_tex,x2eol,label_death,exitus;
Begin
 if not InitDir then exit;
 latin2:=0;
 now_project:=GetNezkompPrj;
 do_autorun:=autorun_path<>'';
 altx:=hdr_nop;
 lastalign:=0;
 GetMem(edSpace,edSize);
 if edSpace=nil then Halt(erLowMem);
 precol:=1;
 prefnt:=1;
 edfajl:=lastpage;
 if not s.Init(model_text,TxtRes.X,TxtRes.Y,0) then Halt(_erBadMode);
 AdjustMode;
 new(s.lista,Init(model_text,s.Xres,1));if s.lista=nil then Halt(erLowMem);
 s.userSpocitej:=SpocitejToXY;
 kSetHandler(true);

 0:{new file}
 prevF3vis.x:=0;
 prevF3vis.y:=0;
 ZfalsovaniMapy;
 s.pen:=PEN_VIRTUAL;
 s.Clr2Ful;
 s.pen:=PEN_VIRT_AREA;
 s.lista^.Clr2Ful;
 if do_autorun then begin
   edfajl:=autorun_path;
   do_autorun:=false;
   end
 else
   edfajl:=UpCased(dlgFile(dlgEscReturnsNothing+dlgUpdateDir+dlgDoLoadDirs+dlgAllowNew,
           _(_msgZadejJmStr),fileMask(isHypertext),PathSlice(edfajl,psFile)));
 ZruseniMapy;
 if edfajl='' then begin
   exitus:
   KillObj(s.lista);
   s.Done;
   FreeMem(edSpace,edSize);
   exit;
   end;
 lastpage:=LoCased(edfajl);
 dirChange(PathSlice(edfajl,psPath));
 edfajl:=PathSlice(edfajl,psFile);
 nowSloupec:=1;
 {vymaze filebazi protoze se behem selektoru moh zmenit direc
  a fajly jsou ve filebazi zrejme ulozeny bez dirce}
 ResetNezkompDM;

 4:
 {precte text.soubor}
 someResult:=erLowMem;
 e.Init(edSize,edSpace,edfajl,dmtfResizeNadp+dmtfRepMisTemp+dmtfCreatePage,someResult);
 case someResult of
   erOk:;
   errFileNotFound:begin
     e.modified:=true;
     PByte(edSpace)^:=0;{aby nameril delku textu 0}
     e.Init(edSize,edSpace,'',0,someResult);
     erCheck(someResult);
     end
   else begin
     if someResult<>_erBadFont then ReportErr(_(someResult));
     goto 0;
     end;
   end;

 myXzoom:=0;
 cil.x:=0;
 cil.y:=0;
 e.GoZaheader3;
 e.nlGoto(+1);
 fixcoords:=true;

 info_cls;
 info_file;

rezoom:

 NastaveniEPodleTextu;
 NastaveniMapyPodleE;
 InsertPalIfNeeded;

 goto redraw;

modif:
 e.modified:=true;

redraw:
 RefreshTextScreen(true);

 if overflows>0 then begin
   myXzoom:=myXzoom*1.1;
   ZruseniMapy;
   goto rezoom;
   end;

 with s do with e do repeat

   10:
   if linenow<>-1 then GotoCoords(ednowx,linenow);
   if blkShiftedActionDone then begin RefreshTextScreen(false);{*}end;
   dlgHelp:=nil;
   Info_XY;
   ListaRedraw;
   SetActivity(syncMovingOn+syncDrawingOn+syncMouseOn);
   repeat
     if linenow=-1 then vga_HideCursor else begin
       vga_ShowCursor;
       Gotoxy(ednowx,ednowy);
       end;
     Sync;
   until GetEvent(event,poss);
   SetActivity(syncMovingOff+syncDrawingOff+syncMouseOff);


   {ReportErr('code='+stri(code(event))
            +' char=#'+stri(ord(char(event)))
            +' extchar=#'+stri(ord(extchar(event))));{}

   blkShiftedActionInit(Shifted and not (CODE(event) in [kInsert,kDelete]));

   possib_in_empty:=(CODE(event) in ([kF1,kF2,kF3,kF4,kEsc]+mcAny))
                 or (EXTCHAR(event) in [#120..#131,#25,#31,#32]);
   if (linenow=-1) and not possib_in_empty then ReportErr(_(_msgPrazdnySloupec))
   else
   CASE CODE(event) of

     mcLeftPressed,
     mcRightPressed:begin
             mouseGetChange(m,n);
             holdcodes:=0;
             end;
     mcLeftHold{move layer}
             :if holdcodes>=0 then begin
                inc(holdcodes);
                if holdcodes=holdcodes2run then MoveCursorTo(poss);
                if holdcodes>=holdcodes2run then begin
                  mouseGetChange(m,n);
                  if (pixStart+m>=0) and (pixStart+pixLen+m<GetNum(e.GetHeader('siz:'),1))
                   then SlpAddNum(nowsloupec,2,m);
                  if integer(SlpY(2*nowsloupec-1)+n)>0
                   then SlpAddNum(nowsloupec,3,n);
                  if (m<>0) or (n<>0) then goto modif;
                  end;
                end;
     mcRightHold{resize and rehook layer}
             :if holdcodes>=0 then begin
                inc(holdcodes);
                if holdcodes=holdcodes2run then MoveCursorTo(poss);
                if holdcodes>=holdcodes2run then begin
                  mouseGetChange(m,n);
 {*bioswriteln(stri(m)+' '+stri(n));}
                  if holdcodes=holdcodes2run then onlyM:=abs(m)>=abs(n);
                  if onlyM then begin
                    {zuzeni/rozsireni}
                    if (m<>0)
                     and (pixLen+m>6)
                     and ((pixLen+m>35) or (OutputKind(0)=okTxt))
                     and (pixMid-(pixLen+m) div 2>=0)
                     and (pixMid-(pixLen+m) div 2+(pixlen+m)<=GetNum(e.GetHeader('siz:'),1)) then begin
                      SlpSetNum(nowsloupec,4,pixLen+m);
                      goto modif;
                      end;
                    end
                  else begin
                    {rehook}
                    inc(acum,n);
                    n:=acum div 10;
                    dec(acum,n*10);
                    if (n<>0) and SlpRehook(nowsloupec,n) then goto modif;
                    end;
                  end;
                end;
     mcLeftReleased{position cursor}
             :if (holdcodes>=0) and (holdcodes<holdcodes2run) then begin
                holdcodes:=-1;
                MoveCursorTo(poss);
                end;
     mcRightReleased{menu}
             :if (holdcodes>=0) and (holdcodes<holdcodes2run) then begin
                holdcodes:=-1;
                goto alt_x;
                end;

     {ka:begin
     asm push word ptr s.pen end;
     pen:=pen_screen;
     if not (freeb[1] in [14..16]) then freeb[1]:=14;
     inc(freeb[1]);
     gotoxy(10,freeb[1]);
     readkey;
     asm pop word ptr s.pen end;
     end;}

     kF1     :begin
              menulist.Init(false);
              menulist.InsertStr(_(_menuHelp0),0);
              menulist.InsertStr(_(_menuHelp1),0);
              menulist.InsertStr(_(_menuHelp2),0);
              menulist.InsertStr(_(_menuHelp3),0);
              menulist.InsertStr(_(_menuHelp4),0);
              menulist.InsertStr(_(_menuHelp5),0);
              menulist.InsertStr(_(_menuHelp6),0);
              menulist.InsertStr(_(_menuHelp7),0);
              menulist.InsertStr(_(_menuHelp8),0);
              menulist.InsertStr(_(_menuHelp9),0);
              menulist.InsertStr(_(_menuHelp10),0);
              menulist.InsertStr(_(_menuHelp11),0);
              i:=dlgMenuNdx(' '+_(_menuHelp),@menulist,hlpMenu);
              menulist.Done;
              if i<>0 then begin
                hlpMenu:=i;
                hlpLocal:=TError(word(_menuHelp)+2*i);
                call_help;
                end;
              {hlpLocal:=_help_editor;
              call_help;
              goto redraw;{}
              end;
     kF2     :ESave;
     kF3     :begin
              fixcoords:=true;{aby se kurzor po f3 nehnul z konce radku na zacatek novyho}
              if extchar(event)=#86 then begin
                pictures:=false;
                animations:=false;
                slideshows:=false;
                end;
              edited:=ShowModifiedPal;
              if extchar(event)=#86 then begin
                pictures:=true;
                animations:=true;
                slideshows:=true;
                end;
              if edited then goto modif else goto redraw;
              end;
     kF4     :begin
              {$ifdef TVED}
              i:=ERawLine;
              e.modified:=true;
              ESave;
              e.Done;
              ZruseniMapy;
              s.forbid_alreadyset:=true;
               new(mode_for_tv,Init(model_text,s.Xres,s.Yres,0));
               mode_for_tv^.forbid_alreadyset:=true;
               mouseSetJump(8,8);
               mys.mouseSetRange(0,0,mode_for_tv^.Xres-1,mode_for_tv^.Yres-1);
               mys.mouseSetPos(mode_for_tv^.Xres div 2,mode_for_tv^.Yres div 2);
                CurScrolScreen:=nil;{nebude aktivni zadna scrolscreena}
                 old_mouseHandler:=mouseHandler;
                 mouseSetHandler(false);
                  oldHeapError:=HeapError;
                   ScreenWidth:=s.Xres;
                   ScreenHeight:=s.Yres;
                   HiResScreen:=true;
                   ScreenBuffer:=ptr(s.segvram,0);
                   if mode_for_tv^.Xres<>80 then ButtonCount:=0 else ButtonCount:=mouseButtons;
                   asm mov ah,3;mov bh,0;int 10h;mov Cursorlines,cx;end;
                   RawEd(edfajl,i);
                  HeapError:=oldHeapError;
                 mouseSetHandler(old_mouseHandler);
                CurScreen:=nil;{turbovision meni mod, uz ani screena neni aktivni}
               KillObj(mode_for_tv);
              s.forbid_alreadyset:=false;
              AdjustMode;
              goto 4;
              {$endif}
              end;
     kF5,kF6 :begin
              if code(event)=kF5 then begin
                {any F5 = zmena barvy}
                menulist.Init(false);
                menulist.InsertStr(_(_menuBarvy1),0);
                menulist.InsertStr(_(_menuBarvy2),0);
                menulist.InsertStr(_(_menuBarvy3),0);
                menulist.InsertStr(_(_menuBarvy4),0);
                precol:=dlgMenuNdx(' '+_(_menuBarvy0),@menulist,precol);
                menulist.Done;
                if precol=0 then continue;
                c:=chr(precol+ord(chgCOL)-1);
                end
              else if extchar(event)=#89 then begin
                {shift F6 = font z fontlistu}
                menulist.Init(false);
                st:=GetHeader('fnt:');
                while st<>'' do menulist.InsertStr(CutName(st),0);
                prefnt:=dlgMenuNdx(' '+_(_msgVyberFont),@menulist,prefnt);
                menulist.Done;
                if prefnt=0 then continue;
                c:=chr(prefnt+ord(chgFNT)-1);
                end
              else if extchar(event)=#99 then begin
                {ctrl F6 = nahrad font ve fontlistu}
                menulist.Init(false);
                st:=GetHeader('fnt:');
                while st<>'' do menulist.InsertStr(CutName(st),0);
                prefnt:=dlgMenuNdx(' '+_(_msgKteryFnNahradit),@menulist,prefnt);
                if prefnt<>0 then st:=PathSlice(dlgFile(0,_(_msgVyberFont),fnts,Pc2Str(menulist.At(prefnt-1))),psFile);
                menulist.Done;
                if prefnt=0 then continue;
                if st='' then continue;
                AssignFontToMark(st,chr(ord(chgFNT)+prefnt-1));
                myXzoom:=0;{aby znova detekoval}
                ZruseniMapy;
                NastaveniEPodleTextu;
                NastaveniMapyPodleE;
                goto modif;
                end
              else begin
                {not-shift F6 = font z fileselectoru}
                st:=PathSlice(dlgFile(0,_(_msgVyberFont),fnts,''),psFile);
                if st='' then continue;
                {st[200]:=pos^; proc to tu bylo?}
                pre:=GetHeader('fnt:');
                c:=GetSetFontMark(st);
                if c>chgFNTz then begin
                  SetHeader('fnt:',pre);
                  dlgStr(_(_msgNoMoreFonts));
                  goto 10;
                  end;
                end;
              i:=0;
              {koukne jestli nemuze chgcol prsknout pres nasledujici}
              if pos^=chgINIT then case c of
                 chgCOL..chgCOLz:case (pos+1)^ of chgCOL..chgCOLz:begin inc(i,2);end;end;
                 chgFNT..chgFNTz:case (pos+1)^ of chgFNT..chgFNTz:begin inc(i,2);end;end;
                 end;
              {koukne jestli nemuze chgcol prsknout pres minulej}
              if (pos-2)^=chgINIT then case c of
                 chgCOL..chgCOLz:case (pos-1)^ of chgCOL..chgCOLz:begin dec(pos,2);inc(i,2);end;end;
                 chgFNT..chgFNTz:case (pos-1)^ of chgFNT..chgFNTz:begin dec(pos,2);inc(i,2);end;end;
                 end;
              InsStr(word(pos),i,chgINIT+c);
              NastaveniEPodleTextu;
              goto modif;
              end;
     kF7     :begin
              if EXTCHAR(event)=#65 then st:=dlgInputLink(_(_msgKamVedeOdkaz),fileMask(isHypertext)+';'+fileMask(isScript))
                                    else st:=dlgInputLink(_(_msgKamVedeOdkaz),'*.*');
              if st<>'' then begin
                InsStr(word(pos),0,chgINIT+chr(ord(chgCOL)+2)+chgINIT+chgLINK+st+chgINIT+chgCOL);
                dec(pos,4+length(st));
                goto modif;
                end;
              end;
     kF8     :begin
              pre:='';
              if extchar(event)=#91{shift-F8} then begin
                pre:=dlgInputLink(_(_msgKamVedeOdkaz),'*.*');
                if pre='' then continue;
                pre:='href='+pre;
                end;
              if GetFlag(flagShading)>0 then begin
                if pre<>'' then pre:=' '+pre;
                pre:=pre+'shadeborder=on castshadow=on whiteborder=on';
                end;
              if pre<>'' then pre:=','+pre;
              st:=PathSlice(dlgFile(0,_(_msgVyberObr),fileMask(isGraphics),''),psLow+psName);
              if (st<>'') and picGetInfo(fileFind(st,isGraphics),orim,orix,oriy) then begin
                InsStr(word(pos),0,#13+#10+cmdINIT+cmdINSPIC+st+','+stri(orix)+'x'+stri(oriy)+pre+cmdDONE+#13+#10);
                goto modif;
                end;
              end;
     kF10    :begin
              st:=dlgInputLink(_(_msgVyberSkript),fileMask(isScript));
              if st<>'' then begin
                InsStr(word(pos),0,#13#10+cmdINIT+cmdSCRIPT+st+cmdDONE);
                goto modif;
                end;
              end;
     kF12    :begin
              label_death:
              if not e.modified then ESave else
               case dlgExit of
                  'C':goto 10;
                  'S':ESave;
                 end;
              e.Done;
              ZruseniMapy;
              goto exitus;
              end;

     {----------KURZOR-------------}
     kLeft   :if EXTCHAR(event)=#75 then begin
                if ednowx>round(pixStart*Xzoom) then dec(ednowx);
                end
              else begin
                while (pos-1)^=TAB do dec(pos);
                repeat
                  dec(pos);
                  case pos^ of
                    ' ':;
                    #13:break;
                    cmdDONE:chGoto(cmdINIT,-0);
                    else if (pos-1)^ in [' ',#10,cmdDONE] then break;
                    end;
                until false;
                SearchCoordsIn(nowsloupec,ednowx,ednowy,linenow);
                end;
     kRight  :if EXTCHAR(event)=#77 then begin
                if ednowx+1<round((pixStart+pixLen)*Xzoom) then inc(ednowx);
                end
              else begin
                repeat
                  inc(pos);
                  case pos^ of
                    ' ':;
                    #13:break;
                    cmdINIT:chGoto(cmdDONE,+1);
                    EOP:begin dec(pos,2);break;end;
                    else if (pos-1)^ in [' ',#10,cmdDONE] then break;
                    end;
                until false;
                SearchCoordsIn(nowsloupec,ednowx,ednowy,linenow);
                end;
     kUp     :if linenow>SlpFirstLine(nowsloupec) then begin dec(linenow);ednowy:=scry^[linenow];end;
     kDown   :if linenow<SlpLastLine(nowsloupec ) then begin inc(linenow);ednowy:=scry^[linenow];end;
     kPgUp   :if EXTCHAR(event)=#73 then begin
                if linenow>SlpFirstLine(nowsloupec)+20 then dec(linenow,21) else linenow:=SlpFirstLine(nowsloupec);
                ednowy:=scry^[linenow];
                end
              else begin
                nowSloupec:=1;
                SlpGo(nowsloupec);
                GotoSlpStart;
                pixSlpGo;
                end;
     kPgDwn  :if EXTCHAR(event)=#81 then begin
                if linenow+20<SlpLastLine(nowsloupec) then inc(linenow,21) else linenow:=SlpLastLine(nowsloupec);
                ednowy:=scry^[linenow];
                end
              else begin
                nowSloupec:=SlpMax;
                SlpGo(nowsloupec);
                GotoSlpEnd;
                pixSlpGo;
                end;
     kHome   :if EXTCHAR(event)=#71
               then GotoLineStart
               else GotoSlpStart;
     kEnd    :if EXTCHAR(event)=#79
               then GotoLineEnd
               else GotoSlpEnd;

     {----------EDIT-------------}
     kBackspace:
              begin
              if (pos-2)^=#13 then begin
               i:=word(pos);
               nlGoto(-1);
               if ReadChar=cmdINIT then
                if ReadChar in [cmdNEWSLP,cmdINSPIC] then continue;{nebackspacuje kdyz je na zacatku sloupce}
               word(pos):=i;
               end;
              if (pos-1)^=cmdDONE then j:=word(pos)-chAdr(cmdINIT,-0) else
              if (pos-2)^ in [#13,chgINIT] then j:=2 else j:=1;
              InsStr(word(pos)-j,j,'');
              goto modif;
              end;
     kEnter,
     kkEnter :begin
              InsStr(word(pos),0,#13#10);
              goto modif;
              end;
     kInsert :begin
              case EXTCHAR(event) of
                #82{none/shift}:if Shifted then blkPaste else begin
                    VeryStartLine(linenow);
                    InsStr(word(pos),0,#13#10);
                    dec(pos,2);
                    end;
                #146{ctrl}:begin blkCopy;goto redraw;end;
                #162{alt}:;
                end;
              goto modif;
              end;
     kDelete :begin
              case EXTCHAR(event) of
                #83{none/shift}:if Shifted then blkCut else
                   if (word(pos)<konec-2{2=crlf}) and ((pos+2)^<>cmdINIT) then begin
                     if pos^=chgINIT then j:=2 else
                      if pos^=#13 then begin j:=2;while (pos+j)^=TAB do inc(j);end
                       else j:=1;
                     InsStr(word(pos),j,'');
                     end;
                #147{ctrl}:blkDelete;
                #163{alt}:;
                end;
              goto modif;
              end;
     kEsc    :;

     else    CASE CHAR(event) of

     #20     :{Ctrl-T}
              if not ((e.pos+2)^ in [EOP,cmdINIT]) then begin
                CtrlT;
                goto modif;
                end;
     #25     :{Ctrl-Y}
              begin
              VeryStartLine(linenow+1);
              p2:=pos;
              j:=SlpNow;
              VeryStartLine(linenow);
              p1:=pos;
              i:=SlpNow;
              {nemazat cr/lf pokud
                -ukoncuje sloupec}
              if i<>j then word(p2):=nlAdr(+1)-2 else
               {-ukoncuje odstavec}
              if ((p1-1)^<>#10) and ((p2-1)^=#10) then dec(p2,2);
              e.DelSpaces(word(p1),p2-p1);
              {vlozit cr/lf pokud za poslednim radkem chybi a ja ho smazal
               a linenow ted tudiz ukazuje na docasne neexistujici radek}
              if p1^=EOP then e.InsStr(word(p1),0,e.newln);
              {pokud jsem pokracovanim odstavce a prerovnanim textu se kurzor
               dostal o radek vys, zas ho skopnout...}
              i:=linenow;
              e.modified:=true;
              RefreshTextScreen(true);
              {...tim se rozhodi se ednowy, proto ho musi prepocitat}
              GotoCoords(0,i);
              SearchCoordsIn(nowsloupec,ednowx,ednowy,linenow);
              end;
     chgINIT,
     cmdINIT,
     cmdDONE :{zakazane znaky};
     #1..#255:{text}
              begin
              InsStr(word(pos),0,csAutoDecodedChar(char(event)));
              blkStatus:=blkNoChange;
              goto modif;
              end;

     #0      :CASE EXTCHAR(event) of

     {----------SLOUPCE-------------}
     #67     :{F9}
              begin
              VeryStartLine(linenow);
              if SlpSplit(nowsloupec) then begin
                inc(nowsloupec);
                RefreshTextScreen(true);
                SlpRehook(nowsloupec,2-2*nowsloupec);
                goto modif;
                end;
              end;
     #92     :{shift-F9}
              if nowsloupec>1 then
               if dlgChoice(_(_msgMamSloucitSlp),_(_dlgYesCancel))=1 then
                if SlpMerge(nowsloupec) then begin
                 dec(nowsloupec);
                 goto modif;
                 end;
     #120..#131:{alt-1..alt-0}
              begin
              i:=ord(extchar(event))-119;
              if i<=SlpMax then begin
                nowSloupec:=i;
                SlpGo(nowsloupec);
                nlGoto(+1);
                GotoSlpStart;
                pixSlpGo;
                end;
              end;

     {---------------OSTATNI-----------------}
     {#45     :{alt-x}
              {goto label_death;}
     #25     :{alt-p}
              begin
              pre:=GetHeader('tex:');
              i:=byte(hdr_tex);
              goto ed_tex;
              end;
     #32     :{alt-d}
              begin
              i:=byte(altx);
              goto menucase;
              end;
     #31     :{alt-s}
              begin
              alt_x:
              dlgHelp:=call_help;
              hlpLocal:=_fileHelp_edmenu;
              menulist.Init(false);
              for i:=1 to hdr_lines do menulist.InsertStr(_(hdr[i].code),0);
              i:=dlgMenuNdx(' '+_(_menuEd0),@menulist,byte(altx));
              menulist.Done;
              menucase:
              if i>0 then begin
                byte(altx):=i;
                case altx of
                  hdr_edr:begin
                       pre:=stri(TxtRes.x)+'x'+stri(TxtRes.y);
                       st:=dlgLine(0,_(_menuRozliseniEdu),pre);
                       if st<>pre then begin
                         TxtRes.x:=CutNum(st);
                         TxtRes.y:=CutNum(st);
                         ReportErr(_(_msgAzPriste));
                         end;
                       end;
                  hdr_ali:begin
                       menulist.Init(false);
                       menulist.InsertStr(_(_menuAli1),0);
                       menulist.InsertStr(_(_menuAli2),0);
                       menulist.InsertStr(_(_menuAli3),0);
                       menulist.InsertStr(_(_menuAli4),0);
                       menulist.InsertStr(_(_menuAli5),0);
                       i:=dlgMenuNdx(' '+_(_menuAli0),@menulist,lastalign);
                       menulist.Done;
                       if i>0 then begin
                         lastalign:=i;
                         e.SetAlignHere(integer(i)-2);
                         goto modif;
                         end;
                       end;
                  hdr_cen:begin
                       e.SlpAddNum(nowsloupec,2,GetNum(e.GetHeader('siz:'),1) div 2-pixMid);
                       goto modif;
                       end;
                  hdr_syz:begin
                       switchYZ:=not switchYZ;
                       end;
                  else begin
                       pre:=GetHeader(hdr[i].txt);
                       st:=pre;
                       case altx of hdr_lan:dlgSelectLanguage;
                                    hdr_tem:begin
                                            st:=PathSlice(dlgFile(0,_(hdr[i].code),fileMask(isHypertext),pre),psLow+psFile);
                                            if st<>pre then begin
                                              e.SetHeader('tem:',st);
                                              KillObj(e.mytemplate);
                                              e.LoadTemplate(0);
                                              end;
                                            end;
                                    hdr_siz:begin
                                             i:=SlpMaxX;
                                             st:=dlgLine(0,_i(_msgVelikStr,stri(i)),pre);
                                             if GetNum(st,1)<i then st:=ReplacedNum(st,1,i);
                                             i:=byte(altx);
                                            end;
                                    hdr_res:st:=dlgLine(0,_(_msgDoporucRozlis),pre);
                                    hdr_nam:st:=dlgLine(0,_(_msgJmenoStranky),pre);
                                    hdr_aut:st:=dlgLine(0,_(_msgJmenoAutora),pre);
                                    hdr_fla:st:=dlgLine(0,_(_msgFlags),pre);
                                    hdr_tex:begin
                                            ed_tex:
                                            dlgHelp:=call_help;
                                            hlpLocal:=_fileHelp_textures;
                                            st:=dlgLine(0,_(_msgDefinujPozadi),pre);
                                            end;
                                    hdr_bkg:begin
                                            if texType(pre)='p' then begin
                                              st:=paramSet(pre,'background',PathSlice(CodeLink(dlgFile(0,_(hdr[i].code),
                                               fileMask(isLoadable+isGraphics),DecodePic(paramGet(pre,'background')))),
                                               psLow+psFile));
                                              end
                                            else begin
                                              st:=pre;
                                              if (st='') or (dlgChoice(_(_msgMuzuZrusitTex),_(_dlgYesCancel))=1) then begin
                                                st:=PathSlice(CodeLink(dlgFile(0,_(hdr[i].code),
                                                     fileMask(isLoadable+isGraphics),'')),psLow+psFile);
                                                if st='' then st:=pre else st:=paramSet('','background',st);
                                                end;
                                              end;
                                            end;
                                    hdr_fnt:st:=dlgLine(0,_(hdr[i].code),pre);
                                    else    st:=PathSlice(dlgFile(0,_(hdr[i].code),Pc2Str(hdr[i].typ),pre),psLow+psFile);
                                    end;
                       if (st<>pre) then begin
                         SetHeader(hdr[i].txt,st);
                         ZruseniMapy;
                         NastaveniEPodleTextu;
                         NastaveniMapyPodleE;
                         InsertPalIfNeeded;
                         goto modif;
                         end;
                       end;
                  end;
                end;
              end;
     end;
     end;
     end;
 until code(event)=kEsc;

 if not e.modified then ESave else
  case dlgExit of 'C':goto 10;
                  'S':ESave;
                 end;
 e.Done;
 ZruseniMapy;
 goto 0;
End;

var
 vykr:string[1];
 param:string[4];
 i,j:integer;
 kbfree:longint;
 titlepic:PathStr;

BEGIN
{  heaplimit:=63*1024;}
  if not ZpracujParametry then Halt(_erWritten);

  if debug then BiosWriteln('Start...');
  if debug then BiosWriteln(_(_msgZabijimDemony));
    Randomize;
    if not DosAtLeast($400) then Halt(_erWritten);
    if mouseButtons=0 then BiosWriteln(_(_msgNoMouse));

  if debug then BiosWriteln(_(_msgCheckEventWait));
    if not EventWaitOk then begin
      if debug then BiosWriteln(_(_msgNoEventWait));
      {BiosWriteln(_(_msgMuzuPokracovat));
      if readkey=#27 then Halt(_erWritten);}
      end;

  if debug then BiosWriteln(_(_msgChkOS));
    CheckOS;
    if debug then BiosWriteln('  ...'+Pc2Str(os[ops]));
    if debug and (ops=windows) then BiosWriteln(_(_msgScrolSuxInWin));

  if debug then BiosWriteln(_(_msgChkMem));
    kbfree:=memavail div 1024;
    if kbfree<3500 then
     if kbfree>2000 then BiosWriteln(_(_msgNeMocPameti)) else begin
       BiosWriteln('');
       BiosWriteln(_(_msgMaloPameti));
       if readkey=#27 then Halt(_erWritten);
       end;

  if debug then BiosWriteln('DMs...');
    ScanDMs(true);
    AddGlobalAtoms;

  if debug then BiosWriteln('INI...');
    GetIni;{musi uz byt ready grafika protoze pred vytvarenim prvniho ini se pta na jazyk}

  if debug then BiosWriteln('ResList holocaust...');
    if debug then BiosWrite('  '+stri(reslist.count)+' -> ');
    PromazReslist;
    if debug then BiosWriteln(stri(reslist.count)+' modes');
    {if vesaversion =0 then BiosWriteln(_(_msgNoVBE));}

  if debug then BiosWriteln('Mouse...');
    LoadSipka;

    InstallCzFonts;

  if debug then BiosWriteln('Main...');
    i:=0;
    j:=0;
    if editmod then Editor else
     if IsSystemPrj(now_project) then begin
       titlepic:=fileFind(inidir+'!title',isLoadable+isGraphics);
       if titlepic='' then titlepic:=EitherS(buttpics and not safemode,'!title.jpg','!title.png');
       if detectedBadGfx and avoidBadGfx then titlepic:='!badgfx';
       Show(titlepic,0,i,j)
       end
      else Show(title,0,i,j);

  if debug then BiosWriteln('The end...');
  BiosWriteln(mach_msg);
END.

konverze: tabulek,mramoru
ripper - sortingy, alt pismeno,
stranka music nebo ndx info k modulum
flag 'precteno' v indexu
posttexturing
samplovanej smooth scroller: sipky,Pgx/y,Home/end
alb2<>alb3
 cmd na zarovnavani zleva az do konce odstavce
cool default pal
cia: pri zmene sipky u kraje obrazovky hodi scrol out of range
v method=movsd mazat mys jen na moment
cia trik: v 320x200/packed b.staticmap(ptr(segvram,0),lineoffset)
vbe buglist: SCOV nabankuje bank(0) pri pozadavku na bank(banks/2)
p29/novinky: cte a playuje sampl furt dal jako by nemel konec

ed: problem s obrazky pod 5 pixelu

b8 k00l

kdyz to nevychazi kvuli dlouhy sekvenci tychz znaku, prizpusobit delku sekvence
 a to na obe strany, podtrzitek pridat, tecek a mezer ubrat.
 rekneme nahradit kazdych >20 stejnych znaku repeats*rpt_char_sir/avg_char_sir
 ale jen mimo oblasti s Ýf,>0Þ

udelat stranky na heslo
volne definovatelny parametry co dat do a.dm a co do b.dm
po gobacku nenastavi uzivatelsky zmenenou paletu ale original
kdyz nenajde ripfajl, chkbox se chova jako by nebyl ripovaci
udelat atommanager aby slo smaznout uzivatelskou paletu
v mainmenu zrusit button 'nezkompilovano'

v 1280x1024 scrol sux (nekdy)
kdyz fejduje tak at nescrolluje
v textmodu jsou cary jinde nez v grafice
prohlizeni clanku vyhne
nahradit px-em askstringy, ankname, password
nekdy zabere text v grafice o neco vic radek
playani pri blackscreenu mozna vrati paletu puvodniho modu
po rozpuleni dlouhyho stringu v grafice na dve pulky to vypise v textmodu
v ini zmenit vyznam fadein/out
dlgMsg v palete s nowbright=0 neni videt
co udela kdyz ma hrat modul a ten neni v projektu - zmlkne nebo hraje dal starej?
at neprestane hrat kdyz dojede na stranku jejiz moduly nema

parlan bugy:
 spadne kdyz je v souboru neuzavreny komentar
 hlasi bug na radce cislo xx ale neukaze ji

[featury]
skript na vlozeni nekolika obrazku vedle sebe
escapnutelnej slider
selektor sortujici fonty podle velikosti a nabizejici jejich pravy jmena
add vertikal kern
fce parlanu na volani standardnich dialogu masiny
autoplay, nahodny ukazovani stranek
moznost zkopnout projekt na disk, moznost smazat projekt z disku
-fulltext search
-flag r kterej yaridi ye bude mit slideshow jedno royliseni
-writer se stinem, s obtahem apod
dat ikonu na plochu

[optimalizace]
vypnout mp3 dekoding muziky kdyz je jeji volume 0

[bugy]
sesypavaci scrsaver v directcolor neztmavuje
vsechny obrazky ze skriptu bere ze jsou to stranky a maj slideshow
pada v data()... blbej hiword nebo loword dkodu?
neuvolneny bajtiky po ani.scr
vgacko: lista je o pixel delsi nez ma bejt
neuvolnuje pamet
superrychlej scrol jako by bylo nekolikrat menis actualfreq nez ma bejt
u redoxe po interactivetests trvale nescrolluje 640*480/15/16
 (masina si mysli jak hw scroluje ale obraz se nehybe)
u redoxe s univbe smoothscrolluje 800x600/15/16, bez univbe je movsd
strka chkbox0/1.gif do rt70[B!].dm
!14.fn a !11.fn nemaj slovensky znaky
