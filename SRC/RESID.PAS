{$A+,B-,E-,F-,G+,I-,L-,N-,O-,Q-,R-,S-,M 4000,0,0}
CONST intr=$33; intrlo=4*intr; intrhi=4*intr+2;
      int1=$3f; int1lo=4*int1; int1hi=4*int1+2;
      int2=0;   int2lo=4*int2; int2hi=4*int2+2;

      CernaTransparentni=0;
      sir:word=0;
      vys:word=500;
      barevw:word=0;
      sizelo:word=64000;
      sizehi:word=0;
      dest:array[1..5] of char='-a.x'#0;


VAR   datafajl:word;
      barevb:byte absolute barevw;
      size:longint absolute sizelo;
      pal1:array[1..1024] of byte;
      pal2:array[1..768] of byte;
      tab1:array[0..255] of word;{pocty vyskytu barev 0..255}
      tab2:array[0..255] of byte;{color xlat tabulka}


BEGIN
 asm
     segcs mov [offset @1+1],ds                       {uprava res: DS}
     segcs mov [offset @2+1],ss                       {uprava res: SS}
     segcs mov [offset @6+1],bp                       {uprava res: BP}
     segcs mov [offset @7+1],sp                       {uprava res: SP}
     xor ax,ax
     mov es,ax
     seges mov ax,[intrlo];segcs mov [offset @3 +1],ax  {uprava res: 33h vector}
     seges mov ax,[intrhi];segcs mov [offset @3 +3],ax
     mov ax,offset @TSR                         {set mux vector}
     seges mov [intrlo],ax
     seges mov [intrhi],cs
     mov ah,62h                                 {save PSP}
     int 21h
     {segcs mov [offset @psp+1],bx}
     dec bx;mov es,bx;mov dx,[es:3];inc dx      {zarezidentneni}
     mov ah,31h
     int 21h


 @TSR:
     cmp ax,3;jz @z                             {qery buts function}
     cmp ax,4;jz @z                             {qery buts function}
     cmp ax,5;jz @z                             {qery buts function}
 @z: pushf
 @3: db 9ah                                     {far call}
     dw 0
     dw 0
     jnz @konec
     shr cx,3
     shr dx,3
     cmp bx,4                                   {middle but}
     jnz @konec



     segcs mov [offset @ss+1],ss                {save ss,sp}
     segcs mov [offset @sp+1],sp
     pusha                                      {save other regs}
     push ds
     push es

  @1:mov si,0                                   {set regs}
     mov ds,si
  @2:mov si,0
     mov ss,si
  @6:mov bp,0
  @7:mov sp,0


{ CORE }
  mov ax,0c08h
  @notkey:
  in al,$60
  test al,$80
  jnz @notkey

  cmp al,20{'t'};jnz @nott;call @textcapture ;jmp @coreend;@nott:
  cmp al, 2{'1'};jnz @not1;mov ax, 3 ;int 10h;jmp @coreend;@not1:
  cmp al, 4{'3'};jnz @not3;mov ax,13h;int 10h;jmp @coreend;@not3:
  cmp al, 5{'4'};jnz @not4;mov ax,5ch;int 10h;jmp @coreend;@not4:
  cmp al, 7{'6'};jnz @not6;mov ax,5dh;int 10h;jmp @coreend;@not6:
  cmp al, 9{'8'};jnz @not8;mov ax,5eh;int 10h;jmp @coreend;@not8:
  cmp al,11{'0'};jnz @not0;mov ax,62h;int 10h;jmp @coreend;@not0:

  cmp al,50{'m'};jnz @nomouse
  {zrychleni M}
   mov ax,0fh;mov cx,4;mov dx,cx;int 33h
  {nastaveni range M-x}
   mov ax,7;mov cx,0;mov dx,640*8;int 33h
  {nastaveni range M-y}
   mov ax,8;mov cx,0;mov dx,480*8;int 33h;
  @nomouse:

  cmp al,46{'c'};jnz @notcapture          {mov ax,13h;int 10h;mov es,sega000;mov byte ptr [es:0],3}
{____________CAPTURE_____________}
         {read and set sir,size}
          mov ax,4f06h;mov bl,1;int 10h;mov ax,bx;{
          mov dx,3d4h;mov al,13h;out dx,al;inc dx;in al,dx;mov ah,0;shl ax,2;}mov sir,ax;mul vys;mov sizelo,ax;mov sizehi,dx
         {palette to pal}
mov ax,ds;mov es,ax
          mov di,offset pal1;mov dx,3c7h;mov al,0;out dx,al;inc dx;inc dx;
          mov cx,100h;@l1:in al,dx;stosb;in al,dx;stosb;in al,dx;stosb;inc di;loop @l1
         {cls tab1,tab2}
          mov di,offset tab1;mov ax,0;mov cx,256+128;rep stosw
         {naplneni tab1}
