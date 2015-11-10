FUNCTION LoadVgaDriver:boolean;
begin
 if debuginfo then writeln('Load VGA driver...');
 if not dm.opendatafile(VgaDriver) then LoadVgaDriver:=false else begin
   readdatafile(lastopenlength,ofs(hereisVGAdriver),seg(hereisVGAdriver));
   DM.closedatafile;
   end;
end;


{$L detekce}
procedure detekce;external;
var   vgamem:byte;
      Pvgadriver:^string;
PROCEDURE DetekceVga;
begin
 if debuginfo then writeln('Detect VGA driver...');
 detekce;
 viditelnychbanku:=vgamem;
 vgadriver:=Pvgadriver^+'.DRV';
end;


PROCEDURE SetupDrv;far;
var   doporucenejdrv:word;
      drvs:word;
      oldbanku:word;
      maxmem:byte;
const drvnamelen=50;

procedure PrepDrvNames2Workseg;
var   d,i,j:word;
      st:uknastring;
      maxmemch:char;
begin
 if debuginfo then writeln('Look for *.DRV...');
 doporucenejdrv:=1;
 drvs:=0;
 for d:=1 to datafajlu do with data[d] do if pos('.DRV',name)>0 then begin
   inc(drvs);
   if name=vgadriver then doporucenejdrv:=drvs;
   DM.opendatafile(name);
   readdatafile(lastOpenLength,0,workseg);
   DM.closedatafile;
   j:=memw[workseg:8]-$100;
   st:=ptr(workseg,j);
   maxmemch:=st^[0];
   st^[0]:=chr(drvnamelen);
   j:=0;
   for i:=1 to drvnamelen do begin
     if st^[i]=#0 then j:=1;
     if j=1 then st^[i]:=' ';
     end;
   st^[drvnamelen+1]:=maxmemch;
   st^[drvnamelen+2]:=chr(d mod 256);
   st^[drvnamelen+3]:=chr(d div 256);
   move(st^,mem[workseg:256*drvs],256);{struktura stringu: 50,string,mezery,maxmem}
   end;
end;

procedure SetupBanku;
var   i,pre,choosen:word;
      st:string[29];
begin
 for i:=1 to maxmem do begin
   str(256*i:4,st);
   st:=st+' KB videopamˆti';
   move(st,mem[workseg:256*i],30);
   end;
 if (viditelnychBanku>0) and (viditelnychBanku<=maxmem) then pre:=viditelnychBanku else pre:=maxmem;
 choosen:=menuselect(maxmem,ptr(workseg,256),256,pre);
 case choosen of 0:viditelnychBanku:=oldbanku;{pri ESC vrati puvodni stav}
                 else viditelnychBanku:=choosen;
                 end;
end;

var   ch:char;
      choosen,drvDkod:word;
      oldvgadriver:stringpath;
label 0;
begin
 oldvgadriver:=vgadriver;
 oldbanku:=viditelnychbanku;

 DetekceVga;
 PrepDrvNames2Workseg;

 0:
 choosen:=menuselect(drvs,ptr(workseg,256),256,doporucenejdrv);

 if choosen=0 then begin{pri ESC vse vrati do puvodniho stavu}
   VgaDriver:=oldvgadriver;
   viditelnychbanku:=oldbanku;
   exit;
   end;

 drvDkod:=memw[workseg:256*choosen+drvnamelen+2];
 VgaDriver:=data[drvDkod].name;

 if not LoadVgaDriver then begin
   writeln('Driver "',VgaDriver,'" nenalezen. Zadej jin˜.');
   goto 0;
   end;

 maxmem:=mem[workseg:256*choosen+drvnamelen+1];
 case maxmem of 1:viditelnychBanku:=1;
                2..16:SetupBanku;
                else errorhalt(44);
                end;
end;

