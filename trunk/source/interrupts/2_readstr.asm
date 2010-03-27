readstr:
call readint
jmp timerinterrupt

	readint:	;;get line, al=last key, esi = buffer, edi = endbuffer	
		mov ebx, eax
	.b:
		push ebx
		push edi
		push esi
		xor al, al
		call rdcharint
		pop esi
		mov [esi], al
		inc esi
		pop edi
		pop ebx
		cmp esi, edi
		jae .done
		cmp al, bl
		jne .b
	.done:
		dec esi
		mov byte [esi], 0
		ret
