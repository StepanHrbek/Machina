Unit      DMWriter; {$i define.inc}

{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}
                             INTERFACE
{‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹}

Uses      Chyby,Memo,
          Objects,Dos,Strings,
          Stringy,Vga,Fonty,Texty,Sys,Fajly,
          Atoms,DMAtoms,
          DMText,Writer2,Textury,DMFile,Loadery;

Function  Init:TError;
Procedure Done;


type  PDMWriter = ^TDMWriter;
      TDMWriter =  object(TDMText)
                     Xzoom,Yzoom    :real;

                     constructor    Init(txSize:longint;txStart:Pchar;name:string;
                                         flags:word;var result:TError);
                     procedure      SetupSimple(destMap:PBitmap;
                                         Fnts,Colors:string;tabmode:byte);
                     procedure      SetupAdvanced(advanced,editmod:boolean;destMap:PBitmap;
                                         OrigFnts,NewFnts,Colors:string;tabmode:byte);
                     function       DetectXzoom:real;
                     function       DetectYzoom:real;
                     procedure      SetupMore(format,zarovnavat,OrigProporc,NewProporc:byte);
                     procedure      SetThree(st:string);
                     function       wrOutput:PWriter2;
                     procedure      Pos2Wr;
                     procedure      Wr2Pos;
                     procedure      WriteInit;
                     function       Write:word;
                     procedure      WriteDone;

                     {$ifdef edit}
                     procedure      GotoCoords(myX,myLine:integer);
                     procedure      SearchCoordsIn(slp:integer;var myX,myY,myLine:integer);
                     procedure      VeryStartLine(myLine:integer);
                     {$endif}

                     destructor     Done;virtual;
                   private
      {$ifdef edit}  edit           :boolean;{ma newwriter pouzit editacni layout?}
      {$endif}
                     writeMaxY      :word;{nejvyssi Y do ktereho bylo psano origWriterem}
                     wrOrig         :PWriter2;
                     wrNew          :PWriter2;

                     bokystart      :integer;
                     bokyramecku    :boolean;
                     ramecekcolor   :longint;

                     oldpos         :pchar;
                   end;



{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}
                          IMPLEMENTATION
{‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹}

Uses  DMBitmap;


{---------------------------------------------------------------------------
 Inicializuje writer.
 txStart ukazuje kde bude zacinat text (jeste tam nemusi byt).
 Po inicializaci, v okamziku kdy je text na svem miste, lze pouzivat
 vsechny metody krome WriteXXXX. S pomoci GetHeader a spol lze
 analyzovat text a zjistit parametry pro setup.
 Obdobne jako u inherited init - kdyz je txStart nil a name<>'',
 nahraje text ze souboru, vystup chyba nebo text ery 3.
 ---------------------------------------------------------------------------}
Constructor TDMWriter.Init(txSize:longint;txStart:Pchar;name:string;
                           flags:word;var result:TError);
begin
 if not inherited Init(txSize,txStart,name,flags,result) then Fail;
 {alokuje provizorni origwriter s nahodnymi parametry kvuli Get/SetHeader}
 New(wrOrig,Init(false,5));
 if wrOrig=nil then Fail;
 {resetne zoom}
 Xzoom:=1;
 Yzoom:=1;
end;

{---------------------------------------------------------------------------
 Nastavi parametry jednoducheho writeru.
 Az po setupu lze pouzivat metody WriteXXXX.

 destMap        - cilova bitmapa
 Fnts           - fonty kterymi je psan puvodni text
 Colors         - sada barev fontu

 Z headeru nacte seznam lokalnich fontu.
 ---------------------------------------------------------------------------}
Procedure TDMWriter.SetupSimple(destMap:PBitmap;Fnts,Colors:string;tabmode:byte);
begin
 SetupAdvanced(false{simple},false{not edit},destMap,Fnts,'',Colors,tabmode);
end;

{---------------------------------------------------------------------------
 Nastavi parametry pokrocileho writeru (umi psat text jinym fontem
 a v jine velikosti bez naruseni puvodniho zarovnavani).
 Az po setupu lze pouzivat metody WriteXXXX.

 advanced       - true
 destMap        - cilova bitmapa
 OrigFnts       - fonty kterymi je psan puvodni text
 NewFnts        - fonty kterymi ma byt text zobrazen
 Colors         - sada barev fontu
 ---------------------------------------------------------------------------}
