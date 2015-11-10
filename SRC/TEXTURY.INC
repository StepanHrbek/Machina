procedure testing;

{-------------------------------------------------------------
;{konstanty
;{-------------------------------------------------------------}
const
      sir=256;
      vys=256;
      bobu=9;
      sped=0;
      spee=21;
      mvel=15;
      minsed=32;
      maxsed=40;
      fogsir=256

;begin
;asm
;push ds
;push es
;pop ds
;{call @Nebe_A_Dudy}
;call @StounKiip
;pop ds
;jmp @end

@init: dw 1234h

;{-------------------------------------------------------------
;{globalni rutiny
;{-------------------------------------------------------------}

@random2ax:
   push dx
   mov ax,1237h
   mul [cs:word ptr @init]
   mov [cs:word ptr @init],ax
   pop dx
   ret


;{-------------------------------------------------------------
;{hlavni 2 rutiny na nebe a zed
;{-------------------------------------------------------------}

@Nebe_A_Dudy:;{------------------------------------------------}
;{generuje texturu nebe 128x128 od DS=ES:0
;{modifikuje spoustu registru
;{pouziva celych 64KB v DS
;{paleta 31-39: db ' UUOT\3DX&;T'9P(;L)<H*>D,@@'
;{ zapsana zpusobem r,g,b; hodnoty+32}

   ;{fill seg}
   xor di,di
   mov ax,257*31
   mov cx,32768
   rep stosw

   ;{generuje zaklad textury}
   xor ax,ax
   mov si,ax
   mov di,ax
   mov bx,4
   @loop:
   lodsb
   test al,1
   jnz @single
   add di,3
   @single:
   add di,256
   inc si
   inc byte ptr [di]
   loop @loop
   dec bx
   jnz @loop

   ;{zjemneni textury}
   xor di,di
   mov dx,4
   @11:
   xor cx,cx
   mov ah,[di]
   @10:
   mov al,[di]
   mov bl,al
   add al,ah
   shr al,1
   stosb
   mov ah,bl
   loop @10
   dec dx
   jnz @11

   ;{tadydadyda}
   call @tex_zmensi
   RET


@StounKiip:;{--------------------------------------------------}
;{generuje texturu zdi 128x128 od DS=ES:0
;{modifikuje spoustu registru
;{pouziva celych 64KB v DS}
;{paleta 31-40: db '32<MIBB>674+-+ 3%#6+(90+=60@;3'
;{ zapsana zpusobem r,g,b; hodnoty+32}

   ;{fill seg}
   xor di,di
   mov ax,257*36
   mov cx,32768
   rep stosw

   ;{generuje zaklad textury}
   mov cx,800
   @41:
   push cx
   call @random2ax
   mov di,ax
   call @zamlz
   pop cx
   loop @41

   ;{nasklada tam cihly}
   mov di,256*50
   mov al,5
   mov si,56

   mov dx,8
   @nextboxline:
   mov cx,4
   @nextbox:
   pusha
   mov dx,27
   call @SubBox
   popa
   add di,64
   loop @nextbox
   add di,sir*31+32
   dec dx
   jnz @nextboxline



   ;{tadydadyda}
   call @tex_rozsyp
   call @tex_rozsyp
   call @tex_rozsyp
   call @tex_zamichej
   call @tex_zmensi
   RET

;{-------------------------------------------------------------
;{pomocne rutinky pro generovani textur
;{-------------------------------------------------------------}

@SubBox:
;{vstup: di - adresa kam to mrsknout
;{       al - jak hluboko ji vymacknout
         dx - vyska
         si - sirka}
     add di,si
     @2:
     mov cx,si
     sub di,cx
     @1:
     sub [di],al
     inc di
     loop @1
     add di,sir
     dec dx
     jnz @2
     ret

@zamlz:
;{vstup: di - adresa kde to ma zamlzit}
   mov ah,maxsed
   mov dx,mvel
   @52:
   mov cx,mvel
   @51:
   cmp [di],ah
   jnc @nomlha1
   inc byte ptr [di]
   @nomlha1:
   inc di
   loop @51
   add di,fogsir-mvel-4
   dec dx
   jnz @52
   ret

@odmlz:
;{vstup: di}
   mov ah,minsed
   mov dx,mvel
   @62:
   mov cx,mvel
   @61:
   mov al,[di]
   cmp al,ah
   jc @nomlha2
   dec al
   mov [di],al
   @nomlha2:
   inc di
   loop @61
   add di,fogsir-mvel-3
   dec dx
   jnz @62
   ret


;{-------------------------------------------------------------
;{ruzne filtry na prohaneni textur
;{-------------------------------------------------------------}

@tex_zmensi:;{-------------------------------------------------}
   xor si,si
   xor di,di
   mov dx,128
   @22:
   mov cx,128
   @21:
   lodsw
   add ax,[si+254]
   add al,ah
   shr al,2
   stosb
   loop @21
   add si,256
   dec dx
   jnz @22
   ret

@tex_zamichej:;{-----------------------------------------------}
   xor si,si
   xor di,di
   mov cx,25600
   @31:
   add di,[cs:si]
   add di,5555
   movsb
   add si,21
   loop @31
   ret

@tex_rozsyp:;{-------------------------------------------------}
   xor si,si
   xor di,di

   mov bx,[si]

   mov dx,sir
   @mlznextslp:
   mov cx,vys
   cmp dx,1
   jnz @fullvys
   sub cx,2
   @fullvys:
   @mlznextline:
   add si,sir
   mov ax,bx
   mov bx,[si]

   ;{testuje presyp AL,AH}
   cmp al,ah
   jz @same1
   jnc @incAH
   sub ax,2*0ffh
   @incAH:
   add ax,0ffh
   @same1:

   ;{testuje presyp AL,BL}
   cmp al,bl
   jz @same2
   jnc @incBL
   dec bx;{bl}
   inc ax;{al}
   jmp @same2
   @incBL:
   inc bx;{bl}
   dec ax;{al}
   @same2:

   mov [si-sir],ax

   loop @mlznextline
   sub si,vys*sir-1
   dec dx
   jnz @mlznextslp
   ret

@end:
;END;end;
