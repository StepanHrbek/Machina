
                      { - VùEùCùTùOùR - EùNùGùIùNùE - }
                         { v1.3 pro CiA - 29.3.1997 }

               { kod: Daniel Sykora (ReDox/MovSD) * (C) 1998 }

Unit      Veng;
Interface {$i define.inc}
Uses      Dos,Objects,Memo,VEngine2,Sys,Vga,Fajly;

Const     Max = 1000; { maximalni pocet plosek/bodu }

          Web      = '1'; { konstanty jednotivych stinovacich metod }
          Flat     = '2';
          Gouraud  = '3';
          Phong    = '4';
          TMap     = '5';
          EnvMap   = '6';
          PhongMap = '7';


Type    PVengScene=^TVengScene;
        TVengScene=object(TBitmap)
          Points,Normals,N,Faces,CPoints:^TPoints;
          FaceList    :Array[1..Max] Of TSortData;
          Shading     :Char;
          Painter     :Boolean;
          LastVertex  :integer;
          LastFace    :integer;
          AngleX,AngleY,AngleZ,AX,AY,AZ,XP,YP,ZP :integer;
          Colour      :Array[0..64] of longint;
          Tick        :longint;
          constructor Init(destination:PAbstractMap;w,h:word);
          procedure   Load(name:PathStr);
          procedure   Draw;
          destructor  Done;virtual;
        end;

Implementation

{
 destination - bitmapa jejiz model a paletu ma scena pouzit,
               typicky obrazovka do ktere se pak scena kopiruje
 w,h         - rozmery sceny v pixelech
}
Constructor TVengScene.Init(destination:PAbstractMap;w,h:word);
var i:integer;
begin
 if not inherited Init(destination^.mapModel,w,h) then Fail;
 New(Points);
 New(Normals);
 New(N);
 New(Faces);
 New(CPoints);
 Shading:=Flat;
 Painter:=False;
 InitSinCos(10);
 AngleX:=0;AngleY:=0;AngleZ:=0;
 xp:=0;yp:=0;zp:=280;AY:=0;AX:=0;AZ:=0;
 for I:=0 to 64 do Colour[i]:=destination^.Color(Round(I*I/17),Round(I*I/17),Round(I*I/17),255);
end;


Procedure TVengScene.Load(name:PathStr);

 {verze pro obyc fajl na disku
 procedure LoadData;
 Var HorAngle,VertAngle,Count : Integer;
     CX,CY,RX1,RY1,RZ1,RX2,RY2,RZ2 : Real;
     F:File of Integer;
     X1,Y1,Z1,Index:Integer;
 Begin
 Assign(F,name);
 Reset(F);
 Read(F,LastVertex);
 Read(F,LastFace);
 Inc(LastFace);
 Inc(LastVertex);
 for Index:=1 to LastVertex do
  begin
   Read(F,X1,Y1,Z1);
   Points^[Index][1]:=X1;
   Points^[Index][2]:=Y1;
   Points^[Index][3]:=Z1;
  end;
 for Index:=1 to LastFace do
  begin
   Read(F,X1,Y1,Z1);
   Faces^[Index,1]:=X1+1;
   Faces^[Index,2]:=Y1+1;
   Faces^[Index,3]:=Z1+1;
  end;
 Close(F);
  For Count:=1 To LastFace Do
  Begin
   RX1:=Points^[Faces^[Count,2],1]-Points^[Faces^[Count,1],1];
   RY1:=Points^[Faces^[Count,2],2]-Points^[Faces^[Count,1],2];
   RZ1:=Points^[Faces^[Count,2],3]-Points^[Faces^[Count,1],3];
   RX2:=Points^[Faces^[Count,3],1]-Points^[Faces^[Count,1],1];
   RY2:=Points^[Faces^[Count,3],2]-Points^[Faces^[Count,1],2];
   RZ2:=Points^[Faces^[Count,3],3]-Points^[Faces^[Count,1],3];
   Normals^[Count,1]:=Round(RY1*RZ2-RY2*RZ1);
   Normals^[Count,2]:=Round(RZ1*RX2-RZ2*RX1);
   Normals^[Count,3]:=Round(RX1*RY2-RX2*RY1);
  End;
 End;
 }

 procedure LoadData;
 Var HorAngle,VertAngle,Count : Integer;
     CX,CY,RX1,RY1,RZ1,RX2,RY2,RZ2 : Real;
     s:PStream;
     X1,Y1,Z1,Index:Integer;
 Begin
 s:=fileReadStream(name);
 with s^ do
  begin
   Read(LastVertex,2);
   Read(LastFace,2);
   Inc(LastFace);
   Inc(LastVertex);
   for Index:=1 to LastVertex do
    begin
     Read(X1,2);
     Read(Y1,2);
     Read(Z1,2);
     Points^[Index][1]:=X1;
     Points^[Index][2]:=Y1;
     Points^[Index][3]:=Z1;
    end;
   for Index:=1 to LastFace do
    begin
     Read(X1,2);
     Read(Y1,2);
     Read(Z1,2);
     Faces^[Index,1]:=X1+1;
     Faces^[Index,2]:=Y1+1;
     Faces^[Index,3]:=Z1+1;
    end;
   KillObj(s);
   For Count:=1 To LastFace Do
    Begin
     RX1:=Points^[Faces^[Count,2],1]-Points^[Faces^[Count,1],1];
     RY1:=Points^[Faces^[Count,2],2]-Points^[Faces^[Count,1],2];
     RZ1:=Points^[Faces^[Count,2],3]-Points^[Faces^[Count,1],3];
     RX2:=Points^[Faces^[Count,3],1]-Points^[Faces^[Count,1],1];
     RY2:=Points^[Faces^[Count,3],2]-Points^[Faces^[Count,1],2];
     RZ2:=Points^[Faces^[Count,3],3]-Points^[Faces^[Count,1],3];
     Normals^[Count,1]:=Round(RY1*RZ2-RY2*RZ1);
     Normals^[Count,2]:=Round(RZ1*RX2-RZ2*RX1);
     Normals^[Count,3]:=Round(RX1*RY2-RX2*RY1);
    End;
  end;
 End;

 procedure CalcVN;
 Var I,J,NF : Integer;
     RelX1,RelY1,RelZ1,RelX2,RelY2,RelZ2,VL : Real;
 Begin
  For I:=1 To LastVertex Do
  Begin
   RelX1:=0;
   RelY1:=0;
   RelZ1:=0;
   NF:=0;
   For J:=1 To LastFace Do
   Begin
    If (Faces^[J,1]=I) Or (Faces^[J,2]=I) Or (Faces^[J,3]=I) Then
    Begin
     RelX1:=RelX1+Normals^[J,1];
     RelY1:=RelY1+Normals^[J,2];
     RelZ1:=RelZ1+Normals^[J,3];
     Inc(NF);
    End;
   End;
   If NF<>0 then
   Begin
    RelX1:=RelX1/NF;
    RelY1:=RelY1/NF;
    RelZ1:=RelZ1/NF;
    VL:=Sqrt(RelX1*RelX1+RelY1*RelY1+RelZ1*RelZ1);
    if VL=0 then VL:=1;
    N^[I,1]:=Round((RelX1/VL)*120);
    N^[I,2]:=Round((RelY1/VL)*120);
    N^[I,3]:=Round((RelZ1/VL)*120);
   End;
  End;
 End;

