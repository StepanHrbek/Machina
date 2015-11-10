{$i hesla.inc}
FUNCTION Password:string;
var   i:word;
      c:char;
      stranka,heslo:string;
      zatimok:boolean;
const a0=$a0;
label nextword,nextchar;
begin
 password:='';
 if now.local_askstringu<>1 then exit;

 i:=bh_hesla;                              i:=ofs(hesla);bh_seg:=seg(hesla);
nextword:
 heslo:='';
 zatimok:=true;
nextchar:
 c:=chr(byte(mem[bh_seg:i]) xor a0);
 heslo:=heslo+c;
 inc(i);
 case c of #0:begin
              stranka:='';
              repeat
               c:=char(byte(mem[bh_seg:i]) xor a0);
               inc(i);
               stranka:=stranka+c;
              until (c=#0) {or (c=#255)};
              dec(stranka[0]);
              if zatimok then begin password:=stranka;exit;end
                         else {if c=#255 then exit else} goto nextword;
              end;
         #255:begin
              {password:='';}
              exit;
              end;
         else begin
              if c<>askstring[now.nowask].stav[length(heslo)] then zatimok:=false;
              goto nextchar;
              end;
         end;
end;