Procedure TDMWriter.SetupAdvanced(advanced,editmod:boolean;destMap:PBitmap;
                                OrigFnts,NewFnts,Colors:string;tabmode:byte);
begin
 {pro pripad ze volas Setup opakovane zrusi writery, ale}
 if wrNew<>nil then wrNew^.Done;
 if wrOrig<>nil then wrOrig^.Done;
 {kdyz nejde o volani z SetupSimple, alokuje newwriter}
 if advanced then begin
   if wrNew=nil then New(wrNew);
   if wrNew=nil then Halt(erLowMem);
   wrNew^.Init(editmod,tabmode);
   wrNew^.SetBitmap(destMap);
   if not wrNew^.lfInit(NewFnts,Colors) then Halt(_erBadFont);
   end;
 {reinicializuje origwriter}
 wrOrig^.Init(false{not edit},tabmode);
 wrOrig^.SetBitmap(destMap);
 if not wrOrig^.lfInit(OrigFnts,Colors) then Halt(_erBadFont);
 {zapamatuje si editmod}
 {$ifdef edit}
 edit:=editmod;
 {ma nastavovat txa:?}
 wrOrig^.under:=0;
 if edit and (OutputKind(0) in [okDirect,ok256]) then begin
   wrOrig^.under:=GetFlag(flagTxa);
   if wrOrig^.under=0 then wrOrig^.under:=20;
   end;
 {$endif}
 (*
 was here but now is moved to consructor:
 {resetne zoom}
 Xzoom:=1;
 Yzoom:=1;
 *)
end;

{---------------------------------------------------------------------------
 Odhadne Xzoom pro editor.
 Ten uz si ho dale serizuje sam, jde jen o pocatecni hodnotu.
 ---------------------------------------------------------------------------}
Function TDMWriter.DetectXzoom:real;
begin
 DetectXzoom:=wrOrig^.lfDetectXzoom(GetHeader('fnt:'));
end;

{---------------------------------------------------------------------------
 Odhadne Yzoom pro editor.
 Ten uz ho nemeni.
 ---------------------------------------------------------------------------}
Function TDMWriter.DetectYzoom:real;
begin
 DetectYzoom:=wrOrig^.lfDetectYzoom(GetHeader('fnt:'));
end;

{---------------------------------------------------------------------------
 zarovnavat     - ke krajum
 OrigProporc    - proporcionalita originalu  \  =0...proporcionalni
 NewProporc     - proporcionalita vystupu    /  >0...konst.sirka tato
 ---------------------------------------------------------------------------}
Procedure TDMWriter.SetupMore(format,zarovnavat,OrigProporc,NewProporc:byte);
begin
 if wrNew<>nil then begin
   wrNew^.SetFormat(format);
   wrNew^.SetProporc(NewProporc);
   wrNew^.SetZarovnavat(zarovnavat);
   end;
 wrOrig^.SetFormat(format);
 wrOrig^.SetProporc(OrigProporc);
 wrOrig^.SetZarovnavat(zarovnavat);
end;

{---------------------------------------------------------------------------
 Jako SetupMore, ale parametry bere ze stringu.
 ---------------------------------------------------------------------------}
Procedure TDMWriter.SetThree(st:string);
var cut:string[20];
    i:longint;
begin
 {prvni parametr - format 0/1}
 cut:=CutString(st,',');
 if cut<>'' then begin
   i:=Valu(cut);
   wrOrig^.SetFormat(i);
   if wrNew<>nil then wrNew^.SetFormat(i);
   end;
 {druhy parametr - proporcionalita 0/1/2/3/4/5/6/7/8..}
 cut:=CutString(st,',');
 if cut<>'' then begin
   i:=Valu(cut);
   wrOrig^.SetProporc(i);
   {aby v edu nepsal proporcionalne-if wrNew<>nil then wrNew^.SetProporc(i);}
   end;
 {treti parametr - zarovnavani 0=vlevo/1=roztah/2=centr/3=vpravo}
 cut:=CutString(st,',');
 if cut<>'' then begin
   i:=Valu(cut);
   wrOrig^.SetZarovnavat(i);
   if edit and (i=1{roztah}) then i:=0;{v edu neroztahuje}
   if wrNew<>nil then wrNew^.SetZarovnavat(i);
   end;
