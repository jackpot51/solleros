	mov edi, buftxt
cpccmd:
	mov al, [esi]
	mov [edi], al
	inc esi
	inc edi
	loop cpccmd
	jmp run