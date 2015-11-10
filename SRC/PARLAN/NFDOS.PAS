Unit NFDos;{$i define.inc}{$f+}


Interface

 uses MyDef, MyDefin, Dos, DMFile,Vga;

 procedure InitNewFunc;
 procedure ErrorHandler(C:Integer);

 const debugScr:boolean=false;
 const ptrPlayFile:function(kod:TDkod):boolean=nil;

 Procedure CreateSystemAtoms;
 Procedure InitVars;

{---------vars-----------}

Const     vButtPics       ='enable_buttonpics';
          vPictures       ='enable_pictures';
          vAnimations     ='enable_animations';
          vSlideshows     ='enable_slideshows';
          vChangemode     ='enable_changemode';
          vModelist       ='enable_modelist';
          vInfopanel      ='enable_infopanel';
          vTests          ='enable_tests';
          vAvoidBadGfx    ='enable_avoidbadgfx';
          vIrq2           ='enable_irq2';
          vPreciseClock   ='enable_preciseclock';
          vHandlerMouse   ='enable_handlermouse';
          vHandlerKeyboard='enable_handlerkeyboard';
          vVolumeMusic    ='volume_music';
          vVolumeSample   ='volume_sample';
          vSpeedMouse     ='speed_mouse';
          vSpeedNumpad    ='speed_numpad';
          vSpeedAutoscrol ='speed_autoscrol';
          vSpeedArrows    ='speed_arrows';
          vSizeMouse      ='size_mouse';
          vDelayNextslide ='delay_nextslide';
          vDelayNextmusic ='delay_nextmusic';
          vDelayScreensav ='delay_screensaver';
          vEditpalFirst   ='editpal_first';
          vEditpalLast    ='editpal_last';
          vEditpalBright  ='editpal_bright';
          vEditpalContras ='editpal_contrast';
          vEditpalR       ='editpal_r';
          vEditpalG       ='editpal_g';
          vEditpalB       ='editpal_b';
          vPressedX       ='pressed_x';
          vPressedZ       ='pressed_z';
          vDirCom         ='dir_common';
          vShell          ='shell';
          vLanguage       ='language';

Var       editpalR       :boolean;
          editpalG       :boolean;
          editpalB       :boolean;
          editpalFirst   :byte;
          editpalLast    :byte;
          slideshows     :boolean;
{          changemodes    :boolean; tohle nahrazuju promennou staticMode}
{          longsamples    :boolean;
          shortsamples   :boolean;}

