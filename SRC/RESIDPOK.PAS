begin
asm
push ds
call @textcapture
pop ds
jmp @end
@textname: db 'text0001.txt',0
@crlf: dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0a0dh
@hand: dw 0
@textcapture:
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
     ret
     @end:
     end;
     end.