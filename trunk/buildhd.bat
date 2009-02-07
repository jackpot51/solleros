@echo off
javac "filecopy.java"
java filecopy
nasm source\sector.asm -f bin -o sector.bin
nasm kernel.asm -f bin -o kernel.bin
del SollerOS.bin
dd if=sector.bin of=SollerOS.bin bs=512
dd if=kernel.bin of=SollerOS.bin bs=512 seek=1
del sector.bin
del kernel.bin
dd --list
set /P doneit="Specify the device to boot SollerOS and press enter."
set /P maybe="Are you sure that you want to write SollerOS to %doneit%?(y/n)"
if /I %maybe%==y dd if=SollerOS.bin bs=512 of=%doneit%
set /P isdone="Press enter."