{vytvori seznam pouzitych *. *.x --.exe
 vytvori seznam stranek}

uses  dos,sluzby;

VAR   firstvar:byte;
      usertyp:byte;

const sizebuf=30000;
      inspic      ='~';
      insbutton   ='';
      togl        ='þ';
{      gstu:word=0;
      maxpikcru=200;}

var   f,g                                       :text;
      filebuf                                   :array[1..sizebuf] of byte;
      readen,
      picuvtomhleclanku,buttonuvtomhleclanku    :word;
{      dulezitejgst,prenic,pretec,precar         :array[1..maxpikcru] of boolean;
      gst                                       :array[1..maxpikcru] of string[13];
      gstsize                                   :array[1..maxpikcru] of longint;}
      wait,pcxs                                 :boolean;

procedure ehalt(n:word);
begin
 if ioresult>0 then ;
 writeln('--error ',n,'--');
 writeln('usertyp=',usertyp);
 halt;
end;

procedure chybi(st:string);
begin
 writeln('Chyb¡ str nka: ',st);
 wait:=true;
end;

FUNCTION navaznost(st1,st2:string):boolean;
var i,j:word;
begin
 navaznost:=false;
 i:=length(st1);
 if i<>length(st2) then exit;
 if copy(st1,1,i-1)<>copy(st2,1,i-1) then exit;
 if ord(st1[i])+1<>ord(st2[i]) then exit;
 navaznost:=true;
end;



var   list:array[1..1000] of record fajl:string[12];typ:byte;dulezitej:boolean;end;
      userstring,userstring2:string;
const polozek:word=0;
      typ_pic=1;
      typ_pcx=2;
      typ_cla=3;{vsechny stranky}
      typ_sub=4;{substranky=volane odnekud}
      typ_rip=5;
      typ_sam=6;
      typ_mus=7;
      typ_pir=8;
      typ_hes=9;

PROCEDURE AddThing2List(n:byte;st:string);
var   i,j:word;
begin
 if n=typ_pcx then pcxs:=true;
 st:=locasestring(st);
 for i:=1 to polozek do with list[i] do if (typ=n) and (fajl=st) then exit;
 inc(polozek);
 list[polozek].fajl:=st;
 list[polozek].typ:=n;
end;


PROCEDURE DoPicyThingyWithUserstring;{umaze prvni znak pokud je '.' or '-'}
var   st2:string;
      pre:char;
label uztamje;
begin
 inc(picuvtomhleclanku);
 st2:='';
 case userstring[1] of '.','-':begin pre:=userstring[1];delete(userstring,1,1);end;
                          else pre:=' ';
                          end;
 {*
 if opendatafile(userstring) then begin
   gstsize[gstu+1]:=lengthdatafile;
   if lengthdatafile<10000 then dulezitejgst[gstu+1]:=true;
   closedatafile;
   end;
 for k:=1 to gstu do if st2=gst[k] then goto uztamje;
 inc(gstu);
 gst[gstu]:=st2;
 k:=gstu;
 uztamje:
 case pre of ' ':prenic[k]:=true;
             '-':precar[k]:=true;
             '.':pretec[k]:=true;
             end;
 }
end;

PROCEDURE Zarad(typ:word;st:string);
begin
 while st>'' do AddThing2List(typ,cutstringfromstring(' ',st));
end;

PROCEDURE ZpracujUserstring;
begin
 case usertyp of
                 typ_pic:begin{1(abc)}
                         if pos('(',userstring)>0 then userstring:=cutstringfromstring('(',userstring);
                         DoPicyThingyWithUserstring;
                         end;
                 typ_rip:if (userstring>'') and (userstring[1]='(') then begin{(,,1) abc}
                           delete(userstring,1,1);
                           Zarad(typ_sam,cutstringfromstring(',',userstring));
                           Zarad(typ_sam,cutstringfromstring(',',userstring));
                           userstring:=cutstringfromstring(')',userstring);
                           end
                         else userstring:='';
                 typ_pir:{1 abc}if pos(' ',userstring)>0 then userstring:=cutstringfromstring(' ',userstring);
                 typ_cla:{1};
                 typ_sub:begin{abc CR/LF 1}
                         userstring:=userstring2;
                         inc(buttonuvtomhleclanku);
                         end;
                 typ_sam:{1};
                 typ_mus:{1 2 3};
                 typ_hes:{*dodelat};
                 else ehalt(1);
                 end;
 Zarad(usertyp,userstring);
end;

PROCEDURE Zapis(n:byte);
var   i:word;
begin
 for i:=1 to polozek do with list[i] do if typ=n then
 if fajl='' then
 asm nop;end
 else
 writeln(g,fajl);
end;


VAR
      i,j,k,l,m,handle                          :word;
      menuon                                    :boolean;
      titleon                                   :boolean;
      t                                         :searchrec;
      str                                       :string;
      budeaddon                                 :boolean;
      rootsize,addsize                          :longint;

LABEL bad1,bad2,bad3,newfile,nextchar,
      uztamje2,shoda,skip,skip2,
      next;

VAR  lastvar:byte;

