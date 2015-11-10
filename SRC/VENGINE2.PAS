{ verze: 0.9 pro CiA - 28.7.1998 }
{ kod: Daniel Sykora (ReDox/MovSD) * (C) 1998 }

Unit      VEngine2;
Interface {$i define.inc}
Uses      Chyby,Vga;
Function  Init:TError;
Procedure Done;

const XRES = 640;
      YRES = 480;

const Max = 300; { maximalni pocet facu }

type PTable = ^TTable; { typ dat pro tabulky Sin a Cos }
     TTable = Array[0..16383] of Integer;

     PSortData = ^TSortData; { typ dat pro QuickSort }
     TSortData = Record  id:Word;Value:Longint end;

     PPoint = ^TPoint; { typ dat 2D/3D bodu }
     TPoint = Array[1..3] of Longint;

     PPoints = ^TPoints; { typ dat pole 2D/3D bodu }
     TPoints = Array[1..Max] of TPoint;

     PSortArray = ^TSortArray; {typ dat pro Face-QuickSort }
     TSortArray = Array[1..Max] of TSortData;

     TData  = Array[0..XRES] of Integer;
     PData = ^TData; { typ dat pro Bresenhamovu interpolaci }

var _Sin,_Cos : PTable;TableMask : Word;
    { tabulky Sin, Cos a Maska urcijici jejich velikost }

Procedure Line(x1,y1,x2,y2:Integer;C:Longint;B:PAbstractMap);
Procedure FlatFace(x1,y1,x2,y2,x3,y3:Integer;C:Longint;B:PAbstractMap);
Procedure InitSinCos(BitSize:Byte);
Procedure Move3D(var Points:TPoints;Count:Word;_dx,_dy,_dz:Longint);
Procedure AddPerspective(var Points:TPoints;Count:Word;SF:Byte;Zd:Longint);
Procedure Rotate3D(var SPoints,DPoints:TPoints;Count:Word;rx,ry,rz:Integer);
Procedure QSort(var SortList:Array of TSortData;Count:Word);
Function  IsVisible(x1,y1,x2,y2,x3,y3:Integer):Integer;

implementation

procedure Line;

var i, dx, dy, np,
    d, di1, di2,
    x, xi1, xi2,
    y, yi1, yi2 : integer;

begin

  dx := abs(x2 - x1);
  dy := abs(y2 - y1);

  if dx >= dy then
    begin
      np  := dx + 1;
      d   := dy shl 1 - dx;
      di1 := dy shl 1;
      di2 := (dy - dx) shl 1;
      xi1 := 1;
      xi2 := 1;
      yi1 := 0;
      yi2 := 1;
    end
  else
    begin
      np  := dy + 1;
      d   := dx shl 1 - dy;
      di1 := dx shl 1;
      di2 := (dx - dy) shl 1;
      xi1 := 0;
      xi2 := 1;
      yi1 := 1;
      yi2 := 1;
    end;

  if x1 > x2 then
    begin
      xi1 := - xi1;
      xi2 := - xi2;
    end;
  if y1 > y2 then
    begin
      yi1 := - yi1;
      yi2 := - yi2;
    end;

  x := x1;
  y := y1;

  for i := 1 to np do
    begin
      B^.Col2Box(x,y,1,1,C);
      if d < 0 then
        begin
          d := d + di1;
          x := x + xi1;
          y := y + yi1;
        end
      else
        begin
          d := d + di2;
          x := x + xi2;
          y := y + yi2;
        end;
    end;
end;

{ interpoluje mezi hodnotami x1 a x2 od y1 do y2 pomoci
  Bresenhamova algoritmu a orezava na rozliseni XRESxYRES
  - vysledek se uklada jako Word }

var Clipping:Boolean;
    Visible:Byte;

procedure Interpol_Clip(x1, y1, x2, y2 : integer; data:pdata);
var i, dx, dy, npix,
    d, di1, di2,
    x, xi1, xi2, xi, yi,
    y, yi1, yi2 : integer;
