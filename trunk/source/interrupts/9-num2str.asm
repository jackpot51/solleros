	cmp al, 0
	jne intx9B
	call showdec
	jmp timerinterrupt
intx9B:
	call showhex
	jmp timerinterrupt