UNIT  Writer2; {$i define.inc}

{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}
                             INTERFACE
{‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹}

USES  Chyby,Memo,
      Objects,Dos,Strings,
      Stringy,Sys,Texty,Fonty,Writer1,Fajly,DMFile,DMText,
      DMAtoms,
      {*}Veng,Vengine2,Scrol,
      Vga,Loadery,FlcPlay;

const debugW:boolean=false;

{
---------------------------------------------------------------------------
                           Uvod k Writeru 2
---------------------------------------------------------------------------

Toto je zakladni podpora pro psani usporadanych vicefontovych textu.
Usporadani textu na vystupu se ridi temito pravidly:

 - kratky radek se centruje
 - dlouhy radek se rozdeli do nekolika ke krajum zarovnanych radku, prvni
   je odsazen, tj. klasicky odstavec
 - radek zacinajici Tabem zacina hned od kraje (neodsazen, necentrovan)
 - radek zacinajici dvema Taby je odsazen jako novy odstavec (necentrovan)
 - po symbolu chgINIT nasleduje znak chgFNT..chgFNTz pro nastaveni fontu
   z lokalniho seznamu fontu nebo znak chgCOL..chgCOLz pro nastaveni barvy
   fontu z lokalniho seznamu barev

Jenom kvuli kompatibilite se starym Parenistem, nepouzivat:
 - Tab uvnitr textu odsadi kurzor doprava na nejblizsi ze znacek, ktere deli
   sloupec na oldTabs stejne velkych kusu (defaultne 5)
 - vyskytne-li se Tab uvnitr textu, radek se nezarovnava, jede az do CR/LF!

}


{i dmtext.inc}

type  Tlfpush  = string[2];

      PWriter2 = ^TWriter2;
      TWriter2 = object(TWriter1)
                     vyhExport       :boolean;
                     {slpXXXX - Sloupec}
                     slpMid          :integer;
                     slpOdsazX       :integer;
                     slpOdsazY       :integer;
                     {otXXXX - Out Text}
                     otY             :word;
                     constructor     Init(editmod:boolean;tabu:byte);
                     procedure       SetFormat(format:byte);
                     procedure       SetZarovnavat(zarovnavat:byte);
                     function        lfInit(fonts,colors:string):boolean;
                     procedure       lfReset;
                     function        lfDetectXzoom(fonts:string):real;
                     function        lfDetectYzoom(fonts:string):real;
                     procedure       WriteLong(newwriter:PWriter2;zoomX,zoomY:real;ender:specstring);
                    private
                     edit            :boolean;{psat v uprave pro editaci?}
                     {lfXXXX - Local Font}
                     lfInited        :boolean;
                     lfFonts         :string;
                     lfColors        :array[0..chgCOLs-1] of longint;
                     lfFont          :char;
                     lfColor         :char;
                     {stXXXX - Scan Text}
                     stSrc2          :Pchar;
                     oldTabs         :byte;
                     {otXXXX - Out Text}
                     otFormat        :byte;{0=primitiv/1=odsazovani+centrovani_nadpisu}
                     otZarovnavat    :byte;{0=vlevo/1=roztah/2=centr/3=vpravo}
                     otOverflReported:boolean;
                     procedure       lfSet(c:char);
                     function        lfPush:Tlfpush;
                     procedure       lfPop(pop:Tlfpush);
                     procedure       MarkEol;
                     function        ScanShort(posun:boolean):integer;
                     function        WriteShort(txtsir:word;txtMaxUnder:integer):boolean;

                    {button reporter}
                    public
                     reportOn        :boolean;
                     procedure       InstallPx(rect:TRect;px:pchar);
                     procedure       PrintPic(name:PathStr;dx0,dy0,dsir,dvys:integer;
                                       link2:pchar;castshad,shadebor,whitebor:integer);
                     procedure       PrintBox(x0,y0,sir,vys:integer;col:longint);
                    private
                     prevOtX         :word;
                     procedure       TryReportLink(var otX:word);
                     procedure       ReportLink(ax,ay,bx,by:integer;script:pchar);

                    {playlist}
                    public
                     playlist        :PPlaylist;
                    private
                     procedure       ReportAnim(r:TRect;akod:TDkod;zoom:word;transp:boolean);

                    {overflows}
                    public
                     overflows       :word;

                    {$ifdef edit}
                    {solidni bloky textu}
                    public
                     under           :word;
                     undery1         :integer;
                     undery2         :integer;
                     underxmid       :integer;
                     underxsir       :integer;
                     underrects      :string;
                    {$endif}
                    end;



{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}
                          IMPLEMENTATION
{‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹}


Uses DMBitmap,Rain2;

const MARKER       =CR;        {znacka pripominajici ShortWriteru ze ShortScanner uz dal nesel}


{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ LOKALNI SEZNAM FONTU ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}

