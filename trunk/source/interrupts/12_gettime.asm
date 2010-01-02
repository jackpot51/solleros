	mov eax, [timeseconds]
	mov ebx, [timenanoseconds]
	mov ecx, ebx
	shr ecx, 10	;this is in microseconds
	jmp timerinterrupt