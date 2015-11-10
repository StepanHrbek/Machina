Unit      DMParser;
Interface {$i define.inc}
Uses      Chyby, Objects,Dos, Stringy,Fajly,DMFile;

Function  Init:TError;
Procedure Done;

Type      PFile=^TFile;
          TFile=object(TObject)
            fajle       :FileStr;{staci ukladat bez cesty, ta se pak locatne}
            size        :longint;
            typ         :byte;
            dosazitelnej:boolean;
            constructor Init(afajl:PathStr;atyp:byte);
            destructor  Done;virtual;
           end;

          TFileList=object(TCollection)
            sizein      :longint;
            sizeout     :longint;
            procedure   AddFiles(typ:word;fajly:string);
            procedure   AddPreflicFor(fajl:PathStr);
            procedure   SubFiles(atyp:byte);
            function    JeDosazitelnej(afajl:PathStr):boolean;
            procedure   JeDosazitelnejFatal(afajl:PathStr);
            procedure   JeDosazitelnejTemplate(afajl:PathStr);
           end;

          PFilelistCollection=^TFilelistCollection;
          TFilelistCollection=object(TStringCollection)
           constructor Init(list,oznameni:PathStr);
           function    Contains(st:PathStr):boolean;
          end;

Var       lst           :TFileList;
          lib           :PFilelistCollection;
          {$ifdef big}
          big           :PFilelistCollection;
          {$endif}
          reportFile    :TReporter;
          reportProb    :TReporter;
          reportInfo    :TReporter;

{$ifdef kod}
Procedure kod_Zahaj;
Procedure kod_Zmen(st:string);
Function  kod_Vrat:string11;
Function  kod_Heslo(kod:string11):string11;
Procedure kod_Caruj;
Function  kod_Ok:boolean;
{$endif}

Const     delta=100;
          typ_pic=1; typ_dulezitejpic=delta+typ_pic; typ_nedulezitejpic=2*delta+typ_pic;
          typ_cla=2;{vsechny stranky}
          typ_rip=3;{v toglu ripnutelne fajly}
          typ_sam=4;{samply}
          typ_mod=5;{moduly}
          typ_fnt=6;{font}
          typ_ani=7;{animace pred strankou (ne na linku nebo na strance)}
          typ_scr=8;{skript}
          typ_unk=9;{unknown}

PROCEDURE probAdd(st:string);
FUNCTION  probShow:boolean;
PROCEDURE probFree;

PROCEDURE AddPageSupport(item:PFile;prj:TPrjs;pages_inserted,add_subpages,expand_templates:boolean);
PROCEDURE AddPagesSupport(prj:TPrjs;pages_inserted,add_subpages,expand_templates:boolean);


Implementation
Uses      Memo, Sys,Loadery,Textury,
          DMText,DMScript,DMAtoms,Supp;


{================================TOOLS===================================}

const wait          :boolean=false;
      {$ifdef kod}
      wait2         :word=0;
      wait3         :word=0;
      maxfiles      =500;
      {$endif}
      smallthing    :longint=30000;{jak velke obrazky jeste zaradi do prvniho DM}
      bigthing      :longint=500000;{jak velke soubory uz neda do prvniho}
      {$ifdef big}
      bigpicdir     ='big';
      bigpic2dir    ='big\zaloha';

      _msgPresunJPG,
      _anone,
      _AaNn,
      _ma,
      _melbymit,
      _msgMaloKompr,

      M m slabˆ komprimovan‚ JPG p©esunout do adres ©e
      (Ano/Ne)
      AaNn
      m 
      mˆl by m¡t
      m lo zkomprimov n

      Move poorly compressed (too big!) JPGs to directory
      (Yes/No)
      YyNn
      has
      should have
      poorly compressed
      {$endif}

var   linkComesFrom :PathStr;


procedure myReportProb(prob:string);
begin
 if @reportProb<>nil then reportProb(prob);
 wait:=true;
