UNIT Supp;

{$i define.inc}

{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}
                             INTERFACE
{‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹}

USES  Chyby,Memo,
      Objects,Dos,Strings,
      Cache,Fajly,DMFile,Stringy,
      Sys,Key,Mys,Vga,Scrol,DMBitmap,Tools,Dialogy,Fonty,Writer1,Writer2,
      DMExport,DMText,
      Atoms,DMAtoms,NFDos,DMScript,
      Loadery,FlcPlay,
      ScrSaver,
      {$ifdef rain}
      Rain2;
      {$else}
      Midas2;
      {$endif}

Function  Init:TError;
Procedure Done;

Const
      musfade   = 14;

      sfEditmod            =1;{nastaveno vzdy pri volani z editoru}
      sfForcePacked        =2;{nastaveno jen kdyz ma nasilne prevadet direct na packed}
      sfDontChangeTextMode =4;{poprve nemen txt rozliseni, pozdeji muzes}

Type  TStaticMode=object {objekt uchovavajici zda mame drzet pevne dany rozliseni nebo si muzem prepinat}
        x,y,bitdepth:word;
        procedure SetDynamic;
        procedure SetLike(screen:PScreen);
        function  ChangeAllowed:boolean;
        end;
Var
      ShowResolutions      :boolean;
      staticMode           :TStaticMode;
      Shell                :string;
      ScreenSaver          :byte;
      chovaniMysi          :byte;
      fadein               :byte;
      fadeout              :byte;
      dirExp               :DirStr;
      dirBrowseMods        :DirStr;
      infobar              :boolean;
      buttpics             :boolean;
      oldiesWarnings       :integer;

PROCEDURE PromazReslist;
PROCEDURE LoadSipka;
PROCEDURE MouseAdjustSize(s:PScreen);
PROCEDURE Show(name:PathStr;flags:word;var startX,startY:integer);

procedure SetDefaultPageName(st:PathStr);
function  GetNextSlidePic:PathStr;


{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}
                          IMPLEMENTATION
{‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹}



  var maxFnHeight:word;{je li <>0, plati}
  procedure my_dlgPreInit;far;
  var doporucFnHeight:word;
  begin
   with CurScreen^ do
     if Yres<Xres then
       case Yres of
          0..100:doporucFnHeight:=6;
        101..350:doporucFnHeight:=8;
        351..400:doporucFnHeight:=11;
        401..480:doporucFnHeight:=14;
        else     doporucFnHeight:=16;
        end
     else
       doporucFnHeight:=16;
   if maxFnHeight=0 then maxFnHeight:=255;
   case minW(doporucFnHeight,maxFnHeight) of
      0.. 5:dlgFont:='!05.fn';
          6:dlgFont:='!06.fn';
      7..10:dlgFont:='!08.fn';
{      0..10:dlgFont:='!08.fn';}
     11..13:dlgFont:='!11.fn';
     14..15:dlgFont:='!14.fn';
     else   dlgFont:='!16.fn';
     end;
   maxFnHeight:=0;
  end;

  procedure my_dlgPostInit;far;
  begin
   SS.smpPlay(GetDkod(nam_menuon,true));
  end;

  procedure my_dlgDone;far;
  begin
   SS.smpPlay(GetDkod(nam_menuout,true));
  end;



procedure TStaticMode.SetDynamic;
begin
 x:=0;
 y:=0;
 bitdepth:=0;
end;

procedure TStaticMode.SetLike(screen:PScreen);
begin
 x:=screen^.Xres;
 y:=screen^.Yres;
 bitdepth:=screen^.BiPP;
 {$ifdef beta}
  if bitdepth=0 then erBetaMsg('SetLike: screena ma bipp=0');
 {$endif}
 if screen^.ByPP=4 then bitdepth:=32;
end;

function TStaticMode.ChangeAllowed:boolean;
begin
 ChangeAllowed:=bitdepth=0;
end;


{---------------------------------------------------------------------------
 Vyhaze z ResListu vsechny nevhodne mody.
 ---------------------------------------------------------------------------}
