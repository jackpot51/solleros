hooksig: ;hook code in ESI to signal in AL
	cmp al, 0
	jne .quit	;only sig 0, the escape key, is handled, and only for one app
;	xor ebx, ebx
;	mov bl, al
;	shl bl, 2
	mov edi, sigtable
	mov [edi], esi
.quit:
	jmp timerinterrupt