begin

  dx := abs(x2 - x1);
  dy := abs(y2 - y1);

  if dx >= dy then
    begin

      npix := dx + 1;
      d :=  dy shl 1 - dx;
      di1 := dy shl 1;
      di2 := (dy - dx) shl 1;
      xi1 := 1;
      xi2 := 1;
      yi1 := 0;
      yi2 := 1;
    end
  else
    begin

      npix := dy + 1;
      d := dx shl 1 - dy;
      di1 := dx shl 1;
      di2 := (dx - dy) shl 1;
      xi1 := 0;
      xi2 := 1;
      yi1 := 1;
      yi2 := 1;
    end;

  if x1 > x2 then
    begin
      xi1 := - xi1;
      xi2 := - xi2;
    end;
  if y1 > y2 then
    begin
      yi1 := - yi1;
      yi2 := - yi2;
    end;

  x := x1;
  y := y1;

  for i := 1 to npix do
    begin
      Xi:=X;Yi:=Y;
      if Yi>YRES-1 then Yi:=YRES-1;
      if Yi<0 then Yi:=0;
      if Xi>XRES-1 then Xi:=XRES-1;
      if Xi<0 then Xi:=0;
      Data^[yi]:=xi;
      if d < 0 then
        begin
          d := d + di1;
          x := x + xi1;
          y := y + yi1;
        end
      else
        begin
          d := d + di2;
          x := x + xi2;
          y := y + yi2;
        end;
    end;
end;

{ interpoluje mezi hodnotami x1 a x2 od y1 do y2 pomoci
  Bresenhamova algoritmu - vysledek se uklada jako Word }
procedure Interpol_Word(x1, y1, x2, y2 : integer; data:pdata);assembler;
var i, d_x, d_y, npix,
    d, di1, di2,
    x, xi1, xi2,
    y, yi1, yi2 : integer;
