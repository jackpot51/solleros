#!/bin/bash
javac filecopy.java
java filecopy
nasm source/sector.asm -f bin -o sector.bin
nasm kernel.asm -f bin -o kernel.bin
rm SollerOS.bin
dd if=sector.bin of=SollerOS.bin bs=512
dd if=kernel.bin of=SollerOS.bin bs=512 seek=1
cd qemu
qemu -soundhw pcspk -boot c -usb -net nic,model=rtl8139,vlan=1,macaddr=52:54:00:12:34:56 -net user,vlan=1 -hda '../SollerOS.bin'
echo "Press Enter to exit."
read doneit
