call printint
jmp timerinterrupt

	printquiet:
		xor ax, ax
		mov [endkeyprint], al
		mov bx, 7
		call printintb
		ret
    print:
		xor ax, ax
		mov bx, 7
	printint:	;;print line, al=last key,bl=modifier, esi=buffer
		mov [startesiprint], esi
		mov [endkeyprint], al
		call printintb
		mov ecx, esi
		sub ecx, [startesiprint]
		push ecx
		call termcopy
		pop ecx
		ret
	printintb:
		mov al, [esi]
		cmp al, [endkeyprint]
		je doneprintint
		call prcharq
		inc esi
		jmp printintb
	doneprintint:
		ret

endkeyprint db 0
startesiprint dd 0
