@echo off
nasm Free/hdsector.asm -f bin -o hdsector.bin
nasm kernel.asm -f bin -o kernel.bin
nasm kernel-com.asm -f bin -o kernel.com
del SollerOS.bin
dd if=hdsector.bin of=SollerOS.bin bs=512
dd if=kernel.bin of=SollerOS.bin bs=512 seek=1
qemu.lnk -L "C:\Program Files\qemu" -boot c -std-vga -soundhw sb16 -hda "C:\Users\Jackpot\Documents\My OS\SVN\Protected Mode\SollerOS.bin" -usb -net nic,model=rtl8139,vlan=1,macaddr=52:54:00:12:34:56 -net user,vlan=1
set /P %doneit="Press Enter."