PROCEDURE PromazReslist;
 function BetterExists(model,x,y:word):boolean;
 const priority:string[8]=chr(model_bgr16)+chr(model_bgr15)+
                          chr(model_rgb16)+chr(model_rgb15)+
                          chr(model_bgr24)+chr(model_bgra32)+
                          chr(model_rgb24)+chr(model_rgba32);
 var   i:word;
 begin
  BetterExists:=false;
  with ResList do
   if Count>0 then
    for i:=Count-1 downto 0 do
     with PResItem(Items^[i])^ do
      if (ax=x) and (ay=y) and
       ( {((amodel in models_direct) and (pos(chr(amodel),priority)<pos(chr(model),priority)))
         or{}
         ((amodel=model_packed) and (model=model_unchained))
       )
       then begin
         BetterExists:=true;
         {$ifdef testvga}bioswrite(' ('+stri(i)+' iz betta) ');{$endif}
         break;
         end;
 end;
var   i:word;
begin
 {$ifdef testvga}
 with ResList do
  if Count>0 then
   for i:=Count-1 downto 0 do
    with PResItem(Items^[i])^ do
     bioswriteln(' '+stri(i)+': '+stri(ax)+'x'+stri(ay)+'/mdl='+stri(amodel));
 {$endif}
 with ResList do
  if Count>0 then
   for i:=Count-1 downto 0 do
    with PResItem(Items^[i])^ do
     if BetterExists(amodel,ax,ay) or
      ((amodel in models_8)
       and not (    (ax>=320){na nekterejch kartach je obraz uzkej}
                and ((amodel<>model_unchained) or (ax+ay<376+308) or (ay=464))
                and (ay<>282){sux na s3_325_virge_3d_2200}
               )
      ) then begin
        {$ifdef testvga}bioswriteln(' kill '+stri(ax)+'x'+stri(ay)+'/mdl='+stri(amodel));{$endif}
        AtFree(i);
        end;
end;

{---------------------------------------------------------------------------
 Zepta se na jedno ze seznamu rozliseni.
 Po escapu vrati -1, jinak index do reslistu.
 ---------------------------------------------------------------------------}
FUNCTION dlgSelectResolution(srcmodel:word):integer;
 var c:TMenuCollection;
     default:integer;
     mindif:word;

 procedure AddToMenu(item:PResItem);far;
 var dif:word;
     kod:longint;
 begin
  with item^ do
   if Convertable(srcmodel,amodel) then begin
    {preselektuje nejblizsi mod, nemusi presne matchovat}
    dif:=abs(ax-curscreen^.Xres)+abs(ay-curscreen^.Yres);
    kod:=ResList.IndexOf(item)+1;
    if (amodel=curscreen^.MapModel) and (dif<mindif) then begin
      default:=kod;
      mindif:=dif;
      end;
    c.InsertStr(stri(ax)+'x'+stri(ay)+'/'+ModelStr[amodel],kod);
    end;
 end;

begin
 dlgSelectResolution:=-1;
 default:=1;
 mindif:=maxword;
 if c.Init(false) then begin
   ResList.ForEach(@AddToMenu);
   maxFnHeight:=screen^.Yres div (c.count+4);
   dlgSelectResolution:=dlgMenuKod(_(_menuPomRes),@c,default)-1;
   c.Done;
   end;
end;

{---------------------------------------------------------------------------
 Zepta se na jeden ze seznamu projektu.
 ---------------------------------------------------------------------------}
FUNCTION dlgSelectProject:integer;
var c:TMenuCollection;
    p:TPrjs;
begin
 dlgSelectProject:=-1;
 if c.Init(false) then begin
   for p:=1 to projects do begin
     c.InsertStr(DM[prj[p].prjDMmain]^.projekt,p);
     end;
   dlgSelectProject:=dlgMenuKod(_(_menuPomProj),@c,now_project);
   c.Done;
   end;
end;

{---------------------------------------------------------------------------
 Zepta se na jednu stranku.
 ---------------------------------------------------------------------------}
FUNCTION dlgSelectPage(now_Dkod:TDkod;autori:string):TDkod;
var c:TMenuCollection;
    Dkod:TDkod;
    st:string[34];
    ndx:integer;
begin
{ aLoadPagDescriptions;}
 c.Init(true);
 with prj[now_project] do begin
   locasni(autori);
   Dkod:=FirstDkod;
   while Dkod<>0 do begin
     if ((autori<>'') or ((DkodIs(Dkod) and isHypertext>0) and (PathSlice(Data(Dkod)^.name^,psName)<>'LANG')))
      and hkNalezi(locased(Pc2Str(atom.aGet(cx(now_project,Dkod,0),aAuthor))),autori) then begin
        st:=Pc2Str(atom.aGet(cx(now_project,Dkod,0),aPageName));
        if st='' then st:=Data(Dkod)^.name^;
        ndx:=c.IndexOf(Str2TempPc(st));
        if ndx=-1 then c.InsertStr(st,Dkod) else
         if Data(Dkod)^.name^<Data(c.KodOf(c.At(ndx))^)^.name^
          then c.KodOf(c.At(ndx))^:=Dkod;
        end;
     Dkod:=NextDkod;
     end;
   end;
 dlgSelectPage:=dlgMenuKod(_(_menuPomPage),@c,now_Dkod);
 c.Done;
end;

{---------------------------------------------------------------------------
 Zepta se na jednu stranku od vybraneho autora.
 ---------------------------------------------------------------------------}
FUNCTION dlgSelectPageByAuthor(now_Dkod:TDkod):TDkod;
var c:TMenuCollection;
    Dkod:TDkod;
    st:string[34];
    ndx:integer;
    sum:longint;
    p,q:pchar;
begin
{ aLoadPagDescriptions;}
 c.Init(true);
 with prj[now_project] do begin
   Dkod:=FirstDkod;
   while Dkod<>0 do begin
     st:=Pc2Str(atom.aGet(cx(now_project,Dkod,0),aAuthor));
     if (st<>'') or (DkodIs(Dkod) and isHypertext>0) then begin
       ndx:=c.IndexOf(Str2Pc(st));
       if ndx=-1 then sum:=0 else sum:=c.KodOf(c.At(ndx))^;
       inc(sum,Data(Dkod)^.len+$1000000);
       if ndx=-1
        then c.InsertStr(st,sum)
        else c.KodOf(c.At(ndx))^:=sum;
       end;
     Dkod:=NextDkod;
     end;
   if c.count>0 then
    for ndx:=0 to c.count-1 do begin
      p:=c.At(ndx);
      sum:=c.KodOf(p)^;
      c.items^[ndx]:=c.StrAndKod(Pc2Str(p)+' '+stri(sum shr 24)+'/'+stri((sum and $ffffff) shr 10)+'KB',0);
      c.FreeItem(p);
      end;
   {c.InsertStr('*',0);}
   end;
 ndx:=0;
 repeat
   ndx:=dlgMenuNdx(_(_menuPomAutori),@c,ndx);
   if ndx=0 then begin Dkod:=0;break;end;
   st:=Pc2Str(Pchar(c.At(ndx-1)));
   while st[length(st)]<>' ' do dec(st[0]);
   dec(st[0]);
   Dkod:=dlgSelectPage(now_Dkod,st);
 until Dkod<>0;
 c.Done;
 dlgSelectPageByAuthor:=Dkod;
end;


{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ SLIDESHOW ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}

var   default_pagename:PathStr;

procedure SetDefaultPageName(st:PathStr);
begin
 default_pagename:=st;
end;

function GetPageName:PathStr;
begin
 if default_pagename<>'' then GetPageName:=default_pagename else
  begin
   {$ifdef beta}
   if CurScrolScreen=nil then erBetaMsg('getpagename');
   {$endif}
   GetPageName:=UpCased(Data(PDMBitmap(CurScrolScreen^.Map)^.Dkod)^.Name^);
  end;
end;

function GetNextSlidePic:PathStr;
var   st:PathStr;
      b:boolean;
      D:DirStr;
      N:NameStr;
      E:ExtStr;
begin
 st:=GetPageName;
 FSplit(st,D,N,E);
 {kdyz neni obrazek, zkusi zahajeni slideshow}
 if ((fileIs(st) and (isLoadable{+isGraphics}))<>isLoadable){+isGraphics}
  and slideshows
  then st:=D+copy(N,1,6)+'00.' else begin
    {zahodi prebytecnou koncovku}
    st:=D+N+'.';
    {kdyz je obrazek ale ne ze slideshow, nepokracuje}
    if (length(N)<=2) or not (st[length(st)-1] in ['0'..'9']) or not (st[length(st)-2] in ['0'..'9'])
     then st:='' else
    {kdyz je obrazek ze slideshow, zkusi pokracovani}
     begin
      if st[length(st)-1]<'9' then inc(st[length(st)-1]) else begin
        inc(st[length(st)-2]);
        st[length(st)-1]:='0';
        end;
      end;
    end;
 GetNextSlidePic:=fileFind(st,isLoadable{+isGraphics});
end;




{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ TREE ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}

Const maxvnoreni      = 100;
Var   tree            :array[1..maxvnoreni] of PScrolScreen;{minimalizovany popis ostatnich stranek}
      intree          :byte;{hloubka vnoreni - kolik stranek je nacato}
      now_page        :TDkod;
      now_parent      :TDkod;

Procedure LeaveMap(s:PScrolScreen;ilistu:boolean);
begin
 {$ifdef beta}
 if s=nil then erBetaMsg('leavemap with s=nil');
 {$endif}
 with s^ do
  if map<>nil then begin
   PDMBitmap(map)^.FillGivenSleepBuf(@mapsleep);
   MapDone(ilistu);
   end;
end;

{---------------------------------------------------------------------------
 Uspi a pushne scrolscreenu na stack uspanych scrolscreen.
 ---------------------------------------------------------------------------}
Procedure PushPage(var s:PScrolScreen);
begin
 if debugC then BiosWriteln('PushPage...');
 {$ifdef beta}
 if s=nil then erBetaMsg('pushpage with s=nil');
 {$endif}
 if intree>=maxvnoreni then erMsg(_(_erMocVnoreni));
 LeaveMap(s,false);
 inc(intree);
 tree[intree]:=s;
 s:=nil;
 if debugC then BiosWriteln('PushPage OK.');
end;

{---------------------------------------------------------------------------
 Popne scrolscreenu ze stacku uspanych scrolscreen.
 Je-li s<>nil, killne ho.
 Vrati name.
 ---------------------------------------------------------------------------}
Function PopPage(var s:PScrolScreen):PathStr;
begin
 if debugC then BiosWriteln('PopPage...');
 if intree=0 then Halt(erLowMem);
 if s<>nil then begin
   s^.silentDone:=true;
   LeaveMap(s,true);
   end;
 with tree[intree]^ do begin
   now_project:=PSleepRec(@mapsleep)^._project;
   now_page   :=PSleepRec(@mapsleep)^._Dkod;
   now_parent :=PSleepRec(@mapsleep)^._parent;
   PopPage    :=Data(now_page)^.name^;
   map:=GetDMBitmap(now_page,now_parent,0{flags},@mapsleep);
   if map=nil then erMsg(_(_erNelzeObnovStr));
   JoinMapTo(map,tree[intree],false);{konverti mapu do modelu screeny}
   PDMBitmap(map)^.titletimeoutcounter:=0;{inaktivuje counter po gobacku}
   if CurScreen<>nil then CurScreen^.Fade(-word(fadeout)*screenfreq div 70);
   reinitSpeed:=+word(fadein)*screenfreq div 70;
   ReInit;{nejdriv nastavit mod nove stranky...}
   end;
 KillObj(s);{...az potom potichu zrusit starou stranku}
 s:=tree[intree];
 tree[intree]:=nil;
 dec(intree);
 if not staticMode.ChangeAllowed then staticMode.SetLike(s);
 if debugC then BiosWriteln('PopPage OK.');
end;

{---------------------------------------------------------------------------
 Goback stranek ze stacku killne.
 ---------------------------------------------------------------------------}
Procedure KillPage(goback:integer);
begin
 for goback:=goback downto 1 do begin
   if intree=0 then exit;
   tree[intree]^.SilentDone:=true;
   KillObj(tree[intree]);
   dec(intree);
   end;
end;


{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ BUTTS ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}

Function ChooseFont(sir,vys:integer):FileStr;
begin
 if vys<350 then ChooseFont:='tiny.fn' else
  if (sir<500) and (vys>sir) then ChooseFont:='tenkej.fn'
   else ChooseFont:='modern.fn';
end;

{---------------------------------------------------------------------------
 Vygeneruje dmbutton - box se dvema stringy a rameckem.
 ---------------------------------------------------------------------------}
var
 w1,w2:PWriter1;
 {bcXXXX - button color; O=outside; I=inside; Tx=textcolor; Fr=framecolor}
 bcO,
 bcOTxLo,
 bcOTxHi,
 bcOFrLo,
 bcOFrHi,
 bcI,
 bcITx,
 bcIFrLo,
 bcIFrHi:longint;

Procedure InitMakeButt(s:PScrolScreen);
begin
 bcO     :=s^.Color(0,160,160,255);
 bcOTxLo :=s^.Color(0,104,104,255);
 bcOTxHi :=s^.Color(0,212,212,255);
 bcOFrLo :=s^.Color(0,212,212,255);
 bcOFrHi :=s^.Color(0,104,104,255);
 bcI     :=s^.Color(0,104,104,255);
 bcITx   :=s^.Color(200,200,0,255);
 bcIFrLo :=s^.Color(0, 68, 68,255);
 bcIFrHi :=s^.Color(0,212,212,255);
{ if s^.MapModel in models_8 then inc(bcITx,9 shl 24);}
 w1:=nil;
 w2:=nil;
 new(w1,Init); if w1=nil then Halt(erLowMem);
 new(w2,Init); if w2=nil then Halt(erLowMem);
 if not w1^.SetFont('bard.fn')                   then Halt(_erBadFont);
 if not w2^.SetFont(ChooseFont(s^.Xres,s^.Yres)) then Halt(_erBadFont);
 w1^.SetColor(bcITx);
end;

Procedure DoneMakeButt;
begin
 KillObj(w1);
 KillObj(w2);
end;

Procedure Frame(b:PBitmap;x,y,sir,vys,ramsir,ramvys:integer;hicolor,locolor:longint);
begin
 with b^ do begin
   Col2Box(x+sir-ramsir,y,ramsir,vys,hicolor);
   Col2Box(x,y,sir,ramvys,locolor);
   Col2Box(x,y+vys-ramvys,sir,ramvys,hicolor);
   Col2Box(x,y,ramsir,vys,locolor);
   end;
end;

Function MakeButt(buttsir,buttvys,ramsir,ramvys:word;pc1,pc2:pchar;highlight:boolean):PBitmap;
const obtah          =1;{jak silny je ramecek}
      addL           =0;{o kolik je zesilena leva strana ramecku}
var   b              :PBitmap;
      botvys,col     :integer;
      winx,winy,
      winsir,winvys  :integer;
begin
 b:=nil;
 nextPal:=CurScreen^.pal;{boxik prijme za svou paletu obazovky}
 new(b,Init(CurScreen^.MapModel,buttsir,buttvys));
 if b=nil then Halt(erLowMem);
 with b^ do begin
   botvys:=minI(w2^.GetFontHeight,buttvys-(2)*ramvys);
   winx  :=(addL+2+obtah)*ramsir;
   winy  :=(     2+obtah)*ramvys;
   winsir:=sizeX-(addL+4+2*obtah)*ramsir;
   winvys:=sizeY-(     4+1*obtah)*ramvys-botvys;
   Col2Ful(bcO);
   Frame(b,0,0,sizeX,sizeY,ramsir,ramvys,bcOFrHi,bcOFrLo);
   if (pc1<>nil) and (winvys>0) then begin
     Frame(b,winx-ramsir,winy-ramvys,winsir+2*ramsir,winvys+2*ramvys,ramsir,ramvys,bcIFrHi,bcIFrLo);
     if not Str2BoxW(b,winx,winy,winsir,winvys,w1,buttpics and not safemode,pc1,0,bcI)
      then erMsg(_(_erBadBox));
     end;
   if highlight then w2^.SetColor(bcOTxHi) else w2^.SetColor(bcOTxLo);
   if not Str2BoxW(b,ramsir,sizeY-1*ramvys-botvys,sizeX-2*ramsir,botvys,w2,false,pc2,+2,bcO)
    then erMsg(_(_erBadBox));
   end;
 MakeButt:=b;
end;

{---------------------------------------------------------------------------
 Vygeneruje a prihodi na obrazovku dmbutton.
 ---------------------------------------------------------------------------}
const buttram=220;
Procedure AddButt(s:PScrolScreen;k:TDkod;buttx1,butty1,buttsir,buttvys:word;pc1,pc2:pchar;highlight:boolean);
var   b:PBitmap;
      ramsir,ramvys:integer;
      oldpen:byte;
      rect:TRect;
label bad;
begin
 with s^ do begin
  ramsir:=round((buttsir/Xres+buttvys/Yres)*Xres/buttram+1);
  ramvys:=round((buttsir/Xres+buttvys/Yres)*Yres/buttram+1);
  with PDMBitmap(map)^ do begin
    b:=MakeButt(buttsir,buttvys,ramsir,ramvys,pc1,pc2,highlight);
    rect.Assign(buttx1,butty1,buttx1+buttsir,butty1+buttvys);
    aInstallPx(project,Dkod,rect,StrNewNum(k),nil,nil);
    end;
  oldpen:=pen;
  pen:=PEN_SCREEN;
  s^.BtF2Box(b,buttx1,butty1);
  pen:=oldpen;
  end;
 b^.Free;
end;

{---------------------------------------------------------------------------
 Zobrazi celou sadu buttonu (horni lista+projekty).
 ---------------------------------------------------------------------------}
const
 kod_setup   =1001;
 kod_index   =1002;
 kod_ripper  =1003;
 kod_shell   =1004;
 kod_help    =1005;{pridano posledni, doufam ze s nicim nekoliduje}
 kod_quit    =1006;
 kod_mode    =1100;

PROCEDURE ShowButts(s:PScrolScreen);
var   buttvys,buttsir,x,y,now,nowdone,buttlines,buttsperline:integer;
      mezeraX,mezeraY,vedlesebe,i,j,nonsysPrjs,zbyva:integer;
      oldmouse{,indexPossible,ripperPossible}:boolean;
      winsir,wintoy,toplinevys:integer;
      lomodes:boolean;
      resBareW,resFullW:word;
type  string13=string[13];

  Function NextNonsys:word;
  begin
   inc(now);if IsSystemPrj(now) then inc(now);
   inc(nowdone);
   NextNonsys:=now;
  end;

  Procedure AddTopButt(kod:longint;st1,st2:string13);
  begin
   buttsir:=(s^.Xres-x) div zbyva;
   AddButt(s,kod,x,0,buttsir,buttvys,Str2Pc(st1),Str2Pc(st2),false);
   inc(x,buttsir);
   dec(zbyva);
  end;

  Function IsGood(p:PResItem):boolean;
  begin
   with p^ do IsGood:=(amodel in models_gfx) and
     ((lomodes and (ax+ay<640+480)) or (not lomodes and (ax+ay>=640+480)));
  end;

  Procedure CountGoodModes(p:PResItem);far;
  begin
   if IsGood(p) then inc(zbyva);
  end;

  Procedure DrawGoodModes(p:PResItem);far;
  var st:string[15];
  begin
   if IsGood(p) then with p^ do begin
     buttvys:=(wintoy-y) div zbyva;
     st:=stri(ax)+'x'+stri(ay)+'/'+ModelStr[amodel];
     AddButt(s,kod_mode+ResList.IndexOf(p),x,y,buttsir,buttvys,nil,
       Str2Pc(st),(s^.Xres=ax) and (s^.Yres=ay) and (s^.MapModel=amodel));
     inc(y,buttvys);
     dec(zbyva);
     end;
  end;

Begin
 InitMakeButt(s);
 with s^ do begin
   nonsysPrjs:=projects-1;
   {indexPossible:=false;
   ripperPossible:=false;}
   oldmouse:=MouseHide;

   {---kresli TOP_BUTTs---}
   toplinevys:=Yres div Either(buttpics and not safemode,5,8);
   buttvys:=toplinevys;
   x:=0;
   zbyva:=5;
   {if indexPossible then inc(zbyva);
   if ripperPossible then inc(zbyva);}

   with DMfile.DM[systemDM]^ do AddTopButt(GetSystemPrj,popisek     ,projekt     );
                                AddTopButt(kod_setup   ,_(_setup1)  ,_(_setup2)  );
   inc(x,Xres div 40);
                                AddTopButt(kod_help    ,_(_help1)   ,_(_help2)   );
   {if indexPossible then        AddTopButt(kod_index   ,_(_index1)  ,_(_index2)  );
   if ripperPossible then       AddTopButt(kod_ripper  ,_(_ripper1) ,_(_ripper2) );}
                                AddTopButt(kod_shell   ,_(_shell1)  ,_(_shell2)  );
                                AddTopButt(kod_quit    ,_(_konec1)  ,_(_konec2)  );
   now:=0;
   nowdone:=0;

   {---kresli RESs---}
   resBareW:=0;
   resFullW:=0;
   if ShowResolutions then begin
     resBareW:=Xres div 6;
     resFullW:=resBareW+6*Xres div Yres;
     winsir:=resBareW;
     wintoy:={top}Yres-8;
     x:=(resFullW-resBareW) div 2;
     y:=toplinevys+8;
     buttsir:=winsir;
     zbyva:=0;
     lomodes:=true;
     ResList.ForEach(@CountGoodModes);
     ResList.ForEach(@DrawGoodModes);
     x:=Xres-resBareW-(resFullW-resBareW) div 2;
     y:=toplinevys+8;
     zbyva:=0;
     lomodes:=false;
     ResList.ForEach(@CountGoodModes);
     ResList.ForEach(@DrawGoodModes);
     end;

   {---kresli DMs---}
   {zacina v [0,y] a vyplni to do [buttswinsir,buttswinvys]}
   y:=toplinevys;
   winsir:=Xres-2*resFullW;
   wintoy:={top}Yres;
   buttsir:=Xres div 6;
   buttvys:=Yres div Either(buttpics and not safemode,6,8);
   mezeraX:=Xres div 36;
   mezeraY:=Yres div 36;
   vedlesebe:=winsir div (buttsir+mezeraX);
   buttlines:=(nonsysPrjs-1+vedlesebe) div vedlesebe;
   if buttlines*(buttvys+mezeraY)<wintoy-y then begin
     {ridke vyplnovani}
     inc(y,(wintoy-y-(buttlines*(buttvys+mezeraY)-mezeraY)) div 2);
     for i:=1 to buttlines do begin
       buttsperline:=(nonsysPrjs-nowdone) div (buttlines+1-i);
       x:=(winsir-(buttsperline*(buttsir+mezeraX)-mezeraX)) div 2;
       for j:=1 to buttsperline do begin
         with DMfile.DM[prj[NextNonsys].prjDMmain]^ do
          AddButt(s,now,x+resFullW,y,buttsir,buttvys,Str2Pc(popisek),Str2Pc(projekt),now=now_project);
         inc(x,buttsir+mezeraX);
         end;
       inc(y,buttvys+mezeraY);
       end
     end
   else begin
     {huste vyplnovani}
     inc(y,Yres div 24);
     buttlines:=trunc(sqrt(nonsysPrjs));
     for buttlines:=buttlines downto 1 do begin
       buttvys:=(wintoy-y) div buttlines;
       buttsperline:=(nonsysPrjs-nowdone) div buttlines;
       x:=0;
       for j:=1 to buttsperline do begin
         buttsir:=(winsir-x) div buttsperline;
         dec(buttsperline);
         with DMfile.DM[prj[NextNonsys].prjDMmain]^ do
          AddButt(s,now,x+resFullW,y,buttsir,buttvys,Str2Pc(popisek),Str2Pc(projekt),now=now_project);
         inc(x,buttsir);
         end;
       inc(y,buttvys);
       end;
     end;

   if oldmouse then MouseShow;
   end;
 DoneMakeButt;
end;


{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ PALETA ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}
{
      Col2Box(a.x,a.y-1-vys,b.x-a.x+1,vys,bcI);
      fullsir:=longint(abs(last-first)+1)*(b.x-a.x) div 40;
      for j:=vys+1 downto 2 do begin
        smallsir:=fullsir*(vys+2-j) div vys;
        if first<=last then Col2Box(a.x+longint(first-1)*(b.x-a.x) div 40,a.y-j,smallsir,1,bcITx)
                       else Col2Box(a.x+longint(first)*(b.x-a.x) div 40-smallsir,a.y-j,smallsir,1,bcITx);
        end;
}

PROCEDURE ShowPalPanel(s:PScrolScreen;direct:boolean);
var  b:PBitmap;
     buttsir,buttvys:integer;
     ramsir,ramvys:integer;
     oldpen:byte;
     winshiftX,winshiftY:integer;
     rect:TRect;
     data:pchar;
begin
 InitMakeButt(s);
 buttsir:=s^.Xres;
 buttvys:=s^.Yres div 5;
 winshiftX:=(s^.Xres-buttsir) div 2;
 winshiftY:=(s^.Yres-buttvys) div 2;
 ramsir:=round((buttsir/s^.Xres+buttvys/s^.Yres)*s^.Xres/buttram+1);
 ramvys:=round((buttsir/s^.Xres+buttvys/s^.Yres)*s^.Yres/buttram+1);
 b:=MakeButt(buttsir,buttvys,ramsir,ramvys,'',Str2TempPc(_(_msgNastaveniPal)),false{highlight});

 oldpen:=s^.pen;
 s^.pen:=PEN_SCREEN;
 s^.BtF2Box(b,winshiftX,winshiftY);
 s^.pen:=oldpen;
 KillObj(b);

 with PDMBitmap(s^.map)^ do
  with rect do begin

   {paleta}
   rect.Assign(buttsir div 25,buttvys div 4,buttsir-buttsir div 25,buttvys div 2);
   rect.Move(winshiftX,winshiftY);
   if direct then begin
     data:=StrNew('9 4');
     editpalFirst:=Bounded(editpalFirst,9,12);
     editpalLast :=Bounded(editpalLast ,9,12);
     end
   else
     data:=StrNew('1 40');
   aInstallPx(project,Dkod,rect,StrNew('!palrng.scr'),data,nil);

   {r,g,b}
   a.x:=buttsir div 20;
   a.y:=buttvys div 2;
   b.x:=a.x+buttsir div 30;
   b.y:=a.y+buttvys div 5;
   Move(winshiftX,winshiftY);
   aInstallPx(project,Dkod,rect,StrNew('!chkbox.scr'),StrNew(vEditpalR),nil);
   Move(buttsir div 20,0);
   aInstallPx(project,Dkod,rect,StrNew('!chkbox.scr'),StrNew(vEditpalG),nil);
   Move(buttsir div 20,0);
   aInstallPx(project,Dkod,rect,StrNew('!chkbox.scr'),StrNew(vEditpalB),nil);

   {<->}
   Move(buttsir div 15,0);
   inc(b.x,b.x-a.x);
   aInstallPx(project,Dkod,rect,StrNew('!palrot.scr'),StrNew('x'),nil);

   {kontrast}
   rect.Assign(buttsir*3 div 9,buttvys*4 div 7,buttsir*5 div 9,buttvys*5 div 7);
   rect.Move(winshiftX,winshiftY);
   aInstallPx(project,Dkod,rect,StrNew('!slide.scr'),StrNew(vEditpalContras),nil);

   {jas}
   rect.Move(buttsir*3 div 11,0);
   aInstallPx(project,Dkod,rect,StrNew('!slide.scr'),StrNew(vEditpalBright),nil);

   {e}
   rect.Move(buttsir*3 div 11,0);
   b.x:=a.x+buttsir div 30;
   aInstallPx(project,Dkod,rect,StrNew('!palexp.scr'),nil,nil);

   {zavola nainstalovany skripty}
   aCallPxs(project,Dkod,s,nil);
   end;

 DoneMakeButt;
end;



{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ ANIMACE ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}

FUNCTION PlayAni(kod:TDkod;setPrevMode:boolean):boolean;
var   p:PDirectFLCPlayer;
      name:PathStr;
      event:TEvent;
      pos:TPoint;
      oldscr:PScrolScreen;
begin
 PlayAni:=false;
 if not animations then exit;
 oldscr:=CurScrolScreen;
 if kod<>0 then begin
   new(p,Init(new(PDMFileStream,Init(kod)),setPrevMode));
   if p<>nil then begin
     name:=PathSlice(data(kod)^.name^,psName);
     SS.smpPlay(GetDkod(fileFind(name,isSample),false));
     repeat
       SS.Sync;
       p^.screen^.Sync;
     until (p^.screen^.GetEvent(event,pos) and not (code(event) in
            [mcLeftHold,mcRightHold,mcCenterHold,mcLeftReleased,mcRightReleased,mcCenterReleased]))
           or kPressed[kkNum] or p^.Sync;
     if kPressed[kF12] then begin
       lastMsg:=mach_msg;
       Halt(erOk);
       end;
     oldscr^.reinitSpeed:=+word(fadein)*oldscr^.screenfreq div 70;
     KillObj(p);
     SS.smpStop;
     SS.smpPlay(GetDkod(nam_fade,true));
     PlayAni:=true;
     end;
   end;
end;

FUNCTION PlayFile(kod:TDkod):boolean;far;
var flags:word;
begin
 PlayFile:=true;
 flags:=DkodIs(kod);
 if (flags and isSound)>0 then SS.smpPlay(kod) else
{ if (flags and isSample)>0 then SS.smpPlay(kod) else
 if (flags and isModule)>0 then SS.musPlay(+musfade,false,kod) else}
{zda se ze jsem to zakomentoval protoze klik na modul odted povazuju za
 hudebni ukazku a tu vyrizuje smpPlay}
 if (flags and (isGraphics+isPlayable))>0 then begin
   if animations then
    with CurScrolScreen^ do
     with PDMBitmap(map)^ do begin
       SS.smpPlay(Dkods_samplyes.Random);
       Fade(-word(fadeout)*screenfreq div 70);
       SetActivity(syncAllOff);
       PlayAni(kod,true);
       SetActivity(syncAllOn);
       end;
   end
 else PlayFile:=false;
end;



{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ SHOW ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}

var   sipkagif:PBitmap;

PROCEDURE LoadSipka;
var name:PathStr;
begin
 name:=fileFind(inidir+'!mouse',isLoadable);
 if name<>'' then sipkagif:=picLoad(name);
 if sipkagif=nil then sipkagif:=picLoad('!mouse.x');
end;

{
 seridi velikost sipky at uz vlastni nebo systemove
}
PROCEDURE MouseAdjustSize(s:PScreen);
var map:PBitmap;
begin
 if s<>nil then begin
   {$ifdef testvga}bioswriteln('supp.adjustsize init');{$endif}
   if sipkagif=nil then map:=nil else map:=sipkagif^.FulCopy;
   {$ifdef testvga}bioswriteln('supp.adjustsize mid');{$endif}
   s^.MouseSetPointer(map,3*640,3*480,0,0);
   {$ifdef testvga}bioswriteln('supp.adjustsize done');{$endif}
   end;
end;


var   sv:PSV;
const vol:array[k1..k0] of byte=(1,3,6,10,16,23,31,40,51,64);{mus volumes}

PROCEDURE myUserSync;far;
var l:longint;
    k:byte;
begin
 with CurScrolScreen^ do
 if map<>nil then
  with PDMBitmap(map)^ do begin
    {sound system sync}
    SS.Sync;
    {crashes}
    l:=GetCrashLevel*SS.smpVolume div 10;
    if l>0 then SS.smpPlayVol(Dkods_samplkra.Random,l);
    {page autoforwarding}
    if titletimeoutcounter>0 then begin
      dec(titletimeoutcounter);
      if titletimeoutcounter=0 then PushEvent(MakeEvent(mcLeftPressed,#0,#0));
      end;
    {screen saver}
    if ScreenSaver<>0 then begin
      l:=TimeFromLastEvent div 1000;
      if (l>ScreenSaver*60) and (sv=nil) then sv:=RandomSaver else
      if (l<ScreenSaver*60) and (sv<>nil) then KillObj(sv);
      if sv<>nil then begin
        if debugpal then SetHwCol(0,40,40,40);
        sv^.Sync;
        if debugpal then SetHwCol(0,0,0,0);
        end;
      end;
    {keys
    if kPressed[kPrintScr] then PushEvent(MakeEvent(kPrintScr,#0,#0));}
    {if kPressed[kPause] then sethwcol(0,30,30,30) else sethwcol(0,0,0,0);}
    for k:=k1 to k0 do if kPressed[k] then SS.musVolume:=vol[k];
    {playlist/anims}
    if ((GetActivity and syncMovingOn)>0) and (playlist<>nil) then playlist^.Sync;
   end;
end;

PROCEDURE myMapUpdate(map:PBitmap);far;
begin
 if PDMBitmap(map)^.playlist<>nil
  then PDMBitmap(map)^.playlist^.Sync;
end;

FUNCTION  dirsList:string;
var st:string;
 procedure AddToSt(dir:pstring);far;
 begin
  if st<>'' then st:=st+#13#10;
  st:=st+dir^;
 end;
begin
 st:='';
 Dirs.ForEach(@AddToSt);
 dirsList:=st;
end;


var backup_pal1:PPalBody;
    backup_pal2:PPalBody;


{---------------------------------------------------------------------------
 Graficka cast od zacatku az do opusteni prostredi.
 ---------------------------------------------------------------------------}
PROCEDURE Show(name:PathStr;flags:word;var startX,startY:integer);
label 3,8,ending,
      labelsetcol,itisbadkey,gouback,help,setup;
var   i,j,k         :integer;
      event         :TEvent;
      st200         :string[200];
      someDkod      :TDkod;
      someLong      :longint;

      newmode       :integer;
      newproj       :TPrjs;
      newpage       :TDkod;

      px            :word;
      pxkod         :word;

      b,bb          :PDMBitmap;    {bitmapa pro tvorenou screenu}

      s             :PScrolScreen; {aktualni screena, nastavena az v okamziku
                                    kdy jsou vsechny predchozi udaje dohotoveny}
      prevs         :PScreen;      {screena kolem Show..nutna kvuli situaci:
       ed,show()=play(kin.flc)(znici curscreen)+show(kin)(prevscreen=nil)+esc(nenastavi prevscreen),ed(spadne)}
      oldKHandler   :boolean;      {zda byl pred show pusten khandler}

      menuing       :Boolean;      {rezimy}
      paleting      :Boolean;
      paleting2     :Boolean;

      virtPres      :TPoint;       {souradnice stisku vzhledem k bitmape}

      gobacky       :boolean;      {prisel jsem na label_jsemtady gobackem?}

      zded_lm_count :shortint;     {docasny data, kvuli dedeni}
      zded_lm_list  :TLMList;
      zded_jumps    :byte;
      zded_mx       :word;
      zded_my       :word;
      {zded_static_slide:boolean;}

      dlgHelpPresel :word;

      maska         :string[35];
      smallerthan   :longint;
      biggerthan    :longint;

      pushes        :byte;
      stack         :array[1..10] of longint;

  procedure push(l:longint);
  begin
   {$ifdef beta}
   if pushes>9 then erBetaMsg(_(_erMinistackOver));
   {$endif}
   inc(pushes);
   stack[pushes]:=l;
  end;

  procedure pop(var l:longint);
  begin
   {$ifdef beta}
   if pushes=0 then erBetaMsg(_(_erMinistackUnder));
   {$endif}
   l:=stack[pushes];
   dec(pushes);
  end;

  function c:PDMBitmap;
  begin
   c:=PDMBitmap(s^.map);
  end;

  procedure ProcOpen(var ing:boolean;sam:TDkod);
  begin
   with s^ do
    with c^ do begin
     SetActivity(syncMovingOff+syncTimerOff{*bez vypnuti timeru nejak tuhne pri closebutts});
     ing:=true;
     SS.smpPlay(sam);
     cur_mapDirect:=true;
     push(Dkod);
     Dkod:=kod_menu;
     pen:= PEN_SCREEN;{GetEvent bude vracet souradnice na obrazovce}
     end;
  end;

  procedure ProcClose(var ing:boolean;sam:TDkod);
  begin
   with s^ do
    with c^ do begin
     SS.smpPlay(sam);
     aLeavePage(project,Dkod);
     pop(Dkod);
     cur_mapDirect:=false;
     MouseHide;
     MapRedraw;
     ListaRedraw;
     SetActivity(syncMouseOn+syncMovingOn+syncTimerOn);
     ing:=false;
     pen:=PEN_VIRT_AREA;{GetEvent bude vracet souradnice na strance}
     end;
  end;

  procedure ProcOpenM;
  var oldmouse:boolean;
  begin
   if s^.MapModel=model_text then begin
     s^.PushEvent(MakeEvent(kF1,#0,#0));
     exit;
     end;
   ProcOpen(menuing,GetDkod(nam_menuon,true));
   oldmouse:=s^.MouseHide;
   ShowButts(s);
   if oldmouse then s^.MouseShow;
  end;

  procedure ProcEndM(sam:boolean);
  begin
   if sam
    then ProcClose(menuing,GetDkod(nam_menuon,true))
    else ProcClose(menuing,0);
  end;

  procedure ProcOpenP1;
  var oldmouse:boolean;
      direct:boolean;
  begin
   if (s^.MapModel in models_8)
   and not c^.palchanged
   and (c^.MapKind=ok256) then begin
     direct:=(atom.aGet(cx(now_project,c^.Dkod,0),aForcepacked)<>nil);
     ProcOpen(paleting,GetDkod(nam_palopen,true));
     backup_pal1^:=s^.map^.pal^.pal;
     oldmouse:=s^.MouseHide;
     ShowPalPanel(s,direct);
     if oldmouse then s^.MouseShow;
     end;
  end;

  procedure ProcAbortP1;
  begin
   ProcClose(paleting,GetDkod(nam_palabort,true));
   s^.map^.pal^.pal:=backup_pal1^;
   s^.Fade(0);
  end;

  procedure ProcEndP1;
  begin
   ProcClose(paleting,GetDkod(nam_palok,true));
   aStorePal(now_project,c^.Dkod,s^.map^.pal);
  end;

  procedure ProcOpenP2;
  begin
   paleting2:=true;
   backup_pal2^:=s^.map^.pal^.pal;
   SetHwCol(0,7,7,7);
   RunScript('!paledit.scr');
  end;

  procedure ProcAbortP2;
  begin
   paleting2:=false;
   s^.map^.pal^.pal:=backup_pal2^;
   s^.Fade(0);
   SetHwCol(0,0,0,0);
  end;

  procedure ProcEndP2;
  begin
   paleting2:=false;
   SetHwCol(0,0,0,0);
  end;

  {0=jen zmena rozliseni}
  {1=fullscreenovej klik}
  {2=klik na link}
  procedure zded_mouse(n:byte);
  begin
   if n<=chovaniMysi then begin
     zded_mx:=65536*s^.mouse.x div s^.Xres;
     zded_my:=65536*s^.mouse.y div s^.Yres;
    end else begin
     zded_mx:=32768;
     zded_my:=32768;
    end;
  end;

  var prev_dlgPreInit :TProc;
      prev_dlgPostInit:TProc;
      prev_dlgDone    :TProc;
      prev_dlgEvents  :string[10];

  procedure Show_Init;
  begin
   oldKHandler      :=kHandler;
   kSetHandler(true);
   unlockLockedKeys :=true;
   intree           :=0;
   s                :=nil;
   prevs            :=curscreen;
   b                :=nil;
   menuing          :=false;
   paleting         :=false;
   paleting2        :=false;
   gobacky          :=false;
   zded_jumps       :=0;
   zded_lm_count    :=0;
   {zded_static_slide:=false;}
   pushes           :=0;
   now_page         :=0;
   now_parent       :=0;
   sv               :=nil;
   dlgHelpPresel    :=kF4;
   prev_dlgPreInit  :=dlgPreInit;
   prev_dlgPostInit :=dlgPostInit;
   prev_dlgDone     :=dlgDone;
   prev_dlgEvents   :=dlgEvents;
   dlgPreInit       :=my_dlgPreInit;
   dlgPostInit      :=my_dlgPostInit;
   dlgDone          :=my_dlgDone;
   dlgEvents        :=chr(kF12);
   userdirty        :=true;
   TimeFromLastEvent;{resetne counter}
   zded_mouse(3);{na zacatku sipku centruje}
  end;

  procedure Show_Done;
  begin
   dlgPreInit       :=prev_dlgPreInit;
   dlgPostInit      :=prev_dlgPostInit;
   dlgDone          :=prev_dlgDone;
   dlgEvents        :=prev_dlgEvents;
   if (s<>nil) and (intree>=1) then s^.GetParentFrom(tree[1]);
   KillPage(30000);
   if s<>nil then begin
     s^.SetActivity(syncAllOff);
     startX:=s^.posNow.X;
     startY:=s^.posNow.Y;
     s^.SilentDone:=false;
     if prevs<>nil then s^.GetThisParent(prevs);
     KillObj(s);
     end;
   unlockLockedKeys :=false;
   kSetHandler(oldKHandler);
  end;

  function Gener8Lista(b:PBitmap):PBitmap;
  var   lista:PBitmap;
        w:PWriter2;
        x:integer;
        name,autor:pchar;
  begin
   {$ifdef testvga}bioswriteln('supp.gener8lista init');{$endif}
   lista:=nil;
   name:=atom.aGet(cx(now_project,now_page,0),aPageName);
   autor:=atom.aGet(cx(now_project,now_page,0),aAuthor);
   if infobar and ((name<>nil) or (autor<>nil)) then begin
     nextpal:=b^.pal;
     New(lista,Init(s^.mapmodel,s^.Xres,s^.Yres div 2));
     if lista<>nil then begin
       if lista^.MapModel=model_text then
         lista^.Col2Ful($8720)
       else begin
         lista^.Col2Ful(lista^.Color(40,40,40,255));
         lista^.Col2Box(0,0,lista^.sizeX,1,lista^.Color(20,20,20,255));
         end;
       New(w,Init(false{no editmod},0{tabu}));
       {nazev}
       w^.stSrc:=name;
       w^.SetBitmap(lista);
       w^.SetFormat(0{neodsazuje, necentruje});
       w^.SetProporc(ord(lista^.MapModel=model_text){orig nebo 1});
       w^.SetZarovnavat(1{roztah ke krajum});
       if ((lista^.MapModel =model_text) and not w^.lfInit('textmode.fn','135'))
       or ((lista^.MapModel<>model_text) and not w^.lfInit(fnDefault,stri(lista^.Color(220,220,220,255))))
        then Halt(_erBadFont);
       w^.slpSir:=lista^.sizeX-2*w^.GetCharShift('m');
       w^.slpMid:=lista^.sizeX div 2;
       w^.WriteLong(nil{newwriter},1,1{any zoom},#0{ender});
       {autor}
       w^.stSrc:=autor;
       if w^.stSrc<>nil then begin
         w^.SetZarovnavat(3{doprava});
         if (w^.otY>0) and (w^.stDest<=w^.slpSir-w^.GetPcLen(w^.stSrc)-2*w^.GetCharShift(' '))
          then dec(w^.otY,w^.GetFontHeight);
         w^.WriteLong(nil{newwriter},1,1{any zoom},#0{ender});
         end;
       if lista^.MapModel=model_text then
         lista^.DelLines(w^.otY,lista^.sizeY)
       else begin
         lista^.DelLines(w^.otY+1,lista^.sizeY);
         lista^.Col2Box(0,lista^.sizeY-1,lista^.sizeX,1,lista^.Color(60,60,60,255));
         lista^.Col2Box(0,0,1,lista^.sizeY,lista^.Color(20,20,20,255));
         lista^.Col2Box(lista^.sizeX-1,0,1,lista^.sizeY,lista^.Color(60,60,60,255));
         end;
       KillObj(w);
       end;
     end;
   Gener8Lista:=lista;
   {$ifdef testvga}bioswriteln('supp.gener8lista done');{$endif}
  end;

  {Vstupy:
   -bitmapa b
   -stranka s (varianty: s mapou, bez mapy, nil)
   Vystupy:
   -stranka s (s mapou)
  Je-li s neprazdne, vezme si jeho predka a killne ho.
  }
  procedure SetModeFor(var b:PDMBitmap;enablechange:boolean);
  var   newS:PScrolScreen;
        _model:word;
        _x,_y,_mode:integer;
  begin
   {$ifdef testvga}bioswriteln('supp.setmodefor init');{$endif}
   {$ifdef beta}
   if b=nil then erBetaMsg('setmodefor b=nil');
   {$endif}
   if CurScreen<>nil then CurScreen^.Fade(-word(fadeout)*CurScreen^.screenfreq div 70);
   if s<>nil then begin
     s^.silentdone:=true;
     LeaveMap(s,true);
     end;
   {if not enablechange
   or (((flags and sfDontChangeTextMode)>0) and (curscreen<>nil)
    and (curscreen^.mapModel=model_text) and (b^.doporucModel=model_text)) then begin
     b^.doporucModel:=curscreen^.mapModel;
     b^.doporucXres:=curscreen^.Xres;
     b^.doporucYres:=curscreen^.Yres;
     flags:=flags and not sfDontChangeTextMode;
     end;}
   if ((flags and sfDontChangeTextMode)>0) and (curscreen<>nil)
    and (curscreen^.mapModel=model_text) and (b^.doporucModel=model_text) then begin
     b^.doporucModel:=curscreen^.mapModel;
     b^.doporucXres:=curscreen^.Xres;
     b^.doporucYres:=curscreen^.Yres;
     flags:=flags and not sfDontChangeTextMode;
     end
   else
   if not enablechange then begin
     case staticMode.bitDepth of
        4:b^.doporucModel:=model_text;
        8:b^.doporucModel:=model_8;
       15:b^.doporucModel:=model_15;
       16:b^.doporucModel:=model_16;
       24:b^.doporucModel:=model_24;
       32:b^.doporucModel:=model_32;
       end;
     b^.doporucXres:=staticMode.x;
     b^.doporucYres:=staticMode.y;
     end;

   {problem: mame 8bit mapu, ale nemuzeme zadat o model_scrol=$a00
             a prednostne model_8=$100, prednostne muzeme chtit jen
             model_packed=$004 nebo model_unchained=$005
    reseni: pokud je zadan prednostne model_packed, zkusme prednostne model_8}
   if b^.doporucModel=model_scrol+model_packed then begin
     _model:=model_8;
     _x:=b^.doporucXres;
     _y:=b^.doporucYres;
     _mode:=0;
     if ModeDoplnInfo(_model,_x,_y,_mode) then b^.doporucModel:=model_8;
     end;

   nextPal:=b^.pal;
   New(newS,Init(b^.doporucModel,b^.doporucXres,b^.doporucYres,0));
   if (newS=nil) or (newS^.InitResult in [chaos,stillold]) then Halt(_erBadMode);
   if s<>nil then begin
     newS^.GetParentFrom(s);
     KillObj(s);
     end;
   s:=newS;
   {$ifdef testvga}bioswriteln('supp.setmodefor 1');{$endif}
   if sipkagif<>nil then MouseAdjustSize(s);
   {$ifdef testvga}bioswriteln('supp.setmodefor 2');{$endif}
   if (b^.MapModel in models_8) xor (s^.MapModel in models_8)
    then b^.palchanged:=true;
   {$ifdef testvga}bioswriteln('supp.setmodefor 3');{$endif}
   s^.MapInit(b,Gener8Lista(b),startX div s^.charXres,startY div s^.charYres);
   {$ifdef testvga}bioswriteln('supp.setmodefor 4');{$endif}
   s^.MouseSetPos(HiWord(longint(s^.Xres)*zded_mx),HiWord(longint(s^.Yres)*zded_my));
   {$ifdef testvga}bioswriteln('supp.setmodefor 5');{$endif}
   s^.UserSync:=myUserSync;
   s^.MapUpdate:=myMapUpdate;
   b:=nil;
   startX:=0;
   startY:=0;
   atom.aSet(cx(0,0,0),aXres,StrNewNum(s^.Xres),forRuntime);
   atom.aSet(cx(0,0,0),aYres,StrNewNum(s^.Yres),forRuntime);
   {$ifdef testvga}bioswriteln('supp.setmodefor done');{$endif}
   if not staticMode.ChangeAllowed then staticMode.SetLike(s);
  end;

  procedure SetAmp;
  var stopmoving    :boolean;
      dlgAmp        :pointer;
      ampTicks      :integer;
      i             :integer;
  begin
   with s^ do begin
    stopmoving:=(GetActivity and syncMovingOn)>0;
    if stopmoving then SetActivity(syncMovingOff);
    ampTicks:=20;
    dlgAmp:=nil;
    repeat
     if kPressed[kkPlus] then begin SS.amp_real:=SS.amp_real*1.02;ampTicks:=50;end;
     if kPressed[kkMinus] then begin SS.amp_real:=SS.amp_real/1.02;ampTicks:=50;end;
     if (dlgAmp=nil) or (SS.amp_long<>round(SS.amp_real)) then begin
       SS.amp_long:=round(SS.amp_real);
       KillObj(dlgAmp);
       dlgAmp:=dlgStrOpen(stri(SS.amp_long)+'%');
       end;
     Sync;
     dec(ampTicks);
     if GetEvent(event,virtPres) then
      if not (code(event) in [kkPlus,kkMinus]) then begin
        PushEvent(event);
        ampTicks:=0;
        end;
    until ampTicks<=0;
    KillObj(dlgAmp);
    if stopmoving then SetActivity(syncMovingOn);
    end;
  end;

  procedure Menu_Export;
  const export_preselect:word=1;
  var   i:integer;
        result:TError;
        c:TMenuCollection;
        b:PBitmap;
        oldpen:byte;
  begin
   if ReadOnlyMod then begin ReportErr(_(_erReadOnly));exit;end;
   c.Init(false);
   c.InsertStr(_(_menuExport1),0);
   c.InsertStr(_(_menuExport2),0);
   c.InsertStr(_(_menuExport3),0);
   c.InsertStr(_(_menuExport4),0);
   c.InsertStr(_(_menuExportW1),0);
   c.InsertStr(_(_menuExportW2),0);
   c.InsertStr(_(_menuExportW3),0);
   c.InsertStr(_(_menuExportM1),0);
   c.InsertStr(_(_menuExportM2),0);
   c.InsertStr(_(_menuExportM3),0);
   i:=dlgMenuNdx(_(_menuExport0),@c,export_preselect);
   c.Done;
   if i=0 then exit;
   export_preselect:=i;
   if not (i in [1,2,8{pozor}]) and ((fileIs(name) and (isLoadable+isGraphics))=(isLoadable+isGraphics)) then begin
       dlgStr(_(_msgStrNeobsText));
       exit;
       end;
   while not dirMake(dirExp) or not dirWriteable(dirExp) do begin
     if copy(dirExp,length(dirExp)-7,8)='\export\' then dec(dirExp[0],7);
     dirExp:=dlgPathBrowser(dlgEscReturnsNothing,_(_msgKamExportovat),'*.* export',dirExp);
     if dirExp='' then exit;
     end;
   SS.smpPlay(GetDkod(nam_rip,true));
   case i of
     1:begin
       oldpen:=s^.pen;
       s^.pen:=PEN_SCREEN;
       b:=s^.BoxCopy(0,0,s^.Xres,s^.Yres);
       s^.pen:=oldpen;
       if b=nil
        then ReportErr(_(erLowMem))
        else picWrite(b,dirExp+PathSlice(name,psName));
       KillObj(b);
       end;
     2:picWrite(s^.map,dirExp+PathSlice(name,psName));
     3:Name2Textfile(Data(now_page)^.name^,dirExp+PathSlice(name,psName)+'.TXT',false{no vyhen});
     4:Name2Textfile(Data(now_page)^.name^,dirExp+PathSlice(name,psName)+'.000',true{vyhen});
     5:Name2Htmlfile(Data(now_page)^.name^,dirExp+PathSlice(name,psName)+'.HTM');
     6:ExportSubtree2Html(Data(now_page)^.name^,dirExp,false{single+support});
     7:ExportSubtree2Html(Data(now_page)^.name^,dirExp,true{subtree+support});
     8:Rip(now_page,dirExp);
     9:ExportSubtree4Mach(Data(now_page)^.name^,dirExp,false{single+support});
    10:ExportSubtree4Mach(Data(now_page)^.name^,dirExp,true{subtree+support});
     end;
  end;


  procedure Menu_Music;

    function DkodIsMusic(Dkod:TDkod):boolean;
    begin
     DkodIsMusic:=
        ( ((DkodIs(Dkod) and isModule)>0) )
     or ( ((DkodIs(Dkod) and isSample)>0) and (Data(Dkod)^.len>128*1024) );
    end;

    function Menu_ModulyVProjektu(proj:TPrjs):boolean;
    var   c               :TMenuCollection;
          Dkod            :TDkod;
    begin
     Menu_ModulyVProjektu:=false;
     c.Init(true);
     {nahaze moduly do kolekce}
     Dkod:=prj[proj].FirstDkod;
     while Dkod<>0 do begin
       if DkodIsMusic(Dkod) then c.InsertStr(Data(Dkod)^.name^,Dkod);
       Dkod:=prj[proj].NextDkod;
       end;
     {osetri pripad ze nejsou zadny moduly}
     if c.count=0 then
       dlgStr(_i(_musNemaVlastMody,DM[prj[proj].prjDMmain]^.projekt))
     else begin
       {pusti dialog}
       Dkod:=dlgMenuKod(DM[prj[proj].prjDMmain]^.projekt,@c,SS.musPlayingDkod);
       {spusti ten modul}
       if Dkod<>0 then begin
         SS.musPlay(+musfade,false,Dkod);
         SS.musPlayingUserOne:=true;
         Menu_ModulyVProjektu:=true;
         end;
       end;
     c.Done;
    end;

    function Menu_KdyStridat:boolean;
    var   i               :integer;
          c               :TMenuCollection;
          max             :longint;
    begin
     Menu_KdyStridat:=false;
     c.Init(false);
     c.InsertStr(_(_musNikdy),-2);
     c.InsertStr(_(_musPoDohrani),-1);
     c.InsertStr(_(_musPo1Minute),1);
     c.InsertStr(_i(_musPoNMinutach,'2'),2);
     c.InsertStr(_i(_musPoNMinutach,'3'),3);
     c.InsertStr(_i(_musPoNMinutach,'5'),5);
     c.InsertStr(_i(_musPoNMinutach,'7'),7);
     c.InsertStr(_i(_musPoNMinutach,'10'),10);
     c.InsertStr(_i(_musPoNMinutach,'15'),15);
     i:=dlgMenuKod(_(_musKdyStridat),@c,SS.musGetSwitching);
     if i<>0 then begin
       SS.musSetSwitching(i);
       Menu_KdyStridat:=true;
       end;
    end;

    {vyber 1 modulu z projektu}
    function Browsi_Projekty:boolean;
    var i,p:integer;
        c:TMenuCollection;
    begin
     c.Init(false);
     for i:=1 to projects do
       c.InsertStr(DM[prj[i].prjDMmain]^.projekt,i);
     p:=PDMBitmap(s^.map)^.project;
     repeat
       p:=dlgMenuKod(_(_musKdeHledatMody),@c,p);
     until (p=0) or Menu_ModulyVProjektu(p);
     c.Done;
     Browsi_Projekty:=p<>0;
    end;

    {vyber 1 modulu z disku}
    function Browsi_Modul:boolean;
    var   dirOld          :DirStr;
          st              :PathStr;
    begin
     Browsi_Modul:=false;
     dirOld:=dirCur;
     dirChange(dirBrowseMods);
     st:=dlgFile(dlgDoLoadDirs+dlgUpdateDir+dlgNoCommon,_(_musJakyModPustit),mods,'');
     if st<>'' then dirBrowseMods:=dirCur;
     dirChange(dirOld);
     if st<>'' then begin
       someDkod:=GetDkod(st,false);
       if someDkod>0 then begin
         SS.musPlay(+musfade,false,someDkod);
         SS.musPlayingUserOne:=true;
         Browsi_Modul:=true;
         end
       else begin
         dlgStr(_i(_musModulNeexistuje,st));
         end;
       end;
    end;

    {vyber 1 adresare z disku}
    function Browsi_ModulDir:boolean;
    var   dirOld          :DirStr;
          st              :PathStr;
    begin
     Browsi_ModulDir:=false;
     dirOld:=dirCur;
     dirChange(dirBrowseMods);
     st:=dlgPathBrowser(dlgDoLoadDirs+dlgUpdateDir+dlgNoCommon,_(_musJakyDirPustit),'*.*','');
     if st<>'' then dirBrowseMods:=dirCur;
     dirChange(dirOld);
     if st<>'' then begin
       SS.musLoadPlaylistFromDir(st);
       Browsi_ModulDir:=true;
       end;
    end;

  var   i,p     :integer;
        c       :TMenuCollection;
        b1,b2   :boolean;
  const mus_1zprojektu=-1;
        mus_1zdisku   =-2;
        mus_dirzdisku =-3;
        mus_abec_nahod=-4;
        mus_kdystridat=-5;
        mus_predchozi =-6;
        mus_dalsi     =-7;
        mus_nahodny   =-8;
        mus_mute      =-9;
        mus_lonstop   =-10;
        mus_frommag   =-11;
        mus_std:integer=0;
  label 1;
  begin
   with s^ do
    with PDMBitmap(map)^ do begin
     1:
     c.Init(false);
     {nahaze volby do kolekce}
       c.InsertStr(_(_musModulZProjektu),mus_1zprojektu);
       c.InsertStr(_(_musModulZDisku),mus_1zdisku);
       c.InsertStr(_(_musAdresarZDisku),mus_dirzdisku);

     if SS.musRandom then
       c.InsertStr(_(_musHratPodleAbecedy),mus_abec_nahod)
     else
       c.InsertStr(_(_musHratNahodne),mus_abec_nahod);
       c.InsertStr(_(_musKdyStridat),mus_kdystridat);

       c.InsertStr(_(_musHratPredchozi),mus_predchozi);
       c.InsertStr(_(_musHratDalsi),mus_dalsi);
       c.InsertStr(_(_musHratNahodny),mus_nahodny);

     if not SS.musMute then
       c.InsertStr(_(_musMute),mus_mute)
     else
     if (SS.musMutedDkod<>0) and (SS.musPlayingUserOne or SS.musPlaylistDir) then
       c.InsertStr(_i(_musZpetK,Data(SS.musMutedDkod)^.name^),mus_mute);

     if SS.musMute or SS.musPlayingUserOne or SS.musPlaylistDir then
       c.InsertStr(_i(_musZpetKMuziceZ,DM[prj[project].prjDMmain]^.projekt),mus_frommag);
     if SS.lonPlaying then
       c.InsertStr(_i(_musStopUkazku,Data(SS.lonPlayingDkod)^.name^),mus_lonstop);
     {pusti dialogy}
     if mus_std=0 then p:=project else p:=mus_std;
     p:=dlgMenuKod(_(_menuPomHudba),@c,p);
     if p<>0 then mus_std:=p;
     case p of
       mus_1zprojektu:begin SS.musMute:=false;SS.musMute:=not Browsi_Projekty;if not SS.musMute then SS.lonStop;end;
       mus_1zdisku   :begin SS.musMute:=false;SS.musMute:=not Browsi_Modul   ;if not SS.musMute then SS.lonStop;end;
       mus_dirzdisku :begin SS.musMute:=false;SS.musMute:=not Browsi_ModulDir;if not SS.musMute then SS.lonStop;end;
       mus_abec_nahod:SS.musRandom:=not SS.musRandom;
       mus_kdystridat:Menu_KdyStridat;
       mus_predchozi :begin SS.musMute:=false;SS.lonStop;SS.musPlayPrev;end;
       mus_dalsi     :begin SS.musMute:=false;SS.lonStop;SS.musPlayNext;end;
       mus_nahodny   :begin SS.musMute:=false;SS.lonStop;SS.musPlayRandom(0);end;
       mus_mute      :if not SS.musMute then begin
                        SS.musMutedDkod:=SS.musPlayingDkod;
                        SS.musStop(16,false);
                        SS.musMute:=true;
                        end
                      else begin
                        SS.musMute:=false;
                        b1:=SS.musPlayingUserOne;
                        b2:=SS.musPlaylistDir;
                        SS.musPlay(0,false,SS.musMutedDkod);
                        SS.musPlayingUserOne:=b1;
                        SS.musPlaylistDir:=b2;
                        end;
       mus_lonstop   :begin
                      SS.lonStop;
                      {dlgStr(SS.getDebugInfo);}
                      end;
       mus_frommag   :begin
                      SS.musMute:=false;
                      SS.musPlayingUserOne:=false;
                      SS.lonStop;
                      SS.musLoadPlaylistFromPage(PDMBitmap(map));
                      end;
       0             :;
       end;
     c.Done;
     if p<>0 then goto 1;
     end;
  end;


  procedure Menu_Help;
  const msir=36;
  var   i:integer;
        kod:longint;
        c:TMenuCollection;
  begin
   with s^ do
    with PDMBitmap(map)^ do begin
     c.Init(false);
     c.InsertStr(LeftRight(_(_menuPomHlp)      , '(F1)',msir),kF1);
     c.InsertStr(LeftRight(_(_menuPomSetup)    , '(F2)',msir),kF2);
     c.InsertStr(LeftRight(_(_menuPomAutori)   , '(F3)',msir),kF3);
     c.InsertStr(LeftRight(_(_menuPomProj)     , '(F4)',msir),kF4);
     c.InsertStr(LeftRight(_(_menuPomRes)      , '(F5)',msir),kF5);
     c.InsertStr(LeftRight(_(_menuPomLang)     , '(F6)',msir),kF6);
     c.InsertStr(LeftRight(_(_menuPomExport)   , '(F7)',msir),kF7);
     if SS.rainID<>'' then
      c.InsertStr(LeftRight(_(_menuPomHudba)    , '(F8)',msir),kF8);
     c.InsertStr(LeftRight(_(_menuPomSuddDeath),'(F12)',msir),kF12);
     if MapModel<>model_text then
      c.InsertStr(LeftRight(_(_menuPomMainMenu) ,'(Esc)',msir),kEsc);
     if ((fileIs(GetPageName) and (isLoadable+isGraphics))<>isLoadable+isGraphics)
      and (mapModel<>model_text) then
      c.InsertStr(LeftRight(_(_menuPomPalEdit)  ,'('+_(_mezernik)+')',msir),kSpace);
     dlgHotkeys:=true;
     kod:=dlgMenuKod('Deus ex Machina '+verzestr,@c,dlgHelpPresel);
     dlgHotkeys:=false;
     c.Done;
     if kod<>0 then begin
       dlgHelpPresel:=kod;
       PushEvent(MakeEvent(kod,#0,#0));
       end;
     end;
  end;

const stri_boolean:array[false..true] of string[3]=('no','yez');
var   thum:PBitmap;
      titleexist:boolean;
      f:PFont;
label label_newpage,
      label_jsemtady,
      label_reopenmenu,
      label_loop,
      label_setres,
      label_setproj,
      label_death,
      label_LeftPressed,
      label_unknown,
      L00,L02;
Begin

  Show_Init;

label_newpage:


  {priprav stranku [name|now_page,jumps,now_project]}
  {vis ze jdes dopredu, stranka po gobacku se generuje jinde}
  {musi sleepnout starou bitmapu jeste pred generovanim nove}
  {kdyz neco nejde, zakric a zustan na strance na ktery jses}
  {kdyzs teprva zacal a na zadny strance nejsi, skonci}

  {dopln name|now_page}
  if now_page=0
   then now_page:=GetDkod(DecodeLink(name,true),false)
   else name:=Data(now_page)^.name^;

  {pokud s neni nil, vyniluje ho}
  if s<>nil then begin
    {$ifdef beta}
    if s^.map=nil then erBetaMsg('show s.map=nil');
    {$endif}
    with PDMBitmap(s^.map)^ do begin
      {zahraje opousteci sampl minule stranky}
      SS.smpPlay(Dkods_samplyes.Random);
      {pokud jeste bezi, zastavi minulou stranku}
      s^.SetActivity(syncAllOff);
      {zapamatuje si minuly muziky aby je moh zdedit}
      zded_lm_list:=lm_list;
      zded_lm_count:=lm_count;
      {a ulozi minulou stranku}
      PushPage(s);
      end;
    end;

  {zkusi pred strankou playnout animacku}
  PlayAni(GetDkod(fileFind(PathSlice(name,psPath+psName),isPlayable+isGraphics),false),false);

  {vsechno z animacek krome prvnich nekolika snimku zahodi}
  caFreeAllBelow(-30);

  {kdyz stranku nema (chybi jazykova mutace apod), hlasi to}
  if (now_page=0) and not DecodeLinkHadDialog then ReportErr(_(_erChybiSoub)+' '+name+'.');

  {generuje novou stranku}
  {---pasmo ve kterem pouziva B---}
  b:=GetDMBitmap(now_page,now_parent,dmtfForcePacked*ord((intree=0) and (flags and sfForcePacked>0)){flags},nil{no sleepbuf});
  if b=nil then begin
    {nejde prvni stranka->konec programu}
    if intree=0 then begin
      Show_Done;
      if (flags and sfEditmod)>0 then exit else Halt(_erWritten);
      end;
    {nejde dalsi stranka->popni minulou}
    SS.smpPlay(GetDkod(nam_ne,true));
    name:=PopPage(s);
    end
  else
  with b^ do begin
    {ulozi thumb projektu}
    with DMfile.DM[prj[now_project].prjDMmain]^ do
     if (mapModel<>model_text) and (name=title) {*povolit: and not readonly}
     and (fileFind(dirIns+'thumbs\'+popisek,isGraphics+isLoadable)='')
     and (fileFind(dirExe+'thumbs\'+popisek,isGraphics+isLoadable)='')
     then begin
       thum:=ResizeBoxCopy(1,0,0,MinI(sizeX,doporucXres),MinI(sizeY,doporucYres),133,100);
       if thum<>nil then begin
         {do dirExe\thumbs uloz jen pokud uz existuje a dirIns\thumbs ne}
         if dirExists(dirExe+'thumbs\') and not dirExists(dirIns+'thumbs\') then
           picWrite(thum,dirExe+'thumbs\'+popisek)
         else
         {jinak uloz do dirIns\thumbs}
           if dirMake(dirIns+'thumbs\')
            then picWrite(thum,dirIns+'thumbs\'+popisek);
         thum^.Free;
         end;
       end;
    {project:=now_project;}{*snad nevadi ze jsem to zaremoval}
    {zdedi jumps}
    jumppagesback:=zded_jumps;
    {kdyz stranka nema muziky, zdedi predchozi}
    if lm_Unspecified then
     for i:=1 to zded_lm_count do
      lm_AddDkod(zded_lm_list[i]);
    {provizorne poopravi timeout}
    {cilem je posuvny slideshow mezi strankama a nehybny pod linkem}
    {pod linkem je ve skutecnosti nehybnej jen prvni pic, ale aspon to}
    if ((fileIs(name) and isHypertext)=0) and (zded_jumps=0) then titletimeoutcounter:=0;
    {nastavi mod}
    SetModeFor(b,staticMode.ChangeAllowed);
    end;
  {-------------------------------}

label_jsemtady:
  with s^ do begin

  mouseSetPos(mouse.X,mouse.Y);
  if mapModel=model_text then vga_HideCursor;

  if not gobacky then begin
    if mapModel in models_8 then BlackHwPal;
    MapRedraw;
    ListaRedraw;
    if not SS.musPlaylistDir then begin
      SS.musLoadFirstsPlaylistFromPage(PDMBitmap(map));
      SS.musLoadPlaylistFromPage(PDMBitmap(map));
      end;
    Fade(+word(fadein)*screenfreq div 70);
    SS.smpPlay(c^.Dkods_samplin1.Random);
    end
  else begin
    if not SS.musPlaylistDir then SS.musLoadPlaylistFromPage(PDMBitmap(map));
    SS.smpPlay(c^.Dkods_samplin2.Random);
    gobacky:=false;
    end;


label_reopenmenu:

  SetActivity(syncAllOn);
  if ((flags and sfEditmod)=0) and (intree=0) and (autorun_path='')
   then ProcOpenM;

label_loop:


  repeat
   Sync;
  until GetEvent(event,virtPres);
  KillObj(sv);

  {skoro jakejkoliv event zrusi automaticky odentrovani stranky}
  if not (code(event) in mcHolds+mcReleases) then
   c^.titletimeoutcounter:=0;

  CASE code(event) OF

              {$ifdef beta}
              kTab:nam_goon:=dlgfile(0,'vyber test-sampla','*.wav;*.iff',nam_goon);
              {$endif}
              kf:begin
                 screenfreq:=valu(dlgLine(0,'forced screen frequency',stri(screenfreq)));
                 retracelen:=65535;
                 end;

              kk5:{ignore numpad 5};

              kM,{muzak}
              kS,{system}
              kB,{buffer}
              kH,{hw scrol}
              kT,{timing}
              kV,{vram}
              kI,{internal}
              kD {dirs}
                  :if not paleting then begin
                    if menuing then ProcEndM(true);
                    st200:=GetDebugInfo(pos(chr(code(event)),chr(kV)+chr(kT)+chr(kH)+chr(kB)+chr(kS)));
                    case code(event) of
                      kS:st200:=st200+
                       #13#10'curdir='+dirCur+
                       #13#10'exedir='+dirExe+
                       #13#10'homedir='+dirIni;
                      kM:st200:=SS.GetDebugInfo;
                      kB:st200:=st200+#13#10+
                       #13#10'slideshow='+stri(rychlostslideshow)+'sec'+
                       #13#10'screensaver='+stri(screensaver)+'min';
                      kI:st200:='INTERNAL INFOORMA'#13#10+'   (INFERNAL)'#13#10'  (BEAN RULEZ)'+
                       #13#10'projects='+stri(projects)+
                       #13#10'DMs='+stri(DMs)+
                       #13#10'link='+name+
                       #13#10'page='+Data(now_page)^.name^+
                       #13#10'mHandler='+stri_boolean[mouseHandler]+
                       #13#10'kHandler='+stri_boolean[kHandler]+
                       #13#10'kZ='+stri(byte(kPressed[kZ]))+
                       #13#10'pushes='+stri(pushes);
                      kD:st200:=DirsList;
                      end;
                    dlgMsg(Str2Pc(st200));
                   end;
                kG:ReportAtoms(cx(0,0,0));
                kO:ReportAtoms(cx(c^.project,0,0));
                kP:ReportAtoms(cx(c^.project,c^.Dkod,0));
{:}
                kR:case Str2Char(dlgLine(0,'A heslo je...','')) of
                   '.':begin
                    st200:=dlgLine(0,'Maska...','*');
                    if st200<>'' then begin
                      maska:=UpCased(st200);
                      st200:=dlgLine(0,'Jen soubory men®° neë... bajtñ.','10000000');
                      if st200<>'' then begin
                        smallerthan:=Valu(st200);
                        st200:=dlgLine(0,'Jen soubory velkÇ aspo§... bajtñ.','0');
                        if st200<>'' then begin
                          biggerthan:=Valu(st200);
                          for k:=1 to prj[c^.project].prjDMs do begin
                           j:=prj[c^.project].prjDM[k];
                           st200:=inidir+PathSlice(dm[j]^.fullfilename,psName);
                           MkDir(st200);
                           for i:=1 to dm[j]^.fajlu do
                            if hkNalezi(PathSlice(Data(MakeLong(j,i))^.name^,psAll+psForcePoint),maska)
                             and (Data(MakeLong(j,i))^.len<smallerthan)
                              and (Data(MakeLong(j,i))^.len>=biggerthan)
                               then if not rip(MakeLong(j,i),st200+'\')
                                then begin
                                  ReportErr(_(_msgRippingNedokoncen));
                                  goto label_loop;
                                  end;
                           end;
                          end;
                        end;
                      end;
                    end;
                   end;
              kEsc:begin
                   if menuing then ProcEndM(true) else
                   if paleting2 then ProcAbortP2 else
                   if paleting then ProcAbortP1 else
                   if (flags and sfEditmod)>0 then goto ending else ProcOpenM;
                   end;
            kSpace:begin
                   if menuing then ProcEndM(true);
                   if not paleting then ProcOpenP1 else
                   if paleting2 then ProcEndP2 else ProcOpenP2;
                   end;
           kkEnter,
            kEnter:if paleting then begin
                     if paleting2 then ProcEndP2 else ProcEndP1;
                     end
                   else
                     goto label_LeftPressed{unknown};
             kZ,kX:if not paleting2 then
                    if (code(event)=kX) and (char(event)=#0) then goto label_death
                     else goto label_unknown;{aby nerval pri nastavovani palety}

            k1..k0:{neni treba, uz to dela sync
                   SS.musVolume:=vol[code(event)]};
            kkPlus,
           kkMinus:SetAmp;

               kF1:if not paleting then begin
                    help:
                    if menuing then ProcEndM(true);
                    Menu_Help;
                    end;
               kF2:if not paleting then begin
                    setup:
                    if menuing then ProcEndM(true);
                    {SS.smpPlay(GetDkod(nam_setup,true));}
                    name       :='!setup';
                    now_parent :=now_page;
                    now_page   :=0;
                    now_project:=GetSystemPrj;{aby mely chkboxy vzdycky stejnej kontext pro ukladani promennejch}
                    zded_jumps :=0;
                    zded_mouse(1);
                    goto label_newpage;
                    end;
               kF3:if not paleting then begin
                    if menuing then ProcEndM(true);
                    newpage:=dlgSelectPageByAuthor(now_page);
                    if newpage<>0 then begin
                      name       :='';
                      now_parent :=now_page;
                      now_page   :=newpage;
                      zded_jumps :=0;
                      zded_mouse(1);
                      goto label_newpage;
                      end;
                    end;{}
               kF4:if not paleting then begin
                    if menuing then ProcEndM(true);
                    newproj:=dlgSelectProject;
                    if newproj<>0 then goto label_setproj;
                    end;
               kF5:if not paleting then begin
                    if menuing then ProcEndM(true);
                    newmode:=dlgSelectResolution(MapModel);
                    if newmode<>-1 then goto label_setres;
                    end;
               kF6:dlgSelectLanguage;
               kF7:if not paleting then begin
                    if menuing then ProcEndM(true);
                    Menu_Export;
                    end;
               kF8:if SS.rainID='' then ReportErr(_(_musNoRain)) else Menu_Music;
              kF11:SS.smpStop;
              kF12:begin
                   label_death:
                   Show_Done;
                   lastMsg:=mach_msg;
                   Halt(erOk);
                   end;


   mcLeftHold,
   mcRightHold,
   mcCenterHold,
   mcLeftReleased,
   mcRightReleased,
   mcCenterReleased:;

   mcCenterPressed:BEGIN
                   if paleting then goto label_unknown;
                   someLong:=GetMs;
                   repeat s^.Sync until (s^.mouse.z=0) or (GetMs>someLong+250);
                   if s^.mouse.z<>0 then goto help else
                    if not menuing then ProcOpenM
                     else ProcEndM(true);
                   END;

    mcRightPressed:BEGIN
                   {---ABORT PAL---}
                   if paleting2 then ProcAbortP2 else
                   if paleting then ProcAbortP1 else

                   {---CLOSE MENU BUTTs---}
                   if menuing then ProcEndM(true) else

                   {---OPEN MENU BUTTs---}
                   if intree=0 then ProcOpenM else

                   {---MENU BACK---}
                   begin
                     c^.jumppagesback:=0;
                     gouback:
                     KillPage(minI(c^.jumppagesback,intree-1));{killne stranky pri multigoback, aspon jednu ale necha}
                     {$ifdef beta}
                     if s=nil then erBetaMsg('show goback s=nil');
                     {$endif}
                     SetActivity(syncAllOff);
                     SS.smpPlay(c^.Dkods_samplgbk.Random);
                     name:=PopPage(s);{popne novy s, pri tom killne stary s}
                     gobacky:=true;
                     goto label_jsemtady;
                     end;
                   END;

     mcLeftPressed:BEGIN
                   label_LeftPressed:
                   {-----ukonceni paletingu2-----}
                   if paleting2 then begin
                     ProcEndP2;
                     goto label_loop;
                     end;

                   px:=aFindPx(c^.project,c^.Dkod,virtPres);

                   {-----ukonceni paletingu-----}
                   if paleting and not paleting2 and (px=0) then begin
                     ProcEndP1;
                     goto label_loop;
                     end;

                   {-----main menu-----}
                   if menuing then begin

                     {---CLOSE MENU BUTTs---}
                     if px=0 then begin
                       ProcEndM(true);
                       goto label_loop;
                       end;

                     pxkod:=StrGetNum(atom.aGet(cx(c^.project,c^.Dkod,px),aScript));
                     ProcEndM(false);{vrati puvodni butts}
                     case pxkod of
                       kod_setup :begin
                                  {$ifndef rain}
                                  SS.smpPlay(GetDkod(nam_goon,true));
                                  RunShell(+fadeout,false,myMidasConfig);
                                  goto label_reopenmenu;
                                  {$else}
                                  goto setup;
                                  {$endif}
                                  end;
                       kod_help  :goto help;
                       kod_shell :begin
                                  SS.smpPlay(GetDkod(nam_goon,true));
                                  ExecCmd(+fadeout,true,Shell);
                                  end;
                       kod_quit  :begin
                                  SS.smpPlay(GetDkod(nam_goodbye,true));
                                  goto ending;
                                  end;
                       kod_mode..32767:begin
                                  newmode:=pxkod-kod_mode;
                                  label_setres:
                                  with c^ do
                                   with PResItem(ResList.At(newmode))^ do begin
                                    doporucModel:=amodel;
                                    doporucXres :=ax;
                                    doporucYres :=ay;
                                    end;
                                  SS.smpPlay(GetDkod(nam_fade,true));
                                  {startX:=;
                                  startY:=;}
                                  bb:=c;{PDMBitmap(s^.map);}
                                  s^.map:=nil;
                                  SetActivity(syncAllOff);
                                  zded_mouse(0);
                                  SetModeFor(bb,true);{setmode killne s, proto musi s^.map presunout do bb}
                                  goto label_jsemtady;
                                  end;
                       else       begin
                                  newproj:=pxkod;
                                  label_setproj:

                                  {hlasi pokud nema projekt svuj title}
                                  asm mov al,now_project;push ax;end;
                                  now_project:=newproj;
                                  titleexist:=fileExists(title);
                                  asm pop ax;mov now_project,al;end;
                                  if not IsSystemPrj(newproj) and not titleexist then begin
                                    dlgStr(_(_msgChybiTitle)+#13#10+_(_msgVytvorTitle));
                                    goto label_loop;
                                    end;

                                  {warnuje pokud jde o oldies}
                                  if (oldiesWarnings>0) and (DMfile.DM[prj[newproj].prjDMmain]^.verzeDM<100) then begin
                                    dlgStr(_(_msgOldiesWarning1)+#13#10+_(_msgOldiesWarning2));
                                    dec(oldiesWarnings);
                                    end;

                                  SS.smpPlay(GetDkod(nam_dvere,true));
                                  SS.lonStop;
                                  if IsSystemPrj(newproj)
                                   then name :='!'+menu
                                   else name :=title;
                                  now_parent :=now_page;
                                  now_page   :=0;
                                  now_project:=newproj;
                                  zded_jumps :=0;
                                  zded_mouse(1);
                                  goto label_newpage;
                                  end;
                       end;
                     goto label_loop;
                     end;

                   {-----link-----}
                   if px>0 then begin
                     someDkod:=aClickPx(c^.project,c^.Dkod,px,s,c);
                     if someDkod>0 then begin
                       name       :='';
                       now_parent :=now_page;
                       now_page   :=someDkod;
                       zded_jumps :=0;
                       zded_mouse(2);
                       goto label_newpage;
                       end;
                     goto label_loop;
                     end;


                   if not menuing and not paleting then begin

                     {--obstara slajdovy navaznosti--}
                     st200:=GetNextSlidePic;
                     if st200<>'' then begin
                       {zacina ci pokracuje ve slajdu}
                       name       :=st200;
                       now_page   :=0;
                       zded_jumps :=c^.jumppagesback+1;
                       zded_mouse(1);
                       goto label_newpage;
                       end;

                     {do st200 da jmeno posledni textpage}
                     {vraci se zpatky dokud na textpage nenarazi}
                     st200:=name;
                     i:=intree;
                     while (i>0) and ((fileIs(st200) and isHypertext)=0) do begin
                       st200:=data(PSleeprec(@tree[i]^.mapsleep)^._Dkod)^.name^;
                       dec(i);
                       end;
                     {kdyz prolejzal zpatky slideshow nebo vubec nebyl
                       na obrazku, at postoupi v serii na dalsi stranku}
                     {kdyz se vratil z linku, at zustane v serii kde je}
                     if (i=intree) or
                        (copy(PathSlice(st200,psName),1,6)=copy(PathSlice(name,psName),1,length(PathSlice(name,psName))-2))
                        then begin

                       {--obstara textpagovy navaznosti--}
                       {skok z bleble_i.ext na bleble_i+1.ext}
                       inc(st200[length(PathSlice(st200,psPath+psName))]);
                       if GetDkod(st200,false)>0 then begin
                         name       :=st200;
                         now_parent :=now_page;
                         now_page   :=0;
                         zded_jumps :=c^.jumppagesback+1;
                         zded_mouse(1);
                         goto label_newpage;
                         end;
                     end;
                     {skok z title na menu}
                     if PathSlice(name,psFile)=title then begin
                       if GetDkod(menu,false)>0 then begin
                         name       :=menu;
                         now_parent :=now_page;
                         now_page   :=0;
                         zded_jumps :=0;
                         zded_mouse(1);
                         goto label_newpage;
                         end;
                       end;
                     {skok z bleble_last na menu}
                     if c^.jumppagesback>0 then goto gouback;
                     {goback pri 1strankovym clanku}
                     if (intree>0) and (aPxs(c^.project,c^.Dkod)=0)
                      then goto gouback;
                     end;

                   {---OPEN MENU BUTTs---}
                   if not menuing and (intree=0) then ProcOpenM;

                   END;
           ELSE label_unknown:begin
                   SS.smpPlay(GetDkod(nam_unknown,true));
                   {ReportErr('code='+stri(code(event))+' char='+stri(byte(char(event)))+
                    ' extchar='+stri(byte(extchar(event))));{}
                   end;
           END;

  goto label_loop;


  ending:
  SetActivity(syncAllOff);
  SS.musStop(+fadeout*2,true);
  Show_Done;
  end;{end of with}
End;


{∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞INIT/DONE∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞}

const unita='supp';
var result:TError;

procedure UserInit;
 begin
  SS.Init;
  ShowResolutions :=false;
  staticMode.SetDynamic;
  Shell           :='';
  ScreenSaver     :=5;
  chovaniMysi     :=1;
  fadein          :=14;
  fadeout         :=8;
  dirExp          :=dirCur+'export\';
  dirBrowseMods   :='';
  sipkagif        :=nil;
  ptrPlayFile     :=PlayFile;
  infobar         :=false;
  buttpics        :=true;
  oldiesWarnings  :=3;
  maxFnHeight     :=0;
  New(backup_pal1);
  New(backup_pal2);
 end;

procedure UserDone;
 begin
  Dispose(backup_pal2);
  Dispose(backup_pal1);
  SS.Done;
  KillObj(sipkagif);
 end;

{$i initdone.inc}
{$ifdef autoinit}
BEGIN
 erCheck(Init);
{$endif}
END.