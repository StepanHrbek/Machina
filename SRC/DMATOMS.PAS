Unit      DMAtoms;
Interface {$i define.inc}
Uses      Chyby,Memo, Dos,Objects, Atoms,DMFile,Vga,Scrol,DMText;
Function  Init:TError;
Procedure Done;

{
  Poznamky:
   -kontexty vracene funkci cx jsou staticke pchary, neuvolnovat
   -objekty na strance musi byt cislovany od 1, 0 je rezervovana
}

{---------kolekce-----------}

Var       atom           :TAllAtomCollection;
          NacitatAtomy   :boolean;
          UkladatAtomy   :byte;

Procedure LoadAtoms;
Procedure StoreAtoms;
Procedure ReportAtoms(context:pchar);
Procedure AddGlobalAtoms;

{---------kontexty----------}

Var       cur_mapDirect  :boolean;
          cur_map        :PBitmap;
          cur_screen     :PScrolScreen;

Const     kod_menu       =10000;{libovolny unikatni Dkod prideleny pro menu}

Function  cx(idPrj:TPrjs;idDkod:TDkod;idObject:TObjs):pchar;

{---------cx:glob-----------}

Const     aProgram       ='program';
          aVersion       ='version';
          aGoto          ='goto';
          aTodo_         ='todo';
          aTodoTail      ='todotail';
          aTodoHead      ='todohead';
          aXres          ='screen_width';
          aYres          ='screen_height';

Function  aTodo(n:longint):pchar;
Procedure aAddTodo(todo:pchar);

{---------cx:prj------------}

Const     aPrjLongName   ='longname';
          aPrjShortName  ='shortname';
          aPicDescriptions='picdescriptions';
          aPagDescriptions='pagdescriptions';
Procedure aLoadPagDescriptions(proj:TPrjs);
Procedure aLoadPicDescriptions(proj:TPrjs);
Procedure aSavePicDescriptions(proj:TPrjs);

{---------cx:page-----------}

Const     aUserPal       ='pal';
          aObjects       ='objects';
          aPageName      ='name';
          aAuthor        ='author';
          aResolution    ='resolution';
          aRest          ='rest';
          aForcePacked   ='forecepacked';
          aSizeX         ='page_width';
          aSizeY         ='page_height';

Function  aLoadPagDescription(prj:TPrjs;Dkod:TDkod;t:PDMText):boolean;
Procedure aStorePal      (prj:TPrjs;Dkod:TDkod;pal:PPal);
Procedure aRestorePal    (prj:TPrjs;Dkod:TDkod;pal:PPal);
Function  aPxs           (prj:TPrjs;Dkod:TDkod):word;
Procedure aInstallPx     (prj:TPrjs;Dkod:TDkod;rect:TRect;script,data:pchar;map:PBitmap);
Procedure aCallPxs       (prj:TPrjs;Dkod:TDkod;screen:PScrolScreen;map:PBitmap);
Function  aFindPx        (prj:TPrjs;Dkod:TDkod;var click:TPoint):word;
Procedure aLeavePage     (prj:TPrjs;Dkod:TDkod);

{---------cx:obj------------}

Const     aRect          ='rect';
          aScript        ='script';
          aData          ='data';
          aClick         ='click';

Procedure aGetPxRect     (context:pchar;var rect:TRect);
Function  aClickPx       (prj:TPrjs;Dkod:TDkod;obj:word;screen:PScrolScreen;map:PBitmap):TDkod;


{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}
                          IMPLEMENTATION
{‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹}

Uses      Strings,
          Stringy,Sys,Fajly,Dialogy,Texty,DMScript,NFDos;

Var       cur_Proj       :TPrjs;
          cur_Dkod       :TDkod;
          cur_obj        :word;

{------------------------------kontexty------------------------------------}

const incx     =';';
      str_menu ='*menu';

var static:string[90];
{
 vraci jmeno kontextu
 hodnota parametru=0  znamena ze kontext nezavisi na tomto parametru
 hodnota parametru=-1 znamena pouzit cur_* neboli hodnotu odpovidajici
                      posledne pustenemu skriptu
}
Function  cx(idPrj:TPrjs;idDkod:TDkod;idObject:TObjs):pchar;
begin
 static:='';
 if idPrj=-1 then idPrj:=cur_Proj;
 if idPrj<>0 then static:=PathSlice(DM[prj[idPrj].prjDMmain]^.fullfilename,psName+psLow);
 if idDkod=-1 then idDkod:=cur_Dkod;
 if idDkod=kod_menu then static:=str_menu else
 if idDkod<>0 then static:=static+incx+Data(idDkod)^.name^;
 if idObject=-1 then idObject:=cur_obj;
 if idObject<>0 then static:=static+incx+stri(idObject);
 cx:=Str2Pc(static);
