@echo off
call build.bat
cd qemu
qemu.exe -m 512 -cpu coreduo -name SollerOS -L . -serial vc:120Cx40C -kernel-kqemu -localtime -boot c -soundhw sb16,pcspk -usb -hda ..\SollerOS.bin -net nic,model=ne2k_pci -net nic,model=e1000 -net nic,model=rtl8139 -net user 
set /P %doneit="Press Enter."
