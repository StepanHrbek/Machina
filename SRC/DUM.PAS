{$define z}
uses  sluzby,crt;
var   stat,x1,x2,y1,y2,x,y,z:word;
      f:text;
CONST movmode=136;
      addmode=  0;
      submode= 40;
      andmode= 32;
      ormode =  8;
      xormode= 48;
      posun:word=0;
      writemode:byte=movmode;

PROCEDURE Line(x1,y1,x2,y2,barva:byte);assembler;
asm  mov al,writemode;segcs mov [offset @2+1],al
     mov ax,0a000h;mov es,ax;mov dh,barva          {dh=barva}
     mov al,160;mul y1;shl ax,1;add al,x1;adc ah,0;add ax,posun;mov di,ax    {di=adresa prvniho bodu}
     mov al,x1;mov ah,x2;sub ah,al;mov bx,1;jnc @8;neg bx;neg ah   {ah=delta X}
  @8:mov dl,y1;mov al,y2;sub al,dl;mov si,320;jnc @7;neg si;neg al {al=delta Y}
  @7:cmp ah,al;jnc @1;xchg al,ah;xchg bx,si
  @1:mov dl,ah;inc al;inc ah;mov ch,0;mov cl,ah    {cx=pocet cyklu}

  @2:seges mov [di],dh
     add di,bx
     sub dl,al
     jnc @3
     add dl,ah
     add di,si
  @3:loop @2
     end;

begin
 asm mov ax,13h;int 10h;end;
 stat:=0;
 assign(f,'dum.dat');
 {$ifdef zadavani}
 mouseon;
 rewrite(f);
 repeat
  getmouse(x,y,z);
  x:=x div 2;
  if (stat=0) and (z>0) then begin
    stat:=1;
    x1:=x;
    y1:=y;
    end;
  if (stat=1) and (z>0) then begin
    writemode:=xormode;
    mouseoff;
    line(x1,y1,x,y,1);
    mouseon;
    refresh(2);
    mouseoff;
    line(x1,y1,x,y,1);
    mouseon;
    writemode:=movmode;
    end;
  if (stat=1) and (z=0) then begin
    stat:=0;
    x2:=x;
    y2:=y;
    mouseoff;
    line(x1,y1,x2,y2,15);
    mouseon;
    writeln(f,x1,',',y1,',',x2,',',y2);
    end;
 until keypressed;
{$else}
 reset(f);
 posun:=32;
 while not eof(f) do begin
   readln(f,x1,y1,x2,y2);
   line(x1,y1,x2,y2,15);
   end;
{$endif}
 close(f);
 readkey;
end.