end;

procedure myReportInfo(info:string);
begin
 if @reportInfo<>nil then reportInfo(info);
end;


FUNCTION MoreInfo:string;
begin
 if linkComesFrom='' then MoreInfo:='.' else
  MoreInfo:=_i(_msgVedeNaNejLinkZ,linkComesFrom)
end;


{===============================LIBRARY=================================}

Constructor TFilelistCollection.Init(list,oznameni:PathStr);
var f:text;
    st:PathStr;
begin
 if not inherited init(100,100) then Halt(erLowMem);
 assign(f,list);
 reset(f);
 if ioresult<>0 then exit;
 while not eof(f) do begin
   readln(f,st);
   st:=locased(PathSlice(st,psFile));
   Insert(NewStr(st));
   myReportInfo(oznameni+' '+st+'.');
   end;
 myReportInfo('');
 close(f);
end;

Function TFilelistCollection.Contains(st:PathStr):boolean;
  function matches(p:pstring):boolean;far;
  begin
   matches:=p^=st;
  end;
begin
 st:=locased(PathSlice(st,psFile));
 Contains:=FirstThat(@matches)<>nil;
end;


{================================CODINK==================================}
{$ifdef kod}
const kodlen=8;
var   kod:string[kodlen];
      kodpos:byte;
      kodboo:array[1..kodlen] of boolean;
      kody:array[0..8] of string11;

Procedure kod_Zahaj;
var i:integer;
begin
 randseed:=123456789;
 kod[0]:=chr(kodlen);
 kodpos:=1;
 for i:=1 to kodlen do kod[i]:=chr(random(256));
 randomize;
 for i:=1 to kodlen do kodboo[i]:=false;
end;

Procedure kod_Zmen(st:string);
var i:integer;
begin
 for i:=1 to length(st) do begin
   kod[kodpos]:=char(ord(kod[kodpos])+ord(st[i])+random(210));
   if kodpos<kodlen then inc(kodpos) else kodpos:=1;
   end;
end;

Function kod_Vrat:string11;
var i:integer;
begin
 for i:=1 to kodlen do kod[i]:=chr(Wrapped(ord(kod[i]),ord('A'),ord('Z')));
 kod_Vrat:=kod;
end;

Function kod_Heslo(kod:string11):string11;
var i,j,k:integer;
    Year, Month, Day, DayOfWeek:word;
    l:longint;
    f:file;
    S:PathStr;
    ini:DateTime;
    res:string11;
begin
 GetDate(Year, Month, Day, DayOfWeek);
 s:=FSearch('system.ini',GetEnv('path'));
 l:=0;
 if s<>'' then begin
   assign(f,s);
   reset(f);
   GetFTime(f,l);
   close(f);
   UnpackTime(l,ini);
   if (year<ini.year) or (month<ini.month) or (day<ini.day)
   or (longint(year)*365+month*30+day > longint(ini.year)*365+ini.month*30+ini.day+14) then
    else l:=longint(year)*12345+longint(month)*2345+longint(day)*345;
   end;
 for i:=1 to kodlen do res[i]:=#39;
 res[0]:=chr(kodlen);
 for i:=1 to kodlen do begin
   randseed:=ord(kod[i]);
   for j:=1 to 95 do begin
     k:=Wrapped(random(299),1,kodlen);
     res[k]:=chr(Wrapped(ord(res[k])+ord(kod[Wrapped(random(199),1,kodlen)])+random(195)+l shr i,ord('a'),ord('z')));
     end;
   end;
 randomize;
 kod_Heslo:=res;
end;

Procedure kod_Caruj;
begin
 kody[3]:=kod_Vrat;
 move(kody[1],kody[2],5*sizeof(kody[1]));
 move(kody[3],kody[5],5*sizeof(kody[1]));
 if (lst.count+5>maxfiles+5) then begin
   kodboo[2]:=true;
   if readkey=#9 then begin
     BiosWrite(kody[6]);
     readln(kody[6]);
     end;
   end;
 if kodboo[2] then begin
   move(kody[4],kody[1],4*sizeof(kody[1]));
   kodboo[7]:=kody[3]=kod_Heslo(kody[1]);
   end;
