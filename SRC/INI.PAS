TYPE  stringpath=string[80];
      string10=string[10];
      uknastring=^string;
CONST debuginfo=false;
VAR   biosfree   :pointer absolute 0:$4f0;

PROCEDURE ErrorHalt(n:word);assembler;
 asm push n;push n;xor ax,ax;mov es,ax;call [es:biosfree];end;

PROCEDURE ErrorMsg(st:string);
begin
 asm mov ax,3;int 10h;end;
 writeln(st);
 errorhalt(46);
end;

FUNCTION LoCaseString(st:string):string;
var i:byte;
begin
 for i:=1 to length(st) do case st[i] of 'A'..'Z':inc(st[i],32);end;
 LoCaseString:=st;
end;

PROCEDURE UpCaseString(p:uknastring);
var i:byte;
begin
 for i:=1 to length(p^) do case p^[i] of 'a'..'z':dec(p^[i],32);end;
end;

CONST hexy:array[0..15] of char='0123456789abcdef';

FUNCTION Dehexy(ch:char):byte;
begin
 case ch of '0'..'9':dehexy:=ord(ch)-ord('0');
            'a'..'f':dehexy:=ord(ch)-ord('a')+10;
            'A'..'F':dehexy:=ord(ch)-ord('A')+10;
                else dehexy:=255;
                end;
end;

{лллллллллллллллл INI лллллллллллллллл}

var   typprom:byte;
      adrprom:word;
      vars_ofs,vars_seg:word;
      vars_ptr:pointer absolute vars_ofs;

FUNCTION FindVariable(name:string):boolean;
begin
     asm mov @result,0
         mov typprom,100
         mov es,vars_seg;mov si,vars_ofs;dec si;dec si
         mov di,offset name;add di,bp
         @nextstring:
         add si,2
         mov ah,255{dylka stringu}
         mov bl,0{zatim neni zadny rozdil}
         @nextbyte:
         inc ah
         seges lodsb;cmp al,30;jc @endofstr
         inc di;cmp al,[ss:di];jz @stejny;mov bl,1;@stejny:
         jmp @nextbyte
         @endofstr:
         seges lodsb{nacte flags}
         {v ES narazil na konec stringu}
          {neni uz konec seznamu vars ?}
          cmp ah,0;jz @badkonec
          {shodny dylky ?}
          mov di,offset name;add di,bp;cmp ah,[ss:di];jnz @nextstring
          {zadny rozdily ?}
          or bl,bl;jnz @nextstring
         {byla nalezena shoda}
         mov typprom,al{typ promenny}
         seges lodsw;mov adrprom,ax{adresa promenny}
         mov @result,1
         @badkonec:
         end;
end;

const msg_diskfull='Mozna je plny disk, nelze zapisovat.';

{var=    ..neudela nic, ponecha puvodni udaje (u booleanu 255)
 var=ano ..nastavi 1
 var=ne  ..nastavi 0}
FUNCTION ReadIni(INIname:stringpath;vars:pointer):Boolean;
var   f:text;
      uknastring:^string;
      st,name,udaj:string;
      someword,i,code:word;
      udajuvIni,somebyte,j:byte;

