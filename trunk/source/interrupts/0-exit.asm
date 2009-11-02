exitprog:
	mov bx, NEW_DATA_SEL
	mov ds, bx
	mov es, bx
	mov fs, bx
	mov bx, SYS_DATA_SEL
	mov gs, bx
	cmp al, 0
	jne near warnexitstatus
	jmp nwcmd
	
warnexitstatus:
	mov cl, al
	mov al, 0
	mov [firsthexshown], al
	push cx
	mov esi, exitstatus1msg
	call print
	pop cx
	call showhexsmall
	mov esi, exitstatus2msg
	call print
	jmp nwcmd
	
exitstatus1msg db "An exit status of 0x",0
exitstatus2msg db 8,"was returned.",10,0