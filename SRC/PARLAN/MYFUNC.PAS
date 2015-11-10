Unit MyFunc;{$i define.inc}{$t-}

{Vsechny funkce,ktere se volaji interne po "prekladu"
 Prg - je ukazatel na seznam prikazu (reprezentovany taky jako seznam TData)
       a ukazuje na aktualni prikaz
 Stack - Obsahuje parametry funkce,vybiraji se pomoci PopArg (Stack) -> PData}

{$IFNDEF DPMI} {$IFNDEF WINDOWS} {$DEFINE REAL} {$ENDIF} {$ENDIF}

interface

uses Strings,MyDef,MyDefin,MyPProc;

procedure DefineFunc (FD : String; Entry : Pointer);
procedure DefineConst (CD : String; Value : Longint);
procedure DefineConstStr(CD : String; Value : PChar);

function RunString (var Prg,Stack : PData) : PData; far;
function RunModul (var Prg,Stack : PData) : PData; far;
function EndRun (var Prg,Stack : PData) : PData; {$IFNDEF REAL} export; {$ENDIF}
function Randik (var Prg,Stack : PData) : PData; {$IFNDEF REAL} export; {$ENDIF}
function Plus (var Prg,Stack : PData) : PData; {$IFNDEF REAL} export; {$ENDIF}
function Minus (var Prg,Stack : PData) : PData; {$IFNDEF REAL} export; {$ENDIF}
function Mul (var Prg,Stack : PData) : PData; {$IFNDEF REAL} export; {$ENDIF}
function DivCode (var Prg,Stack : PData) : PData; {$IFNDEF REAL} export; {$ENDIF}
function ModCode (var Prg,Stack : PData) : PData; {$IFNDEF REAL} export; {$ENDIF}
function XAndX (var Prg,Stack : PData) : PData; {$IFNDEF REAL} export; {$ENDIF}
function XOrX (var Prg,Stack : PData) : PData; {$IFNDEF REAL} export; {$ENDIF}
function XXorX (var Prg,Stack : PData) : PData; {$IFNDEF REAL} export; {$ENDIF}
function Notik (var Prg,Stack : PData) : PData; {$IFNDEF REAL} export; {$ENDIF}
function Less (var Prg,Stack : PData) : PData; {$IFNDEF REAL} export; {$ENDIF}  {Test na mensi}
function LessEqu (var Prg,Stack : PData) : PData; {$IFNDEF REAL} export; {$ENDIF}  {Test na mensi}
function More (var Prg,Stack : PData) : PData; {$IFNDEF REAL} export; {$ENDIF}
function MoreEqu (var Prg,Stack : PData) : PData; {$IFNDEF REAL} export; {$ENDIF}
function IsSame (var Prg,Stack : PData) : PData; {$IFNDEF REAL} export; {$ENDIF}
function NotSame (var Prg,Stack : PData) : PData; {$IFNDEF REAL} export; {$ENDIF}
function Echo (var Prg,Stack : PData) : PData; {$IFNDEF REAL} export; {$ENDIF}
function MakeArray (var Prg,Stack : PData) : PData; {$IFNDEF REAL} export; {$ENDIF}
function MakeList (var Prg,Stack : PData) : PData; {$IFNDEF REAL} export; {$ENDIF}
function AssignLValue (var Prg,Stack : PData) : PData; {$IFNDEF REAL} export; {$ENDIF}
function GetVar (var Prg,Stack : PData) : PData; {$IFNDEF REAL} export; {$ENDIF}
function GetArrVal (var Prg,Stack : PData) : PData; {$IFNDEF REAL} export; {$ENDIF}
function IfCode (var Prg,Stack : PData) : PData; {$IFNDEF REAL} export; {$ENDIF}
function GotoCode (var Prg,Stack : PData) : PData; {$IFNDEF REAL} export; {$ENDIF}
function InitForCode (var Prg,Stack : PData) : PData; {$IFNDEF REAL} export; {$ENDIF}
function ForCheck (var Prg,Stack : PData) : PData; {$IFNDEF REAL} export; {$ENDIF}
function ForDestructor (var Prg,Stack : PData) : PData; {$IFNDEF REAL} export; {$ENDIF}
function ForEach (var Prg,Stack : PData) : PData; {$IFNDEF REAL} export; {$ENDIF}
function WhileCode (var Prg,Stack : PData) : PData; {$IFNDEF REAL} export; {$ENDIF}
function BreakCode (var Prg,Stack : PData) : PData; {$IFNDEF REAL} export; {$ENDIF}
function ContinueCode (var Prg,Stack : PData) : PData; {$IFNDEF REAL} export; {$ENDIF}
function InitCode (var Prg,Stack : PData) : PData; {$IFNDEF REAL} export; {$ENDIF}
function DoneCode (var Prg,Stack : PData) : PData; {$IFNDEF REAL} export; {$ENDIF}
function CallNoRetFunc (var Prg,Stack : PData) : PData; {$IFNDEF REAL} export; {$ENDIF} {Force no return value}
function CallRetFunc (var Prg,Stack : PData) : PData; {$IFNDEF REAL} export; {$ENDIF} {Force no return value}
function CallFunc (Zaraz : PData; var Prg,Stack : PData) : PData;
function RReturn (var Prg,Stack : PData) : PData; {$IFNDEF REAL} export; {$ENDIF}
function Return (var Prg,Stack : PData) : PData; {$IFNDEF REAL} export; {$ENDIF}
function Halt (var Prg,Stack : PData) : PData; {$IFNDEF REAL} export; {$ENDIF}
function StopCode (var Prg,Stack : PData) : PData; {$IFNDEF REAL} export; {$ENDIF}
function ContCode (var Prg,Stack : PData) : PData; {$IFNDEF REAL} export; {$ENDIF}
function Len (var Prg,Stack : PData) : PData; {$IFNDEF REAL} export; {$ENDIF}
function GetType (var Prg,Stack : PData) : PData; {$IFNDEF REAL} export; {$ENDIF}
function Gc (var Prg,Stack : PData) : PData; {$IFNDEF REAL} export; {$ENDIF}
function WriteFree (var Prg,Stack : PData) : PData; {$IFNDEF REAL} export; {$ENDIF}
function WriteVars (var Prg,Stack : PData) : PData; {$IFNDEF REAL} export; {$ENDIF}
function XDefine (var Prg,Stack : PData) : PData; {$IFNDEF REAL} export; {$ENDIF}
function Terminate (var Prg,Stack : PData) : PData; {$IFNDEF REAL} export; {$ENDIF}
function XUpString (var Prg,Stack : PData) : PData; {$IFNDEF REAL} export; {$ENDIF}
function XStrPos (var Prg,Stack : PData) : PData; {$IFNDEF REAL} export; {$ENDIF}
function XStrCopy (var Prg,Stack : PData) : PData; {$IFNDEF REAL} export; {$ENDIF}
function Car (var Prg,Stack : PData) : PData; {$IFNDEF REAL} export; {$ENDIF}
function Cdr (var Prg,Stack : PData) : PData; {$IFNDEF REAL} export; {$ENDIF}
function FD (var Prg,Stack : PData) : PData; {$IFNDEF REAL} export; {$ENDIF}
function BD (var Prg,Stack : PData) : PData; {$IFNDEF REAL} export; {$ENDIF}
function SetCode (var Prg,Stack : PData) : PData; {$IFNDEF REAL} export; {$ENDIF}
function RVar (var Prg,Stack : PData) : PData;
function GlobalVar (var Prg,Stack : PData) : PData; {$IFNDEF REAL} export; {$ENDIF}
function DebugInfoCode (var Prg,Stack : PData) : PData; {$IFNDEF REAL} export; {$ENDIF}
function NoCode (var Prg,Stack : PData) : PData; {$IFNDEF REAL} export; {$ENDIF}
function PrintData (var Stack : PData; Scr : Boolean) : String; {$IFNDEF REAL} export; {$ENDIF}
procedure InitPredefinedFuncs; {$IFNDEF REAL} export; {$ENDIF}
function ErrLine : String; {$IFNDEF REAL} export; {$ENDIF}
function RunError : PStr; {$IFNDEF REAL} export; {$ENDIF}
function ActiveScr : String; {$IFNDEF REAL} export; {$ENDIF}
function ActiveLine : Integer; {$IFNDEF REAL} export; {$ENDIF}
procedure ErrorSignal (var Prg,Stack : PData; EC : Integer);
const _ErrLine    : String [100] = '';
      _RunError   : String [100] = '';
      _ActiveScr  : String [50] = '';
      _ActiveLine : Integer = 0;

