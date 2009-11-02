db 255,44,"chars",0
	mov bx, 7
	mov al, " "
	call int301prnt
	call int301prnt
	call int301prnt
	call int301prnt
	mov al, "0"
charmapnumprnt:
	call int301prnt
	inc al
	push ax
	mov al, " "
	call int301prnt
	pop ax
	cmp al, "9"
	jbe charmapnumprnt
	mov al, "A"
charmapnumprnt2:
	call int301prnt
	inc al
	push ax
	mov al, " "
	call int301prnt
	pop ax
	cmp al, "G"
	jb charmapnumprnt2
	
	mov esi, line
	call printquiet
	xor ax, ax
	mov cl, al
	call showhexsmall
	jmp charmapnocopy ;the first char is 0 which is unprintable
charmapcopy:
	inc al
	push ax
	cmp al, 8
	je charmapnocopy
	cmp al, 9
	je charmapnocopy
	cmp al, 10
	je charmapnocopy
	cmp al, 13
	je charmapnocopy
	cmp al, 255
	je charmapnocopy
	cmp al, 0
	je nomorecharmap
	call int301prnt
	mov al, " "
	call int301prnt
	pop ax
charmapcopycheck:
	inc ah
	cmp ah, 16
	jb charmapcopy
	push ax
	mov esi, line
	call printquiet
	pop ax
	cmp al, 255
	je nomorecharmap
	mov cl, al
	inc cl
	call showhexsmall
	xor ah, ah
	jmp charmapcopy
nomorecharmap:
	jmp nwcmd
charmapnocopy:
	push ax
	mov al, " "
	call int301prnt
	call int301prnt
	pop ax
	jmp charmapcopycheck