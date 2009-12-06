@echo off
set CYGWIN=nodosfilewarning
javac "unfs.java"
javac "filecopy.java"
java filecopy
nasm img.asm -o system-image
set /P %doneit="Press Enter."