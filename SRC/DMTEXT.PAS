Unit      DMText; {$i define.inc}

{ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß}
                             INTERFACE
{ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ}

Uses      Memo,Chyby,
          Dos,Objects,Strings,
          Stringy,CS,Sys,Texty,Vga,Fajly,Fonty,Textury,Streamy,Loadery;

Function  Init:TError;
Procedure Done;


{---------------------------------------------------------------------------
                       Podpora pro analyzu DMPage
 ---------------------------------------------------------------------------}

{$i data.inc}
{$i dmtext.inc}

const idmpage='nfo:ëmÒagî ';
      idmpagelen=11;

const flagColorRam    ='c';
      flagTimeout     ='t';
      flagOldTabs     ='o';
      flagTxa         ='a';
      flagShading     ='s';
      flagDontSavePos ='p';
      flagMusicFirsts ='m';{z kolika prvnich polozek mus: se vybira pri prvnim vlezu na page}
      flagStaticSlide ='l';{nemenit rozliseni ve slideshow}

const maxpulek        =18;

      {flagy pro loader textu}
      dmtfResizeNadp  =1;
      dmtfNoTemplate  =2;
      dmtfRepMisTemp  =4;
      dmtfCreatePage  =8;
      dmtfThisIsTemp  =16;
      dmtfForcePacked =32;
      dmtfNoChkFonts  =64;
      {flagy pro pro generator bitmapy}
      dmtfNoBody      =128;
      dmtfVyhExport   =256;

type  TOK = (ok256,okDirect,okTxt,okGfx2Txt,okPic,okEmpty,ok_none);

      PDMText = ^TDMText;
      TDMText = object(TText3)
                     constructor  Init(txSize:longint;txStart:pointer;name:PathStr;flags:word;var result:TError);
                     function     Save(name:PathStr):TError;
                     destructor   Done;virtual;

                     function     FontsReady:boolean;

                     function     textStart:word;{offset za headerem}
                     procedure    GoZaheader3;
                     procedure    LoadThisTemplate(flags:word;template:PathStr);
                     procedure    LoadTemplate(flags:word);

                     function     GetHeader(what:string):string;
                     function     ExistsHeader(what:string):boolean;
                     function     SetHeader(what,value:string):integer;

                     function     GetFlag(what:char):longint;
                     procedure    SetFlag(what:char;how:longint);

                     function     OutputKind(flags:word):TOK;

                     procedure    SlpReset;
                     function     SlpAddHalf(xx,yy{$ifdef edit},firstline{$endif}:word):boolean;
                     function     SlpMax:integer;
                     function     SlpX(pulka:integer):integer;
                     function     SlpY(pulka:integer):integer;
      {$ifdef edit}
                     function     SlpW(slp:integer):integer;
                     function     SlpNow:integer;
                     procedure    SlpGo(slp:integer);
                     procedure    SlpRect(slp:integer;var rect:TRect);
                     function     SlpMaxX:integer;
                     function     SlpFirstLine(slp:integer):integer;
                     function     SlpLastLine(slp:integer):integer;
                     function     SlpGetNum(slp,kolikaty:integer):integer;
                     procedure    SlpSetNum(slp,kolikaty,value:integer);
                     procedure    SlpAddNum(slp,kolikaty,addvalue:integer);
                     function     SlpRehook(slp,posun:integer):boolean;
                     function     SlpSplit(slp:word):boolean;
                     function     SlpMerge(slp2:word):boolean;
      {$endif}

                    private
                     pulek        :shortint;
                     pulky        :array[0..maxpulek] of record x{=xmid},y{=y0}:integer;{$ifdef edit}adr,line:word;{$endif}end;

                     function     ReadInt3:integer;

                     function     GetNum(adr,kolikaty:word):integer;
                     procedure    SetNum(adr,kolikaty:word;value:integer);
                     procedure    AddNum(adr,kolikaty:word;addvalue:integer);

                     procedure    ReportInsert(adrs:word;inserted:integer);


                     procedure    TransPageHeader;
                     procedure    TransTex;
                     procedure    TransNewslpHeaders;
                     procedure    TransOthers(resizeNadpisy:boolean);
                     procedure    TransChgfnts;
                     procedure    TransChkbox;
                     procedure    TransPicHref;
                     function     AdjustVersion(flags:word;var result:TError):word;

                   public
                     procedure    SetAlignHere(set3:shortint);

                   public
                     modified     :boolean;
                     function     GetSetFontMark(st:FileStr):char;
                     procedure    PutSetFontMark(st:FileStr);
                     procedure    AssignFontToMark(st:PathStr;c:char);
                   public
                     mytemplate   :PDMText;

                     okForced     :TOK;{pretizi vysledek fce OutputKind}
                   end;


{$ifdef edit}
const maxlines        =10000;
type  TEdLines        =array[1..maxlines+1] of word;
var   edofs,scrx,scry :^TEdLines;
      linetotal       :word;{asi takovej index ze ukazuje na 0 na konci fajlu?}
{$endif}



{ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß}
                          IMPLEMENTATION
{ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ}


{---------------------------------------------------------------------------
 Vraci offset za headerem.
 ---------------------------------------------------------------------------}
Function TDMText.textStart:word;
var p:pointer;
begin
 p:=pos;
 GoZaheader3;
 textStart:=word(pos);
 pos:=p;
end;

{---------------------------------------------------------------------------
 Nastavi pos za header ery 3, na zacatek textu.
 ---------------------------------------------------------------------------}
Procedure TDMText.GoZaheader3;
begin
 Reset;
 while system.pos(':',nlGet)=4 do nlGoto(+1);
end;

{---------------------------------------------------------------------------
 Nacte 3ciferny decimalni integer -500..499.
 ---------------------------------------------------------------------------}
Function TDMText.ReadInt3:integer;
var   i:integer;
begin
 i:=ReadCif+10*ReadCif+100*ReadCif;
 if i>=500 then dec(i,1000);
 ReadInt3:=i;
end;



{---------------------------------------------------------------------------
 Vrati hodnotu promenne z headeru.
 Prohledava zacatek textu dokud radky odpovidaji syntaxi headeru:
  3 znakova promenna, dvojtecka, hodnota promenne.
 ---------------------------------------------------------------------------}
Function TDMText.GetHeader(what:string):string;
var   st:string;
      oldpos:pchar;
      inherit:boolean;