asm
  mov ax,[x2]
  mov bx,[x1]
  mov cx,[y2]
  mov dx,[y1]
  sub ax,bx
  jae @@x
  neg ax
  @@x: { |x1 - x2| }
  sub cx,dx
  jae @@y
  neg cx
  @@y: { |y1 - y2| }
  mov [xi1],1
  mov [xi2],1
  mov [yi1],0
  mov [yi2],2
  cmp ax,cx     { d_x >= d_y }
  jae @noxchg
  mov [xi1],0
  mov [yi1],2
  xchg ax,cx
  @noxchg:
  mov bx,ax     { bx <- d_x }
  mov dx,cx     { dx <- d_y }
  mov [npix],bx { d_x }
  shl dx,1
  mov [di1],dx  { d_y * 2 }
  sub dx,ax
  mov [d],dx    { d_y * 2 - d_x }
  sub cx,ax
  shl cx,1
  mov [di2],cx  { (d_y - d_x) * 2 }
  mov ax,[x1]
  mov bx,[x2]
  cmp ax,bx
  jna @nonegx   { x1 <= x2 }
  neg xi1
  neg xi2
  @nonegx:
  mov ax,[y1]
  mov bx,[y2]
  cmp ax,bx
  jna @nonegy   { y1 <= y2 }
  neg yi1
  neg yi2
  @nonegy:
  les di,[data]
  mov si,npix
  inc si

  mov ax,[x1]

  cmp ax,0
  jnl @@clipx1
  xor ax,ax
  @@clipx1:

  mov bx,[y1]

  cmp bx,0
  jnl @@clipy1
  xor bx,bx
  @@clipy1:

  shl bx,1
  add di,bx
  mov dx,[d]
  mov bx,[di1]
  mov cx,[di2]

  { Bres_loop selector }

  cmp xi1,1
  jz  @go2
  cmp xi1,-1
  jz  @go2

  cmp xi2,0
  jnl @no1
  cmp yi2,0
  jle @no1
  jmp @Bres_loop1x
  @no1:

  cmp xi2,0
  jnl @no2
  cmp yi2,0
  jnl @no2
  jmp @Bres_loop1xy
  @no2:

  cmp xi2,0
  jle @no3
  cmp yi2,0
  jnl @no3
  jmp @Bres_loop1y
  @no3:

  jmp @Bres_Loop1

  @go2:

  cmp xi2,0
  jnl @no4
  cmp yi2,0
  jle @no4
  jmp @Bres_loop2x
  @no4:

  cmp xi2,0
  jnl @no5
  cmp yi2,0
  jnl @no5
  jmp @Bres_loop2xy
  @no5:

  cmp xi2,0
  jle @no6
  cmp yi2,0
  jnl @no6
  jmp @Bres_loop2y
  @no6:

  jmp @Bres_Loop2

  { 1: }

  @Bres_loop1:
  mov [es:di],ax
  cmp dx,0
  jnl @21
  add dx,bx
  add di,2
  jmp @31
  @21:
  add dx,cx
  inc ax
  add di,2
  @31:
  dec si
  jnz @Bres_loop1

  jmp @done

  { 1: -x }

  @Bres_loop1x:
  mov [es:di],ax
  cmp dx,0
  jnl @21x
  add dx,bx
  add di,2
  jmp @31x
  @21x:
  add dx,cx
  dec ax
  add di,2
  @31x:
  dec si
  jnz @Bres_loop1x

  jmp @done

  { 1: -y }

  @Bres_loop1y:
  mov [es:di],ax
  cmp dx,0
  jnl @21y
  add dx,bx
  sub di,2
  jmp @31y
  @21y:
  add dx,cx
  inc ax
  sub di,2
  @31y:
  dec si
  jnz @Bres_loop1y

  jmp @done

  { 1: -x  a -y }

  @Bres_loop1xy:
  mov [es:di],ax
  cmp dx,0
  jnl @21xy
  add dx,bx
  sub di,2
  jmp @31xy
  @21xy:
  add dx,cx
  dec ax
  sub di,2
  @31xy:
  dec si
  jnz @Bres_loop1xy

  jmp @done

  { 2: }

  @Bres_loop2:
  mov [es:di],ax
  cmp dx,0
  jnl @22
  add dx,bx
  inc ax
  jmp @32
  @22:
  add dx,cx
  inc ax
  add di,2
  @32:
  dec si
  jnz @Bres_loop2

  jmp @done

  { 2: -x }

  @Bres_loop2x:
  mov [es:di],ax
  cmp dx,0
  jnl @22x
  add dx,bx
  dec ax
  jmp @32x
  @22x:
  add dx,cx
  dec ax
  add di,2
  @32x:
  dec si
  jnz @Bres_loop2x

  jmp @done

  { 2: -y }

  @Bres_loop2y:
  mov [es:di],ax
  cmp dx,0
  jnl @22y
  add dx,bx
  inc ax
  jmp @32y
  @22y:
  add dx,cx
  inc ax
  sub di,2
  @32y:
  dec si
  jnz @Bres_loop2y

  jmp @done

  { 2: -x  a -y }

  @Bres_loop2xy:
  mov [es:di],ax
  cmp dx,0
  jnl @22xy
  add dx,bx
  inc ax
  jmp @32xy
  @22xy:
  add dx,cx
  inc ax
  sub di,2
  @32xy:
  dec si
  jnz @Bres_loop2xy

 @done:

end;

{ interpoluje mezi hodnotami x1 a x2 od y1 do y2 pomoci
  Bresenhamova algoritmu - vysledek se uklada jako Byte }
procedure Interpol_Byte(x1, y1, x2, y2 : integer; data:pointer);assembler;
var i, d_x, d_y, npix,
    d, di1, di2,
    x, xi1, xi2,
    y, yi1, yi2 : integer;
