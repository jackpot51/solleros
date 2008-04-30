#!/bin/bash
nasm Free\sector.asm -f bin -o sector.bin
nasm kernel.asm -f bin -o kernel.bin
dd if=sector.bin of=SollerOS.bin bs=512
dd if=kernel.bin of=SollerOS.bin bs=512 seek=1
echo "Put in your floppy disk to boot SollerOS and press enter."
read done
dd if=SollerOS.bin of=/dev/floppy bs=512