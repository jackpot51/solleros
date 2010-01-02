iconcolor dw 0
	showicon:	;;icon in si, position in (dx,cx), selected in ax, code in bx
		mov [iconselected], al
		and byte [iconselected], 1
		mov ah, 1
		call graphicsadd
	showicon2:
		mov edi, [physbaseptr]
		add dx, dx
		cmp dx, [resolutionx2]
		jb screenxgood
		mov dx, [resolutionx2]
		sub dx, 64
	screenxgood:
		cmp cx, 0
		je noscreenygoodchk
		cmp cx, [resolutiony]
		jb screenygood
		mov cx, [resolutiony]
		sub cx, 32
	screenygood:
		push eax
		push edx
		xor eax, eax
		xor ebx, ebx
		mov bx, [resolutionx2]
		mov ax, cx
		mul ebx
		add edi, eax
		pop edx
		pop eax
	noscreenygoodchk:
		xor ebx, ebx
		mov bx, dx
		add edi, ebx
		xor cx, cx
		mov ax, [esi]
		add esi, 2
		mov [iconcolor], ax
	writeicon:
		mov eax, [esi]
		rol eax, 1
		xor cl, cl
	writeiconline:
		mov dl, 1
		and dl, al
		xor dl, [iconselected]
		mov bx, [background]
		mov [edi], bx
		cmp dl, 0
		je noiconline
		mov dx, [iconcolor]
		mov [edi], dx
	noiconline:
		add edi, 2
		rol eax, 1
		inc cl
		cmp cl, 32
		jb writeiconline
		add esi, 4
		inc ch
		xor edx, edx
		mov dx, [resolutionx2]
		add edi, edx
		sub edi, 64
		cmp ch, 32
		jb writeicon
		xor eax, eax
		ret
