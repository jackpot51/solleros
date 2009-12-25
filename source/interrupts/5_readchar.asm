	call rdcharint
	jmp timerinterrupt
getchar:
	xor al, al
	rdcharint:		;;get char, if al is 0, wait for key
		mov byte [trans], 1
		cmp al, 0
		jne transcheck
		mov byte [trans], 0
	transcheck:
	%ifdef io.serial
		call serial.receive
		cmp al, 13
		je rdenter
	%else
		call getkey
		mov ax, [lastkey]
		cmp ah, 0x1C
		je rdenter
	%endif
		mov bh, [trans]
		cmp byte [specialkey], 0xE0
		jne nospecialtrans
		mov bl, al
		xor al, al
	nospecialtrans:
		or bh, al
		cmp bh, 0
		je transcheck
		jmp rdend
	rdenter:
		mov ah, 0x1C
		mov al, 10
		mov [lastkey], ax
	rdend:
		ret
		
lastkey db 0,0
trans db 0