{****************************************************************************}

implementation uses MyCode,MyVars,
                    {$IFDEF WINDOWS}
                    NFWin, {$ELSE}
                    NFDos, {$ENDIF}
                    MyLan;

{****************************************************************************}

function ErrLine : String; begin ErrLine:=_ErrLine; end;
function RunError : PStr; begin RunError:=@_RunError; end;
function ActiveScr : String; begin ActiveScr:=_ActiveScr; end;
function ActiveLine : Integer; begin ActiveLine:=_ActiveLine; end;

procedure DefineFunc;
 var F : PData;
 begin
   F:=RegisterVar (FD,@Vars); F^.T:=cBinFunc; F^.Value:=Entry;
 end;

procedure DefineConst(CD : String; Value : Longint);
 var F : PData;
 begin
   F:=RegisterVar(CD,@Vars);
   F^.T:=cVar;
   F^.Value:=GetFree;
   F^.Value^.T:=cInt;
   F^.Value^.Data.Int:=Value;
 end;

procedure DefineConstStr(CD : String; Value : pchar);
 var F : PData;
 begin
   F:=RegisterVar(CD,@Vars);
   F^.T:=cVar;
   F^.Value:=GetFree;
   F^.Value^.T:=cStr;
   F^.Value^.Handle:=1;
   F^.Value^.Data.StrC:=StrNew(value);
   F^.Value^.Data.StrL:=StrLen(value)+1;
 end;

procedure ErrorSignal (var Prg,Stack : PData; EC : Integer);
 begin
   _RunError:='Runtime (' + _ErrLine + ')'#13#10;
   ErrCode:=EC;
   case ErrCode of
    1 : _RunError:=_RunError+'Identifikator neobsahuje ukazatel na funkci';
    2 : _RunError:=_RunError+'O vyrazu nelze rozhodnout zda je pravdivy';
    3 : _RunError:=_RunError+'Byl pouzit break nebo continue mimo blok cyklu';
    5 : _RunError:=_RunError+'Nelze srovnat ruzne typy dat';
    6 : _RunError:=_RunError+'Ocekavan seznam';
    7 : _RunError:=_RunError+'Ocekavano cislo';
    8 : _RunError:=_RunError+'Nelze indexovat nic jineho nez pole';
    9 : _RunError:=_RunError+'Prirazeni do pole nelze provest - kolize typu';
    10 : _RunError:=_RunError+'Pozor na prirazeni';
    11 : _RunError:=_RunError+'Return vraci gotocode tesne za endproc (nil';
    12 : _RunError:=_RunError+'funkce by mela vratit hodnotu';
    13 : _RunError:=_RunError+'Index pole mimo rozsah';
    14 : _RunError:=_RunError+'Ocekavan string s kodem';
    15 : _RunError:=_RunError+'Ocekavana hodnota';
   end;
   ErrorHandler(ErrCode);
   Prg:=nil;
 end;

{****************************************************************************}

