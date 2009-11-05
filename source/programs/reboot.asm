	db 255,44,"reboot",0
		lidt [idtreboot]
		int 0
		hlt
	
	idtreboot dw 0
			  dd 0

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
		
