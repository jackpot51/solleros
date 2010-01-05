@echo off
set CYGWIN=nodosfilewarning
javac "unfs.java"
javac "fsmaker.java"
java fsmaker
nasm img.asm -o "../../included/_img.bin"
set /P %doneit="Press Enter."