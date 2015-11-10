Unit      DMFile; {$i define.inc}

{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}
                             INTERFACE
{‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹}

Uses      Chyby,Memo,
          Dos,Objects,
          Stringy,Fajly,Sys,Loadery,DMScript,Dialogy ,Vga{jen kvuli ripu};

{FUNCTION  LoadDM(filename:PathStr):boolean;}

Function  Init:TError;
Procedure Done;

{$i data.inc}

CONST
      maxProjects        =100;
      maxDMs             =400;
      maxDMsInPrj        =10;
      maxObjs            =32767;

      menu               ='MENU';   {nazvy stranek s definovanym vyznamem}
      title              ='TITLE';

      defaultHomeDir     ='C:\DISKMAGS\DM\';
      parEnv             ='DM';     {nazev ctene dosove promenne}

VAR   inidir             :DirStr; {tam je ini file, anketni listky, tam se exportuje tga a txt, tam se implicitne ripuje}
      libdir             :DirStr;
      minVerze           :word;

      editmod            :boolean;

TYPE
      TDkod = longint;
      TPrjs = -1..maxProjects;
      TDMs  = -1..maxDMs;
      TObjs = -1..maxObjs;


      {--- FileBaze ---}
      PFB  =^TFB;
      TFB  =object
              name               :pstring;
              start              :longint;
              len                :longint;
              {function           id:pchar;
              destructor         Done;
             private
              idcache            :pchar;}
            end;
      PAFB =^AFB;
      AFB  =array[1..2000] of TFB;


      {--- DM file ---}
      PDM  =^TDM;
      TDM  =record
              medium             :string[20];
              fullfilename       :PathStr;
              projekt            :string[30];
              addonfor           :string[40];
              popisek            :string[5];
              verzeDM            :word;
              datetime           :longint;
              root               :boolean;
              last_exist_check   :boolean;
              bad                :boolean;
              checked            :boolean;
              loaded             :boolean;
              flags              :word;
              fajlu              :word;
              filebazeofs        :longint;
              firstfileofs       :longint;
              filebaze           :PAFB;
            end;


      {--- projekt ---}
      TPrj =object
              prjDMs             :Tdms;
              prjDMmain          :Tdms;{koliketej DM (ne kolikatej v DMlistu) je main}
              prjDM              :array[1..maxDMsInPrj] of Tdms;
              function           FirstDkod:TDkod;
              function           NextDkod:TDkod;
             private
              d                  :Tdms;
              f                  :word;
            end;

      PDkods=^TDkods;
      TDkods=object(TCollection)
        constructor Init;
        procedure   InsertDkod(Dkod:TDkod);
        procedure   InsertList(st:string);
        procedure   FreeItem(Item:Pointer);virtual;
        function    Random:TDkod;
      end;

VAR   LastopenLength     :LONGINT;
      openAlsoSystemFiles:boolean;

      now_project        :Tprjs;
      nezkompDM          :Tdms;
      systemDM           :Tdms;

      DMs                :Tdms;
      projects           :Tprjs;
      DM                 :array[1..maxDMs] of PDM;
      prj                :array[1..maxProjects] of Tprj;

      autorun_path       :PathStr;

      return2rundir      :boolean;

      Dirs               :TStringCollection;

CONST     dlgDoLoadDirs  =1 shl 16;
          dlgAllowNew    =1 shl 17;
          dlgNoCommon    =1 shl 18;
FUNCTION  dlgFile(flags:longint;popisek,mask,preselect:string):string;

FUNCTION  dirIns:DirStr;
FUNCTION  dirRun:DirStr;
FUNCTION  dirIni:DirStr;
FUNCTION  dirPrj:DirStr;

FUNCTION  fileFindInDirs(name:PathStr):PathStr;

{FUNCTION  LoadDMlist(filename:string):boolean;
FUNCTION  SaveDMlist(filename:string):boolean;}
PROCEDURE ScanDMs(all:boolean);
PROCEDURE FreeAllDMs;
PROCEDURE ResetNezkompDM;
FUNCTION  OpenDMFile(st:PathStr):boolean;
FUNCTION  OpenDkodFile(Dkod:TDkod):boolean;
FUNCTION  Data(Dkod:Tdkod):PFB;
FUNCTION  LoadDkodLocation(Dkod:Tdkod;var fileofs,filesize:longint):PathStr;
FUNCTION  Rip(ripDkod:Tdkod;dest:PathStr):boolean;
FUNCTION  GetDkod(filename:PathStr;errorifnotfound:boolean):TDkod;

FUNCTION  IsSystemPrj(p:TPrjs):boolean;
FUNCTION  IsNezkompPrj(p:TPrjs):boolean;
FUNCTION  GetSystemPrj:TPrjs;
FUNCTION  GetNezkompPrj:TPrjs;

