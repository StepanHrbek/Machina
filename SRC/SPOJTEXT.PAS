{precte vsechny soubory '*.'
 vsechno zapise do unity texty }

uses dos;

{$I nazvy.inc}

const sizebuf=40000;
      error:byte=0;
      inspic='~';

var f,g:text;
    i,j,radek:word;
    st:string;
    filebuf:array[1..sizebuf] of byte;
    str:array[1..100] of string[50];
    len:array[1..100] of word;
    desthandle:word;
    readen:word;
    ofsst,ofsbuf:word;
    handle:word;
    t:searchrec;

begin
 writeln;
 i:=1;
 findfirst('*.',0,t);
 while doserror=0 do begin
  str[i]:=t.name;
  for j:=1 to length(str[i]) do str[i,j]:=chr(ord(str[i,j])+ord('a')-ord('A'));
  inc(i);
  findnext(t);
  end;

 radek:=i-1;


 {-------}
 assign(g,datalist);rewrite(g);writeln(g,'--.exe');
 assign(f,'texty2.inc');rewrite(f);
 ofsst:=ofs(st)+1;
 ofsbuf:=ofs(filebuf);
 for i:=1 to radek do begin

  {precte text z disku}
  write(#10#13,str[i]);
  st:=str[i]+'.'+#0;
  asm {open st}mov ah,3dh;mov al,0;mov dx,ofsst;int 21h;jc @err
      {read st}mov handle,ax;mov bx,ax;mov ah,3fh;mov cx,sizebuf;mov dx,ofsbuf;int 21h;mov readen,ax;jc @err
      {close st}mov ah,3eh;mov bx,handle;int 21h;
      {error}jmp @9;
      @err:mov error,1;
      @9:end;
  if error>0 then begin writeln('    error...');halt;end;
  len[i]:=readen;


  {hleda odkazy na grafiku}
  for j:=1 to readen do if filebuf[j]=ord(inspic) then
    repeat inc(j);write(g,chr(filebuf[j])) until filebuf[j]=10;


  {zapise data do textfajlu}
  write(f,'PROCEDURE _'+str[i]+';assembler;asm');
  for j:=1 to readen do begin
    if j mod 20=1 then write(f,#10#13'db ',filebuf[j])
                  else write(f,',',filebuf[j]);
    end;
  writeln(f,#10#13'end;');


  end;


 close(f);
 close(g);
 {-------}
 assign(f,'texty1.inc');rewrite(f);
 for i:=1 to radek do
   writeln(f,'PROCEDURE _'+str[i]+';');

 writeln(f,#10#13'CONST textfajlu=',radek,';');

 writeln(f,#10#13'CONST adresatextu:array[1..textfajlu] of pointer=(');
 for i:=1 to radek do begin
  write(f,'  @_',str[i]);
  if i<radek then writeln(f,',') else writeln(f,');');
  end;

 writeln(f,#10#13'CONST delkatextu:array[1..textfajlu] of word=(');
 for i:=1 to radek do begin
  write(f,'  ',len[i]);
  if i<radek then writeln(f,',') else writeln(f,');');
  end;

 writeln(f,#10#13'CONST nazevtextu:array[1..textfajlu] of string[8]=(');
 for i:=1 to radek do begin
  write(f,'  ''',str[i],'''');
  if i<radek then writeln(f,',') else writeln(f,');');
  end;

 close(f);
 {-------}
end.