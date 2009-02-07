processtest:
	call thread
	mov esp, edi
	jmp sched
processswitch:
	push gs
	push fs
	push es
	push ds
	pushad
	mov ebx, 0
	mov bx, [currentpid]
	inc bx
	cmp bx, [pid]
	jbe continueswitch
	mov bx, 0
continueswitch:
	mov [currentpid], bx
	inc ebx
	shl ebx, 9
	mov edi, processcache
	add edi, ebx
	mov esp, edi
	popad
	pop ds
	pop es
	pop fs
	pop gs
	iret


pid dw 0
currentpid dw 0

	
thread:
	mov ebx, nwcmd
	mov [user2codepoint], ebx
	ret
	
	pushad
	mov ebx, 0
	mov bx, [pid]
	mov edi, processcache
	inc bx
	mov [pid], bx
	inc bx
	shl ebx, 9
	add edi, ebx
	ret

processcache:	;;512 byte stack is all that is needed now
times 5 times 512 db 0
processcacheend: