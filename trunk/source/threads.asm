;;THIS IS MY FIRST ATTEMPT AT IMPLEMENTING THREADS
threadstarttest:
    call startthreads
	jmp $
mainthread:
	hlt		;;this does not work properly
	mov esi, thrdmain
	call print
	jmp mainthread
thrdmain db "MAIN THREAD ",0

thread1:
	mov eax, 94
thrdlp1:
	dec eax
	push eax
	mov esi, thrd1
	call print
	pop eax
	cmp eax, 0
	je $
	jmp thrdlp1
	
thrd1	db "THREAD 1  ",0

thread2:
	mov eax, 95
thrdlp2:
	dec eax
	push eax
	mov esi, thrd2
	call print
	pop eax
	cmp eax, 0
	je $
	jmp thrdlp2
	
thrd2 db "THREAD 2  ",0
	
thread3:
	mov eax, 96
thrd3lp:
	sub eax, 2	;;each cycle will take twice as long
	mov ecx, eax
	push eax
	call showhex
	mov esi, thrd3
	call print
	pop eax
	cmp eax, 0
	je near nwcmdst
	jmp thrd3lp
	
nwcmdst:
	cli			;;no more interrupts!!!
	mov esi, line
	call print
	jmp nwcmd
	
thrd3 db "THREAD 3  ",0
	
	
thrdtst:
	dd thread1
	dd thread2
	dd thread3
thrdtstend:

startthreads:
	pushad
	mov ax, 0xFFFF
	shr ax, 2	;;divide by 4 to make interrupts happen four times faster
	out 0x40, al
	rol ax, 8
	out 0x40, al
	
	mov eax, cs
	mov edx, eax
	mov ecx, [esp + 40]
	or ecx, 0x200
	mov ebx, esp
	mov esp, stackdummy
	nop
	pushad
	mov eax, mainthread
	mov [esp + 32], eax
	mov [esp + 36], edx
	mov [esp + 40], ecx
	mov [threadlist], esp
			;;that above setup the dummy thread which for some reason does not run
			;;this below will setup the threads found in thrdtst
	mov esp, stack1
	nop
	pushad
	mov eax, thread1
	mov [esp + 32], eax
	mov [esp + 36], edx
	mov [esp + 40], ecx
	mov [threadlist + 4], esp
	mov esp, stack2
	nop
	pushad
	mov eax, thread2
	mov [esp + 32], eax
	mov [esp + 36], edx
	mov [esp + 40], ecx
	mov [threadlist + 8], esp
	mov esp, stack3
	nop
	pushad
	mov eax, thread3
	mov [esp + 32], eax
	mov [esp + 36], edx
	mov [esp + 40], ecx
	mov [threadlist + 12], esp
	mov esp, ebx
	mov al, 0xFE
	out 0x21, al
	mov al, 0x20
	out 0x20, al
	popad
	sti
	ret
	
threadswitch:
	cli
	pushad
	mov edi, threadlist
	mov eax, 0
	mov al, [currentthread]
	inc al
	mov [currentthread], al
	dec al
	shl eax, 2
	add edi, eax
	mov [edi], esp
	add edi, 4
	cmp edi, threadlistend
	jae near nookespthread
	mov eax, [edi]
	cmp eax, 0
	jne near okespthread
nookespthread:
	mov edi, threadlist
	mov al, 0
	mov [currentthread], al
	mov eax, [edi]
okespthread:
	mov esp, eax
	mov al, 0x20
	out 0x20, al
	popad
	sti
	iretd
	
currentthread db 0