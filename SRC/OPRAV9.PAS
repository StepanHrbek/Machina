USES dos;

const dvoucifcislo='07';
      donename :string[14]='par09.dm'#0;
      headname :string[14]='data.$$$'#0;
      bakname  :string[14]='par09.bak'#0;
      notfound:boolean=true;
      buflen=60000;

{      oldheadsize=$869;
      newheadsize=2192;}

      oldheadsize=$890;
      newheadsize=2207;

var   myhand,srchand,desthand:word;
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

    @bad:
    call restoreolddta
    end;

LABEL er1;
BEGIN
 if paramstr(1)<>'x' then begin
   writeln('Na konec PAR09.DM jsi uz pripojil hudbu, pridej jeste 09YEEES.WAV a');
   writeln('spust me s parametrem x.');
   halt;
   end;

 initdatafile;

 assign(f,donename);         if ioresult>0 then goto er1;
 rename(f,bakname);          if ioresult>0 then goto er1;

 assign(f,headname);         if ioresult>0 then goto er1;
 rename(f,donename);         if ioresult>0 then goto er1;

 writeln('Kopiruju data...');
 asm
   {open dest}
    mov ax,3d01h;lea dx,1+donename;int 21h;mov desthand,ax;jc er1
   {seek end dest}
    mov ax,4202h;mov bx,desthand;mov cx,0;mov dx,0;int 21h;jc er1

   {open src}
    mov ax,3d00h;lea dx,1+bakname;int 21h;mov srchand,ax;jc er1
   {seek src zaheader}
    mov ax,4200h;mov bx,srchand;mov cx,0;mov dx,oldheadsize;int 21h;jc er1

    @readnext:
   {read src}
    mov bx,srchand;mov cx,buflen;lea dx,buf;mov ah,3fh;int 21h;mov readen,ax
   {write dest}
    mov bx,desthand;mov cx,readen;lea dx,buf;mov ah,40h;int 21h;jc er1
    cmp readen,0;jnz @readnext

   {close all}
    mov bx,srchand;mov ah,3eh;int 21h;
    mov bx,desthand;mov ah,3eh;int 21h;

    end;
 writeln('Hotovo...');
 assign(f,bakname);erase(f); if ioresult>0 then goto er1;
 halt;
 er1:err('...');
END.