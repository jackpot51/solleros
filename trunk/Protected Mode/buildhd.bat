
@echo off
nasm Free/hdsector.asm -f bin -o hdsector.bin

nasm kernel.asm -f bin -o kernel.bin

nasm kernel-com.asm -f bin -o kernel.com
dd if=hdsector.bin of=SollerOS-linux.bin bs=512

dd if=kernel.bin of=SollerOS-linux.bin bs=512 seek=1

dd --list
set /P %doneit="Specify the device to boot SollerOS and press enter.
"
set /P %maybe="Are you sure that you want to write SollerOS to %doneit%?(y/n)"
if /I %maybe%=="y" dd if=SollerOS-linux.bin of=%doneit%
set /P %done="Press enter."