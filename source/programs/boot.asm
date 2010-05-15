db 255,44,"boot",0
quickboot:
	;load and jump to the bootloader
	; mov ecx, 1
	; xor ebx, ebx
	; mov esi, 0x400000
	; call diskr
	; mov ax, LINEAR_SEL
	; mov fs, ax
	; mov esi, 0x400000
	; mov edi, 0x7C00
	; xor ebx, ebx
; .lp:
	; mov ecx, [esi+ebx]
	; mov [fs:edi+ebx], ecx
	; add ebx, 4
	; cmp ebx, 512
	; jb .lp
	mov bx, bootload
	mov [realmodeptr], bx
	jmp realmode
[BITS 16]
bootload:
	mov ax, 3
	xor bx, bx
	int 10h
	jmp 0:0x7C00
[BITS 32]