label found;
begin
 oldpos:=pos;
 Reset;
 GetHeader:='';
 repeat
  st:=nlRead;
  if copy(st,1,length(what))=what then
   begin
    GetHeader:=copy(st,length(what)+1,255);
    goto found;
   end;
 until system.pos(':',st)<>4;
 inherit:=(mytemplate<>nil) and (what<>'siz:') and (what<>'tem:');
 if inherit then GetHeader:=mytemplate^.GetHeader(what);
 found:
 pos:=oldpos;
end;

Function TDMText.ExistsHeader(what:string):boolean;
var   st:string;
      oldpos:pchar;
      inherit:boolean;
label found;
begin
 oldpos:=pos;
 Reset;
 ExistsHeader:=false;
 repeat
  st:=nlRead;
  if copy(st,1,length(what))=what then
   begin
    ExistsHeader:=true;
    goto found;
   end;
 until system.pos(':',st)<>4;
 inherit:=(mytemplate<>nil) and (what<>'siz:') and (what<>'tem:');
 if inherit then ExistsHeader:=mytemplate^.ExistsHeader(what);
 found:
 pos:=oldpos;
end;

{---------------------------------------------------------------------------
 Nastavi promennou v headeru.
 Vraci o kolik se posunul zbytek textu.
 ---------------------------------------------------------------------------}
Function TDMText.SetHeader(what,value:string):integer;
var   i:word;
      chg:integer;
      st,newvalue:string;
      oldpos:pchar;
      inherit:boolean;
begin
 oldpos:=pos;
 Reset;
 chg:=0;
 repeat
  st:=nlGet;
  if system.pos(':',st)<>4 then break;
  if copy(st,1,length(what))=what then
    begin
     InsStr(word(pos),length(st)+length(newln),'');
     dec(chg         ,length(st)+length(newln));
    end
    else
     nlGoto(+1);
 until false;
 inherit:=(mytemplate<>nil) and (what<>'siz:') and (what<>'tem:');
 if (not inherit and (value<>''))
  or (inherit and (value<>mytemplate^.GetHeader(what))) then begin
   newvalue:=what+value+newln;
   inc(chg,length(newvalue));
   InsStr(word(pos),0,newvalue);
   end;
 pos:=oldpos+chg;
 ReportInsert(0,chg);
end;


{---------------------------------------------------------------------------
 Vrati hodnotu zadaneho flagu z headeru.
 ---------------------------------------------------------------------------}
Function TDMText.GetFlag(what:char):longint;
var   i:word;
      st:string;
begin
 st:=GetHeader('fla:');
 i:=system.pos(what,st);
 if i=0 then
{  case what of
    flagParagraphX:GetFlag:=24;
    else} GetFlag:=0{;
    end              }
 else
  if (i=length(st)) or not (st[i+1] in ['+','-','0'..'9']) then
    case what of
      flagTxa:GetFlag:=20;
      else GetFlag:=1;
      end
  else
    GetFlag:=stringy.GetNum(copy(st,i+1,255),1);
end;

{---------------------------------------------------------------------------
 Nastavi zadany flag v headeru.
 ---------------------------------------------------------------------------}
Procedure TDMText.SetFlag(what:char;how:longint);
var   st:string;
      i:word;
      pozi,leng:integer;
begin
 st:=GetHeader('fla:');
 i:=system.pos(what,st);
 {odstrani stary udaj}
 if i>0 then begin
   if GetNumPos(copy(st,i,255),1,pozi,leng)=how then
    if pozi=1 then exit;{udaj se nemeni}
   if pozi<>1 then leng:=0;
   delete(st,i,leng+1);
   end;
 {nastavi novy udaj}
 case how of 0:;
             1:st:=st+what;
          else st:=st+what+Stri(how);
          end;
 SetHeader('fla:',st);
end;

Function TDMText.OutputKind(flags:word):TOK;
begin
 if okForced<>ok_none then OutputKind:=okForced else
  if locased(GetHeader('fnt:'))='textmode.fn' then OutputKind:=okTxt else
   if stringy.GetNum(GetHeader('res:'),1)+stringy.GetNum(GetHeader('res:'),2)<300 then OutputKind:=okGfx2Txt else
    if (texType(GetHeader('tex:'))='t') or ((flags and dmtfForcePacked)>0) then OutputKind:=ok256 else
     OutputKind:=okDirect;
end;

{---------------------------------------------------------------------------
 Vrati zadane cislo na radce.
 ---------------------------------------------------------------------------}
Function TDMText.GetNum(adr,kolikaty:word):integer;
begin
 GetNum:=stringy.GetNum(nlGetFrom(adr),kolikaty);
end;

{---------------------------------------------------------------------------
 Nastavi zadane cislo na radce.
 ---------------------------------------------------------------------------}
Procedure TDMText.SetNum(adr,kolikaty:word;value:integer);
var   st:string;
begin
 st:=nlGetFrom(adr);
 ReportInsert(adr+1{+1 aby pridal az pristimu sloupci},InsStr(adr,length(st),ReplacedNum(st,kolikaty,value)));
end;

{---------------------------------------------------------------------------
 Zvysi zadane cislo na radce.
 ---------------------------------------------------------------------------}
Procedure TDMText.AddNum(adr,kolikaty:word;addvalue:integer);
begin
 SetNum(adr,kolikaty,GetNum(adr,kolikaty)+addvalue);
end;

{---------------------------------------------------------------------------
 Vynuluje udaje o sloupcich.
 ---------------------------------------------------------------------------}
Procedure TDMText.SlpReset;
begin
 with pulky[0] do begin
   x:=0;
   y:=0;
   {$ifdef edit}
   adr:=word(Pos);
   line:=65535;
   {$endif}
   end;
 pulek:=0;
end;

{---------------------------------------------------------------------------
 Prida zacatek nebo konec sloupce. Volat s pos na zacatku headeru.
 ---------------------------------------------------------------------------}
Function TDMText.SlpAddHalf(xx,yy{$ifdef edit},firstline{$endif}:word):boolean;
begin
 SlpAddHalf:=false;
 if pulek<maxpulek then begin
   inc(pulek);
   with pulky[pulek] do begin
     x    :=xx;
     y    :=yy;
     {$ifdef edit}
     adr  :=word(pos);
     line :=firstline;
     {$endif}
     end;
   SlpAddHalf:=true;
   end;
end;

{---------------------------------------------------------------------------
 Vrati pocet sloupcu.
 ---------------------------------------------------------------------------}
Function TDMText.SlpMax:integer;
begin
 SlpMax:=(pulek+1) div 2;
end;

{---------------------------------------------------------------------------
 Vrati Xmid pulky.
 ---------------------------------------------------------------------------}
Function TDMText.SlpX(pulka:integer):integer;
begin
 SlpX:=pulky[pulka].x;
end;

