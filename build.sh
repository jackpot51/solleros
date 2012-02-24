#!/bin/bash
cd fsmaker
javac "fsmaker.java"
java fsmaker
cd ..
rm SollerOS.bin
nasm source/kernel.asm -f bin -o build/kernel.com -l build/kernel.lst
nasm source/sector.asm -f bin -o SollerOS.bin -l build/sector.lst
