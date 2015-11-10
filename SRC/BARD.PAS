{precte font z bard.m36 a zapise ho do bard.inc}
USES crt;

TYPE  Tmap=array[1..36] of byte;
      Tbard=array[#0..#255] of record sir,vys:byte;map:Tmap;end;
CONST alen:word=0;
      last='}';
      now:char=#1;
      lc=4;carka:array[1..lc] of byte=(24,48,96,192);
      lh=3;hacek:array[1..lh] of byte=(99,54,28);
      lk=5;krouz:array[1..lk] of byte=(6,9,9,9,6);
VAR   bard:Tbard;
      f:file of byte;
      g:text;
      b:byte;
      i,j,bit,byt,bitsir,headlen:word;
      a:array[0..30000] of byte;

LABEL 1,2,3,4,5,6,7;

BEGIN
bitsir:=16;
headlen:=26;
textmode(co80+font8x8);
assign(f,'bard.m36');
reset(f);
for i:=1 to 73 do read(f,b);
assign(g,'bard.inc');
rewrite(g);
writeln(g,'CONST bardhead:array['' ''..''',last,'''] of record bofs:word;bsir,bvys,bdx,bdy,bdx2:byte;end=(');
2:
with bard[now] do begin

  {cte jednu bitmapku}
  i:=0;
  3:
  inc(i);
  read(f,map[i]);
  if (map[i-1]<>$1b) or (map[i]<>$2a) then goto 3;
  vys:=i-2;
  if map[11]=ord('W') then begin
   dec(vys);
   for i:=1 to vys do map[i]:=map[i+1];
   end;
  bitsir:=((map[22]-1) shr 3+1) shl 3;

  {nasimuluje carku,hacek,krouzek misto '{','|','}
  case now of '{':begin
                  for i:=1 to lc do map[headlen+i]:=carka[i];
                  map[18]:=0;
                  map[20]:=15;
                  map[22]:=1;
                  map[26]:=15;
                  map[24]:=lc;
                  end;
              '|':begin
                  for i:=1 to lh do map[headlen+i]:=hacek[i];
                  map[18]:=0;
                  map[20]:=15;
                  map[22]:=1;
                  map[26]:=15;
                  map[24]:=lh;
                  end;
              '}':begin
                  for i:=1 to lk do map[headlen+i]:=krouz[i];
                  map[18]:=0;
                  map[20]:=15;
                  map[22]:=1;
                  map[26]:=15;
                  map[24]:=lk;
                  end;
              end;

  4:
  textattr:=7;
  clrscr;

  {kresli bitmapu}
  if now<' ' then begin inc(now);goto 2;end;
  if bitsir=0 then goto 6;
  byt:=headlen+1;
  i:=0;
  bit:=0;
  5:
  textattr:=7;
  gotoxy(20,1+(byt-headlen) div (bitsir div 8));
  for i:=1 to bitsir do begin
    textattr:=16*(1+map[byt] shr (7-bit) mod 2);write('  ');
    inc(bit);if bit=8 then begin bit:=0;inc(byt);if byt>vys then goto 6;end;
    end;
  goto 5;
  6:

  {pise header}
  textattr:=7;
  gotoxy(1,1);
  for byt:=1 to headlen do begin
    write('[',byt:2,']=',map[byt]:3);
    if (byt<18) and (map[byt]>31) then write('=(',chr(map[byt]),')');
    case byt of 18:write(' - posun tohoto pismene doprava(pix)');
                20:write(' - nadsaz nad radku(pix)');
                22:write(' - sirka(pix)');
                24:write(' - vyska(pix)');
                26:write(' - posun dalsiho pismene doprava(pix)');
                end;
    writeln;
    end;
  7:
  write(g,'(bofs:',alen,';bsir:',map[22],';bvys:',map[24],';bdx:',map[18],';bdy:',map[20],';bdx2:',map[26],')');
  if now<last then writeln(g,',') else writeln(g,');');
  for i:=headlen+1 to headlen+bitsir div 8*map[24] do begin a[alen]:=map[i];inc(alen);end;

  if now=#95 then begin inc(now);goto 7;end;
  if now<last then begin inc(now);goto 2;end;
  end;
1:
close(f);

dec(alen);
writeln(g);
writeln(g,'CONST bardbody:array[0..',alen,'] of byte=(');
for i:=0 to alen-1 do begin
  write(g,a[i],',');
  if i mod 20=19 then writeln(g);
  end;
writeln(g,a[alen],');');
close(g);
END.

kazde pismeno zacina znackou 1B 2A 63
