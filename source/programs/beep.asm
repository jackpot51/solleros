	db 255,44,"beep",0
	mov eax, beepstart
	mov [soundpos], eax
	mov eax, beepend
	mov [soundendpos], eax
	mov byte [soundon], 1
waitforsoundendbeep:
	mov al, [soundon]
	cmp al, 0
	jne waitforsoundendbeep
	ret
	
beepstart:
	dw 50, 4561
beepend: