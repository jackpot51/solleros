;;THIS IS MY FIRST ATTEMPT AT IMPLEMENTING THREADS
threadstarttest:
    jmp startthreads
mainthread:
	hlt		;;this does not work properly
	jmp mainthread
	
nwcmdst:
	cli			;;no more interrupts!!!
	mov esi, line
	call print
	jmp nwcmd
	
modelthread:
	mov ax, [currentthread]
	
	mov ecx, 0
	mov cx, ax
	call showhex
	hlt		;;wait for next time around
	
	mov ecx, 0xC0DE0000
	mov cx, ax
	call showhex
	hlt
	
	mov ecx, 0xDEAD0000
	mov cx, ax
	call showhex
	hlt

	jmp nwcmdst
	
	
thrdtst:
times 256 dd modelthread	;;could go up to 2048, but that takes too long
thrdtstend:

startthreads:
	pushad
	mov ax, 0x7000	;;this is the divider for the PIT
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