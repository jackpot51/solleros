%include "include.inc"
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
		call print
		xor ebx, ebx
		jmp exit
	noportnum db "You must enter a port number from 1 to 4.",10,0
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
		mov esi, telyreceive
		mov ah, 11 
		int 0x30 ;start receive thread
	telykeys:
		hlt
		mov al, 1
		mov ah, 5
		int 0x30
		rol eax, 16
		cmp al, 1
		je exittely
		rol eax, 16
		cmp al, 0
		je telykeys
		mov ah, al
		xor al, al
		cmp ah, 13
		jne telysend
		mov ah, 10
		jmp telysend

	telysend:
		mov dx, [BASEADDRSERIAL]		;wait until transmit is empty
		add dx, 5
		in al, dx
		cmp al, 20h
		je telysend
		mov al, ah
		cmp al, 0
		je telykeys
		mov dx, [BASEADDRSERIAL]
		out dx, al
		cmp al, 10
		jne telykeys
		mov ah, 13
		jmp telysend

	telyreceive:
		hlt
		mov dx, [BASEADDRSERIAL]
		in al, dx
		cmp al, 0
		je telyreceive
		cmp al, 13
		je printline
		mov bx, 7
		mov ah, 6
		int 30h
		jmp telyreceive

	printline:
		mov esi, line
		call print
		jmp telyreceive
		
	exittely:
		xor ebx, ebx
		jmp exit

BASEADDRSERIAL dw 03f8h
