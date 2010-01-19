#!/bin/bash
./build.sh
cd qemu
qemu -soundhw pcspk,sb16 -serial vc:120Cx40C -boot c -usb -net nic,model=rtl8139,vlan=1,macaddr=52:54:00:12:34:56 -net user,vlan=1 -hda '../SollerOS.bin'
echo "Press Enter to exit."
read doneit
