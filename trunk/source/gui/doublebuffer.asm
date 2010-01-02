guicopy:	;for double buffering
	mov byte [copygui], 1
	mov edi, [offscreenmemoffset]
	xor edx, edx
	xor ecx, ecx
	mov dx, [mousecursorposition]
	mov cx, [mousecursorposition + 2]
	add edi, edx
	mov dx, [resolutionx2]
guicp2:
	mov eax, ecx
	push edx
	mul edx
	pop edx
	add edi, eax
	mov [cursorloc], edi
	mov ebx, cursorbmp
	mov cx, [resolutiony]
	rol ecx, 16
	mov cx, [resolutionx]
	mov esi, [physbaseptr]
	mov edi, [offscreenmemoffset]
guicp1:
	mov ax, [esi]
	mov [edi], ax
	add esi, 2
	add edi, 2
	cmp edi, [cursorloc]
	je copycursor
dncopycursor:
	dec cx
	cmp cx, 0
	jne guicp1
	mov cx, [resolutionx]
	rol ecx, 16
	dec cx
	cmp cx, 0
	rol ecx, 16
	jne guicp1
	mov byte [copygui], 0
	ret
copycursor:
	cmp ebx, cursorbmpend
	jae dncopycursor
	mov dx, [resolutionx2]
	add edi, edx
	mov [cursorloc], edi
	sub edi, edx
	dec ebx
	sub edi, 2
	sub esi, 2
	mov dx, 9
curscplp:
	inc ebx
	add esi, 2
	add edi, 2
	mov ax, [esi]
	mov [edi], ax
	mov al, [ebx]
	cmp al, 0
	je curscplp2
	mov word [edi], 1110011110011100b
curscplp2:
	dec cx
	cmp cx, 0
	je dncopycursor
	dec dx
	cmp dx, 0
	jne curscplp
	jmp dncopycursor
	
cursorloc: dd 0