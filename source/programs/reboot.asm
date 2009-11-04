	db 255,44,"reboot",0	
		mov bx, warmboot
		mov [realmodeptr], bx
		mov ebx, halt
		mov [realmodereturn], ebx
		jmp realmode

	coldboot:
		MOV AX, 0040h
		MOV ES, AX
		MOV WORD [ES:00072h], 0h
		JMP 0FFFFh:0000h
		IRET

	warmboot:
		MOV AX, 0040h
		MOV ES, AX
		MOV WORD [ES:00072h], 01234h
		JMP 0FFFFh:0000h
		IRET
		
