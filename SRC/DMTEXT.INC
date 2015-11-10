const
      CR           =#13;
      LF           =#10;
      EOP          =#0;        {konec stranky}
      TAB          =#9;

      chgINIT      ='';      {1 znak vyhrazeny pro nasledujici:}
      chgCOL       ='a';       {znaky pro zmenu barvy}
      chgFNT       ='0';       {znaky pro zmenu fontu}
      chgLINK      ='';       {znak pro linky}
      chgCOLs      =12;
      chgFNTs      =4;
      chgCOLz      =chr(ord(chgCOL)+chgCOLs-1);
      chgFNTz      =chr(ord(chgFNT)+chgFNTs-1);
      chgCOLbard   =chr(ord(chgCOL)+4);
      chgCOLbig    =chr(ord(chgCOL)+5);

      cmdINIT      ='Ý';
      cmdDONE      ='Þ';
      cmdNEWSLP    ='^';
      cmdINSPIC    ='~';
      cmdRESIZE    ='r';
      cmdROVNALINE ='Ä';
      cmdSVISLALINE='³';
      cmdCHECKBOX  ='þ';
      cmdFORMAT    ='f';
      cmdSCRIPT    ='#';

