@echo off
set CYGWIN=nodosfilewarning
javac "unfs.java"
javac "filecopy.java"
java filecopy
nasm img.asm -o "../included/_img.bin"
set /P %doneit="Press Enter."