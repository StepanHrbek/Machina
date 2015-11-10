Unit MyPars;{$i define.inc}            {Analyza predlozeneho textu}

{$IFNDEF DPMI} {$IFNDEF WINDOWS} {$DEFINE REAL} {$ENDIF} {$ENDIF}

interface
uses MyDefin,MyDef;

function ADebugInfo (var Src : PChar; var Prg : PData; Info : PData) : PCode;
function AWSpaces (var Src : PChar; var Prg : PData; Info : PData) : PCode;
function AArrDef (var Src : PChar; var Prg : PData; Info : PData) : PCode;
function AArrVal (var Src : PChar; var Prg : PData; Info : PData) : PCode;
function AExpr (var Src : PChar; var Prg : PData; Info : PData) : PCode;
function APrg (var Src : PChar; var Prg : PData; Info : PData) : PCode;
function AString (var Src : PChar; var Prg : PData; Info : PData) : PCode;
function AList (var Src : PChar; var Prg : PData; Info : PData) : PCode;
function ANumber (var Src : PChar; var Prg : PData; Info : PData) : PCode;
function APlus (var Src : PChar; var Prg : PData; Info : PData) : PCode;
function AMinus (var Src : PChar; var Prg : PData; Info : PData) : PCode;
function AMul (var Src : PChar; var Prg : PData; Info : PData) : PCode;
function ADiv (var Src : PChar; var Prg : PData; Info : PData) : PCode;
function AMod (var Src : PChar; var Prg : PData; Info : PData) : PCode;
function AOr (var Src : PChar; var Prg : PData; Info : PData) : PCode;
function AXor (var Src : PChar; var Prg : PData; Info : PData) : PCode;
function AAnd (var Src : PChar; var Prg : PData; Info : PData) : PCode;
function ANot (var Src : PChar; var Prg : PData; Info : PData) : PCode;
function ALessMore (var Src : PChar; var Prg : PData; Info : PData) : PCode;
function ALParen (var Src : PChar; var Prg : PData; Info : PData) : PCode;
function APtr (var Src : PChar; var Prg : PData; Info : PData) : PCode;
function APtrCont (var Src : PChar; var Prg : PData; Info : PData) : PCode;
function AExprIdent (var Src : PChar; var Prg : PData; Info : PData) : PCode;
function AAssign (var Src : PChar; var Prg : PData; Info : PData) : PCode;
function AIf (var Src : PChar; var Prg : PData; Info : PData) : PCode;
function AWhile (var Src : PChar; var Prg : PData; Info : PData) : PCode;
function AFor (var Src : PChar; var Prg : PData; Info : PData) : PCode;
function ABreak (var Src : PChar; var Prg : PData; Info : PData) : PCode;
function AContinue (var Src : PChar; var Prg : PData; Info : PData) : PCode;
function ADefFunc (var Src : PChar; var Prg : PData; Info : PData) : PCode;
function ACallFunc (var Src : PChar; var Prg : PData; Info : PData) : PCode;
function ARet (var Src : PChar; var Prg : PData; Info : PData) : PCode;
function AHalt (var Src : PChar; var Prg : PData; Info : PData) : PCode;
function AStop (var Src : PChar; var Prg : PData; Info : PData) : PCode;
function ACont (var Src : PChar; var Prg : PData; Info : PData) : PCode;
procedure GiveError (Src : PChar);
procedure Error (I : Integer; AES : PChar);

function ErrS : String; {$IFNDEF REAL} export; {$ENDIF}
function ErrMess : String; {$IFNDEF REAL} export; {$ENDIF}

const _ErrS : String = '';
const _ErrMess : String = '';

implementation

uses MyCode,MyFunc,MyVars,Strings{$IFDEF DPMI} ,WinAPI {$ENDIF}
{$IFDEF WINDOWS} ,WinProcs {$ENDIF};

function ErrS : String; begin ErrS:=_ErrS; end;
function ErrMess : String; begin ErrMess:=_ErrMess; end;

