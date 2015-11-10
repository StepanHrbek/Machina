Unit MyDef;{$i define.inc}

interface


const
  cData     = 1;
  cExtern   = 2;
  cCode     = 3;
  cVar      = 4;
  cList     = 5;
  cFunc     = 6;
  cUserCode = 7;
  cUserList = 8;
  cUserRes  = 9; {Use only value pointer}
  cInt      = 10;
  cPtr      = 11;
  cStr      = 12;
  cBreak    = 13;
  cState    = 14;
  cBinFunc  = 15;
  cDLL      = 17;
  cArray    = 18;
  cArrayIter= 19;
  cNULL     = 4096;
  cNothing  = 8192;
  cMarkuj   = 16384;
  cWasParam = 1;
  cSignum   = 2;
  cLValue   = 8;
  cWasIdent = 16;
  cWasLValue= 32;
  cAllSpaces= 64;
  cEx       = 256;
  cBP       = 32768; {cBreakPoint}
  cTrace    = 16384;

  cHalt     = 1;
  cDone     = 2;
  cStop     = 4;

  LineMagic = '~';
  MaxMemBlock = 10;

type
  PStr = ^String;
  PInterpret = Pointer;
  PInteger = ^Integer;
  PWord = ^Word;
  PParams = ^TParams;
  PPData = ^PData;
  PData = ^TData;
  PCode = PData;
  PList = PData;

  TFunction = function (var Prg,Stack : PData) : PData;
  TParams = Array [0..255] of PData;

  TDataStruct = record
                  case Byte of
                   cInt : (Int : LongInt);
                   cPtr : (Ptr : Pointer);
                   cStr : (StrL : Word;
                           StrC : PChar);
                end;

  TData = record {Hlavni datova struktura - pouzita pri analyze i interpretaci}
                 {viz dale}
            case T : Integer of
             cState           : (State,Prior : LongInt);
             cList            : (Item : PData; Next : PData);
             cVar,cFunc,
             cBinFunc         : (Name : PStr; Value : PData);
             cCode            : (Entry : Pointer; Ptr : Pointer); {Internal Ptr}
             cUserCode        : (UserEntry : PData; UserData : LongInt);
             cInt,cPtr,cStr   : (Handle : Word; Data : TDataStruct);
             cArray           : (Arr : PParams; Count : Integer);
             cArrayIter       : (PArr : PData; Iter : Integer);
             cNothing         : ();
          end;

implementation

end.