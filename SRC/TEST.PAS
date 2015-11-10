{$M 10000,0,0}
uses sluzby;
var i,bank:word;
BEGIN
 VesaInit;
 if mem[seg(vesabanku):ofs(vesabanku)]=0 then begin
   write('chybi vesa bios');
   halt;
   end;
 write(VesaInit512x464);
 for bank:=0 to 3 do begin
   asm mov ax,bank;call VesaBank;end;
   for i:=1 to 10000 do mem[sega000:random(65535)]:=16+8+random(8);
   for i:=0 to 511 do mem[sega000:512*(i div 4)+i]:=31;
   for i:=0 to 511 do mem[sega000:512*(i div 4)+511-i]:=31;
   for i:=0 to 511 do mem[sega000:512*(i div 4)]:=31;
   for i:=0 to 511 do mem[sega000:512*(i div 4)+511]:=31;
   end;
 readkey;
 setcolor(0,30,0,0);
 readkey;
END.