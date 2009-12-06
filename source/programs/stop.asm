	db 255,44,"stop",0
stop:	xor al, al
	mov [BATCHISON], al
	mov [IFON], al
	mov [IFTRUE], al
	mov [LOOPON], al
	ret 