procedure InitPredefinedFuncs; {Zaregistruje pred definovane funkce a konstanty}
 var F : PData;
 begin
   F:=RegisterVar ('UPSTRING',@Vars); F^.T:=cBinFunc; F^.Value:=@XUpString;
   F:=RegisterVar ('NULL',@Vars); F^.T:=cVar; F^.Value:=NULL;
   F:=RegisterVar ('RUNSTR',@Vars); F^.T:=cBinFunc; F^.Value:=@RunString;
   F:=RegisterVar ('LD',@Vars); F^.T:=cBinFunc; F^.Value:=@RunModul;
   F:=RegisterVar ('STRPOS',@Vars); F^.T:=cBinFunc; F^.Value:=@XStrPos;
   F:=RegisterVar ('STRCOPY',@Vars); F^.T:=cBinFunc; F^.Value:=@XStrCopy;
   F:=RegisterVar ('ECHO',@Vars); F^.T:=cBinFunc; F^.Value:=@Echo;
   F:=RegisterVar ('LEN',@Vars); F^.T:=cBinFunc; F^.Value:=@Len;
   F:=RegisterVar ('GC',@Vars); F^.T:=cBinFunc; F^.Value:=@Gc;
   F:=RegisterVar ('WF',@Vars); F^.T:=cBinFunc; F^.Value:=@WriteFree;
   F:=RegisterVar ('WV',@Vars); F^.T:=cBinFunc; F^.Value:=@WriteVars;
   F:=RegisterVar ('DEFINE',@Vars); F^.T:=cBinFunc; F^.Value:=@XDefine;
   F:=RegisterVar ('CAR',@Vars); F^.T:=cBinFunc; F^.Value:=@Car;
   F:=RegisterVar ('CDR',@Vars); F^.T:=cBinFunc; F^.Value:=@Cdr;
   F:=RegisterVar ('SET',@Vars); F^.T:=cBinFunc; F^.Value:=@SetCode;
   F:=RegisterVar ('FD',@Vars); F^.T:=cBinFunc; F^.Value:=@FD;
   F:=RegisterVar ('BD',@Vars); F^.T:=cBinFunc; F^.Value:=@BD;
   F:=RegisterVar ('TYPE',@Vars); F^.T:=cBinFunc; F^.Value:=@GetType;
   F:=RegisterVar ('NOP',@Vars); F^.T:=cBinFunc; F^.Value:=@NoCode;
   F:=RegisterVar ('GVAR',@Vars); F^.T:=cBinFunc; F^.Value:=@GlobalVar;
   F:=RegisterVar ('RAND',@Vars); F^.T:=cBinFunc; F^.Value:=@Randik;
 end;

{****************************************************************************}

