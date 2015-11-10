Unit MyCode;{$i define.inc}

{DEFINE DEBUGLAN}
{Hlavni datove typy,globalni definice}
{Pozn.
 Organizace pameti :
  Po spusteni interpretu alokuje velky kus pameti,ktery rozdely do bunek typu
 TData,tak ze kazda bunka reprezentuje jednu polozku seznamu.Prvni prvek
 je ulozen v glob. promene Free a odtud se prideluji volne pametove bunky
 jednotlivym proceduram. Specialne pri interpretaci to znamena,ze neni treba pro
 kazdy novy vysledek (parametr) alokovat misto na heapu (pomale,problemy s odalokovanim),
 ale staci provest jednu operaci s Free promenou (Free:=Free^.Next); a predat free
 jako volnou bunku.S tim ovsem souvisi i to,ze bunky se budou ztracet (v pripade,
 ze promenou zahodim (napriklad docasny mezi vysledek ve vyrazu) stane se ze ztratim
 o teto bunce informace.Pri nedostatku volnych bunek je tedy aplikovana metoda GarbageCollector,
 ktera nejdrive oznaci bunky,ktere jsou jeste pouzivany a pote vycisti (Prida opet do Free listu)
 ty,jez pouzity nejsou.
}
{$IFNDEF DPMI} {$IFNDEF WINDOWS} {$DEFINE REAL} {$ENDIF} {$ENDIF}
interface
uses MyDefin,MyDef;

  function Push (var Stack : PData; List : PData) : PData;
  function PushArg (var Stack : PData; Item : PData) : PData; {$IFNDEF REAL} export; {$ENDIF}
  function PopArg (var Stack : PData) : PData; {$IFNDEF REAL} export; {$ENDIF}
  function Pop (var Stack : PData) : PData;
  procedure Markuj (W : PData); {Omarkuje pouzite bunky,aby je sweeper nevypustil}
  procedure Sweep; {Zrusi prislusne neomarkovane (tedy nepouzite) bunky a da je zpet do Free - seznamu}
  procedure GarbageCollector; {$IFNDEF REAL} export; {$ENDIF}
  procedure LockGarbage;
  procedure UnLockGarbage;
  function IsFree (F : PData) : LongInt; {$IFNDEF REAL} export; {$ENDIF}
  function StrCheck (Src,Str : PChar) : Boolean; {$IFNDEF REAL} export; {$ENDIF}
  procedure ReleaseMemory; {$IFNDEF REAL} export; {$ENDIF}
  procedure GenerateMemory (N : LongInt); {$IFNDEF REAL} export; {$ENDIF}
  procedure WriteStr (S : String);
  function UpString (S : String) : String;
  procedure Refresh(limit:longint); {$IFNDEF REAL} export; {$ENDIF}
  function GetFree : PData; {$IFNDEF REAL} export; {$ENDIF}
  procedure PutFree (D : PData); {$IFNDEF REAL} export; {$ENDIF}
  procedure Statistic; {$IFNDEF REAL} export; {$ENDIF}

const
    GLock : Integer = 0;
    BoxesCount = 6000;

var
    Mem : Array [1..MaxMemBlock] of PData;
    MemLen : LongInt; MemBlocks : Integer;

implementation
uses {$IFDEF WINDOWS} WinProcs, {$ELSE}
      {$IFDEF DEBUGLAN} Crt, {$ENDIF}
     {$ENDIF} Strings ,vga,sys,stringy {$IFDEF DPMI},WinAPI ,Chyby {$ENDIF};


  procedure LockGarbage; begin Inc (GLock); end;
  procedure UnLockGarbage; begin Dec (Glock); end;

  function Valid( P : PData) : Boolean;
   var I : Integer;
   begin
     Valid:=false;
     for i:=1 to memblocks do
       if (PChar(P) - PChar(Mem[i]) < 0) or
          (PChar(P) - PChar(Mem[i]) > BoxesCount * sizeof( TData)) then Exit;
     Valid:=true;
   end;

  procedure Markuj (W : PData); {Omarkuje pouzite bunky,aby je sweeper nevypustil}
   var T,X : Integer;
   begin
     if (W = nil) or (W^.T and cMarkuj <> 0) { and not valid(W)} then Exit;
     T:=W^.T; W^.T:=W^.T or cMarkuj;
     case T of
      cList,cUserList : begin
                          Markuj (W^.Item);
                          Markuj (W^.Next);
                        end;
      cArray          : for X:=0 to W^.Count-1 do Markuj (W^.Arr^ [X]);
      cDLL            : Markuj (W^.Value);
{     cCode           : Markuj (W^.Next);}
      cVar,cFunc      : Markuj (W^.Value);
      cUserCode       : Markuj (W^.UserEntry);
      {else user defined Markuj in own dlls}
     end;
   end;

  procedure FreeNode (P : PData);
   begin
     case P^.T of
      cDLL : {$IFNDEF REAL} FreeLibrary (P^.Value^.Data.Int){$ENDIF};
      cStr : if P^.Data.StrC <> nil then begin
              FreeMem (P^.Data.StrC,P^.Data.StrL);
              P^.Data.StrC:=nil;
             end;
      cVar,
      cFunc,
      cBinfunc
           : if P^.Name <> nil then begin
              {writeln('Û',P^.Name^);{}
              FreeMem (P^.Name,length(P^.Name^)+1);
              P^.Name:=nil;
             end;
      cArray : if P^.Arr <> nil then begin
{                WriteLn (Seg (P^.Arr^),' ',
                Ofs (P^.Arr^),' ',P^.Count); ReadLn;
                FreeMem (P^.Arr,(P^.Value^.Count)*SizeOf (PData));
                P^.Arr:=nil;}
               end;
     end;
   end;

  procedure Sweep; {Zrusi prislusne neomarkovane (tedy nepouzite) bunky a da je zpet do Free - seznamu}
   var PI : PData; CI,I,N : Integer;
   begin
     Free:=nil; FreeCount:=0;
     for I:=1 to MemBlocks do begin
      if debugpal then SetHwCol(0,63,63,63);
      CI:=0; PI:=Mem [I]; if I <> MemBlocks then N:=BoxesCount else N:=MemLen-BoxesCount*(MemBlocks-1);
      while CI<N do begin
       if (PI^.T and cMarkuj=0) then
        begin FreeNode (PI); Push (Free,PI);
              PI^.T:=cList; Inc (FreeCount); end
        else PI^.T:=PI^.T xor cMarkuj;
       Inc (PI); Inc (CI);
      end;
    end;
    if debugpal then SetHwCol(0,20,20,0);
   end;

  function IsFree (F : PData) : LongInt;
   var I : LongInt;
   begin
     I:=0;
     while F <> nil do begin Inc (I); F:=F^.Next; end;
     IsFree:=I;
   end;

  procedure GarbageCollector;
   begin
     Markuj (Prg);
     Markuj (Stack);
     Markuj (Vars);
     Markuj (Internal);
     Sweep;
     {$IFDEF DEBUGLAN} WriteLn ('Running Garbage Collector. Free:',FreeCount,' ',IsFree (Free));
      {$ENDIF}
   end;

  procedure Statistic;
   begin
     {$IFDEF DEBUGLAN}
     {Exit;}
     {GotoXY (1,WhereY+1);}
     Write ('Free:',FreeCount,' ',IsFree (Free));
     Write (' Prg:',IsFree (Prg));
     Write (' Stack:',IsFree (Stack));
     WriteLn ('  IsFree on heap:',MemAvail,'    ');
     {$IFNDEF WINDOWS} Delay (20); {$ENDIF}
     {$ENDIF}
   end;

  procedure Refresh(limit:longint); {Pokud je malo pameti zavola GarbageCollector}
   begin
     if (FreeCount<limit) and (GLock = 0) then begin
      {$IFDEF DEBUGLAN}
      {ClrScr;}
      WriteLn ('Before GC:'); Statistic; {$ENDIF}
      GarbageCollector; {MinMem:=MemAvail;}
      {$IFDEF DEBUGLAN}
      WriteLn ('Past GC:'); Statistic;
      Delay (1000); {$ENDIF}
     end;
   end;

  function GetFree : PData;
   {$IFDEF DEBUGLAN}
   procedure Writetuj (P : PData);
    begin
      if P <> nil then begin
        WriteLn ('Hi',P^.T);
        case P^.T of
         cVar,cFunc,cBinFunc : WriteLn (P^.Name^);
         cInt : WriteLn (P^.Data.Int);
         cStr : WriteLn (P^.Data.Str^);
        end;
      end else WriteLn ('nilak');
    end;
   {$ENDIF}

   begin
     if debugpal then SetHwCol(0,20,20,0);
{if FreeCount<minfree then ReportErr('FreeCount='+stri(FreeCount));{}
     if Free = nil then begin
      {ReportErr('FreeCount='+stri(FreeCount)+' GLock='+stri(glock));}
      Halt(_erLowMem4Parlan);
      {RunError (254); {Free jsou osetrovany v Refreshy}
     end;
     GetFree:=Free; Free:=Free^.Next; Dec (FreeCount);
     {$IFDEF DEBUGLAN}
     if FreeCount<100 then Statistic;
     if FreeCount <> IsFree (Free) then begin
      if Stack <> nil then Writetuj (Stack^.Item);
      if Stack^.Next <> nil then Writetuj (Stack^.Next^.Item);
      if Stack^.Next^.Next <> nil then Writetuj (Stack^.Next^.Next^.Item);
     end;
     {$ENDIF}
   end;

  procedure PutFree (D : PData);
   begin
     if D = nil then Exit;
     D^.Next:=Free; D^.T:=cList; Free:=D;
     Inc (FreeCount);
   end;

  function Push (var Stack : PData; List : PData) : PData;
   begin
     List^.Next:=Stack; Stack:=List;
     Push:=Stack;
   end;

  function PushArg (var Stack : PData; Item : PData) : PData;
   var D : PData;
   begin
     D:=GetFree; D^.T:=cList; D^.Item:=Item;
     Push (Stack,D);
     PushArg:=Item;
   end;

  function Pop (var Stack : PData) : PData;
   begin
     Pop:=Stack^.Item; Stack:=Stack^.Next;
   end;

  function PopArg (var Stack : PData) : PData;
   var D : PData;
   begin
     PopArg:=nil;
     if Stack=nil then Exit;
     PopArg:=Stack^.Item; D:=Stack; Stack:=Stack^.Next;
     PutFree (D);
   end;

  function UpString (S : String) : String;
   var I : Integer;
   begin
     for I:=1 to Length (S) do S [I]:=UpCase (S [I]);
     UpString:=S;
   end;

  procedure WriteStr (S : String);
   begin
     Write (S);
   end;

  procedure InitInternal;
   begin
     Zarazka:=GetFree; Zarazka^.T:=cNothing; PushArg (Internal,Zarazka);
     NoRetZarazka:=GetFree; NoRetZarazka^.T:=cNothing; PushArg (Internal,NoRetZarazka);
     NULL:=GetFree;  NULL^.T:=cNULL; PushArg (Internal,NULL);
     ListNULL:=GetFree; ListNULL^.T:=cNULL; PushArg (Internal,ListNULL);
   end;

  procedure GenerateMemory (N : LongInt); {A utrhneme si kus pameti}
   var I : Integer; Last : PData;
   begin
     MemLen:=N; Stack:=nil; Vars:=nil; Internal:=nil;
     I:=1;
     while N>BoxesCount do begin
      GetMem (Mem [I],BoxesCount * SizeOf (TData)); Inc (I);
{      writeln('Ûalok:',BoxesCount * SizeOf (TData));{}
      N:=N-BoxesCount;
     end; GetMem (Mem [I],N * SizeOf (TData)); MemBlocks:=I;
{      writeln('Ûalok:',N * SizeOf (TData));{}
     FreeCount:=0;
     for I:=1 to MemBlocks do begin
      Free:=Mem [I]; if I <> MemBlocks then N:=BoxesCount else N:=MemLen-BoxesCount*(MemBlocks-1);
      while N>0 do begin
       Free^.T:=cList; Free^.Item:=nil; Last:=Free; Inc (FreeCount);
       Inc (Free); Last^.Next:=Free; Dec (N);
      end; if I <> MemBlocks then Last^.Next:=Mem [I+1];
     end;
     Last^.Next:=nil; Free:=Mem [1];
     InitInternal;
   end;

  procedure ReleaseMemory;
   var I : Integer;
   begin
     for I:=1 to MemBlocks do
      if I <> MemBlocks then begin
        FreeMem (Mem [I],BoxesCount * SizeOf (TData));
{        writeln('Ûfree:',BoxesCount * SizeOf (TData));{}
        end
      else begin
        FreeMem (Mem [I],(MemLen-BoxesCount*(MemBlocks-1)) * SizeOf (TData));
{        writeln('Ûfree:',(MemLen-BoxesCount*(MemBlocks-1)) * SizeOf (TData));{}
        end;
   end;

  function StrCheck (Src,Str : PChar) : Boolean; {Porovnava vyskyt Podstringu ve stringu}
   var I : Integer;
   begin
     I:=0;
     while (I<StrLen (Str)) and (Src^ <> #0) and
           (UpCase ((Src+I)^) = UpCase ((Str+I)^)) do Inc (I);
     StrCheck:=(I=StrLen (Str));
   end;

end.