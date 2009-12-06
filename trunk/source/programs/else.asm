	db 255,44,"else",0
elsecmd:	xor eax, eax
	cmp [BATCHISON], al
	je near notbatch
	mov al, [IFON]
	mov esi, IFTRUE
	add esi, eax
	mov al, [esi]
	xor al, 1
	mov [esi], al
	ret 