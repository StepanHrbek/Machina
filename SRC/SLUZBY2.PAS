UNIT Sluzby2;{vytazek z unity sluzby, cela ma 75KB}
{$R-}
{ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß}
                             INTERFACE
{ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ}


{VESA}
PROCEDURE VesaBanku;
PROCEDURE VesaInit;
FUNCTION  VesaInit640x480:Boolean;
PROCEDURE VesaSetVis(visy:word);
PROCEDURE VesaBank;
PROCEDURE IncVesaBank;

CONST
      VGA_MODE:byte=0;{0-text;1-vga360;2-svga512;3-svga640}

{ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß}
                          IMPLEMENTATION
{ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ}


{ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ V E S A ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ}

PROCEDURE VesaBankPtr;assembler;
 asm dw 0,0;end;

PROCEDURE VesaGranularity;assembler;
 asm dw 0;end;

PROCEDURE VesaNowBank;assembler;
 asm dw 0;end;

PROCEDURE VesaBanku;assembler;
 asm db 0ffh;{ff=detekovat velikost;0=none;other=size64K}end;

PROCEDURE VesaBank;assembler;
 asm cmp byte ptr VesaBanku,2;jc @bankend
     cmp byte ptr VesaBanku,255;jz @bankend
     cmp ax,word ptr VesaNowBank;jz @bankend
     mov word ptr VesaNowBank,ax
     push ax
     push bx
     push dx
     mov ah,0
     div byte ptr VesaBanku

     mov al,0{ah=zarovnanej 64k bank}
     {granul=64 .. ax=ax>8
      granul=4  .. ax=ax>4
      granul=?  .. ax=ax/granul>2}
     div byte ptr [cs:offset VesaGranularity]
     shr al,2

     xor bx,bx
     xor dh,dh
     mov dl,al

{varianta fast,unsafe
     db 2eh,0ffh,1eh;dw offset vesabankptr{call far ptr [cs:offset bankptr]}
{varianta slow,safe}
     mov ax,4f05h
     int 10h

     pop dx
     pop bx
     pop ax
     @bankend:
     end;

PROCEDURE IncVesaBank;assembler;
 asm
      push ax
      mov ax,word ptr VesaNowBank
      inc ax
      call VesaBank
      pop ax
      end;

PROCEDURE VesaSetVis(visy:word);assembler;
 asm mov ax,4f07h;xor bx,bx;mov cx,(640+512)/2{wrisir};mov dx,visy;int 10h
     end;

PROCEDURE VesaInit;assembler;
 asm
	;{------------alloc 256B buffer----------}
	mov	ah,48h
	mov	bx,64{buffer 256B, pro jistotu 1024}
	int	21h
	jc	@nomem
	mov	es,ax
     {vesa here ? ... get info to buffer es:di}
     mov ax,4f00h;xor di,di;int 10h
     cmp ax,4fh;jnz @novesa
     {header ok ?}
     cmp word ptr [es:00],'EV';jnz @novesa
     cmp word ptr [es:02],'AS';jnz @novesa
     {version >= 1.2 ?}
     cmp word ptr [es:04],0102h;jl @novesa
     {read VESAviditelnychBanku}
     cmp byte ptr VesaBanku,255;jnz @forcedMemsize
     mov ax,[es:18];mov byte ptr VesaBanku,al
     @forcedMemsize:
     {end}
     jmp @end
     @novesa:
     mov byte ptr VesaBanku,0
     @end:
	;{-------------dealloc buffer--------------}
	mov	ah,49h
	int	21h
	@nomem:
     end;


FUNCTION VesaInit640x480:Boolean;
begin
 asm
     mov @result,0
	;{------------alloc 256B buffer----------}
	mov	ah,48h
	mov	bx,64{buffer 256B, pro jistotu 1024}
	int	21h
	jc	@nomem
	mov	es,ax
     {reset nowbank}
     mov word ptr [cs:offset VesaNowBank],0
     {set 640x480}
     mov ax,4f02h;mov bx,101h;int 10h;cmp ax,4fh;jnz @bad
     mov VGA_MODE,3{svga640}
     {get info about mode100 to es:di buffer}
     mov ax,4f01h;mov cx,101h;xor di,di;int 10h;cmp ax,4fh;jnz @bad
     {check granularity}
     mov ax,[es: 4];mov [cs:  offset VesaGranularity],ax
     {read ptr to setbank}
     mov ax,[es:12];mov [cs:  offset vesabankptr],ax
     mov ax,[es:14];mov [cs:2+offset vesabankptr],ax
     {end}
     mov @result,1
     @bad:
	;{-------------dealloc buffer--------------}
	@novesa:
	mov	ah,49h
	int	21h
	@nomem:
     end;
end;


END.