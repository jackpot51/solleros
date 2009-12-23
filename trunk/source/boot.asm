    ; MENU.ASM
%include 'source/signature.asm'
menustart:	
	mov ax, cs
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov [DriveNumber], cl
	mov [lbaad], edx
	call vgaset	;make users switch using a command-this leads to very fast boots
	xor ebx, ebx
	xor ecx, ecx
	xor edx, edx
	xor esi, esi
	xor edi, edi
	jmp pmode
	
vgaset:
	mov ax, 12h
	xor bx, bx
	int 10h
	mov byte [guion], 0
	call getmemorysize;get the memory map after the video is initialized
	ret

getmemorysize:
	mov di, memlistbuf
	xor ebx, ebx
getmemsizeloop:
	mov eax, 0xE820
	mov edx, 0x0534D4150
	mov ecx, 24
	int 0x15
	add di, 24
	cmp di, memlistend
	jae nomoregetmemsize
	cmp ebx, 0
	jne getmemsizeloop
nomoregetmemsize:
	sub di, memlistbuf
	mov [memlistend], di
	ret
	