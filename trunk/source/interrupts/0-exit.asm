exitprog:
	mov esp, stackend	;for now i need to use this
	mov ax, NEW_DATA_SEL
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov ax, SYS_DATA_SEL
	mov gs, ax
	cmp ebx, 0
	jne near warnexitstatus
	jmp nwcmd
	
warnexitstatus:
	mov ecx, ebx
	mov al, 6
	mov [firsthexshown], al
	push ecx
	mov esi, exitstatus1msg
	call printhighlight
	pop ecx
	call showhex
	mov esi, exitstatus2msg
	call printhighlight
	jmp nwcmd
	
exitstatus1msg db "An exit status of 0x",0
exitstatus2msg db 8,"was returned.",10,0