end;

Function kod_Ok:boolean;
var i:integer;
begin
 kod_Ok:=false;
 for i:=kodlen div 2 to kodlen do if kodboo[i] then kod_Ok:=true;
end;
{$endif}

{=============================PROBLEM_LIST===============================}

var   prob:TStringCollection;
      {$ifdef big}
      big2dir:shortint;
      {$endif}

procedure probAdd(st:string);
begin
 prob.Insert(NewStr(st));
end;

function probShow:boolean;
 procedure print(item:Pstring);far;
 var st:PathStr;
     f:file;
 begin
  myReportProb(item^);
  {$ifdef big}
  if item^[length(item^)]=#0 then begin
    if big2dir=0 then begin
      myReportInfo(_(_msgPresunJPG)+' '+bigpicdir+'? '+_(_anone));
      if pos(AskKey(_(_AaNn)),_(_AaNn))<=2 then big2dir:=1 else big2dir:=-1;
      if big2dir=1 then
       if not dirMake(bigpicdir) or not dirMake(bigpic2dir) then begin
         big2dir:=-1;
         end;
      end;
    if big2dir=1 then begin
      st:=copy(item^,1,pos(' ',item^)-1);
      fileCopy(fileOverwrite,st,bigpicdir +PathSlice(st,psSlash+psFile));
      fileMove(fileOverwrite,st,bigpic2dir+PathSlice(st,psSlash+psFile));
      end;
    end;
  {$endif}
 end;
begin
 probShow:=false;
 if prob.count>0 then begin
   prob.ForEach(@print);
   prob.FreeAll;
   probShow:=true;
   end;
end;

procedure probFree;
begin
 prob.FreeAll;
end;


{================================FILELIST==================================}

Function DetectType(afajl:PathStr):byte;
var flags:word;
begin
 flags:=fileIs(afajl);
 if (flags and isSample   )>0 then DetectType:=typ_sam else
 if (flags and isModule   )>0 then DetectType:=typ_mod else
 if (flags and isScript   )>0 then DetectType:=typ_scr else
 if (flags and isHypertext)>0 then DetectType:=typ_cla else
 if (flags and isPlayable )>0 then DetectType:=typ_ani else
 if (flags and isGraphics )>0 then DetectType:=typ_pic else
 if (flags and isFont     )>0 then DetectType:=typ_fnt else
                                   DetectType:=typ_rip;
end;

{neplati bere i nedekodovana jmena}
{bere jen uplne dekodovana jmena}
Constructor TFile.Init(afajl:PathStr;atyp:byte);
var model,x,y:word;
    cursize,minsize,maxsize,badsize:word;
    info:string[50];
