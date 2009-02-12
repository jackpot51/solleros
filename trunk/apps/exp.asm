[BITS 32]
[ORG 0x100000]
db "EX"
	mov eax, 0x12345678
	mov ebx, 0x90ABCDEF
	mov ecx, "EXCE"
	mov edx, "PTIO"
	mov esi, "N 13"
	mov edi, 0xDEADC0DE
exception1:	int 13