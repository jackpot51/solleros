	db 255,44,"beep",0
	mov eax, beepstart
	mov [soundpos], eax
	mov eax, beepend
	mov [soundendpos], eax
	mov byte [soundon], 1
	jmp nwcmd
	
beepstart:
	dw 15, 4561
beepend: