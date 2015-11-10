uses mids3m,sluzby;
type string70=string[70];
      togglerecord=record y1:word;on:byte;end;
var      cestaKank        :string70;
      cestaKdrv        :string70;
      cestaKexe        :string70;
      minulyINI        :string70;
      usedINIname      :string70;
      errorfile        :string[12];
      toggle,toggle2:array[1..40] of togglerecord;

const cislo='x';
      togglu=5;

PROCEDURE SaveAnketa;
var   i:byte;
      w:word;
      f:text;
      fajl:string;
label cantwrite;
begin
   if (length(cestaKank)>1) and (cestaKank[length(cestaKank)]<>'\') then cestaKank:=cestaKank+'\';
   fajl:='anketax.008';
   {zapise vysledek ankety}
   assign(f,fajl);
   rewrite(f);
   if ioresult>0 then goto cantwrite;
   for i:=1 to togglu do write(f,chr(48+toggle[i].on));
   writeln(f);
     {naplni 'fajl' beznym adresarem}
     w:=ofs(fajl);
     asm mov ah,47h;mov dl,0;mov si,w;inc si;mov di,si;push ds;push ss;pop ds;
         int 21h;pop ds;
         push ss;pop es
         mov si,w;inc si;mov al,0;mov cx,100;repne scasb;sub cx,99;neg cx
         mov di,w;mov [ss:di],cl
         end;
   writeln(f,fajl);
   writeln(f,cestaKexe);
   writeln(f,chr(48+SDnum)+chr(48+viditelnychbanku)+vgadriver);
   close(f);

 cantwrite:
end;
begin
saveanketa;
end.