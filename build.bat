@echo off
set CYGWIN=nodosfilewarning
copy nasm.exe %SYSTEMROOT%\System32
cd fsmaker
javac "fsmaker.java"
java fsmaker
cd ..
del SollerOS.bin
nasm build\kernel.asm -f bin -o build\kernel.com -l build\kernel.lst
SET ERR=%ErrorLevel%
nasm build\sector.asm -f bin -o SollerOS.bin
IF %ERR% NEQ 0 set /P %doneit="Press Enter."