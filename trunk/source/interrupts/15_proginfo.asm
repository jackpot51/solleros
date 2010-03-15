	;mov ebx, variables
	mov esi, [currentcommandloc]
	mov edi, esi
	xor ecx, ecx
getcommandzeroes:
	mov al, [edi]
	inc edi
	cmp al, ';'
	je nomorezeroes
	cmp al, 0
	je nomorezeroes
	cmp al, ' '
	jne getcommandzeroes
	inc ecx
	jmp getcommandzeroes
nomorezeroes:
	inc ecx
	dec edi
	mov ebx, [uid]
	mov edx, [currentthread]
	iret
	
