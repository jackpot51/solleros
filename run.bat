@echo off
call build.bat
cd qemu
qemu-img.exe convert -O vmdk ..\SollerOS.bin ..\SollerOS.vmdk
qemu.exe -L . -kernel-kqemu -localtime -boot c -soundhw sb16,pcspk -usb -net nic,model=rtl8139 -net user -hda ../SollerOS.bin
set /P %doneit="Press Enter."