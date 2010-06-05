#!/bin/bash
./build.sh
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
