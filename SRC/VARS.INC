PROCEDURE Vars;assembler;
 asm
  {0-boolean
   1-byte                      ÚÄÄ32=dont update it in modifyinipodleini
   2-word                      ³ ÚÄÄ16=zda se ma sejvovat po midasconfigu
   3-UPstring                  ³ ³ ÚÄÄ8=zda se ma sejvovat na konci
   4-hex_word                  ³ ³ ³ ÚÄÄ0..7=typ promenny
   5-??string                                                }
{$ifdef midas}
  db 'zvukovakarta'         ,0,  16 +2;dw offset midasSDnumber
  db 'typkarty'             ,0,  16 +2;dw offset midasSDcard
  db 'vystupnimod'          ,0,  16 +2;dw offset midasOutputMode
  db 'irq'                  ,0,  16 +2;dw offset midasSDirq
  db 'dma'                  ,0,  16 +2;dw offset midasSDdma
  db 'port'                 ,0,  16 +4;dw offset midasSDport
  db 'mixovacifrekvence'    ,0,  16 +2;dw offset midasMixRate
  db 'maxkanalu'            ,0,      1;dw offset maxMusChannels
  db 'zesilovac'            ,0,      2;dw offset IniAmplify{midasAmplification}
{$endif}
  db 'hlasitosthudby'       ,0,    8+1;dw offset hlasitosthudby
  db 'hlasitostefektu'      ,0,    8+1;dw offset hlasitostefektu
  db 'stridanihudby'        ,0,    8+1;dw offset stridanihudby
  db 'citlivostmysi'        ,0,    8+1;dw offset citlivostmysi
  db 'rychlostscrollingu'   ,0,    8+1;dw offset rychlostscrollingu
  db 'detekovatems'         ,0,      0;dw offset detekovatems
  db 'synchronizace'        ,0,    8+0;dw offset definetimer
  db 'retrace'              ,0,      2;dw offset vadnejRetrace
  db 'crtc5'                ,0,      4;dw offset crtc5
{$ifdef dostran}
  db 'rozsvecetdiody'       ,0,      0;dw offset rozsvecetdiody
  db 'scrolllock'           ,0,    8+0;dw offset scrolllock
  db 'jemnedoladeniscrolu'  ,0,      3;dw offset jemnedoladeniscrolu
  db 'vgadriver'            ,0,    8+3;dw offset vgadriver
  db 'pocetviditelnychbanku',0,    8+1;dw offset viditelnychbanku
{$endif}
  db 'verzeini'             ,0,32+   2;dw offset verzeini
  db 'jmeno'                ,0,      5;dw offset inijmeno
  db 'ukladatanketnilistky' ,0,      0;dw offset ukladatanketnilistky
  db 'ukladatsetup'         ,0,      0;dw offset ukladatsetup
  db 0
  end;
