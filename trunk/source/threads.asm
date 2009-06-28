;;THIS IS MY FIRST ATTEMPT AT IMPLEMENTING THREADS
threadstarttest:
    jmp startthreads
mainthread:
	hlt		;;this does not work properly
	jmp mainthread
	
nwcmdst:
	mov al, 11111101b
	out 0x21, al
	mov byte [threadson], 0
	jmp nwcmd
	
modelthread:
	mov bx, [currentthread]
	mov al, 1
	mov ah, 9
	mov ecx, 0
	mov cx, bx
	int 0x30
	
	mov ecx, 0xC0DE0000
	mov cx, bx
	int 0x30
	
	mov ecx, 0xDEAD0000
	mov cx, bx
	int 0x30
	
	int 0x40	;;skip this thread three times to ensure that all threads run
	int 0x40
	int 0x40
	
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
	mov ax, 0x4000	;;this is the divider for the PIT
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
	
	mov [espold], ebx
	mov eax, esi
	mov esp, stack1
	mov ebx, [lastthread]
	shl ebx, 10
	add esp, ebx
	shr ebx, 10
	nop
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
	mov ax, 0xA000	;;this is the divider for the PIT
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
	;mov al, 0xFE
	;out 0x21, al
	mov al, 0
	out 0x21, al
	mov al, 0x20
	out 0x20, al
	popad
	sti
	jmp $	;;wait for the irq to hook
	
nomorethreadspace:
	mov esi, nmts
	call print
	mov byte [threadson], 0
	jmp nwcmd
nmts	db "teh colonel no can haz moar treds",13,10,0

nomorestackspace:
	mov esi, nmss
	call print
	mov byte [threadson], 0
	jmp nwcmd
nmss	db "teh colonel no can haz moar staqz",13,10,0
	
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
	cmp eax, 0
	je near nwcmdst
okespthread:
	mov esp, eax
	mov al, 0x20
	out 0x20, al
	popad
	sti
	iretd
	
currentthread dw 0
