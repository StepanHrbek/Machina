
PROCEDURE ChytreNaframuj32Lines(line:word);assembler;
const now:word=9999;
 asm
   {reframe ??,??,-,- nebo ??,-,-,- nebo nic pri line=9999}
   mov ax,line
   cmp ax,9999;jnz @normal;mov now,ax;jmp @done
   @normal:
   mov bx,ax;shr bx,5;and ax,31;shl ax,5;add ax,frameseg;mov framewriseg,ax
   cmp bx,now;jz @done
   mov now,bx
   mov ax,4400h;mov dx,now.handle;push bx;int 67h;pop bx;inc bx
   mov ax,4401h;mov dx,now.handle;int 67h;
   @done:
 end;

procedure putter_tab;assembler;
const  L=tex_ramecekcolorLo;
       H=tex_ramecekcolorHi;
{0-mazat nulou
 1-vkladat texturu
 2-skipnout
 ?-stos ?}
asm
 {starter od novy pagy}
 db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,255{normal}
 db 0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,255{skvira1}
 db L,L,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,255{ramecek2}
 db 0,L,L,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,255{skvira1 a ramecek2}
 {starter napichnutej na predchozi page}
 db 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,255{prekryv v pulce minulyho}
 db 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,255{prekryv v pulce minulyho, 1 black}
 db 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,255{prekryv v pulce minulyho, 2 black}
 db 1,2,2,2,1,2,2,1,2,2,1,2,1,2,1,2,1,2,1,2,1,2,1,1,2,1,1,2,1,1,1,2,255{mix1}
 db 0,1,0,0,2,2,2,2,2,2,0,1,1,1,0,0,2,2,2,2,0,1,1,1,1,1,1,0,0,2,2,0,255{mix2bot}
 db 0,0,1,0,2,2,2,2,2,2,0,0,1,1,1,0,2,2,2,2,0,0,1,1,1,1,1,0,2,2,0,0,255{mix2top}
 {ender}
 db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,255{normal}
 db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,255{skvira1}
 db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,H,H,255{ramecek2}
 db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,H,H,0,255{ramecek2 a skvira1}
 end;

PROCEDURE FillEmsPagesWorksegem(kam,radek,x0,sir:word;starter,ender,writer:char);assembler;
var   RadekCounter:word;
 asm
     {fill ems with texture 256x256}
      mov ax,radek;mov RadekCounter,ax;cmp ax,0;jz @end
      cmp sir,0;jz @end
      sub writer,'0'

      {---WRITER---}
      @nextpage:

      {selektne spravnej writerskript (32byte tab)}
      mov ax,RadekCounter
      cmp ax,1;jnz @notender;mov bl,ender;add bl,pocet_starteru;jmp @selected;@notender:
      cmp ax,radek;jnz @notstarter;mov bl,starter;jmp @selected;@notstarter:
      mov bl,'0'
      @selected:
      sub bl,'0'
      mov al,33;mul bl;add ax,offset putter_tab;mov bx,ax

      {naframuje}
      pusha;mov ax,4400h;mov bx,kam;mov dx,now.handle;int 67h;popa
      mov es,frameseg
      PUSH ds;mov ds,workseg
      mov si,kam;shl si,13
      mov di,x0

      {writuje 32 linek}
      @nextline:
       mov cx,sir
       mov ah,[cs:bx];inc bx
       cmp ah,2;jz @movsdone
       cmp ah,1;jz @movsthingy
       cmp ah,255;jz @32linesEnd

      @stosThingy:
       mov al,ah;push ax;push ax;db 66h;pop ax
       push si
       push di
       {zarovna DI na sudou}
       test di,1;jz @s1ok;stosb;dec cx;jz @movsdone;@s1ok:
       {zarovna DI na dablsudou}
       test di,2;jz @s2ok;stosw;sub cx,2;jz @movsdone;@s2ok:
       {dodela zbytek}
       push cx;shr cx,2;db 66h;rep stosw;pop cx;and cx,3;rep stosb
       {goto next}
       jmp @movsdone_pop

      @movsThingy:
       push si
       push di
       {levej ramecek}
       test writer,w_ram;jz @mnedelat_ramecek1
         sub cx,2;jc @movsdone;mov al,tex_ramecekcolorLo;stosb;inc si
         @mnedelat_ramecek1:
       {zarovna DI na sudou}
       test di,1;jz @m1ok;movsb;dec cx;jz @movsdone;@m1ok:
       {zarovna DI na dablsudou}
       test di,2;jz @m2ok;movsw;sub cx,2;jz @movsdone;@m2ok:
       {dodela zbytek}
       push cx;shr cx,2;db 66h;rep movsw;pop cx;and cx,3;rep movsb
       {pravej ramecek}
       test writer,w_ram;jz @mnedelat_ramecek2
         mov al,tex_ramecekcolorHi;stosb
         @mnedelat_ramecek2:

      @movsdone_pop:
       pop di
       pop si
      @movsdone:
       add di,wrisir
       add si,256
      jmp @nextline

      @32linesEnd:
      POP ds
      inc kam{next 16K page}
      dec RadekCounter;jnz @nextpage

      @end:
      end;



