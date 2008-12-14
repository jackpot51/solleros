@echo off
nasm Free/hdsector.asm -f bin -o hdsector.bin
nasm kernel.asm -f bin -o kernel.bin
nasm kernel-com.asm -f bin -o kernel.com
del SollerOS.bin
dd if=hdsector.bin of=SollerOS.bin bs=512
dd if=kernel.bin of=SollerOS.bin bs=512 seek=1
dd --list
set /P doneit="Specify the device to boot SollerOS and press enter."
set /P maybe="Are you sure that you want to write SollerOS to %doneit%?(y/n)"
if /I %maybe%==y dd if=SollerOS.bin of=%doneit%
set /P isdone="Press enter."