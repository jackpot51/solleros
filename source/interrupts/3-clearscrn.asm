call int306
jmp timerinterrupt
clear:		
	int306:	;;clear screen
		mov cx, [charxy]
		mov edi, videobuf
		xor ax, ax
		mov [linebeginpos], ax
		mov [videobufpos], ax
		xor dx, dx
		mov [charpos], ax
	int306b:
		mov [edi], ax
		add edi, 2
		dec cl
		cmp cl, 0
		jne int306b
		mov cl, [charxy]
		dec ch
		cmp ch, 0
		jne int306b
		call termcopy
		ret
		