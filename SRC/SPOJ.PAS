{$I-,N+,M 4000,0,0}

USES dos,sluzby,crt;

{$i data.inc}

TYPE  string40=string[40];

CONST
      daypauza=15;
      prefile  ='par12a';
      preproj1 ='Pa©eni®tà 12';
      preproj2 ='Dal®° screenshoty';
      preproj3 ='Slideshow';
      prepop   ='P12';
      ender:char=#255;

VAR
      totalheadlen,
      instream,fajl,
      sourcehand,desthand,workseg,
      offsetst,offsetdest,offsetsize,
      sizelo,sizehi,nowfile                    :word;
      size                                     :longint absolute sizelo;
      progres,totalsize                        :longint;
      useold,opened                            :boolean;
      lst,hea                                  :text;
      st,full,dest,header1,header2             :string;
      DirInfo                                  :SearchRec;
      myDateTime                               :DateTime;
      Year, Month, Day, DayOfWeek              :Word;
      fullpath                                 :array[1..300] of string[20];
      leng                                     :array[1..300] of longint;
      datastream                               :array[1..10000] of byte;
      add,adds,xorit                           :byte;
      head                                     :array[1..10] of record
                                                   filename:string[12];
                                                   projekt :string;
                                                   addonfor:string;
                                                   popisek :string[5];
                                                   fajlu   :word;
                                                  end;

PROCEDURE Ehalt(n:byte);
begin
 writeln;
 case n of 0:;
           1:writeln('Malo pameti !!!!!!!!!!!!!!!!');
           2:writeln('Nemuzu vytvorit soubor ',dest,'!!!!!');
           3:writeln('Nemuzu najit soubor ',st,' !!!!!');
           4:writeln('Chybny nazev projektu, nastuduj rozsirenou hvezdickovou konvenci...');
           5:writeln('Nemuzu zapisovat do souboru ',dest,', asi malo mista na disku !!!!!');
           6:writeln('Nejdriv pouzij MAKELIST.EXE.');
        else writeln('BUGGGGGG!!!!!!!!');
           end;
 asm mov ax,0c08h;int 21h;end;
 halt;
end;

PROCEDURE Pridej(st:string);
var   last:byte;
      i:word;
begin
 while xorit=0 do begin
   randomize;
   xorit:=random(256);
   instream:=1;
   datastream[instream]:=xorit;
   end;

 for i:=1 to length(st) do begin
   inc(instream);
   datastream[instream]:=datastream[instream-1] xor ord(st[i])+39;
   end;
end;


var   i,j,k,l:word;
      data:string[8];

label 1,2;

BEGIN
 data:=paramstr(1);
 if copy(data,1,4)<>'data' then data:='data'+data;
 offsetst:=ofs(st);
 offsetdest:=ofs(dest);
 asm
   {alloc}
    mov bx,65536/16;mov ah,48h;int 21h;mov workseg,ax
    jnc @okej;push 1;call ehalt;@okej:
   end;
 assign(lst,data+'.lst');
 assign(hea,data+'.hea');


 {zjisti z datalistu kolik bude addonu}
 reset(lst);
 if ioresult>0 then ehalt(6);
 adds:=1;
 i:=0;
 while not eof(lst) do begin
   inc(i);
   readln(lst,st);
   fullpath[i]:=st;
   if st='' then begin inc(adds);dec(i);end else inc(head[adds].fajlu);
   end;
 l:=0;
 for j:=2 to i do for k:=1 to j-1 do if fullpath[j]=fullpath[k] then begin
   writeln('Soubor ',fullpath[j],' je v seznamu vickrat!');
   l:=1;
   end;
 if l=1 then ehalt(0);

 {naloaduje datahead}
 useold:=false;
 FindFirst(data+'.hea', anyfile-directory, DirInfo);
 opened:=false;
 if doserror=0 then begin
   opened:=true;
   getdate(Year, Month, Day, DayOfWeek);
   unpackTime(dirinfo.time,mydatetime);
   if 365*Year+31*Month+Day-daypauza<365*mydatetime.Year+31*mydatetime.Month+mydatetime.Day then useold:=true;
   reset(hea);
   for add:=1 to adds do with head[add] do begin
     if not eof(hea) then readln(hea,filename);
     if not eof(hea) then readln(hea,projekt);
     if not eof(hea) then readln(hea,addonfor);
     if not eof(hea) then readln(hea,popisek);
     end;
   end;

 {vygeneruje zbytek dataheadu}
 for add:=1 to adds do with head[add] do begin
  if filename=''then if add=1 then filename:=prefile else begin
                                                          filename:=head[add-1].filename;inc(filename[ord(filename[0])]);
                                                          end;
  if projekt='' then case add of 1:projekt:=preproj1;
                                 2:projekt:=preproj2;
                                 3:projekt:=preproj3;
                                 end;
  if addonfor=''then if add=1 then addonfor:=''      else addonfor:=head[1].projekt+'*';
  if popisek='' then if add=1 then popisek:=prepop   else popisek:='';
  if not useold then begin
    filename:=ask(1,'Zadej nazev '+chr(48+add)+'. souboru *.DM (bez koncovky)...',8,filename,'!');
    projekt :=ask(1,'Nazvi obsah '+chr(48+add)+'. souboru...',40,projekt,' ');
    addonfor:=ask(1,'Pokud to neni hlavni *.DM soubor, zadej k cemu je to'#13+
              'prislusenstvi. A muzes pouzivat rozsirenou hvezdickovou konvenci.',40,addonfor,' ');
    if addonfor='' then popisek:=ask(1,'Zadej 2-3 pismennou zkratku nazvu.',5,popisek,' ');
    end;
  end;

 {sejvne datahead}
 for add:=1 to adds do with head[add] do begin
   odstranuvozovky(projekt);
   odstranuvozovky(addonfor);
   if not odpovidakonvenci(projekt) or not odpovidakonvenci(addonfor) then ehalt(4);
   end;
 rewrite(hea);
 for add:=1 to adds do with head[add] do begin
   writeln(hea,filename);
   writeln(hea,projekt);
   writeln(hea,addonfor);
   writeln(hea,popisek);
   end;
 close(hea);

 reset(lst);

{‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹}
 for add:=1 to adds do with head[add] do begin
{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}

 write(#13#10#10#10);
 if add>1 then readln(lst,st);

 if addonfor>'' then header1:=headfirst+verze+headbreak+headaddon+' "'+projekt+'" '+headfor+' "'+addonfor+'"'+headlast
                else header1:=headfirst+verze+headbreak+headroot +' "'+projekt+'"'                           +headlast;


 {----------------checkne soubory z datalistu----------------------}
 nowfile:=1;
 totalsize:=0;
 progres:=0;
 instream:=0;
 xorit:=0;
 writeln;

 for fajl:=1 to fajlu do begin

   readln(lst,st);
   upcasestring(@st);
   full:=st;FindFirst(full, anyfile-directory, DirInfo);
   if doserror>0 then begin
     full:='x\'+st;
     FindFirst(full, anyfile-directory, DirInfo);
     if doserror>0 then begin
       full:='wav\'+st;
       FindFirst(full, anyfile-directory, DirInfo);
       if doserror>0 then ehalt(3);
       end;
     end;

   fullpath[nowfile]:=full;
   leng    [nowfile]:=dirinfo.size;
   pridej(st[0]+st+chr(dirinfo.size shr 16)+chr(dirinfo.size shr 8)+chr(dirinfo.size));
   totalsize:=totalsize+dirinfo.size;
   j:=pos('.',st);if j=0 then j:=length(st)+1;
   writeln('                        ',copy(st,1,j-1),copy(st,j,200):10-2*j+length(st),dirinfo.size:12-length(st)+j);
   inc(nowfile);
   end;

 writeln('              -----------------------------------------');
 st:=filename+'.dm';
 j:=pos('.',st);if j=0 then j:=length(st)+1;
 write('                        ',copy(st,1,j-1),copy(st,j,200):10-2*j+length(st),totalsize:12-length(st)+j);
 dec(nowfile);


 header2:=#0#0{flags}
          +chr(nowfile)+chr(nowfile shr 8){pocet fajlu}
          +popisek[0]+popisek{popisek}
          ;
 totalheadlen:=length(header1)+2+length(header2)+instream;

 {---zapise kompletni header---}
 dest:=filename+'.dm'#0;
 asm
  {create dest}
   mov ax,3c00h;mov cx,0;mov dx,offsetdest;inc dx;int 21h;mov desthand,ax;
   jnc @ok;push 2;call ehalt;;@ok:
  {zapise header, filelist}
   mov bx,desthand;lea dx,1+header1   ;mov ch,0;mov cl,[offset header1];mov ah,40h;int 21h
   mov bx,desthand;lea dx,totalheadlen;mov cx,2                        ;mov ah,40h;int 21h
   mov bx,desthand;lea dx,1+header2   ;mov ch,0;mov cl,[offset header2];mov ah,40h;int 21h
   mov bx,desthand;lea dx,datastream  ;mov cx,instream                 ;mov ah,40h;int 21h
  end;


 for i:=1 to nowfile{} do begin
   st:=fullpath[i]+#0;
   size:=leng[i];
   asm
    {open source}
     mov ax,3d00h;mov dx,offsetst;inc dx;int 21h;mov sourcehand,ax;jnc @ok
     push 3;call ehalt
     @ok:

     push sizehi
     push sizelo

    @loop:
     cmp sizehi,0;jz @last
     mov cx,65536/2;call @xfer
     mov cx,65536/2;call @xfer
     dec sizehi
     jmp @loop
    @last:
     mov cx,sizelo;call @xfer
     jmp @close

    @xfer:
    {read data}
     push cx
     mov bx,sourcehand;mov dx,0
     push ds;mov ds,workseg;mov ah,3fh;int 21h;pop ds;
    {write data}
     pop cx
     mov bx,desthand;mov dx,0
     push ds;mov ds,workseg;mov ah,40h;int 21h;pop ds;
     jc @ehalt5
     ret

     @ehalt5:
     push 5
     call ehalt

     @close:
    {close source}
     mov bx,sourcehand;mov ah,3eh;int 21h;

     pop sizelo
     pop sizehi
    end;

    progres:=progres+size;
    write(#13);
    write(round(progres*100/totalsize),'%');
   end;

 asm
  {close dest}
   mov bx,desthand;mov ah,3eh;int 21h;
  end;


{‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹}
 end;
{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}

{----------------------------END----------------------------}

 asm
  {dealloc}
   mov ah,49h;mov es,workseg;int 21h;
  end;

END.


