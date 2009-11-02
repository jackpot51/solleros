	db 255,44,"reboot",0	
	coldboot:
		mov eax, cr0
		and al,0xFE     ; back to realmode
		mov  cr0, eax   ; by toggling bit again
		sti
		MOV AX, 0040h
		MOV ES, AX
		MOV WORD [ES:00072h], 0h
		JMP 0FFFFh:0000h
		IRET

		warmboot:
		cli
		mov eax, cr0
		and al,0xFE     ; back to realmode
		mov  cr0, eax   ; by toggling bit again	
		sti
		xor eax, eax
		MOV AX, 0040h
		MOV ES, AX
		MOV WORD [ES:00072h], 01234h
		JMP 0FFFFh:0000h
		IRET
		