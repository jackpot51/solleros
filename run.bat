@echo off
call build.bat
cd qemu
qemu-img.exe convert -O vmdk ..\SollerOS.bin ..\SollerOS.vmdk
qemu.exe -L . -serial vc:120Cx40C -kernel-kqemu -localtime -boot c -soundhw sb16,pcspk -usb -hda ..\SollerOS.bin -net nic,model=ne2k_pci -net user
set /P %doneit="Press Enter."