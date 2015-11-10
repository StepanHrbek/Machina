@echo off

rem   Spusti Masinu 3.52 z CD, na disk uklada jen dm.ini.

if a%dm%==a set dm=c:\diskmags\dm
set dm=%dm%352
if exist %dm%\dm.ini goto created
if %dm%==c:\diskmags\dm352 mkdir c:\diskmags
mkdir %dm%
:created
dm o ..\..\archiv ..\..\archiv\par5_15 %1 %2 %3 %4 %5 %6 %7 %8 %9
