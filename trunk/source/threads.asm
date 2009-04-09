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
	
modelthread:
	mov ecx, 0
	mov cx, [currentthread]
	call showhex
	hlt		;;wait for next time around
	mov ecx, 0xDEAD0000
	mov cx, [currentthread]
	call showhex
	hlt
	mov ecx, 0xC0DE0000
	mov cx, [currentthread]
	call showhex
	hlt
	jmp nwcmdst
	
	
thrdtst:
	;dd thread1
	;dd thread2
	;dd thread3
times 2048 dd modelthread
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
	mov esi, thrdtst
	mov esp, stack1
	mov edi, threadlist
	add edi, 4
nxtthreadld:
	pushad
	mov eax, [esi]
	mov [esp + 32], eax
	mov [esp + 36], edx
	mov [esp + 40], ecx
	mov [edi], esp
	add esp, 1024
	add esi, 4
	add edi, 4
	cmp edi, threadlistend
	jae near nomorethreadspace
	cmp esp, bssend
	jae near nomorestackspace
	cmp esi, thrdtstend
	jb nxtthreadld
	mov esp, ebx
	mov al, 0xFE
	out 0x21, al
	mov al, 0x20
	out 0x20, al
	popad
	sti
	jmp $	;;wait for the irq to hook
	
nomorethreadspace:
	mov esi, nmts
	call print
	jmp $
nmts	db "teh colonel no can haz moar treds",0

nomorestackspace:
	mov esi, nmss
	call print
	jmp $
nmss	db "teh colonel no can haz moar staqz",0
	
threadswitch:
	cli
	pushad
	mov edi, threadlist
	mov eax, 0
	mov ax, [currentthread]
	inc ax
	mov [currentthread], ax
	dec ax
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
	mov ax, 0
	mov [currentthread], ax
	mov eax, [edi]
okespthread:
	mov esp, eax
	mov al, 0x20
	out 0x20, al
	popad
	sti
	iretd
	
currentthread dw 0