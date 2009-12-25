    ; MENU.ASM
%include 'source/signature.asm'
menustart:	
	mov ax, cs
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov [DriveNumber], cl
	mov [lbaad], edx
%ifdef io.serial
	call getmemorysize
	mov si, serialmsg
	call printrm
	jmp pmode
serialmsg: db "Using serial port 1 for I/O.",0
%else
	call vgaset	;make users switch using a command-this leads to very fast boots
	jmp pmode
%endif
	
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
	
printrm:			; 'si' comes in with string address
    mov bx,07		; write to display
    mov ah,0Eh		; screen function
   .lp:    mov al,[si]         ; get next character
    cmp al,0		; look for terminator 
    je .done		; zero byte at end of string
    int 10h		; write character to screen.    
	inc si	     	; move to next character
    jmp .lp		; loop
.done: ret