end;

Procedure ParseCx(context:string;var proj:TPrjs;var Dkod:TDkod;var obj:word);
var   p:TPrjs;
      cut:PathStr;
      i:word;

 function NalezlV(d:TDMs):boolean;
 var  fajl:word;
 begin
  NalezlV:=false;
  for fajl:=1 to DM[d]^.fajlu do begin
   if DM[d]^.filebaze^[fajl].name^=cut then begin
     Dkod:=MakeLong(d,fajl);
     cut:=GetString(context,incx,3);
     NalezlV:=true;
     if cut='' then exit;
     {hleda matchujici obj}
     obj:=valu(cut);
     exit;
     end;
   end;
 end;

begin
 proj:=0;
 Dkod:=0;
 obj:=0;
 {neni cxGlob?}
 cut:=GetString(context,incx,1);
 if cut='' then exit;
 if cut=str_menu then begin
   Dkod:=kod_menu;
   obj:=valu(GetString(context,incx,2));
   exit;
   end;
 {hleda matchujici projekt}
 for p:=1 to projects do
  if cut=PathSlice(DM[prj[p].prjDMmain]^.fullfilename,psName+psLow) then begin
    proj:=p;
    cut:=GetString(context,incx,2);
    if cut='' then exit;
    {hleda matchujici page}
    for i:=1 to prj[p].prjDMs do
     if NalezlV(prj[p].prjDM[i]) then exit;
    end;
 ReportErr('error in script: bad context '+context);
end;


{----------------------------atomy <-> disk--------------------------------}

Procedure LoadAtoms;
var s:TBufStream;
begin
 if NacitatAtomy and FileExists(iniDir+'dm.ato') and s.Init(iniDir+'dm.ato',stOpenRead,65520) then begin
   if debug then BiosWriteln('LoadAtoms.');
   atom.Done;
   atom.Load(s);
   s.Done;
   end;
end;

Procedure StoreAtoms;
var s:TBufStream;
begin
 if (UkladatAtomy>0) and s.Init(iniDir+'dm.ato',stCreate,65520) then begin
   if debug then BiosWriteln('StoreAtoms.');
   case UkladatAtomy of
    1:atom.asDel(nil,forImplicit);
    2:atom.asDel(nil,forRuntime);
    end;
   atom.Store(s);
   s.Done;
   end;
 atom.Done;
end;


{--------------------------------kdeco------------------------------------}

Procedure ReportAtoms(context:pchar);
var pc:pchar;
begin
 pc:=atom.asGet(context);
 if pc<>nil then begin
   dlgMsg(pc);
   FreeMem(pointer(pc),StrLen(pc)+1);
   end;
end;

Procedure AddGlobalAtoms;
var p:TPrjs;
begin
 for p:=1 to projects do begin
   atom.aSet(cx(p,0,0),aPrjLongName,StrNewStr(DM[prj[p].prjDMmain]^.projekt),forRuntime);
   atom.aSet(cx(p,0,0),aPrjShortName,StrNewStr(DM[prj[p].prjDMmain]^.popisek),forRuntime);
   end;
 atom.aSet(cx(0,0,0),aProgram,StrNewStr(mach_msg),forRuntime);
 atom.aSet(cx(0,0,0),aVersion,StrNewStr(verze   ),forRuntime);
 atom.aSet(cx(0,0,0),aTodoHead,StrNewNum(0),forRuntime);
 atom.aSet(cx(0,0,0),aTodoTail,StrNewNum(0),forRuntime);
end;


var atodo_static:string[15];
{vraci staticky pchar}
Function  aTodo(n:longint):pchar;
begin
 atodo_static:=aTodo_+stri(n);
 aTodo:=Str2Pc(atodo_static);
end;

{neulozi kopii ale primo data}
Procedure aAddTodo(todo:pchar);
var todohead:longint;
begin
 todohead:=StrGetNum(atom.aGet(cx(0,0,0),aTodoHead));
 atom.aSet(cx(0,0,0),aTodo(todohead),todo,forRuntime);
 atom.aSet(cx(0,0,0),aTodoHead,StrNewNum(todohead+1),forRuntime);
end;


Procedure aStorePal(prj:TPrjs;Dkod:TDkod;pal:PPal);
var   i:word;
      st:string[130];
