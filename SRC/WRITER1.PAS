UNIT  Writer1;

{$i define.inc}

{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}
                             INTERFACE
{‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹}

USES  Memo,Chyby,
      Objects,Strings,Dos,
      Vga,Fonty,Sys,Cache,
      Stringy,Fajly,Loadery,DMFile;{kvuli obrazkum v Str2BoxW}


{---------------------------------------------------------------------------
 Writer1 - prostredek k analyze a psani textu (uroven 1).
 ---------------------------------------------------------------------------}

type  SpecString = string[10];

      PWriter1 = ^TWriter1;
      TWriter1 = object(TObject)
                     {stXXXX - Scan Text}
                     stSrc        :Pchar;{ukazatel v textu}
                     stDest       :word;{ukazatel pozice X ve vystupu}
                     slpSir       :word;{sirka vystupu v pixelech}
                     stMezer      :word;{mezer v proskenovanem textu}
                     stSirmez     :word;{pocet pixelu zbylych na konci radku}

                     globshiftY   :integer;{vsechny vystupy maji o tolik souple Y}

                     blkOn        :boolean;{odlisit blok?}
                     blkStart     :word;{jinou barvou kresleny blok}
                     blkEnd       :word;

                     constructor  Init;
                     procedure    SetSpecChars(SpecChars:specstring);
                     procedure    SetProporc(proporc:byte);
                     procedure    SetBitmap(bitmap:PBitmap);
                     procedure    SetColor(color:longint);
                     procedure    SetBackgr(backgr:byte);
                     function     SetFont(name:string):boolean;
                     procedure    MaxReset;
                     function     MaxOver:integer;
                     function     MaxUnder:integer;
                     function     GetFontHeight:integer;
                     function     GetAddSpace:integer;
                     function     GetCharShift(c:char):integer;
                     function     GetPcLen(pc:pchar):integer;
                     function     GetMapSir:integer;
                     function     GetOtColor:longint;
                     function     GetOtBackColor:byte;
                     procedure    CheckFont;

                     procedure    ScanInit;
                     function     Scan:longint;
                     procedure    Print(pismen:word;src:Pchar;var mezer,sirmez,otX:word;otY:word);
                     procedure    PrintStr(st:string;var otX:word;otY:word);
                     destructor   Done;virtual;

                   private
                     {stXXXX - Scan Text}
                     stProporc    :byte;{0=proporc sirky jsou ve fontu; >0=konst.sirka tato}
                     stSpecChars  :specstring;{specialni znaky, ktere tato unita neumi zpracovat}
                     stMaxOver    :integer;{max sizeOver fontu od posledniho volani}
                     stMaxUnder   :integer;{max sizeUnder fontu od posledniho volani}
                     stPrevSrc    :word;{stSrc zacatku skenovaneho slova}
                     stPrevDest   :word;{stDest zacatku skenovaneho slova}
                     stPrevOver   :integer;{stMaxOver zacatku skenovaneho slova}
                     stPrevUnder  :integer;{stMaxUnder zacatku skenovaneho slova}
                     stFirstword  :boolean;{skenuje teprv prvni slovo na radce?}

                     {otXXXX - Out Text}
                     otFont       :PFont;
                     otColor      :longint;
                     otBackColor  :byte;
                   public{jen kvuli printpicu a reportflicu}
                     otBitmap     :PBitmap;
                   private
                     procedure    FreeFont;
                   end;
Function StrBox(model:byte;w:PWriter1;pc:pchar;rezerva:word;backcol:longint):PBitmap;
Function Str2BoxW(b:PBitmap;winx1,winy1,winsir,winvys:word;
                 w:PWriter1;pic:boolean;pc:pchar;side:shortint;backcol:longint):boolean;
Function Str2Box(b:PBitmap;winx1,winy1,winsir,winvys:word;
                 pc:pchar;side:shortint;fnt:PathStr;forecol,backcol:longint):boolean;



