@echo off

rem   Spusti Masinu 3.52 z CD, na disk uklada jen dm.ini.
rem
rem   Spusti ji bez zvuku, coz ma vyznam napr.
rem   - v DOSemu (Linux), ktery zvuk v Masinach 3.xx emulovat neumi
rem   - na pocitacich s nedostatkem pameti (4-16MB), trochu se ji tim usetri

if a%dm%==a set dm=c:\diskmags\dm
set dm=%dm%352
if exist %dm%\dm.ini goto created
if %dm%==c:\diskmags\dm352 mkdir c:\diskmags
mkdir %dm%
:created
dm.exe o ..\..\archiv ..\..\archiv\par5_15 %1 %2 %3 %4 %5 %6 %7 %8 %9
