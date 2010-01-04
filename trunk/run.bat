@echo off
call build.bat
cd qemu
qemu-img.exe convert -O vmdk ..\SollerOS.bin ..\SollerOS.vmdk
qemu.exe -name SollerOS -L . -serial vc:120Cx40C -serial vc:120Cx40C -kernel-kqemu -localtime -boot c -soundhw sb16,pcspk -usb -hda ..\SollerOS.bin -net tap,ifname=TAP -net nic,model=rtl8139 -net nic,model=ne2k_pci
set /P %doneit="Press Enter."