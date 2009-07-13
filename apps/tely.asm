	[BITS 32]
	[ORG 0x400000]
	db "EX"
	tely:
		mov word [BASEADDRSERIAL], 3F8h
		cmp byte [edi], "1"
		je near nofix
		mov word [BASEADDRSERIAL], 2F8h
		cmp byte [edi], "2"
		je near nofix
		mov word [BASEADDRSERIAL], 3E8h
		cmp byte [edi], "3"
		je near nofix
		mov word [BASEADDRSERIAL], 2E8h
		cmp byte [edi], "4"
		je near nofix
		mov esi, noportnum
		mov al, 0
		mov ah, 1
		mov bl, 7
		int 30h
		mov ax, 0
		int 30h
	noportnum db "You must enter a port number from 1 to 4.",10,13,0
	nofix:
		mov ecx, 0
		mov edx, 0
		mov eax, 0
	      	mov dx, [BASEADDRSERIAL]
		mov al, 0
		add dx, 1
		out dx, al		;disable interrupts
	      	mov dx, [BASEADDRSERIAL]
		mov al, 80h
		add dx, 3
		out dx, al		;enable DLAB
	      	mov dx, [BASEADDRSERIAL]
		mov al, 1
		out dx, al
		add dx, 1
		mov al, 0
		out dx, al		;set divisor(buad=115200/divisor)
	      	mov dx, [BASEADDRSERIAL]
		mov al, 3
		add dx, 3
		out dx, al		;8 bits, no parity, one stop bit
	      	mov dx, [BASEADDRSERIAL]
		mov al, 0c7h
		add dx, 2
		out dx, al		;enable FIFO
	      	mov dx, [BASEADDRSERIAL]
		mov al, 0Bh
		add dx, 4
		out dx, al		;IRQs enabled, RTS/DSR set
	telyreceive:
		mov ax, 0
		mov dx, [BASEADDRSERIAL]		;;wait until char received or keyboard pressed
		add dx, 5
		in al, dx
		cmp al, 1
		je testin
		mov dx, [BASEADDRSERIAL]
		in al, dx
		cmp al, 0
		je testin
		mov bx, 7
		;cmp al, 10
		;je printline
		;cmp al, 13
		;je printline
		mov ah, 6
		int 30h
	testin:
		mov al, 23
		mov ah, 5
		int 30h
	;	cmp ah, 0x1
	;	je near donetely
		cmp al, 0
		je near telyreceive
		mov ah, al
		mov al, 0
		mov cx, 100
		cmp ah, 10
		jne telysend
		;mov al, 10
		;mov ah, 6
		;mov bx, 0xf8
		;int 30h
		mov ah, 13
		jmp telysend
	printline:
		mov esi, line
		mov al, 0
		mov ah, 1
		int 30h
		jmp testin

	telysend:
		mov dx, [BASEADDRSERIAL]		;;wait until transmit is empty
		add dx, 5
		in al, dx
		cmp al, 20h
		jne telysend2
		loop telysend
	telysend2:
		mov al, ah
		cmp al, 0
		je near telyreceive
		mov dx, [BASEADDRSERIAL]
		out dx, al
		;mov ah, 6
		;mov bx, 0f8h
		;int 30h
		jmp telyreceive
	;donetely:
	;	mov esi, line
	;	mov ah, 1
	;	mov al, 0
	;	int 30h
	;	mov ax, 0
	;	int 30h
	;	hlt

line db 10,13,0
BASEADDRSERIAL dw 03f8h
