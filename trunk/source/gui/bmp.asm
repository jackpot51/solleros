
showbmp:
	mov ax, [esi]
	cmp ax, "BM"
	jne near endedbmp
	mov edi, [physbaseptr]
	mov ax, dx
	mov bx, cx
	xor ecx, ecx
	xor edx, edx
	mov cx, bx
	mov dx, ax
	add edi, edx
	add edi, edx
	xor edx, edx
	mov dx, [resolutionx2]
	add ecx, [esi + 22]
bmplocloop:
	push edx
	xor eax, eax
	mov ax, dx
	mul ecx
	pop edx
	cmp cx, [resolutiony]
	jbe .nofixy
	xor ecx, ecx
	mov cx, [resolutiony]
.nofixy:
	add edi, eax
	mov edx, [esi + 18]
	mov ecx, [esi + 22]
	mov eax, [esi + 10]
	mov ebx, [esi + 2]
	add ebx, esi
	mov [bmpend], ebx
	mov ebx, edx
	add esi, eax
ldxbmp2:
	xor edx, edx
	mov dx, [resolutionx]
	cmp ebx, edx
	ja ldxbmp
	mov edx, ebx
ldxbmp:
	mov ax, [esi]
	mov [edi], ax
	add edi, 2
	add esi, 2
	cmp esi, [bmpend]
	ja endedbmp
	dec edx
	cmp edx, 0
	ja ldxbmp
	xor edx, edx
	mov dx, [resolutionx]
	cmp ebx, edx
	jbe .notover
.over:
	add esi, ebx
	add esi, ebx
	sub esi, edx
	sub esi, edx
	add edi, ebx
	add edi, ebx
	sub edi, edx
	sub edi, edx
.notover:
	sub edi, ebx
	sub edi, ebx
	sub edi, edx
	sub edi, edx
	dec ecx
	cmp ecx, 0
	ja ldxbmp2
endedbmp:
	call switchmousepos2
	ret
	
	bmpend dd 0