Implementation

 uses  MyVars, MyCode, MyFunc, MyLan, Strings,
       Objects,
       Memo,Chyby,Key,Mys,Fajly,Stringy,Dialogy,Atoms,DMAtoms,
       Loadery,Scrol,Fonty,Cache,Sys,DMBitmap,Supp,FlcPlay,Setup,
       {$ifdef rain}
       Rain2;
       {$else}
       Midas2;
       {$endif}


 function StrNewNoNil(pc:pchar):pchar; {jako StrNew ale nevraci nil}
  begin
    if (pc=nil) or (pc^=#0) then begin
      system.getmem(pointer(pc),1);
      pc^:=#0;
      StrNewNoNil:=pc;
      end
    else
      StrNewNoNil:=StrNew(pc);
  end;


 {level 1: popovani krabicek s typovou kontrolou apod}

 const erLowParams  =1000;
       erMuchParams =1001;
       erBadParam   =1002;

       cokoliv      =-3791;{cislo urcite ruzny od cisel typu parlanu}

 procedure ErrorHandler( C : Integer);
  begin
    case C of
       erLowParams  :dlgStr(RunError^+'Funkce o‡ek v  v¡c parametr–.');
       erMuchParams :dlgStr(RunError^+'Funkce o‡ek v  m¡¤ parametr–.');
       erBadParam   :dlgStr(RunError^+'Funkce o‡ek v  parametr jin‚ho typu.');
       else          dlgStr(RunError^);
    end;
  end;

 function PopTypedArg(var Prg,Stack:PData;typ:integer):PData;
  var result:PData;
  begin
   result:=PopArg(Stack);
   if result=nil then ErrorSignal(Prg,Stack,erLowParams) else
   if (typ<>cokoliv) and (result^.T<>typ) then ErrorSignal(Prg,Stack,erBadParam);
   PopTypedArg:=result;
  end;

 procedure Return(var Prg,Stack:PData;result:PData);
  var pops:integer;
  begin
    pops:=0;
    while PopArg(Stack)<>nil do inc(pops);
    PushArg(Stack,result);
    if pops>0 then ErrorSignal(Prg,Stack,erMuchParams);
  end;


 {level 2: nadstavba pro popovani krabicek bez parametru Prg a Stack}

 var myPrg,myStack:PPData;

 procedure PopInit(var Prg,Stack:PData);
  begin
    myPrg:=@Prg;
    myStack:=@Stack;
  end;

 procedure PopDone(result:PData);
  begin
    Return(myPrg^,myStack^,result);
    myPrg:=nil;
    myStack:=nil;
  end;

 function PopTyped(typ:integer):PData;
  begin
    PopTyped:=PopTypedArg(myPrg^,myStack^,typ);
  end;


 {level 3: nadstavba pro popovani pascalskych promennych}

 procedure PopAny;
  begin
    PopTyped(cokoliv);
  end;

 function PopInt:longint;
  var p:PData;
  begin
    p:=PopTyped(cInt);
    if p=nil then PopInt:=0 else PopInt:=p^.Data.Int;
  end;

 function PopPc:pchar;
  var p:PData;
  begin
    p:=PopTyped(cStr);
    if p=nil then PopPc:=nil else PopPc:=p^.Data.StrC;
  end;

 var someLong:longint;
 function PopPInt:Plong;
  var p:PData;
  begin
    p:=PopTyped(cInt);
    if p=nil then begin
      someLong:=0;
      PopPInt:=@someLong;
      end
    else PopPInt:=@p^.Data.Int;
  end;

 var somePc:pchar;
 function PopPPc:ppchar;
  var p:PData;
  begin
    p:=PopTyped(cStr);
    if p=nil then begin
      somePc:=nil;
      PopPPc:=@somePc;
      end
    else PopPPc:=@p^.Data.StrC;
  end;

 function PopStr:string;
  begin
    PopStr:=Pc2Str(PopPc);
  end;


 {vytvareni promennych parlanu}

 function NewInt(i:longint):PData;
  var n:PData;
  begin
    n:=GetFree;
    n^.T:=cInt;
    n^.Data.Int:=i;
    NewInt:=n;
  end;

 function NewBoo(b:boolean):PData;
  begin
    NewBoo:=NewInt(ord(b));
  end;

 function NewPc_destruct(pc:pchar):PData; {destruuje pc mimo memo.pas}
  var n:PData;
  begin
    n:=GetFree;
    n^.T:=cStr;
    n^.Data.StrC:=StrNewNoNil(pc);
    n^.Data.StrL:=StrLen(n^.Data.StrC);
    NewPc_destruct:=n;
  end;

 function NewPc(pc:pchar):PData; {nedestruuje pc}
  begin
    NewPc:=NewPc_destruct(StrNew(pc));
  end;

 function NewStr(st:string):PData;
  begin
    NewStr:=NewPc(Destr2Pc(st));
  end;


 {vlastni prikazy}
 {kdyz prikaz dostane parametr pchar, nesmi ho smazat}
 {kdyz prikaz vraci pchar, musi pocitat s tim ze ho parlan smaze}


 {dialogy, muzou se hodit}

 function dlgMsg(var Prg,Stack:PData):PData;
  begin
    PopInit(Prg,Stack);
    dialogy.dlgMsg(PopPc);
    PopDone(nil);
    dlgMsg:=nil;
  end;

 function dlgLine(var Prg,Stack:PData):PData;
  begin
    PopInit(Prg,Stack);
    PopDone(NewStr(dialogy.dlgLine(PopInt,PopStr,PopStr)));
    dlgLine:=nil;
  end;

   function GetArrayItem(p:pointer;w:word):pchar;far;
   begin
    GetArrayItem:=mydef.PParams(p)^[w]^.Data.StrC;
   end;

 function dlgMenu(var Prg,Stack:PData):PData;
  var arr:PData;
  begin
    PopInit(Prg,Stack);
    arr:=PopTyped(cArray);
    PopDone(NewInt(dialogy.dlgMenu(Pc2Str(GetArrayItem(arr^.Arr,0)),arr^.Count-1,GetArrayItem,@arr^.Arr^[1],PopInt)));
    dlgMenu:=nil;
  end;

 function dlgFile(var Prg,Stack:PData):PData;
  begin
    PopInit(Prg,Stack);
    PopDone(NewStr(dialogy.dlgSelector(PopInt,PopStr,PopStr,PopStr)));
    dlgFile:=nil;
  end;

 function dlgPath(var Prg,Stack:PData):PData;
  begin
    PopInit(Prg,Stack);
    PopDone(NewStr(dialogy.dlgPathBrowser(PopInt,PopStr,PopStr,PopStr)));
    dlgPath:=nil;
  end;


 {aby se dalo vybirat do ktereho adresare nainstalovat demo apod}

 function dirCur(var Prg,Stack:PData):PData;
  begin
    PopInit(Prg,Stack);
    PopDone(NewStr(fajly.dirCur));
    dirCur:=nil;
  end;

 function dirRun(var Prg,Stack:PData):PData;
  begin
    PopInit(Prg,Stack);
    PopDone(NewStr(dmfile.dirRun));
    dirRun:=nil;
  end;

 function dirIns(var Prg,Stack:PData):PData;
  begin
    PopInit(Prg,Stack);
    PopDone(NewStr(dmfile.dirIns));
    dirIns:=nil;
  end;

 function dirExe(var Prg,Stack:PData):PData;
  begin
    PopInit(Prg,Stack);
    PopDone(NewStr(fajly.dirExe));
    dirExe:=nil;
  end;

 function dirPrj(var Prg,Stack:PData):PData;
  begin
    PopInit(Prg,Stack);
    PopDone(NewStr(dmfile.dirPrj));
    dirPrj:=nil;
  end;

 function dirIni(var Prg,Stack:PData):PData;
  begin
    PopInit(Prg,Stack);
    PopDone(NewStr(dmfile.dirIni));
    dirIni:=nil;
  end;

 function dirTmp(var Prg,Stack:PData):PData;
  begin
    PopInit(Prg,Stack);
    PopDone(NewStr(fajly.dirTemp));
    dirTmp:=nil;
  end;

 function dirExists(var Prg,Stack:PData):PData;
  begin
    PopInit(Prg,Stack);
    PopDone(NewBoo(fajly.dirExists(PopStr)));
    dirExists:=nil;
  end;

 function dirWriteable(var Prg,Stack:PData):PData;
  begin
    PopInit(Prg,Stack);
    PopDone(NewBoo(fajly.dirWriteable(PopStr)));
    dirWriteable:=nil;
  end;

 function dirMake(var Prg,Stack:PData):PData;
  begin
    PopInit(Prg,Stack);
    PopDone(NewBoo(fajly.dirMake(PopStr)));
    dirMake:=nil;
  end;

 function dirChange(var Prg,Stack:PData):PData;
  begin
    PopInit(Prg,Stack);
    PopDone(NewBoo(fajly.dirChange(PopStr)));
    dirChange:=nil;
  end;

 function fileFind(var Prg,Stack:PData):PData;
  begin
    PopInit(Prg,Stack);
    PopDone(NewStr(fileFindInDirs(PopStr)));
    fileExists:=nil;
  end;

 function fileExists(var Prg,Stack:PData):PData;
  begin
    PopInit(Prg,Stack);
    PopDone(NewBoo(fajly.fileExists(PopStr)));
    fileExists:=nil;
  end;

 function fileLoad(var Prg,Stack:PData):PData;
  begin
    PopInit(Prg,Stack);
    PopDone(NewBoo(fajly.fileLoadPchar(Pc2Str(PopPc),nil,PopPPc^)));
    fileLoad:=nil;
  end;

 function fileSave(var Prg,Stack:PData):PData;
  begin
    PopInit(Prg,Stack);
    PopDone(NewBoo(fajly.fileSavePchar(0,Pc2Str(PopPc),PopPc)));
    fileSave:=nil;
  end;


 {zakladni nejcasteji pouzivane prikazy}

 function Exec(var Prg,Stack:PData):PData;
  var s:string;
      typ:byte;
      res:TError;
  begin
    PopInit(Prg,Stack);
    typ:=PopInt;
    s:=PopStr;
    res:=erOk;
    case typ of
      0:if s<>'' then if not CallCommand('/c '+s) then res:=_erCallCommand;
      1:res:=ExecCmd(10,true,s);
      2:res:=ExecCmd(10,false,s);{fore+nosound not supported, toto chovani je zpetna kompatibilita}
      3:res:=ExecCmd(10,false,s);
      end;
    if res<>erOk then dialogy.dlgError(res);
    PopDone(NewBoo(res=erOk));
    Exec:=nil;
  end;

 function ReadOnly(var Prg,Stack:PData):PData;
  begin
    PopInit(Prg,Stack);
    PopDone(NewBoo(readonlymod));
    ReadOnly:=nil;
  end;

 function Rip(var Prg,Stack:PData):PData;
  begin
    PopInit(Prg,Stack);
    PopDone(NewBoo(dmfile.Rip(GetDkod(PopStr,false),PopStr)));
    Rip:=nil;
  end;

 function Play(var Prg,Stack:PData):PData;
  begin
    PopInit(Prg,Stack);
    PopDone(NewBoo(ptrPlayFile(GetDkod(PopStr,false))));
    Play:=nil;
  end;


 {kontexty a atomy}

 function Context(var Prg,Stack:PData):PData;
  begin
    PopInit(Prg,Stack);
    PopDone(NewPc(dmatoms.cx(PopInt,PopInt,PopInt)));
    Context:=nil;
  end;

 function SetAtom(var Prg,Stack:PData):PData;
  begin
    PopInit(Prg,Stack);
    atom.aSet(PopPc{context},PopPc{name},StrNew(PopPc){value},TPermanency(PopInt));
    PopDone(nil);
    SetAtom:=nil;
  end;

 function GetAtom(var Prg,Stack:PData):PData;
  begin
    PopInit(Prg,Stack);
    PopDone(NewPc(atom.aGet(PopPc{context},PopPc{name})));
    GetAtom:=nil;
  end;

{-----------------------manipulace s vlastni mapou--------------------------}


const PixelsRelLeftRight  =0;
      PixelsRelLeftSize   =1;
      PixelsRelMidSize    =2;
      PixelsAbsLeftRight  =3;
      PixelsAbsLeftSize   =4;
      PixelsAbsMidSize    =5;
      PromileRelLeftRight =6;
      PromileRelLeftSize  =7;
      PromileRelMidSize   =8;
      PromileAbsLeftRight =9;
      PromileAbsLeftSize  =10;
      PromileAbsMidSize   =11;

Procedure Coord2AbsLeftSize(form:byte;var i,j,k,l:longint;sizeX,sizeY:word);
var rect:TRect;
const tisic:longint=1000;
begin
 aGetPxRect(cx(-1,-1,-1),rect);
 with rect do begin
   {prevede promile na pixely}
   case form div 3 of
     2:begin{PromileRel}
       i:=i*(b.x-a.x);
       j:=j*(b.y-a.y);
       k:=k*(b.x-a.x);
       l:=l*(b.y-a.y);
       end;
     3:begin{PromileAbs}
       i:=i*sizeX;
       j:=j*sizeY;
       k:=k*sizeX;
       l:=l*sizeY;
       end;
     else begin
       i:=i*tisic;
       j:=j*tisic;
       k:=k*tisic;
       l:=l*tisic;
       end;
     end;
   {provede ostatni konverze}
   case form mod 6 of
     PixelsAbsLeftSize :;
     PixelsRelLeftSize :begin inc(i,tisic*a.x);inc(j,tisic*a.y);end;
     PixelsAbsLeftRight:begin dec(k,i);dec(l,j);end;
     PixelsRelLeftRight:begin dec(k,i);dec(l,j);inc(i,tisic*a.x);inc(j,tisic*a.y);end;
     PixelsAbsMidSize  :begin dec(i,k div 2);dec(j,l div 2);end;
     PixelsRelMidSize  :begin dec(i,k div 2);dec(j,l div 2);inc(i,tisic*a.x);inc(j,tisic*a.y);end;
     end;
   end;
 {clipping}
 if i<0 then begin inc(k,i);i:=0;end;
 if j<0 then begin inc(l,j);j:=0;end;
 if i+k>tisic*sizeX then k:=tisic*sizeX-i;
 if j+l>tisic*sizeY then l:=tisic*sizeY-j;
 if k<0 then k:=0;
 if l<0 then l:=0;
 {rounding}
 k:=(i+k) div 1000;
 l:=(j+l) div 1000;
 i:=i div 1000;
 j:=j div 1000;
 dec(k,i);
 dec(l,j);{
 i:=i div 1000;
 j:=j div 1000;
 k:=k div 1000;
 l:=l div 1000;{}
end;

Function mapColor(rr,gg,bb:byte):longint;
begin
 if cur_mapDirect
  then mapColor:=cur_screen^.Color(rr,gg,bb,255)
  else mapColor:=cur_map^.Color(rr,gg,bb,255);
end;

Procedure mapLoadTo(name:pchar;form,a,b,c,d:longint);
var pic:PBitmap;
    oldmouse:boolean;
begin
 pic:=picLoad(DecodePic(Pc2Str(name)));
{ if pic=nil then pic:=picLoad(DecodePic('!error.pic'));}
 if pic<>nil then begin
   if cur_mapDirect
    then with cur_screen^ do begin
      Coord2AbsLeftSize(form,a,b,c,d,Xres,Yres);
      JoinMapTo(pic,cur_screen,false);
      oldmouse:=MouseHide;
      ResizeBtF2Box(0,pic,a,b,c,d);
      if oldmouse then MouseShow;
      end
    else with cur_map^ do begin
      Coord2AbsLeftSize(form,a,b,c,d,sizeX,sizeY);
      JoinMapTo(pic,cur_map,false);
      ResizeBtF2Box(0,pic,a,b,c,d);
      end;
    KillObj(pic);
    end;
end;

Procedure mapFillTo(col,form,a,b,c,d:longint);
var oldmouse:boolean;
begin
 if cur_mapDirect
  then with cur_screen^ do begin
    Coord2AbsLeftSize(form,a,b,c,d,Xres,Yres);
    oldmouse:=MouseHide;
    Col2Box(a,b,c,d,col);
    if oldmouse then MouseShow;
    end
  else with cur_map^ do begin
    Coord2AbsLeftSize(form,a,b,c,d,sizeX,sizeY);
    Col2Box(a,b,c,d,col);
    end;
end;

Procedure mapText(text,font:pchar;col,form,a,b:longint);
var fnt:PFont;
    c,d:longint;
begin
 if cur_mapDirect then exit;
 c:=0;
 d:=0;
 fnt:=cacheGetFont(Pc2Str(font));
 if fnt<>nil then begin
   with cur_map^ do Coord2AbsLeftSize(form,a,b,c,d,sizeX,sizeY);
   OutPc(text,cur_map,a,b,fnt,0,col);
   caLeave(fnt);
   end;
end;

Procedure mapRefreshTo(form,a,b,c,d:longint);
begin
 if cur_mapDirect then exit;
 with cur_map^ do Coord2AbsLeftSize(form,a,b,c,d,sizeX,sizeY);
 if cur_screen<>nil then cur_screen^.MapRedrawBox(a,b,c,d);
end;

Procedure mapLoad(name:pchar);
begin
 mapLoadTo(name,PromileRelLeftRight,0,0,1000,1000);
end;

Procedure mapFill(col:longint);
begin
 mapFillTo(col,PromileRelLeftRight,0,0,1000,1000);
end;

Procedure mapRefresh;
begin
 mapRefreshTo(PromileRelLeftRight,0,0,1000,1000);
end;

{-----------------------rizeny prehravani animacek--------------------------}

Type
      PAtomicFLCPlayer=^TAtomicFLCPlayer;
      TAtomicFLCPlayer=object(TIndirectFLCPlayer)
        constructor    Init(astream:PStream);
        function       Sync:boolean;virtual;
        destructor     Done;virtual;
       private
        stat_name      :Pchar;
        my_context     :Pchar;
       end;

Constructor TAtomicFLCPlayer.Init(astream:PStream);
var rect:TRect;
begin
 aGetPxRect(cx(-1,-1,-1),rect);
 if not inherited Init(astream,nil,cur_map,rect) then Fail;
 my_context:=StrNew(cx(-1,-1,-1));
 PDMBitmap(cur_map)^.playlist^.Insert(@self);
 stat_name:=StrNewStr('ani'+stri(random(65535)));
end;

Function TAtomicFLCPlayer.Sync:boolean;
var stat:string[7];
    inh:boolean;
    oldframe:word;
begin
 Sync:=false;
 stat:=Pc2Str(atom.aGet(my_context,stat_name));
 if waitingto=maxLong then waitingto:=minLong;
 if stat='frame' then looping:=true else
  if stat='loop' then looping:=true else
   if stat='noloop' then looping:=false
    else waitingto:=maxLong;
 aGetPxRect(my_context,destRect);
 oldframe:=frame;
 inh:=inherited Sync;
 Sync:=inh and (stat='noloop');
 if (inh and (stat='noloop')) or ((frame<>oldframe) and (stat='frame'))
  then atom.aSet(my_context,stat_name,nil,forDunno);
end;

Destructor TAtomicFLCPlayer.Done;
begin
 StrDispose(stat_name);
 StrDispose(my_context);
 inherited Done;
end;

Function InstallAnim(name:pchar):pchar;
var flic:PAtomicFLCPlayer;
    stream:PStream;
begin
 stream:=fileReadStream(Pc2Str(name));
 New(flic,Init(stream));
 if flic=nil then InstallAnim:=nil else begin
   InstallAnim:=flic^.stat_name;
   {atom.aSet(cx(-1,-1,-1),flic^.stat_name,StrNewStr('loop'),forDunno);
   flic^.Sync;
   atom.aSet(cx(-1,-1,-1),flic^.stat_name,nil,forDunno);}
   end;
end;

{-----------------------manipulace s vlastni mapou--------------------------}

 {manipulace s vlastni mapou}

 function _mapColor(var Prg,Stack:PData):PData;
  begin
    PopInit(Prg,Stack);
    PopDone(NewInt(mapColor(PopInt,PopInt,PopInt{rgb})));
    _mapColor:=nil;
  end;

 function _mapLoad(var Prg,Stack:PData):PData;
  begin
    PopInit(Prg,Stack);
    mapLoad(PopPc{name});
    PopDone(nil);
    _mapLoad:=nil;
  end;

 function _mapLoadTo(var Prg,Stack:PData):PData;
  begin
    PopInit(Prg,Stack);
    mapLoadTo(PopPc{name},PopInt{form},PopInt,PopInt,PopInt,PopInt{rect});
    PopDone(nil);
    _mapLoadTo:=nil;
  end;

 function _mapFill(var Prg,Stack:PData):PData;
  begin
    PopInit(Prg,Stack);
    mapFill(PopInt{color});
    PopDone(nil);
    _mapFill:=nil;
  end;

 function _mapFillTo(var Prg,Stack:PData):PData;
  begin
    PopInit(Prg,Stack);
    mapFillTo(PopInt{color},PopInt{form},PopInt,PopInt,PopInt,PopInt{rect});
    PopDone(nil);
    _mapFillTo:=nil;
  end;

 function _mapText(var Prg,Stack:PData):PData;
  begin
    PopInit(Prg,Stack);
    mapText(PopPc{text},PopPc{font},PopInt{color},PopInt{form},PopInt,PopInt{pos});
    PopDone(nil);
    _mapText:=nil;
  end;

 function _mapRefresh(var Prg,Stack:PData):PData;
  begin
    PopInit(Prg,Stack);
    mapRefresh;
    PopDone(nil);
    _mapRefresh:=nil;
  end;

 function _mapRefreshTo(var Prg,Stack:PData):PData;
  begin
    PopInit(Prg,Stack);
    mapRefreshTo(PopInt{form},PopInt,PopInt,PopInt,PopInt{rect});
    PopDone(nil);
    _mapRefreshTo:=nil;
  end;


 {rizena animace}

 function _InstallAnim(var Prg,Stack:PData):PData;
  begin
    PopInit(Prg,Stack);
    PopDone(NewPc(InstallAnim(PopPc{name})));
    _InstallAnim:=nil;
  end;

 function _Sync(var Prg,Stack:PData):PData;
  begin
    PopInit(Prg,Stack);
    if cur_screen<>nil then cur_screen^.Sync;
    PopDone(nil);
    _Sync:=nil;
  end;


 {events, drag & drop}

 const PixelsScreen        =0;
       PixelsPage          =1;
       PixelsObject        =2;
       PromileScreen       =3;
       PromilePage         =4;
       PromileObject       =5;

 function mouseGet(var Prg,Stack:PData):PData;
  var x,y:integer;
      rect:TRect;

  procedure mGet(fromScreen:boolean);
  begin
   if fromScreen
    then cur_screen^.MouseGetPos(PEN_SCREEN,x,y)
    else cur_screen^.MouseGetPos(PEN_VIRT_AREA,x,y);
  end;

  label 1,2;
  begin
    PopInit(Prg,Stack);
    if cur_screen<>nil then
     with cur_screen^ do begin
       case PopInt of
         PixelsScreen :begin
                       1:
                       mGet(true);
                       end;
         PromileScreen:begin
                       2:
                       mGet(true);
                       x:=longint(x)*1000 div Xres;
                       y:=longint(y)*1000 div Yres;
                       end;
         PixelsPage   :begin
                       if cur_mapDirect then goto 1;
                       mGet(false);
                       end;
         PromilePage  :begin
                       if cur_mapDirect then goto 2;
                       if cur_map<>nil then begin
                         mGet(false);
                         x:=longint(x)*1000 div cur_map^.sizeX;
                         y:=longint(y)*1000 div cur_map^.sizeY;
                         end;
                       end;
         PixelsObject :begin
                       aGetPxRect(cx(-1,-1,-1),rect);
                       mGet(cur_mapDirect);
                       dec(x,rect.a.x);
                       dec(y,rect.a.y);
                       end;
         PromileObject:begin
                       aGetPxRect(cx(-1,-1,-1),rect);
                       mGet(cur_mapDirect);
                       x:=longint(x-rect.a.x)*1000 div (rect.b.x-rect.a.x);
                       y:=longint(y-rect.a.y)*1000 div (rect.b.y-rect.a.y);
                       end;
         end;
       PopPInt^:=x;
       PopPInt^:=y;
       PopPInt^:=mouse.z;
       {Sync;}
       end;
    PopDone(nil);
    mouseGet:=nil;
  end;

 function eventGet(var Prg,Stack:PData):PData;
  var oldpen:byte;
      event:TEvent;
      pos:TPoint;
      rect:TRect;
      tp:longint;
      pe,px,py:PLong;
      res:boolean;
  label 1,2;
  begin
    PopInit(Prg,Stack);
    tp:=PopInt;{typ}
    pe:=PopPInt;{event}
    px:=PopPInt;{x}
    py:=PopPInt;{y}
    res:=false;
    with cur_screen^ do begin
      oldpen:=pen;
      case tp of
         PixelsScreen :begin
                       1:
                       pen:=PEN_SCREEN;
                       res:=GetEvent(event,pos);
                       if res then begin
                         px^:=pos.x;
                         py^:=pos.y;
                         end;
                       end;
         PromileScreen:begin
                       2:
                       pen:=PEN_SCREEN;
                       res:=GetEvent(event,pos);
                       if res then begin
                         px^:=longint(pos.x)*1000 div Xres;
                         py^:=longint(pos.y)*1000 div Yres;
                         end;
                       end;
         PixelsPage   :begin
                       if cur_mapDirect then goto 1;
                       pen:=PEN_VIRT_AREA;
                       res:=GetEvent(event,pos);
                       if res then begin
                         px^:=pos.x;
                         py^:=pos.y;
                         end;
                       end;
         PromilePage  :begin
                       if cur_mapDirect then goto 2;
                       if cur_map<>nil then begin
                         pen:=PEN_VIRT_AREA;
                         res:=GetEvent(event,pos);
                         if res then begin
                           px^:=longint(pos.x)*1000 div cur_map^.sizeX;
                           py^:=longint(pos.y)*1000 div cur_map^.sizeY;
                           end;
                         end;
                       end;
         PixelsObject :begin
                       pen:=PEN_VIRT_AREA;
                       if cur_mapDirect then pen:=PEN_SCREEN;
                       res:=GetEvent(event,pos);
                       if res then begin
                         aGetPxRect(cx(-1,-1,-1),rect);
                         px^:=pos.x-rect.a.x;
                         py^:=pos.y-rect.a.y;
                         end;
                       end;
         PromileObject:begin
                       pen:=PEN_VIRT_AREA;
                       if cur_mapDirect then pen:=PEN_SCREEN;
                       res:=GetEvent(event,pos);
                       if res then begin
                         aGetPxRect(cx(-1,-1,-1),rect);
                         px^:=longint(pos.x-rect.a.x)*1000 div (rect.b.x-rect.a.x);
                         py^:=longint(pos.y-rect.a.y)*1000 div (rect.b.y-rect.a.y);
                         end;
                       end;
         end;
      if res then pe^:=event;
      pen:=oldpen;
      end;
    PopDone(NewBoo(res));
    eventGet:=nil;
  end;

 {variables}

 procedure byte_to_left(p:PLong;var l:byte;max:word);far;
 begin
  p^:=Bounded(longint(l)*1000 div max,0,1000);
 end;

 procedure byte_to_right(p:PLong;var l:byte;max:word);far;
 begin
  l:=Bounded(p^*max div 1000,0,max);
 end;

 procedure boo_to_left(p:PLong;var b:boolean);far;
 begin
  p^:=ord(b);
 end;

 procedure boo_to_right(p:PLong;var b:boolean);far;
 begin
  b:=p^<>0;
 end;

 procedure str_to_left(p:PPchar;var s:openstring);far;
 begin
  if p<>nil then StrDispose(p^);
  p^:=StrNewNoNil(Str2Pc(s));
 end;

 procedure str_to_right(p:PPchar;var s:openstring);far;
 begin
  s:=Pc2Str(p^);
 end;

 type TRemap=procedure(p:PLong;var l:byte;max:word);
 type TMapboo=procedure(p:PLong;var b:boolean);
 type TMapstr=procedure(p:PPchar;var s:openstring);

 var  workpal:TPalBody;

 function GetBright:word;
 begin
  workpal:=cur_screen^.pal^.pal;
  GetBright:=500;
 end;

 procedure SetBright(i:integer);
 begin
  with cur_screen^.pal^ do begin
    pal:=workpal;
    SmoothBright(editpalFirst,editpalLast,i,editpalR,editpalG,editpalB);
    end;
 end;

 procedure SetContrast(i:integer);
 begin
  with cur_screen^.pal^ do begin
    pal:=workpal;
    SmoothContrast(editpalFirst,editpalLast,i,editpalR,editpalG,editpalB);
    end;
 end;

 function SmoothCols(var Prg,Stack:PData):PData;
  begin
    PopInit(Prg,Stack);
    with cur_screen^.pal^ do begin
      pal[editpalFirst].r:=PopInt;
      pal[editpalFirst].g:=PopInt;
      pal[editpalFirst].b:=PopInt;
      SmoothCols(editpalLast ,pal[editpalLast ].r,pal[editpalLast ].g,pal[editpalLast ].b,
                 editpalFirst,pal[editpalFirst].r,pal[editpalFirst].g,pal[editpalFirst].b);
      end;
    PopDone(nil);
    SmoothCols:=nil;
  end;

 function EndPaleting2(var Prg,Stack:PData):PData;
  var event:TEvent;
      pos:TPoint;
      result:byte;
  begin
    result:=0;
    PopInit(Prg,Stack);
    with cur_screen^ do
     while GetEvent(event,pos) do
      if code(event) in [mcLeftPressed,mcRightPressed,kEnter,kkEnter,kSpace,kEsc,kF12] then begin
        PushEvent(event);
        result:=1;
        break;
        end;
    PopDone(NewInt(result));
    EndPaleting2:=nil;
  end;

 function GetRGB(var Prg,Stack:PData):PData;
  begin
    PopInit(Prg,Stack);
    with cur_screen^.pal^.pal[PopInt] do begin
      PopPInt^:=4*r+r shr 4;
      PopPInt^:=4*g+g shr 4;
      PopPInt^:=4*b+b shr 4;
      end;
    PopDone(nil);
    GetRGB:=nil;
  end;

 procedure HandleVar(remap:TRemap;mapboo:TMapboo;mapstr:TMapstr);
  var   name:string[20];
  begin
    name:=PopStr;
    if name=''               then PopInt{ignore empty var} else
    if name=vButtPics        then mapboo(PopPInt,buttpics) else
    if name=vPictures        then mapboo(PopPInt,pictures) else
    if name=vAnimations      then mapboo(PopPInt,animations) else
    if name=vSlideshows      then mapboo(PopPInt,slideshows) else
    if name=vChangemode      then {mapboo(PopPInt,changemodes) else}
                                  begin
                                   if @mapboo=@boo_to_left then PopPInt^:=ord(staticMode.ChangeAllowed) else
                                    if PopInt<>0 then staticMode.SetDynamic else
                                     if cur_screen<>nil then staticMode.SetLike(cur_screen);
                                  end
                                  else
    if name=vModelist        then mapboo(PopPInt,ShowResolutions) else
    if name=vInfopanel       then mapboo(PopPInt,infobar) else
    if name=vTests           then mapboo(PopPInt,t_interact) else
    if name=vAvoidBadGfx     then mapboo(PopPInt,avoidBadGfx) else
    if name=vIrq2            then begin mapboo(PopPInt,irq2_enabled);screen^.ReadIrq2Enabled;end else
    if name=vPreciseClock    then if @remap=@byte_to_left then PopPInt^:=ord(GetPreciseClock)
                                                         else SetPreciseClock(PopInt<>0) else
    if name=vHandlerMouse    then if @remap=@byte_to_left then PopPInt^:=ord(mouseHandler)
                                                          else mouseSetHandler(PopInt<>0) else
    if name=vHandlerKeyboard then if @remap=@byte_to_left then PopPInt^:=ord(kHandler) else kSetHandler(PopInt<>0) else
    if name=vVolumeMusic     then remap(PopPInt,SS.musVolume,64) else
    if name=vVolumeSample    then remap(PopPInt,SS.smpVolume,64) else
    if name=vSpeedMouse      then begin remap(PopPInt,mouseSpeed,64);
                                  if cur_screen<>nil then cur_screen^.mouseAdjustSpeed;end else
    if name=vSpeedNumpad     then remap(PopPInt,citlivostNumpadu,64) else
    if name=vSpeedAutoscrol  then remap(PopPInt,autoscrolSpeed,64) else
    if name=vSpeedArrows     then remap(PopPInt,citlivostSipek,64) else
    if name=vSizeMouse       then begin remap(PopPInt,mouseSize,100);
                                  if cur_screen<>nil then MouseAdjustSize(cur_screen);end else
    if name=vDelayNextslide  then remap(PopPInt,rychlostSlideshow,20) else
    if name=vDelayNextmusic  then if @remap=@byte_to_left then PopPInt^:=SS.musGetSwitching
                                                          else SS.musSetSwitching(PopInt) else
    if name=vDelayScreensav  then remap(PopPInt,screenSaver,20) else
    if name=vEditpalR        then mapboo(PopPInt,editpalR) else
    if name=vEditpalG         then mapboo(PopPInt,editpalG) else
    if name=vEditpalB        then mapboo(PopPInt,editpalB) else
    if name=vEditpalFirst    then remap(PopPInt,editpalFirst,1000) else
    if name=vEditpalLast     then remap(PopPInt,editpalLast,1000) else
    if name=vEditpalBright   then if @remap=@byte_to_left then PopPInt^:=GetBright else SetBright(2*PopInt-1000) else
    if name=vEditpalContras  then if @remap=@byte_to_left then PopPInt^:=GetBright else SetContrast(2*PopInt-1000) else
    if name=vPressedZ        then mapboo(PopPInt,kPressed[kZ]) else
    if name=vPressedX        then mapboo(PopPInt,kPressed[kX]) else
    if name=vDirCom          then mapstr(PopPPc,LibDir) else
    if name=vShell           then mapstr(PopPPc,Shell) else
    if name=vLanguage        then mapstr(PopPPc,language) else
    begin dlgStr('Get/SetVar('+name+'=unknown)');PopAny;end;
    PopDone(nil);
  end;

 Procedure CreateSystemAtom(name,value:pchar);
 begin
  if atom.aGet(cx(0,0,0),name)=nil then atom.aSet(cx(0,0,0),name,value,forEver);
 end;

 Procedure CreateSystemAtoms;
 begin
  {CreateSystemAtom(vBackgrounds ,StrNewPc('1'));
  CreateSystemAtom(vPictures    ,StrNewPc('1'));
  CreateSystemAtom(vSlideshows  ,StrNewPc('1'));
  CreateSystemAtom(vAnimations  ,StrNewPc('1'));
  CreateSystemAtom(vChangemode  ,StrNewPc('1'));
  CreateSystemAtom(vInfopanel   ,StrNewPc('1'));
  CreateSystemAtom(vLongsamples ,StrNewPc('1'));
  CreateSystemAtom(vShortsamples,StrNewPc('1'));}
 end;

 function GetVar(var Prg,Stack:PData):PData;
  begin
    PopInit(Prg,Stack);
    HandleVar(byte_to_left,boo_to_left,str_to_left);
    GetVar:=nil;
  end;

 function SetVar(var Prg,Stack:PData):PData;
  begin
    PopInit(Prg,Stack);
    HandleVar(byte_to_right,boo_to_right,str_to_right);
    SetVar:=nil;
  end;

 Procedure InitVars;
 begin
  editpalR    :=true;
  editpalG    :=true;
  editpalB    :=true;
  editpalFirst:=1;
  editpalLast :=8;
  slideshows  :=true;
{  changemodes :=true; ...toto nahrazuju promennou staticMode}
{  longsamples :=true;
  shortsamples:=true;}
 end;

 {string parsing}

 function cutChar(var Prg,Stack:PData):PData;
  begin
    PopInit(Prg,Stack);
    {PopDone(NewInt(ord(StrRolChar(PopPPc^))));{do verze 3.05}
    PopDone(NewStr(StrRolChar(PopPPc^)));{od verze 3.10}
    cutChar:=nil;
  end;

 function cutInt(var Prg,Stack:PData):PData;
  begin
    PopInit(Prg,Stack);
    PopDone(NewInt(StrRolNum(PopPPc^)));
    cutInt:=nil;
  end;

 function cutString(var Prg,Stack:PData):PData;
  begin
    PopInit(Prg,Stack);
    PopDone(NewStr(StrRolStr(PopPPc^,PopPc^)));
    cutString:=nil;
  end;

 function cutName(var Prg,Stack:PData):PData;
  begin
    PopInit(Prg,Stack);
    PopDone(NewStr(StrRolName(PopPPc^)));
    cutName:=nil;
  end;

 {back to basics}

 function _val(var Prg,Stack:PData):PData;
  begin
    PopInit(Prg,Stack);
    PopDone(NewInt(Valu(PopStr)));
    _val:=nil;
  end;

 function _str(var Prg,Stack:PData):PData;
  begin
    PopInit(Prg,Stack);
    PopDone(NewStr(Stri(PopInt)));
    _str:=nil;
  end;


 {zaregistrovani prikazu}

 procedure InitNewFunc;
  begin
    DefineFunc('val'         ,@_val         );
    DefineFunc('str'         ,@_str         );

    DefineFunc('dlgMsg'      ,@dlgMsg       );
    DefineFunc('dlgLine'     ,@dlgLine      );
    DefineFunc('dlgMenu'     ,@dlgMenu      );
    DefineFunc('dlgFile'     ,@dlgFile      );
    DefineFunc('dlgPath'     ,@dlgPath      );

    DefineFunc('dirCur'      ,@dirCur       );
    DefineFunc('dirIns'      ,@dirIns       );
    DefineFunc('dirRun'      ,@dirRun       );
    DefineFunc('dirExe'      ,@dirExe       );
    DefineFunc('dirPrj'      ,@dirPrj       );
    DefineFunc('dirIni'      ,@dirIni       );
    DefineFunc('dirTmp'      ,@dirTmp       );

    DefineFunc('dirExists'   ,@dirExists    );
    DefineFunc('dirWriteable',@dirWriteable );
    DefineFunc('dirMake'     ,@dirMake      );
    DefineFunc('dirChange'   ,@dirChange    );

    DefineFunc('fileFind'    ,@fileFind     );{nezdokumentovano}
    DefineFunc('fileExists'  ,@fileExists   );
    DefineFunc('fileLoad'    ,@fileLoad     );
    DefineFunc('fileSave'    ,@fileSave     );

    DefineFunc('Exec'        ,@Exec         );
    DefineFunc('ReadOnly'    ,@ReadOnly     );
    DefineFunc('Rip'         ,@Rip          );
    DefineFunc('Play'        ,@Play         );

    DefineFunc('Context'     ,@Context      );
    DefineFunc('SetAtom'     ,@SetAtom      );
    DefineFunc('GetAtom'     ,@GetAtom      );
    DefineFunc('SetVar'      ,@SetVar       );
    DefineFunc('GetVar'      ,@GetVar       );

    DefineFunc('mapColor'    ,@_mapColor    );
    DefineFunc('mapLoad'     ,@_mapLoad     );
    DefineFunc('mapLoadTo'   ,@_mapLoadTo   );
    DefineFunc('mapFill'     ,@_mapFill     );
    DefineFunc('mapFillTo'   ,@_mapFillTo   );
    DefineFunc('mapText'     ,@_mapText     );
    DefineFunc('mapRefresh'  ,@_mapRefresh  );
    DefineFunc('mapRefreshTo',@_mapRefreshTo);

    DefineFunc('InstallAnim' ,@_InstallAnim );
    DefineFunc('Sync'        ,@_Sync        );

    DefineFunc('mouseGet'    ,@mouseGet     );
    DefineFunc('eventGet'    ,@eventGet     );

    DefineFunc('SmoothCols'  ,@SmoothCols   );
    DefineFunc('EndPaleting2',@EndPaleting2 );
    DefineFunc('GetRGB'      ,@GetRGB       );

    DefineFunc('cutChar'     ,@cutChar      );
    DefineFunc('cutInt'      ,@cutInt       );
    DefineFunc('cutString'   ,@cutString    );
    DefineFunc('cutName'     ,@cutName      );

    DefineConst('forDunno'           ,longint(forDunno)   );
    DefineConst('forPagetime'        ,longint(forPagetime));
    DefineConst('forRuntime'         ,longint(forRuntime) );
    DefineConst('forImplicit'        ,longint(forImplicit));
    DefineConst('forEver'            ,longint(forEver)    );

    DefineConst('PixelsRelLeftRight' ,PixelsRelLeftRight  );
    DefineConst('PixelsRelLeftSize'  ,PixelsRelLeftSize   );
    DefineConst('PixelsRelMidSize'   ,PixelsRelMidSize    );
    DefineConst('PixelsAbsLeftRight' ,PixelsAbsLeftRight  );
    DefineConst('PixelsAbsLeftSize'  ,PixelsAbsLeftSize   );
    DefineConst('PixelsAbsMidSize'   ,PixelsAbsMidSize    );
    DefineConst('PromileRelLeftRight',PromileRelLeftRight );
    DefineConst('PromileRelLeftSize' ,PromileRelLeftSize  );
    DefineConst('PromileRelMidSize'  ,PromileRelMidSize   );
    DefineConst('PromileAbsLeftRight',PromileAbsLeftRight );
    DefineConst('PromileAbsLeftSize' ,PromileAbsLeftSize  );
    DefineConst('PromileAbsMidSize'  ,PromileAbsMidSize   );

    DefineConst('PixelsScreen'       ,PixelsScreen        );
    DefineConst('PixelsPage'         ,PixelsPage          );
    DefineConst('PixelsObject'       ,PixelsObject        );
    DefineConst('PromileScreen'      ,PromileScreen       );
    DefineConst('PromilePage'        ,PromilePage         );
    DefineConst('PromileObject'      ,PromileObject       );

    DefineConstStr('cr'              ,#13                 );
    DefineConstStr('lf'              ,#10                 );
    DefineConstStr('endl'            ,#13#10              );

    OldVars:=Vars;
  end;


end.



todo:
 -do kazduho scr automaticky naincludit template.scr
