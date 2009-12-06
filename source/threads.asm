;;THIS IS MY FIRST ATTEMPT AT IMPLEMENTING THREADS
threadstarttest:
    jmp startthreads
mainthread:
	hlt		;;this does not work properly
	jmp mainthread
	
nwcmdst:
	mov byte [threadson], 0
	ret
	
modelthread:
	mov al, 1
	mov ah, 9
	mov ecx, [currentthread]
	int 0x30
	call timerinterrupt
	jmp nwcmdst
	
	
threadson db 0
lastthread dd 4

thrdtst:
times 256 dd modelthread	;;could go up to 2048, but that takes too long
thrdtstend:

	espold dd 0

threadfork:
	mov byte [threadson], 1
	pushad
	
	mov eax, cs
	mov edx, eax
	mov ecx, [esp + 40]
	or ecx, 0x200
	mov ebx, esp
	mov esp, stackdummy
	
	pushad
	mov eax, mainthread
	mov [esp + 32], eax
	mov [esp + 36], edx
	mov [esp + 40], ecx
	mov [threadlist], esp
	
	mov [espold], ebx
	mov eax, esi
	mov esp, stack1
	mov ebx, [lastthread]
	shl ebx, 10
	add esp, ebx
	shr ebx, 10
	pushad
	mov [esp + 32], eax
	mov [esp + 36], edx
	mov [esp + 40], ecx
	mov [threadlist + ebx], esp
	mov esp, [espold]
	add ebx, 4
	mov [threadlist + ebx], esp
	add ebx, 4
	mov [lastthread], ebx
	mov al, 0x20
	out 0x20, al
	popad
	ret

startthreads:
	mov byte [threadson], 1
	pushad
	
	mov eax, cs
	mov edx, eax
	mov ecx, [esp + 40]
	or ecx, 0x200
	mov ebx, esp
	mov esp, stackdummy
	
	pushad
	mov eax, mainthread
	mov [esp + 32], eax	;used to be 32
	mov [esp + 36], edx ;used to be 36
	mov [esp + 40], ecx
	mov [threadlist], esp

			;;that above setup the dummy thread which for some reason does not run
			;;this below will setup the threads found in thrdtst

testthreads:
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
	popad
	sti
	jmp $	;;wait for the irq to hook
	
nomorethreadspace:
	mov esi, nmts
	call print
	mov byte [threadson], 0
	jmp nwcmd
nmts	db "teh colonel no can haz moar treds",10,0

nomorestackspace:
	mov esi, nmss
	call print
	mov byte [threadson], 0
	jmp nwcmd
nmss	db "teh colonel no can haz moar staqz",10,0
	
threadswitch:
	cli
	pushad
	mov edi, threadlist
	mov eax, [currentthread]
	inc eax
	mov [currentthread], eax
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
	xor eax, eax
	mov [currentthread], eax
	mov eax, [edi]
	cmp eax, 0
	je near nwcmdst
okespthread:
	mov esp, eax
	mov al, 0x20
	out 0x20, al
	popad
	sti
	ret
	
currentthread dd 0
