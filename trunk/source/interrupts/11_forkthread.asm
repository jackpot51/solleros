forkthread:
			 ;esi is next thread's start address, if 0, fork current thread
			;returns the PID of the new fork in ebx
;WARNING:THIS WILL NOT WORK IN C UNTIL IT COPIES THE ENTIRE STACK INCLUDING FPU AND SSE REGISTERS
	cli
	pushad
	mov [.espold], esp
	mov byte [threadson], 1
	mov ebx, [currentthread]
	shl ebx, 2
	mov [threadlist + ebx], esp
	shr ebx, 2
	cmp ebx, 0
	jne .simplestack
	mov ebx, stackend
	sub ebx, esp
	jmp .stackcalcdone
.simplestack:
	shl ebx, 10
	add ebx, stack1
	sub ebx, esp
.stackcalcdone:
	sub esp, ebx
	add esp, stack1
	mov ebx, [lastthread]
	shl ebx, 8
	add esp, ebx
	mov [.stackend], ebx

	mov ebp, esp
	mov esp, [.espold]

	shr ebx, 10 ;get pid then push it
	mov [esp + 16], ebx ;set the old ebx to the new PID

	xor ebx, ebx
.stackcopy:
	mov ax, [esp + ebx]
	mov [ebp + ebx], ax
	add ebx, 2
	cmp ebx, [.stackend]
	jb .stackcopy

	xor eax, eax
	mov ax, cs
	mov edx, eax
	mov ecx, [esp + 40]
	or ecx, 0x200
	
	cmp esi, 0
	jne .nochangestack
	mov esi, [esp + 32]
.nochangestack:
	mov eax, esi
	mov esp, ebp

	mov [esp + 32], eax
	mov [esp + 36], edx
	mov [esp + 40], ecx

	mov ebx, [lastthread]
	mov [threadlist + ebx], esp
	add ebx, 4
	mov [lastthread], ebx
	mov esp, [.espold]
	popad
	sti
	iret

.espold dd 0
.stackend dd 0
