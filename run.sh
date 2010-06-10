#!/bin/bash
./build.sh
cd qemu
qemu -soundhw pcspk,sb16 -serial stdio -boot c -usb -net nic,model=ne2k_pci,vlan=1 -net nic,model=e1000,vlan=1 -net nic,model=rtl8139,vlan=1 -net user,vlan=1 -hda '../SollerOS.bin' -localtime
echo "Press Enter to exit."
read doneit