BEGIN
 fillchar(firstvar,ofs(lastvar)-ofs(firstvar),0);
 writeln;
{* cd('e:');{}

 {---------------nacte seznam clanku-----------------------------}

 findfirst('*.',0,t);
 while doserror=0 do begin
  AddThing2List(typ_cla,t.name);
  findnext(t);
  end;


{----------------------hleda PCXy do slideshow--------------------}

 for i:=1 to polozek do with list[i] do if typ=typ_cla then begin
   str:='x\'+copy(fajl,1,6);
   j:=0;
   next:
   findfirst(str+chr(48+j div 10)+chr(48+j mod 10)+'.pcx',0,t);
   if doserror=0 then begin
     AddThing2List(typ_pcx,t.name);
     inc(j);
     goto next;
     end;
   end;


 {----------prelouska clanky a vyhleda ktery fajly budou treba----------}

 for i:=1 to polozek do if list[i].typ=typ_cla then begin

{  if list[i].fajl='agent' then
   asm nop;end;}

  picuvtomhleclanku:=0;
  buttonuvtomhleclanku:=0;

  write(#10#13,list[i].fajl);

{  if length(list[i].fajl)>12 then
    asm nop;end;}

  {precte text z disku}
  str:=list[i].fajl+#0;
  asm {open st}mov ah,3dh;mov al,0;mov dx,offset str+1;int 21h;jc @err
      {read st}mov handle,ax;mov bx,ax;mov ah,3fh;mov cx,sizebuf;lea dx,filebuf;int 21h;mov readen,ax;jc @err
      {close st}mov ah,3eh;mov bx,handle;int 21h;jmp @9;
      @err:push 2;call ehalt
      @9:end;

  inc(rootsize,readen);

  asm push ds;pop es
      lea si,filebuf
      lea dx,filebuf;add dx,readen;{dx=ofs_zalastchar}
    @nextline:
      mov di,si{si=zacatek lajny}
      mov al,13;mov cx,dx;sub cx,di;add cx,1;repne scasb;sub di,2{di=posledni znak lajny pred 13}
      db 66h;mov ax,[si]
      mov bl,typ_pic;cmp al,INSPIC             ;jz @thing1
      mov bl,typ_sub;cmp al,INSBUTTON          ;jz @thing1
      mov bl,typ_rip;cmp al,TOGL               ;jz @thing1
      mov bl,typ_sam;db 66h;cmp ax,'is';db 'n:';jz @thing4
      mov bl,typ_sam;db 66h;cmp ax,'os';db 'u:';jz @thing4
      mov bl,typ_mus;db 66h;cmp ax,'um';db 's:';jz @thing4
      mov bl,typ_hes;db 66h;cmp ax,'eh';db 's:';jz @thing4
      jmp @checkend

    @thing4:add si,3
    @thing1:add si,1
      mov usertyp,bl
      pusha

      {zkopci lajnu1 do stringu1}
      push di
      sub di,si;mov cx,di;inc cx
      lea di,userstring
      mov al,cl;stosb;
      rep movsb
      pop di

      {zkopci lajnu2 do stringu2}
      add di,3
      mov si,di
      mov al,13;mov cx,dx;sub cx,di;add cx,1;repne scasb;sub di,2
      sub di,si;mov cx,di;inc cx
      lea di,userstring2
      mov al,cl;stosb;
      rep movsb

      push es
      call ZpracujUserString
      pop es

      popa

    @checkend:
      mov si,di
      add si,3
      cmp si,dx;jc @nextline
      end;

{
  if (buttonuvtomhleclanku>0) or (list[i].fajl=locasestring(title)) then
   for j:=1 to picuvtomhleclanku do dulezitejgst[gstu+1-j]:=true;
}
  end;


{------------------sejvne seznam potrebnejch souboru-----------------}

 assign(g,datalist);rewrite(g);

 zapis(typ_sam);
 zapis(typ_mus);
 zapis(typ_rip);
 zapis(typ_cla);
 zapis(typ_pir);
 zapis(typ_pic);
{ writeln(g,'dark.sid');}

 (*
 {---> zapise dulezity pikcry  {LOCAL}
 for i:=1 to gstu do if dulezitejgst[i] then begin
   writeln(g,gst[i]);
   inc(rootsize,gstsize[i]);
   end
  else begin
   budeAddOn:=true;
   inc(addsize,gstsize[i]);
   end;

 if budeAddOn then begin
   if rootsize>2*addsize then writeln(g);
   {---> zapise nedulezity pikcry  {LOCAL}
   for i:=1 to gstu do if not dulezitejgst[i] then writeln(g,gst[i]);
   end;
*)

 if pcxs then writeln(g);
 zapis(typ_pcx);
 close(g);

{-------------------warnings-------------------------}
(*
 {hlasky o zmensenejch pikcrech}
 writeln;
 writeln;
 for i:=1 to gstu do if pretec[i] and not precar[i] and not prenic[i] then begin
   writeln('Zmensit: ',gst[i]);
{   wait:=true;}
   end;
*)
 {hlasky o nedosazitelnejch strankach}
 writeln;
 for i:=1 to polozek do with list[i] do if typ=typ_cla then begin
   {zkontroluje zda neni v seznamu volanejch}
   for j:=1 to polozek do if (list[j].typ=typ_sub) and (list[j].fajl=fajl) then goto skip;
   {zkontroluje zda to neni menu, title}
   if fajl=locasestring(menu)  then menuon:=true else
   if fajl=locasestring(title) then titleon:=true else begin
     {zkontroluje zda to neni abc2,3 atd}
     for k:=1 to polozek do if (typ=typ_cla) and navaznost(list[k].fajl,fajl) then goto skip;
     {ohlasi ze stranka neni dosazitelna}
     writeln('Nezarazena stranka: ',fajl);
     wait:=true;
     skip:
     end;
   end;

 {hlasky o tom co chybi}
 writeln;
 if not menuon  then chybi(menu);
 if not titleon then chybi(title);
 for i:=1 to polozek do with list[i] do if typ=typ_sub then begin
   {zkontroluje zda neni v seznamu existujicich clanku}
   for j:=1 to polozek do if (list[j].typ=typ_cla) and (list[j].fajl=fajl) then goto skip2;
   chybi(fajl);
   skip2:
   end;

 if wait then begin
   close(g);
{*   deletefile(datalist);}
   waitkey;
   end
END.

kousne se kdyz neni textfajl zakoncenej CR/LF

