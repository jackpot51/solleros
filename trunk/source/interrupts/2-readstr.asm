call readint
jmp timerinterrupt

	readint:	;;get line, al=last key, esi = buffer, edi = endbuffer
		mov [endkeyread], al
		mov [endbufferread], edi
	readintb:
		push esi
		xor al, al
		call rdcharint
		pop esi
		mov [esi], al
		inc esi
		cmp esi, [endbufferread]
		jae readdone
		cmp al, [endkeyread]
		jne readintb
	readdone:
		dec esi
		mov byte [esi], 0
	ret
endkeyread db 0
endbufferread dd 0
