call clear
jmp timerinterrupt
%ifdef io.serial
clear:
	ret
%else
clear:		
		mov cx, [charxy]
		mov edi, videobuf
		xor ax, ax
		mov [linebeginpos], ax
		mov [videobufpos], ax
		xor dx, dx
		mov [charpos], ax
		mov ah, 7
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
	cleardouble:
		mov edi, videobuf2
		mov cx, [charxy]
		xor eax, eax
	clearc:
		mov [edi], eax
		add edi, 4
		sub cl, 2
		cmp cl, 0
		jne clearc
		mov cl, [charxy]
		dec ch
		cmp ch, 0
		jne clearc
		call termcopy
		ret
%endif
		
