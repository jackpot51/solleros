	mov edi, buftxt
cpcmd:
	mov al, [esi]
	mov [edi], al
	inc esi
	inc edi
	cmp al, 0
	jne cpcmd
	call run
	iret