{---------------------------------------------------------------------------
 Vrati Y pulky.
 ---------------------------------------------------------------------------}
Function TDMText.SlpY(pulka:integer):integer;
begin
 SlpY:=pulky[pulka].y;
end;

{$ifdef edit}
{---------------------------------------------------------------------------
 Vrati W sloupce.
 ---------------------------------------------------------------------------}
Function TDMText.SlpW(slp:integer):integer;
begin
 SlpW:=GetNum(pulky[2*slp-1].adr,4);
end;

{---------------------------------------------------------------------------
 Skoci na zacatek headeru sloupce.
 ---------------------------------------------------------------------------}
Procedure TDMText.SlpGo(slp:integer);
begin
 if (slp>=1) and (slp<=SlpMax) then word(pos):=pulky[2*slp-1].adr;
end;

{---------------------------------------------------------------------------
 Vrati polohu a tvar sloupce.
 ---------------------------------------------------------------------------}
Procedure TDMText.SlpRect(slp:integer;var rect:TRect);
begin
 rect.a.x:=SlpX(2*slp-1)-SlpW(slp) div 2;
 rect.b.x:=rect.a.x+SlpW(slp);
 rect.a.y:=SlpY(2*slp-1);
 rect.b.y:=SlpY(2*slp);
end;

{---------------------------------------------------------------------------
 Vrati nejvetsi X do ktereho zasahuje nejaky sloupec.
 ---------------------------------------------------------------------------}
Function TDMText.SlpMaxX:integer;
var   i,max:integer;
begin
 max:=0;
 for i:=1 to SlpMax do max:=maxW(max,SlpX(2*i)+SlpGetNum(i,4) div 2);
 SlpMaxX:=max;
end;

{---------------------------------------------------------------------------
 Vrati prvni Line ve sloupci.
 Pokud tam zadna neni...?
 ---------------------------------------------------------------------------}
Function TDMText.SlpFirstLine(slp:integer):integer;
begin
 SlpFirstLine:=pulky[2*slp-1].line;
end;

{---------------------------------------------------------------------------
 Vrati posledni Line ve sloupci.
 Pokud tam zadna neni...?
 ---------------------------------------------------------------------------}
Function TDMText.SlpLastLine(slp:integer):integer;
begin
 SlpLastLine:=pulky[2*slp].line;
end;

{---------------------------------------------------------------------------
 Vrati sloupec ve kterem lezi pos.
 ---------------------------------------------------------------------------}
Function TDMText.SlpNow:integer;
var   i:integer;
begin
 for i:=1 to SlpMax+1 do {+1 aby pri prilis velkym pos vratil max+1}
  if word(pos)<pulky[2*i].adr then break;{was: <=}
 SlpNow:=i;
end;

{---------------------------------------------------------------------------
 Vrati zadane cislo v definici sloupce.
 ---------------------------------------------------------------------------}
Function TDMText.SlpGetNum(slp,kolikaty:integer):integer;
begin
 SlpGetNum:=GetNum(pulky[2*slp-1].adr,kolikaty);
end;

{---------------------------------------------------------------------------
 Nastavi zadane cislo v definici sloupce.
 ---------------------------------------------------------------------------}
Procedure TDMText.SlpSetNum(slp,kolikaty,value:integer);
begin
 SetNum(pulky[2*slp-1].adr,kolikaty,value);
end;

{---------------------------------------------------------------------------
 Zvysi zadane cislo v definici sloupce.
 ---------------------------------------------------------------------------}
Procedure TDMText.SlpAddNum(slp,kolikaty,addvalue:integer);
begin
 AddNum(pulky[2*slp-1].adr,kolikaty,addvalue);
end;

{---------------------------------------------------------------------------
 Sloupec slp zavesi o posun pozic dal nez je. Hlida si meze (0..sloupcu).
 Vraci jestli tim doslo ke zmene.
 ---------------------------------------------------------------------------}
Function TDMText.SlpRehook(slp,posun:integer):boolean;
var   old:word;
begin
 SlpRehook:=false;
 old:=SlpGetNum(slp,1);
 if old+posun<0 then posun:=-old else
 if old+posun>2*slp-2 then posun:=2*slp-2-old;
 if posun<>0 then begin
   SlpSetNum(slp,1,old+posun);
   SlpAddNum(slp,2,SlpX(old)-SlpX(old+posun));
   SlpAddNum(slp,3,SlpY(old)-SlpY(old+posun));
   SlpRehook:=true;
   end;
end;

{---------------------------------------------------------------------------
 Rozdeli sloupec v pozici pos na dva.
 Vraci jestli akci provedl.
 ---------------------------------------------------------------------------}
Function TDMText.SlpSplit(slp:word):boolean;
var   i,j:integer;
      addy:string[5];
begin
 SlpSplit:=false;
 if pulek+2<=maxpulek then begin
   for i:=slp to SlpMax do begin
     j:=SlpGetNum(i,1);
     if j div 2>=slp then SlpSetNum(i,1,j+2);
     end;
{   if ((pos-1)^=newln[length(newln)]) and () then addy:='' else} addy:=newln;
   InsStr(word(pos),0,addy+cmdINIT+cmdNEWSLP+
     Stri(2*slp)+',0,16,'+Stri(SlpGetNum(slp,4))+cmdDONE+newln);
   SlpSplit:=true;
   end;
end;

{---------------------------------------------------------------------------
 Spoji dva sloupce do jednoho, parametr je druhy z nich.
 Vraci jestli akci provedl.
 ---------------------------------------------------------------------------}
Function TDMText.SlpMerge(slp2:word):boolean;
var   i,j:integer;
begin
 SlpMerge:=false;
 if slp2>1 then begin
   {slpce poveseny na rusenej prevesi na jeho predchudce}
   for i:=slp2+1 to SlpMax do begin
     j:=SlpGetNum(i,1);
     if j=2*slp2-2 then SlpRehook(i,-1) else
      if j=2*slp2-1 then SlpRehook(i,-2) else
       if j=2*slp2 then SlpRehook(i,-3);
     end;
   {killne slpheader}
   for i:=slp2+1 to SlpMax do begin
     j:=SlpGetNum(i,1);
     if j>=2*slp2 then SlpSetNum(i,1,j-2);
     end;
   i:=pulky[2*slp2-1].adr;{adr}
   j:=nlAdrFrom(i,+1)-i;{len}
   InsStr(i,j,'');
   ReportInsert(i,-j);
   SlpMerge:=true;
   end;
end;
{$endif}

{---------------------------------------------------------------------------
 Opravi adresy sloupcu, radek apod.. pri insertu nebo deletu.
 ---------------------------------------------------------------------------}