PROCEDURE PlaceMixedTexture(st:string);
var   basetexture,modifikant:char;
      sub:string;
      st1:string;
      i,j,lines,nowline,wasline,code,x0,xsir:word;
      starter,ender,writer:char;
      menitNowline:byte;
label 1,nedelete11,putit,nextflag;
begin
 nowline:=0;
 1:
 wasline:=nowline;

 {odstrihne jedno slovo}
 sub:=CutStringFromString(' ',st);
 if sub='' then exit;

 {nastavi defaults}
 menitNowline:=0;
 starter:='0';
 ender:='0';
 writer:='0';
 x0:=(wrisir-vissir) div 2;
 xsir:=vissir;

 {nacte flags}
 nextflag:
 case sub[1] of '|':begin i:=1;menitNowline:=menitNowline xor 1;end;
                '/':begin i:=1;if nowline>0 then dec(nowline) else errorhalt(49);dec(wasline);end;
                '-','=':begin
                    i:=pos('.',sub);
                    st1:=copy(sub,2,i-2);
                    val(st1,j,code);
                    if code>0 then errorhalt(49);
                    case sub[1] of '-':if nowline>=j then dec(nowline,j) else errorhalt(49);
                                   '=':nowline:=j;
                                   end;
                    menitNowline:=menitNowline xor 2;{=10. znamena natvrdo goto line 10}
                    end;
                '(':begin
                    st1:=CutStringFromString(',',sub);delete(st1,1,1);
                    val(st1,x0,code);
                    if (x0>=512) or (code>0) then errorhalt(49);
                    st1:=CutStringFromString(')',sub);
                    val(st1,xsir,code);
                    if (x0+xsir>512) or (code>0) then errorhalt(49);
                    goto nextflag;{skipne delete(sub,1,1)}
                    end;
                else goto nedelete11;
                end;
 delete(sub,1,i);
 goto nextflag;
 nedelete11:

 {zjisti na kolik radek to bude}
 i:=1;while (length(sub)>=i) and (sub[i]>='0') and (sub[i]<='9') do inc(i);dec(i);
 if i=0 then lines:=999 else val(copy(sub,1,i),lines,code);
 if nowline+lines>(now.radek shr 1) then lines:=(now.radek shr 1)-nowline;
 delete(sub,1,i);

 {zjisti jaka textura a vygeneruje ji}
 if sub='' then errorhalt(49);
 basetexture:=sub[1];
 delete(sub,1,1);
 MakeTextureInSegWithCache(basetexture,workseg);

 {nacte a provede pozadovane upravy textury}
 if sub='' then goto putit;
 modifikant:=sub[1];
 delete(sub,1,1);
 case modifikant of '-','0':;
                    end;

 {nacte starter,ender,writer}
 if sub='' then goto putit;
 starter:=sub[1];
 case starter of '-':starter:='0';
                 end;
 delete(sub,1,1);

 if sub='' then goto putit;
 ender:=sub[1];
 case ender of '-':ender:='0';
               end;
 delete(sub,1,1);

 if sub='' then goto putit;
 writer:=sub[1];
 case writer of '-':writer:='0';
                end;
 delete(sub,1,1);

 if sub>'' then errorhalt(49);

 {putne to a kdyz neni konec, zaloopuje k dalsimu slovu}
 putit:
 if basetexture<>'z' then FillEmsPagesWorksegemPro(now.radek shl 4,
        nowline,lines,x0,xsir,ord(starter)-48,ord(ender)-48,ord(writer)-48);
 case menitNowline of
    0:nowline:=wasline+lines;
    1,2:nowline:=wasline;
    3:nowline:=nowline+lines;
    end;
 {if nowline<(now.radek shr 1) then} goto 1;
