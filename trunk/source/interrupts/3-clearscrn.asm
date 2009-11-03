call clear
jmp timerinterrupt
clear:		
		mov cx, [charxy]
		mov edi, videobuf
		xor ax, ax
		mov [linebeginpos], ax
		mov [videobufpos], ax
		xor dx, dx
		mov [charpos], ax
	clearb:
		mov [edi], ax
		add edi, 2
		dec cl
		cmp cl, 0
		jne clearb
		mov cl, [charxy]
		dec ch
		cmp ch, 0
		jne clearb
		call termcopy
		ret
		
