Unit Atoms; {$i define.inc}


Interface

 Uses Chyby,Memo, Objects,Strings, Stringy;

 Type TPermanency = (forDunno,forPagetime,forRuntime,forImplicit,forEver);

      PAllAtomCollection = ^TAllAtomCollection;
      TAllAtomCollection = object(TSortedCollection)
        constructor Init;
        function    KeyOf(item:pointer):pointer;virtual;
        function    Compare(key1,key2:pointer):integer;virtual;
        procedure   aSet(context,name,value:pchar;perm:TPermanency);
        function    aGet(context,name:pchar):pchar;
        function    asGet(context:pchar):pchar;
        procedure   asDel(acontext:pchar;perm:TPermanency);
      end;

 Const     debugAto:boolean=false;

Implementation

{ Const
      empty='';}

 Type
      PAtom = ^TAtom;
      TAtom = object(TObject)
        name        :pchar;
        value       :pchar;
        permanency  :TPermanency;
        destructor  Done;virtual;
      end;

      PAtomCollection = ^TAtomCollection;
      TAtomCollection = object(TSortedCollection)
        context     :pchar;
        constructor Load(var s:TStream);
        procedure   Store(var s:TStream);
        function    GetItem(var s:TStream):pointer;virtual;
        procedure   PutItem(var s:TStream;item:pointer);virtual;
        function    KeyOf(item:pointer):pointer;virtual;
        function    Compare(key1,key2:pointer):integer;virtual;
        procedure   atomSet(name,value:pchar;perm:TPermanency);
        function    atomGet(name:pchar):pchar;
        function    atomsGet:pchar;
        procedure   atomsDel(perm:TPermanency);
        destructor  Done;virtual;
      end;


 { --- Atom --- }

 Destructor TAtom.Done;
 begin
  if name<>nil then StrDispose(name);
  if value<>nil then StrDispose(value);
 end;

 { --- Atom Collection --- }

 Constructor TAtomCollection.Load(var s:TStream);
 begin
  inherited Load(s);
  context:=s.StrRead;
 end;

 Procedure TAtomCollection.Store(var s:TStream);
 begin
  inherited Store(s);
  s.StrWrite(context);
 end;

 Function TAtomCollection.GetItem(var s:TStream):pointer;
 var atom:PAtom;
 begin
  New(atom,Init);
  if atom=nil then Halt(erLowMem);
  atom^.name:=s.StrRead;
  atom^.value:=s.StrRead;
  s.Read(atom^.permanency,sizeof(atom^.permanency));
  GetItem:=atom;
 end;

 Procedure TAtomCollection.PutItem(var s:TStream;item:pointer);
 begin
  with PAtom(item)^ do begin
    s.StrWrite(name);
    s.StrWrite(value);
    s.Write(permanency,sizeof(permanency));
    end;
 end;

 Function TAtomCollection.KeyOf(item:pointer):pointer;
 begin
  KeyOf:=PAtom(item)^.name;
 end;

 Function TAtomCollection.Compare(key1,key2:pointer):integer;
 begin
  Compare:=StrComp(key1,key2);
 end;

 {neulozi se kopie ale primo value}
 Procedure TAtomCollection.atomSet(name,value:pchar;perm:TPermanency);
 var atom:PAtom;
     index:integer;
 begin
  if debugAto then BiosWriteln('atomSet '+Pc2Str(name)+'='+Pc2Str(value));
  if not Search(name,index) then begin
    if value=nil then exit;
    New(atom,Init);
    if atom=nil then Halt(erLowMem);
    atom^.name:=StrNew(name);
    atom^.value:=value;
    atom^.permanency:=perm;
    Insert(atom);
    exit;
    end;
  if value=nil then begin
    AtFree(index);
    exit;
    end;
  StrDispose(PAtom(At(index))^.value);
  PAtom(At(index))^.value:=value;
  if perm<>forDunno then PAtom(At(index))^.permanency:=perm;
 end;

 {vraci primo value, ne kopii value}
 Function TAtomCollection.atomGet(name:pchar):pchar;
 var index:integer;
     value:pchar;
 begin
  if Search(name,index) then value:=PAtom(At(index))^.value else value:=nil;
  if debugAto then BiosWriteln('atomGet '+Pc2Str(name)+'='+Pc2Str(value));
  atomGet:=value;
 end;

 {vraci novy pchar vytvoreny GetMemem}
 Function TAtomCollection.atomsGet:pchar;
 var   len:word;
       alist:pchar;
  procedure AddLen(item:PAtom);far;
  begin
   with item^ do
    inc(len,2+StrLen(name)+1+StrLen(value)+2);
  end;
  procedure StrAdd(var pc:pchar;st:string);
  begin
   move(st[1],pc^,length(st));
   inc(pc,length(st));
  end;
  procedure AddAtom(item:PAtom);far;
  begin
   with item^ do
    StrAdd(alist,#13#10+chr(48+byte(permanency))+' '+Pc2Str(name)+'='+Pc2Str(value));
  end;
 begin
  if context=nil then len:=1+1 else len:=1+StrLen(context)+1;
  ForEach(@AddLen);
  GetMem(pointer(alist),len+1);
  atomsGet:=alist;
  if alist=nil then exit;
  alist^:=#0;
  StrAdd(alist,'['+Pc2Str(context)+']');
  ForEach(@AddAtom);
  alist^:=#0;
 end;

 Procedure TAtomCollection.atomsDel(perm:TPermanency);
 var i:integer;
 begin
  i:=count;
  while i>0 do begin
    dec(i);
    if PAtom(items^[i])^.permanency<=perm then AtFree(i);
    end;
 end;

 Destructor TAtomCollection.Done;
 begin
  if context<>nil then StrDispose(context);
  inherited Done;
 end;

 { --- All Atom Collections --- }

 Constructor TAllAtomCollection.Init;
 begin
  inherited Init(100,500);
 end;

 Function TAllAtomCollection.KeyOf(item:pointer):pointer;
 begin
  KeyOf:=PAtomCollection(item)^.context;
 end;

 Function TAllAtomCollection.Compare(key1,key2:pointer):integer;
 const nic:pchar='';
 begin
  if key1=nil then key1:=nic;
  if key2=nil then key2:=nic;
  Compare:=StrComp(key1,key2);
 end;

 {neulozi se kopie ale primo value}
 Procedure TAllAtomCollection.aSet(context,name,value:pchar;perm:TPermanency);
 var index:integer;
     atomcol:PAtomCollection;
 begin
{  if context=nil then context:=empty;{}
  if Search(context,index)
   then PAtomCollection(At(index))^.atomSet(name,value,perm)
   else begin
    if value=nil then exit;
    New(atomcol,Init(10,50));
    if atomcol=nil then Halt(erLowMem);
    if context=nil then erMsg('SetAtom: context=nil');
    atomcol^.context:=StrNew(context);
    atomcol^.atomSet(name,value,perm);
    Insert(atomcol);
    end;
 end;

 {vraci primo value, ne kopii value}
 Function TAllAtomCollection.aGet(context,name:pchar):pchar;
 var index:integer;
 begin
{  if context=nil then context:=empty;{}
  if Search(context,index)
   then aGet:=PAtomCollection(At(index))^.atomGet(name)
   else aGet:=nil;
 end;

 {vraci novy string vytvoreny GetMemem}
 Function TAllAtomCollection.asGet(context:pchar):pchar;
 var index:integer;
 begin
  if Search(context,index)
   then asGet:=PAtomCollection(At(index))^.atomsGet
   else asGet:=nil;
 end;

 {vraci false pokud se stringy rovnaji
              nebo je druhy delsi a jako prvni dalsi znak ma ';'
              nebo je pattern prazdny}
 function StrDontMatch(pattern,str2:pchar):boolean;assembler;
 asm
	PUSH	DS
	CLD
	LES	DI,pattern
        mov ax,es
        or ax,di
        jz @diff
	MOV	SI,DI
	MOV	CX,0FFFFH
	XOR	AX,AX
	CWD
	REPNE	SCASB
	NOT	CX
	MOV	DI,SI
	LDS	SI,str2
        mov ax,ds
        or ax,si
        jz @match_str2empty
        dec cx
	REPE	CMPSB
        {vratit 1 kdyz not zf or [si]<>(#0 and ';')}
        {vratit 0 kdyz zf a [si]=(#0 nebo ;)}
        mov al,1
        jnz @diff
        lodsb
        or al,al
        jz @match
      @match_str2empty:
        sub al,';'
      @match:
      @diff:
	POP	DS
 end;

 {v kontextu promazne atomy bez vetsi permanence}
 Procedure TAllAtomCollection.asDel(acontext:pchar;perm:TPermanency);
 var i:integer;
 begin
  i:=count;
  while i>0 do begin
    dec(i);
    with PAtomCollection(items^[i])^ do
     if not StrDontMatch(acontext,context) then begin
       atomsDel(perm);
       if count=0 then self.AtFree(i);
       end;
    end;
 end;

 { --- Other --- }

 const
  RAtomCollection: TStreamRec = (
    ObjType: 53;
    VmtLink: Ofs(TypeOf(TAtomCollection)^);
    Load: @TAtomCollection.Load;
    Store: @TAtomCollection.Store);


Begin
 RegisterType(RAtomCollection);
End.
