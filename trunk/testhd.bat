@echo off
set CYGWIN=nodosfilewarning
javac "filecopy.java"
java filecopy
nasm source\sector.asm -f bin -o sector.bin
nasm kernel.asm -f bin -o kernel.bin
del SollerOS.bin
dd if=sector.bin of=SollerOS.bin bs=512
dd if=kernel.bin of=SollerOS.bin bs=512 seek=1
cd qemu
qemu-img.exe convert -O vmdk ..\SollerOS.bin ..\SollerOS.vmdk
qemu.exe -L . -kernel-kqemu -localtime -boot c -soundhw all -usb -net nic,model=rtl8139 -net user -hda ../SollerOS.bin
set /P %doneit="Press Enter."