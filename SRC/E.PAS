uses sluzby;
  (*

PROCEDURE End28Msg(st:string);
type  Tend28=record c1,c2,c3:word;bo,sp:byte;end;
const endu28=3;
      end28:array[1..endu28] of Tend28=(
        (c1:(16*0+11)*256+ord('Û');c2:(16*4+15)*256+ord(' ');c3:(16*4+11)*256+ord('Ä');bo:0;sp:0),
        (c1:(16*2+10)*256+ord('Û');c2:(16*2+14)*256+ord(' ');c3:(16*2+ 0)*256+ord('Í');bo:0;sp:1),
        (c1:(16*2+10)*256+ord('ß');c2:(16*2+14)*256+ord(' ');c3:(16*2+10)*256+ord('Ä');bo:2;sp:0));
var   i:word;
      e28:byte;
begin
 e28:=random(endu28);
 i:=ofs(end28)+sizeof(Tend28)*e28;
 asm mov si,i
     {font size=15}
     mov dx,3d4h;mov al,9;out dx,al;inc dx;in al,dx;and al,240;add al,14;out dx,al
     {kurzor o pixel nahoru}
     mov ah,1;mov cx,0c0eh;int 10h
     {clr screen top}
     mov es,segb800;mov di,25*80*2
     mov cx,80;mov ax,[si  ];rep stosw{down line}
     mov cx,80;mov ax,[si+2];rep stosw{top text}
     mov cx,80;mov ax,[si+4];rep stosw{top line}
     {border=2}
     mov ax,1001h;mov bh,[si+6];int 10h
     {vertical panning}
     mov dx,3d4h;mov ax,0e08h;out dx,ax{}
     end;
 nowvis:=0;
 gotoxy((txsir-length(st)) shr 1,27);
 write(st);
 gotoxy(1,1);
 splitY(400-25*15-1-end28[e28].sp);
 setvis(80*25);
end;
*)
begin
 randomize;
 end28msg('ahooooj');
 readkey;
end.

