prntchar:
	xor ah, ah
%ifdef io.serial
	call prcharint
	jmp timerinterrupt
prcharint:	
prcharq:
	call serial.send
	ret
%else
cmp bl, bh
je prchar.notimer
call prcharint
jmp timerinterrupt
prchar.notimer:
	call prcharq
	iret
	
prcharint:	;print char, char in ax, modifier in bx, if bl = bh  then termcopy will not happen, will run termcopy if called as is
xor ah, ah
	cmp bl, bh
	je prcharq
	call prcharq
	call termcopy
	ret
termguion db 0
termcopyon db 0
prcharq:
	shl ebx, 16
	mov bx, ax
	mov eax, ebx
	mov [charbuf], eax
	mov ebx, [videobufpos]
	mov edi, videobuf
	add edi, ebx
	mov eax, [removedvideo]
	mov [edi], eax
	mov eax, [charbuf]
	xor edx, edx
	mov dx, [charpos]
	xor ecx, ecx
	mov cx, [charxy]
	cmp ax, 9
	je near prtab
	cmp ax, 13		;I am phasing this out-it is used by windows but not unix based systems
	je near prcr
	cmp ax, 10
	je near prnlcr
	cmp ax, 8
	je near prbs
	cmp ax, 255		;null character
	je near donescr
	cmp ax, (fontend - fonts)/16
	jae near prnofont
donepr:
	mov [edi], eax
	add edi, 4
	inc dl
donecrnl:
	cmp dl, cl
	jae near preol
doneeol:
	cmp dh, ch
	jae near prscr	
donescr:
	mov ebx, edi
	mov eax, [edi]
	mov [removedvideo], eax
	sub ebx, videobuf
	mov [videobufpos], ebx
	mov [charpos], dx
	mov eax, [charbuf]
	mov ebx, eax
	shr ebx, 16
	ret
	
	prnofont:
		mov ax, 2
		jmp donepr
	prtab:
		mov ebx, [linebeginpos]
		sub edi, videobuf
		sub edi, ebx
		shr edi, 5
		shl edi, 5
		add edi, 32
		shr dl, 3
		shl dl, 3
		add dl, 8
		add edi, videobuf
		add edi, ebx
		jmp donecrnl
	
	prcr:
		xor dl, dl
		mov edi, videobuf
		mov ebx, [linebeginpos]
		add edi, ebx
		jmp donecrnl
			
	prbs:
		mov ebx, [linebeginpos]
		cmp dl, 0
		je prbackline
	prnobmr:
		mov [linebeginpos], ebx
		dec dl
		xor eax, eax
		sub edi, 4
		jmp donecrnl
	prbackline:
		xor bx, bx
		mov dl, cl
		cmp dh, 0
		je prnobmr
		mov ebx, [linebeginpos]
		push cx
		xor ecx, ecx
		mov cl, [esp]
		shl ecx, 2
		sub ebx, ecx
		pop cx
		dec dh
		jmp prnobmr
		
	prnlcr:
		inc dh
		xor ebx, ebx
		xor dl, dl
		mov bl, cl
		shl bx, 2
		mov edi, videobuf
		add ebx, [linebeginpos]
		mov [linebeginpos], ebx
		add edi, ebx
		jmp donecrnl
		
	preol:
		xor dl, dl
		inc dh
		xor ebx, ebx
		mov bl, cl
		shl bx, 2
		add ebx, [linebeginpos]
		mov [linebeginpos], ebx
		jmp doneeol
	prscr:
		dec dh
		mov edi, videobuf
		xor ebx, ebx
		mov bl, cl
		shl bx, 2
		add ebx, edi
	intscrollloop:
		mov eax, [ebx]
		mov [edi], eax
		add edi, 4
		add ebx, 4
		dec cl
		cmp cl, 0
		jne intscrollloop
		mov cl, [charxy]
		dec ch
		cmp ch, 1
		ja intscrollloop
		xor eax, eax
		sub edi, videobuf
		mov [linebeginpos], edi
		add edi, videobuf
		mov ebx, edi
	intloopclear:
		mov [ebx], eax
		add ebx, 4
		dec cl
		cmp cl, 0
		jne intloopclear
		dec ch
		cmp ch, 0
		jne intloopclear
		mov cx, [charxy]
		jmp donescr
		
linebeginpos dd 0
videobufpos: dd 0
charpos db 0,0
charxy db 80,30
charbuf dd 0
%endif
