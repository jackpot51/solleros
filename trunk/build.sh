#!/bin/bash
cd fsmaker
javac "fsmaker.java"
java fsmaker
cd ..
rm -f SollerOS.bin
nasm source/kernel.asm -f bin -o build/kernel.com -l build/kernel.lst || exit 1
nasm source/sector.asm -f bin -o SollerOS.bin -l build/sector.lst || exit 1
