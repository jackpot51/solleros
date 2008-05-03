@echo off
cd "F:\Documents and Settings\Administrator\My Documents\My OS\SVN\Protected Mode"
del SollerOS-exp.bin
..\nasm kernel-com.asm -f bin -o kernel.com
..\nasm Free\sector.asm -f bin -o sector.bin
..\nasm kernel.asm -f bin -o kernel.bin
..\dd if=sector.bin of=SollerOS-exp.bin bs=512
..\dd if=kernel.bin of=SollerOS-exp.bin bs=512 seek=1
set /P done="Put in your floppy disk to boot SollerOS and press enter."
..\dd if=SollerOS-exp.bin of=\\?\Device\Floppy0 bs=512
set /P done="Finished writing to floppy."