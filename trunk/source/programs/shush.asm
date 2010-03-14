db 255,44,"shush",0	;if you add 2 values it will switch size using the first as X in chars and the second as Y in chars
shushprog:
%ifdef gui.included
	cmp byte [guion], 0
	je near .noswitchsize
	mov esi, [currentcommandloc]
	add esi, 6
	push esi
	dec esi
.findspace:
	inc esi
	mov al, [esi]
	cmp al, 0
	je near .noswitchsize
	cmp al, "X"
	je .donefind
	cmp al, "x"
	je .donefind
	cmp al, " "
	jne .findspace
.donefind:
	xor al, al
	mov [esi], al
	inc esi
	mov edi, esi
	call cnvrttxt
	mov eax, ecx
	pop esi
	push eax
	mov edi, esi
	call cnvrttxt
	mov ebx, ecx
	pop eax	
	cmp bx, 0
	je near .noswitchsize
	cmp ax, 0
	je near .noswitchsize
	shl bx, 3
	shl ax, 4
	cmp bx, [resolutionx]
	jbe .nofixx
	mov bx, [resolutionx]
.nofixx:
	add ax, 16
	cmp ax, [resolutiony]
	jbe .nofixy
	mov ax, [resolutiony]
.nofixy:
	sub ax, 16
	xor cx, cx
	xor dx, dx
	mov [termwindow], bx
	mov [termwindow + 2], ax	;the previous lines of code make a large terminal window that is 4 characters smaller than the screen
	mov esi, termwindow
	xor ebx, ebx
	xor ax, ax
	call showwindow
	call guiclear
	call clear
	call reloadallgraphics
	call switchmousepos2
.noswitchsize:
%endif
	mov esi, shushmsg
	call print
	ret
	shushmsg db "Welcome to the SollerOS Hardly Unix-Compatible Shell!",10,0
