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
		call getkey
		mov bh, [trans]
		mov ax, [lastkey]
		cmp ah, 1Ch
		je rdenter
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
		mov al, 10
	rdend:
		ret
		
lastkey db 0,0
trans db 0
