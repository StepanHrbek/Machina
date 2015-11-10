Unit      DMScript;
Interface {$i define.inc}
Uses      Dos,Chyby;

Function  Init:TError;
Procedure Done;

PROCEDURE RunScript(name:PathStr);

FUNCTION  dlgInputLink(hlaska:string;mask:PathStr):string;
FUNCTION  dlgInputScriptParams(name:PathStr):string;

FUNCTION  ParamsMatchAndGetFiles(reporter:TReporter;script:PathStr;paramvals,paramdeclars:string;var files:openstring):boolean;
FUNCTION GetParamDeclarsAndFiles(reporter:TReporter;script:PathStr;paramvals:string;var paramdeclars,files:openstring):boolean;
FUNCTION  AddScriptFiles(reporter:TReporter;script:PathStr;paramvals:string;var files:openstring):boolean;

Implementation

Uses      Strings,
          Texty,Stringy,Fajly,Dialogy,DMFile,Vga,
          MyLan,MyDef,MyDefin,MyFunc,MyPars,MyPProc,MyVars,MyCode,NFDos;


{---------------------------------------------------------------------------
 Spusti skript.
 ---------------------------------------------------------------------------}
PROCEDURE RunScript(name:PathStr);
var p:pchar;
begin
 ResetLan;
 RunFlags:=0;
 ErrCode:=0;
 p:=LoadSource(name); {if dlgError(LoadPchar(name,p))<>erOk then exit;}
 Prg:=CompileSource(p,true);
 if Prg=nil then ReportErr(ErrMess) else begin
   Run(-1);
   if ErrCode<>0 then begin RefreshLan;ReportErr(ErrMess);end;
   end;
 DoneSource(p); {FreeMem(pointer(p),StrLen(p)+1);}
 if debugpal then SetHwCol(0,0,0,0);
end;

{---------------------------------------------------------------------------
 Zepta se uzivatele na link.
 ---------------------------------------------------------------------------}
FUNCTION dlgInputLink(hlaska:string;mask:PathStr):string;
begin
 mask:=PathSlice(dlgFile(0,hlaska,mask,''),psFile+psLow);
 if (fileIs(mask) and isScript)>0 then mask:=dlgInputScriptParams(mask);
 dlgInputLink:=CodeLink(mask);
end;

{---------------------------------------------------------------------------
 Zepta se uzivatele na parametry skriptu a vraci je spolu s name.
 ---------------------------------------------------------------------------}
FUNCTION dlgInputScriptParams(name:PathStr):string;
var t:TText2;
    pc:pchar;
    c:TMenuCollection;
    st:string;
    paramdeclars:string absolute st;
    paramname:string[80];
    paramtype:string[10];
    results:string;
    result:string;
    script:PathStr;
    descr:string[76];
    i:integer;
 function brk:boolean;
 begin
  brk:=false;
  if paramdeclars<>'' then begin
    brk:=true;
    ReportErr(_(_scrSkript)+' '+name+': '+_(_scrMaPrebytecParams));
    name:='';
    results:='';
    end;
 end;
 function uvoz(st:string):string;{je-li treba, obali uvozovkami}
 var bak:string;
 begin
  bak:=st;
  cutname(st);
  if st='' then uvoz:=bak else uvoz:='"'+bak+'"';
 end;