end;


{ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ MAIN ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}

{---------------------------------------------------------------------------
 Srovna redundantni informaci v Pos a wrOrig^.stSrc.
 ---------------------------------------------------------------------------}
Procedure TDMWriter.Pos2Wr;
begin
 wrOrig^.stSrc:=pos;
end;

Procedure TDMWriter.Wr2Pos;
begin
 pos:=wrOrig^.stSrc;
end;

{---------------------------------------------------------------------------
 Vraci ten writer, ktery dela vystupy.
 ---------------------------------------------------------------------------}
Function TDMWriter.wrOutput:PWriter2;
begin
 if wrNew<>nil then wrOutput:=wrNew else wrOutput:=wrOrig;
end;

{---------------------------------------------------------------------------
 Resetne promenne pred psanim cele stranky.
 ---------------------------------------------------------------------------}
Procedure TDMWriter.WriteInit;
var stx,sty:string[10];
begin
 {zazalohuje pos}
 oldpos:=pos;
 {$ifdef edit}
 if edit then begin
   {init lines-array.}
   linetotal :=0;
   {resetne solidni bloky textu}
   wrOrig^.undery1:=-1;
   wrOrig^.underrects:='';
   end;
 {$endif}
 wrOrig^.slpMid      :=0;
 wrOrig^.slpSir      :=0;
 {nacte odsazy}
 wrOrig^.slpOdsazX   :=24;
 wrOrig^.slpOdsazY   :=0;
 sty:=GetHeader('par:');
 stx:=CutString(sty,',');
 sty:=CutString(sty,',');
 if stx<>'' then wrOrig^.slpOdsazX:=valu(stx);
 if sty<>'' then wrOrig^.slpOdsazY:=valu(sty);
 {resetne font}
 wrOrig^.lfReset;
 if wrNew<>nil then wrNew^.lfReset;
 {kurzor na start}
 GoZaheader3;
 {resetne sloupce}
 SlpReset;
 {resetne maxY}
 writeMaxY:=0;
 {resetne ramecky}
 bokystart:=0;
 bokyramecku:=false;
 {zmeni format je-li treba. inicializovan byl v setupmore.}
 SetThree(GetHeader('fmt:'));
end;


{---------------------------------------------------------------------------
 Pise kus textu, i pres vice sloupcu.
 Ramecky v editmodu tvrde praska do freesegu.
 ---------------------------------------------------------------------------}
Function TDMWriter.Write:word;

  procedure PrintMinus(k:word;var i,j:word);
  begin
   while k>0 do begin
     wrOutput^.PrintStr(rep('ƒ',MinW(k,255)),i,j);
     dec(k,MinW(k,255));
     end;
  end;

  procedure Blah1(var i,j,k:word);
  begin
   i:=round(wrOrig^.slpMid*Xzoom)
     -round(wrOrig^.slpSir*Xzoom) div 2;
   j:=round(wrOrig^.otY*Yzoom);
   k:=round(wrOrig^.slpSir*Xzoom);
  end;

  const znak:array[0..3] of char=('⁄','ø','¿','Ÿ');
        c0=8;{background}
        c1=0;{cary}
        c2=7;{cislo sloupce}{2,6,3 snesitelny, 5,4,1,9,10 ne}
        c3=7;{otec sloupce}
  var   oldcol:longint;
        oldback:byte;

  function Hlavicka(otecSloupce:byte):boolean;{kresli hlavicku sloupce}
  var i,j,k:word;
      sloupcu:shortint;
  begin
   hlavicka:=false;
   if SlpAddHalf(wrOrig^.slpMid,wrOrig^.otY{$ifdef edit},linetotal+1{$endif}) then begin
     {$ifdef edit}
     if edit then begin
       sloupcu:=SlpMax;
       Blah1(i,j,k);
       if k>8 then
        with wrOutput^ do begin
         oldcol:=GetOtColor;
         oldback:=GetOtBackColor;
         SetBackgr(c0);
         SetColor(c1);PrintStr('⁄ƒ',i,j);
         SetColor(c2);PrintStr(chr(48+sloupcu),i,j);
         SetColor(c1);PrintMinus(k-8,i,j);
         inc(otecSloupce);
         if otecSloupce=1 then
           PrintStr(rep('ƒ',3),i,j)
         else begin
           SetColor(c3);
           PrintStr(znak[2*(otecSloupce and 1)],i,j);
           PrintStr(chr(48+otecSloupce div 2),i,j);
           PrintStr(znak[2*(otecSloupce and 1)+1],i,j);
           SetColor(c1);
           end;
         PrintStr('ƒø',i,j);
         SetColor(oldcol);
         SetBackgr(oldback);
         end;
       end;
     {$endif}
     hlavicka:=true;
     end;
  end;

  procedure Patka;{kresli patku odstavce}
  var i,j,k:word;
      sloupcu:shortint;
  begin
   writeMaxY:=maxI(writeMaxY,wrOrig^.otY);
   {$ifdef edit}
   if edit then begin
     sloupcu:=SlpMax;
     Blah1(i,j,k);
     inc(j);
     if k>4 then
      with wrOutput^ do begin
       oldcol:=GetOtColor;
       oldback:=GetOtBackColor;
       SetBackgr(c0);
       SetColor(c1);PrintStr('¿ƒ',i,j);
       SetColor(c2);PrintStr(chr(48+sloupcu),i,j);
       SetColor(c1);PrintMinus(k-4,i,j);
                    PrintStr('Ÿ',i,j);
       SetColor(oldcol);
       SetBackgr(oldback);
       end;
     end;
   {$endif}
   SlpAddHalf(wrOrig^.slpMid,wrOrig^.otY{$ifdef edit},linetotal{$endif});
  end;