asm
  mov ax,[x2]
  mov bx,[x1]
  mov cx,[y2]
  mov dx,[y1]
  sub ax,bx
  jae @@x
  neg ax
  @@x: { |x1 - x2| }
  sub cx,dx
  jae @@y
  neg cx
  @@y: { |y1 - y2| }
  mov [xi1],1
  mov [xi2],1
  mov [yi1],0
  mov [yi2],2
  cmp ax,cx     { d_x >= d_y }
  jae @noxchg
  mov [xi1],0
  mov [yi1],2
  xchg ax,cx
  @noxchg:
  mov bx,ax     { bx <- d_x }
  mov dx,cx     { dx <- d_y }
  mov [npix],bx { d_x }
  shl dx,1
  mov [di1],dx  { d_y * 2 }
  sub dx,ax
  mov [d],dx    { d_y * 2 - d_x }
  sub cx,ax
  shl cx,1
  mov [di2],cx  { (d_y - d_x) * 2 }
  mov ax,[x1]
  mov bx,[x2]
  cmp ax,bx
  jna @nonegx   { x1 <= x2 }
  neg xi1
  neg xi2
  @nonegx:
  mov ax,[y1]
  mov bx,[y2]
  cmp ax,bx
  jna @nonegy   { y1 <= y2 }
  neg yi1
  neg yi2
  @nonegy:
  les di,[data]
  mov si,npix
  inc si

  mov ax,[x1]

  cmp ax,0
  jnl @@clipx1
  xor ax,ax
  @@clipx1:

  mov bx,[y1]

  cmp bx,0
  jnl @@clipy1
  xor bx,bx
  @@clipy1:

  add di,bx
  mov dx,[d]
  mov bx,[di1]
  mov cx,[di2]

  { Bres_loop selector }

  cmp xi1,1
  jz  @go2
  cmp xi1,-1
  jz  @go2

  cmp xi2,0
  jnl @no1
  cmp yi2,0
  jle @no1
  jmp @Bres_loop1x
  @no1:

  cmp xi2,0
  jnl @no2
  cmp yi2,0
  jnl @no2
  jmp @Bres_loop1xy
  @no2:

  cmp xi2,0
  jle @no3
  cmp yi2,0
  jnl @no3
  jmp @Bres_loop1y
  @no3:

  jmp @Bres_Loop1

  @go2:

  cmp xi2,0
  jnl @no4
  cmp yi2,0
  jle @no4
  jmp @Bres_loop2x
  @no4:

  cmp xi2,0
  jnl @no5
  cmp yi2,0
  jnl @no5
  jmp @Bres_loop2xy
  @no5:

  cmp xi2,0
  jle @no6
  cmp yi2,0
  jnl @no6
  jmp @Bres_loop2y
  @no6:

  jmp @Bres_Loop2

  { 1: }

  @Bres_loop1:
  mov [es:di],al
  cmp dx,0
  jnl @21
  add dx,bx
  inc di
  jmp @31
  @21:
  add dx,cx
  inc ax
  inc di
  @31:
  dec si
  jnz @Bres_loop1

  jmp @done

  { 1: -x }

  @Bres_loop1x:
  mov [es:di],al
  cmp dx,0
  jnl @21x
  add dx,bx
  inc di
  jmp @31x
  @21x:
  add dx,cx
  dec ax
  inc di
  @31x:
  dec si
  jnz @Bres_loop1x

  jmp @done

  { 1: -y }

  @Bres_loop1y:
  mov [es:di],al
  cmp dx,0
  jnl @21y
  add dx,bx
  dec di
  jmp @31y
  @21y:
  add dx,cx
  inc ax
  dec di
  @31y:
  dec si
  jnz @Bres_loop1y

  jmp @done

  { 1: -x  a -y }

  @Bres_loop1xy:
  mov [es:di],al
  cmp dx,0
  jnl @21xy
  add dx,bx
  dec di
  jmp @31xy
  @21xy:
  add dx,cx
  dec ax
  dec di
  @31xy:
  dec si
  jnz @Bres_loop1xy

  jmp @done

  { 2: }

  @Bres_loop2:
  mov [es:di],al
  cmp dx,0
  jnl @22
  add dx,bx
  inc ax
  jmp @32
  @22:
  add dx,cx
  inc ax
  inc di
  @32:
  dec si
  jnz @Bres_loop2

  jmp @done

  { 2: -x }

  @Bres_loop2x:
  mov [es:di],al
  cmp dx,0
  jnl @22x
  add dx,bx
  dec ax
  jmp @32x
  @22x:
  add dx,cx
  dec ax
  inc di
  @32x:
  dec si
  jnz @Bres_loop2x

  jmp @done

  { 2: -y }

  @Bres_loop2y:
  mov [es:di],al
  cmp dx,0
  jnl @22y
  add dx,bx
  inc ax
  jmp @32y
  @22y:
  add dx,cx
  inc ax
  dec di
  @32y:
  dec si
  jnz @Bres_loop2y

  jmp @done

  { 2: -x  a -y }

  @Bres_loop2xy:
  mov [es:di],al
  cmp dx,0
  jnl @22xy
  add dx,bx
  inc ax
  jmp @32xy
  @22xy:
  add dx,cx
  inc ax
  dec di
  @32xy:
  dec si
  jnz @Bres_loop2xy

 @done:

