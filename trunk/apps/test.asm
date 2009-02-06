[BITS 32]
[ORG 0x100000]
db "EX"
mov esi, 0x200000
mov edi, file
mov ah, 7
int 30h
mov ebx, 0x200000
add ebx, 2
jmp ebx
file db "executablewithareallyreallyreallyextremelyterriblylongnameandnoextension",0