Procedure TDMText.ReportInsert(adrs:word;inserted:integer);
var   i:word;
begin
{$ifdef edit}
 if inserted<>0 then begin
  {opravi adresy sloupcu}
  for i:=0 to pulek do
   with pulky[i] do
    if adr>=adrs then begin
      inc(adr,inserted);
      if adr<adrs then adr:=adrs;
      end;
  {opravi adresy radek}
  for i:=1 to linetotal do
   if edofs^[i]>=adrs then inc(edofs^[i],inserted);
  end;
{$endif}
end;






{ßßßßßßßßßßßßßßßßßßßßßßßßßßßßß KONVERZE ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß}

const oldNORMAL                 ='tenkej.fn';
      oldDABL                   ='tenkejh.fn';
      oldDABLBOLD               ='tenkejhb.fn';
      oldBARD                   ='bard_0.fn';
      oldBIG                    ='big_0.fn';
      oldBIGPUL                 ='bigpul_0.fn';

{---------------------------------------------------------------------------
 Vraci jakym signalem ma byt oznamovan font st.
 Podle potreby prihodi dosud nezarazeny font do headeru.
 ---------------------------------------------------------------------------}
Function TDMText.GetSetFontMark(st:FileStr):char;
var   i:integer;
      oldf:PathStr;
      c:char;
      oldp:pchar;
      minpos:word;
label freeslot_c;
begin
 LoCasni(st);
 {pokud font uz je v headeru, vrati jeho znak}
 oldf:=LoCased(GetHeader('fnt:'));
 c:=chgFNT;
 while oldf<>'' do begin
   if st=CutString(oldf,';') then begin GetSetFontMark:=c;exit;end;
   inc(c);
   end;
 {font neni v headeru, hledame pro nej volny slot}
 oldp:=pos;
 c:=chgFNT;
  {hleda jestli je pouzit prvni slot}
  Reset;
  stGoto(chgINIT+c);
  if Eof then begin
    Reset;
    GoZaheader3;
    repeat
      case ReadChar of
        cmdINIT:chGoto(cmdDONE,+1);
        chgINIT:if ReadChar in [chgFNT..chgFNTz] then goto freeslot_c;
        #13:Skip(1);
        else break;{nasel pismeno prvnim fontem}
        end;
      if Eof then goto freeslot_c;
    until false;
    end;
  {hleda jestli je volny nektery z dalsich slotu}
  repeat
   inc(c);
   Reset;
   stGoto(chgINIT+c);
  until Eof;
 freeslot_c:
 pos:=oldp;
 {prepiseme slot c vybranym fontem}
 {if c>chgFNTz then erBetaMsg('moc fontu na jedne strance');}
 GetSetFontMark:=c;
 AssignFontToMark(st,c);
end;

Procedure TDMText.AssignFontToMark(st:PathStr;c:char);
var oldf,newf:string;
begin
 oldf:=LoCased(GetHeader('fnt:'));
 newf:='';
 while c<>chgFNT do begin newf:=newf+';'+CutName(oldf);dec(c);end;
 CutName(oldf);
 newf:=newf+';'+LoCased(st)+';'+oldf;
 while newf[length(newf)]=';' do dec(newf[0]);
 SetHeader('fnt:',copy(newf,2,255));
end;

Procedure TDMText.PutSetFontMark(st:FileStr);
begin
 pos^:=GetSetFontMark(st);
end;

{---------------------------------------------------------------------------
 Nastavi zarovnani aktualniho odstavce.
   -1=implicitni
 0..3=jako v prikazu f
 ---------------------------------------------------------------------------}
Procedure TDMText.SetAlignHere(set3:shortint);
var   oldpos:pchar;
      begline1,begline2,begline3:word;{klicovy mista..zacatky prikazu f}
      bef1,bef2,bef3:shortint;{format before our paragraph}
      aft1,aft2,aft3:shortint;{format after our paragraph, must stay unchanged}
      s:string[10];
      startup3:shortint;
      qq:char;