end;

Function ClipFace(x1,y1,x2,y2,x3,y3:Integer):Byte;
begin
Clipping:=False;Visible:=0;
if X1<0 then begin Clipping:=True;Inc(Visible) end;
if Y1<0 then begin Clipping:=True;Inc(Visible) end;
if X2<0 then begin Clipping:=True;Inc(Visible) end;
if Y2<0 then begin Clipping:=True;Inc(Visible) end;
if X3<0 then begin Clipping:=True;Inc(Visible) end;
if Y3<0 then begin Clipping:=True;Inc(Visible) end;
if X1>XRES-1 then begin Clipping:=True;Inc(Visible) end;
if Y1>YRES-1 then begin Clipping:=True;Inc(Visible) end;
if X2>XRES-1 then begin Clipping:=True;Inc(Visible) end;
if Y2>YRES-1 then begin Clipping:=True;Inc(Visible) end;
if X3>XRES-1 then begin Clipping:=True;Inc(Visible) end;
if Y3>YRES-1 then begin Clipping:=True;Inc(Visible) end;
ClipFace:=Visible;
end;

Procedure FlatFace;

var  XL,XR : TData; y,j,i:integer; XRSeg,XROfs,XLSeg,XLOfs,nscan:word;

begin

XRSeg:=Seg(XR);
XROfs:=Ofs(XR);
XLSeg:=Seg(XL);
XLOfs:=Ofs(XL);

if ClipFace(x1,y1,x2,y2,x3,y3)>8 then Exit;

for i:=1 to 2 do begin
if Y1>Y2 then begin
J:=Y2;Y2:=Y1;Y1:=J;
J:=X2;X2:=X1;X1:=J;
end;
if Y2>Y3 then begin
J:=Y3;Y3:=Y2;Y2:=J;
J:=X3;X3:=X2;X2:=J;
end end;

if (X2<X1) or (X2<X3) then
begin
if Clipping then begin
Interpol_Clip(X1,Y1,X2,Y2,@XL);
Interpol_Clip(X2,Y2,X3,Y3,@XL);
Interpol_Clip(X1,Y1,X3,Y3,@XR);
end else begin
Interpol_Word(X1,Y1,X2,Y2,@XL);
Interpol_Word(X2,Y2,X3,Y3,@XL);
Interpol_Word(X1,Y1,X3,Y3,@XR);
end end;

if (X2>X1) or (X2>X3) then
begin
if Clipping then begin
Interpol_Clip(X1,Y1,X2,Y2,@XR);
Interpol_Clip(X2,Y2,X3,Y3,@XR);
Interpol_Clip(X1,Y1,X3,Y3,@XL);
end else begin
Interpol_Word(X1,Y1,X2,Y2,@XR);
Interpol_Word(X2,Y2,X3,Y3,@XR);
Interpol_Word(X1,Y1,X3,Y3,@XL);
end end;

if Y1<0 then Y1:=0;
if Y3<0 then Y3:=0;
if Y1>YRES-1 then Y1:=YRES-1;
if Y3>YRES-1 then Y3:=YRES-1;
nscan:=Y3-Y1;
if nscan>0 then for Y:=Y1 to Y3 do begin
   if XL[Y]<XR[Y] then I:=XL[Y] else I:=XR[Y];
   B^.Col2Box(I,Y,Abs(XR[Y]-XL[Y]),1,C);
   end;
end;

