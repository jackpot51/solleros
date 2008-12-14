#!/bin/bash
nasm Free/sector.asm -f bin -o sector.bin
nasm kernel-linux.asm -f bin -o kernel.bin
rm SollerOS.bin
dd if=sector.bin of=SollerOS.bin bs=512
dd if=kernel.bin of=SollerOS.bin bs=512 seek=1
echo Put in your floppy disk to boot SollerOS and press enter.
read doneit
dd if=SollerOS.bin of=/dev/fd0 bs=512
