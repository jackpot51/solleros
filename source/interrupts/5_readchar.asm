readchar:
	call rdcharint
	jmp timerinterrupt
getchar:
	xor al, al
	rdcharint:		;get char, if al is 0, wait for key
		mov word [trans], 1
		cmp al, 0
		jne transcheck
		mov word [trans], 0
	transcheck:
	%ifdef io.serial
		call serial.receive
		xor ah, ah
		cmp al, 13
		je rdenter
	%else
		call getkey
		mov ax, [lastkey + 2]
		cmp ax, 1
		je rdend ;return if ESC
		cmp ax, 0x1C
		je rdenter
	%endif
		mov ax, [lastkey]
		mov bx, [trans]
		cmp byte [specialkey], 0xE0
		jne nospecialtrans
	nospecialtrans:
		or bx, ax
		cmp bx, 0
		je transcheck
		jmp rdend
	rdenter:
		shl eax, 16
		mov ax, 10
		mov [lastkey], eax
	rdend:
		mov eax, [lastkey]
		ret
		
lastkey dd 0
trans dw 0