begin
 if pal=nil
  then atom.aSet(cx(prj,Dkod,0),aUserPal,nil,forImplicit)
  else with pal^ do begin
    st[0]:=#120;
    for i:=1 to 40 do begin
      st[3*i-2]:=chr(pal[i].r+32);
      st[3*i-1]:=chr(pal[i].g+32);
      st[3*i-0]:=chr(pal[i].b+32);
      end;
    atom.aSet(cx(prj,Dkod,0),aUserPal,StrNew(Str2Pc(st)),forImplicit);
    end;
end;

Procedure aRestorePal(prj:TPrjs;Dkod:TDkod;pal:PPal);
var   i:word;
      pc:pchar;
begin
 if pal<>nil then
  with pal^ do begin
   pc:=atom.aGet(cx(prj,Dkod,0),aUserPal);
   if pc=nil
    then for i:=1 to 40 do begin
      pal[i].r:=0;
      pal[i].g:=0;
      pal[i].b:=0;
      end
    else for i:=1 to 40 do begin
      pal[i].r:=ord(pc[3*i-2])-32;
      pal[i].g:=ord(pc[3*i-1])-32;
      pal[i].b:=ord(pc[3*i-0])-32;
      end;
   end;
end;



Function aPxs(prj:TPrjs;Dkod:TDkod):word;
begin
 aPxs:=valu(Pc2Str(atom.aGet(cx(prj,Dkod,0),aObjects)));
end;

Function aNewPx(prj:TPrjs;Dkod:TDkod):word;
var objects:word;
begin
 objects:=aPxs(prj,Dkod)+1;
 atom.aSet(cx(prj,Dkod,0),aObjects,StrNewNum(objects),forPagetime);
 aNewPx:=objects;
end;

Procedure aInstallPx(prj:TPrjs;Dkod:TDkod;rect:TRect;script,data:pchar;map:PBitmap);
var context:pchar;
    obj:word;
