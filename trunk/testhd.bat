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
cd qemu
qemu.exe -L . -boot c -std-vga -soundhw sb16 -usb -net nic,model=rtl8139,vlan=1,macaddr=52:54:00:12:34:56 -net user,vlan=1 -hda ../SollerOS.bin
set /P %doneit="Press Enter."