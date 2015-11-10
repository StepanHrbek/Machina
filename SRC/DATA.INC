CONST
      verzenum=352;
      compatto=verzenum div 10*10+9;
      verze   =chr(48+verzenum div 100)+chr(48+verzenum div 10 mod 10)+chr(48+verzenum mod 10);
      verzestr=chr(48+verzenum div 100)+'.'+chr(48+verzenum div 10 mod 10)+chr(48+verzenum mod 10){$ifdef beta}+'á'{$endif};

      beta=''{' - absolutne neoficialni'{};
      mach_msg='Deus ex Machina '+verzestr+beta+'.'#255;

      datalist      ='project.lst';
      datahead      ='project.hea';
      exclude       ='library.lst';
      {$ifdef big}
      bigpic        ='bigpic.lst';
      {$endif}

      headfirst     ='Dement''s MagZine Format ';
      headroot      ='Root';
      headaddon     ='AddOn';
      headfor       ='for';
      headbreak     =' þ ';
      headlast      =#13#10#13#10#0;


{$ifdef rain}
      wavs='*.wav;*.iff;*.mp3';
      mods='*.mod;*.s3m;*.xm;*.it;*.mp3';
{$else}
      wavs='*.wav;*.iff';
      mods='*.mod;*.s3m;*.mtm';
{$endif}
      fnts='*.fn';

