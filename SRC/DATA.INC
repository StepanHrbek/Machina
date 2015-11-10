CONST
      cislo='12';
      verzenum=43;
      verze=chr(48+verzenum div 100)+chr(48+verzenum div 10 mod 10)+chr(48+verzenum mod 10);

      datalist      ='data.lst';
      datahead      ='data.hea';
      anketa        ='anketa';
      IniName       ='DISKMAG.INI';
      curworkdir    ='C:\DISKMAGS\PARENIST\';

      sam_goodbye   ='goodbye.wav';
      sam_rip       ='meepmeep.wav';
      sam_ne        ='incorrec.wav';
      sam_goon      =1;
      sam_goback    =2;
      sam_setupon   =3;
      sam_setupout  =5;
      sam_menuon    =4;
      sam_menuout   =5;
      sam_togl      =6;
      sam_slide     =7;
      sam_cvak      =5;
      sam_nope      =8;
      sam_local     =9;
      exesamplu     =sam_local-1;
      maxsamplu     =exesamplu+1; {global}
      EXEsamply:array[1..exesamplu] of string[12]=('goon.raw','goback.raw',
                       'setupon.raw','menuon.raw','menuout.raw','togl.raw',
                       'slide.raw','nope.raw');

      headfirst     ='Dement''s MagZine Format ';
      headroot      ='Root';
      headaddon     ='AddOn';
      headfor       ='for';
      headbreak     =' þ ';
      headlast      =#13#10#13#10#0;

      commonDM      ='DISKMAG.DM';
      commonEdDM    ='EDITOR.DM';

      hdrinsertu=13;
      hdrinserty:array[1..hdrinsertu] of record
                                           txt:string[4];
                                           typ:string[9];
                                           popis:string[14];
                                         end=(
{          (txt:'tex:';typ:''          ;popis:'    Pozad¡    '),}
          (txt:'si1:';typ:'wav\*.wav' ;popis:'WAV:vstup  sem'),
          (txt:'si2:';typ:'wav\*.wav' ;popis:'WAV:n vrat sem'),
          (txt:'sin:';typ:'wav\*.wav' ;popis:'WAV:vstp+n vrt'),
          (txt:'sen:';typ:'wav\*.wav' ;popis:'WAV:out forwrd'),
          (txt:'sou:';typ:'wav\*.wav' ;popis:'WAV:out goback'),
          (txt:'mus:';typ:'*.mod'     ;popis:'    Hudba     '),
          (txt:'pir:';typ:'x\*.pir'   ;popis:'    Pir t     '),
          (txt:'ank:';typ:'anketa.sav';popis:'Anketn¡ l¡stek'),
          (txt:'hes:';typ:''          ;popis:'    Heslo     '),
          (txt:'***:';typ:''          ;popis:'  Po‡et TAB–  '),
          (txt:'***:';typ:''          ;popis:' Import textu '),
          (txt:'***:';typ:''          ;popis:'Tabulka  knihy'),
          (txt:'***:';typ:''          ;popis:' Tabulka  hry '));
{      hdr_tex=1;
      hdr_si1=hdr_tex+1;}
      hdr_si1=1;
      hdr_si2=hdr_si1+1;
      hdr_sin=hdr_si2+1;
      hdr_sen=hdr_sin+1;
      hdr_sou=hdr_sen+1;
      hdr_mus=hdr_sou+1;
      hdr_pir=hdr_mus+1;
      hdr_ank=hdr_pir+1;
      hdr_hes=hdr_ank+1;
      hdr_tab=hdr_hes+1;
      hdr_imp=hdr_tab+1;
      hdr_kni=hdr_imp+1;
      hdr_hra=hdr_kni+1;

