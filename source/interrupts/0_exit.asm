exitprog:
	mov esp, stackend	;for now i need to use this
	mov ax, NEW_DATA_SEL
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov ax, SYS_DATA_SEL
	mov gs, ax
	cmp ebx, 0
	jne near .error
	jmp nwcmd
	
.error:
	mov ecx, ebx
	mov al, 6
	mov [firsthexshown], al
	push ecx
	mov esi, .msg1
	call printhighlight
	pop ecx
	call showhex
	mov esi, .msg2
	call printhighlight
	jmp nwcmd
	
.msg1 db "An exit status of 0x",0
.msg2 db 8,"was returned.",10,0