{ posune bodu 2D/3D }
procedure Move3D(var Points:TPoints;Count:Word;_dx,_dy,_dz:Longint); assembler;
asm
   les  di,[dword ptr points]
   mov  cx,[count]
 db 66h; mov  ax,[word ptr _dx] { mov eax,[_dx] }
 db 66h; mov  bx,[word ptr _dy] { mov ebx,[_dy] }
 db 66h; mov  dx,[word ptr _dz] { mov edx,[_dz] }
@@pointloop:
 db 66h; add  [es:di],ax        { add es:[di],eax }
 db 66h; add  [es:di+4],bx      { add es:[di+4],ebx }
 db 66h; add  [es:di+8],dx      { add es:[di+8],edx }
   add  di,12
   dec  cx
   jnz  @@pointloop
end;

{ prida perspektivu }
procedure AddPerspective(var Points:TPoints;Count:Word;SF:Byte;Zd:Longint); assembler;
asm
   les  di,[dword ptr points]
   mov  bx,[count]
   mov  cl,[sf]
@@pointloop:
   push bx

 db 66h; mov  bx,[es:di+8]      { mov ebx,[es:di+8] }
 db 66h; add  bx,[word ptr zd]  { add ebx,[zd] }
 db 66h; test bx,bx             { test ebx,ebx }
   jz  @@nextpoint

 db 66h; mov  ax,[es:di]        { mov eax,[es:di] }
 db 66h; sal  ax,cl             { sal eax,cl }
 db 66h; mov  dx,ax             { mov edx,eax }
 db 66h; sar  dx,31             { sar edx,31 }
 db 66h; idiv bx                { idiv ebx }
 db 66h; mov  [es:di],ax        { mov [es:di],eax }

 db 66h; mov  ax,[es:di+4]      { mov eax,[es:di+4] }
 db 66h; sal  ax,cl             { sal eax,cl }
 db 66h; mov  dx,ax             { mov edx,eax }
 db 66h; sar  dx,31             { sar edx,31 }
 db 66h; idiv bx                { idiv ebx }
 db 66h; mov  [es:di+4],ax      { mov [es:di+4],eax }

@@nextpoint:
   add  di,12
   pop  bx
   dec  bx
   jnz  @@pointloop
end;

{ zjisti viditelnost }
function IsVisible(x1,y1,x2,y2,x3,y3:Integer):Integer; assembler;
asm
 mov  ax,[y2]
 sub  ax,[y1]
 mov  bx,[x3]
 sub  bx,[x1]
 imul bx
 mov  cx,ax
 mov  ax,[y3]
 sub  ax,[y1]
 mov  bx,[x2]
 sub  bx,[x1]
 imul bx
 sub  cx,ax
 mov  ax,cx
 neg  ax
end;

{ rotuje 3D body }
procedure Rotate3D(var SPoints,DPoints:TPoints;Count:Word;rx,ry,rz:Integer); assembler;
var xs,xc,ys,yc,zs,zc,x1,y1,z1 : Longint;
asm
   push ds
   mov  dx,[tablemask]
   les  di,[dword ptr _sin]
   lds  si,[dword ptr _cos]
   mov  bx,[rx]
   and  bx,dx
   shl  bx,1
 db 66h; db $26, $0f, $bf, $01   { movsx eax,[es:di+bx] }
 db 66h; mov  [word ptr xs],ax   { mov [xs],eax }
 db 66h; db $0f, $bf, $00        { movsx eax,[ds:si+bx] }
 db 66h; mov  [word ptr xc],ax   { mov [xc],eax }
   mov  bx,[ry]
   and  bx,dx
   shl  bx,1
 db 66h; db $26, $0f, $bf, $01   { movsx eax,[es:di+bx] }
 db 66h; mov  [word ptr ys],ax   { mov [ys],eax }
 db 66h; db $0f, $bf, $00        { movsx eax,[ds:si+bx] }
 db 66h; mov  [word ptr yc],ax   { mov [yc],eax }
   mov  bx,[rz]
   and  bx,dx
   shl  bx,1
 db 66h; db $26, $0f, $bf, $01   { movsx eax, [es:di+bx] }
 db 66h; mov  [word ptr zs],ax   { mov [zs],eax }
 db 66h; db $0f, $bf, $00        { movsx eax, [ds:si+bx] }
 db 66h; mov  [word ptr zc],ax   { mov [zc],eax }

   lds  si,[dword ptr spoints]
   les  di,[dword ptr dpoints]
   mov  cx,[count]
