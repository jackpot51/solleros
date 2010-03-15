	mov edi, esi
	call cnvrttxt	;the string goes into esi, number into ecx
	jmp timerinterrupt
	