begin
 inherited Init;
 fajle:=locased({DecodePic}(afajl));
 if atyp=typ_unk then atyp:=DetectType(fajle);
 typ:=atyp;
 {$ifdef kod}
 kod_Zmen(fajl);
 {$endif}
 if (lib<>nil) and lib^.Contains(fajle) then exit;
 if (fajle='') or not fileExists(fajle) then begin
   probAdd(_(_erChybiSoub)+' '+fajle+MoreInfo);
   exit;
   end;
 size:=fileSize(fajle);
 dosazitelnej:=PathSlice(fajle,psName)=title;
 inc(lst.sizein,size);

 {$ifdef big}
 if big<>nil then
  if PathSlice(fajle,psExt)='JPG' then
   if picGetInfo(fajle,model,x,y) then begin
    cursize:=size div 1024;
    minsize:=longint(x)*y div 1024 div 10;
    maxsize:=longint(x)*y div 1024 div 4;
    badsize:=longint(x)*y div 1024 div 3+10;
    info:=_(_ma)+' '+stri(cursize)+' KB, '+_(_melbymit)+' '+stri(minsize)+'..'+stri(maxsize)+' KB';
    if (cursize>badsize) and (not big^.Contains(fajl))
     then probAdd(fajle+' '+_(_msgMaloKompr)+', '+info+'.'#0);
    end;
 {$endif}
end;

Destructor TFile.Done;
begin
 if @reportFile<>nil then reportFile(fajle);
 if (typ=typ_cla) and not dosazitelnej
  then myReportProb(_i(_msgNezarazenaStr,fajle));
 dec(lst.sizein,size);
 inc(lst.sizeout,size);
end;

Procedure TFileList.AddFiles(typ:word;fajly:string);
var st:PathStr;
 function Matches(item:PFile):boolean;far;
 begin
  matches:=item^.fajle=st;
 end;
begin
 while fajly>'' do begin
   st:=LoCased(CutName(fajly));
   myReportInfo('  -> '+st);
   st:=locased(DecodePic(st));
   if ((lib=nil) or not lib^.Contains(st)) and (FirstThat(@Matches)=nil)
    then Insert(New(PFile,Init(st,typ)));
   {$ifdef kod}
   kodboo[5]:=23+count<=23+maxfiles;
   {$endif}
   end;
end;

Procedure TFileList.AddPreflicFor(fajl:PathStr);
begin
 fajl:=fileFind(PathSlice(fajl,psPath+psName),isGraphics+isPlayable);
 if fajl<>'' then begin
   lst.AddFiles(typ_ani,fajl);
   lst.AddFiles(typ_sam,fileFind(PathSlice(fajl,psPath+psName),isSample));
   end;
end;

Procedure TFileList.SubFiles(atyp:byte);
var   i:word;
begin
 if count>0 then
  for i:=count-1 downto 0 do
   with PFile(items^[i])^ do
    if (typ=atyp) and (size<bigthing) then AtFree(i);
end;

{je dosazitelnej?}
Function TFileList.JeDosazitelnej(afajl:PathStr):boolean;
var   i:word;
begin
 JeDosazitelnej:=true;
 LoCasni(afajl);
 if (lib<>nil) and lib^.Contains(afajl) then exit;
 if count>0 then
  for i:=count-1 downto 0 do
   with PFile(items^[i])^ do
    if (fajle=afajl) then begin dosazitelnej:=true;exit;end;
 JeDosazitelnej:=false;
end;

{kdyz neni dosazitelnej, hlas to}
Procedure TFileList.JeDosazitelnejFatal(afajl:PathStr);
begin
 if not JeDosazitelnej(afajl)
  then probAdd(_(_erChybiSoub)+' '+afajl+MoreInfo);
end;

{kdyz neni nastaven nebo dosazitelnej, hlas to}
Procedure TFileList.JeDosazitelnejTemplate(afajl:PathStr);
begin
 if afajl<>'!' then
  if afajl='' then {probAdd(_(_erTemplateNenastaven)+MoreInfo)}
   else JeDosazitelnejFatal(afajl);
end;


{================================PARSER==================================}


PROCEDURE AddPagesupport(item:PFile;prj:TPrjs;pages_inserted,add_subpages,expand_templates:boolean);

  procedure AddSlide(first:PathStr);
  begin
   while first<>'' do begin
     lst.AddPreflicFor(first);
     lst.AddFiles(typ_nedulezitejpic,first);
     SetDefaultPageName(first);
     first:=GetNextSlidePic;
     end;
  end;

  procedure AddLink(link:string;reporter:TReporter);
  var flags:word;
      list:string;
  begin
   if link='' then exit;
   {stranka: vsechny existujici jazykove mutace; a kdyz nejsou tak jednu neexistujici}
   {obrazek: jeden jediny obrazek s nejlepsim formatem; a kdyz neni tak neexistujici, klidne .pic}
   {skript: vsechny potrebne fajly, i neexistujici}
   list:=AllLinkDestinations(reporter,link);
   {zda se ze ted skriptu pridal vsechno i kdyz add_subpages=false,
    ale skutecnost je takova ze subpages proste nepridal,
    nechapu proc ale udelal to spravne}
   while list<>'' do begin
     link:=CutName(list);
     flags:=fileIs(link);
     if (flags and isHypertext)>0 then begin
       if add_subpages then
        if pages_inserted
         then lst.JeDosazitelnejFatal(link)
         else begin
              lst.AddFiles(typ_cla,link);
              lst.JeDosazitelnej(link);
              end;
       end else
     if (flags and (isLoadable{+isGraphics}))=isLoadable{+isGraphics} then AddSlide(link)
     else lst.AddFiles(typ_unk,link);
     end;
  end;

  procedure MakeEveryPicImportant(item:PFile);far;
  begin
   with item^ do
    if typ=typ_pic then
     typ:=typ_dulezitejpic;
  end;

  var smallpicsize:longint;
  procedure MakeSmallPicImportant(item:PFile);far;
  begin
   with item^ do
    if typ=typ_pic then
     if size<smallthing then typ:=typ_dulezitejpic else typ:=typ_nedulezitejpic;
  end;

var   e                    :TDMText;
      tem                  :PDMText;
      result               :TError;
      st1,st2              :string;
      i                    :word;
      ver                  :word;
      buttonuvtomhleclanku :word;
      obrazek              :FileStr;
      obrazekFound         :PathStr;
const dat:string[21]='CfembOfnftifhzjEfnfou';
label 1,2,3,4,5,6;
begin
 with item^ do
  if typ=typ_cla then begin

    linkComesFrom:=fajle;
    buttonuvtomhleclanku:=0;
    myReportInfo(' '+fajle);
    lst.AddPreflicFor(fajle);
    if dat[1]='C' then
     for i:=1 to 21 do dec(dat[i]);

    {zaradi a oznaci pristi stranku v serii za dosazitelnou}
    st1:=fajle;
    inc(st1[length(PathSlice(st1,psPath+psName))]);
    if fileExists(st1) then AddLink(st1,erIgnore{nervi kdyz neexistuje});
    {was:lst.JeDosazitelnej(st1);}

    {prida slideshow}
    SetDefaultPageName(fajle);
    AddSlide(GetNextSlidePic);

    {precte text z disku}
    e.Init(0,nil,fajle,ord(not expand_templates)*dmtfNoTemplate+dmtfNoChkFonts,result);
    erCheck(result);
    ver:=GetNum(e.GetHeader('nfo:'),1);
    if (ver<200) or (ver>compatto) then probAdd(_2(_msgStrankaNeniFit,fajle,verzestr));

    {do atomu naloaduje description}
    aLoadPagDescription(prj,GetDkod(fajle,true),@e);

    {zaradi templaty}
    if expand_templates then begin
      tem:=@e;
      while (tem<>nil) and (tem^.GetHeader('tem:')<>'!') do begin
        lst.AddFiles(typ_cla,tem^.GetHeader('tem:'));
        tem:=tem^.mytemplate;
        end;
      end;
    lst.JeDosazitelnejTemplate(e.GetHeader('tem:'));

    {najde soubory v promennych}
    lst.AddFiles(typ_mod,e.GetHeader('mus:'));
    lst.AddFiles(typ_sam,e.GetHeader('sin:'));
    lst.AddFiles(typ_sam,e.GetHeader('sou:'));
    lst.AddFiles(typ_sam,e.GetHeader('sen:'));
    lst.AddFiles(typ_sam,e.GetHeader('si1:'));
    lst.AddFiles(typ_sam,e.GetHeader('si2:'));
    lst.AddFiles(typ_sam,e.GetHeader('skr:'));
    st1:=e.GetHeader('tex:');
    case texType(st1) of
      't':begin
          2:
          cutstring(st1,'<');
          st2:=cutstring(st1,'>');
          if st2>'' then begin
           if st2[1]='*' then delete(st2,1,1);
           lst.AddFiles(typ_pic,st2);
           goto 2;
           end;
          end;
      'p':begin
          lst.AddFiles(typ_pic,paramGet(st1,'background'));
          end;
      end;
    lst.AddFiles(typ_fnt,e.GetHeader('fnt:'));

    {najde soubory v prikazech}
    e.Reset;
    e.EndPtr^:=cmdINIT;
    3:
    e.chGoto(cmdINIT,1);
    if not e.Eof then begin
      st1:=e.chRead(cmdDONE);
      case st1[1] of
        cmdINSPIC:begin
          delete(st1,1,1);
          obrazek:=CutString(st1,',');
          obrazekFound:=PathSlice(fileFind(obrazek,isGraphics),psFile);
          if obrazekFound='' then probAdd(_2(_msgObrPouzityNaNeex,obrazek,fajle));
          lst.AddFiles(typ_pic,obrazekFound);
          CutString(st1,',');
          AddLink(paramGet(st1,'href'),probAdd{rvi kdyz neexistuje});
          end;
        cmdSCRIPT:begin
          AddLink(copy(st1,2,255),probAdd{rvi kdyz neexistuje});
          inc(buttonuvtomhleclanku);
          end;
        end;
      goto 3;
      end;

    {najde linky}
    e.Reset;
    e.EndPtr^:=chgINIT;
    if PathSlice(fajle,psName)=title then begin
      st1:=menu;
      goto 5;
      end;
    4:
    e.chGoto(chgINIT,1);
    if not e.Eof then begin
      if e.pos^=chgLINK then begin
        st1:=e.chRead(chgINIT);
        delete(st1,1,1);
        5:
        inc(buttonuvtomhleclanku);
        AddLink(st1,probAdd{rvi kdyz neexistuje});
        end;
      goto 4;
      end;

    {$ifdef kod}
    e.Reset;
    while not e.Eof do begin
      if CmpBlock(@dat[16],e.Pos,6) then inc(wait3) else
      if CmpBlock(@dat[1],e.Pos,5) then inc(wait2) else
      if CmpBlock(@dat[6],e.Pos,10) then inc(wait2,2);
      inc(e.Pos);
      end;
    {$endif}

    if (buttonuvtomhleclanku>=3) or (PathSlice(fajle,psName)=title)
     then lst.ForEach(@MakeEveryPicImportant)
     else lst.ForEach(@MakeSmallPicImportant);

    e.Done;
    linkComesFrom:='';
    end;
end;

PROCEDURE AddPagesSupport(prj:TPrjs;pages_inserted,add_subpages,expand_templates:boolean);
var i:word;
begin
 i:=0;
 while i<lst.count do begin
   AddPageSupport(lst.items^[i],prj,pages_inserted,add_subpages,expand_templates);
   inc(i);
   end;
end;


{°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°INIT/DONE°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°}

const unita='dmparser';
var result:TError;

procedure UserInit;
 begin
  reportFile   :=nil;
  reportProb   :=nil;
  reportInfo   :=nil;
  linkComesFrom:='';
  lib          :=nil;
  {$ifdef big}
  big          :=nil;
  big2dir      :=0;
  {$endif}
  if lst.Init(1000,1000) then begin
    if prob.Init(100,100) then begin
      exit;
      end;
    lst.Done;
    end;
  result:=erLowMem;
 end;

procedure UserDone;
 begin
  KillObj(lib);
  {$ifdef big}
  KillObj(big);
  {$endif}
  lst.Done;
  prob.Done;
 end;

{$i initdone.inc}
{$ifdef autoinit}
BEGIN
 erCheck(Init);
{$endif}
END.