Constructor TWriter2.Init(editmod:boolean;tabu:byte);
begin
 inherited Init;
 SetSpecChars(CR+EOP+chgINIT);
 {lfInit('','1,2,3,4,5');}
 lfInited     :=false;
 edit         :=editmod;
 if edit then globshiftY:=1;
 oldTabs      :=tabu;
 SetFormat(1);
 SetZarovnavat(1{roztah});
end;

Procedure TWriter2.SetFormat(format:byte);
begin
 otFormat:=format;
end;

Procedure TWriter2.SetZarovnavat(zarovnavat:byte);
begin
 otZarovnavat:=zarovnavat;
end;

Function TWriter2.lfInit(fonts,colors:string):boolean;
var   i:word;
begin
 {poznamena si seznam lokalnich fontu (soubory oddelene strednikem)}
 lfFonts   :=fonts;
 {overi existenci fontu}
 while fonts<>'' do if GetDkod(CutString(fonts,';'),false)=0 then begin lfInit:=false;break;end;
 lfInit    :=true;
 {poznamena si seznam barev}
 for i:=0 to chgCOLs-1 do begin
   if (i=0) or (colors<>'')
    then lfColors[i]:=CutNum(colors)
    else lfColors[i]:=lfColors[i-1] and $ffffff;
   if i>3 then inc(lfColors[i],(i-3)*$1000000);
   end;
 {zneskodni aktualni hodnoty aby si LF_Set nemyslel, ze nedochazi ke zmene}
 lfFont    :=#0;
 lfColor   :=#0;
 {nastavi zakladni hodnoty}
 lfInited:=true;
 lfReset;
end;

Procedure TWriter2.lfReset;
begin
 {nastavi zakladni hodnoty}
 lfSet(chgFNT);
 lfSet(chgCOL);
end;

Procedure TWriter2.lfSet(c:char);
var   temp:string;
begin
 {$ifdef beta}
 if not lfInited then ReportErr('Not lfInited') else
 {$endif}
 case c of chgFNT..chgFNTz:if lfFont<>c{nastavuje jen kdyz se meni} then
                    begin
                     {vezme ze seznamu lokalnich fontu c-ty a loadne ho}
                     if not SetFont(stringy.GetString(lfFonts,';',ord(c)-ord(chgFNT)+1))
                      then SetFont(fnDefault);
                     {v editmodu zmeni barvu pozadi}
                     {$ifdef edit}
                     if edit then SetBackgr(ord(c)-ord(chgFNT));
                     {$endif}
                     {zapamatuje si nastaveni}
                     lfFont:=c;
                    end;
           chgCOL..chgCOLz:if lfColor<>c{nastavuje jen kdyz se meni} then
                    begin
                     {nastavi jednu ze ctyr barev ci nekolika dalsich mixu}
                     SetColor(lfColors[ord(c)-ord(chgCOL)]);
                     {zapamatuje si nastaveni}
                     lfColor:=c;
                    end;
           end;
end;

Function TWriter2.lfPush:Tlfpush;
begin
 lfPush:=lfFont+lfColor;
end;

Procedure TWriter2.lfPop(pop:Tlfpush);
begin
 lfSet(pop[1]);
 lfSet(pop[2]);
end;

{---------------------------------------------------------------------------
 Odhadne Xzoom pro editor.
 Ten uz si ho dale serizuje sam, jde jen o pocatecni hodnotu.
 ---------------------------------------------------------------------------}
Function TWriter2.lfDetectXzoom(fonts:string):real;
var st:string;
    r,s:word;
    i:word;
begin
 if not lfInited then lfInit(fonts,'');
 r:=maxword;
 st:=lfFonts;
 i:=0;
 while cutName(st)<>'' do begin
   lfSet(chr(ord(chgFNT)+i));
   s:=GetPcLen('Ahojky...');
   if s<r then r:=s;
   inc(i);
   end;
 lfDetectXzoom:=9/MaxW(r,9);
end;

{---------------------------------------------------------------------------
 Odhadne Yzoom pro editor.
 Ten uz ho nemeni.
 ---------------------------------------------------------------------------}
Function TWriter2.lfDetectYzoom(fonts:string):real;
var h:word;
begin
 if not lfInited then lfInit(fonts,'');
 lfSet(chgFNT);
 h:=GetFontHeight;
 if h=0
  then lfDetectYzoom:=1
  else lfDetectYzoom:=1/h;
end;

{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ BUTTONY ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}

