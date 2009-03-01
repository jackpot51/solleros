@echo off
javac "filecopy.java"
java filecopy
nasm source\sector.asm -f bin -o sector.bin
nasm kernel.asm -f bin -o kernel.bin -l kernel.lst
del SollerOS.bin
dd if=sector.bin of=SollerOS.bin bs=512
dd if=kernel.bin of=SollerOS.bin bs=512 seek=1
cd qemu
qemu.exe -L . -boot c -soundhw sb16 -usb -std-vga -net nic,model=rtl8139 -net user -hda ../SollerOS.bin
set /P %doneit="Press Enter."