var   i,j:word;
      f:text;
const st:string='RIPRIPRIP'#0'rip'#0#255;
      a0=$a0;

begin
 assign(f,'hesla.inc');rewrite(f);
 writeln(f,'const hesla:array[1..',length(st),'] of byte=(');
 for i:=1 to length(st)-1 do begin
   write(f,ord(st[i]) xor a0,',');
   if i mod 20=19 then writeln(f);
   end;
 writeln(f,ord(st[i+1]) xor a0,');');
 close(f);
end.