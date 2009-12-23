call printint
jmp timerinterrupt

	printhighlight:
		xor ax, ax
		mov bx, 0xF0
		jmp printint
	printquiet:
		xor ax, ax
		mov [endkeyprint], al
		mov bx, 7
		call printint.b
		ret
    print:
		xor ax, ax
		mov bx, 7
	printint:	;;print line, al=last key,bl=modifier, esi=buffer
		push esi
		mov [endkeyprint], al
		call .b
		mov ecx, esi
		pop edi
		sub ecx, edi
		push ecx
		call termcopy
		pop ecx
		ret
	.b:
		mov al, [esi]
		cmp al, [endkeyprint]
		je .done
		call prcharq
		inc esi
		jmp .b
	.done:
		ret

endkeyprint db 0
