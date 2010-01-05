cd qemu
qemu-img.exe convert -O vmdk ..\SollerOS.bin ..\SollerOS.vmdk
qemu-img.exe convert -O vpc ..\SollerOS.bin ..\SollerOS.vhd