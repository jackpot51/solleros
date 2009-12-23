	cmp al, 0
	jne num2strb
	call showdec
	jmp timerinterrupt
num2strb:
	call showhex
	jmp timerinterrupt
