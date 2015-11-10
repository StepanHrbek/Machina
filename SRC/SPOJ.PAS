UNIT Spoj;

INTERFACE {$i define.inc}

Uses Dos;

PROCEDURE SpojList(destdir:PathStr);

IMPLEMENTATION

USES Chyby,Memo, Objects, fajly,stringy,Dialogy,sys,vga,dmfile;

{$i data.inc}

TYPE  PFileInfo=^TFileInfo;
      TFileInfo=object(TObject)
        name:PString;
        size:longint;
        constructor Init(aname:string;asize:longint);
        destructor Done;virtual;
        end;

Constructor TFileInfo.Init(aname:string;asize:longint);
begin
 name:=NewStr(aname);
 size:=asize;
end;

Destructor TFileInfo.Done;
begin
 DisposeStr(name);
end;




PROCEDURE SpojList(destdir:PathStr);

 CONST
       forceNewHea:boolean=false;
       daypauza=15;
       prefile  ='rt41a';
       preproj1 ='Realtime 41';
       preproj2 ='Optional data';
       prepop   ='R41';
       ender:char=#255;

 VAR
       totalheadlen,
       instream,fajl,
       sourcehand,desthand,
       offsetst,offsetdest,
       nowfile                                  :word;
       size                                     :longint;
       progres,totalsize                        :longint;
       useold,opened                            :boolean;
       lst,hea                                  :text;
       st,full,dest                             :string;
       DirInfo                                  :SearchRec;
       myDateTime                               :DateTime;
       Year, Month, Day, DayOfWeek              :Word;
       datastream                               :PLine;
       add,adds,xorit                           :byte;

 TYPE  thead             =array[1..maxDMsInPrj] of record
                            filename:string;
                            projekt :string;
                            addonfor:string;
                            popisek :string;
                            fajlu   :word;
                          end;
 VAR   head              :^thead;

       files             :TCollection;

 PROCEDURE Ehalt(n:byte);
 begin
  BiosWriteln('');
  case n of 0:;
            2:BiosWriteln(_(_erNelzeVytvSoub)+' '+GetCore(dest)+'.');
            3:BiosWriteln(_(_erChybiSoub)+' '+st+'.');
            4:BiosWriteln(_(_erSpatnyNazevPrj));
            5:BiosWriteln(_(_erNelzePsatSoub)+' '+GetCore(dest)+', '+_(_erAsiMaloMista));
            6:BiosWriteln(_(_erNejdrivKompiluj));
         else BiosWriteln('BUGGGGGG!');
            end;
  WaitKey;
  Halt(_erWritten);
 end;

 PROCEDURE Pridej(st:string);
 var   last:byte;
       i:word;
 begin
  while xorit=0 do begin
    randomize;
    xorit:=random(256);
    instream:=1;
    datastream^[instream]:=xorit;
    end;

  for i:=1 to length(st) do begin
    inc(instream);
    datastream^[instream]:=byte(datastream^[instream-1] xor ord(st[i])+39);
    end;
 end;

 PROCEDURE odstranuvozovky(var st:string);
 begin
  if pos('"',st)>0 then begin
    CutString(st,'"');
    st:=CutString(st,'"');
    end;
 end;

 FUNCTION fullpath(n:word):string;
 begin
  fullpath:=PFileInfo(files.items^[n])^.name^;
 end;

 FUNCTION leng(n:word):longint;
 begin
  leng:=PFileInfo(files.items^[n])^.size;
 end;

 FUNCTION Zprava(st:string;spaces:word):string;
 begin
  while length(st)<spaces do st:=' '+st;
  Zprava:=copy(st,length(st)+1-spaces,255);
 end;



 var   i,j,k,l:word;
       s:TScreen;
       t:SearchRec;
       header:string absolute freeS;{tento string musi byt v DS}

 label 1,2;

