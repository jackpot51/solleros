boot:
	mov ax, cs
	mov ds, ax
	mov es, ax
	mov ss, ax
	rdtsc
	mov [initialtsc], eax
	mov [initialtsc + 4], edx
	mov [lasttsc], eax
	mov [lasttsc + 4], edx
	mov [DriveNumber], cl
	mov [lbaad], ebx
%ifdef io.serial
	call getmemorysize
	mov si, serialmsg
	call printrm
	jmp pmode
serialmsg: db 10,13,"SollerOS: Using serial port ",io.serial," for I/O.",0
%else
	call vgaset	;make users switch using a command-this leads to very fast boots
	call getmemorysize	;get the memory map after the video is initialized
	jmp pmode
%endif
	
vgaset:
	mov ax, 12h
	xor bx, bx
	int 10h
	mov byte [guion], 0
	ret

getmemorysize:
	mov di, memlistbuf
	xor ebx, ebx
.lp:
	mov eax, 0xE820
	mov edx, 0x0534D4150
	mov ecx, 24
	int 0x15
	add di, 24
	cmp di, memlistend
	jae .done
	test ebx, ebx
	jnz .lp
.done:
	sub di, memlistbuf
	mov [memlistend], di
	ret
	
printrm:			; 'si' comes in with string address
    mov bx,07		; write to display
    mov ah,0Eh		; screen function
   .lp:    mov al,[si]         ; get next character
    test al,al		; look for terminator 
    jz .done	; zero byte at end of string
    int 10h		; write character to screen.    
	inc si	     	; move to next character
    jmp .lp		; loop
.done: ret
