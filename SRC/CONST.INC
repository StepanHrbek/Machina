CONST
      menu  ='MENU';
      title ='TITLE';

      verzeIni             :word=0;
      IniJmeno             :string[20]='anonym';
      UkladatAnketniListky :boolean=true;
      UkladatSetup         :boolean=true;
      debuginfo            :boolean=false;
      detekovatEMS         :boolean=true;
      stridanihudby        :byte=5;
      forcecurworkdir      :boolean=false;
      jemnedoladeniscrolu  :string[6]='kmopa';
      VadnejRetrace        :word=1;
      crtc5                :integer=-1;

      {nasledujici promenny az do VGAdriver musej mit dohromady 40 bytu}
      hlasitostHudby       :byte=32;      {meni se}
      hlasitostEfektu      :byte=64;      {meni se}
      rychlostScrollingu   :byte=24;      {meni se}
      citlivostMysi        :byte=32;      {meni se}
      defineTimer          :byte=1;       {meni se}

{$ifdef dostran}
      scrolllock           :boolean=false;{meni se}
      viditelnychBanku     :byte=1;       {meni se}
      VGAdriver            :stringpath='';{meni se}
      rozsvecetdiody       :boolean=false;
VAR   startupDrv           :stringpath;
TYPE  array40=array[1..7] of byte;
{$else}
TYPE  array40=array[1..5] of byte;
{$endif}

(*
CONST
      vlastnihandlerByte   :byte=255;{255 kvuli autodetekci}
VAR   vlastnihandler       :boolean absolute vlastnihandlerByte;
*)
VAR
      setupAbsolute        :array40 absolute hlasitosthudby;
      startupSetup         :array40;