begin
{ reporterr('aInstallPx '+stri(prj)+' '+stri(dkod)+' '+pc2str(script)+' '+pc2str(data));{}
 obj:=aNewPx(prj,Dkod);
 context:=cx(prj,Dkod,obj);
 atom.aSet(context,aRect,StrNewStr(stri(rect.a.x)+' '+stri(rect.a.y)+' '+stri(rect.b.x)+' '+stri(rect.b.y)),forPagetime);
 atom.aSet(context,aScript,script,forPagetime);
 atom.aSet(context,aData,data,forPagetime);
 {zavola skript hned pri instalaci}
 atom.aSet(context,aClick,nil,forDunno);
 if fileIs(Pc2Str(script)) and isScript<>0
  then aClickPx(prj,Dkod,obj,nil,map);
end;

Procedure aGetPxRect(context:pchar;var rect:TRect);
var pc:pchar;
begin
 pc:=atom.aGet(context,aRect);
 rect.a.x:=StrCutNum(pc);
 rect.a.y:=StrCutNum(pc);
 rect.b.x:=StrCutNum(pc);
 rect.b.y:=StrCutNum(pc);
end;

{Function aGetPxScript(context:pchar):TDkod;
begin
 aGetPxScript:=GetNum(atom.aGet(context,aScript));
end;
}
(*
Function aGetPxMap(context:pchar):PBitmap;
var pc:pchar;
    map:PBitmap;
    rect:TRect;
begin
 {varianta A: kazdy objekt ma vlastni mapu oddelenou od page}
 {ta by se mela odalokovat pri ruseni atomu aMap}
 pc:=atom.aGet(context,aMap);
 if pc<>nil
  then aGetPxMap:=Ptr(ReadNum(pc),ReadNum(pc))
  else begin
   aGetPxRect(context,rect);
   New(map,Init(model_packed,rect.b.x-rect.a.x,rect.b.y-rect.a.y));
   if map=nil then system.Halt(erLowMem);
   atom.aSet(context,aMap,StrNewStr(stri(PtrRec(map).Seg)+':'+stri(PtrRec(map).Ofs)),forRuntime);
   aGetPxMap:=map;
   end;
 {varianta B: kazdy objekt ma vlastni mapu vnorenou do page}
end;
*)

Procedure aCallPxs(prj:TPrjs;Dkod:TDkod;screen:PScrolScreen;map:PBitmap);
var obj:word;
    pc:pchar;
begin
 for obj:=1 to valu(Pc2Str(atom.aGet(cx(prj,Dkod,0),aObjects))) do begin
   pc:=cx(prj,Dkod,obj);
   atom.aSet(pc,aClick,nil,forDunno);
   if fileIs(Pc2Str(atom.aGet(pc,aScript))) and isScript<>0
    then aClickPx(prj,Dkod,obj,screen,map);
   end;
end;

Function aFindPx(prj:TPrjs;Dkod:TDkod;var click:TPoint):word;
var obj:word;
    rect:TRect;
    pc:pchar;
begin
 for obj:=1 to valu(Pc2Str(atom.aGet(cx(prj,Dkod,0),aObjects))) do begin
   pc:=cx(prj,Dkod,obj);
   aGetPxRect(pc,rect);
{   with rect do dlgStr(Pc2Str(pc)+' '+stri(a.x)+' '+stri(a.y)+' '+stri(b.x)+' '+stri(b.y));}
   if rect.Contains(click) then begin
     aFindPx:=obj;
     click.x:=longint(10000)*(click.x-rect.a.x) div (rect.b.x-rect.a.x);
     click.y:=longint(10000)*(click.y-rect.a.y) div (rect.b.y-rect.a.y);
     atom.aSet(pc,aClick,StrNewStr(stri(click.x)+' '+stri(click.y)),forDunno);
     exit;
     end;
   end;
 aFindPx:=0;
end;

Function aClickPx(prj:TPrjs;Dkod:TDkod;obj:word;screen:PScrolScreen;map:PBitmap):TDkod;
var scriptName:FileStr;
    decodedName:FileStr;
    scriptDkod:TDkod;
    nextName:FileStr;
    nextDkod:TDkod;
    flags:word;
    todotail:longint;
    data:pchar;
label 0;
begin
 0:
{ ReportAtoms(cx(now_project,Dkod,obj));{}
 nextDkod:=0;
 scriptName:=Pc2Str(atom.aGet(cx(prj,Dkod,obj),aScript));
 decodedName:=DecodeLink(scriptName,true);
 scriptDkod:=GetDkod(decodedName,false);
 if scriptDkod=0
  then begin
    if not DecodeLinkHadDialog
     then ReportErr(_(_msgLinkVedeNa)+' '+scriptName+','#13#10+_(_msgKteryztoNenalez))
    end
  else begin
    flags:=DkodIs(scriptDkod);
    {link na sampl,modul,animaci}
    if (flags and isPlayable)>0 then ptrPlayFile(scriptDkod) else
    {link na stranku}
    if (flags and isHypertext)>0 then nextDkod:=scriptDkod else
    {link na obrazek}
    if (flags and isLoadable)>0 then nextDkod:=scriptDkod else
    {link na skript}
    if (flags and isScript)>0 then begin
          cur_Proj  :=prj;
          cur_Dkod  :=Dkod;
          cur_obj   :=obj;
          cur_map   :=map;
          cur_screen:=screen;

          if ((cur_map<>nil) and (cur_map^.MapModel<>model_text))
           or ((cur_screen<>nil) and (cur_screen^.MapModel<>model_text)) then
            RunScript(scriptName);

{ReportAtoms(cx(0,0,0));{}
          todotail:=StrGetNum(atom.aGet(cx(0,0,0),aTodoTail));
          if todotail<StrGetNum(atom.aGet(cx(0,0,0),aTodoHead)) then begin
{ReportAtoms(cx(prj,Dkod,1));{}
            data:=atom.aGet(cx(0,0,0),aTodo(todotail));
            ParseCx(StrCutStr(data,' '),prj,Dkod,obj);
{ReportErr(stri(prj)+' '+stri(dkod)+' '+stri(obj));{}
            atom.aSet(cx(prj,Dkod,obj),aData,StrNew(data),forDunno);
            atom.aSet(cx(prj,Dkod,obj),aClick,nil,forDunno);
            atom.aSet(cx(0,0,0),aTodotail,StrNewNum(todotail+1),forDunno);
            goto 0;
            end;

         nextName:=Pc2Str(atom.aGet(cx(0,0,0),aGoto));
         nextDkod:=GetDkod(DecodeLink(nextName,true),false);
         atom.aSet(cx(0,0,0),aGoto,nil,forDunno);
         if (nextName<>'') and (nextDkod=0) and (not DecodeLinkHadDialog) then
          ReportErr(scriptName+' '+_(_msgOdkazujeNa)+' '+nextName+','#13#10+_(_msgKteryztoNenalez));
         end
    {link na nesmysl}
    else ReportErr(_(_msgLinkVedeNa)+' '+scriptName+'.'#13#10+_(_msgFormNepodpor));
    end;
 aClickPx:=nextDkod;
{ ReportAtoms(cxObj(Dkod,obj));{}
end;
{
Function aClick(Dkod:TDkod;click:TPoint):TDkod;
begin
 aClickPx(Dkod,aFindPx(Dkod,click));
end;
}
Procedure aLeavePage(prj:TPrjs;Dkod:TDkod);
var obj:word;
begin
 for obj:=1 to aPxs(prj,Dkod) do
  atom.asDel(cx(prj,Dkod,obj),forPagetime);
 atom.asDel(cx(prj,Dkod,0),forPagetime);
end;

{---------------------------------------------------------------------------
 Nascanuje nam: a aut: do atomu.
 ---------------------------------------------------------------------------}
Function aLoadPagDescription(prj:TPrjs;Dkod:TDkod;t:PDMText):boolean;
var st:string;
begin
{reporterr('-(dkod='+stri(hiword(dkod))+':'+stri(word(dkod)));{*}
 aLoadPagDescription:=false;
 st:=t^.GetHeader('nam:');
 if st<>'' then begin
{reporterr(' nam:'+st+' (dkod='+stri(hiword(dkod))+':'+stri(word(dkod)));{*}
   atom.aSet(cx(prj,Dkod,0),aPageName,StrNewStr(st),forRuntime);
   aLoadPagDescription:=true;
   end;
 st:=t^.GetHeader('aut:');
 if st<>'' then begin
   atom.aSet(cx(prj,Dkod,0),aAuthor,StrNewStr(st),forRuntime);
   aLoadPagDescription:=true;
   end;
end;

{---------------------------------------------------------------------------
 Pokud je treba, zjisti a do atomu ulozi popisky vsech stranek projektu.
 ---------------------------------------------------------------------------}
Procedure aLoadPagDescriptions(proj:TPrjs);
var Dkod:TDkod;
    result:TError;
    t:TDMText;
    loadedok,
    loaded:longint;
begin
 if atom.aGet(cx(proj,0,0),aPagDescriptions)=nil then
  with prj[proj] do begin
    loaded:=0;
    loadedok:=0;
    Dkod:=FirstDkod;
    while Dkod<>0 do begin
      inc(loaded);
      if DkodIs(Dkod) and isHypertext>0 then
       if (atom.aGet(cx(proj,Dkod,0),aPageName)=nil) and
        (atom.aGet(cx(proj,Dkod,0),aAuthor)=nil) then begin
          t.Init(0,nil,Data(Dkod)^.name^,0,result);
          if not aLoadPagDescription(proj,Dkod,@t) then dec(loadedok);
          t.Done;
          end;
      Dkod:=NextDkod;
      end;
    inc(loadedok,loaded);
    atom.aSet(cx(proj,0,0),aPagDescriptions,StrNewStr(stri(loadedok)+'/'+stri(loaded)+' loaded'),forRuntime);
    end;
end;

{---------------------------------------------------------------------------
 Pokud je treba, zjisti a do atomu ulozi popisky z descript.ion.
 ---------------------------------------------------------------------------}
Procedure aLoadPicDescriptions(proj:TPrjs);
var p:pchar;
    t:TText2;
    fname:FileStr;
    filepos,descrpos,lfpos:pchar;
    picDkod:TDkod;
    loadedok,
    loaded:longint;
    abskonec:word;
    desc_fname:string[13];
begin
 if atom.aGet(cx(proj,0,0),aPicDescriptions)=nil then begin
   if IsSystemPrj(proj) then desc_fname:='!descrip.ion'
    else desc_fname:='descript.ion';
   if not fileExists(desc_fname) or not fileLoadPchar(desc_fname,nil,p) then begin
      atom.aSet(cx(proj,0,0),aPicDescriptions,StrNew('not found'),forRuntime);
      end
    else begin
      loaded:=0;
      loadedok:=0;
      t.Init(p,StrLen(p)+1);
      abskonec:=t.konec;
      while not t.Eof do begin
        filepos:=t.pos;
        t.chGoto(CR,+1);
        lfpos:=t.pos;
        if not t.Eof then begin
          (lfpos-1)^:=#0;
          t.konec:=word(lfpos-1);
          end;
        t.pos:=filepos;
        fname:=DecodePic(t.chRead(' '));
        if not t.Eof then begin
          picDkod:=GetDkod(fname,false);
          if picDkod<>0 then begin
            descrpos:=t.pos;
            t.chGoto('|',+1);
            {if not t.Oof then (t.pos-1)^:=#0;
            atom.aSet(cx(proj,picDkod,0),aPageName,StrNew(descrpos),forRuntime);
            if not t.Oof then atom.aSet(cx(proj,picDkod,0),aAuthor,StrNew(t.pos),forRuntime);
            if not t.Oof then (t.pos-1)^:='|';}
            if not t.Oof then (t.pos-1)^:=#0;
            atom.aSet(cx(proj,picDkod,0),aPageName,StrNew(descrpos),forRuntime);
            if not t.Oof then begin
              (t.pos-1)^:='|';
              descrpos:=t.pos;
              t.chGoto('|',+1);
              if not t.Oof then (t.pos-1)^:=#0;
              atom.aSet(cx(proj,picDkod,0),aAuthor,StrNew(descrpos),forRuntime);
              if not t.Oof then begin
                (t.pos-1)^:='|';
                descrpos:=t.pos;
                t.chGoto('|',+1);
                if not t.Oof then (t.pos-1)^:=#0;
                atom.aSet(cx(proj,picDkod,0),aResolution,StrNew(descrpos),forRuntime);
                if not t.Oof then begin
                  (t.pos-1)^:='|';
                  descrpos:=t.pos;
                  atom.aSet(cx(proj,picDkod,0),aRest,StrNew(descrpos),forRuntime);
                  end;
                end;
              end;
            inc(loadedok);
            end;
          end;
        t.konec:=abskonec;
        t.pos:=lfpos;
        if not t.Eof then (t.pos-1)^:=CR;
        inc(t.pos);
        inc(loaded);
        end;
      t.Done;
      atom.aSet(cx(proj,0,0),aPicDescriptions,StrNewStr(stri(loadedok)+'/'+stri(loaded)+' loaded'),forRuntime);
      end;
   end;
end;

{---------------------------------------------------------------------------
 Do descript.ion ulozi popisky stranek z atomu.
 ---------------------------------------------------------------------------}
Procedure aSavePicDescriptions(proj:TPrjs);
var t:TText2;
    Dkod:TDkod;
    pc1,pc2,pc3,pc4:pchar;
begin
 proj:=GetNezkompPrj;
 t.Init(freeptr,MinL(freesize,65535));
 t.static:=true;
 t.Rewrite;
{reporterr('proj='+stri(proj));{*}
 Dkod:=prj[proj].FirstDkod;
 while Dkod<>0 do begin
{reporterr('ukladam deskripsn pro dkod='+stri(dkod)+' (proj='+stri(proj)+')');{*}
   pc1:=atom.aGet(cx(proj,Dkod,0),aPageName);
   pc2:=atom.aGet(cx(proj,Dkod,0),aAuthor);
   pc3:=atom.aGet(cx(proj,Dkod,0),aResolution);
   pc4:=atom.aGet(cx(proj,Dkod,0),aRest);
   if ((pc1<>nil) and (pc1^<>#0))
   or ((pc2<>nil) and (pc2^<>#0))
   or ((pc3<>nil) and (pc3^<>#0))
   or ((pc4<>nil) and (pc4^<>#0)) then begin
     t.Write(Data(Dkod)^.name^+' ');
     t.WritePc(pc1);
     if ((pc2<>nil) and (pc2^<>#0))
     or ((pc3<>nil) and (pc3^<>#0))
     or ((pc4<>nil) and (pc4^<>#0)) then begin
       t.Write('|');
       t.WritePc(pc2);
       if ((pc3<>nil) and (pc3^<>#0))
       or ((pc4<>nil) and (pc4^<>#0)) then begin
         t.Write('|');
         t.WritePc(pc3);
         if (pc4<>nil) and (pc4^<>#0) then begin
           t.Write('|');
           t.WritePc(pc4);
           end;
         end;
       end;
     t.Writeln('');
     end;
   Dkod:=prj[proj].NextDkod;
   end;
 t.Done;
 fileSave(fileOverwrite,'descript.ion',Ptr(PtrRec(t.pos).Seg,t.start),t.FileSize);
end;


{∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞INIT/DONE∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞}

const unita='dmatoms';
var result:TError;

procedure UserInit;
 begin
  NacitatAtomy     :=false;
  UkladatAtomy     :=0;
  atom.Init;
  cur_mapDirect    :=false;
 end;

procedure UserDone;
 begin
  atom.Done;
 end;

{$i initdone.inc}
{$ifdef autoinit}
BEGIN
 erCheck(Init);
{$endif}
END.