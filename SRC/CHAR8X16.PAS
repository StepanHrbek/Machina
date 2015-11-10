{$define tlustej_}
{$R-}
uses crt;

const lastchar='©';
{$ifdef tlustej}
      ble='tlustej';
      {$i tlustej.inc}
{$else}
      ble='tenkej';
      {$i tenkej.inc}
{$endif}

var a:array[' '..lastchar,0..15] of byte;
const lena=sizeof(a);

VAR mx,my,mz,x,y,z,i,j:integer;
    ch:char;
    c:char;

CONST chgon:boolean=false;
      cz:array[0..5] of byte=(0,28,2*(32+28),48,29,19);
      ca:array[1..30] of byte=
    (128,130,131,133,134,135,136,137,139,143,144,145,146,149,150,151,152,155,157,158,159,160,161,162,163,164,165,166,168,169);
      cb:array[1..30] of char=
    ('C','e','d','D','T','c','e','E','I','A','E','z','Z','O','u','U','y','S','Y','R','t','a','i','o','u','n','N','U','s','r');
      cc:array[1..30] of byte=
    ( 2 , 1 , 2 , 2 , 2 , 2 , 2 , 2 , 1 , 1 , 1 , 2 , 2 , 1 , 3 , 1 , 1 , 2 , 1 , 2 , 2 , 1 , 1 , 1 , 1 , 2 , 2 , 3 , 2 , 2 );


PROCEDURE Save;
var i,j:integer;
    f:text;
    c:char;
begin if chgon then begin
 assign(f,ble+'.inc');
 rewrite(f);
 writeln(f,'const ',ble,':array['' ''..''',lastchar,''',0..15] of byte=(');
 for c:=' ' to lastchar do begin
   write(f,'(');
   for j:=0 to 14 do write(f,a[c,j],',');
   write(f,a[c,15],')');
   if c<lastchar then writeln(f,',') else writeln(f,');');
   end;
 close(f);
end;end;

PROCEDURE Q(xx,yy,zz:integer);
begin
 gotoxy(22+4*xx,5+yy);
 textbackground(zz);
 write('    ');
end;

procedure SHOW;
var i,j:integer;
    b:array[0..7] of byte;
begin
 asm mov ax,2;int 33h;end;
 for j:=0 to 15 do begin
   for i:=0 to 7 do begin b[i]:=a[c,j] shr (7-i) mod 2;q(i,j,0);end;
   for i:=1 to 7 do if b[i]=1 then q(i-1,j,b[i]);
   for i:=0 to 6 do if b[i]=1 then q(i+1,j,b[i]*2);
   for i:=0 to 7 do if b[i]=1 then q(i  ,j,b[i]*3);
   end;
 asm mov ax,1;int 33h;end;
 gotoxy(24+4*x,5+y);
end;

PROCEDURE SetColor(color,r,g,b:byte);assembler;
 asm mov dx,3c8h;mov al,color;out dx,al;inc dx;mov al,r;out dx,al;mov al,g;out dx,al;mov al,b;out dx,al;end;

LABEL 1;

BEGIN
{$ifdef tlustej}
 move(tlustej,a,sizeof(a));
{$else}
 move(tenkej,a,sizeof(a));
{$endif}
{
 asm
  push ds
  mov ah,11h;mov al,30h;mov bh,6;push bp;int 10h;
  mov si,bp;pop bp
  mov di,offset a+(128-32)*16
  mov cx,128*8
  mov ax,es
  mov bx,ds
  mov es,bx
  mov ds,ax
  add si,128*16
  rep movsw
  pop ds
  end;
 for c:=' ' to '' do for i:=0 to 15 do a[c,i]:=b[c,i];
}

{ for c:=#32 to #255 do begin j:=a[c,15];for i:=15 downto 1 do a[c,i]:=a[c,i-1];a[c,0]:=j;end;}
{ for i:=1 to 30 do begin a[chr(ca[i])]:=a[cb[i]];if cz[cc[i]]>0 then a[chr(ca[i]),0]:=cz[cc[i]];end;}


 textattr:=7;clrscr;
 x:=0;y:=0;c:='T';
 setcolor(1, 0, 0,43);
 setcolor(2,15,15,53);
 setcolor(3,30,30,63);

{ for c:=' ' to lastchar do for i:=0 to 15 do a[c,i]:=a[c,i] shl 1;{}
 show;
 asm mov ax,1;int 33h;end;
 repeat
   gotoxy(24+4*x,5+y);
   delay(150);
   asm mov ax,3;int 33h;sub cx,21*8;sub dx,4*8;shr cx,5;mov mx,cx;shr dx,3;mov my,dx;mov mz,bx;end;
   if mx<8 then x:=mx;
   if my<16 then y:=my;
   if mz>0 then goto 1;
   if keypressed then begin
     ch:=readkey;
     case ch of    #13:begin 1:a[c,y]:=a[c,y] xor 128 shr x;chgon:=true;show;end;
                   #80:if y<15 then inc(y);
                   #72:if y>0 then dec(y);
                   #75:if x>0 then dec(x);
                   #77:if x<7 then inc(x);
                   ',':begin for i:=0 to 15 do a[c,i]:=a[c,i] shl 1;chgon:=true;show;end;
                   '.':begin for i:=0 to 15 do a[c,i]:=a[c,i] shr 1;chgon:=true;show;end;
                    #9:begin for i:=0 to 15 do a[c,i]:=0;chgon:=true;show;end;
                   '+':if c<lastchar then begin inc(c);show;end;
                   '-':if c>' ' then begin dec(c);show;end;
                   '*':if ord(c)+10<ord(lastchar) then begin inc(c,11);show;end;
                   '/':if ord(c)-10>32  then begin dec(c,11);show;end;
                   's':save;
         ' '..lastchar:begin c:=ch;show;end;
                   end;
     end;

 until ch=#27;
end.