{prace se soubory pomoci handlu, max 1 otevreny soubor}
{VAR       datahandle:word;{
FUNCTION  OpenFile(st:string):boolean;
FUNCTION  LengthFile:longint;}
FUNCTION  LocateFile(st:PathStr):PathStr;
FUNCTION  ReadFile(kam:pointer;len:word):word;
PROCEDURE SeekFileFromCur(okolik:longint);
PROCEDURE SeekFileFromStart(kam:longint);
FUNCTION  CloseFile:boolean;


type  PDMFileStream=^TDMFileStream;
      TDMFileStream=object(TStream)
        constructor   Init(Dkod:TDkod);
        function      GetPos:longint;virtual;
        function      GetSize:longint;virtual;
        procedure     Read(var buf;count:word);virtual;
        procedure     Seek(newpos:longint);virtual;
        destructor    Done;virtual;
       private
        filehandle    :word;
        size          :longint;
        pos           :longint;
      end;

FUNCTION DkodIs(Dkod:TDkod):word;

FUNCTION  CodeLink(link:string):string;
FUNCTION  DecodeLink(link:string;dialog:boolean):string;
Var       DecodeLinkHadDialog:boolean;
FUNCTION  DecodeInspic(name:PathStr):PathStr;
FUNCTION  DecodePic(name:PathStr):string;
FUNCTION  AllPageLinkDestinations(name:PathStr):string;
FUNCTION  AllLinkDestinations(reporter:TReporter;link:string):string;

{---------------------------------------------------------------------------
 Hvezdickova konvence.
 ---------------------------------------------------------------------------}
FUNCTION  hkIsOk(st:string):boolean;
FUNCTION  hkNalezi(prvek,mnozina:string):boolean;

{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}
                          IMPLEMENTATION
{‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹}


FUNCTION dlgFile(flags:longint;popisek,mask,preselect:string):string;
begin
 if flags and dlgDoLoadDirs=0 then flags:=flags or dlgDontLoadDirs else dec(flags,dlgDoLoadDirs);
 if flags and dlgAllowNew  =0 then flags:=flags or dlgForbidNew    else dec(flags,dlgAllowNew  );
 if flags and dlgNoCommon  =0 then mask:=libdir+';'+mask;
 dlgFile:=dlgSelector(
   (dlgRatherBig+dlgShowDetailTab+dlgShowDirectory+dlgSearchFromCursor) or
   flags,popisek,mask,preselect);
end;


Function TPrj.FirstDkod:TDkod;
begin
 d:=1;
 f:=1;
 FirstDkod:=NextDkod;
end;

Function TPrj.NextDkod:TDkod;
begin
 NextDkod:=0;
 if d<=prjDMs then
  with DM[prjDM[d]]^ do
   if f>fajlu then begin inc(d);f:=1;NextDkod:=NextDkod;end
    else begin NextDkod:=MakeLong(prjDM[d],f);inc(f);end;
end;


constructor TDkods.Init;
begin
 inherited Init(5,10);
end;

procedure TDkods.InsertDkod(Dkod:TDkod);
begin
 if Dkod<>0 then Insert(pointer(Dkod));
end;

procedure TDkods.InsertList(st:string);
begin
 while st<>'' do InsertDkod(GetDkod(CutName(st),true));
end;

function TDkods.Random:TDkod;
begin
 if count=0
  then Random:=0
  else Random:=TDkod(Items^[system.random(count)]);
end;

procedure TDkods.FreeItem(Item:Pointer);
begin
end;


{‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹ HVEZDICKOVA KONVENCE ‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹}

{---------------------------------------------------------------------------
 Vraci zda string neporusuje syntaxi rozsirene hvezdickove konvence.
 Syntaxe:
  ? - libovolny znak
  * - libovolny string, i prazdny
  [var1|var2|var3...] - jedna z uvedenych variant
  " - pouziva se k ohraniceni stringu, proto se nesmi vyskytovat uvnitr
  #0..#31 - tyto znaky jsou preventivne zakazany
 ---------------------------------------------------------------------------}
FUNCTION  hkIsOk(st:string):boolean;
var   zavorek:integer;
      i:word;
label bad;
begin
 hkIsOk:=false;
 zavorek:=0;
 for i:=1 to length(st) do
  case st[i] of '[':inc(zavorek);
                ']':if zavorek>0then dec(zavorek)else goto bad;
        #0..#31,'"':goto bad;
                '|':if zavorek=0then goto bad
                end;
 if zavorek<>0 then goto bad;
 hkIsOk:=true;
bad:
end;

{---------------------------------------------------------------------------
 Vraci zda prvek nalezi do mnoziny zadane rozsirenou hvezdickovou konvenci.
 Funkce predpoklada ze druhy parametr odpovida konvenci, nesnazi se
 detekovat nejake syntakticke chyby.
 Vysvetleni nazvu: *.bak je mnozina souboru, bagr.bak jeji prvek, a tahle
  funkce zjisti jestli prvek nalezi do mnoziny.
 ---------------------------------------------------------------------------}
FUNCTION hkNalezi(prvek,mnozina:string):boolean;
var   i,j,k,l,m:byte;
label ok;
begin
 hkNalezi:=false;
 if prvek=mnozina then goto OK;
 {odstrani sekvence hvezdicek, ktere zada vul snazici se zahltiti stack}
 for i:=length(mnozina) downto 2 do
  if (mnozina[i]='*') and (mnozina[i-1]='*') then delete(mnozina,i,1);

 if prvek='' then begin
   if mnozina[1]='*' then if hkNalezi('',copy(mnozina,2,255)) then goto OK;
   exit;
   end;

 for i:=1 to length(prvek) do
   if i>length(mnozina) then exit
   {---------------- obstara syntaxi * ---------------}
   else
   if mnozina[i]='*' then
     begin
     for j:=i to length(prvek)+1 do
      if hkNalezi(copy(prvek,j,255),copy(mnozina,i+1,255)) then goto OK;
     end
   {---------------- obstara syntaxi [|] ---------------}
   else
   if mnozina[i]='[' then
     begin
     {i <- pozice zacatku vyrazu: '['}
     {k <- pozice konce vyrazu: ']'}
     l:=0;
     for k:=i+1 to length(mnozina) do
      case mnozina[k] of '[':inc(l);
                         ']':if l>0 then dec(l) else break;
                         end;
     {j <- pozice zacatku substringu: '[' nebo '|'}
     j:=i;
     repeat
       {m <- pozice konce substringu: '|' nebo ']'}
       l:=0;
       for m:=j+1 to k do
        case mnozina[m] of '[':inc(l);
                           ']':if l>0 then dec(l) else break;
                           '|':if l=0 then break;
                           end;
       if hkNalezi(copy(prvek,i,200),copy(mnozina,j+1,m-j-1)+copy(mnozina,k+1,255)) then goto OK;
       j:=m;
     until mnozina[m]=']';
     exit;
     end
   {---------------- obstara syntaxi ? ---------------}
   else
   if (mnozina[i]<>prvek[i]) and (mnozina[i]<>'?') then exit;

 if not hkNalezi('',copy(mnozina,length(prvek)+1,255)) then exit;
ok:
 hkNalezi:=true;
end;




CONST commonDM      ='DM.DM';

VAR   lastAddedPrj       :Tprjs;

FUNCTION DriveOk(drive:char;medium:string):boolean;
begin
 {*kontrolovat medium, cachovat}
 driveOk:=dskReady(drive);
end;
FUNCTION DriveChangeable(drive:char):boolean;
begin
 DriveChangeable:=dskId(drive) in [dskFloppy,dskCdrom];
end;


FUNCTION dirIns:DirStr;
var   f:SearchRec;
      st:PathStr;
begin
 dirIns:=defaultHomeDir;
 if GetEnv(parenv)<>'' then begin
   st:=FExpand(GetEnv(parenv));
   if st[length(st)]='\' then dec(st[0]);
   FindFirst(st,anyfile,f);
   if (doserror=0) and ((f.attr and directory)>0) then dirIns:=st+'\';
   end;
end;

var rundir:DirStr;

FUNCTION  dirRun:DirStr;
begin
 dirRun:=rundir;
end;

FUNCTION  dirIni:DirStr;
begin
 dirIni:=inidir;
end;

FUNCTION  dirPrj:DirStr;
begin
 dirPrj:=PathSlice(DM[prj[now_project].prjDMmain]^.fullfilename,psPath);
end;


FUNCTION  fileFindInDirs(name:PathStr):PathStr;
  function DirFound(p:PString):boolean;far;
  begin
   fileFindInDirs:=p^+name;
   DirFound:=fileExists(p^+name);
  end;
begin
 if fileExists(name) then fileFindInDirs:=name
 else begin
   if (PathSlice(name,psDisk)<>'') or (name[1]='\'){name ma abs.cestu}
    or (Dirs.FirstThat(@DirFound)=nil) then fileFindInDirs:='';
   end;
end;

{‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹ SOUBORY: HANDLE ‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹}

VAR       datahandle:word;

{---------------------------------------------------------------------------
 Otevre soubor. Vraci uspesnost.
 ---------------------------------------------------------------------------}
FUNCTION  OpenFile(st:PathStr):boolean;
var x:word absolute st;
begin
 {kontrola zda to existuje.. device neexistuje}
 {zpomali kompilaci asi o 7%}
 if not dos_fileExists(st) then OpenFile:=false else begin
 {klasicke otevreni}
   Str2Pc(st);
   asm
    mov ax,3d00h;lea dx,x+1
    push ds;mov bx,ss;mov ds,bx;int 21h;pop ds
    jc @skip
    mov datahandle,ax
    @skip:
    cmc;sbb al,al;mov @result,al
   end;
   end;
end;

FUNCTION  LocateAndOpenFile(st:PathStr):PathStr;

  function LocalOpen(st2:PathStr):boolean;
  begin
   if OpenFile(st2) then begin LocalOpen:=true;LocateAndOpenFile:=st2;end
                    else LocalOpen:=false;
  end;

var sthaspath:boolean;
begin
 LocateAndOpenFile:='';
 sthaspath:=(pos('\',st)>0) or (pos(':',st)>0);
 if sthaspath then
   LocalOpen(st)
 else
   if not LocalOpen(dirCur+st) then LocalOpen(libdir+st);
end;

FUNCTION  LocateFile(st:PathStr):PathStr;
begin
 st:=LocateAndOpenFile(st);
 if st<>'' then CloseFile;
 LocateFile:=st;
end;

{---------------------------------------------------------------------------
 Vraci delku souboru. Pozor, zaroven provede seek(0).
 ---------------------------------------------------------------------------}
FUNCTION LengthFile:longint;
var   siz:longint;
begin
 asm
    {to konec}
     mov ax,4202h;mov bx,datahandle;mov cx,0;mov dx,0;int 21h;
     mov word ptr siz  ,ax
     mov word ptr siz+2,dx
    {to zacatek}
     mov ax,4200h;mov bx,datahandle;mov cx,0;mov dx,0;int 21h;
     end;
 LengthFile:=siz;
end;

{---------------------------------------------------------------------------
 Cte data ze souboru, obdoba blockread. Vraci pocet prectenych bajtu.
 ---------------------------------------------------------------------------}
FUNCTION ReadFile(kam:pointer;len:word):word;assembler;
 asm
   mov ah,3fh;mov bx,datahandle;mov cx,len;
   push ds;lds dx,kam;int 21h;pop ds
   jnc @ok;xor ax,ax;@ok:
 end;

{---------------------------------------------------------------------------
 Posune ukazatel v souboru o zadanou delku.
 ---------------------------------------------------------------------------}
PROCEDURE SeekFileFromCur(okolik:longint);assembler;
 asm
     mov ax,4201h
     mov bx,datahandle
     mov cx,word ptr okolik+2
     mov dx,word ptr okolik
     int 21h;
 end;

{---------------------------------------------------------------------------
 Presune ukazatel v souboru na zadanou pozici, obdoba seek.
 ---------------------------------------------------------------------------}
PROCEDURE SeekFileFromStart(kam:longint);assembler;
 asm
     mov ax,4200h
     mov bx,datahandle
     mov cx,word ptr kam+2
     mov dx,word ptr kam
     int 21h
 end;

{---------------------------------------------------------------------------
 Zavre soubor, obdoba close. Vraci uspesnost.
 ---------------------------------------------------------------------------}
{$ifdef beta}
procedure closingclosed;
begin
 erBetaMsg('closefile 1');
end;
{$endif}

FUNCTION CloseFile:boolean;assembler;
 asm
     xor bx,bx
     xchg bx,datahandle

     {$ifdef beta}
     or bx,bx
     jnz @ok
     call closingclosed
     @ok:
     {$endif}

     mov ah,3eh
     int 21h
     mov al,255;adc al,0
 end;



{‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹ DM FORMAT ‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹}


{---------------------------------------------------------------------------
 Prialokuje jeden DM.
 ---------------------------------------------------------------------------}
FUNCTION IncDMs:boolean;
Begin
 if DMs=maxDMs then begin
   ReportErr(_(_erMocDMs));
   IncDMs:=false;
   exit;
   end;
 if not GetMem(pointer(DM[DMs+1]),sizeof(TDM)) then begin
   ReportErr(_(erLowMem));
   IncDMs:=false;
   exit;
   end;
 inc(DMs);
 fillchar(DM[DMs]^,sizeof(TDM),0);
 IncDMs:=true;
End;



{---------------------------------------------------------------------------
 Odalokuje posledni DM.
 ---------------------------------------------------------------------------}
PROCEDURE DecDMs;
var   i:word;
begin
 {$ifdef beta}
 if DMs=0 then erBetaMsg('decdms 1');
 if DM[DMs]=nil then erBetaMsg('decdms 2');
 {$endif}
 with DM[DMs]^ do begin
   if filebaze<>nil then begin
     for i:=fajlu downto 1 do DisposeStr(filebaze^[i].name);
     FreeMem(pointer(filebaze),fajlu*sizeof(TFB));
     end;
   end;
 FreeMem(pointer(DM[DMs]),sizeof(TDM));
 DM[DMs]:=nil;
 dec(DMs);
end;


{---------------------------------------------------------------------------
 Smaze udaje z DM[nezkompDM].
 ---------------------------------------------------------------------------}
PROCEDURE ResetNezkompDM;
var   i:word;
begin
 if nezkompDM<>0 then
  if DM[nezkompDM]<>nil then
   with DM[nezkompDM]^ do
    if filebaze<>nil then begin
      for i:=fajlu downto 1 do DisposeStr(filebaze^[i].name);
      FreeMem(pointer(filebaze),fajlu*sizeof(TFB));
      filebaze:=nil;
      fajlu:=0;
      end;
end;


{---------------------------------------------------------------------------
 Zrusi DMlist.
 ---------------------------------------------------------------------------}
PROCEDURE FreeAllDMs;
begin
 while DMs>0 do decDMs;
 projects      :=0;
 fileExists    :=dos_fileExists;
 fileReadStream:=dos_fileReadStream;
 fileGetSize   :=dos_fileGetSize;
end;


{---------------------------------------------------------------------------
 Prida jeden projekt a zaradi do nej DM z workDM.
 ---------------------------------------------------------------------------}
FUNCTION AddProject(NthDM:TDMs):TPrjs;
var   i:word;
label 1;
begin
 AddProject:=0;
 if projects=maxProjects then begin
   ReportErr(_(_erMocPrjs));
   exit;
   end;
 inc(projects);
 {najde misto kam podle abecedy zaradit projekt}
 for i:=1 to projects-1 do begin
   if DM[NthDM]^.projekt<DM[prj[i].prjDMmain]^.projekt then goto 1;
   end;
 i:=projects;
 1:
 lastAddedPrj:=i;
 {zaradi deem na pozici i}
 for i:=projects downto lastAddedPrj do prj[i+1]:=prj[i];
 with prj[lastAddedPrj] do begin
   prjDMs:=1;
   prjDMmain:=NthDM;
   prjDM[1]:=NthDM;
   end;

 AddProject:=lastAddedPrj;
end;


{---------------------------------------------------------------------------
 Prida DM do projektu.
 ---------------------------------------------------------------------------}
PROCEDURE AddDM2prj(NthDM:Tdms;proj:word);
var   i,j:word;
label 1;
begin
 with prj[proj] do begin
   if prjDMs=maxDMsInPrj then begin
     ReportErr(_(_erMocDMsInPrj));
     exit;
     end;
   inc(prjDMs);
   {najde misto kam podle casu zaradit deem}
   for i:=1 to prjDMs-1 do
    if DM[prjDM[i]]^.datetime<DM[NthDM]^.datetime then goto 1;
   i:=prjDMs;
   1:
   {zaradi deem na pozici i}
   for j:=prjDMs downto i+1 do prjDM[j]:=prjDM[j-1];
   prjDM[i]:=NthDM;
   end;
end;


{---------------------------------------------------------------------------
 Nacte z DM souboru hlavicku, vytvori k nemu zaznam, naplni filebazi etc.
 ---------------------------------------------------------------------------}
FUNCTION  LoadDM(filename:PathStr):boolean;

var   fbsrc:word;{src v komprimovanych datech}
      fbseg:word;{segment od filebaze}

function GetByte:byte;
begin
 getbyte:=(byte(mem[fbseg:fbsrc]+256-39)) xor mem[fbseg:fbsrc-1];
 inc(fbsrc);
end;

var   dirinfo   :SearchRec;
      i,j,code  :word;
      uvozovky  :array[1..4] of byte;
      st        :string;
      decodest  :string[13];
      ofsinDM   :longint;
      usedDM    :Tdms;
      oldboo,
      newboo    :boolean;
      oldver,
      newver    :word;
      found     :boolean;

label noneDM,badDM,badDMclosed,goodDM;

Begin
 {--zkusi najit DM v all_DM's_listu--}
 LoadDM:=true;
 for usedDM:=1 to DMs do if filename=DM[usedDM]^.fullfilename then exit;

 {--pripravi pamet pro novou polozku--}
 LoadDM:=false;
 if not IncDMs then exit;
 usedDM:=DMs;

 with DM[usedDM]^ do begin
   if debug then BiosWrite('  ...'+filename);
   {$ifdef beta}
   if loaded or checked then erBetaMsg('loaddm 1 '+filename);
   {$endif}
   fullfilename:=filename;

   {--existuje?--}
   FindFirst(filename,anyfile-directory,dirinfo);
   found:=doserror=0;

     {--je to nezkompilovanej projekt?--}
     if PathSlice(filename,psFile)=title then begin
         projekt               :=_(_Nezkompilovano);
         popisek               :='-';
         verzeDM               :=verzenum;
         root                  :=found or editmod;
         datetime              :=dirinfo.time;
         nezkompDM             :=usedDM;
         if root then addProject(usedDM);
         goto goodDM;
       end;

   if not found                                    then goto noneDM;
   {--nacte header--}
   if not OpenFile(filename)                       then goto noneDM;
   if     ReadFile(@st[1],255)<>255                then goto badDM;
   st[0]:=#255;

   {--testuje jestli je korektni header--}
   if copy(st,1,length(headfirst))<>headfirst      then goto badDM;
   val(copy(st,1+length(headfirst),3),verzeDM,code);
   if (code<>0) or (verzeDM>compatto)              then goto badDM;
   if verzeDM<minVerze                             then goto badDM;
   if copy(st,1+length(headfirst)+length(verze)+length(headbreak),length(headroot ))=headroot  then root:=true
    else
    if copy(st,1+length(headfirst)+length(verze)+length(headbreak),length(headaddon))=headaddon then root:=false
                                                   else goto badDM;
   j:=0;
   for i:=1 to 255 do
    case st[i] of
      #0:break;
      '"':if j=4                                   then goto badDM
           else begin inc(j);uvozovky[j]:=i;end;
      end;
   if (root and (j<>2)) or (not root and (j<>4))   then goto badDM;

   {--naplni dminfo--}
   fullfilename:=filename;
   datetime    :=dirinfo.time;
   projekt     :=copy(st,uvozovky[1]+1,uvozovky[2]-uvozovky[1]-1);
   if not root then
    addonfor   :=copy(st,uvozovky[3]+1,uvozovky[4]-uvozovky[3]-1);
   i:=0;repeat inc(i) until st[i]=#0;inc(i);
   firstfileofs:=word(memw[seg(st):ofs(st[i])]);inc(i,2);
   flags       :=word(memw[seg(st):ofs(st[i])]);inc(i,2);
   fajlu       :=word(memw[seg(st):ofs(st[i])]);inc(i,2);
   popisek[0]  :=st[i];
   for j:=1 to length(popisek) do popisek[j]:=st[i+j];inc(i,length(popisek)+1);
   filebazeofs :=i-1;

   {--naplni filebazi--}
   if fajlu=0                                      then goto badDM;
   {compressed data pro docasne pouziti loadne pred konec filebaze}
   if not GetMem(pointer(filebaze),fajlu*sizeof(TFB)) then begin
     ReportErr(_(erLowMem));
     goto badDM;
     end;
   SeekFileFromStart(filebazeofs);{skip headstuff}
   i      :=word(firstfileofs-filebazeofs);  {I=compressed size}
   fbsrc  :={ofs(filebaze^)+fajlu*sizeof(TFB)-i;}0;
   fbseg  :={seg(filebaze^);}freeseg;
   ReadFile(ptr(fbseg,fbsrc),i);{read filelist}
   CloseFile;
   ofsinDM:=firstfileofs;
   inc(fbsrc);
   for i:=1 to fajlu do with filebaze^[i] do begin
     decodest[0]:=chr(getbyte);
     for j:=1 to ord(decodest[0]) do decodest[j]:=chr(getbyte);
     name:=NewStr(decodest);
     start:=ofsinDM;
     len:=longint(getbyte)+longint(getbyte) shl 8+longint(getbyte) shl 16;
     flags:=0;
     inc(ofsinDM,len);
     end;

   {--oznaci si jeden systemovej dm, ostatni kickne--}
   if copy(filename,length(filename)-length(commonDM),255)='\'+commonDM then begin
     {ignoruje dm.dm jiny verze nez moje}
     if (systemDM<>0) or (DM[usedDM]^.verzeDM<>verzeNum) then goto badDMclosed;
     systemDM:=usedDM;
     with DM[systemDM]^ do if root=false then erMsg(fullfilename+' '+_(_erMusiBytRoot)+'.');
     addProject(usedDM);
     goto goodDM;
     end;

   {--updatne projektovy vazby mezi DMkama--}
   if root then begin
     if addProject(usedDM)<>0 then begin
       {k rootu hleda addony}
       with prj[lastAddedPrj] do st:=DM[prjDMmain]^.projekt;
       for i:=1 to DMs do
         if not DM[i]^.root then
          if hkNalezi(st,DM[i]^.addonfor) then
           addDM2prj(i,lastAddedPrj);
       end;
     end
   else begin
     {hleda rooty k addonu}
     for i:=1 to projects do
      with prj[i] do
       if hkNalezi(DM[prjDMmain]^.projekt,addonfor) then
        addDM2prj(usedDM,i);
     end;

 goodDM:
   {uz je closnuto}
   checked           :=true;
   last_exist_check  :=true;
   bad               :=false;
   loaded            :=true;
   LoadDM            :=true;
   if debug then BiosWriteln(' '+_(_rulez));
   exit;

 badDM:
   {jeste neni closnuto}
   CloseFile;
 badDMclosed:
   {uz je closnuto}
   checked           :=true;
   last_exist_check  :=true;
   bad               :=true;
   loaded            :=false;
   LoadDM            :=false;
   if debug then BiosWriteln(' '+_(_sux));
   exit;

 noneDM:
   checked           :=true;
   last_exist_check  :=false;
   loaded            :=false;
   LoadDM            :=false;
   if debug then BiosWriteln(' '+_(_none));
   exit;

   end;

End;
(*
{---------------------------------------------------------------------------
 Nahraje seznam DM souboru.
 ---------------------------------------------------------------------------}
FUNCTION  LoadDMlist(filename:string):boolean;
const delic='≥';
var   f:text;
      st:string;
      i:word;
      ok:boolean;
label thisdmdone,closeit;
begin
 LoadDMlist:=false;
 assign(f,filename);
 reset(f);
 if ioresult<>0 then exit;
 while not eof(f) do begin
   if not IncDMs then goto closeit;
   with DM[DMs]^ do begin
     readln(f,st);
     if st[1]<>';' then begin
       {data nactena ze souboru}
       medium           :=cutstring(delic,st);
       fullfilename     :=cutstring(delic,st);
       projekt          :=cutstring(delic,st);
       addonfor         :=cutstring(delic,st);
       popisek          :=cutstring(delic,st);
       ok               :=cutword(delic,st,verzeDM);
       ok               :=cutlong(delic,st,datetime) and ok;
       if not ok then
        if dumb then begin decDMs;goto thisdmdone;end
                else erMsg('Nekorektn° data v DM listu.');
       last_exist_check :=st[1]='1';
       index_loaded     :=st[2]='1';
       if DriveOk(fullfilename[1],medium) then LoadDM(fullfilename);
       end;
     end;
   thisdmdone:
   end;
 closeit:
 close(f);
 LoadDMlist:=true;
end;


{---------------------------------------------------------------------------
 Ulozi seznam DM souboru, nesejvne samorosty.
 ---------------------------------------------------------------------------}
FUNCTION  SaveDMlist(filename:string):boolean;
const delic='≥';
      boo:array[false..true] of char=('0','1');
var   f:text;
      i:word;
begin
 SaveDMlist:=false;
 assign(f,filename);
 rewrite(f);
 if ioresult<>0 then exit;
 for i:=1 to DMs do
   with DM[i]^ do
    if projekt<>'Nezkompilov†no' then begin
     writeln(f,medium+delic+fullfilename+delic+projekt+delic+addonfor+delic+popisek
               +delic+stri(verzeDM)+delic+stri(datetime)
               +delic+boo[index_loaded]+boo[last_exist_check]);
     if ioresult<>0 then begin close(f);exit;end;
     end;
 close(f);
 SaveDMlist:=true;
end;
*)

{---------------------------------------------------------------------------
 Loadne vsechny DMka ze zadaneho adresare.
 ---------------------------------------------------------------------------}
PROCEDURE LoadDMsIn(st:string);
var   dirinfo   :SearchRec;
begin
 if debug then BiosWriteln(_(_msgHledamDMsV)+' '+st);
 findfirst(st+'*.dm',anyfile-directory,dirinfo);
 while doserror=0 do with dirinfo do begin
   LoadDM(st+name);
   findnext(dirinfo);
   end;
end;


Function dm_fileExists(name:PathStr):boolean;far;
begin
 dm_fileExists:=GetDkod(name,false)<>0;
end;

Function DkodReadStream(kod:TDkod):PStream;far;
var s:PDMFileStream;
begin
 DkodReadStream:=nil;
 if kod<>0 then begin
   New(s,Init(kod));
   if (s<>nil) and (s^.status<>0) then KillObj(s);
   DkodReadStream:=s;
   end;
end;

Function dm_fileReadStream(name:PathStr):PStream;far;
begin
 dm_fileReadStream:=DkodReadStream(GetDkod(name,false));
end;

Function dm_fileGetSize(name:PathStr;var size:longint):boolean;far;
var Dkod:TDkod;
begin
 Dkod:=GetDkod(name,false);
 if Dkod<>0 then size:=Data(Dkod)^.len;
 dm_fileGetSize:=Dkod<>0;
end;

{---------------------------------------------------------------------------
 Prohleda mista kde by se daly ocekavat DM soubory a nalezene hned loadne.
 ---------------------------------------------------------------------------}
PROCEDURE ScanDMs(all:boolean);

  procedure TryLoadDMs(dir:pstring);far;
  begin
   LoadDMsIn(dir^);
  end;

var   i:word;
begin
 if DMs<>0 then exit;

 if not LoadDM(dirExe+commonDM) then erMsg(_(_erChybiSoub)+' '+commonDM+' '+_(_verze)+' '+verze+'.');
 LoadDM(FExpand(title));
 if all then begin
   Dirs.ForEach(@TryLoadDMs);
   if autorun_path<>'' then LoadDM(autorun_path);
   end;

 now_project:=GetSystemPrj;
 for i:=1 to projects do if DM[prj[i].prjDMmain]^.fullfilename=autorun_path then now_project:=i;

 fileExists    :=dm_fileExists;
 fileReadStream:=dm_fileReadStream;
 fileGetSize   :=dm_fileGetSize;
end;


{---------------------------------------------------------------------------
 Vraci zda je projekt systemovy.
 ---------------------------------------------------------------------------}
FUNCTION  IsSystemPrj(p:TPrjs):boolean;
begin
 IsSystemPrj:=DM[prj[p].prjDMmain]^.popisek='doc';
end;

{---------------------------------------------------------------------------
 Vraci zda je projekt nezkompilovany.
 ---------------------------------------------------------------------------}
FUNCTION  IsNezkompPrj(p:TPrjs):boolean;
begin
 IsNezkompPrj:=DM[prj[p].prjDMmain]^.popisek='-';
end;

{---------------------------------------------------------------------------
 Vraci cislo systemoveho projektu.
 ---------------------------------------------------------------------------}
FUNCTION  GetSystemPrj:TPrjs;
var p:TPrjs;
begin
 for p:=1 to projects do
  if IsSystemPrj(p) then begin GetSystemPrj:=p;exit;end;
 GetSystemPrj:=0;
end;

{---------------------------------------------------------------------------
 Vraci cislo nezkompilovaneho projektu.
 ---------------------------------------------------------------------------}
FUNCTION  GetNezkompPrj:TPrjs;
var p:TPrjs;
begin
 for p:=1 to projects do
  if IsNezkompPrj(p) then begin GetNezkompPrj:=p;exit;end;
 GetNezkompPrj:=0;
end;

{---------------------------------------------------------------------------
 Otevre soubor zadaneho Dkodu.
 ---------------------------------------------------------------------------}
FUNCTION  OpenDkodFile(Dkod:TDkod):boolean;
var   uspech:boolean;
      myname:PathStr;
begin
 {$ifdef beta}
 if (datahandle<>0) then erBetaMsg('opendkodfile 1');
 {$endif}

 with Data(Dkod)^ do begin
   if HiWord(Dkod)=nezkompDM then begin
     myname:=name^;
     uspech:=LocateAndOpenFile(myname)<>'';
     if uspech then lastopenlength:=LengthFile;
     end
   else begin
     myname:=DM[HiWord(Dkod)]^.fullfilename;
     uspech:=OpenFile(myname);
     if uspech then begin
       SeekFileFromStart(start);
       lastopenLength:=len;
       end;
     end;
   end;
 if not uspech then ReportErr(_(_erNelzeOtevSoub)+' '+myname+'.');
 OpenDkodFile:=uspech;
end;

{---------------------------------------------------------------------------
 Otevre soubor. Hleda ve filebazi i na disku.
 ---------------------------------------------------------------------------}
FUNCTION  OpenDMFile(st:PathStr):boolean;
var   fajl:word;
      p:pointer;

  function FoundInDM(d:TDMs):boolean;
  var fajl:word;
  begin
   FoundInDM:=false;
   with DM[d]^ do
    if loaded then
     for fajl:=1 to fajlu do
      with filebaze^[fajl] do
       if name^=st{soubor nalezen ve filebazi} then begin
         FoundInDM:=OpenDkodFile(MakeLong(d,fajl));
         exit;
         end;
  end;

  function FoundInPrj(pr:TPrjs):boolean;
  var i:word;
  begin
   FoundInPrj:=true;
   with prj[pr] do
    for i:=1 to prjDMs do
     if FoundInDM(prjDM[i]) then exit;
   FoundInPrj:=false;
  end;

label foundInData,foundInNezkomp,notFound;
begin
 OpenDMFile:=true;
 upcasni(st);

 {$ifdef beta}
 if datahandle<>0 then erBetaMsg('opendmfile 1');
 if now_project=0 then erBetaMsg('opendmfile 2: read_dm before scan_all_dms');
 {$endif}

 {je-li ve standardni DMs filebazi, je pouzit}
 if FoundInPrj(now_project) then exit;
 if openAlsoSystemFiles then
  if FoundInDM(systemDM) then exit;

 {otevre samorost; neni-li nalezen -> exit}
 if LocateAndOpenFile(st)='' then begin OpenDMFile:=false;exit;end;

 {neni-li dosud ve filebazi samorostu, je mu vytvorena polozka}
 with DM[nezkompDM]^ do begin
   for fajl:=1 to fajlu do
    with filebaze^[fajl] do
     if name^=st then goto foundInNezkomp;
   fajl:=fajlu+1;
   if not GetMem(p,(fajlu+1)*sizeof(TFB)) then begin
     ReportErr(_(erLowMem));
     OpenDMFile:=false;
     exit;
     end;
   if filebaze<>nil then begin
     move(filebaze^,p^,fajlu*sizeof(TFB));
     FreeMem(pointer(filebaze),fajlu*sizeof(TFB));
     end;
   filebaze:=p;
   inc(fajlu);
   fillchar(filebaze^[fajl],sizeof(TFB),0);
   with filebaze^[fajl] do begin
     name:=NewStr(st);
     len:=LengthFile;
     end;
   end;

 foundInNezkomp:
 with DM[nezkompDM]^.filebaze^[fajl] do begin
   {stacilo by :=len, ale bezpecnejsi je merit velikost pokazdy znova, pri editaci se casto meni}
   lastopenlength:=LengthFile;
   end;
end;



{---------------------------------------------------------------------------
 Vraci pointer na data - info o souboru.
 ---------------------------------------------------------------------------}
FUNCTION  Data(Dkod:Tdkod):PFB;
begin
 if Dkod=0 then
  erMsg('Internal error Data(0).');
 data:=PFB(@DM[HiWord(Dkod)]^.filebaze^[word(Dkod)]);
end;

{---------------------------------------------------------------------------
 Zjisti v jakem souboru a jeho casti se Dkodem zadany soubor nachazi.
 ---------------------------------------------------------------------------}
FUNCTION  LoadDkodLocation(Dkod:Tdkod;var fileofs,filesize:longint):PathStr;
begin
 with Data(Dkod)^ do
 {alone file}
 if HiWord(Dkod)=nezkompDM then begin
   fileofs:=0;
   filesize:=0;
   LoadDkodLocation:=LocateFile(name^);
   end
 {in dm file}
 else begin
   fileofs:=start;
   filesize:=len;
   LoadDkodLocation:=DM[HiWord(Dkod)]^.fullfilename;
   end;
end;

                               {
Function TFB.Id:pchar;
begin
 if idcache=nil then idcache:=StrNew(Str2TempPc(
   PathSlice(DM[HiWord(idDkod)]^.fullfilename,psName)+'.'+Data(idDkod)^.name^
   ));
 Id:=cache;
end;

Destructor TFB.Done;
begin
end;
                              }

{---------------------------------------------------------------------------
 Ripne soubor z filebaze na disk.
 Dest muze a nemusi obsahovat i jmeno souboru.
 ---------------------------------------------------------------------------}
FUNCTION  Rip(ripDkod:Tdkod;dest:PathStr):boolean;
var   srcStream,destStream:PStream;
      d:PObject;
label ex;
begin
 rip:=false;
 if ripDkod<=0 then begin ReportErr(_(errFileNotFound));goto ex;end;
 if ReadOnlyMod then begin ReportErr(_(_erReadOnly));goto ex;end;
 with data(ripDkod)^ do begin
  if PathSlice(dest,psFile)='' then dest:=dest+PathSlice(name^,psFile);
  if (HiWord(ripDkod)=nezkompDM) and (locased(name^)=locased(dest)) then begin rip:=true;goto ex;end;
  if CurScreen=nil then d:=nil else d:=dlgStrOpen('RIP '+dest);
  srcStream:=DkodReadStream(ripDkod);
  if srcStream<>nil then
   if dirMake(PathSlice(dest,psPath)) then begin
    destStream:=fileCreateStream(dest);
    if destStream<>nil then begin
      destStream^.CopyFrom(srcStream^,srcStream^.GetSize);
      rip:=(srcStream^.status=stOk) and (destStream^.status=stOk);
      KillObj(destStream);
      end;
    KillObj(srcStream);
    end;
  KillObj(d);
  end;
 ex:
end;


{---------------------------------------------------------------------------
 Vraci Dkod hledaneho souboru.
 ---------------------------------------------------------------------------}
FUNCTION  GetDkod(filename:PathStr;errorifnotfound:boolean):TDkod;
var   i:word;

function found(deem:Tdms):boolean;
var   j:word;
begin
 with DM[deem]^ do
  for j:=1 to fajlu do
   if filebaze^[j].name^=filename then begin
     GetDkod:=MakeLong(deem,j);
     found:=true;
     exit;
     end;
 found:=false;
end;

function foundInprj(peerje:Tprjs):boolean;
var   i:word;
begin
 with prj[peerje] do
  for i:=1 to prjDMs do if found(prjDM[i]) then begin
    foundInprj:=true;
    exit;
    end;
 foundInprj:=false;
end;

Begin
 getDkod:=0;
 if filename='' then exit;
 UpCasni(filename);
 {prohleda DMs z projektu}
 if foundInprj(now_project) then exit;
 {prohleda DMs z systemPrj}
 if foundInprj(GetSystemPrj) then exit;
 {prohleda samorosty}
 if found(nezkompDM) then exit;
 {zkusi ho otevrit z disku a znovu prohleda samorosty}
 if OpenDMFile(filename) then begin
   CloseFile;
   if found(nezkompDM) then exit;
   end;
 {nenalezeno}
 if errorifnotfound then ReportErr(_(_erChybiSoub)+' '+filename+'.');
End;



Constructor TDMFileStream.Init(Dkod:TDkod);
var   oldhandle:word;
begin
 inherited Init;
 oldhandle:=datahandle;
 if not OpenDkodFile(Dkod) then Fail;
 size:=lastopenLength;
 pos:=0;
 filehandle:=datahandle;
 datahandle:=oldhandle;
end;

Function TDMFileStream.GetSize:Longint;
begin
 GetSize:=size;
end;

Function TDMFileStream.GetPos:Longint;
begin
 GetPos:=pos;
end;

Procedure TDMFileStream.Read(var Buf;Count:Word);
var   oldhandle:word;
      er:boolean;
begin
 oldhandle:=datahandle;
 datahandle:=filehandle;
 er:=(ReadFile(@buf,count)<>count) and (@StreamError<>nil);
 inc(pos,count);
 datahandle:=oldhandle;
 if er then Error(stReadError,0);
end;

Procedure TDMFileStream.Seek(newpos:longint);
var   oldhandle:word;
begin
 oldhandle:=datahandle;
 datahandle:=filehandle;
 SeekFileFromCur(newpos-pos);
 pos:=newpos;
 datahandle:=oldhandle;
end;

Destructor TDMFileStream.Done;
var   oldhandle:word;
begin
 oldhandle:=datahandle;
 datahandle:=filehandle;
 CloseFile;
 datahandle:=oldhandle;
 inherited Done;
end;





FUNCTION DkodIs(Dkod:TDkod):word;
begin
 if Dkod=0 then DkodIs:=0 else DkodIs:=fileIs(Data(Dkod)^.name^);
end;


{---------------------------------------------------------------------------
 link=stranka: vraci vsechny na disku existujici jazykove mutace,
               na ktere muze link korektne ukazovat
 ---------------------------------------------------------------------------}
FUNCTION AllPageLinkDestinations(name:PathStr):string;
var result:string;
    mask:string[80];
    add:PathStr;
begin
 if PathSlice(name,psExt)='' then begin
   name:=PathSlice(name,psPath+psName);
   if fileExists(name) then result:=name else result:='';
   mask:=fileMask(isLanguage);
   while mask<>'' do begin
     add:=name+copy(CutString(mask,';'),2,4);
     if fileExists(add) then AddName(result,add);
     end;
   end
 else
   result:=DecodeLink(name,false);
 AllPageLinkDestinations:=result;
end;

{---------------------------------------------------------------------------
 Zakoduje prvni soubor v linku.
 ---------------------------------------------------------------------------}
FUNCTION CodeLink(link:string):string;
var flags:word;
    name:string;
    params:string absolute link;
begin
 name:=CutName(params);
 if params<>'' then params:=' '+params;
 flags:=fileIs(name);
 if ((flags and (isGraphics+isLoadable))=isGraphics+isLoadable)
 and ((flags and isPlayable)=0){animacku necha s puvodni extenzi}
  then CodeLink:=PathSlice(name,psLow+psPath+psName)+'.pic'+params
  else CodeLink:=PathSlice(name,psLow+psPath+psFile)       +params;
end;

{---------------------------------------------------------------------------
 Pokud to jde, .pic ve jmenu souboru nahradi spravnou koncovkou.
 Vraci i neexistujici soubory.
 ---------------------------------------------------------------------------}
FUNCTION DecodePic(name:PathStr):string;
var found:PathStr;
begin
 DecodePic:=name;
 if PathSlice(name,psExt)='PIC' then begin
   found:=fileFind(PathSlice(name,psDir+psName),isGraphics+isLoadable);
   if found<>'' then DecodePic:=found;
   end;
end;

{---------------------------------------------------------------------------
 .pic ve jmenu souboru nahradi spravnou koncovkou.
 Pokud soubor nebo nahrada neexistuje, vraci prazdny link.
 ---------------------------------------------------------------------------
FUNCTION DecodePic(name:PathStr):string;
begin
 if PathSlice(name,psExt)='PIC'
  then DecodePic:=fileFind(PathSlice(name,psDir+psName),isGraphics+isLoadable)
  else DecodePic:=fileFind(name,isAnything);
end;

{---------------------------------------------------------------------------
 Dekoduje prvni soubor v linku.
 Kdyz nejde, vraci ''.
 ---------------------------------------------------------------------------}
FUNCTION DecodeLink(link:string;dialog:boolean):string;
var name:string;
    params:string absolute link;
 function try(name:PathStr):boolean;
 begin
  if fileExists(name) then begin
    DecodeLink:=name+params;
    try:=true;
    end
  else
    try:=false;
 end;
var ext:ExtStr;
    otherlangs:string;
    t:TMenuCollection;
    sel:byte;
begin
 DecodeLinkHadDialog:=false;
 name:=CutName(params);
 if params<>'' then params:=' '+params;
 DecodeLink:='';
 ext:=PathSlice(name,psExt);
 if ext='PIC' then begin
   name:=fileFind(PathSlice(name,psDir+psName),isGraphics+isLoadable);
   if name<>'' then name:=name+params;
   DecodeLink:=name;
   exit;
   end;
 if ext='' then if try(name+'.'+language) then exit;
 if try(name) then exit;
 if dialog then
  if (fileIs(name) and isHypertext)>0 then begin
   {stranka: vrat vsechny na disku existujici jazykove mutace, klidne i ''}
   {obrazek: je jedno}
   {skript: je jedno}
   otherlangs:=AllPageLinkDestinations(name+params);
   if otherlangs='' then exit;
   t.Init(false);
   while otherlangs<>'' do t.InsertStr(cutName(otherlangs),0);
   sel:=dlgMenuNdx(_(_msgChybi)+' '+name+','#13+_(_msgVyberNahrJazyk),@t,1);
{   sel:=dlgMenu(_(_msgChybi)+' '+name+','#13+_(_msgVyberNahrJazyk),t.count,pointer(t.items),4,1);}
   DecodeLinkHadDialog:=true;
   if sel>0 then DecodeLink:=Pc2Str(Pchar(t.items^[sel-1]))+params;
   t.Done;
   end;
end;

{---------------------------------------------------------------------------
 Dekoduje jmeno obrazku v inspicu.
 Kdyz nejde, vraci ''.
 ---------------------------------------------------------------------------}
FUNCTION DecodeInspic(name:PathStr):PathStr;
begin
 if (PathSlice(name,psExt)='') or (PathSlice(name,psExt)='PIC')
  then DecodeInspic:=fileFind(PathSlice(name,psDir+psName),isGraphics)
  else DecodeInspic:=fileFind(name,isGraphics);
end;

{---------------------------------------------------------------------------
 link=stranka: vraci vsechny na disku existujici jazykove mutace,
               na ktere muze link korektne ukazovat
               a i jednu neexistujici, pokud neukazuje na zadnou
 link=obrazek: vybere a vraci jeden jediny obrazek, i neexistuje-li. i .pic
 link=skript:  vraci vsechny i neexistujici potrebne soubory
 ---------------------------------------------------------------------------}
FUNCTION AllLinkDestinations(reporter:TReporter;link:string):string;
var result:string;
    name:string;
    params:string absolute link;
begin
 name:=CutName(params);
 if (fileIs(name) and isScript)>0 then begin
   result:=name;
   if not AddScriptFiles(reporter,name,params,result)
    then {prob je uz reportnut, osetrovat ho nebudeme};
   end
 else
 if (fileIs(name) and isHypertext)>0 then begin
   result:=AllPageLinkDestinations(name);
   {pokud neni zadna jazykova mutace, vrati aspon jednu neexistujici,
    ktera pak vyvola hlasku "chybi tento soubor"}
   if result='' then result:=name;
   end
 else begin
   result:=DecodeLink(name,false);
   if result='' then result:=name;
   end;
 AllLinkDestinations:=result;
end;


{∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞INIT/DONE∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞}

const unita='dmfile';
var result:TError;
    OldShutDown:procedure;

procedure ShutDown;far;
 begin
  {kdyz doslo k chybe pri otevrenem souboru, vynuluje datahandle aby
   pristi pristup k jinemu souboru nevyvolal "betaverze hlasi: opendmfile 1"}
  datahandle:=0;
  if @OldShutDown<>nil then OldShutDown;
 end;

procedure UserInit;
 var mask:string[80];
 begin
  rundir       :=dirCur;
  inidir       :=dirCur;{neni definitivni, jeste se bude menit}
  autorun_path :='';
  now_project  :=0;
  DMs          :=0;
  projects     :=0;
  nezkompDM    :=0;
  systemDM     :=0;
  minVerze     :=100;
  editmod      :=false;
  return2rundir:=true;
  Dirs.Init(5,5);{doufam ze bude dost pameti}
  Dirs.Insert(NewStr(dirCur));
  Dirs.Insert(NewStr(dirExe));
  Dirs.Insert(NewStr(dirIns));
  OldShutDown  :=ShutDownInts;
  ShutDownInts :=ShutDown;
  mask:=fileMask(isLanguage);
  while mask<>'' do fileRegister(copy(CutString(mask,';'),3,3),isHypertext+isLanguage);
  fileRegister(''   ,isHypertext);
  fileRegister('SCR',isScript);
  fileRegister('VEC',isPlayable+isGraphics+isScalable);
  openAlsoSystemFiles:=true;
 end;

procedure UserDone;
 begin
  if return2rundir then dirChange(rundir);
  FreeAllDMs;
  Dirs.Done;
 end;

{$i initdone.inc}
{$ifdef autoinit}
BEGIN
 erCheck(Init);
{$endif}
END.


osetrit praci s nenaloadovanym DMkem
dkod veci nalezeny v samorostech/v systemu nerezat now_projektem ale
  nezkompDM/systemDM-kem

Koncepce prace se samorosty (soubory mimo .DM)
----------------------------------------------
 OpenDMFile(st) hleda st v adresarich kolem. Najde a otevre treba direc\st,
 ale vytvori polozku st.
 Vsichni kdo manipulujou s polozkou musej pocitat s tim, ze pravej soubor
 je direc\st, samotny st neexistuje. S polozkou krome OpenDMFile
 manipulujou: midas2.musPlay,