Procedure TWriter2.TryReportLink(var otX:word);
var   pc:pchar;
      podnulou:char;

  procedure Export2Vyhen;
  var vyhStr:string[3];
      vyhPos:TText1;
  begin
   if vyhExport then begin
     vyhStr:='';
     {zjisti jestli pristi chgXXX neni link}
     vyhPos.Init(stSrc+1);
     vyhPos.chGoto(chgINIT,+1);
     if vyhPos.GetChar=chgLINK then vyhStr:='~' else
       {kdyz neni, nastavi aspon barvu}
       case (stSrc+1)^ of
         chr(ord(chgCOL)+0):vyhStr:='|07';
         chr(ord(chgCOL)+1):vyhStr:='|11';
         chr(ord(chgCOL)+2):vyhStr:='|14';
         chr(ord(chgCOL)+3):vyhStr:='|15';
         chr(ord(chgCOL)+4):vyhStr:='|14';
         end;
     vyhPos.Done;
     PrintStr(vyhStr,otX,otY);
     end;
  end;

begin
 if (stSrc+1)^=chgLINK then begin
   inc(stSrc,2);
   pc:=stSrc;
   while not (stSrc^ in [chgINIT,CR,EOP]) do inc(stSrc);
   podnulou:=stSrc^;
   stSrc^:=#0;{docasne zde vytvori konec pcharu pc}
   if vyhExport then PrintStr('~['+Pc2Str(pc)+']',otX,otY);
   ReportLink(prevOtX,otY-maxOver,otX,otY+maxUnder,pc);
   stSrc^:=podnulou;{konec pcharu opet odstrani}
   end;
 if vyhExport then Export2Vyhen;
 prevOtX:=otX;
end;

Procedure TWriter2.ReportLink(ax,ay,bx,by:integer;script:pchar);

 procedure PutBkgCol(x,y,sir,attr:word);
 var p:pbyte;
 begin
  p:=@otBitmap^.tab^[y]^[2*x+1];
  for sir:=sir downto 1 do begin
    p^:=(p^ and 15)+attr;
    inc(p,2);
    end;
 end;

var podtrhcol:longint;
    rect:TRect;
    linkok:boolean;
