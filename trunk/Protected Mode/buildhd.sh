#!/bin/bash
nasm Free/hdsector.asm -f bin -o hdsector.bin
nasm kernel-linux.asm -f bin -o kernel.bin
rm SollerOS.bin
dd if=hdsector.bin of=SollerOS.bin bs=512
dd if=kernel.bin of=SollerOS.bin bs=512 seek=1
echo Specify the device to boot SollerOS and press enter.
read doneit
ls $doneit*
echo Are you sure that you want to write SollerOS to $doneit"?(y/n)"
read maybe
if [ $maybe = "y" ]
then
dd if=SollerOS.bin of=$doneit bs=512
fi