var   st:string;
      otecSloupce:byte;
      name:PathStr;
      link:string;
      usex,usey{,dx,dy}:integer;
      ratiox,ratioy:real;
      castshad,shadebor,whitebor:integer;

  procedure ParsePic(st:string);
  begin
   name:=DecodeInspic(copy(CutString(st,','),2,255));
   usex:=CutNum(st);{newsize}
   usey:=CutNum(st);
   delete(st,1,1);{,}
   link:=paramGet(st,'href');
   shadebor:=byte(paramGet(st,'shadeborder')='on');
   whitebor:=byte(paramGet(st,'whiteborder')='on');
   castshad:=byte(paramGet(st,'castshadow')='on');
  end;

  procedure Resize(left,right:integer);
  begin
   with wrOrig^ do begin
     {dx:=slpMid-slpSir div 2+left;
     dy:=slpMid+slpSir div 2+right;}
     inc(slpMid,(right+left) div 2);
     inc(slpSir,right-left);
     end;
  end;

var   line_sir,
      line_vys   :byte;
      line_txtmod:boolean;
      boxRect    :TRect;
      script_pc  :pchar;

  function line_color(svis:boolean):longint;
  begin
   if not line_txtmod then line_color:=ramecekColor else
    if svis
     then line_color:=MakeWord($80+ramecekColor,ord('≥'))
     else line_color:=MakeWord($80+ramecekColor,ord('ƒ'));
  end;