{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}
                          IMPLEMENTATION
{‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹}


Constructor TWriter1.Init;
begin
 inherited Init;
 SetSpecChars(#0);
 SetProporc(0);
end;

{---------------------------------------------------------------------------
 Nastavi seznam specialnich znaku v textu.
 ---------------------------------------------------------------------------}
Procedure TWriter1.SetSpecChars(SpecChars:specstring);
begin
 stSpecChars:=SpecChars;
end;

{---------------------------------------------------------------------------
 Nastavi proporcionalitu textu.
 ---------------------------------------------------------------------------}
Procedure TWriter1.SetProporc(proporc:byte);
begin
 stProporc:=proporc;
end;

{---------------------------------------------------------------------------
 Nasmeruje vystup do zadane bitmapy.
 ---------------------------------------------------------------------------}
Procedure TWriter1.SetBitmap(bitmap:PBitmap);
begin
 otBitmap:=bitmap;
end;


{---------------------------------------------------------------------------
 Nastavi pro vystup zadanou barvu.
 ---------------------------------------------------------------------------}
Procedure TWriter1.SetColor(color:longint);
begin
 otColor:=color;
end;

{---------------------------------------------------------------------------
 Pro pouziti v textmodu pro odliseni fontu, nastavi barvu pozadi.
 ---------------------------------------------------------------------------}
Procedure TWriter1.SetBackgr(backgr:byte);
begin
 otBackColor:=backgr;
end;

{---------------------------------------------------------------------------
 Nastavi pro vystup zadany font, predchozi font uvolni.
 ---------------------------------------------------------------------------}
Function TWriter1.SetFont(name:string):boolean;
begin
 FreeFont;
 if name<>'' then otFont:=cacheGetFont(name);
 if otFont<>nil then begin
   stMaxOver :=MaxI(stMaxOver ,otFont^.sizeOver);
   stMaxUnder:=MaxI(stMaxUnder,otFont^.sizeUnder);
   end
 else
   ReportErr(_(_erBadFont));
 SetFont:=otFont<>nil;
end;

{---------------------------------------------------------------------------
 Uvolni pouzity font.
 ---------------------------------------------------------------------------}
Procedure TWriter1.FreeFont;
begin
 caLeave(otFont);
end;

{---------------------------------------------------------------------------
 Procedura resetne MaxOver, MaxUnder.
 Funkce vraceji sizeOver/sizeUnder nejvetsiho pouziteho fontu od posledniho
 resetu.
 ---------------------------------------------------------------------------}
Procedure TWriter1.MaxReset;
begin
 if otFont=nil
  then begin stMaxOver:=0;stMaxUnder:=0;end
  else begin stMaxOver:=otFont^.sizeOver;stMaxUnder:=otFont^.sizeUnder;end;
end;

Function TWriter1.MaxOver:integer;
begin
 MaxOver:=stMaxOver;
end;

Function TWriter1.MaxUnder:integer;
begin
 MaxUnder:=stMaxUnder;
end;


{---------------------------------------------------------------------------
 Vraci addspace aktualniho fontu.
 ---------------------------------------------------------------------------}
Function TWriter1.GetFontHeight:integer;
begin
 if (otFont=nil) then GetFontHeight:=0
                 else GetFontHeight:=otFont^.sizeOver+otFont^.sizeUnder;
end;

{---------------------------------------------------------------------------
 Vraci addspace aktualniho fontu.
 ---------------------------------------------------------------------------}
Function TWriter1.GetAddSpace:integer;
begin
 if (otFont=nil) or (stProporc>0) then GetAddSpace:=0
                                  else GetAddSpace:=otFont^.addspace;
end;

{---------------------------------------------------------------------------
 Vraci shift (sirku) zadaneho znaku v aktualnim fontu.
 ---------------------------------------------------------------------------}
Function TWriter1.GetCharShift(c:char):integer;
begin
 if otFont=nil then GetCharShift:=0 else
  if stProporc>0 then GetCharShift:=stProporc else
   if not (c in [otFont^.firstchar..otFont^.lastchar]) then GetCharShift:=0 else
    GetCharShift:=otFont^.tablo^[c].shift;
end;

{---------------------------------------------------------------------------
 Vraci sirku textu psaneho aktualnim fontem.
 ---------------------------------------------------------------------------}
Function TWriter1.GetPcLen(pc:pchar):integer;
var len:integer;
begin
 if (pc=nil) or (otFont=nil) or (pc^=#0) then GetPcLen:=0 else
  if stProporc>0 then GetPcLen:=stProporc*StrLen(pc) else begin
    len:=(StrLen(pc)-1)*otFont^.addspace;
    while pc^<>#0 do begin
      if pc^ in [otFont^.firstchar..otFont^.lastchar]
       then inc(len,otFont^.tablo^[pc^].shift);
      inc(pc);
      end;
    GetPcLen:=len;
    end;
end;

{---------------------------------------------------------------------------
 Vraci sirku bitmapy.
 ---------------------------------------------------------------------------}
Function TWriter1.GetMapSir:integer;
begin
 if otBitmap=nil then GetMapSir:=0 else GetMapSir:=otBitmap^.sizeX;
end;

{---------------------------------------------------------------------------
 Vraci otColor.
 ---------------------------------------------------------------------------}
Function TWriter1.GetOtColor:longint;
begin
 GetOtColor:=otColor;
end;
Function TWriter1.GetOtbackColor:byte;
begin
 GetOtBackColor:=otBackColor;
end;


Procedure TWriter1.CheckFont;
begin
 if otFont=nil then erMsg('Pokus o psani prazdnym fontem.');
end;


{---------------------------------------------------------------------------
 Inicializuje skenovani noveho radku.
 (Ulozi si polohu prvniho pismene pro pripad, ze slovo pretece radek a
  bude nutno vratit se zpet. Metoda Scan muze zacit nebo skoncit uprostred
  slova, takze toto nastaveni musi byt provedeno mimo ni v okamziku kdy
  nekdo nahore vi ze jsme _urcite na zacatku slova_.)
 ---------------------------------------------------------------------------}
Procedure TWriter1.ScanInit;
begin
 stPrevSrc    :=PtrRec(stSrc).Ofs;
 stPrevDest   :=stDest;
 stPrevOver   :=stMaxOver;
 stPrevUnder  :=stMaxUnder;
 stFirstword  :=true;
end;

{---------------------------------------------------------------------------
 Prochazi text od pozice stSrc(=zdroj ve znacich), stDest(=cil
 v pixelech) do prvniho specialniho znaku nebo do posledniho slova
 nez stDest pretece slpSir. Pouziva otFont, stProporc.
  stSrc     - posune bud na onen spec.znak nebo na mezeru za poslednim slovem
  stDest    - posune o proskenovany pocet pixelu
  stSirmez  - sirka pridana k mezeram = co pri preteceni zbylo na konci radku
 a zvysi
  stMezer   - celkem mezer

 Radek konci pretecenim (hi=$4000) nebo nekterym ze seznamu
 specialnich znaku (hi=0). V dolnim wordu vysledku je vzdy
 pocet proskenovanych pismen (je to integer, protoze muze byt zaporny).

 Pozor: stDest muze po skonceni ukazovat za slpSir, kdyz mez pretece
        pri pricitani addspace pred spec.znakem, ktery neni uveden v seznamu
        stDeladds.
 Pozor: kdyz se prvni slovo na radku nevejde, slovo rozdeli. ok.
        kdyz se nevejde jine slovo, vrati se pred nej. attention:
         zacinal-li uprostred slova, vrati se az na jeho zacatek!
 ---------------------------------------------------------------------------}
Function TWriter1.Scan:longint;assembler;
 var   pretek          :word;
       local_addspace  :word;
       PrevDest        :word;{pozice za predchozim znakem (bez addspace)}
 asm
     {trvale zustava ES:DI=SELF}
     les di,self

     {defaultni vysledek je false - nepretek}
     xor ax,ax
     mov pretek,ax

     {otFont=nil -> quit}
     db 66h;cmp word ptr [es:di+otFont],0;jz @done

     {
     FS:SI - stSrc
     GS:BX - FontTable
     ES:DI - SELF, SpecChars
     DL    - nejnizsi znak obsazeny ve fontu
     DH    - nejvyssi znak obsazeny ve fontu
     CX    - stDest, pozice na vystupu v pixelech
     }

     {init}
     mov [es:di+stSirmez],ax{stSirmez:=0}
     mov cx,[es:di+stDest]{cx=pozice na radce (0..slpSir)}
     seges;db 0fh,0b4h,0b5h;dw stSrc{LFS SI,[ES:DI+stSrc]}
     seges;db 0fh,0b5h,9dh;dw otFont{LGS BX,[ES:DI+otFont]}


     {nacte do promennych udaje o aktualnim fontu}
     db 65h{gs:};mov dl,[bx+TFont.firstchar]
     db 65h{gs:};mov dh,[bx+TFont.lastchar]

     {proporcionalni >then> nacte l_addspace >else> l_addspace=0}
     mov ah,[es:di+stProporc]
     or ah,ah
     jz @real2
      xor ax,ax
      jmp @real2done
     @real2:
      db 65h{gs:};mov al,[bx+TFont.addspace]
      cbw
     @real2done:
     mov local_addspace,ax

     db 65h{gs:};db 0fh,0b5h,9fh;dw TFont.tablo{LGS BX,[bx+PackedFont.tablo]}
     add bx,TCharInfo.shift{GS:BX=@OT_Font^.tablo[#0].shift}

     {ulozi si vychozi pozici a preskoci pridavani addspace}
     mov PrevDest,cx
     jmp @firstchar

    @nextchar:
     {ulozi si pozici tesne za predchozim znakem (jeste pred addspacem)}
     {na 100% vim ze je <= slpSir (pokud byl vstup <= slpSir)}
     mov PrevDest,cx
     {addspace prida PRED znak}
     {pri tom uz muze pretect}
     add cx,local_addspace

    @firstchar:
     {nacte jedno pismeno}
     db 64h{fs:};lodsb

     {je to mezera?}
     cmp al,' ';jz @mezera

     {je to specialni znak?}
     push cx
     mov cl,byte ptr [es:di+stSpecChars]
     mov ch,0
     push di
      lea di,[di+stSpecChars+1]
      repne scasb
     pop di
     pop cx
     jz @special

     {je to normalni znak}
     call near ptr @addShiftofALtoCX

     {uz jsem na konci radku?}
     @testpreteceni:
      cmp cx,[es:di+slpSir]
      jna @nextchar

     {jsem na konci radku}
     @preteceni:
      mov pretek,4000h
      cmp [es:di+stFirstword],0;jnz @longword
      {vrati se o mezeru zpatky}
      dec [es:di+stMezer]
      mov cx,[es:di+slpSir];sub cx,[es:di+stPrevdest];mov [es:di+stSirmez],cx
      {restorne souradnice z posledni mezery}
      mov si,[es:di+stPrevOver ];mov [es:di+stMaxOver ],si
      mov si,[es:di+stPrevUnder];mov [es:di+stMaxUnder],si
      mov si,[es:di+stPrevSrc]
      mov cx,[es:di+stPrevDest]
      jmp @end

     {subrutina: pricte k CX shift pismene AL}
     {pri stProporc>0 je sirka konstantni stProporc}
     @addShiftofALtoCX:
      mov ah,[es:di+stProporc]
      or ah,ah
      jz @real1
       add cl,ah
       adc ch,0
       retn
      @real1:
       {je obsazen ve fontu?}
       cmp al,dl;jb @neni
       cmp al,dh;ja @neni
      @je:
       mov ah,type TCharInfo
       mul ah
       add bx,ax
       db 65h{gs:};add cl,[bx]{pricte shift pismene}
       adc ch,0
       sub bx,ax
      @neni:
       retn

     {mezera}
     @mezera:
      inc [es:di+stMezer]
      call near ptr @addShiftofALtoCX
      mov ax,[es:di+stMaxOver ];mov [es:di+stPrevOver ],ax
      mov ax,[es:di+stMaxUnder];mov [es:di+stPrevUnder],ax
      mov ax,PrevDest
      mov [es:di+stPrevdest],ax
      mov [es:di+stPrevsrc],si
      mov [es:di+stFirstword],0
      jmp @testpreteceni

     {cely radek je jedno prilis dlouhe slovo}
     @longword:
      mov cx,PrevDest{killne posledni addspace}
       mov ax,[es:di+slpSir]
       sub ax,cx
       mov [es:di+stSirmez],ax{nepovinne predani udaje kolik pixelu zbylo naocet}
      jmp @end

     {konec, jeden z techto pripadu:
      - narazil na specialni znak (posledni addspace zapocitan)
     }
     @special:
      mov cx,PrevDest{vyrusi addspace}


     {konec, jeden z techto pripadu:
      - preteceni prev.addspacem nebo ted.pismenem, nastaveno na posledni mezeru (posledni addspace nezapocitan)
      - preteceni prev.addspacem nebo ted.mezerou, nastaveno na tuto mezeru (posledni addspace nezapocitan)
      - preteceni prev.addspacem nebo ted.longwordem, nastaveno na toto pismeno (zarovnano na max)
     }
     @end:
      dec si
      mov ax,si;sub ax,word ptr [es:di+stSrc]{ax=kolik pismen proskenoval}
      mov word ptr [es:di+stSrc],si{zvysi stSrc}
      mov [es:di+stDest],cx{zvysi stDest}

     @done:
      {vraci ax=kolik pismen proskenoval, dx=pretek}
      mov dx,pretek

 {poznamecka: se v tom uz nevyznam, ale skoro bych rek, ze to funguje!}
 {poznamecka2: poznamecka byla prehnane optimisticka}

 {mozne konce
   proskenoval +neco: vraci hodnoty ziskane pricitanim, inc(stDest,tempAdd) ze ScanShort je zapracovan a straven
   proskenoval -neco: vraci stare absolutni hodnoty z stPrevXxxx, inc(stDest,tempAdd) ze ScanShort je prebit a odstaven
   proskenoval 0: vraci to s cim zacal, inc(stDest,tempAdd) ze ScanShort se tam zas musi rucne vyeliminovat
 }
 end;


{---------------------------------------------------------------------------
 Pise zadany pocet pismen ze zadane pozice na vstupu do zadane pozice
 na vystupu.
  Pismen - pocet pismen k vytisteni
  Src    - ukazatel na prvni pismeno
  Mezer  - pocet mezer, po kazde mezere ho snizi (neni-li uz nula)
  Sirmez - pocet pixelu, ktere je nutno plynule rozlozit do Mezer,
           do kazde mezery kousek strci a Sirmez snizi
  otX    - Xova poloha vystupu, posune ji
  otY    - Yova poloha vystupu
 Zvyrazni blok na offsetech od blkStart do blkEnd.
 ---------------------------------------------------------------------------}
Procedure TWriter1.Print(pismen:word;src:Pchar;var mezer,sirmez,otX:word;otY:word);
const blkBackColor=4;
begin
 {xxxxx}
 if not blkOn or (pismen=0) or (blkStart>=blkEnd) or (blkStart>=word(src)+pismen) or (blkEnd<=word(src)) then
   otX:=OutText(pismen,Src,Mezer,Sirmez,otBitmap,otX,otY+globshiftY,otFont,stProporc,otColor+otBackColor shl 4) else
 {XXXXX}
 if (blkStart<=word(src)) and (blkEnd>=word(src)+pismen) then
   otX:=OutText(pismen,Src,Mezer,Sirmez,otBitmap,otX,otY+globshiftY,otFont,stProporc,otColor+blkBackColor shl 4) else
 {XXXxx}
 if (blkStart<=word(src)) then begin
   otX:=OutText(blkEnd-word(src),Src,Mezer,Sirmez,otBitmap,otX,otY+globshiftY,otFont,stProporc,otColor+blkBackColor shl 4);
   otX:=OutText(pismen+word(src)-blkEnd,Src+blkEnd-word(src),Mezer,Sirmez,otBitmap,otX,otY+globshiftY,otFont,stProporc,
        otColor+otBackColor shl 4);
   end else
 {xxXXX}
 if (blkEnd>=word(src)+pismen) then begin
   otX:=OutText(blkStart-word(src),Src,Mezer,Sirmez,otBitmap,otX,otY+globshiftY,otFont,stProporc,otColor+otBackColor shl 4);
   otX:=OutText(pismen+word(src)-blkStart,Src+blkStart-word(src),Mezer,Sirmez,otBitmap,otX,otY+globshiftY,otFont,stProporc,
        otColor+blkBackColor shl 4);
   end else
 {xxXxx}
 begin
   otX:=OutText(blkStart-word(src),Src,Mezer,Sirmez,otBitmap,otX,otY+globshiftY,otFont,stProporc,otColor+otBackColor shl 4);
   otX:=OutText(blkEnd-blkStart,Src+blkStart-word(src),Mezer,Sirmez,otBitmap,otX,otY+globshiftY,otFont,stProporc,
        otColor+blkBackColor shl 4);
   otX:=OutText(pismen+word(src)-blkEnd,Src+blkEnd-word(src),Mezer,Sirmez,otBitmap,otX,otY+globshiftY,otFont,stProporc,
        otColor+otBackColor shl 4);
   end;
end;

{---------------------------------------------------------------------------
 Pise zadany string do zadane pozice na vystupu.
 Posouva otX.
 ---------------------------------------------------------------------------}
Procedure TWriter1.PrintStr(st:string;var otX:word;otY:word);
var   Mezer,Sirmez:word;
begin
 if otY+otFont^.maxPod>otBitmap^.sizeY then exit;
 {pokus..ale zda se ze prispiva stabilite a vyplati se to tu nechat}

 Mezer:=0;
 Sirmez:=0;
 otX:=OutText(length(st),@st[1],Mezer,Sirmez,otBitmap,otX,otY+globshiftY,otFont,stProporc,otColor+otBackColor shl 4);
end;

{---------------------------------------------------------------------------
 Uvolni font.
 ---------------------------------------------------------------------------}
Destructor TWriter1.Done;
begin
 FreeFont;
 inherited Done;
end;


{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ CACHE NA THUMBY ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}

{thumb hleda v mnoha adresarich, kdyz uz ho najde+nahraje a ulozi v cache,
 nemusi priste zas prolezat adresare a nahravat ho}

Type
 PThumbId = ^TThumbId;
 TThumbId = object(TCacheId)
   thumbname:NameStr;
   constructor Init(pc:pchar);
   function Load:PObject;virtual;
   destructor Done;virtual;
 end;

Constructor TThumbId.Init(pc:pchar);
begin
 {bioswrite('init('+name+')');}
 inherited Init;
 thumbname:=Pc2Str(pc);
end;

Destructor TThumbId.Done;
begin
 {bioswrite('done('+filename+')');}
 inherited Done;
end;

Function TThumbId.Load:PObject;
var st:PathStr;
 function ContainsThumb(dir:pstring):boolean;far;
 begin
  st:=fileFind(dir^+'thumbs\'+thumbname,isLoadable+isGraphics);
  ContainsThumb:=st<>'';
 end;
begin
 {nejdriv ho hleda s ! v DM}
 st:=fileFind('!'+thumbname,isLoadable+isGraphics);
 {pak ho hleda na disku tam kam se thumby instaluji a kde se vytvareji
 if st='' then st:=fileFind(dirIns+'thumbs\'+thumbname,isLoadable+isGraphics);
 {kdyz neuspeje, zkusi jeste pobliz exace (=spusteni z cd bez instalace)
 if st='' then st:=fileFind(dirExe+'thumbs\'+thumbname,isLoadable+isGraphics);}
 {pak ho hleda ve vsech adresarich dirlistu}
 if st='' then Dirs.FirstThat(@ContainsThumb);
 if st='' then Load:=nil else Load:=picLoad(st);
end;

{---------------------------------------------------------------------------
 Zadany obrazek nahraje a vrati na nej pointer.
 Pozor: Ziskany obrazek nemen a neuvolnuj pres TBitmap.Free, ale pres caLeave.
 ---------------------------------------------------------------------------}
const cachePriorThumb=cachePriorPic;{priorita jakou dostanou thumby v cache}

Function cacheGetThumb(pc:pchar):PBitmap;
begin
 cacheGetThumb:=PBitmap(caGet(New(PThumbId,Init(pc)),cachePriorThumb));
end;


{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ BOXY S NAPISEM / OBRAZKEM ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}

{---------------------------------------------------------------------------
 Vytvori spravne velky box a nacpe do nej string.
 ---------------------------------------------------------------------------}
Function StrBox(model:byte;w:PWriter1;pc:pchar;rezerva:word;backcol:longint):PBitmap;
var   big            :PBitmap;
      x,y            :word;
      sirka,vyska    :integer;
      pismen         :word;
      nula           :word;
begin
 StrBox:=nil;
 with w^ do begin
  MaxReset;
  stSrc:=pc;
  stDest:=0;
  slpSir:=15000;
  ScanInit;
  pismen:=Scan;
  sirka:=stDest;
  vyska:=maxOver+maxUnder;
  new(big,Init(model,sirka+2*rezerva,vyska+2*rezerva));
  if big=nil then exit;
  big^.Col2Ful(backcol);
  SetBitmap(big);
  x:=rezerva;
  y:=maxOver+rezerva;
  nula:=0;
  Print(pismen,pc,nula,nula,x,y);
  StrBox:=big;
  end;
end;

{---------------------------------------------------------------------------
 Do boxu libovolne velikosti nacpe obrazek nebo vypise jmeno pokud neexistuje.
 Pouzije dodany Writer.
 side=-2 centrovat. kdyz se nevejde, zobrazit levy kraj
 side=-1 zarovnat doleva at uz se vejde nebo ne
 side= 0 centrovat
 side= 1 zarovnat doprava at uz se vejde nebo ne
 side= 2 centrovat. kdyz se nevejde, zobrazit pravy kraj
 ---------------------------------------------------------------------------}
Function Str2BoxW(b:PBitmap;winx1,winy1,winsir,winvys:word;
                  w:PWriter1;pic:boolean;pc:pchar;side:shortint;backcol:longint):boolean;
const rezerva        =10;
var   cach,img       :PBitmap;
      putsir,putvys  :integer;
      srcx,srcy      :integer;
      destx,desty    :integer;
      st             :PathStr;
begin
 Str2BoxW:=false;
 if (winsir<=0) or (winvys<=0) or (winx1<0) or (winy1<0) then exit;
 {zkusi nahrat obrazek}
 if pic then begin
   cach:=cacheGetThumb(pc);
   if cach<>nil then begin
     {verze 1:pomaly resize
     b^.ResizeBtF2Box(1,cach, winx1,winy1, winsir,winvys);
     caLeave(cach);
     Str2BoxW:=true;
     exit;
     {verze 2:prevod na spravny model+rychly resize}
     img:=cach^.FulCopy;
     caLeave(cach);
     JoinMapTo(img,b,false{praxe ukazuje dobre vysledky i bez kvantizace});
     if img<>nil then begin
       b^.ResizeBtF2Box(0,img, winx1,winy1, winsir,winvys);
       img^.Free;
       Str2BoxW:=true;
       exit;
       end;
     end;
   end;
 {misto obrazku vygeneruje napis}
 img:=StrBox(b^.MapModel,w,pc,rezerva,backcol);
 if img=nil then exit;
 putsir:=minI(img^.sizeX,winsir);
 putvys:=minI(img^.sizeY,winvys);
 case side of -2:if img^.sizeX-2*rezerva<winsir then side:=0 else side:=-1;
               2:if img^.sizeX-2*rezerva<winsir then side:=0 else side:=+1;
               end;
 case side of -1:srcx:=rezerva;
               0:srcx:=maxI(0,(img^.sizeX-winsir) div 2);
               1:srcx:=img^.sizeX-putsir-rezerva;
               end;
 srcy:=maxI(0,(img^.sizeY-winvys) div 2);
 case side of -1:destx:=winx1;
               0:destx:=winx1+(winsir-putsir) div 2;
               1:destx:=winx1+winsir-putsir;
               end;
 desty:=winy1+(winvys-putvys) div 2;
 b^.Col2Box(winx1,winy1,winsir,winvys,backcol);
 b^.BtB2Box(img,srcx,srcy, putsir,putvys, destx,desty);
 img^.Free;
 Str2BoxW:=true;
end;

{---------------------------------------------------------------------------
 Do boxu libovolne velikosti nacpe string.
 Writer si sam vytvori a zrusi.
 ---------------------------------------------------------------------------}
Function Str2Box(b:PBitmap;winx1,winy1,winsir,winvys:word;
                 pc:pchar;side:shortint;fnt:PathStr;forecol,backcol:longint):boolean;
var   w              :PWriter1;
label bad;
begin
 Str2Box:=false;
 new(w,Init);
 if w=nil then goto bad;
 w^.SetColor(forecol);
 if not w^.SetFont(fnt) then goto bad;
 if not Str2BoxW(b,winx1,winy1,winsir,winvys,w,false,pc,side,backcol) then goto bad;
 Str2Box:=true;
 exit;
bad:
 KillObj(w);
end;
           (*
{---------------------------------------------------------------------------
 Vytvori box zadaneho modelu a sirky.
 Vysku zdetekuje.
 Napise do nej text.
 ---------------------------------------------------------------------------}
Function Pc2BoxW(model:word;w:word;
                  pc:pchar;backcol:longint):boolean;
var   big            :PBitmap;
      putsir,putvys  :integer;
      srcx,srcy      :integer;
      destx,desty    :integer;
begin
 Str2BoxW:=false;
 if (winsir<=0) or (winvys<=0) or (winx1<0) or (winy1<0) then exit;
 big:=StrBox(b^.MapModel,w,pc,rezerva,backcol);
 if big=nil then exit;
 putsir:=minI(big^.sizeX,winsir);
 putvys:=minI(big^.sizeY,winvys);
 case side of -1:srcx:=0;
               0:srcx:=maxI(0,(big^.sizeX-winsir) div 2);
               1:srcx:=big^.sizeX-putsir;
               end;
 srcy:=maxI(0,(big^.sizeY-winvys) div 2);
 case side of -1:destx:=0;
               0:destx:=winx1+(winsir-putsir) div 2;
               1:destx:=winx1+winsir-putsir;
               end;
 desty:=winy1+(winvys-putvys) div 2;
 b^.Col2Box(winx1,winy1,winsir,winvys,backcol);
 b^.BtB2Box(big,srcx,srcy, putsir,putvys, destx,desty);
 big^.Free;
 Str2BoxW:=true;
end;     *)

END.