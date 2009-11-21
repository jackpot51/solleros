#!/bin/bash
javac filecopy.java
java filecopy
nasm source/sector.asm -f bin -o sector.bin
nasm kernel.asm -f bin -o kernel.bin
rm SollerOS.bin
dd if=sector.bin of=SollerOS.bin bs=512
dd if=kernel.bin of=SollerOS.bin bs=512 seek=1
rm sector.bin
rm kernel.bin
ls /dev/hd*
ls /dev/sd*
echo "Specify the device to boot SollerOS and press enter."
read doneit
echo "Are you sure that you want to write SollerOS to $doneit?(y/n)"
read maybe
if [ $maybe == y ]
then
sudo dd if=SollerOS.bin bs=512 of=$doneit
sudo sync
fi
echo "Press enter."
read isdone