end;

PROCEDURE PlaceNopeTexture(n:byte);assembler;
  asm
      mov cx,now.radek;shr cx,1;mov bx,0;
      @nextpage:push cx
      mov ax,4400h;mov dx,now.handle;push bx;int 67h;pop bx;inc bx
      mov es,frameseg
      mov di,0;mov al,n;mov ah,al;mov cx,8*1024/2;push ax;push ax;db 66h;pop ax;db 66h;rep stosw
      pop cx;loop @nextpage
      end;

PROCEDURE FillEmsWorksegem;assembler;
 asm
     {fill ems with texture 256x256}
      mov ax,now.radek;shr ax,1;mov [cs:offset @za-2],ax
      mov bx,0
      @nextpage:push bx;
      mov ax,4400h;mov dx,now.handle;push bx;int 67h;pop bx
      mov es,frameseg
      push ds;mov ds,workseg

      mov si,bx;shl si,13
      mov di,0
      mov dx,32;@1:
      mov cx,128;db 66h;rep movsw;sub si,256
      dec dx;jnz @1

      pop ds
      pop bx;inc bx;cmp bx,260;@za:jnz @nextpage
      end;

PROCEDURE PlaceNormalTexture(j:char);
const texturyhotovy:byte=0;
      poradiC=2;
      poradiD=3;
var   poradiVems:byte;
begin
 case j of 'a':poradiVems:=0;
           'b':poradiVems:=1;
           'c':poradiVems:=poradiC;
           'd':poradiVems:=poradiD;
          else poradiVems:=255;
          end;
 {specialni pripad textur c a d}
 if ((j='c') or (j='d')) and ((texturyhotovy and (4+8))=0) then begin
   texturyhotovy:=texturyhotovy or (4+8);
   MakeTextureInSeg('c',workseg);
   NaframujNaTexturu(poradiC);
   CopySeg(workseg,frameseg);
   if j='c' then FillEmsWorksegem;
   MakeTextureInSeg('d',workseg);
   NaframujNaTexturu(poradiD);
   CopySeg(workseg,frameseg);
   if j='d' then FillEmsWorksegem;
   end
 {bezny textury ukladany do ems}
 else begin
   if poradiVems<textur then begin
     NaframujNaTexturu(poradiVems);
     if texturyhotovy and (1 shl poradiVems)=0 then MakeTextureInSeg(j,frameseg);
     CopySeg(frameseg,workseg);
     texturyhotovy:=texturyhotovy or (1 shl poradiVems);
     end
 {bezny textury neukladany do ems}
   else
     MakeTextureInSeg(j,workseg);

   FillEmsWorksegem;
   end;
end;

PROCEDURE PlaceTexture(ch:char);
begin
  case ch of 'z':;
             'y':PlaceNopeTexture(0);
            else PlaceNormalTexture(ch);
            end;
end;


PROCEDURE PlaceSingleTexture(j:char);
begin
 MakeTextureInSegWithCache(j,workseg);
 FillEmsPagesWorksegem(0,now.radek shr 1,false,false);
end;

PROCEDURE PlaceTexture(st:string);
begin
  if length(st)>1 then PlaceMixedTexture(st)
                  else case st[1] of 'z':;
                                     'y':PlaceNopeTexture(0);
                                    else PlaceSingleTexture(st[1]);
                                    end;
end;