@@pointloop:
   push cx

 db 66h; mov  ax,[word ptr ds:si+4] { mov eax,[ds:si+4] }
 db 66h; imul [word ptr xc]         { imul xc }
 db 66h; mov  bx,ax                 { mov ebx,eax }
 db 66h; mov  ax,[word ptr ds:si+8] { mov eax,[ds:si+8] }
 db 66h; imul [word ptr xs]         { imul [xs] }
 db 66h; add  bx,ax                 { add ebx,eax }
 db 66h; sar  bx,8                  { sar ebx,8 }
 db 66h; mov  [word ptr y1],bx      { mov [y1],ebx }

 db 66h; mov  ax,[word ptr ds:si+4] { mov eax,[ds:si+4] }
 db 66h; neg  ax                    { neg eax }
 db 66h; imul [word ptr xs]         { imul xs }
 db 66h; mov  cx,ax                 { mov ebx,eax }
 db 66h; mov  ax,[word ptr ds:si+8] { mov eax,[ds:si+8] }
 db 66h; imul [word ptr xc]         { imul [xc] }
 db 66h; add  cx,ax                 { add ecx,eax }
 db 66h; sar  cx,8                  { sar ecx,8 }
 db 66h; mov  [word ptr z1],cx      { mov [z1],ecx }

 db 66h; mov  ax,[word ptr ds:si]   { mov eax,[ds:si] }
 db 66h; imul [word ptr yc]         { imul [yc] }
 db 66h; mov  bx,ax                 { mov ebx,eax }
 db 66h; mov  ax,cx                 { mov eax,ecx }
 db 66h; imul [word ptr ys]         { imul [ys] }
 db 66h; add  bx,ax                 { add ebx,eax }
 db 66h; sar  bx,8                  { sar ebx,8 }
 db 66h; mov  [word ptr x1],bx      { mov [x1],ebx }
 db 66h; mov  ax,[word ptr ds:si]   { mov eax,[ds:si] }
 db 66h; neg  ax                    { neg eax }
 db 66h; imul [word ptr ys]         { imul ys }
 db 66h; mov  bx,ax                 { mov ebx,eax }
 db 66h; mov  ax,cx                 { mov eax,ecx }
 db 66h; imul [word ptr yc]         { imul [yc] }
 db 66h; add  bx,ax                 { add ebx,eax }
 db 66h; sar  bx,8                  { sar ebx,8 }
 db 66h; mov  [es:di+8],bx          { mov [es:di+8],ebx }

 db 66h; mov  ax,[word ptr x1]      { mov eax,[x1] }
 db 66h; imul [word ptr zc]         { imul [zc] }
 db 66h; mov  bx,ax                 { mov ebx,eax }
 db 66h; mov  ax,[word ptr y1]      { mov eax,[y1] }
 db 66h; imul [word ptr zs]         { imul [zs] }
 db 66h; add  bx,ax                 { add ebx,eax }
 db 66h; sar  bx,8                  { sar ebx,8 }
 db 66h; mov  [es:di],bx            { mov [es:di],ebx }

 db 66h; mov  ax,[word ptr x1]      { mov eax,[x1] }
 db 66h; neg  ax                    { neg eax }
 db 66h; imul [word ptr zs]         { imul zs }
 db 66h; mov  bx,ax                 { mov ebx,eax }
 db 66h; mov  ax,[word ptr y1]      { mov eax,[y1] }
 db 66h; imul [word ptr zc]         { imul [zc] }
 db 66h; add  bx,ax                 { add ebx,eax }
 db 66h; sar  bx,8                  { sar ebx,8 }
 db 66h; mov  [es:di+4],bx          { mov [es:di+4],ebx }

   add  si,12
   add  di,12
   pop  cx

   dec  cx
   jnz  @@pointloop
   pop  ds
end;


