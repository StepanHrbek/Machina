Unit      DMExport;
Interface {$i define.inc}
Uses      Dos,Objects;

Type      string80        =string[80];

Var       maxlen4emphasize:word;
          maxlen4centering:word;
          webHeader       :string80;
          webBodyHard     :string80;
          webBodySoft     :string80;
          webEmphasizeOn  :string80;
          webEmphasizeOff :string80;
          webBreak        :string80;
          webParaLeft     :string80;
          webParaCenter   :string80;
          webtitle        :string80;
          webauthor       :string80;
          webgenerator    :boolean;

FUNCTION  Name2Textfile(name,destname:PathStr;vyhen:boolean):boolean;
FUNCTION  Name2Htmlfile(name,destname:PathStr):boolean;
PROCEDURE ExportSubtree2Html(name,destdir:PathStr;subtree:boolean);
PROCEDURE ExportSubtree4Mach(name,destdir:PathStr;subtree:boolean);

Implementation
Uses      Memo,Chyby, Strings, Stringy,Cs,Sys,Vga,Fonty,Fajly,Streamy,
          Textury,Dialogy,DMFile,DMWriter,DMText,DMBitmap,DMParser;


{do vyhen nastavi zda je doporuceno orezavat (false=nechat orig.layout)}
FUNCTION File2Textmap(name:PathStr;var vyhen:boolean):PBitmap;
var   w:PDMWriter;
      b:PDMBitmap;
      result:TError;
      x,y,skip:word;
begin
 b:=nil;
 result:=erLowMem;
 new(w,Init(0,nil,name,dmtfResizeNadp,result));
 if result=erOk then begin
   w^.SetHeader('res:','80x30');
   result:=erLowMem;
   if not vyhen then begin
     New(b,InitW(0{dkod fuk},w,0{flags},0,0,result));
     end
   else begin
     New(b,InitW(0{dkod fuk},w,ord(vyhen)*dmtfVyhExport{flags},100,3,result));
     with b^ do begin
       {zdvoji tildy... nezdvojuje ty kolem linku co maj zustat jen jednou}
       skip:=0;
       for y:=sizeY-1 downto 0 do
        for x:=sizeX-1 downto 0 do
         if char(GetPixel(x,y))='~' then begin
           if (skip=0) and (char(GetPixel(MinW(x+1,sizeX-1),y))='[') then skip:=2;
           if skip=0 then Box2Box(b,x,y,sizeX-1-x,1,x+1,y);
           dec(skip);
           end;
       {dve volne radky presune na zacatek}
       Box2Box(b,0,0,sizeX,sizeY-2,0,2);
       Clr2Box(0,0,sizeX,2);
       Clr2Box(0,sizeY-1,sizeX,1);
       {pripise hlavicku a paticku}
       OutStr('$'+name,b,0,1,nil,1,1);
       OutStr('#'+w^.GetHeader('nam:')+' / '+w^.GetHeader('aut:'),b,0,2,nil,1,1);
       OutStr('$END',b,0,sizeY,nil,1,1);
       end;
     end;
   vyhen:=vyhen and (w^.OutputKind(0{flags})<>okTxt);
   KillObj(w);
   end;
 File2Textmap:=b;
 if result<>erOk then ReportErr(_(result));
end;

FUNCTION Textmap2Stream(b:PBitmap;orezavat:boolean;s:PStream):boolean;
var   i,y,x0{prvni znak},x1{posledni znak}:integer;
      wasempty:boolean;
const crlf:array[1..2] of char=#13#10;
      spaces=[32,ord('°')];
label 1;
begin
 Textmap2Stream:=false;
 if (s=nil) or (b=nil) or (b^.MapModel<>model_text) then ReportErr(_(errInvalidArguments))
  else with b^ do begin
    wasempty:=true;
    {zjisti jestli muze odriznout levy kraj}
    if not orezavat then
      x0:=0
    else begin
      for x0:=0 to sizeX-1 do
        for y:=0 to sizeY-1 do
         if not (tab^[y]^[2*x0] in spaces) then goto 1;
      inc(x0);
      1:
      end;
    for y:=0 to sizeY-1 do begin
      x1:=sizeX-1;
      while (x1>=x0) and (tab^[y]^[2*x1] in spaces) do dec(x1);
      {prazdne radky vynecha}
      if not orezavat or not wasempty or (x1>=x0) then begin
        for i:=x0 to x1 do s^.Write(tab^[y]^[2*i],1);
        s^.Write(crlf[1],2);
        end;
      wasempty:=x1<x0;
      end;
    Textmap2Stream:=true;
    end;
end;

FUNCTION Name2Textfile(name,destname:PathStr;vyhen:boolean):boolean;
var   s:PStream;
      b:PBitmap;
      d:PObject;
