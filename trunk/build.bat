@echo off
cd "F:\Documents and Settings\Administrator\My Documents\My OS\SVN"
nasm Free\sector.asm -f bin -o sector.bin
nasm kernel.asm -f bin -o kernel.bin
dd if=sector.bin of=SollerOS.bin bs=512
dd if=kernel.bin of=SollerOS.bin bs=512 seek=1
set /P done="Done."