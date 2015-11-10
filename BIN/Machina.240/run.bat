@echo off

rem   Spusti Masinu 2.40 z CD, na disk uklada jen dm.ini.
rem   Pouze pro prohlizeni projektu do verze 3.09 (Pareniste 5-40, RT 41-68).

if a%dm%==a set dm=c:\diskmags\dm
set dm=%dm%240
if exist %dm%\dm.ini goto created
if %dm%==c:\diskmags\dm240 mkdir c:\diskmags
mkdir %dm%
:created
dm o ..\..\archiv ..\..\archiv\par5_15 %1 %2 %3 %4 %5 %6 %7 %8 %9
