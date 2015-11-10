Unit MyPProc;{$i define.inc} {Zacatek preprocesoru (nic zatim neumi)}

interface

procedure InitPrepro;
procedure Preprocesor;
function LoadSource (FS : String) : PChar; {Nacte script do pameti}
procedure DoneSource (PC : PChar);


implementation uses {$IFDEF WINDOWS} WinTypes,WinProcs,{$ENDIF}
                    Fajly,Stringy,Texty,
                    Strings,MyDef,MyDefin,MyCode,MyPars;
type
    TDef = record
             F,T : String[20];
             Pos : Integer;
           end;
    TDefines = array [1..100] of TDef;

const
    CDefines : Integer = 0;
    SrcBufLen = 40000;
var
    Defines : TDefines;
    SrcBuf, ISrcBuf : PChar;

function LoadSource (FS : String) : PChar; {Nacte script do pameti}
 const
   AllocFirstly=2000; AllocStep=2000;
 var
   S,L : String;
   XSrc,XSrcStart : PChar;
   SrcLen,Line : Integer;
   tpc:pchar;
   t:TText2;
 begin
   CDefines:=0; ISrcBuf:=SrcBuf;
   if Pos ('.',FS)=0 then FS:=FS+'.SCR';
   if not fileLoadPchar(FS,nil,tpc) then begin
    GetMem (XSrcStart,1); XSrcStart^:=#0;
    LoadSource:=XSrcStart;
    Exit;
    end;
   t.Init(tpc,StrLen(tpc)+1);
   SrcLen:=AllocFirstly;
   GetMem (XSrcStart,SrcLen+1); Line:=1; XSrc:=XSrcStart;
   while Not t.EOF do begin
    S:=t.nlRead; Str (Line,L); Inc (Line);
    S:=ConCat ('{',LineMagic,FS,'|',L,'}',S,#13#10);
    {WriteLn (S); ReadLn;}
    if Length (S)+XSrc-XSrcStart+1>SrcLen then begin
     SrcLen:=SrcLen+AllocStep; GetMem (XSrc,SrcLen+1);
     StrCopy (XSrc,XSrcStart); FreeMem (XSrcStart,SrcLen-AllocStep);
     XSrcStart:=XSrc; XSrc:=XSrcStart+StrLen (XSrcStart); {!!!}
    end;
    StrPCopy (XSrc,S); XSrc:=XSrc+Length (S);
   end;
   t.Done;
   GetMem (XSrc,StrLen (XSrcStart)+1); StrCopy (XSrc,XSrcStart);
   FreeMem (XSrcStart,SrcLen+1); LoadSource:=XSrc;
 end;
(*
 var
   F : Text; S,L : String;
   XSrc,XSrcStart : PChar;
   SrcLen,Line : Integer;
 begin
   CDefines:=0; ISrcBuf:=SrcBuf;
   if Pos ('.',FS)=0 then FS:=FS+'.SCR';
   {WriteLn(FS);}
   Assign (F,FS); Reset (F); if IOResult <> 0 then begin
    GetMem (XSrcStart,1); XSrcStart^:=#0;
    LoadSource:=XSrcStart;
    Exit;
   end;
   SrcLen:=AllocFirstly;
   GetMem (XSrcStart,SrcLen+1); Line:=1; XSrc:=XSrcStart;
   while Not (EOF (F)) do begin
    ReadLn (F,S); Str (Line,L); Inc (Line);
    S:=ConCat ('{',LineMagic,FS,'|',L,'}',S,#13#10);
    {WriteLn (S); ReadLn;}
    if Length (S)+XSrc-XSrcStart+1>SrcLen then begin
     SrcLen:=SrcLen+AllocStep; GetMem (XSrc,SrcLen+1);
     StrCopy (XSrc,XSrcStart); FreeMem (XSrcStart,SrcLen-AllocStep);
     XSrcStart:=XSrc; XSrc:=XSrcStart+StrLen (XSrcStart); {!!!}
    end;
    StrPCopy (XSrc,S); XSrc:=XSrc+Length (S);
   end;
   Close (F);
   GetMem (XSrc,StrLen (XSrcStart)+1); StrCopy (XSrc,XSrcStart);
   FreeMem (XSrcStart,SrcLen+1); LoadSource:=XSrc;
 end;
*)

procedure DoneSource (PC : PChar);
 begin
   if PC = nil then Exit;
   if PC=Src then Src:=nil;
   FreeMem (PC,StrLen (PC)+1);
 end;

procedure AInclude (var PC : PChar); {Includeje do PC pokud tam je #Include}
 var
   S : String; NewSrc,SPC,ISrc : PChar;
 begin
   SPC:=PC;
   if Not (StrCheck (PC+1,'INCLUDE')) then Exit;
   Inc (PC,8);
   while ((PC^>#0) and not (PC^ in ['"',#13,#10])) do Inc (PC);
   if PC^ <> '"' then begin _ErrS:='"'; Error( 5, PC); Exit; end else Inc (PC);
   S:='';
   while (PC^>#0) and not (PC^ in ['"',#13,#10]) do begin S:=S+PC^; Inc (PC); end;
   if PC^ = #0 then begin _ErrS:='"'; Error( 5, PC); Exit; end else Inc (PC);
   ISrc:=LoadSource (S);
   {WriteLn (StrLen (Src)+StrLen (ISrc)+1,' ',MaxAvail);}
   GetMem (NewSrc,StrLen (Src)+StrLen (ISrc)+1);
   SPC^:=#0; StrCopy (NewSrc,Src); SPC:=NewSrc+StrLen (Src);
   StrCat (NewSrc,ISrc); StrCat (NewSrc,PC);
   FreeMem (Src,StrLen (Src)+1); FreeMem (ISrc,StrLen (ISrc)+1);
   Src:=NewSrc; {!!!Prirazeni do globalni promene!!!}
   PC:=SPC;
 end;

procedure RegDefine(AF,AT : String);
 begin
   AF:=AF+#0; AT:=AT+#0;
   Inc(CDefines);
   with Defines[CDefines] do begin
     F:=AF; T:=AT; Pos:=0;
   end;
 end;

procedure ADefine (var PC : PChar);
 var
   F,T : String; NewSrc,SPC,ISrc : PChar;
 begin
   SPC:=PC;
   if Not (StrCheck (PC+1,'DEFINE')) then Exit;
   Inc (PC,7);
   F:=''; while PC^<>'\' do begin F:=F+PC^; Inc (PC); end; Inc (PC);
   T:=''; while PC^<>'\' do begin T:=T+PC^; Inc (PC); end; Inc (PC);
   RegDefine(F,T);
 end;

procedure NextChar(C : Char);
 var I : Integer;
 begin
   for I:=1 to CDefines do
    with Defines[I] do begin
     if F[Pos]=C then Inc(Pos) else Pos:=0;
     if Pos=Length(F) then
      begin
        StrCopy(ISrcBuf-Length(F)+1,@T[1]);
        ISrcBuf:=ISrcBuf-Length(F)+1+Length(T);
        Pos:=0;
      end;
    end;
 end;

procedure Preprocesor; {Zatim neumi nicmoc}
 var XSrc : PChar;
 begin
   XSrc:=Src;
   while XSrc^ > #0 do begin
    if XSrc^ <> '#' then begin NextChar( XSrc^); Inc(XSrc); end
     else case UpCase ((XSrc+1)^) of
            'I' : AInclude (XSrc);
            'D' : ADefine (XSrc);
            else Inc(XSrc);
          end;
   end;
 end;

procedure InitPrepro;
 begin
   GetMem(SrcBuf,SrcBufLen);
 end;


end.