begin
 {$ifdef beta}
 if mem[PtrRec(pos).Seg:konec]<>ord(EOP) then erBetaMsg('dmwriter.text.lastchar<>0.');
 {$endif}
 wrOutput^.overflows:=0;
 wrOutput^.blkOn:=edit;
 wrOutput^.blkStart:=blkStart;
 wrOutput^.blkEnd:=blkEnd;
 {podle otbitmap spocita tloustky car}
 with wrOutput^ do begin
   line_txtmod:=otBitmap^.MapModel=model_text;
   line_sir:=1;
   line_vys:=1;
   if (not line_txtmod) and (TypeOf(TDMBitmap)=TypeOf(otBitmap^)) then
    with PDMBitmap(otBitmap)^ do begin
      line_sir:=1+doporucXres div 512;
      line_vys:=1+doporucYres div 384;
      end;
   end;
 {main loop}
 repeat
  case GetChar of
   cmdINIT:
        begin
         inc(pos);
         script_pc:=pos;
         st:=chRead(cmdDONE);
         Case st[1] of
           cmdNEWSLP:
             begin
              if SlpMax>0 then Patka;
              {spocita souradnice novyho odstavce relativne podle otcovskeho odstavce}
              otecSloupce      :=CutNum(st);
              wrOrig^.slpMid   :=SlpX(otecSloupce)+CutNum(st);
              wrOrig^.otY      :=SlpY(otecSloupce)+CutNum(st);{zde je v par5/title aritm.preteceni,bugfixed by par05fix.dm}
              wrOrig^.slpSir   :=CutNum(st);
              {vrati pos na zacatek headeru aby SlpAddHalf ulozil spravny pos}
              nlGoto(0);
              if Hlavicka(otecSloupce)
               then begin
                    nlGoto(+1);
                    if word(pos)>konec then word(pos):=konec;{aby prezil konec souboru hned na radce s newslpem}
                    end
               else ReportErr(_(_erMocSloupcu));
             end;
           cmdINSPIC:
             begin
             if debugW then BiosWriteln('Writer ParsePic...');
             ParsePic(st);
             {volitelne: if link='' then link:=name;}
             if debugW then BiosWriteln('Writer PrintPic...');
             wrOutput^.PrintPic(name,
                maxI((360-512) div 2,round(Xzoom*(wrOrig^.slpMid{+dx}-usex div 2))),
                maxI(0,round(Yzoom*(wrOrig^.otY{+dy}))),
                either((round(Xzoom*usex)=0) and (usex>0),1,round(Xzoom*usex)),
                either((round(Yzoom*usey)=0) and (usey>0),1,round(Yzoom*usey)),
                Str2Pc(link),castshad,shadebor,whitebor);
             if debugW then BiosWriteln('Writer PrintPic OK');
             inc(wrOrig^.otY,usey);
             nlGoto(+1);
             if word(pos)>konec then word(pos):=konec;{aby prezil konec souboru hned na radce s pikcrem}
             end;
           cmdRESIZE:
             Resize(CutNum(st),CutNum(st));
           cmdROVNALINE:
             with wrOutput^ do begin
              if GetFlag(flagColorRam)<>0
               then ramecekColor:=GetOtColor
               else if line_txtmod then ramecekcolor:=11 else ramecekcolor:=wrOutput^.otBitmap^.Color(0,215,215,255);
              PrintBox(slpMid-slpSir div 2,otY,slpSir,line_vys,line_color(false));
             end;
           cmdSVISLALINE:
             with wrOutput^ do begin
              if GetFlag(flagColorRam)<>0
               then ramecekColor:=GetOtColor
               else if line_txtmod then ramecekcolor:=11 else ramecekcolor:=wrOutput^.otBitmap^.Color(0,215,215,255);
              if bokyramecku then begin
                PrintBox(slpMid-slpSir div 2,bokyStart,line_sir,otY-bokyStart,line_color(true));
                PrintBox(slpMid-slpSir div 2+slpSir,bokyStart,line_sir,otY-bokyStart,line_color(true));
                end;
              bokystart:=otY;
              bokyramecku:=not bokyramecku;
             end;
           cmdSCRIPT:
             with wrOutput^ do
              with PDMBitmap(otBitmap)^ do
               with boxRect do begin
                 {parsing for everybody}
                 {implicitni rect: nasledujici radek textu aktualnim fontem}
                 a.x:=slpMid-slpSir div 2;
                 a.y:=otY;
                 b.x:=a.x+slpSir;
                 b.y:=a.y+round(GetFontHeight*Yzoom);
                 (pos-1)^:=#0;
                 wrOutput^.InstallPx(boxRect,script_pc+1);
                 (pos-1)^:=cmdDONE;
                 end;
           cmdFORMAT:
             SetThree(copy(st,2,255));
           END;
        end;
   EOP: begin
         if debugW then BiosWriteln('Writer Break');
         Patka;
         break;
        end;
   ELSE begin
        Pos2Wr;
        if debugW then BiosWrite('');
        wrOrig^.WriteLong(wrNew,Xzoom,Yzoom,EOP+cmdINIT);
        if debugW then BiosWrite('');
        Wr2Pos;
        end;
   END;
 until false;
 Write:=wrOutput^.overflows;
end;

{---------------------------------------------------------------------------
 Zavolat po dopsani textu.
 ---------------------------------------------------------------------------}
