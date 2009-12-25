serial:
	.init:
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
		ret
		
	.receive:
		mov dx, [BASEADDRSERIAL]
		in al, dx
		cmp al, 127
		jne .doner
		mov al, 8;replace delete with backspace
	.doner:
		ret

	.send:
		mov ecx, 256
		xchg al, ah
	.send1:
		mov dx, [BASEADDRSERIAL]		;wait until transmit is empty or cx is empty
		add dx, 5
		in al, dx
		cmp al, 20h
		jne .send2
		loop .send1
	.send2:
		xchg al, ah
		cmp al, 0
		je .nosend
		mov dx, [BASEADDRSERIAL]
		out dx, al
		cmp al, 10
		jne .nosend
		mov al, 13
		out dx, al
		mov al, 10
	.nosend:
		ret

BASEADDRSERIAL dw 03f8h
specialkey db 0