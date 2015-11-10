{* public domain by Dement *}
{$S+,M 65000,0,0}

{---------------------------------------------------------------------------
 Otestuje zda string odpovida rozsirene hvezdickove konvenci a vraci vysledek.
 ---------------------------------------------------------------------------}

FUNCTION  OdpovidaKonvenci(st:string):boolean;
var   zavorek:integer;
      i:word;
label bad;
begin
 OdpovidaKonvenci:=false;
 zavorek:=0;
 for i:=1 to length(st) do case st[i] of '"':goto bad;
                                         '[':inc(zavorek);
                                         ']':if zavorek>0 then dec(zavorek) else goto bad;
                                     #0..#31:goto bad;
                                         '|':if zavorek=0 then goto bad;
                                         end;
 if zavorek<>0 then goto bad;
 OdpovidaKonvenci:=true;
 bad:
end;

{---------------------------------------------------------------------------
 Zjisti zda je prvni parametr (normalni nazev) zahrnut ve druhem parametru
 (hvezdickovou konvenci zapsany nazev) a vysledek vrati. Funkce predpoklada
 ze druhy parametr odpovida konvenci, nesnazi se detekovat nejake syntakticke
 chyby.
 ---------------------------------------------------------------------------}

FUNCTION XjeprvkemY(norm,hvezd:string):boolean;
var   i,j,k,l,m:byte;
label ok;
begin
 XjeprvkemY:=false;
 if norm=hvezd then goto OK;

 {odstrani sekvence hvezdicek, ktere zada vul snazici se zahltiti stack}
 for i:=length(hvezd)-1 downto 1 do if (hvezd[i]='*') and (hvezd[i+1]='*') then delete(hvezd,i,1);

 if norm='' then begin
   if hvezd[1]='*' then if XjeprvkemY('',copy(hvezd,2,255)) then goto OK;
   exit;
   end;

 for i:=1 to length(norm) do
   if i>length(hvezd) then exit
   {---------------- obstara syntaxi * ---------------}
   else
   if hvezd[i]='*' then
     begin
     for j:=i to length(norm)+1 do if XjeprvkemY(copy(norm,j,255),copy(hvezd,i+1,255)) then goto OK;
     end
   {---------------- obstara syntaxi [|] ---------------}
   else
   if hvezd[i]='[' then
     begin
     {i <- pozice zacatku vyrazu: '['}
     {k <- pozice konce vyrazu: ']'}
     l:=0;
     for k:=i+1 to length(hvezd) do case hvezd[k] of '[':inc(l);
                                                     ']':if l>0 then dec(l) else break;
                                                     end;
     {j <- pozice zacatku substringu: '[' nebo '|'}
     j:=i;
     repeat
       {m <- pozice konce substringu: '|' nebo ']'}
       l:=0;
       for m:=j+1 to k do case hvezd[m] of '[':inc(l);
                                           ']':if l>0 then dec(l) else break;
                                           '|':if l=0 then break;
                                           end;
       if XjeprvkemY(copy(norm,i,200),copy(hvezd,j+1,m-j-1)+copy(hvezd,k+1,255)) then goto OK;
       j:=m;
     until hvezd[m]=']';
     exit;
     end
   {---------------- obstara syntaxi ? ---------------}
   else
   if (hvezd[i]<>norm[i]) and (hvezd[i]<>'?') then exit;

 if not XjeprvkemY('',copy(hvezd,length(norm)+1,255)) then exit;
 ok:
 XjeprvkemY:=true;
end;


begin
 writeln(XjeprvkemY('12','[12|1]2'));
 writeln(XjeprvkemY(
  'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
  '*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a'+
  '*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a'+
  '*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a'+
  '*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a'
  ));
end.