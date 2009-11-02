call int301
jmp timerinterrupt
	
int301:	;;print char, char in al, modifier in bl, will run videobufcopy if called as is
	call int301prnt
	call termcopy
	ret
termguion db 0
termcopyon db 0
int301prnt:
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
	je near int301tab
	cmp al, 13		;I am phasing this out-it is used by windows but not unix based systems
	je near int301cr
	cmp al, 10
	je near int301nlcr
	cmp al, 8
	je near int301bs
	cmp al, 255		;;null character
	je near donescr
	mov [edi], ax
	add edi, 2
	inc dl
donecrnl:
	cmp dl, cl
	jae near int301eol
doneeol:
	cmp dh, ch
	jae near int301scr	
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
	
	int301tab:
		inc edi
		shr edi, 4
		shl edi, 4
		add edi, 16
		shr dl, 3
		shl dl, 3
		add dl, 8
		dec edi
		jmp donecrnl
	
	int301cr:
		xor dl, dl
		xor ebx, ebx
		mov edi, videobuf
		mov bx, [linebeginpos]
		add edi, ebx
		jmp donecrnl
			
	int301bs:
		cmp dl, 0
		je int301backline
	int301nobmr:
		dec dl
		xor ax, ax
		sub edi, 2
		jmp donecrnl
	int301backline:
		mov dl, cl
		cmp dh, 0
		je int301nobmr
		dec dh
		jmp int301nobmr
		
	int301nlcr:
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
		
	int301eol:
		xor dl, dl
		inc dh
		xor ebx, ebx
		mov bl, cl
		shl bx, 1
		add bx, [linebeginpos]
		mov [linebeginpos], bx
		jmp doneeol
	int301scr:
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