Begin
 if debuginfo then writeln('Hledam ',INIname);
 vars_ptr:=vars;
 assign(f,INIname);
 reset(f);
 if ioresult>0 then ReadIni:=false else begin
  ReadIni:=true;
  udajuvIni:=0;
  while not eof(f) do begin
   readln(f,st);
   if (st[0]>#0) and (st[1]<>';') then begin
     i:=pos('=',st);
     name:=locasestring(copy(st,1,i-1));
     udaj:=locasestring(copy(st,i+1,200));
     if FindVariable(name) then case typprom and 7 of
                   0,1:if udaj<>'' then begin
                         if udaj='ne' then somebyte:=0 else
                         if udaj='ano' then somebyte:=1 else begin
                           val(udaj,somebyte,code);
                           if code>0 then errormsg('Chybny udaj v radce: '+st);
                          end;
                         byte(mem[dseg:adrprom]):=somebyte;
                         end;
                     2:if udaj<>'' then begin
                         val(udaj,someword,code);
                         if code>0 then errormsg('Chybne cislo v radce: '+st);
                         word(memw[dseg:adrprom]):=someword;
                         end;
                     4:if udaj<>'' then begin
                         someword:=0;
                         for i:=1 to length(udaj) do begin
                           j:=dehexy(udaj[i]);
                           if j>15 then errormsg('Chybne hexadecimalni cislo v radce: '+st);
                           someword:=someword shl 4+j;
                           end;
                         word(memw[dseg:adrprom]):=someword;
                         end;
                   3,5:if udaj<>'' then begin
                         uknastring:=ptr(dseg,adrprom);
                         if typprom and 7=3 then upcasestring(@udaj){stringy prevede na upcase}
                                            else udaj:=copy(st,i+1,200);{nacte puvodni zneni stringu}
                         uknastring^:=udaj;
                         end;
                     else errormsg('Interni chyba INI readeru.');
                     end{ else errormsg('Neznamy parametr v INI souboru: '+st){};
     end;
   end;
  close(f);
  end;
End;

PROCEDURE delFakenew_New2Fakenew_openFakenew_createNew(var f,g:text;INI:stringpath);
const bleble='old.ini';
var fakeINI:stringpath;
begin
 fakeINI:=copy(INI,1,pos('\',INI))+bleble;
 DeleteFile(fakeINI);
 RenameFile(INI,fakeINI,true);
 assign(f,fakeINI);
 reset(f);
 assign(g,INI);
 rewrite(g);
end;


PROCEDURE WriteIni(INIname:stringpath;vars:pointer;filtr:byte);
var   f,g:text;
      st,name,udaj:string;
      someword,i,code:word;
      somebyte:byte;
      uknastring:^string;
Begin
 vars_ptr:=vars;
 code:=0;
 delFakenew_New2Fakenew_openFakenew_createNew(f,g,INIname);
 while not eof(f) do begin
   readln(f,st);
   if (st[0]>#0) and (st[1]<>';') then begin
     i:=pos('=',st);
     if i=0 then errormsg('Chybna syntaxe v INI na radce: '+st);
     name:=copy(st,1,i-1);
     if FindVariable(locasestring(name)) and ((typprom and filtr)>0) then begin
       case typprom and 7 of
                     0:begin
                       somebyte:=byte(mem[dseg:adrprom]);
                       case somebyte of 0:udaj:='ne';
                                        1:udaj:='ano';
                                      255:udaj:='';
{                                      else udaj:='******************'+chr(somebyte);{}
                                      else errormsg('Chybna hodnota promenne pri ukladani INI.');{}
                                      end;
                       end;
                     1:begin
                       somebyte:=byte(mem[dseg:adrprom]);
                       if somebyte=255 then udaj:='' else str(somebyte,udaj);
                       end;
                     2:begin
                       someword:=word(memw[dseg:adrprom]);
                       if someword=65535 then udaj:='' else str(someword,udaj);
                       end;
                     4:begin
                       someword:=word(memw[dseg:adrprom]);
                       udaj:='';
                       if someword<>65535 then repeat
                                                 udaj:=hexy[someword mod 16]+udaj;
                                                 someword:=someword shr 4;
                                               until someword=0;
                       end;
                   3,5:begin
                       uknastring:=@mem[dseg:adrprom];
                       udaj:=uknastring^;
                       end;
                     end;
       st:=name+'='+udaj;
       end;
     end;
   writeln(g,st);
   if ioresult<>0 then errormsg(msg_diskfull);
   end;
 close(f);
 erase(f);
 close(g);
End;

PROCEDURE ModifyIniPodleIni(NewIni,OldIni:stringpath);
var   f,g:text;
      st,name:string;
      i,j:word;
      udaju:byte;
      a:array[1..maxudajuINI] of string[80];
Begin
 {precte vyznamny radky z puvodniho INI}
 assign(f,OldIni);
 reset(f);
 udaju:=0;
 while not eof(f) do begin
   readln(f,st);
   if (st[0]>#0) and (st[1]<>';') then begin
     name:=copy(st,1,pos('=',st)-1);
     typprom:=32;
     if (not FindVariable(locasestring(name))){updatuje nenalezeny veci}
     or ((typprom and 32)=0){updatuje nalezeny bez flagu 32} then begin
       if udaju>=maxudajuINI then errorhalt(50+13) else inc(udaju);
       a[udaju]:=st;
       end;
     end;
   end;
 close(f);

 {modifikuje novej INI podle staryho}
 delFakenew_New2Fakenew_openFakenew_createNew(f,g,newini);
 while not eof(f) do begin
   readln(f,st);
   if (st[0]>#0) and (st[1]<>';') then begin
     j:=pos('=',st);
     for i:=1 to udaju do if copy(st,1,j-1)=copy(a[i],1,j-1) then st:=a[i];
     end;
   writeln(g,st);
   if ioresult<>0 then errormsg(msg_diskfull);
   end;
 close(f);
 erase(f);
 close(g);
End;

