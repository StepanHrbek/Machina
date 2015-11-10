Unit MyDefin;{$i define.inc}

interface
uses Strings,MyDef;
const
  MinFree4RunStep     : LongInt  = 20;
  MinFree4Compilation : LongInt  = 5000;
{ MinMem    : LongInt  = 80000;}

  AllocMem  : LongInt = 1000;
  DebugInfo : Boolean = true;

  ErrCode   : Integer = 0;
  ErrSrc    : PChar   = nil;
  RunCode   : Integer = 0;
  RunFlags  : Integer = 0;

type
  TInitProc = procedure;

  const Zarazka        : PData = nil; {tyto se nadefinuji hned po initu pameti}
  const NoRetZarazka   : PData = nil;
  const NULL           : PData = nil;
  const ListNULL       : PData = nil;

var
  Src : PChar;
  Free,Stack,OldVars,Vars,Internal : PData; Prg : PCode;
  FreeCount : LongInt;

  Mem : Array [1..MaxMemBlock] of PData;
  MemLen : LongInt; MemBlocks : Integer;

  function NewStr( S : String) : PStr;

implementation

function NewStr(S: String): PStr;
var
  P: PStr;
begin
  if S = '' then P := nil else
  begin
    GetMem(P, Length(S) + 1);
    P^ := S;
  end;
  NewStr := P;
end;

end.