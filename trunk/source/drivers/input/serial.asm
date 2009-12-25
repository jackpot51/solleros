serial:
	.init:
	    mov dx, [.address]
		mov al, 0
		add dx, 1
		out dx, al		;disable interrupts
	    mov dx, [.address]
		mov al, 80h
		add dx, 3
		out dx, al		;enable DLAB
	    mov dx, [.address]
		mov al, 1
		out dx, al
		add dx, 1
		mov al, 0
		out dx, al		;set divisor(buad=115200/divisor)
	    mov dx, [.address]
		mov al, 3
		add dx, 3
		out dx, al		;8 bits, no parity, one stop bit
	    mov dx, [.address]
		mov al, 0c7h
		add dx, 2
		out dx, al		;enable FIFO
	    mov dx, [.address]
		mov al, 0Bh
		add dx, 4
		out dx, al		;IRQs enabled, RTS/DSR set
		ret
		
	.receiveloop:
		sti
		hlt
		cmp byte [trans], 0
		je .receive
		ret
	.receive:
		xor ah, ah
		mov dx, [.address]
		in al, dx
		cmp al, 0
		je .receiveloop
	.nowait:
		cmp al, 0x1B
		je .special
		cmp al, 127
		je .del
		cmp al, 0x7E
		je .home
	.doner:
		mov ah, 0xFF
		mov byte [specialkey], 0
	.done:
		mov [lastkey], ax
		ret
		
	.del:
		mov al, 8;replace delete with backspace
		jmp .doner
		
	.home:
		cmp byte [specialkey], 0x1B
		jne .doner
		xor al, al
		jmp .receive
	
	.exitcode:
		mov ah, 1
		xor al, al
		jmp .done
		
	.special:
		in al, dx
		cmp al, 0x5B
		jne .exitcode
		mov byte [specialkey], 0x1B
		in al, dx
		mov ah, al
		xor al, al
		jmp .done

	.send:
		mov ecx, 256
		xchg al, ah
	.send1:
		mov dx, [.address]		;wait until transmit is empty or cx is empty
		add dx, 5
		in al, dx
		cmp al, 20h
		jne .send2
		loop .send1
	.send2:
		xchg al, ah
		cmp al, 0
		je .nosend
		mov dx, [.address]
		out dx, al
		cmp al, 10
		jne .nosend
		mov al, 13
		out dx, al
		mov al, 10
	.nosend:
		ret

%if io.serial == "1"
	.address dw 0x3F8
%endif
%if io.serial == "2"
	.address dw 0x2F8
%endif
%if io.serial == "3"
	.address dw 0x3E8
%endif
%if io.serial == "4"
	.address dw 0x2E8
%endif
specialkey db 0