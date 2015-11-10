Unit MyLan;{$i define.inc}

{$IFNDEF DPMI} {$IFNDEF WINDOWS} {$DEFINE REAL} {$ENDIF} {$ENDIF}
interface
uses Strings,MyDef,MyDefin,MyCode,MyPars,MyFunc;
{$I-}

procedure InitLan (ADI : Boolean; AMem : LongInt);
{ADI - ?ma se uzit debug info?, doporucuji true - kvuli chybovym hlaskam
 AMem - pamet pro data interpretovaneho programu
}
procedure ResetLan;
{
nastaveni stavu jako po inicializaci - uzij jen u kritickych chyb nebo
kdyz potrebujes, aby interpret zapomnel definice vsech procedur a fci
predtim definovanych
}
procedure RefreshLan;
{
refresh po chybe
}
procedure DoneLan;
function CompileSource (var ASrc : PChar; R : Boolean) : PData; {R=true}
{
Zkompiluje ASrc a vrati pripadne nove naalokovany prostor v ASrc - je-li potreba naalokovat
}
function Run (Counter : LongInt) : Integer; {export}
{
Counter kolik elementarnich operaci se ma vykonat v jednom interpretacnim cyklu
po jeho skonceni se zase dostanes k lizu muzes neco refreshnout a pak se volanim
teto fce pustit do pokracovani interpretace
pokud uzijes jako parametr -1 provede se program az do konce - bez preruseni
vrati-li fce 0 je hotovo - interpretace skoncila
}
implementation uses MyPProc;

procedure Turn (P : PCode); forward; {Analyzovana data jsou v prefixu,ja je potrebuju v postfixu}
procedure Analyze; forward;

procedure ResetLan;
begin
  Prg:=nil; Stack:=nil; Vars:=OldVars;
  {GarbageCollector;}Refresh(MinFree4Compilation);
end;

procedure RefreshLan;
begin
  Prg:=nil; Stack:=nil;
end;

function CompileSource;
 begin
   CompileSource:=nil;
   if R then begin Prg:=nil; Stack:=nil; end;
   {GarbageCollector;}Refresh(MinFree4Compilation);
   Src:=ASrc;
   Preprocesor;
   Analyze;
   {GarbageCollector;}Refresh(MinFree4Compilation);
   if ErrCode = 0 then begin
    Turn (Prg);
    {$IFDEF DEBUGLAN} Statistic; {$ENDIF}
    CompileSource:=Prg;
   end else Prg:=nil;
   ASrc:=Src;
 end;

function Run (Counter : LongInt) : Integer; {Spusti jiz "prelozeny" kod}
 var Next : PCode;
 begin
   RunCode:=0; ErrCode:=0;
   while (Prg <> nil) and (Counter <> 0) do begin
    if Counter>0 then Dec(Counter);
    Refresh(MinFree4RunStep);
    Next:=nil;
    if (Prg^.Item <> nil) and (Prg^.Item^.T=cCode) then
     Next:=TFunction (Prg^.Item^.Entry) (Prg,Stack)
    else if (Prg^.Item = nil) or (Prg^.Item <> nil) and (Prg^.Item^.T <> cNothing) then
     PushArg (Stack,Prg^.Item);
    if Prg = nil then break;
    if Next <> nil then Prg:=Next else Prg:=Prg^.Next;
   end;
   if Prg <> nil then Run:=-1 else Run:=0;
 end;

procedure Analyze; {Analyzuje Source v SRC : PChar - globalni promena}
 var XSrc : PChar;
     D : TData;
     P : PData;
 begin
   ErrCode:=0; XSrc:=Src;
   Prg:=nil;
   P:=GetFree; P^.T:=cCode; P^.Entry:=@InitCode; PushArg (Prg,P);
   APrg (XSrc,Prg,@D); {A zaciname globalni analyzu}
   if XSrc^ <> #0 then GiveError (XSrc);
   P:=GetFree; P^.T:=cCode; P^.Entry:=@DoneCode; PushArg (Prg,P); {Push End. na Prg stack}
 end;

procedure Turn (P : PCode); {Analyzovana data jsou v prefixu,ja je potrebuju v postfixu}
 begin
   Prg:=nil;
   while P <> nil do PushArg (Prg,PopArg (P));
 end;

procedure InitLan;
 begin
   if AMem>=AllocMem then AllocMem:=AMem;
   DebugInfo:=true;
   GenerateMemory (AllocMem);
   InitPredefinedFuncs;
   MyDefin.OldVars:=MyDefin.Vars;
 end;

procedure DoneLan;
 begin
   Sweep;
   ReleaseMemory;
 end;

end.