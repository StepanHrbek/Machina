uses crt;
{$i data.dat}
var comp,raw:longint;
    i:word;
const long1:longint=1;
begin
raw:=0;
comp:=0;
for i:=1 to datafajlu do with data[i] do if colors>0 then begin
  inc(comp,len);
  raw:=raw+long1*picx*picy;
  end;
writeln('  raw size: ',raw:7);
writeln('compressed: ',comp:7,'  ...',round(100*comp/raw),'%');
writeln;
readkey;
end.