function IsTrue (P : PData) : Integer; {For internal use,test if Expresion has true value}
 begin
   case P^.T of
    cInt : IsTrue:=Ord (P^.Data.Int <> 0);
    cStr : IsTrue:=Ord ((P^.Data.StrC <> nil) and (P^.Data.StrC^ > #0));
    cUserList,cList : IsTrue:=Ord (P^.Item <> ListNULL);
    cNothing,cNULL : IsTrue:=Ord ((P <> NULL) and (P <> ListNULL));
    else begin IsTrue:=-1; ErrorSignal (Prg,Stack,2); end;
   end;
 end;

{****************************************************************************}

function RunString;
 var S,G,P : PData;
 begin
   RunString:=nil;
   S:=PopArg (Stack);
   if S^.T <> cStr then begin ErrorSignal (Prg,Stack,2); end;
   GetMem (Src,StrLen (S^.Data.StrC)+1); StrCopy (Src,S^.Data.StrC);
   PushArg (Stack,Prg); Prg:=nil; Prg:=CompileSource (Src,false);
   DoneSource (Src); Src:=nil; P:=Prg;
   while (P <> nil) and ((P^.Item = nil) or (P^.Item^.Entry <> @DoneCode)) do P:=P^.Next;
   if P=nil then begin Prg:=PopArg (Stack); Exit; end;
   P^.Item^.Entry:=@EndRun;
   P:=Prg; Prg:=PopArg (Stack); PopArg (Stack);
   {G:=GetFree; G^.T:=cStr; G^.Data.Str:=Src; PushArg (Stack,G);}
   StopCode (Prg,Stack); Prg:=P;
   RunString:=Prg; PushArg (Stack,nil);
 end;

function EndRun;
 var P : PData;
 begin
   ContCode (Prg,Stack); EndRun:=Prg;
   {P:=PopArg (Stack);
   Src:=P^.Data.Str; P^.Data.Str:=nil;}
 end;

function RunModul;
 var S,G,P : PData;
 begin
   RunModul:=nil;
   S:=PopArg (Stack);
   if S^.T <> cStr then begin ErrorSignal (Prg,Stack,2); end;
   Src:=LoadSource (StrPas (S^.Data.StrC));
   PushArg (Stack,Prg); Prg:=nil; Prg:=CompileSource (Src,false);
   DoneSource (Src); Src:=nil; P:=Prg;
   while (P <> nil) and ((P^.Item = nil) or (P^.Item^.Entry <> @DoneCode)) do P:=P^.Next;
   if P=nil then begin Prg:=PopArg (Stack); Exit; end;
   P^.Item^.Entry:=@EndRun;
   P:=Prg; Prg:=PopArg (Stack); PopArg (Stack);
   StopCode (Prg,Stack); Prg:=P;
   RunModul:=Prg; PushArg (Stack,nil);
 end;

{****************************************************************************}

function Plus;
 var P : Array [0..1] of PData;
     X : Byte; D : PData;
 begin
   for X:=1 downto 0 do P [X]:=PopArg (Stack);
   D:=GetFree;
   case P [0]^.T of
    cInt : begin D^.T:=cInt; D^.Data.Int:=P [0]^.Data.Int+P [1]^.Data.Int; end;
    cStr : begin
             D^.T:=cStr;
             D^.Data.StrL:=StrLen (P [0]^.Data.StrC)+StrLen (P [1]^.Data.StrC)+1;
             GetMem (D^.Data.StrC,D^.Data.StrL);
             StrCopy (D^.Data.StrC,P [0]^.Data.StrC); StrCat (D^.Data.StrC,P [1]^.Data.StrC);
           end;
   end;
   PushArg (Stack,D); Plus:=nil;
 end;

{****************************************************************************}

function Minus;
 var P : Array [0..1] of LongInt;
     X : Byte; D : PData;
 begin
   for X:=1 downto 0 do P [X]:=PopArg (Stack)^.Data.Int;
   D:=GetFree; D^.T:=cInt; D^.Data.Int:=P [0]-P [1];
   PushArg (Stack,D); Minus:=nil;
 end;

{****************************************************************************}

function Mul;
 var P : Array [0..1] of LongInt;
     X : Byte; D : PData;
 begin
   for X:=1 downto 0 do P [X]:=PopArg (Stack)^.Data.Int;
   D:=GetFree; D^.T:=cInt; D^.Data.Int:=P [0]*P [1];
   PushArg (Stack,D); Mul:=nil;
 end;

{****************************************************************************}

function DivCode;
 var P : Array [0..1] of LongInt;
     X : Byte; D : PData;
 begin
   for X:=1 downto 0 do P [X]:=PopArg (Stack)^.Data.Int;
   D:=GetFree; D^.T:=cInt; D^.Data.Int:=P [0] div P [1];
   PushArg (Stack,D); DivCode:=nil;
 end;

{****************************************************************************}

function ModCode;
 var P : Array [0..1] of LongInt;
     X : Byte; D : PData;
 begin
   for X:=1 downto 0 do P [X]:=PopArg (Stack)^.Data.Int;
   D:=GetFree; D^.T:=cInt; D^.Data.Int:=P [0] mod P [1];
   PushArg (Stack,D); ModCode:=nil;
 end;

{****************************************************************************}

function XOrX;
 var P : Array [0..1] of LongInt;
     X : Byte; D : PData;
 begin
   for X:=1 downto 0 do P [X]:=PopArg (Stack)^.Data.Int;
   D:=GetFree; D^.T:=cInt; D^.Data.Int:=P [0] or P [1];
   PushArg (Stack,D); XOrX:=nil;
 end;

{****************************************************************************}

function XXorX;
 var P : Array [0..1] of LongInt;
     X : Byte; D : PData;
 begin
   for X:=1 downto 0 do P [X]:=PopArg (Stack)^.Data.Int;
   D:=GetFree; D^.T:=cInt; D^.Data.Int:=P [0] xor P [1];
   PushArg (Stack,D); XXorX:=nil;
 end;

{****************************************************************************}

function XAndX;
 var P : Array [0..1] of LongInt;
     X : Byte; D : PData;
 begin
   for X:=1 downto 0 do P [X]:=PopArg (Stack)^.Data.Int;
   D:=GetFree; D^.T:=cInt; D^.Data.Int:=P [0] and P [1];
   PushArg (Stack,D); XAndX:=nil;
 end;

{****************************************************************************}

function Notik;
 var P,D : PData;
 begin
   P:=PopArg (Stack);
   D:=GetFree; D^.T:=cInt; D^.Data.Int:=Ord (IsTrue (P)=0);
   PushArg (Stack,D); Notik:=nil;
 end;

{****************************************************************************}
{tady by to chtelo udelat jednoduseji - casem}

function Less;
 var P : Array [0..1] of LongInt;
     X : Byte; D : PData;
 begin
   for X:=1 downto 0 do P [X]:=PopArg (Stack)^.Data.Int;
   D:=GetFree; D^.T:=cInt; D^.Data.Int:=Ord (P [0]<P [1]);
   PushArg (Stack,D); Less:=nil;
 end;

function LessEqu;
 var P : Array [0..1] of LongInt;
     X : Byte; D : PData;
 begin
   for X:=1 downto 0 do P [X]:=PopArg (Stack)^.Data.Int;
   D:=GetFree; D^.T:=cInt; D^.Data.Int:=Ord (P [0]<=P [1]);
   PushArg (Stack,D); LessEqu:=nil;
 end;

function More;
 var P : Array [0..1] of LongInt;
     X : Byte; D : PData;
 begin
   for X:=1 downto 0 do P [X]:=PopArg (Stack)^.Data.Int;
   D:=GetFree; D^.T:=cInt; D^.Data.Int:=Ord (P [0]>P [1]);
   PushArg (Stack,D); More:=nil;
 end;

function MoreEqu;
 var P : Array [0..1] of LongInt;
     X : Byte; D : PData;
 begin
   for X:=1 downto 0 do P [X]:=PopArg (Stack)^.Data.Int;
   D:=GetFree; D^.T:=cInt; D^.Data.Int:=Ord (P [0]>=P [1]);
   PushArg (Stack,D); MoreEqu:=nil;
 end;

function IsSame;
 var P : Array [0..1] of PData;
     X : Byte; D : PData;
 begin
   IsSame:=nil;
   for X:=1 downto 0 do P [X]:=PopArg (Stack);
   D:=GetFree; D^.T:=cInt;
   if (P [0]^.T <> P [1]^.T) and (P [0]^.T <> cNULL) and (P [1]^.T <> cNULL) then
    begin ErrorSignal (Prg,Stack,5); Exit; end;
   case P [1]^.T of
    cInt : D^.Data.Int:=Ord (P [0]^.Data.Int=P [1]^.Data.Int);
    cStr : D^.Data.Int:=Ord (strcomp (P [0]^.Data.StrC,P [1]^.Data.StrC) = 0);
    cUserList : D^.Data.Int:=(Ord ((P [0]=P [1]) or (P [0]^.Item^.T=cNULL) and (P [1]^.Item^.T=cNULL)));
    cNULL : D^.Data.Int:=Ord (P [0]^.T=cNULL);
    else D^.Data.Int:=Ord (P [0]=P [1]);
   end;
   PushArg (Stack,D);
 end;

function NotSame;
 var P : Array [0..1] of LongInt;
     X : Byte; D : PData;
 begin
   NotSame:=IsSame (Prg,Stack);
   Stack^.Item^.Data.Int:=Ord (Not (Boolean (Stack^.Item^.Data.Int)));
 end;

{****************************************************************************}

function PrintData (var Stack : PData; Scr : Boolean) : String;
 function Pis : String;
  var P : PData; RS,S : String;
  function Converti (S : String) : String;
   var RS : String; I : Integer;
   begin
     RS:=''; I:=1;
     while I<=Length (S) do begin
      RS:=RS+S [I];
      if S [I]='\' then RS:=RS+S [I];
      Inc (I);
     end;
     Converti:=RS;
   end;

  begin
    RS:=''; P:=PopArg (Stack);
    while P <> nil do begin
     case P^.T of
      cInt : Str (P^.Data.Int,S);
      cFunc : if Not Scr then S:='Funkce:' + P^.Name^ else S:='@'+P^.Name^;
      cBinFunc : if Not Scr then S:='Binarni funkce:' + P^.Name^ else S:='@'+P^.Name^;
      cVar : if Not Scr then S:='Promena:' + P^.Name^ else S:='@'+P^.Name^;
      cCode : S:='Kod';
      cStr : if Scr then S:='"'+Converti (StrPas (P^.Data.StrC))+'"' else S:=StrPas (P^.Data.StrC);
      cList,cUserList : begin
                          S:='[';
                          while P^.Item <> ListNULL do begin
                           PushArg (Stack,nil);
                           PushArg (Stack,P^.Item);
                           S:=S + Pis; P:=P^.Next;
                           if P^.Item <> ListNULL then S:=S + ',';
                          end;
                          S:=S + ']';
                        end;
      cNULL : S:='NULL';
      else S:='Buh vi co to je';
     end;
     P:=PopArg (Stack); RS:=RS+S;
    end;
    Pis:=RS;
  end;

 begin
   PrintData:=Pis;
 end;

function Echo;
 var S : String;
 begin
   S:=PrintData (Stack,false);
   WriteLn (S);
   Echo:=nil; PushArg (Stack,nil); {!!!!}
 end;

{****************************************************************************}

function MakeArray;
 var V,E : PData; X,OC : Integer; OA : PParams;
 begin
   MakeArray:=nil;
                {WriteLn ('Before');}
   E:=PopArg (Stack); V:=PopArg (Stack);
   if E^.T <> cInt then begin ErrorSignal (Prg,Stack,7); Exit; end;
   if (V^.Value <> nil) and (V^.Value^.T=cArray) and (V^.Value^.Count <> E^.Data.Int) then
    begin OA:=V^.Value^.Arr; OC:=V^.Value^.Count; end else OC:=0;
   if (V^.Value = nil) or (V^.Value^.T <> cArray) then begin V^.Value:=GetFree; V^.Value^.T:=cArray; end;
                {WriteLn ('Before',OC,V^.Value^.T);}
   V^.Value^.Count:=E^.Data.Int; {WriteLn ('Past',(V^.Value^.Count)*SizeOf (PData));}
   GetMem (V^.Value^.Arr,(V^.Value^.Count)*SizeOf (PData));
                {WriteLn ('Past');}
   for X:=0 to V^.Value^.Count-1 do
    if OC>X then V^.Value^.Arr^ [X]:=OA^ [X] else
     V^.Value^.Arr^ [X]:=NULL;
   if OC > 0 then FreeMem (OA,OC*SizeOf (PData));
                {WriteLn ('Past');}
 end;

{function MakeArray;
 var V,N,E : PData; X : Integer;
 begin
   MakeArray:=nil;
   E:=PopArg (Stack); V:=PopArg (Stack);
   if E^.T <> cInt then begin ErrorSignal (Prg,Stack,7); Exit; end;

   if (V^.Value^.T=cArray) and (V^.Value^.Count <> E^.Data.Int) then
     FreeMem (V^.Value^.Arr,V^.Value^.Count*SizeOf (PData))
    else if V^.Value^.T <> cArray then begin V^.Value:=GetFree; V^.Value^.T:=cArray; end;
   if E^.Data.Int = 0 then Exit;
   V^.Value^.Count:=E^.Data.Int; GetMem (V^.Value^.Arr,(V^.Value^.Count)*SizeOf (PData));
   for X:=0 to V^.Value^.Count-1 do V^.Value^.Arr^ [X]:=NULL;
 end;}

{****************************************************************************}

function MakeList;
 var P,L : PData;

 begin
   L:=nil; PushArg (L,ListNULL); L^.T:=cUserList;
   repeat
    P:=PopArg (Stack);
    if P <> nil then begin PushArg (L,P); L^.T:=cUserList; end;
   until P = nil;
   PushArg (Stack,L);
   MakeList:=nil;
 end;

{****************************************************************************}

function Car;
 var L : PData;
 begin
   L:=PopArg (Stack); PopArg (Stack);
   if L^.Item = nil then PushArg (Stack,NULL)
    else PushArg (Stack,L^.Item);
   Car:=nil;
 end;

{****************************************************************************}

function Cdr;
 var L : PData;
 begin
   L:=PopArg (Stack); PopArg (Stack);
   if L^.Next = nil then PushArg (Stack,L) else PushArg (Stack,L^.Next);
   Cdr:=nil;
 end;

{****************************************************************************}

function FD;
 var L,E : PData;
 begin
   E:=PopArg (Stack); L:=PopArg (Stack); PopArg (Stack);
   if L^.T <> cUserList then begin ErrorSignal (Prg,Stack,6); Exit; end;
   PushArg (L,E); L^.T:=cUserList; PushArg (Stack,L);
   FD:=nil;
 end;

function BD;
 var L,E : PData;
 begin
   L:=PopArg (Stack); E:=PopArg (Stack); PopArg (Stack);
   if (L^.T <> cUserList) or (E^.T <> cUserList) then begin ErrorSignal (Prg,Stack,6); Exit; end;
   L^.Next:=E; PushArg (Stack,L);
   BD:=nil;
 end;

function SetCode;
 var L,E : PData;
 begin
   E:=PopArg (Stack); L:=PopArg (Stack); PopArg (Stack);
   if (L^.T <> cUserList) then begin ErrorSignal (Prg,Stack,6); Exit; end;
   L^.Item:=E; PushArg (Stack,L);
   SetCode:=nil;
 end;

{****************************************************************************}

function AssignLValue;
 var E,V,A : PData;
 begin
   AssignLValue:=nil;
   E:=PopArg (Stack); V:=PopArg (Stack);
   if (Stack <> nil) and (Stack^.Item <> nil) and (Stack^.Item^.T = cArray) then begin
     A:=PopArg (Stack);
     if V^.T <> cInt then begin ErrorSignal (Prg,Stack,9); Exit; end;
     if V^.Data.Int >= A^.Count then begin ErrorSignal (Prg,Stack,13); Exit; end
      else A^.Arr^ [V^.Data.Int]:=E;
    end else begin
     if (V = nil) or (V^.T <> cVar) then begin ErrorSignal (Prg,Stack,10); Exit; end;
     V^.Value:=E;
   end;
 end;

{****************************************************************************}

function GetVar; {Vezmi obsah promene a soupni ji na stack pro dalsi zpracovani}
 var
   P,V : PData;
 begin
   V:=PopArg (Stack);
   if V = nil then begin ErrorSignal (Prg,Stack,15); Exit; end;
   case V^.T of
    cVar : V:=V^.Value;
    cFunc,cBinFunc,cArray : ;
    else begin ErrorSignal (Prg,Stack,15); Exit; end;
   end;
   PushArg (Stack,V);
   GetVar:=nil;
 end;

{****************************************************************************}

function GetArrVal;
 var
   P,V,E : PData;
 begin
   GetArrVal:=nil;
   E:=PopArg (Stack); V:=PopArg (Stack);
   if E^.T <> cInt then begin ErrorSignal (Prg,Stack,7); Exit; end;
   if V^.T <> cArray then begin ErrorSignal (Prg,Stack,8); Exit; end;
   if E^.Data.Int >= V^.Count then begin ErrorSignal (Prg,Stack,13); Exit; end
    else PushArg (Stack,V^.Arr^ [E^.Data.Int]);
 end;

{****************************************************************************}

function IfCode; {Klasicky if}
 var
   Cond,EndifCode,ElseCode : PData;
 begin
   ElseCode:=PopArg (Stack)^.UserEntry;
   EndifCode:=PopArg (Stack)^.UserEntry;
   Cond:=PopArg (Stack);
   if IsTrue (Cond) = 0 then
     if ElseCode <> nil then IfCode:=ElseCode^.Next else IfCode:=EndifCode^.Next
    else IfCode:=nil;
 end;

{****************************************************************************}

function GotoCode; {Zatim se pouziva interne}
 var P : PData;
 begin
   P:=PopArg (Stack);
   GotoCode:=P^.UserEntry^.Next; {Jako navratova hodnota se preda ukazatel na kod,kde se ma pokracovat}
 end;

{****************************************************************************}

function InitForCode; {Inicializace pred forem}
 var XFrom,XVar : PData;
 begin
   XFrom:=Stack^.Next^.Item; XVar:=Stack^.Next^.Next^.Item;
   XVar^.Value:=GetFree; {Pozor zatim prasarna}
   XVar^.Value^.T:=cInt; XVar^.Value^.Data.Int:=XFrom^.Data.Int-1;
   InitForCode:=nil;
 end;

function ForCheck; {Checkuje zda for cyklus nema skoncit}
 var XVar,XTo,P : PData;
 begin
   XVar:=Stack^.Next^.Next^.Next^.Item; XTo:=Stack^.Next^.Item;
   P:=GetFree; P^.T:=cInt; P^.Data.Int:=XVar^.Value^.Data.Int+1;
   XVar^.Value:=P;
{   Nova hodnota,kdyby se nekam ulozila byla by nasledne zmenena,nelze}

{   XVar^.Value^.Data.Int:=XVar^.Value^.Data.Int+1;}

   if XVar^.Value^.Data.Int>XTo^.Data.Int then
     begin P:=PopArg (Stack); ForCheck:=P^.UserEntry^.Next^.Next^.Next; end
    else ForCheck:=nil;
 end;

{****************************************************************************}

function ForEach; {For each x in list/array}
 var V,L,N : PData;
 begin
   {writeln('-');     asm mov ah,8;int 21h;end;{}
   V:=Stack^.Next^.Next^.Item; {var}
   L:=Stack^.Next^.Item; {List}
   {dostane pole: vytvori misto nej pole s iteratorem}
   if L^.T = cArray then begin
     N:=GetFree;
     N^.T:=cArrayIter;
     N^.PArr:=L;
     N^.Iter:=0;
     L:=N;
     Stack^.Next^.Item:=N;
     end;
   {dostane pole s iterartorem: projizdi a hleda inicializovane prvky}
   if L^.T = cArrayIter then begin
     {writeln ('typ=',l^.t,' count=',l^.parr^.count,' iter=',l^.iter,' [0]=',l^.parr^.arr^[0]^.t,' [1]=',l^.parr^.arr^[1]^.t);
     asm mov ah,8;int 21h;end;{}
     while (L^.Iter<L^.PArr^.Count) and (L^.PArr^.Arr^[L^.Iter]=NULL){(L^.Arr^[L^.Iter]^.T=cArray)} do inc(L^.Iter);
     if L^.Iter<L^.PArr^.Count then begin
       ForEach:=nil;
       V^.Value:=L^.PArr^.Arr^[L^.Iter];
       inc(L^.Iter);
       {writeln('-cont-');     asm mov ah,8;int 21h;end;{}
       end
      else begin
       ForEach:=PopArg (Stack)^.UserEntry^.Next^.Next^.Next;
       {writeln('-ende-');     asm mov ah,8;int 21h;end;{}
       end;
     end
   else
   {dostane seznam: ukusuje si po jednom zkraje}
   if L^.T = cUserList then begin
     V^.Value:=L^.Item; Stack^.Next^.Item:=L^.Next;
     if L^.Item <> ListNULL then begin
       ForEach:=nil;
       {writeln('-cont-');     asm mov ah,8;int 21h;end;{}
       end
      else begin
       ForEach:=PopArg (Stack)^.UserEntry^.Next^.Next^.Next;
       {writeln('-ende-');     asm mov ah,8;int 21h;end;{}
       end;
     end
   else
   {jinak: hlasi chybu}
     ErrorSignal (Prg,Stack,4);
 end;

{****************************************************************************}

function ForDestructor;
 begin
   while (Stack^.Item=nil) or (Stack^.Item^.T <> cVar) do PopArg (Stack);
   PopArg (Stack); {Jeste ten var}
    {Var,to,from mozna v jinem poradi nebo listvar pro for each}
   ForDestructor:=nil;
 end;

{****************************************************************************}

function WhileCode; {na stack adresa pred endwhile,tesne pred gotocode na zacatek}
 var P : PData;
 begin
   P:=PopArg (Stack);
   if IsTrue (P) = 1 then WhileCode:=nil else begin
    P:=PopArg (Stack); WhileCode:=P^.UserEntry^.Next^.Next^.Next;
   end;
 end;

{****************************************************************************}

function ContinueCode;
 var P : PCode;
 begin
   P:=Stack^.Item; {Tak tady je ukazatel na konec cyklu type cUserCode pred gotocode na zacatek
                       a kdyz ne tak nejsme v cyklu}
   if P^.T <> cUserCode then begin ErrorSignal (Prg,Stack,3); Exit; end;
   ContinueCode:=P^.UserEntry^.Next;
 end;

{****************************************************************************}

function BreakCode;
 var P : PCode;
 begin
   P:=PopArg (Stack);
   if P^.T <> cUserCode then begin ErrorSignal (Prg,Stack,3); Exit; end;
   BreakCode:=P^.UserEntry^.Next^.Next^.Next;
 end;

{****************************************************************************}

function CallNoRetFunc;
 begin
   CallNoRetFunc:=CallFunc (NoRetZarazka,Prg,Stack);
 end;

function CallRetFunc;
 begin
   CallRetFunc:=CallFunc (Zarazka,Prg,Stack);
 end;

function CallFunc; {A volani funkce interne nebo externi,podle toho na co ukazuje prislusny identifikator na stacku}
 var F,Entry,P,Param,XV,LVars : PData;
     CouldRead : Boolean;
 begin
   {if Zaraz = nil then Zaraz:=Zarazka;}
   CallFunc:=nil; F:=PopArg (Stack);
   if (F^.T = cVar) and (F^.Value <> nil) then F:=F^.Value;
   if F^.T = cBinFunc then begin
      {WriteLn ('Ahoj',Seg (F^.Value^),' ',Ofs (F^.Value^));}
      CallFunc:=TFunction (F^.Value) (Prg,Stack);
      if Zaraz=NoRetZarazka then PopArg (Stack);
    end else begin
     if F^.T <> cFunc then begin ErrorSignal (Prg,Stack,1); Exit; end;
     Entry:=F^.Value^.Next;
     P:=Entry; LVars:=nil; XV:=LVars; CouldRead:=true;
     repeat {Vyber parametry a uloz je do prirazovacich prikazu,
             vygenerovanych na zacatku kazdeho bloku funkce,podle parametru v definici}
       if CouldRead then Param:=PopArg (Stack);
       if Param = nil then CouldRead:=false;
       if P^.Item=Zarazka then break; {Kvuli parametrum prijde z parsingu}
       PushArg (XV,P^.Item); {Var}
       if XV^.Next = nil then LVars:=XV;
       PushArg (XV,P^.Item^.Value); {Value}
       if Param <> nil then P^.Next^.Item:=Param else P^.Next^.Item:=NULL;
       P:=P^.Next^.Next^.Next;
     until false;
     while Param <> nil do Param:=PopArg (Stack);
     PushArg (Stack,Prg);
     PushArg (Stack,Zaraz); {Zarazka pro lokalni promene a parametry}
     {Add LVars to stack}
     if LVars <> nil then begin LVars^.Next:=Stack; Stack:=XV; end;
     PushArg (Stack,Zaraz); {!!!!} {Zarazka pro pripad neporadku na stacku napr kvuli cyklum}
     CallFunc:=Entry;
   end;
 end;

{****************************************************************************}

function RReturn; {Obnov globalni promene,odstran prebytecne hodnoty ze stacku a ven}
 var RetVal,P,G : PData;
 begin
   RetVal:=PopArg (Stack);
   while (Stack^.Item = nil) or (Stack^.Item^.T <> Zarazka^.T) do PopArg (Stack); {!!!!!}
   PopArg (Stack); {!!!!}
   while (Stack^.Item = nil) or (Stack^.Item^.T <> Zarazka^.T) do AssignLValue (Prg,Stack);
   P:=PopArg (Stack);
   G:=PopArg (Stack)^.Next; if G = nil then begin ErrorSignal (Prg,Stack,11); Exit; end;
   RReturn:=G;
   if P=Zarazka then PushArg (Stack,RetVal); {else p=NoRetZarazka - no ret}
 end;

{****************************************************************************}

function Return;
 var RetVal,P,G : PData;
 begin
   while (Stack^.Item = nil) or (Stack^.Item^.T <> Zarazka^.T) do PopArg (Stack); {!!!!}
   PopArg (Stack); {!!!!}
   while (Stack^.Item = nil) or (Stack^.Item^.T <> Zarazka^.T) do AssignLValue (Prg,Stack);
   P:=PopArg (Stack); if P=Zarazka then begin ErrorSignal (Prg,Stack,12); Exit; end;
   G:=PopArg (Stack)^.Next; if G = nil then begin ErrorSignal (Prg,Stack,11); Exit; end;
   Return:=G;
 end;

{****************************************************************************}

function Len;
 var D : PData;
 begin
   D:=GetFree; D^.T:=cInt;
   D^.Data.Int:=StrLen (PopArg (Stack)^.Data.StrC);
   PopArg (Stack); {nilova zarazka}
   PushArg (Stack,D); Len:=nil;
 end;

{****************************************************************************}

function Randik;
 var N,D : PData;
 begin
   N:=PopArg (Stack); {nilova zarazka}
   if N^.T <> cInt then ErrorSignal (Prg,Stack,7);
   D:=GetFree; D^.T:=cInt;
   D^.Data.Int:=Random(N^.Data.Int);
   PopArg (Stack); {nilova zarazka}
   PushArg (Stack,D); Randik:=nil;
 end;

{****************************************************************************}

function GetType;
 var D : PData;
 begin
   D:=GetFree; D^.T:=cInt;
   D^.Data.Int:=PopArg (Stack)^.T;
   PopArg (Stack); {nilova zarazka}
   PushArg (Stack,D); GetType:=nil;
 end;

{****************************************************************************}

function Gc; {Externi vyvolani GarbageCollectoru}
 begin
   GarbageCollector;
   {nechame tam nilovou zarazku}
   Gc:=nil; PushArg (Stack,nil); {!!!!}
 end;

{****************************************************************************}

function WriteFree;
 begin
   Statistic;
{   WriteLn ('Free nodes :',IsFree (Free));}
   WriteFree:=nil;
   {nechame tam nilovou zarazku}
 end;

{****************************************************************************}

function WriteVars;
 var V,XV : PData;
 begin
   V:=Vars;
   while V <> nil do begin
    XV:=Pop (V);
    Write ('Name :',XV^.Name^);
    {GotoXY (35,WhereY); }Write ('Typ :');
    case XV^.T of
     cFunc    : Write ('proc funkce');
     cBinFunc : Write ('bin funkce');
     cVar     : case XV^.Value^.T of
                 cNULL : Write ('NULL');
                 cInt  : Write ('cislo');
                 cPtr  : Write ('obecna data');
                 cStr  : Write ('string');
                end;
    end; WriteLn; ReadLN;
   end;
   {nechame tam nilovou zarazku}
   WriteVars:=nil;
 end;

{****************************************************************************}

function XDefine;
 var P,R : PData;
 begin
   P:=PopArg (Stack); PopArg (Stack);
   R:=GetFree; R^.T:=cInt;
   if P = NULL then R^.Data.Int:=0
    else R^.Data.Int:=1;
   PushArg (Stack,R);
   XDefine:=nil;
 end;

{****************************************************************************}

function Terminate (var Prg,Stack : PData) : PData;
 begin
   Prg:=nil; Terminate:=nil;
 end;

{****************************************************************************}

function XStrPos (var Prg,Stack : PData) : PData;
 var W,P,R : PData; Pos : PChar;
 begin
   W:=PopArg (Stack); P:=PopArg (Stack); PopArg (Stack);
   R:=GetFree; R^.T:=cInt; PushArg (Stack,R);
   Pos:=StrPos (P^.Data.StrC,W^.Data.StrC);
   if Pos = nil then R^.Data.Int:=-1 else  R^.Data.Int:=Pos-P^.Data.StrC;
   XStrPos:=nil;
 end;

{****************************************************************************}

function XStrCopy (var Prg,Stack : PData) : PData;
 var W,F,L,R : PData;
 begin
   W:=PopArg (Stack); F:=PopArg (Stack); L:=PopArg (Stack); PopArg (Stack);
   R:=GetFree; R^.T:=cStr; PushArg (Stack,R);
   R^.Data.StrL:=L^.Data.Int+1;
   GetMem (R^.Data.StrC,R^.Data.StrL);
   StrLCopy (R^.Data.StrC,W^.Data.StrC+F^.Data.Int,L^.Data.Int);
   XStrCopy:=nil;
 end;

{****************************************************************************}

function XUpString (var Prg,Stack : PData) : PData;
 var W,R : PData; P : PChar;
 begin
   W:=PopArg (Stack); PopArg (Stack); P:=W^.Value^.Data.StrC;
   while P^ <> #0 do begin P^:=UpCase (P^); Inc (P) end;
   PushArg (Stack,W^.Value);
   XUpString:=nil;
 end;

{****************************************************************************}

function InitCode;
 begin
   RunCode:=0;
   InitCode:=nil;
 end;

function DoneCode;
 begin
   RunCode:=cDone; {WriteLn ('Doneing...'); readln;}
   DoneCode:=nil;
 end;

{****************************************************************************}

function DebugInfoCode;
 var V,L : PData; LS : String;
 begin
   L:=PopArg (Stack); V:=PopArg (Stack);
   Str (Integer (L^.Data.Int and Not (cBP)),LS);
   _ActiveScr:=V^.Name^; _ActiveLine:=L^.Data.Int and Not (cBP);
   if _ActiveLine=0 then _ActiveLine:=1;
   _ErrLine:=V^.Name^ + ' :' + LS;
   if (L^.Data.Int and cBP <> 0) or (RunFlags and cTrace <> 0) then begin
    StopCode (Prg,Stack);
   end;
   DebugInfoCode:=nil;
 end;

{****************************************************************************}

function RVar;
 var V : PData;
 begin
   V:=PopArg (Stack);
   if (V = nil) or (V^.T <> cVar) then Exit;
   RemoveVar (V^.Name^);
   RVar:=nil;
 end;

function GlobalVar;
 var V,BV : PData;
 begin
   GlobalVar:=nil; V:=PopArg (Stack);
   if (V = nil) or Not (V^.T in [cVar,cFunc,cBinFunc]) then Exit;
   BV:=FindBeforeVar (V^.Name^); if BV=OldVars then Exit;
   if BV=Vars then Vars:=Vars^.Next
    else BV^.Next:=BV^.Next^.Next;
   BV^.Next:=OldVars^.Next; OldVars^.Next:=BV;
 end;

{****************************************************************************}

function NoCode;
 begin
   NoCode:=nil; PushArg (Stack,nil);
 end;

{****************************************************************************}

function Halt;
 begin
   RunCode:=cHalt; Prg:=nil;
   Halt:=nil;
 end;

function StopCode;
 begin
   PushArg (Stack,Prg); Prg:=nil;
   RunCode:=cStop;
   StopCode:=nil;
 end;

function ContCode;
 begin
   Prg:=PopArg (Stack)^.Next; ContCode:=nil;
 end;

end.