[BITS 32]
[ORG 0x400000]
start:
db "EX"
jmp $
;finding out the ways to emulate certain linux calls. This will be added to the kernel eventually