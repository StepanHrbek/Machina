{$r+,q+}
program Parlan;
uses
  Crt, MyLan, MyDef, MyDefin, MyFunc, MyPars, MyPProc,
  MyVars, MyCode{, NFDos};
{$I-}

var {Err : Integer;}
    Command : String; Source : PChar;

begin
  ClrScr;
  writeln(memavail);
  InitLan (true,15000); InitNewFunc;
  repeat
    ReadLn (Command);
    if Command <> '' then begin
       Command:=Command+#0; RunFlags:=0; ErrCode:=0;
       Source:=@Command[1]; Prg:=CompileSource(Source,true);
       if Prg = nil then WriteLn('Error :' + ErrMess)
        else begin
          Run(-1);
          if ErrCode <> 0 then begin
            RefreshLan;
            WriteLn('Error :' + ErrMess)
          end;
        end;
    end;
  until Command[1]='.';
  DoneLan;
  writeln(memavail);
end.
