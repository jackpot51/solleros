charmapnum db 0
db 255,44,"charmap",0
	mov esi, [currentcommandloc]
	add esi, 9
	cmp byte [esi], 0
	je .nospecific
	call cnvrthextxt
	mov ax, cx
	mov bx, 7
	call prcharq
	ret
.nospecific:
	mov bx, 7
	mov ax, " "
	mov byte [charmapnum], 0
	call prcharq
	call prcharq
	call prcharq
	call prcharq
	mov ax, "0"
charmapnumprnt:
	call prcharq
	inc ax
	push ax
	mov ax, " "
	call prcharq
	pop ax
	cmp ax, "9"
	jbe charmapnumprnt
	mov ax, "A"
charmapnumprnt2:
	call prcharq
	inc ax
	push ax
	mov ax, " "
	call prcharq
	pop ax
	cmp ax, "G"
	jb charmapnumprnt2
	
	mov esi, line
	call printquiet
	xor ax, ax
	mov cx, ax
	call showhexsmall
	jmp charmapnocopy ;the first char is 0 which is unprintable
charmapcopy:
	inc ax
	push ax
	cmp ax, 8
	je charmapnocopy
	cmp ax, 9
	je charmapnocopy
	cmp ax, 10
	je charmapnocopy
	cmp ax, 13
	je charmapnocopy
	cmp ax, 255
	je charmapnocopy
	cmp ax, 256
	je nomorecharmap
	call prcharq
	mov ax, " "
	call prcharq
	pop ax
charmapcopycheck:
	inc byte [charmapnum]
	cmp byte [charmapnum], 16
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
	mov byte [charmapnum], 0
	jmp charmapcopy
nomorecharmap:
	ret
charmapnocopy:
	push ax
	mov ax, " "
	call prcharq
	call prcharq
	pop ax
	jmp charmapcopycheck
