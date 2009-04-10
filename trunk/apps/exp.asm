[BITS 32]
[ORG 0x400000]
db "EX"
	mov eax, 0xD15EA5ED
	push eax
	mov eax, 0xB100D015
	push eax
	mov eax, 0xBAD2FEED
	push eax
	mov eax, 0x2A11D095
	push eax
	mov eax, 0xA11CA752
	push eax
	mov eax, 0x1510750F
	push eax
	mov eax, 0xDEADCA75
	push eax
	mov eax, 0xDEADD095
	push eax
	mov eax, 0x12345678
	mov ebx, 0x90ABCDEF
	mov ecx, "EXCE"
	mov edx, "PTIO"
	mov esi, "N 13"
	mov edi, 0xDEADC0DE
exception1:	int 0x13