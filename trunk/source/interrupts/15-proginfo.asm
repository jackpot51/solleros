	mov ebx, variables
	mov esi, [lastcommandpos]
	add esi, commandbuf
	mov edi, esi
	xor ecx, ecx
getcommandzeroes:
	mov al, [edi]
	inc edi
	cmp al, 0
	je nomorezeroes
	cmp al, ' '
	jne getcommandzeroes
	inc ecx
	jmp getcommandzeroes
nomorezeroes:
	inc ecx
	dec edi
	iret
	