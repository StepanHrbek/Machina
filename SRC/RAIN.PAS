Unit      Rain;

Interface {$G+,I-,Q-,R-,S-,T+,V+,X+}

Type      TReportError=procedure(s:string);
Type      TReportEnd=procedure(handle:longint);
Var       ReportError:TReportError;
Var       ReportEnd:TReportEnd;

FUNCTION  RainInit:string;
PROCEDURE RainPoll;
FUNCTION  RainPlay(filename:string;fileofs,filesize,loop,volume,panning:longint):longint;
PROCEDURE RainSetVolume(handle,volume:longint);
PROCEDURE RainSetPanning(handle,panning:longint);
PROCEDURE RainStop(handle:longint);
PROCEDURE RainAmplification(amp:longint);

Var       async:byte;

{ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß}
                          IMPLEMENTATION
{ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ}

uses WinDos,Strings,Objects;

const
  CMD_NONE     =0;
  CMD_PLAY     =1;
  CMD_STOP     =2;
  CMD_VOL      =3;
  CMD_PAN      =4;
  CMD_AMPLIFY  =5;
  CMD_TERMINATE=-1;

const
  protokol:byte=0;

{protokol 1}
type
  TLongs=array[0..255] of longint;
  PLongs=^TLongs;
const
  talk:PLongs    =nil;
  TALK_BUFSIZE   =1024; {talk buffer length}
  TALK_STRSIZE   =256;  {max talk string length including zero end}
  TALK_CMD       =0;
  TALK_PARAM1    =1;
  TALK_PARAM2    =2;
  TALK_PARAM3    =3;
  TALK_FILE_OFS  =4;
  TALK_FILE_SIZE =5;   function
  TALK_FILE_NAME :pchar;assembler;asm mov ax,word ptr talk;mov dx,word ptr talk+2;add ax,6*4;end; function
  TALK_REPORT    :pchar;assembler;asm mov ax,word ptr talk;mov dx,word ptr talk+2;add ax,128*4;end;

{protokol 2}
var
  raincmd:text;
  rainrep:file;
  raincmdname:string;
  rainrepname:string;
const
  lasthandle:longint=0;
var
  input:string;
const
  skipeol:boolean=false;
