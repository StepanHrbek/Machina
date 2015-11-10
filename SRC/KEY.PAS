uses crt;
var i:byte;
label 1;
begin
1:
i:=ord(readkey);
if i=27 then exit;
writeln(i);
goto 1;
end.