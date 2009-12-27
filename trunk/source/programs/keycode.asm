db 255,44,"keycode",0
keycode:
	mov byte [trans], 0
	mov byte [threadson], 0
%ifdef io.serial
.noserial:
	hlt
	mov dx, [serial.address]
	in al, dx
	cmp al, 0
	je .noserial
	mov cl, al
	call showhexsmall
	cmp al, 0x1B
	jne .noserial
	in al, dx
	mov cl, al
	call showhexsmall
	cmp cl, 0x5B
	je .noserial
	ret
%else
	call getkey
	xor eax, eax
	xor ecx, ecx
	mov cl, [specialkey]
	cmp cl, 0
	je near .nospecialkeycode
	call showhexsmall
.nospecialkeycode:
	mov ax, [lastkey]
	mov cl, ah
	call showhexsmall
	cmp ah, 1
	jne keycode
	ret
%endif