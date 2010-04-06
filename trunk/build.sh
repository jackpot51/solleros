#!/bin/bash
cd fsmaker
javac "fsmaker.java"
java fsmaker
cd ..
rm SollerOS.bin
nasm build/kernel.asm -f bin -o build/kernel.com -l build/kernel.lst
nasm build/sector.asm -f bin -o SollerOS.bin