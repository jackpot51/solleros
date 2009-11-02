call int303
jmp timerinterrupt

	printquiet:
		xor ax, ax
		mov [endkey303], al
		mov bx, 7
		call int303b
		ret
    print:
		xor ax, ax
		mov bx, 7
	int303:	;;print line, al=last key,bl=modifier, esi=buffer
		mov [startesi303], esi
		mov [endkey303], al
		call int303b
		mov ecx, esi
		sub ecx, [startesi303]
		push ecx
		call termcopy
		pop ecx
		ret
	int303b:
		mov al, [esi]
		cmp al, [endkey303]
		je doneint303
		call int301prnt
		inc esi
		jmp int303b
	doneint303:
		ret

endkey303 db 0
startesi303 dd 0