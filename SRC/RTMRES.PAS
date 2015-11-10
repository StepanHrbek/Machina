{ ************************************************}
{                                                }
{   RTM Loader Demo                              }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{ ************************************************}

program RTMRes;

{$M 2048,0,0}

uses Dos;

procedure PrintStr(const S: String); assembler;
asm
	PUSH	DS
    LDS	    SI,S
	CLD
	LODSB
	XOR	    AH,AH
    XCHG	AX,CX
    MOV	    AH,40H
    MOV	    BX,1
    MOV	    DX,SI
    INT	    21H
    POP	    DS
end;

var
  Command: PathStr;
  Parameters: String;
  I: Integer;

begin
  PrintStr('RTMRes  Version 1.0  Copyright (c) 1992 by Borland International'#10#13);
  SwapVectors;
  Command := '';
  Parameters := '';
  if ParamCount > 0 then
  begin
    Command := FSearch(ParamStr(1), GetEnv('PATH'));
    if Command = '' then
    begin
      Command := GetEnv('COMSPEC');
      Parameters := '/C ' + ParamStr(1) + ' ';
    end;
    for I := 2 to ParamCount do
      Parameters := Parameters + ' ' + ParamStr(I);
  end
  else
  begin
    PrintStr('RTM Resident.  Type ''EXIT'' to uninstall.'#10#13);
    Command := GetEnv('COMSPEC');
  end;
  Exec(Command, Parameters);
  SwapVectors;
  PrintStr('RTM Unloaded.'#10#13);
end.
