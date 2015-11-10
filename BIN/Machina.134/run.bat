@echo off

rem   Spusti Masinu 1.34 z CD, na disk uklada jen dm.ini.
rem   Pouze pro prohlizeni projektu verze 0.xx a 1.xx (Pareniste 5-40).

if a%dm%==a set dm=c:\diskmags\dm
set dm=%dm%134
if exist %dm%\dm.ini goto created
if %dm%==c:\diskmags\dm134 mkdir c:\diskmags
mkdir %dm%
:created
dm o ..\..\archiv ..\..\archiv\par5_15 %1 %2 %3 %4 %5 %6 %7 %8 %9