begin
 oldpos:=pos;
 begline1:=nlAdr(0);{ulozi zacatek naseho odstavce}
 begline2:=nlAdr(+1);{ulozi zacatek dalsiho odstavce}
 begline3:=nlAdr(+2);{ulozi neco jako konec dalsiho odstavce}

 {zjisti startup format startupX}
 startup3:=1;
 s:=GetHeader('fmt:');
 CutString(s,',');
 CutString(s,',');
 if s<>'' then startup3:=valu(s);

 {zjisti implicitni format befX}
 GoZaheader3;
 bef1:=-1;
 bef2:=-1;
 bef3:=-1;
 repeat
   if Eof or (word(pos)>=begline2) then break;
   if pos^=cmdFORMAT then begin
     inc(pos);{skip f}
{qq:=(pos+20)^;(pos+20)^:=#0;reporterr(strpas(pos));(pos+20)^:=qq;{*}
     if pos^ in ['0'..'9'] then bef1:=StrCutNum(pos);
{qq:=(pos+20)^;(pos+20)^:=#0;reporterr(strpas(pos));(pos+20)^:=qq;{*}
     inc(pos);{skip ,}
     if pos^ in ['0'..'9'] then bef2:=StrCutNum(pos);
{qq:=(pos+20)^;(pos+20)^:=#0;reporterr(strpas(pos));(pos+20)^:=qq;{*}
     inc(pos);{skip ,}
     if word(pos)<begline1 then
      if pos^ in ['0'..'9'] then bef3:=StrCutNum(pos);
     end;
   chGoto(cmdINIT,+1);
 until false;
 {zjisti implicitni format aftX}
 GoZaheader3;
 aft1:=-1;
 aft2:=-1;
 aft3:=-1;
 repeat
   if Eof or (word(pos)>=begline3) then break;
   if pos^=cmdFORMAT then begin
{qq:=(pos+20)^;(pos+20)^:=#0;reporterr(strpas(pos));(pos+20)^:=qq;{*}
     inc(pos);{skip f}
     if pos^ in ['0'..'9'] then aft1:=StrCutNum(pos);
     inc(pos);{skip ,}
     if pos^ in ['0'..'9'] then aft2:=StrCutNum(pos);
     inc(pos);{skip ,}
     if pos^ in ['0'..'9'] then aft3:=StrCutNum(pos);
     end;
   chGoto(cmdINIT,+1);
 until false;

 {najde kam prsknout zacatek alignu}
 word(pos):=begline1;
 begline1:=0;
 while pos^=cmdINIT do begin
   if (pos+1)^='f' then begline1:=word(pos);
   chGoto(cmdDONE,+1);
   end;
 if begline1<>0 then word(pos):=begline1;
 {nastavi zacatek alignu}
 if pos^=cmdINIT then DelSpaces(word(pos),chAdr(cmdDONE,+1)+1-word(pos));
 if (bef3=-1) and (set3=startup3) then set3:=-1;{jako uplne prvni nastavi startup -> nic nenastavovat}
 if set3=bef3 then set3:=-1;{jako pozdejsi nastavi co bylo predtim -> nic nenastavovat}
 bef3:=set3;
 s:='';
 if bef1<>-1 then s:=stri(bef1);
 s:=s+',';
 if bef2<>-1 then s:=s+stri(bef2);
 s:=s+',';
 if bef3<>-1 then s:=s+stri(bef3);
 if s<>',,' then InsStr(word(pos),0,cmdINIT+cmdFORMAT+s+cmdDONE);

{reporterr('start='+stri(startup3)+' bef='+stri(bef3)+' aft='+stri(aft3));{*}
 {najde kam prsknout konec alignu}
 nlGoto(+1);
 begline2:=0;
 while pos^=cmdINIT do begin
   if (pos+1)^='f' then begline2:=word(pos);
   chGoto(cmdDONE,+1);
   end;
 if begline2<>0 then word(pos):=begline2;
 {nastavi konec alignu}
 if pos^=cmdINIT then DelSpaces(word(pos),chAdr(cmdDONE,+1)+1-word(pos));
 if (aft3=-1) and (set3<>-1) then aft3:=startup3;{neco nastavi jako uplne prvni do prazdna -> ukoncit startupem}
 if (bef3=-1) and (set3=-1) and (aft3=startup3) then aft3:=-1;{smaze neco uplne prvni a ukonceno startupem -> smazat i ten}
 s:='';
 if (aft1<>-1) and (aft1<>bef1) then s:=stri(aft1);
 s:=s+',';
 if (aft2<>-1) and (aft2<>bef2) then s:=s+stri(aft2);
 s:=s+',';
 if (aft3<>-1) and (aft3<>bef3) then s:=s+stri(aft3);
 if s<>',,' then InsStr(word(pos),0,cmdINIT+cmdFORMAT+s+cmdDONE);

 {hotovo}
 pos:=oldpos;
end;

{---------------------------------------------------------------------------
 Vraci priblizne cislo verze (0,20,43,100..).
 ---------------------------------------------------------------------------}
FUNCTION HeaderVersion(st:string):word;
var   i,j:word;
begin
 if copy(st,1,idmpagelen)=idmpage
  then HeaderVersion:=Valu(copy(st,idmpagelen+1,3))
  else begin
   j:=0;
   for i:=1 to minW(length(st),18) do case st[i] of '0'..'9':inc(j);end;
   if (length(st)=4) and (j=4) then HeaderVersion:=20 else
    if (length(st)=18) and (j>=16) then HeaderVersion:=43
     else HeaderVersion:=0;
   end;
end;

{---------------------------------------------------------------------------
 Zkonverti header.
 Z verze 0.31..0.99 na verzi 1.xx..2.xx.
 ---------------------------------------------------------------------------}
Procedure TDMText.TransPageHeader;
var   st:string;
      i:word;
const h_radek      =1;
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
      f_killprevmus=8;
      f_timeout    =64;
begin
 {nacte headerinfo}
 Reset;
 st:=nlRead;
 {prepise stary header novym}
 InsStr(start,18,idmpage+verze);
 {oznaci paletu}
 if ((ord(st[h_flags]) and f_vlastni_pal)>0)
  and (GetHeader('pal:')='') then InsStr(word(Pos),0,'pal:');
 {nastavi flags}
 i:=ord(st[h_flags]);
 if (i and f_color_ram  )>0 then SetFlag(flagColorRam   ,1);
 if (i and f_timeout    )>0 then SetFlag(flagTimeout    ,5);
 {nastavi texturu}
 if GetHeader('tex:')='' then SetHeader('tex:',st[h_textura]);
 {nastavi pagesize}
 if GetHeader('siz:')=''
  then SetHeader('siz:','360x'+stri( maxW(464,16*( Valu(copy(st,h_radek,3))-2 )) ));
 {nastavi resolution}
 if GetHeader('res:')=''
  then SetHeader('res:','360x464');
 {nastavi taby}
 SetFlag(flagOldTabs,ord(st[h_tabs])-48);
 {nastavi fonty}
 SetHeader('fnt:',oldNORMAL);
end;

{---------------------------------------------------------------------------
 Zkonverti popis textur.
 Z verze 0.31..0.99 na verzi 1.xx..2.xx.
 ---------------------------------------------------------------------------}
Procedure TDMText.TransTex;
var   s1,s2:string;
      i:word;
begin
 { =num -> =num-16 }
 s2:=GetHeader('tex:');
 s1:='';
 repeat
  s1:=s1+CutString(s2,'=');
  if s2='' then break;
  s1:=s1+'=';
  s2:=ReplacedNum(s2,1,maxI(0,stringy.GetNum(s2,1)-16));
 until false;
 { (num,num) pred kodem textury -> (num-76,num) }
 for i:=1 to length(s1) do
  if (s1[i]='(') and not (s1[i-1] in ['a'..'z','~','>']) then
   s1:=copy(s1,1,i)+
       ReplacedNum(copy(s1,i+1,255),1,
                   maxI(0,stringy.GetNum(copy(s1,i+1,255),1)-76));
 {save it}
 SetHeader('tex:',s1);
end;

{---------------------------------------------------------------------------
 Zkonverti NEWSLP headery.
 Z verze 0.31..0.99 na verzi 1.xx..2.xx.
 ---------------------------------------------------------------------------}
Procedure TDMText.TransNewslpHeaders;
var   slp,s,x,y,z:integer;
      sir:array[0..10] of integer;
      st:string;
const oldNEWSLP    ='^';
begin
 {nacte sirky sloupcu}
 GoZaheader3;
 sir[0]:=0;
 slp:=1;
 while word(Pos)<konec do begin
   st:=nlRead;
   if (st[1]=oldNEWSLP) and (length(st)=11) then begin
     dec(pos,5);
     if slp<11 then sir[slp]:=ReadInt3;
     inc(slp);
     end;
   end;
 {zkonverti headery sloupcu a nektere spec.znaky}
 GoZaheader3;
 while word(Pos)<konec do begin
   st:=nlGet;
   if length(st)>0 then case st[1] of
     oldNEWSLP:if (length(st)=11) then
       begin
       inc(pos);
       s:=ord(ReadChar)-48;
       slp:=(s+1) div 2;
       x:=ReadInt3;
       y:=ReadInt3;
       z:=ReadInt3;
       if slp=0 then dec(x,76);
       InsStr(word(Pos)-11,11,cmdINIT+cmdNEWSLP+Stri(s)+','
              +Stri(x+(z-sir[slp]) div 2)+','+Stri(y*16)+','+Stri(z)+cmdDONE);
       end;
     END;
   nlGoto(+1);
   end;
end;

{---------------------------------------------------------------------------
 Zkonverti ostatni blbosti (inspicy, oldtaby..).
 Z verze 0.31..0.99 na verzi 1.xx..2.xx.
 ---------------------------------------------------------------------------}
Procedure TDMText.TransOthers(resizeNadpisy:boolean);
var   st:string;
      modif1,modif2:string[15];
      name:PathStr;
      x,y,z,xx,yy,len,del:word;
      bard,big,drawer:byte;
      now_slpmid:integer;
      insidesvis:boolean;
      add_tab:boolean;
      add_dwn:boolean;
      add_rov:boolean;
const oldROVNALINE ='Ä';
      oldSVISLALINE='³';
      oldTAB       ='@';
      oldINSPIC    ='~';
      oldCHECKBOX  ='þ';
      oldASKSYMBOL =':';
      oldINSBIGCHAR='|';
      oldINSBUTTON ='';
      oldMRAMOR    ='§';
      oldTABULKA   ='“';
      resiz        ='50';
label test_endofline;
begin
 GoZaheader3;
 insidesvis:=false;
 add_tab:=false;
 add_dwn:=false;
 add_rov:=false;
 while word(Pos)<konec do begin
   st:=nlGet;
   if length(st)>0 then case st[1] of
     cmdINIT:
       {*sux pokud je togl v zavesenym sloupci}
       if st[2]=cmdNEWSLP then now_slpmid:=stringy.GetNum(st,2);
     oldROVNALINE:
       begin
       if insidesvis then begin add_rov:=true;InsStr(word(Pos),1,'');end
                     else InsStr(word(Pos),1,cmdINIT+cmdROVNALINE+cmdDONE);
       add_tab:=true;
       goto test_endofline;
       end;
     oldSVISLALINE:
       begin
       if not insidesvis then add_dwn:=true
                         else InsStr(word(Pos),0,cmdINIT+cmdRESIZE+'-10,10'+cmdDONE);
       InsStr(word(Pos),1,cmdINIT+cmdSVISLALINE+cmdDONE);
       insidesvis:=not insidesvis;
       add_tab:=true;
      test_endofline:
       if not (pos^ in [oldROVNALINE,oldSVISLALINE]) then begin
         if add_rov then begin add_rov:=false;InsStr(word(Pos),0,cmdINIT+cmdROVNALINE+cmdDONE);end;
         if add_dwn then begin add_dwn:=false;InsStr(word(Pos),0,cmdINIT+cmdRESIZE+'10,-10'+cmdDONE);end;
         if add_tab then begin add_tab:=false;InsStr(word(Pos),0,TAB);end;
         end;
       continue;
       end;
     oldTAB:
       InsStr(word(Pos),1,TAB);
     oldINSPIC:
       begin
       len:=length(st);
       name:=CutString(st,'(');
       if st='' then begin
         {za jmenem obrazku nenasleduje (sirka,vyska), musime je zjistit}
         picGetInfo(copy(name,2+ord(name[2] in ['.','-']),255),z,x,y);
         end
       else begin
         x:=CutNum(st);
         y:=CutNum(st);
         end;
       case name[2] of
         '.': begin xx:=x div 2;yy:=y;  del:=2;end;
         '-': begin xx:=x;      yy:=y;  del:=2;end;
         else begin xx:=x;      yy:=y*2;del:=1;end;
         end;
       Delete(name,1,del);
       InsStr(word(Pos),len,cmdINIT+cmdINSPIC+name+','+
              stri(xx)+'x'+stri(yy)+cmdDONE);
       end;
     oldCHECKBOX:
       begin
       name:=cmdINIT+cmdCHECKBOX+stri(94-now_slpmid)+',0,12,16';
       if st[2]='('
        then InsStr(word(Pos),system.pos(')',st),name+','+copy(st,3,system.pos(')',st)-3)+cmdDONE)
        else InsStr(word(Pos),1,name+cmdDONE);
       end;
     oldASKSYMBOL:{*};
     oldINSBIGCHAR,
     oldINSBUTTON:
       begin
       {what size}
       if st[3]='-'
         then bard:=1
         else begin bard:=0;if (st[2]<'a') then big:=1 else big:=0;end;
       {what modifier}
       modif2:=chgINIT+chgCOL;{*vzdy nastavi color 1}
       if (bard=0) then begin
         if st[2]<'a' then drawer:=ord(st[2])-ord('A')
                      else drawer:=ord(st[2])-ord('a');
         modif1:=chgINIT+chr(ord(chgCOLbig)+drawer);
         end
        else
         if (st[2]='a') then modif1:=chgINIT+chgCOLbard
                        else begin modif1:='';modif2:='';end;
       {resizne sloupec kolem nadpisu, ktery se driv nezarovnavaly}
       modif2:=modif2+newln;
       if resizeNadpisy then begin
         modif1:=cmdINIT+cmdRESIZE+'-'+resiz+'+'+resiz+cmdDONE+modif1;
         modif2:=modif2+cmdINIT+cmdRESIZE+'+'+resiz+'-'+resiz+cmdDONE;
         end;
       {insert commands}
       InsStr(word(Pos),2+bard-1,modif1+chgINIT);
       if bard=1 then PutSetFontMark(oldBARD) else
        if big=1 then PutSetFontMark(oldBIG)
                 else PutSetFontMark(oldBIGPUL);
       if st[1]=oldINSBUTTON then begin
         nlGoto(+1);
         InsStr(word(Pos)-length(newln),length(newln),chgINIT+chgLINK);
         end;
       nlGoto(+1);
       dec(pos,length(newln));
       InsStr(word(Pos),length(newln)-1,chgINIT);
       PutSetFontMark(oldNORMAL);
       InsStr(word(Pos)+1,0,modif2);
       chGoto(cmdDONE,+1);{jde za resize}
       continue;{vyhne se prechodu na novy radek}
       end;
     oldMRAMOR:{*};
     oldTABULKA:{*};
     END;
   nlGoto(+1);
   end;
end;

{---------------------------------------------------------------------------
 Zkonverti CHGFNTy.
 Z verze 0.31..0.99 na verzi 1.xx..2.xx.
 ---------------------------------------------------------------------------}
Procedure TDMText.TransChgfnts;
var   st                        :string;
      fDabl                     :boolean;
      fDablbold                 :boolean;
const oldchgINIT                ='`';
      oldchgCOL                 ='a';
      oldchgCOLz                =chr(ord(oldchgCOL)+3);
      oldchgDABL                ='e';
      oldchgDABLBOLD            ='f';
begin
 fDabl:=false;
 fDablbold:=false;
 {zkonverti headery sloupcu a nektere spec.znaky}
 GoZaheader3;
 while word(Pos)<konec do begin
   case Pos^ of
     oldchgINIT:
       begin
        Pos^:=chgINIT;
        inc(Pos);
        case Pos^ of oldchgCOL..oldchgCOLz:
                       Pos^:=chr(ord(Pos^)-ord(oldchgCOL)+ord(chgCOL));
                     oldchgDABL:
                       begin
                       if fDabl then PutSetFontMark(oldNORMAL)
                                else PutSetFontMark(oldDABL);
                       fDabl:=not fDabl;
                       end;
                     oldchgDABLBOLD:
                       begin
                       if fDablbold then PutSetFontMark(oldNORMAL)
                                    else PutSetFontMark(oldDABLBOLD);
                       fDablbold:=not fDablbold;
                       end;
                     else
                       Pos^:=chgFNT;
                     end;
       end;
     END;
   inc(Pos);
   end;
end;

{---------------------------------------------------------------------------
 Zkonverti CHKBOXy na SCRIPTy.
 Z verze 1.xx na verzi 2.xx.
 ---------------------------------------------------------------------------}
Procedure TDMText.TransChkbox;
var st:string;
    cmdlen:word;
    dxmid2left,dytop2top,sir,vys:integer;
    smp0,smp1,rip:FileStr;
begin
 GoZaheader3;
 repeat
   chGoto(cmdINIT,+1);
   if Eof then break;
   if pos^=cmdCHECKBOX then begin
     Skip(1);
     st:=chGet(cmdDONE);
     cmdlen:=length(st)+1;
     dxmid2left:=CutNum(st);
     dytop2top:=CutNum(st);
     sir:=CutNum(st);
     vys:=CutNum(st);
     delete(st,1,1);
     smp0:=CutName(st);
     smp1:=CutName(st);
     rip:=CutName(st);
     if rip<>''
      then st:='!rip.scr '+rip
      else begin
        if smp1<>'' then st:=' '+smp1;
        if smp0<>'' then st:=' '+smp1+st;
        st:='!chkbox.scr 0'+st;
        end;
     InsStr(word(pos)-1,cmdlen,cmdSCRIPT+'!move.scr '+stri(dxmid2left)+' '+
       stri(dytop2top)+' '+stri(sir)+' '+stri(vys)+' '+st);
     end;
 until false;
end;

{---------------------------------------------------------------------------
 Zkonverti obrazky odkazujici nekam.
 Z verze 1.xx na verzi 2.xx.
 ---------------------------------------------------------------------------}
Procedure TDMText.TransPicHref;
var i:integer;
begin
 GoZaheader3;
 repeat
   chGoto(cmdINIT,+1);
   if Eof then break;
   if pos^=cmdINSPIC then begin
     {skip name}
     chGoto(',',+1);
     {skip size}
     for i:=1 to 2 do
      repeat inc(pos) until not (pos^ in ['0'..'9']);
     {ins href=}
     if pos^<>cmdDONE then InsStr(word(pos),1,',href=');
     end;
 until false;
end;

{---------------------------------------------------------------------------
 Prijme jakykoliv text ve writeru, vystupem je text aktualni verze
 nebo nastavi do result chybu.

 Do verzi 0..49 prida template or ! podle flagu dmtfAddTemplate.
 Do verzi 100..199 prida template or ! podle toho zda stranka je template.
 ---------------------------------------------------------------------------}
Function TDMText.AdjustVersion(flags:word;var result:TError):word;
var   wantsir:word;
      i:word;
      p:pchar;
      t:FileStr;
      addtemp:boolean;
begin
 {nacte headerinfo}
 Reset;
 {zkontroluje verzi}
 if FileSize=0 then i:=0 else i:=HeaderVersion(nlGet);
 AdjustVersion:=i;
 {budeme nastavovat template?}
 addtemp:=((flags and dmtfThisIsTemp)=0) and (GetHeader('tem:')='');
 {overi zda implicitni template existuje a kdyztak nahlasi chybu}
 if addtemp then begin
   t:='template';
   if not fileExists(t) then begin
     if (flags and dmtfRepMisTemp)>0 then ReportErr(_(_erChybiSoub)+' '+t+'.');
     addtemp:=false;
     end;
   end;
 case i of
   0..30:begin
        {prekoduje cestinu}
        csSetPreferred;
        csClearHits;
        while not eof do begin
          csHit(pos^);
          inc(pos);
          end;
        csSetCoding;
        Reset;
        while not eof do begin
          csXlat(pos^);
          inc(pos);
          end;
        Reset;
        csClearHits;
        if addtemp then LoadThisTemplate(flags,'template');
        {zjisti jak velka by nova stranka mela byt}
        if mytemplate=nil
         then wantsir:=640
         else wantsir:=stringy.GetNum(mytemplate^.GetHeader('siz:'),1);
        {podle toho udela velkou stranku a prvni sloupec}
        InsStr(start,0,
               idmpage+verze+newln+
               'siz:'+stri(wantsir)+'x480'+newln+
               cmdINIT+cmdNEWSLP+'0,'+stri(wantsir div 2)+',0,'+stri(wantsir*4 div 5)+cmdDONE+newln+newln);
        if mytemplate=nil then begin
          SetHeader('res:','640x480');
          SetHeader('fnt:',fnDefault);
          {SetHeader('tex:','b');
          st[0]:=#120;
          for i:=1 to 120 do st[i]:=chr(32+defaultPal40[2+i]);
          SetHeader('pal:',st);{*}
          end;
        if addtemp then SetHeader('tem:','template');
        LoadTemplate(flags);
        end;
   31..49:begin
        {pri konverzi nesmi byt pritomen template}
        TransPageHeader;
        TransTex;
        TransNewslpHeaders;
        TransOthers((flags and dmtfResizeNadp)>0);
        TransChgfnts;
        TransChkbox;
        if addtemp then SetHeader('tem:','template');
        LoadTemplate(flags);
        end;
   100..199:begin
        TransChkbox;
        TransPicHref;
        if addtemp then SetHeader('tem:','template');
        LoadTemplate(flags);
        InsStr(start+idmpagelen,length(verze),verze);
        end;
   200..compatto:begin
        LoadTemplate(flags);
        InsStr(start+idmpagelen,length(verze),verze);
        end;
   else result:=_erNovejsiFormat;
   end;
end;

{---------------------------------------------------------------------------
 Pokud to jde, nahraje template.
 ---------------------------------------------------------------------------}
Procedure TDMText.LoadThisTemplate(flags:word;template:PathStr);
var templateResult:TError;
begin
 templateResult:=erLowMem;
 New(mytemplate,Init(0,nil,template,flags or dmtfThisIsTemp or dmtfNoChkFonts,templateResult));
 if templateResult<>erOk then ReportErr(_(templateResult));
end;
{---------------------------------------------------------------------------
 Pokud to jde, nahraje template.
 ---------------------------------------------------------------------------}
Procedure TDMText.LoadTemplate(flags:word);
var templateResult:TError;
begin
 if (mytemplate=nil) and
    ((flags and dmtfNoTemplate)=0) and
    (GetHeader('tem:')<>'') and
    (GetHeader('tem:')<>'!'){ and
    (GetHeader('tem:')<>name)} then begin
      templateResult:=erLowMem;
      New(mytemplate,Init(0,nil,GetHeader('tem:'),
        (flags and not dmtfCreatePage) or dmtfThisIsTemp or dmtfNoChkFonts,templateResult));
      if templateResult<>erOk then ReportErr(_(templateResult));
      end;
end;

{---------------------------------------------------------------------------
 Je-li txStart=nil a name='', vytvori prazdny text velikosti rezervy.
 Je-li txStart<>nil, prijme tento text v bloku od txStart do maxend.
  Volat az kdyz je text na miste.
 Je-li name<>'', nahraje text ze souboru, vystup chyba nebo text ery 3.
 Hodi ukazatel na start.
 ---------------------------------------------------------------------------}
var vnoreni:word;
Constructor TDMText.Init(txSize:longint;txStart:pointer;name:PathStr;flags:word;var result:TError);
var   rezerva:longint;
      staticmem:boolean;
      templateResult:TError;
      tstart:word;
Begin
 {ochrana proti zacykleni v templatech}
 if (flags and dmtfThisIsTemp)=0 then vnoreni:=0 else begin
   inc(vnoreni);
   if vnoreni>6 then begin
     result:=_erCyklickyTemp;
     Fail;
     end;
   end;

 {je pamet staticka?}
 staticmem:=txStart<>nil;

 {zaridi aby byl na txStart text, txSize jeho delka a rezerva rezerva za nim}
 if (name='') or (((flags and dmtfCreatePage)>0) and (not fileExists(name))) then begin
   if txStart=nil then begin
      {nemam pamet ani text}
      if not GetMem(txStart,txSize) then begin result:=erLowMem;Fail;end;
      rezerva:=txSize;
      txSize:=0;
      end else
   if name='' then begin
      {mam pamet a v ni text}
      rezerva:=txSize-StrLen(txStart);
      txSize:=StrLen(txStart);
      end
   else begin
      {mam prazdnou pamet}
      rezerva:=txSize;
      txSize:=0;
      end;
   end
  else begin
   {mam nahrat text ze souboru}
   if txSize=0
    then rezerva:=4000{napr export2html credits pridava hodne dat a vyzaduje tedy velkou rezervu}
    else rezerva:=0;
   if not fileLoad(name,nil,txStart,txSize,rezerva) then begin result:=_erFileLoad;Fail;end;
   end;
 if rezerva<1000 then begin result:=_erLowBuffer;Fail;end;

 {na konec hodi #0}
 PLine(txStart)^[txSize]:=0;

 {init self}
 inherited Init(txStart,txSize+rezerva);
 static:=staticmem;
 SlpReset;

 {upravi text do nejnovejsi verze formatu}
 {nahraje pritom template}
 result:=erOk;
 if PathSlice(name,psFile)='TEMPLATE'
  then AdjustVersion(flags or dmtfThisIsTemp,result)
  else AdjustVersion(flags,result);
 if result<>erOk then begin
    Done;
    Fail;
    end;

 {nacte blkStart/End jeste nez ty offsety povore editaci stranky}
 tstart:=textStart;
 blkStart:=valu(paramGet(GetHeader('pos:'),'blkStart'))+tstart;
 blkEnd:=valu(paramGet(GetHeader('pos:'),'blkEnd'))+tstart;

 {zkontroluje jestli je header (i s includnutim template) uplny}
 if (flags and dmtfNoTemplate)=0 then
  if (GetHeader('res:')='')
  or (GetHeader('siz:')='')
  or (GetHeader('fnt:')='') then begin
    result:=_erNeuplnyHeader;
    Done;
    Fail;
    end;

 modified:=false;
 if ((flags and dmtfNoChkFonts)=0) and not FontsReady then begin
   result:=_erBadFont;
   Done;
   Fail;
   end
 else
   result:=erOk;

 okForced:=ok_none;
End;

{---------------------------------------------------------------------------
 Mrkne se, zda ma vsechny fonty.
 ---------------------------------------------------------------------------}
Function TDMText.FontsReady:boolean;
var fonts:string;
    font:PathStr;
begin
 FontsReady:=true;
 fonts:=GetHeader('fnt:');
 while fonts<>'' do begin
   font:=CutName(fonts);
   if not fileExists(font) then begin
     ReportErr(_(_erChybiSoub)+' '+font+'.');
     FontsReady:=false;
     end;
   end;
end;

{---------------------------------------------------------------------------
 Ulozi text do souboru pokud byl modifikovan.
 ---------------------------------------------------------------------------}
Function TDMText.Save(name:PathStr):TError;
begin
 Save:=erOk;
 if modified then
  if fileSave(fileOverwrite,name,startPtr,FileSize) then modified:=false
   else Save:=_erFileSave;
end;

{---------------------------------------------------------------------------
 Hu.
 ---------------------------------------------------------------------------}
Destructor TDMText.Done;
begin
 KillObj(mytemplate);
 inherited Done;
end;


{°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°INIT/DONE°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°}

const unita='dmtext';
var result:TError;

procedure UserInit;
 begin
  {$ifdef edit}
  New(edofs);
  New(scrx);
  New(scry);
  {$endif}
 end;

procedure UserDone;
 begin
  {$ifdef edit}
  Dispose(scry);
  Dispose(scrx);
  Dispose(edofs);
  {$endif}
 end;

{$i initdone.inc}
{$ifdef autoinit}
BEGIN
 erCheck(Init);
{$endif}
END.
