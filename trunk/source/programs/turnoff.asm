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
			mov ah, 0x53
			mov al, 4
			xor bx, bx
			int 0x15
			
			mov ah, 0x53
			mov al, 1
			xor bx, bx
			int 0x15
			
			mov ah, 0x53
			mov al, 8
			mov bx, 1
			mov cx, 1
			int 0x15
			
			mov ah, 0x53
			mov al, 7
			mov bx, 1
			mov cx, 3
			int 0x15
			jmp $
			[BITS 32]
halt: jmp $
