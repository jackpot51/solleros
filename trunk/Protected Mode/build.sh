#!/bin/bash
nasm Free/sector.asm -f bin -o sector.bin
nasm kernel-linux.asm -f bin -o kernel.bin
dd if=sector.bin of=SollerOS-linux.bin bs=512
dd if=kernel.bin of=SollerOS-linux.bin bs=512 seek=1
echo Put in your floppy disk to boot SollerOS and press enter.
read doneit
dd if=SollerOS-linux.bin of=/dev/fd0 bs=512