procedure WriteErr (EC : Integer);
 var I  : Integer; S : String;
 begin
   case EC of
    1 : S:='Neocekavany operator';
    2 : S:='Chybi prava zavorka';
    3 : S:='Chybi leva zavorka';
    4 : S:='Ocekavan identifikator';
    5 : S:='Chybi klicove slovo :' + _ErrS;
    6 : S:='Ocekavan vyraz';
    7 : S:='Neznamy identifikator';
    8 : S:='Identifikator neni funkce';
    9 : S:='Neukonceny string';
    10 : S:='Chybi endif';
    12 : S:='Ocekavan konec seznamu - ]';
    13 : S:='Identifikator nepopisuje funkci';
    14 : S:='Nelze prirazovat hodnoty identifikatoru funkce';
    15 : S:='Ocekavano ENDWHILE';
    16 : S:='Index pole lze pouzit jen po lvalue';
    17 : S:='Po extern musi nasledovat string se jmenem dll ve ktere je funkce definovana';
    18 : S:='Soubor DLL nelze nacist';
    19 : S:='Funkce neni z DLL dostupna';
    20 : S:='Nelze pouzit samostatny vyraz';
    30 : S:='Chybi druhy operand';
    31 : S:='Seznamu obsahuje nespravny vyraz';
    255 : S:='Neocekavany vyraz'
    else S:='';
   end;
   if ErrSrc <> nil then begin
    _ErrMess:='Src:';
    {
    I:=-2; while (i>-150) and (ErrSrc+i > Src) and ((ErrSrc+I+2)^ <> '~') do Dec (I);
    repeat
      _ErrMess:=_ErrMess+(ErrSrc+I)^;
      Inc (I);
    until i=0;
   end else _ErrMess:='';
   _ErrMess:=_ErrMess + #13#10 + S;
    }
    I:=-2; while (ErrSrc > Src) and ((ErrSrc+I+2)^ <> '~') do Dec (I);
    repeat
      Inc (I); _ErrMess:=_ErrMess+(ErrSrc+I)^;
    until ((ErrSrc+I)^ in [#0,#13,#10]);
   end else _ErrMess:='';
   _ErrMess:=_ErrMess + #10 + S;
 end;

procedure Error (I : Integer; AES : PChar);
 begin
   if ErrCode <> 0 then Exit;
   ErrCode:=I; ErrSrc:=AES;
   WriteErr (ErrCode);
 end;

function KeyWord (S : String) : Boolean;
 const MK = 20;
 const KW : Array [1..MK] of String[8] = (
  'FOR','FROM','TO','IF','THEN','ELSE','ENDIF','ENDFOR','ENDPROC','WHILE','ENDWHILE','PROC',
  'CONTINUE','BREAK','PRIVATE','RETURN','HALT','STOP','CONT','EACH');
 var X : Integer;
 begin
   for X:=1 to MK do
    if UpString (S) = KW [X] then
     begin KeyWord:=true; Exit; end;
   KeyWord:=false;
 end;

{****************************************************************************}

function TestIdent (Src : PChar) : String; {Vyzkousi zda nasleduje identifikator}
 var S : String;
 begin
   S:=''; if Not (Src^ in ['0'..'9']) then
    while UpCase (Src^) in ['_','A'..'Z','0'..'9'] do begin S:=S+Src^; Inc (Src); end;
   TestIdent:=S;
 end;

{****************************************************************************}

const
  LineIdent : String = '{' + LineMagic + '}';

function AWSpaces; {Vynecha mezery entery ...}
 var Left : Integer;

 begin
   {if CheckerSet <> nil then TCheckerProc (CheckerSet) (Src-MyDefin.Src);}

   while Src^ in [' ',#13,#10] do Inc (Src);
   AWSpaces:=Prg;
   if Src^='{' then begin Left:=0;
    if ((Src+1)^=LineMagic) and ((Info=nil) or
       (Info^.State and cAllSpaces = 0)) then begin AWSpaces:=nil; Exit; end;
    repeat
     case Src^ of
      '{' : Inc (Left);
      '}' : Dec (Left);
     end;
     Inc (Src);
    until Left=0;
    AWSpaces:=AWSpaces (Src,Prg,Info); {!!!Pozor na #0}
   end;
   if Src^ <> #0 then AWSpaces:=nil;
 end;

function ADebugInfo;
 procedure DebugInfoCoding;
  var V,P,Le : PData; N,L : String; Line,Err : Integer;
  begin
    N:=Copy (LineIdent,3,Pos ('|',LineIdent)-3);
    L:=Copy (LineIdent,Length (N)+4,Length (LineIdent)-Length (N)-4);
    if Pos ('.',N) > 0 then Delete (N,Pos ('.',N),Length (N)-Pos ('.',N)+1);
    V:=RegisterVar (N,@Vars);
    Val (L,Line,Err); Le:=GetFree; Le^.T:=cInt; Le^.Data.Int:=Line;
    PushArg (Prg,V); PushArg (Prg,Le);
    P:=GetFree; P^.T:=cCode; P^.Entry:=@DebugInfoCode;
    PushArg (Prg,P);
  end;
 begin
   ADebugInfo:=nil;
   if (Src^<>'{') or ((Src+1)^<>LineMagic) then Exit;
   LineIdent:='{';
   repeat Inc (Src); LineIdent:=LineIdent + Src^; until Src^ = '}';
   Inc (Src); if DebugInfo then DebugInfoCoding;
   ADebugInfo:=Prg; {Prg muze byt nil}
 end;

{****************************************************************************}

function AArrDef;
 var P,V : PData;
     D : TData;
     S : String;
 begin
   AArrDef:=nil;
   if ErrCode <> 0 then Exit;
   if Not (StrCheck (Src,'ARRAY ')) then Exit;
   Inc (Src,5); AWSpaces (Src,Prg,nil);
   S:=TestIdent (Src); if (S = '') or KeyWord (S) then begin Error (4,Src); Exit; end;
   V:=RegisterVar (S,@Vars); PushArg (Prg,V); Inc (Src,Length (S));
   AWSpaces (Src,Prg,nil); if Src^ <> '[' then begin _ErrS:='['; Error (5,Src); Exit; end;
   Inc (Src); D.State:=0; D.Prior:=0;
   if AExpr (Src,Prg,@D) = nil then begin Error (6,Src); Exit; end;
   AWSpaces (Src,Prg,nil); if Src^ <> ']' then begin _ErrS:=']'; Error (5,Src); Exit; end;
   Inc (Src);
   P:=GetFree; P^.T:=cCode; P^.Entry:=@MakeArray; PushArg (Prg,P); AArrDef:=P;
 end;

{****************************************************************************}

function ANumber; {Je tam cislo}
 var P : PData; {Pozor kdyz se prohodi P a N vede k potizim u B.scr}
     N : LongInt;
     OK : Boolean;
 begin
   ANumber:=nil; N:=0;
   if ErrCode <> 0 then Exit;
   if ((Info^.State and cWasParam) <> 0) then Exit;
   if ((Info^.State and cLValue) <> 0) then Exit;
   OK:=false;
   while Src^ in ['0'..'9'] do begin
    N:=Abs (N*10+Ord (Src^)-48);
    Inc (Src); OK:=true;
   end;
   if Not (OK) then Exit;
   Info^.State:=Info^.State or cWasParam; {Poznamenej ze bylo cislo}
   P:=GetFree; with P^ do begin T:=cInt; Handle:=1; Data.Int:=N; end;
   PushArg (Prg,P); ANumber:=P; {A uloz ho jako parametr do programu (Prg stacku)}
 end;

{****************************************************************************}

function AString; {Je tam string}
 var S : String;
     PC : PChar;
     P : PData;
 begin
   AString:=nil; PC:=Src; S:='';
   if ErrCode <> 0 then Exit;
   if ((Info^.State and cWasParam) <> 0) then Exit;
   if (PC^<>'"') then Exit;
   Inc (PC);
   while Not (PC^ in [#13,#10,'"']) do begin
    if PC^='\' then begin
     Inc (PC);
     case PC^ of
      'n' : S:=S+#10;
      'r' : S:=S+#13;
      '\' : S:=S+'\';
      '"' : S:=S+'"';
      else S:=S+PC^;
     end;
    end else S:=S+PC^; Inc (PC);
   end;
   if (PC^ <> '"') then begin Error (9,PC); Exit; end;
   Info^.State:=Info^.State or cWasParam;
   P:=GetFree; with P^ do begin T:=cStr; Handle:=1; GetMem (Data.StrC,Length (S)+1); Data.StrL:=Length (S)+1;
   StrPCopy (Data.StrC,S); end;
   PushArg (Prg,P); AString:=P; Src:=PC+1; {Sup s nim na stack}
 end;

{****************************************************************************}

function AList;
 var
   L : PData;
   E : TData;
begin
   AList:=nil;
   if ErrCode <> 0 then Exit;
   if ((Info^.State and cWasParam) <> 0) then Exit;
   if ((Info^.State and cLValue) <> 0) then Exit;
   if (Src^<>'[') then Exit;
   L:=GetFree; L^.T:=cCode; L^.Entry:=@MakeList;
   PushArg (Prg,nil); Inc (Src);
   while (Src^<>']') do begin
     E.State:=cAllSpaces; E.Prior:=0; AWSpaces (Src,Prg,@E);
     E.State:=0; E.Prior:=0; if AExpr (Src,Prg,@E) = nil then begin Error (31,Src); Exit end;
     E.State:=cAllSpaces; E.Prior:=0; AWSpaces (Src,Prg,@E);
     if Src^ <> ',' then break else Inc (Src);
   end;
   if Src^ <> ']' then begin Error (12,Src); Exit; end;
   Inc (Src); Info^.State:=Info^.State or cWasParam; {Poznamenej ze byl param,aby se nectlo dal}
   PushArg (Prg,L); AList:=L;
 end;

{****************************************************************************}

function APlus; {Byl parametr,je tam + a nasleduje vyraz? - ano prida prislusne instrukce na prg stack}
 var
   P,D : PData;
   E : TData;
 begin
   APlus:=nil;
   if ErrCode <> 0 then Exit;
   if Src^<>'+' then Exit;
   if (Info^.State and cWasParam <> 0) and (Info^.Prior<{=}5) then begin {neni na zacatku}
    {Na Prg stacku uz mame jeden parametr}
    E.State:=0; E.Prior:=5; Inc (Src); AExpr (Src,Prg,@E); {Prida dalsi parametr}
    P:=GetFree; P^.T:=cCode; P^.Entry:=@Plus; {A zpracovani funkci Plus}
    PushArg (Prg,P); APlus:=P;
   end else Info^.State:=Info^.State or cEx;
 end;

{****************************************************************************}

function AMinus; {Dava pozor na vyrazy typu ----5*--3-3}
 var
   P,D : PData;
   E : TData;
 begin
   AMinus:=nil;
   if ErrCode <> 0 then Exit;
   if Src^<>'-' then Exit;
   if Info^.State and cWasParam = 0 then begin {A to je unarni minus}
    P:=GetFree; P^.T:=cInt; P^.Data.Int:=-1; PushArg (Prg,P);
    Inc (Src); E.State:=0; E.Prior:=7;
    if AExpr (Src,Prg,@E) = nil then begin Error (6,Src); Exit; end;
    P:=GetFree; P^.T:=cCode; P^.Entry:=@Mul; PushArg (Prg,P);
    Info^.State:=Info^.State or cWasParam;
    AMinus:=P;
   end else
   if Info^.Prior<5 then begin {neni na zacatku}
    E.State:=0; E.Prior:=5; Inc (Src); AExpr (Src,Prg,@E);
    P:=GetFree; P^.T:=cCode; P^.Entry:=@Minus;
    PushArg (Prg,P); AMinus:=P;
   end else Info^.State:=Info^.State or cEx;
 end;

{****************************************************************************}

function ANot;
 var P : PCode; E : TData;
 begin
   ANot:=nil;
   if ErrCode <> 0 then Exit;
   if Src^<>'!' then Exit;
   if Info^.State and cWasParam <> 0 then begin Error (1,Src); Exit; end;
   if (Info^.Prior<{=}9) then begin {neni na zacatku}
    E.State:=0; E.Prior:=9; Inc (Src); AExpr (Src,Prg,@E);
    P:=GetFree; P^.T:=cCode; P^.Entry:=@Notik;
    PushArg (Prg,P); ANot:=P;
    Info^.State:=Info^.State or cWasParam;
   end else Info^.State:=Info^.State or cEx;
 end;

{****************************************************************************}

function AMul;
 var P : PCode; E : TData;
 begin
   AMul:=nil;
   if ErrCode <> 0 then Exit;
   if Src^<>'*' then Exit;
   if Info^.State and cWasParam = 0 then begin Error (1,Src); Exit; end;
   if (Info^.State and cWasParam <> 0) and (Info^.Prior<{=}7) then begin {neni na zacatku}
    E.State:=0; E.Prior:=7; Inc (Src); AExpr (Src,Prg,@E);
    P:=GetFree; P^.T:=cCode; P^.Entry:=@Mul;
    PushArg (Prg,P); AMul:=P;
   end else Info^.State:=Info^.State or cEx;
 end;

{****************************************************************************}

function ADiv;
 var P : PCode; E : TData;
 begin
   ADiv:=nil;
   if ErrCode <> 0 then Exit;
   if Src^<>'/' then Exit;
   if Info^.State and cWasParam = 0 then begin Error (1,Src); Exit; end;
   if (Info^.State and cWasParam <> 0) and (Info^.Prior<{=}7) then begin {neni na zacatku}
    E.State:=0; E.Prior:=7; Inc (Src); AExpr (Src,Prg,@E);
    P:=GetFree; P^.T:=cCode; P^.Entry:=@DivCode;
    PushArg (Prg,P); ADiv:=P;
   end else Info^.State:=Info^.State or cEx;
 end;

{****************************************************************************}

function AMod;
 var P : PCode; E : TData;
 begin
   AMod:=nil;
   if ErrCode <> 0 then Exit;
   if Src^<>'%' then Exit;
   if Info^.State and cWasParam = 0 then begin Error (1,Src); Exit; end;
   if (Info^.State and cWasParam <> 0) and (Info^.Prior<{=}7) then begin {neni na zacatku}
    E.State:=0; E.Prior:=7; Inc (Src); AExpr (Src,Prg,@E);
    P:=GetFree; P^.T:=cCode; P^.Entry:=@ModCode;
    PushArg (Prg,P); AMod:=P;
   end else Info^.State:=Info^.State or cEx;
 end;

{****************************************************************************}

function AOr;
 var P : PCode; E : TData;
 begin
   AOr:=nil;
   if ErrCode <> 0 then Exit;
   if Src^<>'|' then Exit;
   if Info^.State and cWasParam = 0 then begin Error (1,Src); Exit; end;
   if (Info^.State and cWasParam <> 0) and (Info^.Prior<{=}5) then begin {neni na zacatku}
    E.State:=0; E.Prior:=5; Inc (Src); AExpr (Src,Prg,@E);
    P:=GetFree; P^.T:=cCode; P^.Entry:=@XOrX;
    PushArg (Prg,P); AOr:=P;
   end else Info^.State:=Info^.State or cEx;
 end;

{****************************************************************************}

function AXor;
 var P : PCode; E : TData;
 begin
   AXor:=nil;
   if ErrCode <> 0 then Exit;
   if Src^<>'$' then Exit;
   if Info^.State and cWasParam = 0 then begin Error (1,Src); Exit; end;
   if (Info^.State and cWasParam <> 0) and (Info^.Prior<{=}5) then begin {neni na zacatku}
    E.State:=0; E.Prior:=5; Inc (Src); AExpr (Src,Prg,@E);
    P:=GetFree; P^.T:=cCode; P^.Entry:=@XXorX;
    PushArg (Prg,P); AXor:=P;
   end else Info^.State:=Info^.State or cEx;
 end;

{****************************************************************************}

function AAnd;
 var P : PCode; E : TData;
 begin
   AAnd:=nil;
   if ErrCode <> 0 then Exit;
   if Src^<>'&' then Exit;
   if Info^.State and cWasParam = 0 then begin Error (1,Src); Exit; end;
   if (Info^.State and cWasParam <> 0) and (Info^.Prior<{=}6) then begin {neni na zacatku}
    E.State:=0; E.Prior:=6; Inc (Src); AExpr (Src,Prg,@E);
    P:=GetFree; P^.T:=cCode; P^.Entry:=@XAndX;
    PushArg (Prg,P); AAnd:=P;
   end else Info^.State:=Info^.State or cEx;
 end;

{****************************************************************************}

function ALessMore;
 var P,OldPrg : PCode; E : TData;
 begin
   ALessMore:=nil; OldPrg:=Prg;
   if ErrCode <> 0 then Exit;
   if Not (Src^ in ['<','>','=','!']) then Exit; {Neni <,ani >}
   if (Src^ in ['=','!']) and ((Src+1)^<>'=') then Exit;
   if (Info^.State and cWasParam <> 0) and (Info^.Prior<{=}2) then begin {neni na zacatku}
    P:=GetFree; P^.T:=cCode;
    case Src^ of
     '<' : if (Src+1)^ = '=' then P^.Entry:=@LessEqu else P^.Entry:=@Less;
     '>' : if (Src+1)^ = '=' then P^.Entry:=@MoreEqu else P^.Entry:=@More;
     '=' : begin P^.Entry:=@IsSame; Inc (Src); end;
     '!' : begin P^.Entry:=@NotSame; Inc (Src); end;
    end;
    E.State:=0; E.Prior:=2; Inc (Src); if Src^='=' then Inc (Src);
    AWSpaces (Src,Prg,nil);
    if AExpr (Src,Prg,@E) = nil then begin Error (30,Src); Prg:=OldPrg; Exit; end;
    PushArg (Prg,P); ALessMore:=P;
   end else Info^.State:=Info^.State or cEx;
 end;

{****************************************************************************}

function ALParen; {A leva zavorka - zaciname Expr od znova}
 var
   D : TData;
 begin
   ALParen:=nil;
   if ErrCode <> 0 then Exit;
   if Src^<>'(' then Exit;
   if Info^.State and cWasParam <> 0 then Exit;
   Inc (Src); D.State:=0; D.Prior:=0;
   {if} AExpr (Src,Prg,@D);{ = nil then begin
    Error (6,Src); Exit; end;} {Analyza Expr od zacatku,kdyz narazi na ) zastavi se, protoze ho nezna}
   if Src^<>')' then begin Error (2,Src); Exit; end;
   Info^.State:=Info^.State or cWasParam; Inc (Src);
   ALParen:=Prg;
 end;

{****************************************************************************}

function APtr;
 var S : String;
     V : PData;
 begin
   APtr:=nil;
   if Src^<>'@' then Exit;
   {Inc (Src);}
   if Info^.State and cWasParam <> 0 then Exit;
   S:=TestIdent (Src+1); if (S = '') or KeyWord (S) then begin Error (4,Src); Exit; end;
   V:=RegisterVar (S,@Vars); PushArg (Prg,V);
   Info^.State:=Info^.State or cWasParam;
   {Info^.State:=Info^.State or cWasPtr;}
   APtr:=Prg; Inc (Src,1+Length (S));
 end;

{****************************************************************************}

function APtrCont; {!!! neni jeste dotazeno nefunguje X^^}
 var D : TData;
     V,P : PData;
 begin
   APtrCont:=nil;
   if Info^.State and cWasLValue = 0 then Exit; {Musi predchazet lvalue}
   if Src^<>'^' then Exit;
   Inc (Src);
   {if Info^.State and cLValue = 0 then begin}
    P:=GetFree; P^.T:=cCode; P^.Entry:=@GetVar; PushArg (Prg,P); {end;}
   Info^.State:=Info^.State or cWasParam or cWasLValue;
   APtrCont:=P;
 end;

{****************************************************************************}

function AExprIdent;
 var P,V : PData;
     S : String;

 begin
   AExprIdent:=nil;
   if ErrCode <> 0 then Exit;
   if (Info^.State and cWasParam) <> 0 then Exit;
   if (Info^.State and cWasLValue) <> 0 then Exit;
   S:=TestIdent (Src); if (S = '') or KeyWord (S) then Exit;
   Inc (Src,Length (S));
   V:=RegisterVar (S,@Vars); PushArg (Prg,V);
   {if Info^.State and cLValue = 0 then begin}
     P:=GetFree; P^.T:=cCode; P^.Entry:=@GetVar; PushArg (Prg,P); {Vezmi hodnotu promene}
     if Info^.State and cLValue = 0 then Info^.State:=Info^.State or cWasParam;
   {end;}
   Info^.State:=Info^.State or cWasLValue;
   AExprIdent:=P;
 end;

{****************************************************************************}

function AArrVal;
 var P,V : PData; D : TData;
     S : String; PC : PChar;
 begin
   AArrVal:=nil;
   if ErrCode <> 0 then Exit;
   if Src^<>'[' then Exit else Inc (Src);
   if Info^.State and cWasLValue = 0 then begin Error (16,Src); Exit; end;
   D.State:=0; D.Prior:=0;
   AWSpaces (Src,Prg,nil); if AExpr (Src,Prg,@D) = nil then begin Error (6,Src); Exit; end;
   AWSpaces (Src,Prg,nil); if Src^ <> ']' then begin _ErrS:=']'; Error (5,Src); Exit; end;
   Inc (Src);
   if Info^.State and cLValue <> 0 then Info^.State:=Info^.State or cWasLValue
    else Info^.State:=Info^.State or cWasParam;
   P:=GetFree; P^.T:=cCode; P^.Entry:=@GetArrVal; PushArg (Prg,P);
   AArrVal:=P;
 end;

{****************************************************************************}

function ACallFunc; {Volani funkce,osetri parametry}
 var XPC : PChar;
     F,P : PData;
     S : String;

     procedure ImmLocVars; {Prida na stack vyhodnoceni jednotlivych parametru}
      var D : TData; XPrg,PPrg : PData;
      begin
        AWSpaces (Src,Prg,nil); if (Src^) = ')' then Exit;
        D.State:=0; D.Prior:=0; XPrg:=nil;
        if AExpr (Src,XPrg,@D) = nil then Exit;
        if Src^ = ',' then begin Inc (Src); ImmLocVars; end;
        PPrg:=XPrg;
        while PPrg^.Next <> nil do Pop (PPrg);
        PPrg^.Next:=Prg; Prg:=XPrg;
      end;

 begin
   ACallFunc:=nil;
   if ErrCode <> 0 then Exit;
   if (Info^.State and cWasLValue = 0) and (Info^.State and cWasParam = 0) then Exit;
   if Src^<>'(' then Exit;

   PopArg (Prg); {to je @getvar}
   F:=Prg;
   while Not (Prg^.Item^.T in [cVar,cBinFunc,cFunc]) do Prg:=Prg^.Next;
   P:=Prg; Prg:=Prg^.Next;

   PushArg (Prg,nil);
   Inc (Src);

   ImmLocVars; if ErrCode <> 0 then Exit;
   if Src^<>')' then begin Error (2,Src); Exit; end;
   Inc (Src);

   P^.Next:=Prg; Prg:=F;

   P:=GetFree; P^.T:=cCode;
   if Info^.State and cLValue <> 0 then P^.Entry:=@CallNoRetFunc
    else P^.Entry:=@CallRetFunc;
   PushArg (Prg,P);
   if (Info^.State and cLValue = 0) then Info^.State:=Info^.State or cWasParam
    else Info^.State:=Info^.State or cEx;{!!!!!!!!!}
   ACallFunc:=P; Info^.State:=Info^.State and Not (cWasLValue); {!!!!!!!!!}
 end;

{****************************************************************************}

function AExpr; {Tady se zkousi vsechno mozne co patri k vyhodnoceni vyrazu}
 var
   Param : PData;
   Suc,WS : Boolean;
   P : PCode;
 begin
   AExpr:=nil; WS:=false; {Info^.State:=Info^.State or cRetValue;}
   if ErrCode <> 0 then Exit;
   repeat
     AWSpaces (Src,Prg,Info);
     Suc:=(ANumber (Src,Prg,Info)<>nil);
     Suc:=Suc or (AList (Src,Prg,Info)<>nil);
     Suc:=Suc or (AArrVal (Src,Prg,Info)<>nil);
     Suc:=Suc or (APtr (Src,Prg,Info)<>nil);
     Suc:=Suc or (APtrCont (Src,Prg,Info)<>nil);
     Suc:=Suc or (AString (Src,Prg,Info)<>nil);
     Suc:=Suc or (ALessMore (Src,Prg,Info)<>nil);
     Suc:=Suc or (ANot (Src,Prg,Info)<>nil);
     Suc:=Suc or (AMul (Src,Prg,Info)<>nil);
     Suc:=Suc or (ADiv (Src,Prg,Info)<>nil);
     Suc:=Suc or (AMod (Src,Prg,Info)<>nil);
     Suc:=Suc or (AXor (Src,Prg,Info)<>nil);
     Suc:=Suc or (AOr (Src,Prg,Info)<>nil);
     Suc:=Suc or (AAnd (Src,Prg,Info)<>nil);
     Suc:=Suc or (APlus (Src,Prg,Info)<>nil);
     Suc:=Suc or (AMinus (Src,Prg,Info)<>nil);
     Suc:=Suc or (ACallFunc (Src,Prg,Info)<>nil);
     Suc:=Suc or (ALParen (Src,Prg,Info)<>nil);
     Suc:=Suc or (AAssign (Src,Prg,Info)<>nil);
     {Suc:=Suc or (AAssignArr (Src,Prg,Info) <> nil);}
     Suc:=Suc or (AExprIdent (Src,Prg,Info)<>nil);
     WS:=WS or Suc;
   until Not (Suc) or (Info^.State and cEx<>0) or (Src^=#0);
   {Info^.State:=Info^.State xor cRetValue;}
   if (Info^.State and cLValue <> 0) and
      (Info^.State and cWasLValue <> 0) then Error (20,Src) {!!!!!!!!!}
    else if WS and (ErrCode = 0) then AExpr:=Prg;
 end;

{****************************************************************************}

function AAssign; {Prirazeni promene}
 var P,V : PData;
     D : TData;
 begin
   AAssign:=nil;
   if ErrCode <> 0 then Exit;
   if Src^ <> '=' then Exit;
   if Info^.State and cLValue = 0 then Exit; {Jsem uvnitr vyrazu}
   if Info^.State and cWasLValue = 0 then begin Error (20,Src); Exit; end;
   if Prg^.Item^.T in [cFunc,cBinFunc] then begin Error (14,Src); Exit; end;
   P:=PopArg (Prg);
   Inc (Src); D.State:=0; D.Prior:=0; AExpr (Src,Prg,@D);
   P^.Entry:=@AssignLValue; {misto @GetVar}
   PushArg (Prg,P); Info^.State:=cEx; AAssign:=P;
   Info^.State:=Info^.State and Not (cWasLValue); {!!!!!!!!!}
 end;

{****************************************************************************}

function AIf; {Analyza If nemusi obsahovat [else]}
 var P,G,OC,EC : PCode;
     D : TData;
 begin
   AIf:=nil;
   if ErrCode <> 0 then Exit;
   if Not (StrCheck (Src,'IF ')) then Exit;
   Inc (Src,2); D.State:=0; D.Prior:=0; AExpr (Src,Prg,@D);
   AWSpaces (Src,Prg,nil); if Not (StrCheck (Src,'THEN')) then begin _ErrS:='THEN'; Error (5,Src); Exit; end;
   Inc (Src,4); EC:=GetFree; EC^.T:=cUserCode; PushArg (Prg,EC); {goto endif}
   OC:=GetFree; OC^.T:=cUserCode; PushArg (Prg,OC); {goto else - pouziva se pri provadeni ifu}
   P:=GetFree; P^.T:=cCode; P^.Entry:=@IfCode;
   PushArg (Prg,P); APrg (Src,Prg,@D);

   AWSpaces (Src,Prg,nil); if StrCheck (Src,'ELSE') then begin {Mame else kod}
    PushArg (Prg,EC); G:=GetFree; G^.T:=cCode; G^.Entry:=@GotoCode; PushArg (Prg,G);
    Inc (Src,4); OC^.UserEntry:=Prg; APrg (Src,Prg,@D);
   end else OC^.UserEntry:=nil;
   EC^.UserEntry:=Prg;
   AWSpaces (Src,Prg,nil);
   if Not (StrCheck (Src,'ENDIF')) then begin Error (10,Src-1); Exit; end;
   AIf:=P; Inc (Src,5);
 end;

{****************************************************************************}

function AWhile;
 var D : TData;
     Start,P,G : PData;
 begin
   AWhile:=nil;
   if ErrCode <> 0 then Exit;
   if Not (StrCheck (Src,'WHILE ')) then Exit;
   Inc (Src,5); AWSpaces (Src,Prg,nil);
   D.State:=0; D.Prior:=0;
   G:=GetFree; G^.T:=cUserCode; PushArg (Prg,G); {Kod pro skok tesne pred endwhile bude
                                                  na stacku k dispozici pro break a continue}
   Start:=Prg;
   if AExpr (Src,Prg,@D) = nil then begin Error (6,Src); Exit; end;
   P:=GetFree; P^.T:=cCode; P^.Entry:=@WhileCode; PushArg (Prg,P);
   D.State:=0; D.Prior:=0; APrg (Src,Prg,@D);
   AWSpaces (Src,Prg,nil);
   if Not (StrCheck (Src,'ENDWHILE')) then begin Error (15,Src); Exit; end;
   G^.UserEntry:=Prg;
   P:=GetFree; P^.T:=cUserCode; P^.UserEntry:=Start; PushArg (Prg,P);
   P:=GetFree; P^.T:=cCode; P^.Entry:=@GotoCode; PushArg (Prg,P);
   Inc (Src,8); AWhile:=Prg;
 end;

{****************************************************************************}

function AFor;
 var Each : Boolean;
     Start,V,P,G : PCode;
     D : TData;
     S : String;

 begin
   AFor:=nil;
   if ErrCode <> 0 then Exit;
   if Not (StrCheck (Src,'FOR ')) then Exit;
   Inc (Src,3);
   AWSpaces (Src,Prg,nil);
   if StrCheck (Src,'EACH ') then begin Each:=true; Inc (Src,4); AWSpaces (Src,Prg,nil); end
    else Each:=false;
   S:=TestIdent (Src); if (S = '')  or KeyWord (S) then begin Error (4,Src); Exit; end;
   V:=RegisterVar (S,@Vars); PushArg (Prg,V); Inc (Src,Length (S));
   AWSpaces (Src,Prg,nil);
   if Not (Each) then begin
     if Not (StrCheck (Src,'FROM')) then begin _ErrS:='FROM'; Error (5,Src); Exit; end;
     Inc (Src,4);
     D.State:=0; D.Prior:=0; if AExpr (Src,Prg,@D) = nil then begin Error (6,Src); Exit; end;
     AWSpaces (Src,Prg,nil); if Not (StrCheck (Src,'TO')) then begin _ErrS:='TO'; Error (5,Src); Exit; end;
     Inc (Src,2);
     D.State:=0; D.Prior:=0; if AExpr (Src,Prg,@D) = nil then begin Error (6,Src); Exit; end;
     P:=GetFree; P^.T:=cCode; P^.Entry:=@InitForCode; PushArg (Prg,P);
     G:=GetFree; G^.T:=cUserCode; PushArg (Prg,G);
     Start:=Prg;
     P:=GetFree; P^.T:=cCode; P^.Entry:=@ForCheck; PushArg (Prg,P);
    end else begin
     if Not (StrCheck (Src,'IN')) then begin _ErrS:='IN'; Error (5,Src); Exit; end;
     Inc (Src,2); AWSpaces (Src,Prg,nil);
     D.State:=0; D.Prior:=0; if AExpr (Src,Prg,@D) = nil then begin Error (6,Src); Exit; end;
     G:=GetFree; G^.T:=cUserCode; PushArg (Prg,G);
     Start:=Prg;
     P:=GetFree; P^.T:=cCode; P^.Entry:=@ForEach; P^.Ptr:=ptr(0,0); PushArg (Prg,P);
   end;
   APrg (Src,Prg,@D);
   AWSpaces (Src,Prg,nil); if Not (StrCheck (Src,'ENDFOR')) then begin _ErrS:='ENDFOR'; Error (5,Src); Exit; end;
   G^.UserEntry:=Prg;
   P:=GetFree; P^.T:=cUserCode; P^.UserEntry:=Start; PushArg (Prg,P);
   P:=GetFree; P^.T:=cCode; P^.Entry:=@GotoCode; PushArg (Prg,P);
   P:=GetFree; P^.T:=cCode; P^.Entry:=@ForDestructor; PushArg (Prg,P);
   Inc (Src,6);
   AFor:=P;
 end;

{****************************************************************************}

function ABreak; {!!! Jeste poradne nefunguje}
 var P : PCode;
 begin
   ABreak:=nil; if ErrCode <> 0 then Exit;
   if Not (StrCheck (Src,'BREAK ')) then Exit;
   Inc (Src,5);
   P:=GetFree; P^.T:=cCode; P^.Entry:=@BreakCode; PushArg (Prg,P);
   ABreak:=P;
 end;

{****************************************************************************}

function AContinue;
 var P : PCode;
 begin
   AContinue:=nil; if ErrCode <> 0 then Exit;
   if Not (StrCheck (Src,'CONTINUE '))then Exit;
   Inc (Src,8);
   P:=GetFree; P^.T:=cCode; P^.Entry:=@ContinueCode; PushArg (Prg,P);
   AContinue:=P;
 end;

{****************************************************************************}

function ADefFunc; {Definice funkce}
 var S : String;
     Proc,P,V,G,Oprg,XPrg : PData;
     D : TData;

     procedure ImmLocVars; {Vytvoreni prikazu Param1=nil Param2=nil ... na zacatku bloku}
      var S : String;
      begin
        AWSpaces (Src,Prg,nil); S:=TestIdent (Src);
        if (S = '') then Exit;
        if KeyWord (S) then begin Error (4,Src); Exit; end;
        Inc (Src,Length (S));
        V:=RegisterVar (S,@Vars); PushArg (Prg,V);
        PushArg (Prg,NULL);
        P:=GetFree; P^.T:=cCode; P^.Entry:=@AssignLValue; PushArg (Prg,P);
        if Src^ = ',' then begin Inc (Src); ImmLocVars; end;
      end;

     procedure IntDef; {Zpracuj interni definici funkce}
      begin
        D.State:=0; APrg (Src,Prg,@D); {Analyzuje vnitrni blok funkce}
        P:=GetFree; P^.T:=cCode; P^.Entry:=@Return; PushArg (Prg,P);
        AWSpaces (Src,Prg,nil); if Not (StrCheck (Src,'ENDPROC')) then Exit;
        Inc (Src,7);
      end;

     procedure ExtDef; {Zpracuj externi definici funkce}
      var S : String; XC : PChar;
          H : PData; P : Pointer;
      begin
        Inc (Src,6); AWSpaces (Src,Prg,nil);
        if Src^ <> '"' then begin Error (17,Src); Exit; end;
        Inc (Src);
        S:=''; while Src^ <> '"' do begin S:=S+Src^; Inc (Src); end;
        Inc (Src); H:=RegisterVar (S,@Vars);
        if H^.T = cVar then begin H^.T:=cDLL;
           GetMem (XC,Length (S)+5);
           if Pos ('.',S) = 0 then StrPCopy (XC,S+'.DLL')
            else StrPCopy (XC,S);
           V:=GetFree; V^.T:=cInt;
           {$IFNDEF REAL}
           V^.Data.Int:=LoadLibrary (XC);
           P:=GetProcAddress (V^.Data.Int,'InitDLL');
           if V^.Data.Int <= 21 then begin Error (18,Src); Exit; end;
           if P <> nil then TInitProc (P);
           H^.Value:=V;
           FreeMem (XC,Length (S)+5);
           {$ENDIF}
        end;
        Proc^.T:=cBinFunc; Proc^.Value:=nil;
        GetMem (XC,Length (Proc^.Name^)+1); StrPCopy (XC,Proc^.Name^);
        {$IFNDEF REAL}
        Proc^.Value:=GetProcAddress (H^.Value^.Data.Int,XC); {!!PROTECT!!}
        {$ENDIF}
        if Proc^.Value = nil then begin Error (19,Src); Exit; end;
        FreeMem (XC,Length (Proc^.Name^)+1);
      end;

 begin
   ADefFunc:=nil;
   if ErrCode <> 0 then Exit;
   AWSpaces (Src,Prg,nil); if Not (StrCheck (Src,'PROC ')) then Exit;
   Inc (Src,4); AWSpaces (Src,Prg,nil); S:=TestIdent (Src);
   if (S = '') or KeyWord (S) then begin Error (4,Src); Exit; end;
   Inc (Src,Length (S));
   Proc:=RegisterVar (S,@Vars);
   {if (Proc <> nil) and
      (Proc^.T <> cFunc) and (Proc^.T <> cNULL) then begin Error (13,Src); Exit; end;}
   Proc^.T:=cFunc; {Zaregistruj identifikator funkce}
   AWSpaces (Src,Prg,nil); if Src^<>'(' then Exit;
   G:=GetFree; G^.T:=cUserCode; PushArg (Prg,G);
   P:=GetFree; P^.T:=cCode; P^.Entry:=@GotoCode; PushArg (Prg,P); {Uloz skok pro return}
   Proc^.Value:=Prg;
   Inc (Src); ImmLocVars;
   if Src^<>')' then begin Error (11,Src); Exit; end; {!!! Pozor !!!}
   Inc (Src);

   OPrg:=nil; PushArg (OPrg,Zarazka); XPrg:=OPrg;
   AWSpaces (Src,OPrg,nil); ADebugInfo (Src,OPrg,nil); {Tady je debug info}
   AWSpaces (Src,OPrg,nil);
   if StrCheck (Src,'PRIVATE ') then begin Inc (Src,7); ImmLocVars; end;
   XPrg^.Next:=Prg; Prg:=OPrg;

   if StrCheck (Src,'EXTERN ') then ExtDef else IntDef; {Jedna se o externi?}
   G^.UserEntry:=Prg; ADefFunc:=G;
 end;

{****************************************************************************}

function ARet;
 var PC : PChar;
     OP,P,UC : PCode;
     D : TData;
 begin
   ARet:=nil; PC:=Src;
   if ErrCode <> 0 then Exit;
   if Not (StrCheck (PC,'RETURN')) then Exit;
   Inc (PC,6);
   D.State:=0; D.Prior:=0; OP:=Prg; AExpr (PC,Prg,@D);
   P:=GetFree; P^.T:=cCode;
   if OP=Prg then P^.Entry:=@Return else P^.Entry:=@RReturn; {Vloz vyvolanikodu pro return}
   PushArg (Prg,P);
   ARet:=P; Src:=PC;
 end;

{****************************************************************************}

function AHalt;
 var P : PCode;
 begin
   AHalt:=nil;
   if Not (StrCheck (Src,'HALT ')) then Exit;
   Inc (Src,4);
   P:=GetFree; P^.T:=cCode; P^.Entry:=@Halt; PushArg (Prg,P);
   AHalt:=P;
 end;

function AStop;
 var P : PCode;
 begin
   AStop:=nil;
   if Not (StrCheck (Src,'STOP ')) then Exit;
   Inc (Src,4);
   P:=GetFree; P^.T:=cCode; P^.Entry:=@StopCode; PushArg (Prg,P);
   AStop:=P;
 end;

function ACont;
 var P : PCode;
 begin
   ACont:=nil;
   if Not (StrCheck (Src,'CONT ')) then Exit;
   Inc (Src,4);
   P:=GetFree; P^.T:=cCode; P^.Entry:=@ContCode; PushArg (Prg,P);
   ACont:=P;
 end;

{****************************************************************************}

function APrg; {A to je analyza vsech moznych konstrukci v bloku}
 var P : PData;
     I : Integer;
 begin
   APrg:=nil;
   if ErrCode <> 0 then Exit;
   repeat
     Info^.State:=0; Info^.Prior:=0;
     if AWSpaces (Src,Prg,Info) <> nil then break;
     if ADebugInfo (Src,Prg,Info) <> nil then Continue;
     if AArrDef (Src,Prg,Info) <> nil then Continue;
     if AIf (Src,Prg,Info) <> nil then Continue;
     if AWhile (Src,Prg,Info) <> nil then Continue;
     if AFor (Src,Prg,Info) <> nil then Continue;
     if ADefFunc (Src,Prg,Info) <> nil then Continue;
     if ABreak (Src,Prg,Info) <> nil then Continue;
     if AContinue (Src,Prg,Info) <> nil then Continue;
     if ARet (Src,Prg,Info) <> nil then Continue;
     if AHalt (Src,Prg,Info) <> nil then Continue;
     if AStop (Src,Prg,Info) <> nil then Continue;
     if ACont (Src,Prg,Info) <> nil then Continue;
     Info^.State:=Info^.State or cLValue; if AExpr (Src,Prg,Info) <> nil then Continue;
     break
   until false;
 end;

{****************************************************************************}

procedure GiveError (Src : PChar);
 begin
   case Src^ of
    ')' : Error (3,Src);
    else Error (255,Src);
   end;
 end;

end.

{Globalni analyza APrg vyhodnocuje vsechny prikazy mozne v bloku
 if,for,prirazeni ...
 A dalsi analyzovaci funkce jsou volany jiz s techto
  AIf napriklad vola analyzu AExpr aby se ujistila,ze za klicovym
  slovem if nasleduje vyraz,pak - li ze ano je jiz funkci AExpr prelozen a pridan
  do "prelozeneho" seznamu prikazu na jehoz pocatek ukazuje Prg : PData (globalni promena)
  Pak - li ze je neuspesna ohlasi se chyba.

 Jedine,kde je analyza netrivialni je v AExpr.
 Jak probiha se pokusim priblizit na prikladu :
  1+2*3+1


  precte se cislo a ulozi na zasobnik tedy mame Prg -> [1]
  nacte se operator + (ten ale pozaduje dalsi parametr a tedy se rekurzivne vola
  opet AExpr (s tim,ze je predana priorita operatoru naposledy precteneho tedy +)
  pokracuje se stejne a ulozi se na zasobnik prikazu opet cislo
  mame tedy prg -> [2] -> [1]
  Cte se * priorita je vyssi nez naposledy prectena -> jedeme dal
  Precte se 3 mame Prg -> [3] -> [2] -> [1]
  Dalsi je + ale to ma nizsi prioritu nez naposledy prectene tedy se vracime
  az bude mit + nizssi (abychom mohli zase pokracovat)
  Ulozi se tedy na zasobnik operace mame tedy
   Prg -> [*] [3] [2] [1]
  Je porad stejna tedy pridame dalsi operator
   Prg -> [+] [*] [3] [2] [1]
  Tedy uz je to v poradku a muzeme jit dal
  Cteme + a volame opet AExpr
  |  Cteme 1 a mame Prg -> [1] [+] [*] [3] [2] [1]
  Pridame operator Prg -> [+] [1] [+] [*] [3] [2] [1]


  Globalne plati :
   Pri interpretaci je ale potreba na zasobnik nejdrive ulozit parametry a
    po te vyvolat funkce,ktera parametry zpracuje,proto je po analyze obraceno poradi
   Tedy po analyze mame
    Prg -> [1] [2] [3] [*] [+] [1] [+]

    A vyhodnocovani probiha :
     Je na rade kod (rozumi se v Prg^.Item) ne uloz data na zasobnik a vezmi Prg:=Prg^.Next;
                                            ano zavolej funkci

     Na prikladu :
      Stack Pred volanim :           Vola se :    Stack po volani :
       ->[1] [2] [3]                   [*]         ->[1] [6]
       ->[1] [6]                       [+]         ->[7]
       ->[7] [1]                       [+]         ->[8]

 Bugfix by D.Ment:
  Radu binarnich operatoru se stejnou prioritou odted vyhodnocuje zleva.
  Stacilo 9x zakomentovat rovnitko v .prior<=const, viz vyskyty {=}

  Taky jsem na radek 754 pridal P^.Ptr:=ptr(0,0); uz nevim proc.
