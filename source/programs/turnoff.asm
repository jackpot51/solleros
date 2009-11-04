db 255,44,"rmode",0
	mov bx, rmodetest
	mov [realmodeptr], bx
	mov ebx, waitkey
	mov [realmodereturn], ebx
	jmp realmode
[BITS 16]
rmodetest:
	mov si, rmodestr
rmodeprnt:
	lodsb
	or al, al
	jz .done
	mov ah, 0xE
	int 0x10
	jmp rmodeprnt
.done: ret

rmodestr db "Hello from real mode!",10,13,"Goodbye!",10,13,0

	db 255,44,"turnoff",0
			mov bx, shutdown
			mov [realmodeptr], bx
			mov ebx, halt
			mov [realmodereturn], ebx
			jmp realmode

			[BITS 16]
		shutdown:
			MOV AX, 5300h	; Shuts down APM-Machines.
			XOR BX, BX	; Newer machines automatically
			INT 15h		; shut down
			MOV AX, 5304h
			XOR BX, BX
			INT 15h		; Interrupt 15h originally was
			MOV AX, 5301h	; used for Cartridges (cassettes)
			XOR BX, BX	; but is still in use for
			INT 15h		; diverse things
			MOV AX, 5307h
			MOV BX, 1
			MOV CX, 3
			INT 15h
			IRET
			[BITS 32]
halt: jmp $