mov es,sega000
          mov si,0
          mov di,0
          mov cx,0
          mov dx,sizehi
         @nextpage1:
          pusha;mov bx,0;mov ax,4f05h;int 10h;popa{video page <- dl}
          or dx,dx
          jnz @loop1
          mov cx,sizelo
         @loop1:
          seges lodsb;mov ah,0;shl ax,1;mov bx,ax;inc word ptr [bx+offset tab1];loop @loop1
          dec dx
          jns @nextpage1

         {redukce palety, tab1 -> tab2}
          mov cx,255
          @l3:
          push cx
           mov dx,0
           mov cx,256
           mov si,offset tab1
           @l2:
           lodsw
           cmp dx,ax
           jnc @nomax
           mov dx,ax{dx=maximum vyskytu}
           mov bx,si{adresa nejcastejsi barvy v tab1}
           @nomax:
           loop @l2
          pop cx
          cmp dx,0;jz @redend
          sub bx,2
          mov word ptr [bx],0
          sub bx,offset tab1
          shr bx,1{bl=cislo nejcastejsi barvy}
          add bx,offset tab2
              {cerna barva nejcastejsi -> konvertit na 00}
              cmp cl,255;jnz @notNejcastejsiCerna
              mov al,CernaTransparentni;cmp al,0;jz @notNejcastejsiCerna
              mov byte ptr [bx],0{bude transformovano na cernou}
              loop @l3
              @notNejcastejsiCerna:
          mov byte ptr [bx],cl{bude transformovano na 255,254...}
          loop @l3
          @redend:

         {trans a000 -> a000}
          mov di,0;mov cx,0;mov bx,offset tab2
          mov dx,sizehi
         @nextpage2:
          pusha;mov bx,0;mov ax,4f05h;int 10h;popa{video page <- dl}
          @4:mov al,[es:di];xlat;stosb;loop @4
          dec dx;jns @nextpage2

mov ax,ds;mov es,ax
         {clr pal2}
          mov di,offset pal2;mov cx,768/2;mov ax,0;rep stosw;
         {trans pal -> pal2}
          mov barevw,0
          mov di,offset tab2
          mov si,offset pal1
          mov cx,256
          @5:
          mov ah,0
          mov al,[di];inc di
          mov bx,ax;add bx,ax;jnz @nozero;add si,4;jmp @l;@nozero:add bx,ax;add bx,offset pal2
          lodsb;mov [bx  ],al
          lodsb;mov [bx+1],al
          lodsb;mov [bx+2],al
          inc si
          inc barevb
          @l:loop @5
         {nastavi barvy}
          mov si,offset pal2;
          mov dx,3c8h;mov al,0;out dx,al;inc dx;mov cx,3*256
          @q1:lodsb;out dx,al;loop @q1
         {open}
          mov ah,3ch;mov cx,0;mov dx,offset dest;int 21h;mov datafajl,ax
{          jnc @okopen;push 4;call errorhalt;@okopen:}
         {save header}
          mov bx,datafajl;mov cx,5;mov dx,offset sir;mov ah,40h;int 21h;
         {save palette}
          mov bx,datafajl;mov cx,barevw;shl cx,1;add cx,barevw;
          mov dx,offset pal2+768;sub dx,cx;mov ah,40h;int 21h;
         {save bitmap}
          mov si,sizehi
          mov dx,0
         @nextpage3:
          pusha;mov bx,0;mov ax,4f05h;int 10h;popa{video page <- dl}
          mov bx,datafajl
          mov cx,0
          cmp dx,si
          jnz @notlast
          mov cx,sizelo
         @notlast:
          pusha;push ds
          mov ds,sega000;
          push cx;mov cx,1;mov dx,0;mov ah,40h;int 21h;
          pop cx; dec cx;  mov dx,1;mov ah,40h;int 21h;
          pop ds;popa
          inc dx
          cmp si,dx
          jnc @nextpage3
         {close}
          mov bx,datafajl;mov ah,3eh;int 21h;

 @notcapture:

 @coreEnd:

     pop es                                     {restore other regs}
     pop ds
     popa
 @ss:mov sp,0                                   {restore ss,sp}
     mov ss,sp
 @sp:mov sp,0

@KONEC:
     iret


{----------------sejvnuti pulscreeny------------------}
@textname: db 'text0001.txt',0
@crlf: dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0a0dh
@hand: dw 0
@textcapture:
     push ds
     push es
     pusha

     push cs         {pripravi segmenty}
     pop ds
     mov ax,0b800h
     mov es,ax
                     {create file for writing}
     mov ah,3ch
     mov cx,0
     mov dx,offset @textname
     int 21h
     mov [cs:offset @hand],ax
                     {capture text - pravou pulku obrazu}
     mov si,0
     push ds
     xor ax,ax
     mov ds,ax
     mov cl,[484h]{pocet radek}
     mov ch,0
     inc cx
     pop ds
    @nextline:
    push cx
                     {zkopci lajnu do CS}
     mov di,offset @crlf
     add si,2*40
     mov cx,40
     @movechar:
     seges lodsw
     mov [cs:di],al;inc di{segcs stosb}
     loop @movechar
                     {sejvne lajnu i s crlf}
     mov ah,40h
     mov bx,[cs:offset @hand]
     mov dx,offset @crlf
     mov cx,42
     int 21h

    pop cx
    loop @nextline
                     {close file}
     mov ah,3eh;
     mov bx,[cs:offset @hand]
     int 21h

     popa
     pop es
     pop ds
     ret


     end;
END.