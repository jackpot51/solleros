@echo off
call build.bat
dd --list
set /P doneit="Specify the device to boot SollerOS and press enter."
set /P maybe="Are you sure that you want to write SollerOS to %doneit%?(y/n)"
if /I %maybe%==y dd if=SollerOS.bin bs=512 of=%doneit%
set /P isdone="Press enter."