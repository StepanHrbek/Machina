const pointer65=4*$65;
      bksize:byte=64;
      vgamem:byte=1;
      dactype:word=0;

      buftbl:array[1..4] of word=($A000,$A000,$B000,$B800);

var detected:word;
begin
asm
jmp @start
@prefix: db 'Doporuceny driver: $'
@nic:    db 0,'$'
@v7_old: db 6,'v7_old$'
@v7_new: db 6,'v7_new$'
@tseng:  db 6,'et3000$'
@tseng4: db 6,'et4000$'


@detected: dw offset @nic



@start:
       	mov	ax,6f00h		;{Test for Video 7}
	xor	bx,bx
	cld
	int	10h
	cmp	bx,'V7'
	jnz	@nov7
	mov	detected,offset @v7_old
	mov	bksize,64		;{ 64k bank size}
	mov	ax,6f07h
	cld
	int	10h
	cmp	al,6fh
	jnz	@skp1
	and	ah,7fh
	mov	[vgamem],ah
@skp1:
        mov     dx,3c4h
        mov     al,08eh
        out     dx,al
        inc     dx
        in      al,dx
	cmp     al,05Ah		;{ Is this a version 5 chip?}
	jl	@Have5		;{ We have a version 5 or later chip}
        jmp     @fini

        @have5:
	mov	detected,offset @v7_new
        jmp     @fini



@nov7:

	mov	dx,3dah			;{Test for Tseng 4000 & 3000}
	in	al,dx			;{bit 8 is opposite of bit 4}
	mov	ah,al			;{(vertical retrace bit)}
	shr	ah,1
	shr	ah,1
	shr	ah,1
	shr	ah,1
	xor	al,ah
	test	al,00001000b
	jz	@notsjump
	mov	dx,3d4h			;{check for Tseng 4000 series}
	mov	ax,0f33h
	call	@_isport2
	jnz	@not4
	mov	ax,0ff33h		;{top 4 bits should not be there}
	call	@_isport2
	jnz	@4000
{        jz      notsjump}
@400032:mov	[vgamem],4		;{full meg with eight 256kx4 RAMs}
        mov     detected,offset @tseng4
	mov	[bksize],64		;{ 64k bank size}
        jmp     @fini
@4000:
	mov	dx,3bfh			;{Enable access to extended registers}
	mov	al,3
	out	dx,al
	mov	dx,3d8h
	mov	al,0a0h
	out	dx,al
	mov	al,0ffh
	mov	dx,3cdh			;{test bank switch register}
	call	@_isport1
	jnz	@not4
	mov     detected,offset @tseng
	mov	[bksize],64		;{ 64k bank size}
	mov	ax,10f1h		;{Extended BIOS call to get DAC type on Tseng4000}
	int	10h
	cmp	ax,10h
	jnz	@nodac
	mov	bh,0
	mov	[dactype],bx
@nodac:	mov	dx,3d4h			;{Tseng 4000 memory detect 1meg}
	mov	al,37h
	out	dx,al
	inc	dx
	in	al,dx
	test	al,1000b		;{if using 64kx4 RAMs then no more than 256k}
	jz	@nomem
	and	al,3
	cmp	al,1			;{if 8 bit wide bus then only two 256kx4 RAMs}
	jbe	@nomem
	mov	[vgamem],2
	cmp	al,2			;{if 16 bit wide bus then four 256kx4 RAMs}
	je	@nomem
	mov	[vgamem],4		;{full meg with eight 256kx4 RAMs}
@nomem:	mov     detected,offset @tseng4
	mov	[bksize],64		;{ 64k bank size}
	jmp	@fini

@notsjump:jmp @nots

@not4:	mov	dx,3d4h			;{Test for Tseng 3000}
	mov	ax,1f25h		;{is the Overflow High register there?}
	call	@_isport2
	jnz	@nots
	mov	al,03fh			;{bottom six bits only}
	mov	dx,3cdh			;{test bank switch register}
	call	@_isport1
	jnz	@nots
	mov     detected,offset @tseng
	mov	[bksize],64		;{ 64k bank size}
	call	@_t3memchk
	jmp	@fini

@nots:




@FINI:
	xor ax,ax
	mov es,ax
	mov di,[es:pointer65]
	mov si,[es:pointer65+2]
	mov es,si
	or di,di
	jnz @neninil
	or si,si
	jnz @neninil

	mov ah,9
	mov dx,offset @prefix
        push ds;mov bx,cs;mov ds,bx;int 21h;pop ds
	mov ah,9
	mov dx,detected
	inc dx
        push ds;mov bx,cs;mov ds,bx;int 21h;pop ds
	jmp @konec

@neninil:
	mov al,vgamem		;{ulozi vgamem}
	stosb

	mov si,detected		;{ulozi card name}
        push ds;mov bx,cs;mov ds,bx;
	mov al,[si]
	inc al
	mov ah,0
	mov cx,ax
	rep movsb
        pop ds

	jmp @konec






@_isport2:		;{check for valid indexed i/o port, al is index, ah is bit mask}
	push	bx
	mov	bx,ax
	out	dx,al
	mov	ah,al
	inc	dx
	in	al,dx
	dec	dx
	xchg	al,ah
	push	ax
	mov	ax,bx
	out	dx,ax
	out	dx,al
	mov	ah,al
	inc	dx
	in	al,dx
	dec	dx
	and	al,bh
	cmp	al,bh
	jnz	@noport2
	mov	al,ah
	mov	ah,0
	out	dx,ax
	out	dx,al
	mov	ah,al
	inc	dx
	in	al,dx
	dec	dx
	and	al,bh
	cmp	al,0
@noport2:pop	ax
	out	dx,ax
	pop	bx
	ret

@_isport1:		;{check for valid i/o port, al is bit mask}
	mov	ah,al
	in	al,dx
	push	ax
	mov	al,ah
	out	dx,al
	in	al,dx
	and	al,ah
	cmp	al,ah
	jnz	@noport1
	mov	al,0
	out	dx,al
	in	al,dx
	and	al,ah
	cmp	al,0
@noport1:pop	ax
	out	dx,al
	ret


@_t3memchk:{				;[Charles Marslett -- ET3000 memory ck]}
	mov	dx,3dah
	in	al,dx			;{Reset the attribute flop (read 0x3DA)}
	mov	dx,03c0h
	mov	al,36h
	out	dx,al
	inc	dx
	in	al,dx			;{Save contents of ATTR[0x16]}
	push	ax
	or	al,10h
	dec	dx
	out	dx,al
	mov	dx,3ceh			;{Find the RAM buffer...}
	mov	al,6
	out	dx,al
	inc	dx
	in	al,dx
	and	ax,000Ch
	shr	ax,1

	mov	bx,ax
	push	es
	mov	es,[bx+offset buftbl]
	mov	ax,09C65h
	mov	bx,1
	mov	es:[bx],ax
	mov	es:[bx+2],ax
	inc	bx
	mov	ax,es:[bx]
	pop	es
	cmp	ax,0659Ch
	jne	@et3k_256
	mov	[vgamem],2
@et3k_256:
	mov	dx,3c0h
	mov	al,36h
	out	dx,al
	pop	ax
	out	dx,al			;{Restore ATTR[16h]}
	ret

@konec: end;

end.
