call int304
jmp timerinterrupt

	int304:	;;get line, al=last key, esi = buffer, edi = endbuffer
		mov [endkey304], al
		mov [endbuffer304], edi
	int304b:
		push esi
		xor al, al
		call int302
		pop esi
		mov [esi], al
		inc esi
		cmp esi, [endbuffer304]
		jae int304done
		cmp al, [endkey304]
		jne int304b
	int304done:
		dec esi
		mov byte [esi], 0
	ret
endkey304 db 0
endbuffer304 dd 0