BEGIN
 new(head);
 if head=nil then Halt(erLowMem);
 fillchar(head^,sizeof(head^),0);
 datastream:=freeptr;
 dumb:=false;
 offsetst:=ofs(st);
 offsetdest:=ofs(dest);
 assign(lst,datalist);
 assign(hea,datahead);

 {zjisti z datalistu kolik bude addonu}
 if not files.Init(500,500) then Halt(erLowMem);
   FindFirst(datalist,0,t);if doserror<>0 then ehalt(6);
   reset(lst);
   if ioresult>0 then ehalt(6);
   adds:=1;
   while not eof(lst) do begin
     readln(lst,st);
     if st='' then inc(adds) else begin
       files.Insert(New(PFileInfo,Init(st,0)));
       inc(head^[adds].fajlu);
       end;
     end;
   l:=0;
   if files.count>1{aby count-2 na dalsi radce nepodteklo} then
    for j:=1 to files.count-2 do for k:=0 to j-1 do
     if fullpath(j)=fullpath(k) then begin
       BiosWriteln(fullpath(j)+' '+_(_msgJeVSeznVickrat));
       l:=1;
       end;
   if l=1 then ehalt(0);
 files.FreeAll;

 {naloaduje datahead}
 useold:=false;
 FindFirst(datahead, anyfile-directory, DirInfo);
 opened:=false;
 if doserror=0 then begin
   opened:=true;
   getdate(Year, Month, Day, DayOfWeek);
   unpackTime(dirinfo.time,mydatetime);
   if 365*longint(Year)+31*Month+Day-daypauza<365*longint(mydatetime.Year)+31*mydatetime.Month+mydatetime.Day
    then useold:=true;
   reset(hea);
   for add:=1 to adds do with head^[add] do begin
     if not eof(hea) then readln(hea,filename);
     if not eof(hea) then readln(hea,projekt);
     if not eof(hea) then readln(hea,addonfor);
     if not eof(hea) then readln(hea,popisek);
     end;
   end;

 {vygeneruje zbytek dataheadu}
 for add:=1 to adds do with head^[add] do begin
  if filename=''then if add=1       then filename:=prefile else begin
                                                               filename:=head^[add-1].filename;inc(filename[ord(filename[0])]);
                                                                end;
  if projekt='' then if add=1       then projekt:=preproj1 else projekt:=preproj2;
  if addonfor=''then if add=1       then                   else addonfor:=head^[1].projekt+'*';
  if popisek='' then if addonfor='' then popisek:=prepop;
  if forceNewHea then useold:=false;
  if not useold then begin
    s.Init(model_text,80,25,0);
    filename:=PathSlice(dlgLine(0,_i(_spZadejNazevDMFile,chr(48+add)),filename),psPath+psName);
    projekt :=dlgLine(0,_i(_spNazviObsahDM,chr(48+add)),projekt);
    addonfor:=dlgLine(0,_(_spJeToPrislusenstvi1)+#13+_(_spJeToPrislusenstvi2),addonfor);
    if addonfor='' then popisek:=dlgLine(0,_(_spZadejZkratku),popisek);
    s.Done;
    end;
  end;

 {sejvne datahead}
 for add:=1 to adds do with head^[add] do begin
   odstranuvozovky(projekt);
   odstranuvozovky(addonfor);
   if not hkIsOk(projekt) or not hkIsOk(addonfor) then ehalt(4);
   end;
 rewrite(hea);
 for add:=1 to adds do with head^[add] do begin
   writeln(hea,filename);
   writeln(hea,projekt);
   writeln(hea,addonfor);
   writeln(hea,popisek);
   end;
 close(hea);

 reset(lst);





{‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹}
 for add:=1 to adds do with head^[add] do begin
{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}

 BiosWrite(#13#10#10#10);
 if add>1 then readln(lst,st);


 {----------------checkne soubory z datalistu----------------------}
 nowfile:=1;
 totalsize:=0;
 progres:=0;
 instream:=0;
 xorit:=0;
 BiosWriteln('');

 files.FreeAll;

 for fajl:=1 to fajlu do begin

   readln(lst,st);
   upcasni(st);
   full:=locatefile(st);
   while pos(':',st)>0 do cutstring(st,':');
   while pos('\',st)>0 do cutstring(st,'\');
   FindFirst(full, anyfile-directory, DirInfo);
   if doserror>0 then ehalt(3);

   files.Insert(New(PFileInfo,Init(full,dirinfo.size)));

   pridej(st[0]+st+chr(dirinfo.size shr 16)+chr(dirinfo.size shr 8)+chr(dirinfo.size));
   totalsize:=totalsize+dirinfo.size;

   j:=pos('.',st);if j=0 then j:=length(st)+1;
   BiosWriteln('                        '+copy(st,1,j-1)
     +Zprava(copy(st,j,200),10+length(st)-2*j)+Zprava(stri(dirinfo.size),12+j-length(st)));
   inc(nowfile);
   end;

 BiosWriteln('              -----------------------------------------');
 st:=filename+'.dm';
 j:=pos('.',st);if j=0 then j:=length(st)+1;
 BiosWriteln('                        '+copy(st,1,j-1)
     +Zprava(copy(st,j,200),10+length(st)-2*j)+Zprava(stri(totalsize),12+j-length(st)));
 dec(nowfile);


 {---zapise kompletni header---}
 if PathSlice(filename,psPath)<>'' then destdir:='';
 dest:=destdir+filename+'.dm'#0;

 {ovsem nejdriv ho vygeneruje}
 if addonfor>'' then header:=headfirst+verze+headbreak+headaddon+' "'+projekt+'" '+headfor+' "'+addonfor+'"'+headlast
                else header:=headfirst+verze+headbreak+headroot +' "'+projekt+'"'                           +headlast;
 totalheadlen:=length(header)+2+2+2+1+length(popisek)+instream;
 header:=header
          +chr(totalheadlen)+chr(totalheadlen shr 8){delka headeru}
          +#0#0{flags}
          +chr(nowfile)+chr(nowfile shr 8){pocet fajlu}
          +popisek[0]+popisek{popisek}
          ;
 asm
  {create dest}
   mov ax,3c00h;mov cx,0;mov dx,offsetdest;inc dx;push ds;push ss;pop ds;int 21h;pop ds
   mov desthand,ax;jnc @ok
   push 2;push bp;call ehalt
   @ok:
  {zapise header, filelist}
   mov ah,40h;mov bx,desthand;mov ch,0;mov cl,[offset header];lea dx,1+header;int 21h
   mov ah,40h;mov bx,desthand;mov cx,instream                ;push ds;lds dx,datastream;inc dx;int 21h;pop ds
  end;


 if nowfile>0 then
  for i:=0 to nowfile-1 do begin
   st:=fullpath(i)+#0;
   size:=leng(i);
   asm
    {open source}
     mov ax,3d00h;mov dx,offsetst;inc dx;push ds;push ss;pop ds;int 21h;pop ds
     mov sourcehand,ax;jnc @ok
     push 3;push bp;call ehalt
     @ok:

     db 66h;push word ptr size

    @loop:
     cmp word ptr size+2,0;jz @last
     mov cx,65536/2;call near ptr @xfer
     mov cx,65536/2;call near ptr @xfer
     dec word ptr size+2
     jmp @loop
    @last:
     mov cx,word ptr size;call @xfer
     jmp @close

    @xfer:
    {read data}
     push cx
     mov bx,sourcehand;mov dx,0
     push ds;mov ds,freeseg;mov ah,3fh;int 21h;pop ds;
    {write data}
     pop cx
     mov bx,desthand;mov dx,0
     push ds;mov ds,freeseg;mov ah,40h;int 21h;pop ds;
     jc @ehalt5
     cmp ax,cx
     jne @ehalt5
     retn

     @ehalt5:
     push 5;push bp;call ehalt

     @close:
    {close source}
     mov bx,sourcehand;mov ah,3eh;int 21h;

     db 66h;pop word ptr size
    end;

    progres:=progres+size;
    BiosWrite(#13);
    if totalsize=0
     then BiosWrite('100%')
     else BiosWrite(stri(round(progres/totalsize*100))+'%');
   end;

 asm
  {close dest}
   mov bx,desthand;mov ah,3eh;int 21h;
  end;


{‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹}
 end;
{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}

 BiosWriteln('');
End;


END.


strka zkratku do addonu
zachova stary jmeno prvniho souboru
