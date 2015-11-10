uses sluzby;
var a:boolean;
    cestaKexe,INIname,minulycislo,minulyINI:string70;
begin
 cestaKexe:='f:\-parenis';
 INIname:='pareni.ini';
 minulycislo:='6';
 a:=inteligentnehledejsoubor(cestaKexe,INIname,minulycislo,minulyINI);
 modifyINIpodleINI('pareni2.ini','pareni.ini');
end.