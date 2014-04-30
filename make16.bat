set CPS230_ROOT=c:\cps230
set ASM=%CPS230_ROOT%\bin\jwasm
set LINK=%CPS230_ROOT%\bin\jwlink
set INCLUDE=c:\Irvine
set LIB=c:\Irvine

%ASM% -nologo -omf -Zm -Fl -Zi -c %1.asm
if errorlevel 1 goto terminate
%LINK% format dos option quiet,map file %1.obj library Irvine16.lib

:terminate
