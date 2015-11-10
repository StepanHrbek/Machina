var f:file of byte;
    g:text;
var b:byte;
    i,j:integer;
    a:array[0..10000] of byte;

BEGIN
 assign(f,'setup.a');reset(f);
 assign(g,'setup.inc');rewrite(g);
 i:=0;
 repeat
   read(f,a[i]);
   inc(i);
 until eof(f);
 dec(i);
 writeln(g,'const setuptextlen=',i,';');
 writeln(g,'const setuptext:array[0..setuptextlen] of byte=(');
 for j:=0 to i-1 do begin
   write(g,a[j],',');
   if j mod 20=19 then writeln(g);
   end;
 writeln(g,a[i],');');
 close(f);
 close(g);

END.