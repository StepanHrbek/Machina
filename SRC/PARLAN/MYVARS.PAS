Unit MyVars;{$i define.inc}

{Registrace identifikatoru,o nichz se uz vi - provadi se i zabehu}

{$IFNDEF DPMI} {$IFNDEF WINDOWS} {$DEFINE REAL} {$ENDIF} {$ENDIF}
interface
uses MyDefin,MyDef;

function RegisterVar (S : String; XVars : PPData) : PData; {$IFNDEF REAL} export; {$ENDIF}
function FindVar (S : String) : PData; {$IFNDEF REAL} export; {$ENDIF} {Hleda krabicku pri Analyze,parametry viz predchozi}
function FindBeforeVar (S : String) : PData; {$IFNDEF REAL} export; {$ENDIF} {V^.Next has found}
procedure RemoveVar (S : String); {$IFNDEF REAL} export; {$ENDIF}
{Registrace identifikatoru,o nichz se uz vi - provadi se i zabehu}

implementation
uses MyCode,Strings;

function RegisterVar;
 {Na vstupu identifikator na vystupu ukazatel na krabicku ve ktere je ulozeno jmeno a hodnota
  - vsude kde se vyskytne ve zdrojovem textu identifikator se pracuje s ukazatelem na tuto krabicku}
 var
   V : PData;

 begin
   V:=XVars^;
   while (V <> nil) and (V^.Item^.Name^ <> UpString (S)) do V:=V^.Next;
   if V = nil then begin
     V:=GetFree; V^.T:=cVar; V^.Value:=NULL;
     V^.Name:=NewStr (UpString (S));
     PushArg (XVars^,V);
   end else V:=V^.Item;
   RegisterVar:=V;
 end;

function FindVar (S : String) : PData; {Hleda krabicku pri Analyze,parametry viz predchozi}
 var
   V : PData;
 begin
   V:=Vars;
   while (V <> nil) and (UpString (V^.Item^.Name^) <> UpString (S)) do
    V:=V^.Next;
   if V <> nil then V:=V^.Item;
   FindVar:=V;
 end;

function FindBeforeVar (S : String) : PData; {Hleda krabicku pri Analyze,parametry viz predchozi}
 var
   V : PData;
 begin
   V:=Vars; FindBeforeVar:=V;
   if V^.Item^.Name^ = UpString (S) then Exit;
   while (V^.Next <> nil) and (V^.Next^.Item^.Name^ <> UpString (S)) do
    V:=V^.Next;
   if V^.Next = nil then V:=nil;
   FindBeforeVar:=V;
 end;

procedure RemoveVar (S : String); {Hleda krabicku pri Analyze,parametry viz predchozi}
 var
   V : PData;
 begin
   V:=FindBeforeVar (S); if V = nil then Exit;
   if V = Vars then Vars:=Vars^.Next
    else begin
     if V^.Next = OldVars then OldVars:=V^.Next^.Next;
     V^.Next:=V^.Next^.Next;
   end;
 end;

end.