begin
 {sanity check kvuli oldies, nechceme kreslit podtrhlink mimo stranku}
 ax:=Bounded(ax,0,otBitmap^.sizeX-1);
 ay:=Bounded(ay,0,otBitmap^.sizeY-1);
 bx:=Bounded(bx,ax,otBitmap^.sizeX);
 by:=Bounded(by,ay,otBitmap^.sizeY);
{ if ax<0 then ax:=0;
 if ay<0 then ay:=0;
 if bx>=otBitmap^.sizeX then bx:=otBitmap^.sizeX;
 if by>=otBitmap^.sizeY then by:=otBitmap^.sizeY;
 {}

 if reportOn then
  if ax>bx then begin
    ReportLink(ax,ay-(by-ay),slpMid+slpSir div 2,ay,script);
    ReportLink(slpMid-slpSir div 2,ay,bx,by,script);
    end
  else begin
    with rect do begin
      a.x:=ax;
      a.y:=ay;
      b.x:=bx;
      b.y:=by;
      if (otBitmap^.MapModel=model_packed) and (HiByte(HiWord(GetOtColor))>0)
       then podtrhcol:=1
       else podtrhcol:=GetOtColor;
      linkok:=DecodeLink(Pc2Str(script),false)<>'';
      if (otBitmap^.MapModel=model_text)
       then PutBkgCol(ax,ay,bx-ax,$40-$30*ord(linkok)) else
      {if not oldie then{v oldies nepodtrhava}
      if not linkok
       then PrintBox(ax,ay+(by-ay)*3 div 5-1,bx-ax,1,podtrhcol)
       else PrintBox(ax,by-1,bx-ax,1,podtrhcol);
      end;
    {$ifdef beta}
    if typeof(otBitmap^)<>typeof(TDMBitmap) then erBetaMsg('reportlink: oáek†v†m DMBitmap, ne Bitmap');
    {$endif}
    InstallPx(rect,script);
    end;
end;

Procedure TWriter2.InstallPx(rect:TRect;px:pchar);
var script:pchar;
    data:pchar;
begin
 if edit
  then with rect do PrintBox(a.x,a.y,b.x-a.x,b.y-a.y,$720)
  else begin
    script:=StrNewStr(StrCutName(px));
    data:=StrNew(px);
    aInstallPx(PDMBitmap(otBitmap)^.project,PDMBitmap(otBitmap)^.Dkod,rect,script,data,otBitmap);
    end;
end;



Type
        PVengPlayer=^TVengPlayer;
        TVengPlayer=object(TPlayer)
          scene          :TVengScene;
          destRect       :TRect;
          mixingBuf      :PBitmap;
          constructor    Init(rect:TRect;vec:PathStr;otBitmap:PAbstractMap;zoom:word;transp:boolean);
          function       Sync:boolean;virtual;
          destructor     Done;virtual;
         end;

Constructor TVengPlayer.Init(rect:TRect;vec:PathStr;otBitmap:PAbstractMap;zoom:word;transp:boolean);
begin
 TObject.Init;
 destRect:=rect;
 if not scene.Init(otBitmap,rect.b.x-rect.a.x,rect.b.y-rect.a.y) then Fail;
 New(mixingBuf,Init(scene.MapModel,rect.b.x-rect.a.x,rect.b.y-rect.a.y));
 if mixingBuf=nil then begin scene.Done;Fail;end;
 scene.Load(vec);
 scene.ZP:=zoom;
 scene.transparent:=transp;
end;

Function TVengPlayer.Sync:boolean;
var   srcSize:Objects.TPoint;
      destRng,newSrcRect,newDestRect:TRect;
begin
 with scene do begin
   {zarotuje objektem}
   AngleX:=(AngleX+6) And TableMask;
   AngleY:=(AngleY+8) And TableMask;
   AngleZ:=(AngleZ+4) And TableMask;
   {smaze pozadi}
   Clr2Ful;
   {do snimku vkresli objekt}
   Draw;
   end;
 {zkopci snimek na obrazovku}
 with scrolscreen^ do begin
   srcSize.x:=scene.sizeX;
   srcSize.y:=scene.sizeY;
   GetClipping(destRng);
   GetResizeBltClipping(srcSize,destRect,destRng,newSrcRect,newDestRect);
   if not newDestRect.Empty
    then SuperResizeBtB2Box(0,@scene,map,mixingBuf,newSrcRect,newDestRect);
   end;
 Sync:=false;
end;

Destructor TVengPlayer.Done;
begin
 scene.Done;
 KillObj(mixingBuf);
 TObject.Done;
end;



Procedure TWriter2.ReportAnim(r:TRect;akod:TDkod;zoom:word;transp:boolean);
var   p:PPlayer;
begin
 if playlist<>nil then begin
   if (DkodIs(akod) and isFixedSize)>0
    then p:=new(PIndirectFLCPlayer,Init(new(PDMFileStream,Init(akod)),nil{screen},otBitmap,r))
    else p:=new(PVengPlayer,Init(r,Data(akod)^.name^,otBitmap,zoom,transp));
   if p<>nil then playlist^.Insert(p);
   end;
end;

{---------------------------------------------------------------------------
 Kresli picture do zadaneho vyrezu.
 Neposouva otY.
 ---------------------------------------------------------------------------}
Procedure TWriter2.PrintPic(name:PathStr;dx0,dy0,dsir,dvys:integer;
                             link2:pchar;castshad,shadebor,whitebor:integer);
var   sx0,sy0,ssir,svys:word;{src params}
      rx0,ry0,rsir,rvys:real;{src relative params <0..1>}
      b:PBitmap;
      p:PPal;
      r:TRect;
      i:word;
begin
 {tady by bylo mozny pouzit GetResizeBltClipping()}
 with otBitmap^ do begin
  {$ifdef beta}
  if (dsir<=0) or (dx0+dsir<=0) or (dx0>=sizeX) or
     (dvys<=0) or (dy0+dvys<=0) or (dy0>=sizeY) then erBetaMsg('printpic chaos 1');
  {$endif}
  rx0:=0;
  ry0:=0;
  rsir:=1;
  rvys:=1;
  if dx0<0 then begin rx0:=-dx0/dsir;rsir:=(dsir+dx0)/dsir;inc(dsir,dx0);dx0:=0;end;
  if dy0<0 then begin ry0:=-dy0/dvys;rvys:=(dvys+dy0)/dvys;inc(dvys,dy0);dy0:=0;end;
  if dx0+dsir>=sizeX then begin rsir:=rsir*(sizeX-dx0)/dsir;dsir:=sizeX-dx0;end;
  if dy0+dvys>=sizeY then begin rvys:=rvys*(sizeY-dy0)/dvys;dvys:=sizeY-dy0;end;
  {$ifdef beta}
  if (dsir<=0) or (dx0+dsir<=0) or (dx0>=sizeX) or
     (dvys<=0) or (dy0+dvys<=0) or (dy0>=sizeY) then erBetaMsg('printpic chaos 2');
  {$endif}
  if (link2<>nil) and (link2^<>#0) then ReportLink(dx0,dy0,dx0+dsir-1,dy0+dvys-1,link2);
  if MapModel=model_text
   then PrintBox(dx0,dy0,dsir,dvys,$700+176) else
  if (fileIs(name) and isPlayable)>0 then begin
    r.assign(dx0,dy0,dx0+dsir,dy0+dvys);
    ReportAnim(r,GetDkod(name,true),650,true);
    end
  else begin
    for i:=0 to 20 do SS.Sync;
    if name='' then b:=nil else b:=picLoad(name);
    if b=nil then begin
       for i:=0 to 20 do SS.Sync;
       {--udela prazdny ramecek--}
       PrintBox(dx0,dy0,dsir-2,dvys-2,Color(100,100,100,255));
       PrintBox(dx0+2,dy0+2,dsir-2,dvys-2,Color(60,60,60,255));
       PrintBox(dx0+2,dy0+2,dsir-4,dvys-4,Color(0,0,0,255));
      end else begin
       {--opravi model bitmapy--}
       if (DM[HiWord(GetDkod(name,false))]^.verzeDM<200) and (b^.MapModel=model_packed)
        then b^.transparent:=true;
       if b^.transparent
        then shadebor:=0;{u transparentnich nema smysl}
       if (shadebor<>0) and (b^.MapModel in models_direct)
        and not (otBitmap^.mapModel in models_direct) then ShadeBorder(b);
       JoinMapTo(b,otBitmap,true);
       if (shadebor<>0) and (b^.MapModel in models_direct) then ShadeBorder(b);
       {--namapuje bitmapu--}
       sx0:=round(rx0*b^.sizeX);
       sy0:=round(ry0*b^.sizeY);
       ssir:=round(rsir*b^.sizeX);
       svys:=round(rvys*b^.sizeY);
       if castshad<>0 then
        if b^.transparent then begin
          {stin transparentniho objektu}
          {v 95% pripadu ma paletu, directy si tudiz muzem dovolit ignorovat}
          {ale stejne nevim jak to sikovne udelat}
          end
        else
          {stin netransparentniho objektu}
          CastShadow(otBitmap,dx0,dy0,dsir,dvys);
       ResizeBtB2Box(0,b,sx0,sy0,ssir,svys,dx0,dy0,dsir,dvys);
       if whitebor<>0 then WhiteBorder(otBitmap,dx0,dy0,dsir,dvys,255);
       b^.Free;
      end;
    end;
  end;
end;


{---------------------------------------------------------------------------
 Kresli box do zadaneho vyrezu.
 ---------------------------------------------------------------------------}
Procedure TWriter2.PrintBox(x0,y0,sir,vys:integer;col:longint);
begin
 if otBitmap<>nil then otBitmap^.Col2Box(x0,y0+globshiftY,sir,vys,col);
end;


{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ WRITER ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}

{---------------------------------------------------------------------------
 Oznaci konec radku znakem >.
 ---------------------------------------------------------------------------}
Procedure TWriter2.MarkEol;
const c='>';
var   x:word;
begin
 {Podivny vypocet je kvuli precizni synchronizaci s rameckem.}
 x:=slpMid-slpSir div 2+slpSir-GetCharShift(c);
 PrintStr(c,x,otY);
 inc(overflows);
end;

{---------------------------------------------------------------------------
 Naskenuje kousek textu od stSrc, stDest.
 Parametr posun udava jestli tyto ukazatele a dalsi parametry posunuje
 do nove pozice.
 Zpracovava chgINIT,TAB.
 Skonci kdyz narazi na CR apod.
 Nastavi stMezer, stSirmez.
 Do stSrc2 da pri posunu stare stSrc, bez posunu nove stSrc.
 Vraci delku textu v pixelech.
 Doslo-li na radce k preteceni, vraci o $4000 vic.
 ---------------------------------------------------------------------------}
Function TWriter2.ScanShort(posun:boolean):integer;
var   startDest   :word;
      startSrc    :Pchar;
      addik       :integer;
      psat        :integer;
      tempAdd     :integer;
      pushed      :Tlfpush;
      l           :longint;
      tabonline   :boolean;
label normalchar;
begin
 addik        :=0;
 stMezer      :=0;
 stSirmez     :=0;
 stSrc2       :=stSrc;
 tempAdd      :=0;
 tabonline    :=false;
 ScanInit;
 if not posun then begin
   pushed     :=lfPush;
   startSrc   :=stSrc;
   end;
 startDest    :=stDest;
 repeat
   case stSrc^ of
     TAB:   begin
             if oldtabs=0 then goto normalchar;
             tabonline:=true;
             inc(stSrc);
{zruseno asi proto, ze linky s tabama to driv nezalamovalo
             stDest:=((stDest+1)*Tabs div slpSir+1)*slpSir div Tabs;{}
            end;
     chgINIT:begin
             {$ifdef edit}
             {pri editaci v textmodu zapocita znaky }
             if edit then
               begin
                if stDest+2>slpSir
                 then begin addik:=$4000;break;end
                 else inc(stDest,2);
               end
              else
             {$endif}
               {mimo editmod nezapocitava chgLINK}
               if (stSrc+1)^=chgLINK then
                repeat inc(stSrc) until stSrc^ in [chgINIT,CR,EOP];
             {znova testne zda nasleduje chgINIT,
              skiplink nas totiz moh posunout na konec radku}
             if stSrc^=chgINIT then begin
               inc(stSrc);
               lfSet(stSrc^);
               inc(stSrc);
               end;
            end;
     ELSE   begin
             normalchar:
             inc(stDest,tempAdd);{pricte addspace doufaje ze nasleduje text,
              pritom muze i pretect}
             l:=Scan;
             psat:=LoInt(l);
             addik:=HiWord(l);
             if psat<=0 then
               begin
                if psat=0 then begin
                  dec(stDest,tempAdd);{zrusi addspace kdyz text nenasledoval}
                  if addik=$4000 then inc(stSirmez,tempAdd);{
kdyz skoncil pretecenim, opravi vypocet stSirmez provedeny Scanem.
kdyz skoncil koncem lajny, nic nemeni, stSirmez=const 0.
skoncit necim jinym, treba zmenou fontu, by nemel.

pokud o 10 radek vys pri incu pretek, scanovani namerilo zaporny sirmez.
tento inc ho zpet znezaporni.
chyba: do kratkych linek napr na zacatku !news.cz to vklada pixelovy mezery,
 zakomentovanim se to spravi ale to nemuzu

jak je to se sirmez ?
  psat>0: vraci spravne cislo, tempAdd zapracovan
  psat=0: pokud skoncil pretecenim, melo by se opravit stSirmez o tempAdd
  psat<0: vraci hodnoty v minulosti ulozene do stPrevXxxx, tempAdd vyeliminovan
}
                  end;
                break;
               end;
             if addik=$4000 then break;
             tempAdd:=GetAddSpace;
            end;
     END;
 until false;
 {kdyz pretek kvuli tabu, skipne zbytek}
 if tabonline then begin while stSrc^<>#13 do inc(stSrc);end;
 ScanShort    :=addik+stDest-startDest;
 if not posun then begin
   stSrc2     :=stSrc;
   stSrc      :=startSrc;
   stDest     :=startDest;
   lfPop(pushed);
   end;
end;

{---------------------------------------------------------------------------
 Pise na jeden radek kousek textu od stSrc, stDest do slpXXXX, otY.
 Tyto ukazatele posouva.
 Zpracovava chgINIT,TAB.
 Skonci kdyz narazi na CR apod.
 Vyuziva hodnoty v stMezer, stSirmez.
 Vraci jestli psani skoncilo pretecenim sirky radku.
 ---------------------------------------------------------------------------}
Function TWriter2.WriteShort(txtsir:word;txtMaxUnder:integer):boolean;
var   Xmezer      :word;
      Xsirmez     :word;
      otX         :word;
      pretek      :boolean;
      psat        :integer;
      tempAdd     :integer;
      l           :longint;
      tabonline   :boolean;
      mute        :boolean;
label normalchar;
begin
 {mute kdyz se dostane pod konec stranky}
 mute:=otY+txtMaxUnder+globShiftY>otBitmap^.sizeY;
 if mute and not otOverflReported then begin
   {nehlasi zkracovani textu v dumbmode ani v oldies ani pri prerendrovavani jinym writerem(tam se preteceni daj cekat)}
   if not dumb and (minVerze>=100) and (otBitmap^.MapModel<>model_text) then
     ReportErr(_(_erZkracujiText));
   otOverflReported:=true;
   end;
 {Zarovnavani 0=doleva, 1=roztazeni, 2=centr, 3=doprava}
{bioswriteln('                 stdest='+stri(stdest)+' slpsir='+stri(slpsir)+
' txtsir='+stri(txtsir)+' sirmez='+stri(stsirmez)+' ');{}
 case otZarovnavat of
   0:stSirmez:=0;
   1:;
   2:begin if slpSir-stDest>txtsir then inc(stDest,(slpSir-stDest-txtsir) div 2);stSirmez:=0;end;
   3:begin if slpSir-stDest>txtsir then stDest:=slpSir-txtsir;stSirmez:=0;end;
   end;
 otX          :=slpMid-slpSir div 2+stDest;
 tempAdd      :=0;
 Xmezer       :=stMezer;
 Xsirmez      :=stSirmez;
 tabonline    :=false;
 ScanInit;
 {$ifdef edit}
 if edit then begin
   {Nastavi naky promenny o tomhle radku pro editor.}
   if linetotal<maxlines then begin
     inc(linetotal);
     edofs^[linetotal]:=ofs(stSrc^);
     scrx^[linetotal]:=otX;
     scry^[linetotal]:=otY;
     end;
   end;
 {$endif}
 repeat
   case stSrc^ of
     TAB:   begin
             if oldtabs=0 then goto normalchar;
             tabonline:=true;
             inc(stSrc);
             {$ifdef edit}
             if edit then
               begin
                PrintStr(TAB,otX,otY);
                inc(stDest,GetCharShift(TAB));
                continue;
               end;
             {$endif}
             stDest:=((stDest+1)*oldTabs div slpSir+1)*slpSir div oldTabs;
             otX:=slpMid-slpSir div 2+stDest;
            end;
     chgINIT:begin
             {$ifdef edit}
             if edit then begin
               if stDest+2>slpSir then
                 begin
                  WriteShort:=true;
                  MarkEol;
                  break;
                 end;
               inc(stDest,2);
               if (stSrc+1)^=chgLINK
                then PrintStr('',otX,otY)
                else PrintStr('',otX,otY);
               end
              else
             {$endif}
               {mimo editmod zpracuje chgLINK}
               TryReportLink(otX);
             {znova testne zda nasleduje chgINIT,
              TryReportLink nas totiz moh posunout na konec radku}
             if stSrc^=chgINIT then begin
               inc(stSrc);
               lfSet(stSrc^);
               {$ifdef edit}
               if edit then
                PrintStr('',otX,otY);
               {$endif}
               inc(stSrc);
               end;
            end;
     ELSE   begin
             normalchar:
             inc(stDest,tempAdd);{pricte addspace doufaje ze nasleduje text}
             inc(otX,tempAdd);
             l:=Scan;
             psat:=LoInt(l);
             pretek:=HiWord(l)>0;
(*             if psat<=0 then
               begin
                if psat=0 then begin
                  dec(stDest,tempAdd);{zrusi addspace kdyz text nenasledoval}
{do kratkych linek to misty vkladalo pixelovy mezery
                  inc(stSirmez,tempAdd);{i tady musi zrusit to co s addspacem urobil scan}
                  end;
                if pretek then begin
                  WriteShort:=true;
                  MarkEol;
                  break;
                  end;
                WriteShort:=false;
                break;
               end;*)
             if (psat>0) and not mute
              then Print(psat,stSrc-psat,Xmezer,Xsirmez,otX,otY);
             if pretek then begin
               WriteShort:=true;
               {zde je zrejme fuk ze muze vratit neopravene stDest}
               {hlavni je zvysit overflows}
               MarkEol;
               break;
               end;
             if psat<=0 then begin
               {zda se ze by se melo konat i pro psat<0...
               if psat=0 then begin
                 dec(stDest,tempAdd);{zrusi addspace kdyz text nenasledoval}
  {do kratkych linek to misty vkladalo pixelovy mezery
                 inc(stSirmez,tempAdd);{i tady musi zrusit to co s addspacem urobil scan}
                 {end;}
               dec(stDest,tempAdd);{zrusi addspace kdyz text nenasledoval}
               {if pretek then inc(stSirmez,tempAdd);na to uz je zrejme po funuse}
               WriteShort:=false;
               break;
               end;
             tempAdd:=GetAddSpace;
            end;
     END;
 until false;
 {kdyz pretek kvuli tabu, skipne zbytek a oznaci preteceni}
 if tabonline then
  if stSrc^<>MARKER then begin
    while stSrc^<>MARKER do inc(stSrc);
    MarkEol;
    end;
end;

{---------------------------------------------------------------------------
 Pise text od stSrc, stDest do slpXXXX, otY. Tyto ukazatele posouva.
 Zpracovava chgINIT,TAB,CR. Vysledkem je k okrajum zarovnany,
 popr. vycentrovany text pres vice radek.
 Skonci kdyz narazi na znak obsazeny v parametru ender.
 ---------------------------------------------------------------------------}
Procedure TWriter2.WriteLong(newwriter:PWriter2;zoomX,zoomY:real;ender:specstring);
var   pretek     :boolean;
      TextSrcOld :word;
      sir,newsir :integer;
      centruj    :boolean;{centrovat radek?}
      mark       :char;
      newpara    :boolean;
const CRLFx2     :pchar=#13#10#13#10;
label newline,odsadit,prirazit;
begin
 if stSrc=nil then exit;
 CheckFont;
 if newwriter<>nil then newwriter^.CheckFont;

 {Novy vetsi kus textu (odstavec nebo centrovany napis).}
 centruj     :=true;
 newpara     :=true;

 while pos(stSrc^,ender)=0 do begin

   {$ifdef edit}
   {zkusi jestli tu nezacina solidni blok textu}
   if (under<>0) and (undery1<0) and cmpBlock(stSrc-4,CRLFx2,4) and not (stSrc^ in [cmdINIT,#13]) then begin
     underxmid:=slpMid;
     underxsir:=slpSir+2*under;
     if abs(640-underxsir)<10 then underxsir:=640;
     undery1:=integer(otY)-under;
     end;
   {$endif}

   {Zacina s kurzorem uplne vlevo.}
   stDest:=0;
   {Resetne maxvys.}
   MaxReset;

   {ruzna formatovani textu}
   case otFormat of
     {primitivni formatovani ala T602}
     0:sir:=ScanShort(false{neposun});
     {automaticke centrovani a odsazovani odstavcu}
     1:begin
        {Kdyz je to novy radek, koukne jestli nezacina jednim dvema taby.}
        if stSrc^=TAB then
          begin
           inc(stSrc);
           if stSrc^=TAB
            then begin inc(stSrc);goto odsadit;end
            else begin stDest:=0;newpara:=false;goto prirazit;end;
          end;
        {Proskenuje radek.}
        sir:=ScanShort(false{neposun});
        {Kdyz je to novy radek:}
        if centruj then
          {Kdyz se sem cely vejde, vycentruje ho.}
          if (sir and $4000)=0 then begin
            if otZarovnavat<>2 then{aby necentroval 2x}
             stDest:=(slpSir-sir) div 2;
            end
           {Kdyz text pokracuje pres dalsi radek:}
          else begin
            odsadit:
            {Odsadi tento radek jako novy odstavec.}
            stDest:=slpOdsazX;
            newpara:=true;
            prirazit:
            {Resetne maxvys.}
            MaxReset;
            {Proskenuje radek znova po odsazeni.}
            sir:=ScanShort(false{neposun});
            end;
        {Kdyz pri scanu pretek tak pristi necentrovat.}
        centruj:=(sir and $4000)=0;
       end;
     end;

   {Posun o namerenou maximalni vysku nad lajnou dolu.}
   inc(otY,MaxOver);
   {Posun o odsazY na zacatku odstavce.}
   inc(otY,ord(newpara)*slpOdsazY);
   {Ma dalsi radek pravo zvat se zacatkem odstavce?}
   newpara:=sir and $4000=0;
   {Mark eol.}
   mark:=stSrc2^;
   stSrc2^:=MARKER;
   if debugW then BiosWrite('.');
   {Pisu stejnym fontem jako scanuju ?}
   if newwriter=nil then begin
     {Pise radek originalnim writerem.}
     WriteShort(sir and $3fff,MaxUnder);
     end
    else
     begin
      {Preda newwriteru parametry ziskane z origscanneru.}
      newwriter^.stSrc     :=stSrc;
      newwriter^.otY       :=MaxW(1,round(zoomY*otY));
{      reporterr(stri(otY)+'->'+stri(newwriter^.otY));{}
      newwriter^.slpMid    :=round(zoomX*slpMid);
      newwriter^.slpSir    :=round(zoomX*slpSir);
      {Proscanuje stejny text newwriterem bez omezeni delky.}
      newwriter^.slpSir    :=$3fff;
      newsir:=newwriter^.ScanShort(false{neposun});
      newwriter^.slpSir    :=round(zoomX*slpSir);
      {Pretect by pri neomezene delce nemel, ale jistota je jistota..}
      newsir               :=newsir and $3fff;
{      bioswrite(stri(newsir)+'->');{}
      {Psat bude relativne od stejneho mista jako origwriter.}
      newwriter^.stDest    :=round(zoomX*stDest);
      {Spocita o kolik je roztahnout.}
      newwriter^.stMezer   :=stMezer;
{bioswriteln('                            new.slpsir='+stri(newwriter^.slpSir)+
' newsir='+stri(newsir)+' new.stdest='+stri(newwriter^.stDest)+' z*stdest'+stri(round(zoomX*stDest)));{}
      if centruj then
       newwriter^.stSirmez :=0 else
       newwriter^.stSirmez :=MAXI(0,integer(newwriter^.slpSir) -newwriter^.stDest{odsazeni} -newsir);
     {Pise radek s omezenim delky.}
{      bioswrite(stri(stdest)+'->');{}
     newwriter^.WriteShort(newsir,round(zoomY*MaxUnder));

     {Posune ukazatele a parametry(font,color..) v selfu.}
     (*ScanShort(true{posun}); nefunguje tak jak ma*)
     {rychlejsi ale min univerzalni ekvivalent (zato funkcni):}
     stSrc:=stSrc2;
     inc(stDest,sir and $3fff+stSirmez);
     lfSet(newwriter^.lfFont);
     lfSet(newwriter^.lfColor);{}

     end;
   {Unmark eol.}
   stSrc2^:=mark;
   {Preskoci oddelovac radku.}
   case stSrc^ of  CR:inc(stSrc,2);
                  ' ':inc(stSrc);
                  end;
   {Posun o namerenou maximalni vysku pod lajnou dolu.}
   inc(otY,MaxUnder);

   {Provizorni osetreni pretekani.}
   {Vyssi bitmapu stejne nejde vygenerovat.}
   if otY>16380 then otY:=16380;

   {$ifdef edit}
   {zkusi jestli tu nekonci solidni blok textu}
   if (under<>0) and (undery1>=0) and cmpBlock(stSrc,CRLFx2,4) and (length(underrects)<230) then begin
     undery2:=otY+under;
     if undery2-undery1>40 then begin
       if underrects<>'' then underrects:=underrects+' ';
       underrects:=underrects
        +stri(underxmid)+','
        +stri(undery1)+','
        +stri(underxsir)+','
        +stri(undery2-undery1);
       end;
     undery1:=-1;
     end;
   {$endif}

   end;
end;


END.
