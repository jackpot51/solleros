db 255,44,"keys",0
keycode:
	mov byte [trans], 0
	mov byte [threadson], 0
	call getkey
	xor eax, eax
	xor ecx, ecx
	mov cl, [specialkey]
	cmp cl, 0
	je near nospecialkeycode
	call showhexsmall
nospecialkeycode:
	mov ax, [lastkey]
	mov cl, ah
	call showhexsmall
	cmp ah, 1
	jne keycode
	jmp nwcmd