begin
 results:='';
 if fileLoadPchar(LocateFile(name),nil,pc) and t.Init(pc,StrLen(pc)+1) then begin
     c.Init(false);
     t.Reset;
     repeat
       st:=t.nlRead;
       if copy(st,1,8)='{param: ' then c.InsertStr(copy(st,9,length(st)-9),0);
       if copy(st,1,8)='{descr: ' then descr:=copy(st,9,length(st)-9);
     until copy(st,1,1)<>'{';
     if c.count=0 then begin
       ReportErr(_(_scrSkript)+' '+name+' '+_(_scrNemaZdokuParams));
       name:='';
       end
     else begin
       if c.count=1 then i:=1 else i:=dlgMenuNdx(descr+#13+_(_scrVyberDruhParams),@c,1);
       if i=0 then name:='' else begin
         paramdeclars:=Pc2Str(c.items^[i-1]);
         while paramdeclars<>'' do begin
           paramtype:=CutString(paramdeclars,':');
           paramname:=CutString(paramdeclars,' ');
           if paramtype='number'    then result:=dlgLine(0,paramname,'') else
           if paramtype='string'    then result:=Uvoz(dlgLine(0,paramname,'')) else
           if paramtype='file'      then result:=PathSlice(dlgFile(0,paramname,'*.*',''),psLow+psFile) else
           if paramtype='loadable'  then result:=dlgInputLink(paramname,fileMask(isLoadable)) else
           if paramtype='playable'  then result:=dlgInputLink(paramname,fileMask(isPlayable)) else
           if paramtype='executable'then result:=dlgInputLink(paramname,fileMask(isExecutable)) else
           if paramtype='sound'     then result:=dlgInputLink(paramname,fileMask(isSound)) else
           if paramtype='sample'    then result:=dlgInputLink(paramname,fileMask(isSample)) else
           if paramtype='module'    then result:=dlgInputLink(paramname,fileMask(isModule)) else
           if paramtype='animation' then result:=dlgInputLink(paramname,fileMask(isPlayable+isGraphics)) else
           if paramtype='font'      then result:=dlgInputLink(paramname,fileMask(isFont)) else
           if paramtype='script'    then begin result:=dlgInputLink(paramname,fileMask(isScript));if brk then break;end else
           if paramtype='link'      then begin result:=dlgInputLink(paramname,'*.*');if brk then break;end else
           if paramtype='...'       then begin result:=dlgLine(0,paramname,'');if brk then break;end else
             begin
               ReportErr(_(_scrSkript)+' '+name+', '+_(_scrParametr)+' '
                    +paramname+' '+_(_scrMaNeznamyTyp)+' '+paramtype+'.');
               name:='';
               results:='';
               break;
               end;
           if result='' then begin name:='';results:='';break;end;
           AddName(results,result);
           end;
         end;
       end;
     t.Done;
     c.Done;
     end;
 if results<>'' then results:=' '+results;
 dlgInputScriptParams:=name+results;
end;

FUNCTION isFile(name:string):boolean;
begin
 isFile:=
    (CharsIn('.',name)<=1) and
    (CharsIn(':',name)<=1) and
    (pos(':',name) in [0,2]) and
    (pos(' ',name)=0) and
    (pos('+',name)=0) and
    (pos(';',name)=0) and
    (pos(',',name)=0) and
    (length(PathSlice(name,psName)) in [1..8]) and
    (length(PathSlice(name,psExt)) in [0..3]);
end;

FUNCTION isNumber(number:string):boolean;
var i:integer;
begin
 isNumber:=false;
 if number[1] in ['+','-'] then delete(number,1,1);
 for i:=1 to length(number) do
  if not (number[i] in ['0'..'9']) then exit;
 isNumber:=true;
end;



{---------------------------------------------------------------------------
 Hleda vhodnou sadu parametru ve skriptu.
 Pri uspesnem zmatchovani nastavi paramdeclars a rozsiri files.
 Soubory zustanou nedekodovane a seznam muze obsahovat duplicity.
 ---------------------------------------------------------------------------}
FUNCTION GetParamDeclarsAndFiles(reporter:TReporter;script:PathStr;paramvals:string;var paramdeclars,files:openstring):boolean;
var t:TText2;
    pc:pchar;
    st:string;
    selected:boolean;
label ok;
begin
 selected:=false;
 script:=LocateFile(script);
 if (script<>'') and fileLoadPchar(script,nil,pc) and t.Init(pc,StrLen(pc)+1) then begin
     t.Reset;
     repeat
       st:=t.nlRead;
       if copy(st,1,8)='{files: ' then AddName(files,copy(st,9,length(st)-9));
       if not selected then
        if copy(st,1,8)='{param: ' then begin
          paramdeclars:=copy(st,9,length(st)-9);
          selected:=ParamsMatchAndGetFiles(reporter,script,paramvals,paramdeclars,files);
          end;
     until copy(st,1,1)<>'{';
     if not selected
      then reporter(_(_scrSkript)+' '+script+' '+_(_scrNeumiParams)+' '+paramvals+'.');
     t.Done;
     end;
 GetParamDeclarsAndFiles:=selected;
end;

{---------------------------------------------------------------------------
 Zkousi zadanou sadu parametru.
 Pri uspesnem zmatchovani rozsiri files.
 Soubory zustanou nedekodovane a seznam muze obsahovat duplicity.
 ---------------------------------------------------------------------------}
FUNCTION ParamsMatchAndGetFiles(reporter:TReporter;script:PathStr;paramvals,paramdeclars:string;var files:openstring):boolean;
var paramtype:string[10];
    paramname:string[80];
    paramval:string;
begin
 ParamsMatchAndGetFiles:=false;
 while paramdeclars<>'' do begin
   paramtype:=CutString(paramdeclars,':');
   paramname:=CutString(paramdeclars,' ');
   paramval:=CutString(paramvals,' ');
   if paramval='' then exit;
   if paramtype='number' then begin
         if not isNumber(paramval) then exit;
         end else
   if paramtype='string' then begin
         end else
   if paramtype='file' then begin
         if not isFile(paramval) then exit;
         AddName(files,paramval);
         end else
   if paramtype='loadable' then begin
         if not isFile(paramval) then exit;
         if ((fileIs(paramval) and isLoadable)=0)
          and (PathSlice(paramval,psExt)<>'PIC') then exit;
         AddName(files,paramval);
         end else
   if paramtype='playable' then begin
         if not isFile(paramval) then exit;
         if (fileIs(paramval) and isPlayable)=0 then exit;
         AddName(files,paramval);
         end else
   if paramtype='executable' then begin
         if not isFile(paramval) then exit;
         if (fileIs(paramval) and isExecutable)=0 then exit;
         AddName(files,paramval);
         end else
   if paramtype='sound' then begin
         if not isFile(paramval) then exit;
         if (fileIs(paramval) and isSound)=0 then exit;
         AddName(files,paramval);
         end else
   if paramtype='sample' then begin
         if not isFile(paramval) then exit;
         if (fileIs(paramval) and isSample)=0 then exit;
         AddName(files,paramval);
         end else
   if paramtype='module' then begin
         if not isFile(paramval) then exit;
         if (fileIs(paramval) and isModule)=0 then exit;
         AddName(files,paramval);
         end else
   if paramtype='animation' then begin
         if not isFile(paramval) then exit;
         if (fileIs(paramval) and (isPlayable+isGraphics))=0 then exit;
         AddName(files,paramval);
         end else
   if paramtype='font' then begin
         if not isFile(paramval) then exit;
         if (fileIs(paramval) and isFont)=0 then exit;
         AddName(files,paramval);
         end else
   if paramtype='script' then begin
         if not isFile(paramval) then exit;
         if (fileIs(paramval) and isScript)=0 then exit;
         AddName(files,paramval);
         if not AddScriptFiles(reporter,paramval,CutAll(paramvals),files) then exit;
         if paramdeclars<>'' then begin
           reporter(_(_scrSkript)+' '+script+' '+_(_scrMaPrebytecParams));
           exit;
           end;
         end else
   if paramtype='link' then begin
         if not isFile(paramval) then exit;
         AddName(files,paramval);
         if (fileIs(paramval) and isScript)>0 then
          if not AddScriptFiles(reporter,paramval,CutAll(paramvals),files) then exit;
         if paramdeclars<>'' then begin
           reporter(_(_scrSkript)+' '+script+' '+_(_scrMaPrebytecParams));
           exit;
           end;
         end else
   if paramtype='...' then begin
         if paramdeclars<>'' then begin
           reporter(_(_scrSkript)+' '+script+' '+_(_scrMaPrebytecParams));
           exit;
           end;
         paramvals:='';
         end else
   begin
         reporter(_(_scrSkript)+' '+script+', '+_(_scrParametr)+' '
           +paramname+'='+paramval+' '+_(_scrMaNeznamyTyp)+' '+paramtype+'.');
         exit;
         end;
   end;
 if paramvals<>'' then exit;
 ParamsMatchAndGetFiles:=true;
end;

{---------------------------------------------------------------------------
 Rozsiri files o soubory, ktere skript vyzaduje.
 Soubory zustanou nedekodovane a seznam muze obsahovat duplicity.
 ---------------------------------------------------------------------------}
FUNCTION AddScriptFiles(reporter:TReporter;script:PathStr;paramvals:string;var files:openstring):boolean;
var   paramdeclars:string;
begin
 AddScriptFiles:=GetParamDeclarsAndFiles(reporter,script,paramvals,paramdeclars,files);
end;



{같같같같같같같같같같같같같같같같INIT/DONE같같같같같같같같같같같같같같같같같�}

const unita='dmscript';
var result:TError;

procedure UserInit;
 begin
  InitLan(true,15000);
  InitNewFunc;
  CreateSystemAtoms;
  InitVars;
 end;

procedure UserDone;
 begin
  DoneLan;
 end;

{$i initdone.inc}
{$ifdef autoinit}
BEGIN
 erCheck(Init);
{$endif}
END.