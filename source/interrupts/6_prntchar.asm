call prcharint
jmp timerinterrupt
	
prcharint:	;;print char, char in al, modifier in bl, if bh = bl then termcopy will not happen, will run videobufcopy if called as is
	cmp bl, bh
	je prcharq
	call prcharq
	call termcopy
	ret
termguion db 0
termcopyon db 0
prcharq:
	mov ah, bl
	mov [charbuf], ax
	xor ebx, ebx
	mov bx, [videobufpos]
	mov edi, videobuf
	add edi, ebx
	mov ax, [removedvideo]
	mov [edi], ax
	mov ax, [charbuf]
	xor edx, edx
	mov dx, [charpos]
	xor ecx, ecx
	mov cx, [charxy]
	cmp al, 9
	je near prtab
	cmp al, 13		;I am phasing this out-it is used by windows but not unix based systems
	je near prcr
	cmp al, 10
	je near prnlcr
	cmp al, 8
	je near prbs
	cmp al, 255		;;null character
	je near donescr
	mov [edi], ax
	add edi, 2
	inc dl
donecrnl:
	cmp dl, cl
	jae near preol
doneeol:
	cmp dh, ch
	jae near prscr	
donescr:
	mov ebx, edi
	mov ax, [edi]
	mov [removedvideo], ax
	sub ebx, videobuf
	mov [videobufpos], bx
	mov [charpos], dx
	mov ax, [charbuf]
	mov bl, ah
	ret
	
	prtab:
		xor ebx, ebx
		mov bx, [linebeginpos]
		sub edi, videobuf
		sub edi, ebx
		shr edi, 4
		shl edi, 4
		add edi, 16
		shr dl, 3
		shl dl, 3
		add dl, 8
		add edi, videobuf
		add edi, ebx
		jmp donecrnl
	
	prcr:
		xor dl, dl
		xor ebx, ebx
		mov edi, videobuf
		mov bx, [linebeginpos]
		add edi, ebx
		jmp donecrnl
			
	prbs:
		cmp dl, 0
		je prbackline
	prnobmr:
		dec dl
		xor ax, ax
		sub edi, 2
		jmp donecrnl
	prbackline:
		mov dl, cl
		cmp dh, 0
		je prnobmr
		dec dh
		jmp prnobmr
		
	prnlcr:
		inc dh
		xor ebx, ebx
		xor dl, dl
		mov bl, cl
		shl bx, 1
		mov edi, videobuf
		add bx, [linebeginpos]
		mov [linebeginpos], bx
		add edi, ebx
		jmp donecrnl
		
	preol:
		xor dl, dl
		inc dh
		xor ebx, ebx
		mov bl, cl
		shl bx, 1
		add bx, [linebeginpos]
		mov [linebeginpos], bx
		jmp doneeol
	prscr:
		dec dh
		mov edi, videobuf
		xor ebx, ebx
		mov bl, cl
		shl bx, 1
		add ebx, edi
	intscrollloop:
		mov ax, [ebx]
		mov [edi], ax
		add edi, 2
		add ebx, 2
		dec cl
		cmp cl, 0
		jne intscrollloop
		mov cl, [charxy]
		dec ch
		cmp ch, 1
		ja intscrollloop
		xor ax, ax
		sub edi, videobuf
		mov [linebeginpos], di
		add edi, videobuf
		mov ebx, edi
	intloopclear:
		mov [ebx], ax
		add ebx, 2
		dec cl
		cmp cl, 0
		jne intloopclear
		dec ch
		cmp ch, 0
		jne intloopclear
		mov cx, [charxy]
		jmp donescr
		
linebeginpos dw 0
videobufpos: dw 0
charpos db 0,0
charxy db 80,30
charbuf dw 0
