	[BITS 32]
	[ORG 0x400000]
	db "EX"
	tely:
		mov esi, line
		mov bx, 7
		mov al, 0
		mov ah, 1
		int 30h
		mov [telydx], dx
		mov ecx, 0
		mov edx, 0
		mov eax, 0
	      	mov dx, [BASEADDRSERIAL]		;;initialize serial
		mov al, 0
		add dx, 1
		out dx, al
	      	mov dx, [BASEADDRSERIAL]
		mov al, 80h
		add dx, 3
		out dx, al
	      	mov dx, [BASEADDRSERIAL]
		mov al, 3
		out dx, al
		add dx, 1
		mov al, 0
		out dx, al
	      	mov dx, [BASEADDRSERIAL]
		mov al, 3
		add dx, 3
		out dx, al
	      	mov dx, [BASEADDRSERIAL]
		mov al, 0c7h
		add dx, 2
		out dx, al
	      	mov dx, [BASEADDRSERIAL]
		mov al, 0Bh
		add dx, 4
		out dx, al
		mov cx, 1000
	telyreceive:
		mov ax, 0
		mov dx, [BASEADDRSERIAL]		;;wait until char received or keyboard pressed
		add dx, 5
		in al, dx
		cmp al, 1
		je telyreceive2
		loop telyreceive
		mov al, 23
		mov ah, 5
		int 30h
		cmp ah, 0x1
		je near donetely
		mov ah, al
		mov al, 0
		mov cx, 100
		cmp ah, 13
		jne telysend
		mov ah, 10
		jmp telysend

	nullchar db 0,0

	telyreceive2:
		mov dx, [BASEADDRSERIAL]
		in al, dx
		mov [chartely], al
		mov dx, [telydx]
		mov esi, chartely
		cmp byte [chartely], 10
		je telyline
		cmp byte [chartely], 13
		je telyline
		cmp byte [chartely], 0Eh
		je novalidchartely
		jmp notelyline
	telyline:
		mov esi, line
	notelyline:
		mov bx, 7
		mov al, 0
		mov ah, 1
		int 30h
	novalidchartely:
		mov [telydx], dx
		mov cx, 1000
		jmp telyreceive
		
		chartely db 0,0,0
		chartely2 db 0,0,0

	telysend:
		mov dx, [BASEADDRSERIAL]		;;wait until transmit is empty
		add dx, 5
		in al, dx
		cmp al, 20h
		jne telysend2
		loop telysend
	telysend2:	
		mov [chartely2], ah				;;send ASCII
		mov al, ah
		mov dx, [BASEADDRSERIAL]
		out dx, al
		mov cx, 1000
		cmp al, 0
		je telyreceive
		mov dx, [telydx]
		mov esi, chartely2
		cmp byte [chartely2], 10
		je telyline2
		cmp byte [chartely2], 13
		je telyline2
		cmp byte [chartely2], 0Eh
		je novalidchartely2
		jmp notelyline2
	telyline2:
		mov esi, line
	notelyline2:
		mov al, 0
		mov ah, 1
		mov bx, 0f8h
		int 30h
	novalidchartely2:
		mov [telydx], dx
		mov cx, 1000
		jmp telyreceive
	donetely:
		mov dx, [telydx]
		mov esi, line
		mov ah, 1
		mov al, 0
		int 30h
		mov ax, 0
		int 30h

line db 10,13,0
BASEADDRSERIAL dw 03f8h
telydx dw 0
com dw 0