Procedure TDMWriter.WriteDone;
begin
 {$ifdef edit}
 if edit then begin
   {zakonci pole poslednim radkem}
   inc(linetotal);
   edofs^[linetotal]:=word(Pos);
   scrx^[linetotal]:=round(wrNew^.slpMid*Xzoom);
   scry^[linetotal]:=round(writeMaxY*Yzoom);
   end;
 {$endif}
 {obnovi pos}
 pos:=oldpos;
 {$ifdef edit}
 if edit then begin
   {zanese do headeru aktualizovane udaje}
   if writeMaxY<>GetNum(GetHeader('siz:'),2) then begin
     SetHeader('siz:',stri(GetNum(GetHeader('siz:'),1))+'x'+stri(writeMaxY));
     modified:=true;
     end;
   if GetFlag(flagTxa)>0 then
    if wrOrig^.underrects<>GetHeader('txa:') then begin
     SetHeader('txa:',wrOrig^.underrects);
     modified:=true;
     end;
   end;
 {$endif}
end;

{---------------------------------------------------------------------------
 Uvolni wrOrig a wrNew.
 ---------------------------------------------------------------------------}
Destructor TDMWriter.Done;
begin
 KillObj(wrOrig);
 KillObj(wrNew);
 inherited Done;
end;


{$ifdef edit}
{---------------------------------------------------------------------------
 Nastavi pos (was edi) na adresu udanou souradnicemi.
 ---------------------------------------------------------------------------}
Procedure TDMWriter.GotoCoords(myX,myLine:integer);
var x,y:integer;
begin
 {$ifdef beta}
 if (myLine<1) or (myLine>=linetotal) then erBetaMsg('GotoCoords(out of range)');
 {$endif}
 x:=scrx^[myLine];
 y:=scry^[myLine];
 word(pos):=edofs^[myLine];
 while word(pos)<=edofs^[myLine+1]-1 do begin
   if (x>=myX) or (pos^=#13) then begin
     if ((pos-1)^=chgINIT) or (pos^=#10) then inc(pos);
     exit;
     end else inc(x);
   inc(pos);
   end;
end;

{---------------------------------------------------------------------------
 Vraci souradnice udane adresou pos (was ednowi).
 ---------------------------------------------------------------------------}
Procedure TDMWriter.SearchCoordsIn(slp:integer;var myX,myY,myLine:integer);
var i:integer;
    first,last:integer;
begin
 {$ifdef beta}
 if (slp<1) or (slp>SlpMax) then erBetaMsg('SearchCoordsIn(out of range)');
 {$endif}
 {neni ednowi mimo text?}
 if (word(pos)<edofs^[1]) then word(pos):=edofs^[1];
 {hleda radek}
 first:=SlpFirstLine(slp);
 last:=SlpLastLine(slp);
 if first>last then begin
   myLine:=-1;
   myX:=-1;
   myY:=-1;
   exit;
   end;
 for i:=first{1} to last{linetotal} do
  if (word(pos)<edofs^[i]) then begin
    {uz vim ze je
      bud v tele radku i-1   ... potom nlAdr(-0) je <= edofs[i-1]
      nebo v headeru radku i ... potom nlAdr(-0) je >  edofs[i-1]}
    if (i>first{1}){pred radkem 1 byt nemuze}
     and (nlAdr(-0)<=edofs^[i-1])
      then dec(i){je v tele radku i-1}
      else word(pos):=edofs^[i];{presune pos na zacatek tela radku i}
    break;
    end;
 myLine:=i;
 {spocita souradnice}
 myX:=scrx^[myLine];
 myY:=scry^[myLine];
 {najde v nem spravny znak}
 inc(myX,word(pos)-edofs^[myLine]);
end;

{---------------------------------------------------------------------------
 Skoci na uplny zacatek radku myLine (was edi/ednowi).
 ---------------------------------------------------------------------------}
Procedure TDMWriter.VeryStartLine(myLine:integer);
begin
 word(pos):=edofs^[myLine];
 if (pos-2)^=TAB then dec(pos,2) else
 if (pos-1)^=TAB then dec(pos);
 while (pos-1)^=cmdDONE do begin dec(pos);chGoto(cmdINIT,+0);dec(pos);end;
end;
{$endif}


{∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞INIT/DONE∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞}

function Init:TError;
 begin
  Init:=erOk;
 end;

procedure Done;
 begin
 end;

END.