begin
 LoadData;
 CalcVN;
end;


Procedure TVengScene.Draw;

 procedure ClipXY(var X,Y:Integer);
 begin
  x:=Bounded(x,0,sizeX-1);
  y:=Bounded(y,0,sizeY-1);
 end;

var     X,Y,X1,Y1,Z1,X2,Y2,Z2,X3,Y3,Z3,I,U1,U2,U3,V1,V2,V3,C,D1,D2,
        D3,DZ12,DZ23,DZ13 : Integer;
        Id,FaceId : Word;
        C1,C2,C3 : Longint;
begin
 Rotate3D(Points^,CPoints^,LastVertex,AngleX,AngleY,AngleZ);
 if Shading=TMap
  then Rotate3D(N^,Normals^,LastVertex,AX,AY,0)
  else Rotate3D(N^,Normals^,LastVertex,AngleX+AX,AngleY+AY,AngleZ+AZ);
 Move3D(CPoints^,LastVertex,xp,yp,zp);
 AddPerspective(CPoints^,LastVertex,8,0);
 Move3D(CPoints^,LastVertex,sizeX div 2,sizeY div 2,0);
 for Id:=1 to LastFace do
 begin
  FaceList[Id].iD:=Id;
  FaceList[Id].Value:=CPoints^[Faces^[Id,1],3]+
   CPoints^[Faces^[Id,2],3]+CPoints^[Faces^[Id,3],3];
 end;
 QSort(FaceList,LastFace);
 For Id:=1 To LastFace Do Begin
  FaceId:=FaceList[Id].ID;
  X1:=CPoints^[Faces^[FaceId,1],1];
  Y1:=CPoints^[Faces^[FaceId,1],2];
  Z1:=CPoints^[Faces^[FaceId,1],3];
  X2:=CPoints^[Faces^[FaceId,2],1];
  Y2:=CPoints^[Faces^[FaceId,2],2];
  Z2:=CPoints^[Faces^[FaceId,2],3];
  X3:=CPoints^[Faces^[FaceId,3],1];
  Y3:=CPoints^[Faces^[FaceId,3],2];
  Z3:=CPoints^[Faces^[FaceId,3],3];
  If (IsVisible(X1,Y1,X2,Y2,X3,Y3)<0) or Painter Then
    case Shading of
    Web:begin
         ClipXY(X1,Y1);ClipXY(X2,Y2);ClipXY(X3,Y3);
         C1:=Colour[Abs(Normals^[Faces^[FaceId,1],3]) div 2];
         C2:=Colour[Abs(Normals^[Faces^[FaceId,2],3]) div 2];
         C3:=Colour[Abs(Normals^[Faces^[FaceId,3],3]) div 2];
         Line(x1,y1,x2,y2,C1,@self);
         Line(x2,y2,x3,y3,C2,@self);
         Line(x1,y1,x3,y3,C3,@self)
        end;
    Flat:begin
         U1:=Normals^[Faces^[FaceId,1],3];
         U2:=Normals^[Faces^[FaceId,2],3];
         U3:=Normals^[Faces^[FaceId,3],3];
         C1:=Colour[Abs((U1+U2+U3) div 6)];
         FlatFace(x1,y1,x2,y2,x3,y3,c1,@self);
        end;
     end
    End;
end;


Destructor TVengScene.Done;
begin
 Dispose(Points);
 Dispose(Normals);
 Dispose(CPoints);
 Dispose(Faces);
 Dispose(N);
 inherited Done;
end;


End.