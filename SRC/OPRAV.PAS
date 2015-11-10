USES dos;

const dvoucifcislo='07';
      oldname :string[14]='pareni'+dvoucifcislo+'.exe'#0;
      oldname2:string[14]='pareni'+dvoucifcislo+'.old'#0;
      newname :string[14]='pareni'+dvoucifcislo+'.new'#0;
      notfound:boolean=true;
      buflen=60000;

      oldheadsize=$869;
      newheadsize=
var   myhand,oldhand,newhand:word;
      header:array[1..30] of byte;
      cestakexe:string;
      myexelenglo,myexelenghi,oldexelenglo,oldexelenghi:word;
      myexeleng:longint absolute myexelenglo;
      oldexeleng:longint absolute oldexelenglo;
      buf:array[1..buflen] of byte;
      readen:word;
      f:file;

PROCEDURE Err(st:string);
begin
 writeln;
 writeln('CHYBA: ',st);
 writeln;
 writeln('--------------------');
 writeln('     DEBUG INFO');
 writeln('--------------------');
 writeln('    myhand:',myhand);
 writeln('   oldhand:',oldhand);
 writeln('   newhand:',newhand);
 writeln(' cestakexe:',cestakexe);
 writeln(' myexeleng:',myexeleng);
 writeln('oldexeleng:',oldexeleng);
 halt;
end;

VAR   oldDTAofs,oldDTAseg:word;
      newDTA:array[1..43] of byte;

PROCEDURE RestoreOldDta;assembler;
 asm mov ah,1ah;mov dx,oldDTAofs;push ds;mov ds,oldDTAseg;int 21h;pop ds;end;

PROCEDURE StoreOldDta;assembler;
 asm mov ah,2fh;int 21h;mov oldDTAseg,es;mov oldDTAofs,bx
     mov ah,1ah;mov dx,offset newDTA;int 21h;end;

PROCEDURE notexe;
begin
 err('Soubor '+oldname+' neni klasicky EXE soubor.');
end;

PROCEDURE InitDataFile;assembler;
var pathstart,pathend,pathseg,realDS:word;
 asm
    call storeolddta
    mov realDS,DS
   {get psp,environment,selfpath}
    mov ah,62h;int 21h;mov es,bx;mov ds,[es:02ch];mov pathseg,DS
    mov di,65535;mov ax,0;
    @1:inc di;cmp [di],ax;jnz @1;add di,4
   {copy path to 'cestaKexe'}
    mov pathstart,di
    mov ES,realDS
    mov si,di
    lea di,cestaKexe+1
    mov ah,0;
    mov cl,0
   @12:lodsb;stosb;inc ah;
    cmp al,'\';jnz @nolom;mov cl,ah;@nolom:
    or al,al;jnz @12;
    mov pathend,si
    mov [es:offset cestaKexe],cl
   {open self}
    mov ax,3d00h;mov dx,pathstart;int 21h
    mov DS,realDS
    mov myhand,ax
   {read exe header - 6 bytes}
    mov bx,myhand;mov cx,6;mov dx,offset header;mov ah,3fh;int 21h;
   {pocita dylku exe fajlu}
    {cmp word ptr [offset header],'ZM';jz @exe;jmp notexe;@exe:}
    mov ax,[offset header+4];dec ax;shl ax,1;mov bh,0;mov bl,ah;shl ax,8
    mov cx,[offset header+2];add ax,cx;or cx,cx;jnz @zz;add ax,512;@zz:
    mov [offset myexeleng],ax;mov [offset myexeleng+2],bx

   {open ten co budu patchovat}
    mov ax,3d00h;lea dx,1+oldname;int 21h;jc @bad
    mov notfound,0
    mov oldhand,ax
   {read exe header - 6 bytes}
    mov bx,oldhand;mov cx,6;mov dx,offset header;mov ah,3fh;int 21h;
   {pocita dylku exe fajlu}
    cmp word ptr [offset header],'ZM';jz @exe;jmp notexe;@exe:
    mov ax,[offset header+4];dec ax;shl ax,1;mov bh,0;mov bl,ah;shl ax,8
    mov cx,[offset header+2];add ax,cx;or cx,cx;jnz @zz2;add ax,512;@zz2:
    mov [offset oldexeleng],ax;mov [offset oldexeleng+2],bx

    @bad:
    call restoreolddta
    end;

LABEL er1,er2;
BEGIN
 initdatafile;
 if notfound then err('Soubor '+oldname+'nenalezen v beznem adresari.');
 writeln('Zalohuju puvodni soubor...');
 asm
   {open new}
    mov ax,3c00h;mov cx,0;lea dx,1+newname;int 21h;jc er1
    mov notfound,1
    mov newhand,ax
   {my to myexeleng}
    mov ax,4200h;mov bx,myhand;mov cx,myexelenghi;mov dx,myexelenglo;int 21h;
   {old to oldexeleng}
    mov ax,4200h;mov bx,oldhand;mov cx,oldexelenghi;mov dx,oldexelenglo;
    int 21h;

    @readnext:
   {read myexe}
    mov bx,myhand;mov cx,buflen;lea dx,buf;mov ah,3fh;int 21h;mov readen,ax
   {write new}
    mov bx,newhand;mov cx,readen;lea dx,buf;mov ah,40h;int 21h;jc er2
    cmp readen,0;jnz @readnext

    @readnext2:
   {read oldexe}
    mov bx,oldhand;mov cx,buflen;lea dx,buf;mov ah,3fh;int 21h;mov readen,ax
   {write new}
    mov bx,newhand;mov cx,readen;lea dx,buf;mov ah,40h;int 21h;jc er2
    cmp readen,0;jnz @readnext2

   {close all}
    mov bx,newhand;mov ah,3eh;int 21h;
    mov bx,oldhand;mov ah,3eh;int 21h;
    mov bx,myhand;mov ah,3eh;int 21h;

    end;
 writeln('Hotovo...');
 assign(f,oldname2);erase(f);if ioresult>0 then ;
 assign(f,oldname);rename(f,oldname2);
 assign(f,newname);rename(f,oldname);
 writeln('EXE opraven. Starou verzi EXE souboru (nyni ma koncovku OLD) muzes smazat.');
 halt;

 er1:err('Nelze vytvorit pracovni soubor '+newname+'...');
 er2:err('Nelze zapsat do pracovniho souboru '+newname+'... Asi plny disk.');
END.