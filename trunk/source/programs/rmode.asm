db 255,44,"rmode",0
	mov bx, rmodetest
	mov [realmodeptr], bx
	mov ebx, waitkey
	mov [realmodereturn], ebx
	jmp realmode
[BITS 16]
rmodetest:
	mov si, rmodestr
	xor bx, bx
rmodeprnt:
	lodsb
	or al, al
	jz .done
	mov ah, 0xE
	inc bx
	int 0x10
	jmp rmodeprnt
.done: ret

rmodestr db "Hello from real mode!",10,13,"Goodbye!",10,13,0
[BITS 32]