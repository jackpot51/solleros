#!/bin/bash
nasm Free/sector.asm -f bin -o sector.bin
nasm kernel-linux.asm -f bin -o kernel.bin
dd if=sector.bin of=SollerOS-linux.bin bs=512
dd if=kernel.bin of=SollerOS-linux.bin bs=512 seek=1
qemu -no-kqemu -std-vga -boot a -fda SollerOS-linux.bin -usb -net nic,model=rtl8139,vlan=1,macaddr=52:54:00:12:34:56 -net user,vlan=1 -serial stdio -d int,pcall
