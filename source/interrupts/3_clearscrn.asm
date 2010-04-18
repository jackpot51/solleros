clearscrn:
call clear
jmp timerinterrupt
%ifdef io.serial
clear:
	ret
%else
clear:
		mov cx, [charxy]
		mov edi, videobuf
		xor eax, eax
		mov [linebeginpos], eax
		mov [videobufpos], eax
		xor dx, dx
		mov [charpos], ax
		mov ax, 7
		shl eax, 16
	clearb:
		mov [edi], eax
		add edi, 4
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
		dec cl
		cmp cl, 0
		jne clearc
		mov cl, [charxy]
		dec ch
		cmp ch, 0
		jne clearc
		call termcopy
		ret
%endif
		
