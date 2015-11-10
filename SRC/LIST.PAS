UNIT List;

INTERFACE {$i define.inc}

FUNCTION MakeList:boolean;

IMPLEMENTATION

uses  Chyby,Memo, Dos,Objects, Stringy,Sys,Fajly,Dialogy,DMFile,DMText,DMParser,DMAtoms;

var projectfile:text;

procedure myReportFile(st:string);far;
begin
 writeln(projectfile,st);
end;

FUNCTION MakeList:boolean;

 procedure Pridej1Dir(mask:PathStr);
 var   t:searchrec;
       fajl:word;
       p:pointer;
 label foundInNezkomp,skip;
 begin
  findfirst(mask,0,t);
  while doserror=0 do begin
   if PathSLice(t.name,psName)<>'LANG' then begin
     lst.AddFiles(typ_cla,t.name);

     {plni filebazi - bez toho se spravne nevygeneruje descript.ion}
     with DM[nezkompDM]^ do begin
       for fajl:=1 to fajlu do
        with filebaze^[fajl] do
         if name^=t.name then goto foundInNezkomp;
       fajl:=fajlu+1;
       if not GetMem(p,(fajlu+1)*sizeof(TFB)) then begin
         ReportErr(_(erLowMem));
         goto skip;
         end;
       if filebaze<>nil then begin
         move(filebaze^,p^,fajlu*sizeof(TFB));
         FreeMem(pointer(filebaze),fajlu*sizeof(TFB));
         end;
       filebaze:=p;
       inc(fajlu);
       fillchar(filebaze^[fajl],sizeof(TFB),0);
       with filebaze^[fajl] do begin
         name:=NewStr(t.name);
         len:=0;{LengthFile;}
         end;
       end;
       skip:
       foundInNezkomp:

     end;
   findnext(t);
   end;
 end;

 procedure Pridej(mask:FileStr);
 begin
  Pridej1Dir(mask);
  Pridej1Dir(LibDir+mask);
 end;

 procedure PridejClanky;
 var  mask:string[80];
 begin
  pridej('*.');
  mask:=fileMask(isLanguage);
  while mask<>'' do pridej(CutString(mask,';'));
 end;

Label ok;
Begin
 makelist:=false;
 New(lib,Init(exclude,_(_msgVylucujiZPrj)));
 {$ifdef big}
 New(big,Init(bigpic,_(_msgNehledimNaSize)));
 {$endif}
 {$ifdef kod}
 kod_Zahaj;
 {$endif}
 ReportFile:=myReportFile;
 ReportProb:=erWrite;
 ReportInfo:=erWrite;

 {---------------naplni seznam clanku------------------------------}

 BiosWriteln(_(_msgProhlizimVazby));
 PridejClanky;
 if lst.count=0 then erMsg(_(_erNoPages2Compile));
 if AllPageLinkDestinations(title)='' then lst.JeDosazitelnejFatal(title);
 aLoadPicDescriptions(GetNezkompPrj);

 {----------prelouska clanky a zaradi podpurny fajly---------------}

 AddPagesSupport(GetNezkompPrj,true{pages inserted},true{subpages},true{templates});
 {$ifdef kod}
 kod_Caruj;
 {$endif}

 {----------------vytvori a prida descript.ion------------------------}

 aSavePicDescriptions(GetNezkompPrj);
 Pridej('descript.ion');
 lst.JeDosazitelnej('descript.ion');

 {----------------sejvne seznam vsech fajlu------------------------}

 assign(projectfile,datalist);
 {$ifdef kod}
 if kod_Ok then
 {$endif}
   rewrite(projectfile);
 BiosWriteln('');

 lst.SubFiles(typ_fnt);
 lst.SubFiles(typ_sam);
 lst.SubFiles(typ_mod);
 lst.SubFiles(typ_scr);
 lst.SubFiles(typ_cla);
 lst.SubFiles(typ_rip);
 lst.SubFiles(typ_dulezitejpic);

 BiosWrite(_(_msgPrjSize)+': ');
 if lst.sizein>MaxL(lst.sizeout,1000000) then begin
   writeln(projectfile);
   BiosWriteln(stri(lst.sizeout div 1024)+'+'+stri(lst.sizein div 1024)+'KB');
   end
 else
   BiosWriteln(stri((lst.sizein+lst.sizeout) div 1024)+'KB');
 lst.SubFiles(typ_nedulezitejpic);
 lst.FreeAll;
 close(projectfile);
 ReportFile:=nil;

{-------------------warnings-------------------------}
 if probShow then begin
   FlushKey;
   if readkey<>'8' then fileDelete(0,datalist) else goto ok;
   end
 else begin
   ok:
   makelist:=true;
   end;

 {$ifdef big}
 KillObj(big);
 {$endif}
 KillObj(lib);
End;


END.
