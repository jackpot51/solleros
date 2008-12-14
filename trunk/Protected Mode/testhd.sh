#!/bin/bash
nasm Free/hdsector.asm -f bin -o hdsector.bin
nasm kernel-linux.asm -f bin -o kernel.bin
dd if=hdsector.bin of=SollerOS-linux.bin bs=512
dd if=kernel.bin of=SollerOS-linux.bin bs=512 seek=2
qemu  -boot c -std-vga -soundhw sb16 -hda SollerOS-linux.bin -usb -net nic,model=rtl8139,vlan=1,macaddr=52:54:00:12:34:56 -net user,vlan=1 -serial stdio 
#extra stuff(debugging): "-d int,pcall"