{ QuickSort }
procedure QSort(var SortList:Array of TSortData; Count:Word);

 procedure qsortinner(i1,i2 : integer);
 var
  j1,j2 : integer;
  p  : pointer;
 begin
  if i1=i2 then
   exit;
  p:=@sortlist;
  asm
     les  di,[dword ptr p]
     mov  bx,[i1]
     mov  cx,bx
     shl  bx,2
     shl  cx,1
     add  bx,cx
   db 66h; mov  dx,[es:di+bx+2] { mov edx,[es:di+bx+2] }

     mov  ax,[i1]
     mov  [j1],ax
     mov  ax,[i2]
     mov  [j2],ax

  @@loop1:
     mov  ax,[j1]
  @@more_1:
     cmp  ax,[i2]
     jg  @@exit_1
     mov  bx,ax
     mov  cx,bx
     shl  bx,2
     shl  cx,1
     add  bx,cx
   db 66h; cmp  [es:di+bx+2],dx { cmp [es:di+bx+2],edx }
     jle  @@exit_1
     inc  ax
     jmp  @@more_1
  @@exit_1:
     mov  [j1],ax

     mov  ax,[j2]
  @@more_2:
     cmp  ax,[i1]
     jl  @@exit_2
     mov  bx,ax
     mov  cx,bx
     shl  bx,2
     shl  cx,1
     add  bx,cx
   db 66h; cmp  [es:di+bx+2],dx { cmp [es:di+bx+2],edx }
     jge  @@exit_2
     dec  ax
     jmp  @@more_2
  @@exit_2:
     mov  [j2],ax

     mov  ax,[j1]
     mov  bx,[j2]
     cmp  ax,bx
     jg  @@exit_3
     mov  si,di
     mov  cx,ax
     shl  ax,2
     shl  cx,1
     add  si,cx
     add  si,ax
     mov  cx,bx
     shl  bx,2
     shl  cx,1
     add  bx,cx
     mov  ax,[es:si]
     xchg ax,[es:di+bx]
     mov  [es:si],ax
   db 66h; mov  ax,[es:si+2]    { mov eax,[es:si+2] }
   db 66h; xchg ax,[es:di+bx+2] { xchg eax,[es:di+bx+2] }
   db 66h; mov  [es:si+2],ax    { mov [es:si+2],eax }
     inc  [j1]
     dec  [j2]
  @@exit_3:
     mov  ax,[j1]
     cmp  ax,[j2]
     jle  @@loop1
  end;
  if j1<i2 then
   qsortinner(j1,i2);
  if j2>i1 then
   qsortinner(i1,j2);
 end;

begin
 qsortinner(0,count-1);
end;

{ inicializuej tabulku Sin a Cos }
procedure InitSinCos(BitSize:Byte);
var i:word;period:real;
begin
  if _sin<>nil then FreeMem(_sin,(tablemask+1)*2);
  if _cos<>nil then FreeMem(_cos,(tablemask+1)*2);
 if bitsize<1 then
  bitsize:=1
 else if bitsize>14 then
  bitsize:=14;
 tablemask:=(1 shl bitsize)-1;
 getmem(_Sin,(tablemask+1)*2);
 getmem(_Cos,(tablemask+1)*2);
 if (_Sin=nil) or (_Cos=nil) then
  runerror(203);
 period:=(tablemask+1)/2;
 for i:=0 to tablemask do begin
  _Sin^[i]:=round(256*sin(i*pi/period));
  _Cos^[i]:=round(256*cos(i*pi/period));
 end;
end;


{같같같같같같같같같같같같같같같같INIT/DONE같같같같같같같같같같같같같같같같같�}

const unita='vengine2';
var result:TError;

procedure UserInit;
 begin
  _sin:=nil;
  _cos:=nil;
 end;

procedure UserDone;
 begin
  if _sin<>nil then FreeMem(_sin,(tablemask+1)*2);
  if _cos<>nil then FreeMem(_cos,(tablemask+1)*2);
 end;

{$i initdone.inc}
{$ifdef autoinit}
BEGIN
 erCheck(Init);
{$endif}
END.