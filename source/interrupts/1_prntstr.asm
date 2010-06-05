prntstr:
xor ah, ah
call printint
jmp timerinterrupt

	printquiet:
		xor ax, ax
		mov [endkeyprint], ax
		mov bx, 7
		call printint.b
		ret

	printhighlight:
		xor ax, ax
		mov bx, 0xF0
		jmp printint

	printline:
		mov esi, line
    print:
		xor ax, ax
		mov bx, 7
	printint:	;print line, ax=last key,bx=modifier, esi=buffer
		push esi
		mov [endkeyprint], ax
		call .b
		mov ecx, esi
		pop edi
		sub ecx, edi
		push ecx
		call termcopy
		pop ecx
		ret
	.b:	
		push ebx
		xor eax, eax
		mov al, [esi]
		cmp al, 0xFF
		je .doneutf
		cmp al, 0xC0
		jb .doneutf
		cmp al, 0xE0
		jb .two
		inc esi
		mov ch, [esi]
		inc esi
		mov cl, [esi]
		shl al, 4
		shl cl, 2
		shr cx, 2
		or ch, al
		mov ax, cx
		jmp .doneutf
	.two:
		mov ch, [esi]
		inc esi
		mov cl, [esi]
		shl cx, 2
		shr ch, 2
		shr cx, 2
		mov ax, cx
	.doneutf:
		pop ebx
		cmp ax, [endkeyprint]
		je .done
		cmp ax, 0xFEFF
		je .noprint
		call prcharq
	.noprint:
		inc esi
		jmp .b
	.done:
		ret

endkeyprint dw 0