function ReadReply:string;
  var readen,p10:word;
  begin
   ReadReply:='';
   blockread(rainrep,input[length(input)+1],255-length(input),readen);
   inc(input[0],readen);
   p10:=pos(#10,input);
   if (p10>0) then begin
     if input[p10-1]=#13 then begin delete(input,p10-1,1);dec(p10);end;
     if not skipeol then ReadReply:=copy(input,1,p10-1);
     delete(input,1,p10);
     skipeol:=false;
     end
   else if length(input)=255 then begin
     if not skipeol then ReadReply:=input;
     input:='';
     skipeol:=true;
     end;
  end;

{asynchronous calls}
type
  pboolean=^boolean;
var
  dosunsafe:pboolean;
  errors:TStringCollection;
procedure CleverReportError(error:string);
  begin
   if async=0 then ReportError(error) else errors.Insert(NewStr(error));
  end;
procedure SetCol(col,r,g,b:byte);assembler;
  asm
   mov dx,3c8h;mov al,col;out dx,al;inc dx
   mov al,r;out dx,al
   mov al,g;out dx,al
   mov al,b;out dx,al
  end;

{common}
function Str2Pc(var st: OpenString): PChar; assembler;
  var p:word absolute st;
  asm
   les  di,p
   mov  bl,[es:di]
   xor  bh,bh
   cmp  bx,p.word[-2]
   je   @overwritelast
   inc  bx
  @overwritelast:
   mov  [es:bx+di],bh
   xchg ax,di
   mov  dx,es
   inc  ax
  end;

FUNCTION RainInit:string;
var j,code,segment:word;
    env:pchar;
    ver:string;
label err;
begin
 if protokol<>0 then begin
   RainInit:='RainInit may be called just once.';
   exit;
   end;
 RainInit:='';
 env:=GetEnvVar('RAIN');
 if env<>nil then begin
   ver:=StrPas(env);
   {invalidate rain variable so child processes won't think rain is for them}
   (env-2)^:='X';
   {is rain talking via memory?}
   if copy(ver,1,4)='SEG ' then begin
      val(copy(ver,5,255),segment,code);
      if (code=0) and (segment<>0) then begin
        {$ifdef dpmi}
        asm
          mov     ax,2
          mov     bx,segment
          int     31h
          jc      err
          mov     segment,ax
        end;
        {$endif}
        talk:=ptr(segment,0);
        RainInit:=StrPas(TALK_REPORT);
        TALK_REPORT^:=#0;
        protokol:=1;
        exit;
        err:
        end;
      end;
   {is rain talking via file?}
   if copy(ver,1,5)='FILE ' then begin
      raincmdname:=copy(ver,6,255);
      j:=pos(',',raincmdname);
      if (j>1) and (j<length(raincmdname)) then begin
        rainrepname:=copy(raincmdname,j+1,255);
        raincmdname[0]:=chr(j-1);
        assign(rainrep,rainrepname);
        filemode:=$40;
        reset(rainrep,1);
        filemode:=2;
        if ioresult=0 then begin
          assign(raincmd,raincmdname);
          filemode:=$41;
          append(raincmd);
          if ioresult<>0 then rewrite(raincmd);
          filemode:=2;
          if ioresult=0 then begin
            input:='';
            repeat ver:=ReadReply until ver<>'';{wait for server version}
            RainInit:=ver;
            repeat ver:=ReadReply until ver='';{skip replies for previous clients}
            protokol:=2;
            exit;
            end;
          close(rainrep);
          end;
        end;
      end;
   end;
end;

FUNCTION RainCommand(command,param1,param2,param3:longint;filename:pchar;fileofs,filesize:longint):longint;
var   reply:string;
      handle:longint;
      code:integer;
      error:pstring;
const raincommands:byte=0;
begin
 RainCommand:=0;

{ if not dosunsafe^ then setcol(0,0,0,0) else setcol(0,63,0,0); {}

 {just one command at one time, ignore asynchronous commands if necessary}
 inc(raincommands);
 if (raincommands=1) and ((async=0) or not dosunsafe^) then begin

   {report errors stored by asynchronously issued commands}
   if async=0 then
    while errors.count>0 do begin
      error:=errors.At(0);
      errors.AtDelete(0);
      ReportError(error^);
      DisposeStr(error);
      end;
   {send command, read reply}
   case protokol of
     1:begin
       talk^[TALK_PARAM1]:=param1;
       talk^[TALK_PARAM2]:=param2;
       talk^[TALK_PARAM3]:=param3;
       if filename=nil then TALK_FILE_NAME^:=#0 else StrCopy(TALK_FILE_NAME,filename);
       talk^[TALK_FILE_OFS]:=fileofs;
       talk^[TALK_FILE_SIZE]:=filesize;
       talk^[TALK_CMD]:=command;
       asm int 12h;end;
       reply:=StrPas(TALK_REPORT);
       if reply<>'' then TALK_REPORT^:=#0;
       end;
     2:begin
       case command of
         CMD_PLAY     :writeln(raincmd,command,' ',param1,' ',param2,' ',param3,' ',fileofs,' ',filesize,' ',filename);
         CMD_VOL      ,
         CMD_PAN      :writeln(raincmd,command,' ',param1,' ',param2);
         CMD_STOP     ,
         CMD_AMPLIFY  ,
         CMD_TERMINATE:writeln(raincmd,command,' ',param1);
         end;
       flush(raincmd);
       reply:=ReadReply;
       end;
     else
       reply:='';
     end;
   {return handle if needed}
   if command=CMD_PLAY then begin
     inc(lasthandle);
     RainCommand:=lasthandle;
     end;
   {call reporters}
   if reply<>'' then
    if reply[1]=' ' then CleverReportError(copy(reply,2,255)) else
     if copy(reply,1,7)='end of ' then begin
       val(copy(reply,8,255),handle,code);
       if code=0 then ReportEnd(handle)
         else CleverReportError('Unknown report: '+reply);
       end
     else CleverReportError('Unknown report: '+reply);

   end;
 dec(raincommands);
end;

PROCEDURE RainPoll;
begin
 RainCommand(CMD_NONE,0,0,0,nil,0,0);
end;

FUNCTION  RainPlay(filename:string;fileofs,filesize,loop,volume,panning:longint):longint;
begin
 RainPlay:=RainCommand(CMD_PLAY,loop,volume,panning,Str2Pc(filename),fileofs,filesize);
end;

PROCEDURE RainSetVolume(handle,volume:longint);
begin
 RainCommand(CMD_VOL,handle,volume,0,nil,0,0);
end;

PROCEDURE RainSetPanning(handle,panning:longint);
begin
 RainCommand(CMD_PAN,handle,panning,0,nil,0,0);
end;

PROCEDURE RainStop(handle:longint);
begin
 RainCommand(CMD_STOP,handle,0,0,nil,0,0);
end;

PROCEDURE RainAmplification(amp:longint);
begin
 RainCommand(CMD_AMPLIFY,amp,0,0,nil,0,0);
end;

procedure IgnoreEnd(handle:longint);far;
begin
{ writeln('RAIN: end of ',handle); {}
end;

procedure EchoError(s:string);far;
begin
 writeln('RAIN: ',s);
end;


var oldExitProc:pointer;

procedure RainExitProc;far;
 var env:pchar;
 begin
  exitProc:=oldExitProc;
  RainCommand(CMD_TERMINATE,exitcode,0,0,nil,0,0);
  errors.Done;
  {validate rain variable to get rain visible for possible next clients}
  env:=GetEnvVar('RAIX');
  if env<>nil then (env-2)^:='N';
 end;

BEGIN
 ReportError:=EchoError;
 ReportEnd:=IgnoreEnd;
 async:=0;
 errors.Init(5,5);
 asm
   mov ah,34h
   int 21h
   mov word ptr dosunsafe,bx
   mov word ptr dosunsafe+2,es
 end;
 oldExitProc:=exitProc;
 exitProc:=@RainExitProc;
END.