begin
 d:=dlgStrOpen('EXPORT '+destname);
 Name2Textfile:=false;
 s:=fileCreateStream(destname);
 if s<>nil then begin
   b:=File2Textmap(name,vyhen{zmeni se na orezavat});
   if b<>nil then begin
     Name2Textfile:=Textmap2Stream(b,vyhen{orezavat},s);
     KillObj(b);
     end;
   KillObj(s);
   end;
 KillObj(d);
end;



PROCEDURE SetDefaults;
begin
 maxlen4emphasize:=70;
 maxlen4centering:=60;
 webHeader       :='';
 webBodyHard     :='';
 webBodySoft     :='';
 webEmphasizeOn  :='<EM>';
 webEmphasizeOff :='</EM>';
 webBreak        :='<BR>';
 webParaLeft     :='<P>';
 webParaCenter   :='<P ALIGN=CENTER>';
 webtitle        :='';
 webauthor       :='';
 webgenerator    :=true;
end;

FUNCTION Name2Htmlfile(name,destname:PathStr):boolean;
var   s:PXlatStream;
      t:TDMText;
      formatovat:boolean;
      centruju:boolean;
      lines,tabs:word;

const webHead1     ='<HTML>'#13#10
                   +'<HEAD>'#13#10
                   +' <META HTTP-EQUIV="Content-type" CONTENT="text/html; charset=iso-8859-2">'#13#10;
      webAuthor1   =' <META NAME="Author" CONTENT="';
      webAuthor2   ='">'#13#10;
      webGenerator1=' <META NAME="Genarator" CONTENT="Deus ex Machina '+verzestr+'">'#13#10;
      webTitle1    =' <TITLE>';
      webTitle2    ='</TITLE>'#13#10;
      webHead2     ='</HEAD>'#13#10;
      CRLF         =#13#10;
      webImg1      =#13#10#13#10'<P><IMG src="';
      webImg2      ='" ALT=';
      webImg3      ='>';
      webLink1     ='<A href="';
      webLink2     ='"';
      webLink3     ='>';
      webLink4     ='</A>';
      webEnd       =#13#10#13#10'</BODY>'#13#10'</HTML>'#13#10;

  procedure Write(p:pchar);
  begin
   s^.Write(p^,StrLen(p));
  end;

  procedure Write2NewLine(var st:openstring);
  begin
   if st<>'' then Write(Str2TempPc(CRLF+st));
  end;

  procedure Write2EndLine(var st:openstring);
  begin
   if st<>'' then Write(Str2TempPc(st+CRLF));
  end;

  procedure ResetNewlines;
  begin
   lines:=0;
   tabs:=0;
  end;

  procedure FlushNewlines;
  var centrovat:boolean;
      newpara:boolean;
  begin
   if lines>0 then begin
     centrovat:=formatovat and (tabs=0) and (t.nlAdr(+1)-word(t.pos)<=maxlen4centering);
     newpara:=(lines>1) or (centrovat<>centruju);
     if not newpara then Write2NewLine(webBreak) else begin
       if lines>1 then Write(CRLF);
       if centrovat then Write2NewLine(webParaCenter) else Write2NewLine(webParaLeft);
       centruju:=centrovat;
       end;
     lines:=0;
     end;
   tabs:=0;
  end;

  procedure Chg2Html;
  var oldpos:pointer;
      st:string[80];
      link:string[20];
      c:char;
  label 1;
  begin
   t.Skip(1);
   1:
   c:=t.ReadChar;
   oldpos:=t.pos;
   st:=t.chRead(chgINIT);
   if t.ReadChar=chgLINK then begin
     link:=t.chRead(chgINIT);
     if DecodeLink(link,false)<>'' then link:=DecodeLink(link,false);
     if (fileIs(link) and isHypertext)>0 then link:=PathSlice(link,psPath+psName)+'.htm';
     FlushNewlines;
     Write(Str2TempPc(webLink1+LoCased(link)+webLink2+webLink3+st+webLink4));
     goto 1;
     end
    else begin
     if (c<>'0') and (c<>'a') and isin(length(st),1,maxlen4emphasize)
     and (pos(CR,st)=0) and (pos(cmdINIT,st)=0) then begin
       t.Skip(-1);
       FlushNewlines;
       Write(Str2TempPc(webEmphasizeOn+st+webEmphasizeOff));
       goto 1;
       end;
     t.pos:=oldpos;
     end;
  end;

  procedure Cmd2Html;
  var st:string[80];
      cmd:char;
  begin
   t.Skip(1);
   st:='';
   while t.GetChar<>cmdDONE do st:=st+t.ReadChar;
   t.Skip(1);
   cmd:=st[1];
   delete(st,1,1);
   case cmd of
     cmdINSPIC:begin
                ResetNewlines;
                st:=CutName(st);
                if DecodeInspic(st)<>'' then st:=DecodeInspic(st);
                Write(Str2TempPc(webImg1+PathSlice(st,psFile+psLow)+webImg2+st+webImg3));
               end;
     {cmdNEWSLP:;}
     cmdROVNALINE:Write('<HR>');
     {cmdSVISLALINE:;
     cmdCHECKBOX:;}
     cmdFORMAT:formatovat:=st[1]='1';
     end;
  end;

  procedure Body2Html;
  var tex:string;
      myWebBody:string;
    procedure tex2htm(machname,htmlname:string11);
    var value:string[40];
    begin
     if paramGet(myWebBody,htmlname)='' then begin
       value:=paramGet(tex,machname);
       if value='' then value:=paramGet(webBodySoft,htmlname);
       if value<>'' then myWebBody:=paramSet(myWebBody,htmlname,DecodePic(value));
       end;
    end;
  begin
   formatovat:=true;
   centruju:=false;
   ResetNewlines;
   t.GoZaheader3;
   Write2EndLine(webHeader);
   Write(webHead1);
   if t.GetHeader('aut:')<>'' then Write(Str2TempPc(webAuthor1+t.GetHeader('aut:')+webAuthor2)) else
    if webauthor<>'' then Write(Str2TempPc(webAuthor1+webauthor+webAuthor2));
   if webgenerator then Write(webGenerator1);
   if t.GetHeader('nam:')<>'' then Write(Str2TempPc(webTitle1+t.GetHeader('nam:')+webTitle2)) else
    if webtitle<>'' then Write(Str2TempPc(webTitle1+webtitle+webTitle2));
   Write(webHead2);
   tex:=t.GetHeader('tex:');
   myWebBody:=webBodyHard;
   if (texType(tex)='p') then begin
     tex2htm('bgcolor','bgcolor');
     tex2htm('background','background');
     tex2htm('text','text');
     tex2htm('link','link');
     end;
   if myWebBody<>''
    then myWebBody:='<BODY '+myWebBody+'>'
    else myWebBody:='<BODY>';
   Write2EndLine(myWebBody);
   while not t.Eof do
    case t.GetChar of
      cmdINIT:Cmd2Html;
      chgINIT:Chg2Html;
      CR     :begin inc(lines);tabs:=0;t.Skip(2);end;
      TAB    :begin inc(tabs);t.Skip(1);end;
      else    begin FlushNewlines;s^.Write(t.pos^,1);t.Skip(1);end;
      end;
   Write(webEnd);
  end;

  procedure WebLinks2Html;
  var   startofs,endofs,i:word;
        st:string[80];
        prep:string[10];
        tecek,zavinacu,lomitek,zavorek:byte;
        samacisla:boolean;
  label 1;
  begin
   t.GoZaheader3;
   repeat
     1:
     t.chGoto('.',+1);
     if t.Eof then break;
     if t.pos^=' ' then goto 1;
     t.Skip(-1);
     startofs:=MaxW(t.chAdr(chgINIT,-0)+2,
               MaxW(t.chAdr(cmdDONE,-0)+1,
               MaxW(t.chAdr(' '    ,-0)+1,
               MaxW(t.chAdr(','    ,-0)+1,
               MaxW(t.chAdr(';'    ,-0)+1,
               MaxW(t.chAdr('"'    ,-0)+1,
               MaxW(t.chAdr(''''   ,-0)+1,
               MaxW(t.chAdr('>'    ,-0)+1,
               MaxW(t.chAdr(')'    ,-0)+1,
                    t.chAdr(#10    ,-0)+1)))))))));
     endofs  :=MinW(t.chAdr(chgINIT,+1),
               MinW(t.chAdr(' '    ,+1),
               MinW(t.chAdr(','    ,+1),
               MinW(t.chAdr(';'    ,+1),
               MinW(t.chAdr('"'    ,+1),
               MinW(t.chAdr(''''   ,+1),
               MinW(t.chAdr('<'    ,+1),
               MinW(t.chAdr('('    ,+1),
                    t.chAdr(#13    ,+1)))))))));
     while (endofs>startofs) and (pchar(ptr(seg(t.pos^),startofs))^='.') do begin inc(startofs);inc(t.pos);end;
     while (endofs>startofs) and (pchar(ptr(seg(t.pos^),endofs-1))^='.') do dec(endofs);
     t.Skip(+1);
     if isin(endofs-startofs,2+3+3,60) then begin
       st[0]:=chr(endofs-startofs);
       move(pchar(ptr(seg(t.pos^),startofs))^,st[1],length(st));
       samacisla:=true;
       for i:=1 to length(st) do if not (st[i] in ['.','0'..'9']) then samacisla:=false;
       if not samacisla and (pos('..',st)=0) then begin
         tecek:=CharsIn('.',st);
         zavinacu:=CharsIn('@',st);
         lomitek:=CharsIn('/',st);
         zavorek:=CharsIn('(',st)+CharsIn(')',st)+CharsIn('[',st)+CharsIn(']',st)+CharsIn('{',st)+CharsIn('}',st);
         LoCasni(st);
         if pos(':',st)>0 then prep:=CutString(st,':') else prep:='';
         if zavorek<2 then
          if (zavinacu=1) and isin(tecek,1,6) and (lomitek=0) then begin
           prep:='mailto:';
           t.InsStr(startofs,endofs-startofs,webLink1+prep+st+webLink2+webLink3+st+webLink4);
           end
          else if (zavinacu=0) and isin(tecek,2,10) then begin
           if copy(st,1,2)='//' then delete(st,1,2);
           if prep='' then prep:='http';
           prep:=prep+'://';
           t.InsStr(startofs,endofs-startofs,webLink1+prep+st+webLink2{+' target=_top'}+webLink3+st+webLink4);
           end;
         end;
       end;
   until false;

  end;

var result:TError;
    d:PObject;
begin
 d:=dlgStrOpen('EXPORT '+destname);
 Name2Htmlfile:=false;
 s:=New(PXlatStream,Init(fileCreateStream(destname),Kamenici,IsoLatin2));
 if s<>nil then begin
   if t.Init(0,nil,name,0,result) then begin
     WebLinks2Html;
     Body2Html;
     Name2Htmlfile:=true;
     t.Done;
     end
   else ReportErr(_(result));
   KillObj(s);
   end;
 KillObj(d);
end;

var dir4export:PathStr;
    exportonlythis:PathStr;

procedure htmlReportFile(st:string);far;
begin
 if (fileIs(st) and isHypertext)>0 then begin
   if (exportonlythis='') or (exportonlythis=UpCased(st))
    then Name2Htmlfile(st,dir4export+PathSlice(st,psName)+'.HTM');
   end
 else
 if (fileIs(st) and (isGraphics+isSound))>0
  then Rip(GetDkod(st,false),dir4export+PathSlice(st,psFile));
end;

{name musi byt skutecne jmeno vcetne pripadne pripony
 z aktualni stranky exportuje jen jeji jazyk,
 z podstromu vsechny jazyky (ale do stejnyho.htm, takze zustane jen jeden)}
PROCEDURE ExportSubtree2Html(name,destdir:PathStr;subtree:boolean);
begin
 ReportFile:=htmlReportFile;
 dir4export:=destdir;
 lst.AddFiles(typ_cla,name);
 if subtree then begin
   exportonlythis:='';
   AddPagesSupport(now_project,false{pages not inserted},true{subpages},false{no templates});
   end
 else begin
   exportonlythis:=''{UpCased(name)...neexport by templaty};
   AddPageSupport(lst.items^[0],now_project,false{pages not inserted},false{no subpages},false{no templates});
   end;
 probFree;
 lst.SubFiles(typ_cla);
 lst.SubFiles(typ_dulezitejpic);
 lst.SubFiles(typ_nedulezitejpic);
 ReportFile:=nil;
 lst.FreeAll;
end;

procedure machReportFile(st:string);far;
var Dkod:TDkod;
begin
 Dkod:=GetDkod(st,false);
 if (Dkod<>0) then
  if (exportonlythis='') or (exportonlythis=UpCased(st)) or (fileIs(st) and isHypertext=0)
   then Rip(Dkod,dir4export+PathSlice(st,psFile));
 {chyby v projektu pri exportu nehlasi}
end;

{name musi byt skutecne jmeno vcetne pripadne pripony
 z aktualni stranky exportuje jen jeji jazyk,
 z podstromu vsechny jazyky}
PROCEDURE ExportSubtree4Mach(name,destdir:PathStr;subtree:boolean);
begin
 ReportFile:=machReportFile;
 dir4export:=destdir;
 {lst.AddFiles(typ_cla,AllLinkDestinations(erIgnore,PathSlice(name,psName)));}
 lst.AddFiles(typ_cla,name);
 if subtree then begin
   exportonlythis:='';
   AddPagesSupport(now_project,false{pages not inserted},true{subpages},true{templates})
   end
 else begin
   exportonlythis:=''{UpCased(name)...neexport by templaty};
   AddPageSupport(lst.items^[0],now_project,false{pages not inserted},false{no subpages},true{templates});
   end;
 probFree;
 lst.FreeAll;
 ReportFile:=nil;
end;

END.