settime:
	mov [timeseconds], eax
	mov [timenanoseconds], ebx
	jmp timerinterrupt
	
