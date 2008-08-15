gui:	;Let's see what I can do
	;I am going to try to make this as freestanding as possible
	mov byte [guion], 1
	call clear
	mov si, ghostie
	mov ax, 0
	mov bx, boo
	mov cx, 150
	mov dx, 100
	call showicon
	mov si, pacmsg
	mov cx, 40
	mov dx, 120
	mov ax, 0
	mov bx, 0
	call showstring
	mov si, pacman
	mov ax, 0
	mov bx, pacmannomnom
	mov cx, 80
	mov dx, 130
	call showicon
	mov si, pacmanpellet
	mov ax, 0
	mov bx, 0
	mov cx, 80
	mov dx, 80
	call showicon
	mov si, start
	mov cx, 464
	mov dx, 0
	mov ax, 0
	mov bx, winblows
	call showstring
	mov si, gotomenu
	mov cx, 0
	mov dx, 0
	mov ax, 0
	mov bx, gotomenuboot
	call showstring
	mov dx, [mousecursorposition]
	mov cx, [mousecursorposition + 2]
	mov bx, 0
	mov ah, 0
	mov al, 170
	call savefont
guiloop:
	call cursorgui
	jmp guiloop

mousecursorposition dw 132,132	
guion db 0

	cursorgui:
		cmp byte [mouseon],1
		je .maincall2
		call MAINP
		mov byte [mouseon],1
		.maincall2:
		call mousemain
	showpixelcursor:
		mov dx, [mousecursorposition]
		mov cx, [mousecursorposition + 2]
		mov bx, 0
		mov ah, 0
		mov al, 170
		call showfont
		mov dx, [mousecursorposition]
		mov cx, [mousecursorposition + 2]
		mov al, [XCOORD]
		add al, al
		cmp al, 128
		jae subxcoord
		mov ah, 0
		add dx, ax
		jmp subxcoorddn
	subxcoord:
		mov bl, 0
		sub bl, al
		mov bh, 0
		sub dx, bx
	subxcoorddn:
		mov bl, [YCOORD]
		mov al, 0
		sub al, bl
		cmp al, 128
		jae subycoord
		mov ah, 0
		add cx, ax
		jmp subycoorddn
	subycoord:
		mov bl, 0
		sub bl, al
		mov bh, 0
		sub cx, bx
	subycoorddn:
		cmp dx, 10000
		jbe nooriginx2
		mov dx, 0
	nooriginx2:
		cmp cx, 10000
		jbe nooriginy2
		mov cx, 0
	nooriginy2:
		cmp dx, 638
		jbe nofixxcolumn2
		mov dx, 638
	nofixxcolumn2:
		cmp cx, 478
		jbe nofixyrow2
		mov cx, 478
	nofixyrow2:
		cmp byte [LBUTTON], 1
		je clickicon
		cmp byte [RBUTTON], 1
		je clickicon
		mov [mousecursorposition], dx
		mov [mousecursorposition + 2], cx
		mov bx, 0
		mov ah, 0
		mov al, 170
		call savefont
		mov dx, [mousecursorposition]
		mov cx, [mousecursorposition + 2]
		mov bx, 0
		mov ah, 0
		mov al, 169
		call showfont
		ret

	clickicon:
		mov si, graphicstable
		mov word [codepointer], 0
	clicon2:
		cmp word [si], 1
		je near iconselect
		cmp word [si], 2
		je near textselected
		cmp word [si], 0
		je near nexticonsel
	iconselect:
		mov dx, [si + 4]
		mov ax, dx
		add ax, 32
		mov cx, [si + 6]
		mov bx, cx
		add bx, 32
		cmp [mousecursorposition], dx
		jb near nexticonsel
		cmp [mousecursorposition], ax
		ja near nexticonsel
		cmp [mousecursorposition + 2], cx
		jb near nexticonsel
		cmp [mousecursorposition + 2], bx
		ja near nexticonsel
		cmp word [si + 8], 1
		je near unselecticon
		mov word [si + 8], 1
		mov ax, [si + 2]
		mov bx, [si + 10]
		mov si, ax
		mov ax, 1
		mov [codepointer], bx
		call showicon
		jmp doneiconsel
	unselecticon:
		mov word [si + 8], 0
		mov ax, [si + 2]
		mov si, ax
		mov ax, 0
		mov bx, [si + 10]
		call showicon
		mov word [codepointer], 0
		jmp doneiconsel
	textselected:
		mov bx, [si + 2]
		mov dx, [si + 4]
		mov ax, dx
		mov cx, [si + 6]
	lengthtesttext:
		cmp byte [bx], 0
		je donetesttextlength
		inc bx
		add ax, 8
		jmp lengthtesttext
	donetesttextlength:
		mov bx, cx
		add bx, 15
		cmp [mousecursorposition], dx
		jb near nexticonsel
		cmp [mousecursorposition], ax
		ja near nexticonsel
		cmp [mousecursorposition + 2], cx
		jb near nexticonsel
		cmp [mousecursorposition + 2], bx
		ja near nexticonsel
		cmp word [si + 8], 1
		je near unselecttext
		mov word [si + 8], 1
		mov bx, [si + 10]
		mov [codepointer], bx
		mov si, [si + 2]
		mov ax, 1
		call showstring
		jmp doneiconsel
	unselecttext:
		mov word [si + 8], 0
		mov bx, [si + 10]
		mov si, [si + 2]
		mov word [codepointer], 0
		mov ax, 0
		call showstring
		jmp doneiconsel		
	nexticonsel:
		add si, 12
		cmp si, graphicstableend
		jae doneiconsel
		jmp clicon2
	doneiconsel:
		cmp word [codepointer], 0
		je doneiconsel2
		mov bx, [codepointer]
		call bx
	doneiconsel2:
		mov dx, [mousecursorposition]
		mov cx, [mousecursorposition + 2]
		mov bx, 0
		mov ah, 0
		mov al, 170
		call savefont
		mov ah, 0
		mov al, 169
		mov dx, [mousecursorposition]
		mov cx, [mousecursorposition + 2]
		mov bx, 0
		call showfont
		ret

	graphicsadd:
		mov di, graphicstable
	shwgrph1:
		cmp word [di + 2], si
		je showgraphicsreplace
		add di, 12
		cmp di, graphicstableend
		jae showgraphicsnew
		jmp shwgrph1
	showgraphicsreplace:
		mov word [di + 2], si
		mov word [di + 4], dx
		mov word [di + 6], cx
		mov word [di + 10], bx
		mov bh, 0
		mov bl, ah
		mov ah, 0
		mov word [di + 8], ax		
		mov word [di], bx
		mov bx, [di + 10]
		mov ax, [di + 8]
		jmp showgraphics2
	showgraphicsnew:
		mov di, graphicstable
	shwgrph2:
		cmp word [di], 0
		je showgraphicsreplace
		add di, 12
		cmp di, graphicstableend
		jae showgraphics2
		jmp shwgrph2		
	showgraphics2:
		ret

	showstring:
		mov ah, 2
		mov [mouseselecton], al
		call graphicsadd
	showstring2:
		mov ah, 0
		mov al, [si]
		cmp al, 0
		je doneshowstring
		inc si
		mov [showstringsi], si
		call showfont
		add dx, 8
		mov si, [showstringsi]
		jmp showstring2
	doneshowstring:
		mov byte [mouseselecton], 0
		ret
		
	showicon:	;;icon in si, position in (dx,cx), selected in ax, code in bx
		mov ah, 1
		mov [iconselected], al
		call graphicsadd
		cmp dx, [screenx]
		jb screenxgood
		mov dx, [screenx]
		sub dx, 32
	screenxgood:
		mov bx, 8
		mov ax, dx
		mov dx, 0
		div bx
		mov [remainder], dx
		mov bx, ax
		sub bx, word [screenxdived]
		cmp cx, [screeny]
		jb screenygood
		mov cx, [screeny]
		sub cx, 32
	screenygood:
		add bx, word [screenxdived]
		loop screenygood
		mov cx, 31
		sub si, 4
	writeicon:
		add si, 7
		push cx

		mov ax, 0
		mov dl, 0
		mov dh, 11111111b
		mov al, [si]
		cmp byte [iconselected], 1
		jne nosel1
		not al
	nosel1:	mov cx, [remainder]
		cmp cx, 0
		je wi12
	wi1:	ror ax, 1
		ror dx, 1
		loop wi1
	wi12:	and dx, [gs:bx]
		mov [gs:bx], ax
		or [gs:bx], dx
		add bx, 1
		sub si, 1

		mov ax, 0
		mov dl, 0
		mov dh, 11111111b
		mov al, [si]
		cmp byte [iconselected], 1
		jne nosel2
		not al
	nosel2:	mov cx, [remainder]
		cmp cx, 0
		je wi22
	wi2:	ror ax, 1
		ror dx, 1
		loop wi2
	wi22:	and dx, [gs:bx]
		mov [gs:bx], ax
		or [gs:bx], dx
		add bx, 1
		sub si, 1

		mov ax, 0
		mov dl, 0
		mov dh, 11111111b
		mov al, [si]
		cmp byte [iconselected], 1
		jne nosel3
		not al
	nosel3:	mov cx, [remainder]
		cmp cx, 0
		je wi32
	wi3:	ror ax, 1
		ror dx, 1
		loop wi3
	wi32:	and dx, [gs:bx]
		mov [gs:bx], ax
		or [gs:bx], dx
		add bx, 1
		sub si, 1

		mov ax, 0
		mov dl, 0
		mov dh, 11111111b
		mov al, [si]
		cmp byte [iconselected], 1
		jne nosel4
		not al
	nosel4:	mov cx, [remainder]
		cmp cx, 0
		je wi42
	wi4:	ror ax, 1
		ror dx, 1
		loop wi4
	wi42:	and dx, [gs:bx]
		mov [gs:bx], ax
		or [gs:bx], dx
		sub bx, 3

		add bx, word [screenxdived]
		pop cx
		loop writeiconjump
		ret
	writeiconjump:
		jmp writeicon
		
		

	;Here are some vars
	showstringsi db 0,0
	pacmsg	db "Pacman was awesome!",0
	pacnom  db "Om nom nom nom",0
	start	db "start",0
	gotomenu db "SollerOS",0
	winmsg	db "windows sucks balls",0
	screenxdived dw 80
	screenx dw 640
	screeny dw 480
	icon dw 0	;pointer to icon
	codepointer dw 0 ;pointer to code
	iconselected db 0
	
	gotomenuboot:
		call clear
	mov byte [guion], 0
		jmp bootit

	winblows:
		mov si, winmsg
		mov dx, 0
		mov cx, 448
		mov bx, 0
		mov ax, 1
		call showstring
		ret

	pacmannomnom:
		mov si, pacnom
		mov dx, 130
		mov cx, 60
		mov bx, 0
		mov ax, 0
		call showstring
		ret

	boomsg db "Boo",0
	boo:
		mov si, boomsg
		mov dx, 100
		mov cx, 320
		mov bx, 0
		mov ax, 0
		call showstring
		ret
		

	graphicstable
	times 200h dw 0
	graphicstableend

	cursor	db	10000000b ;cursor bitmap, monochrome, 8x16
		db	11000000b
		db	11100000b
		db	11110000b
		db	11111000b
		db	11111100b
		db	11111110b
		db	11111111b
		db	11111100b
		db	11011100b
		db	10011100b
		db	00011100b
		db	00011100b
		db	00001110b
		db	00001110b
		db	00000110b

	pacmanpellet
		dd	00000000000000000000000000000000b ;32x32 icon
		dd	00000000000000000000000000000000b
		dd	00000000000000000000000000000000b
		dd	00000000000000000000000000000000b
		dd	00000000000000000000000000000000b
		dd	00000000000000000000000000000000b
		dd	00000000000000000000000000000000b
		dd	00000000000000000000000000000000b
		dd	00000000000000000000000000000000b
		dd	00000000000000000000000000000000b ;because I can
		dd	00000000000000000000000000000000b
		dd	00000000000000111100000000000000b
		dd	00000000000001111110000000000000b
		dd	00000000000011111111000000000000b
		dd	00000000000111111111100000000000b
		dd	00000000000111111111100000000000b
		dd	00000000000111111111100000000000b
		dd	00000000000111111111100000000000b
		dd	00000000000011111111000000000000b
		dd	00000000000001111110000000000000b
		dd	00000000000000111100000000000000b
		dd	00000000000000000000000000000000b
		dd	00000000000000000000000000000000b
		dd	00000000000000000000000000000000b
		dd	00000000000000000000000000000000b
		dd	00000000000000000000000000000000b
		dd	00000000000000000000000000000000b
		dd	00000000000000000000000000000000b
		dd	00000000000000000000000000000000b
		dd	00000000000000000000000000000000b
		dd	00000000000000000000000000000000b
		dd	00000000000000000000000000000000b


	pacman	dd	00000000000000000000000000000000b	;Icon 32x32
		dd	00000000000000000000000000000000b
		dd	00000000000000000000000000000000b
		dd	00000000000000000000000000000000b
		dd	00000000000000000000000000000000b
		dd	00000000000011111111000000000000b ;because I can
		dd	00000000000011111111000000000000b
		dd	00000000001111111111110000000000b
		dd	00000000001111111111110000000000b
		dd	00000000111111111111111100000000b
		dd	00000000111111111111111100000000b
		dd	00000000000011111111111111000000b
		dd	00000000000011111111111111000000b
		dd	00000000000000001111111111100000b
		dd	00000000000000001111111111100000b
		dd	00000000000000000000111111100000b
		dd	00000000000000000000111111100000b
		dd	00000000000000001111111111100000b
		dd	00000000000000001111111111100000b
		dd	00000000000011111111111111000000b
		dd	00000000000011111111111111000000b
		dd	00000000111111111111111100000000b
		dd	00000000111111111111111100000000b
		dd	00000000001111111111110000000000b
		dd	00000000001111111111110000000000b
		dd	00000000000011111111000000000000b
		dd	00000000000011111111000000000000b
		dd	00000000000000000000000000000000b
		dd	00000000000000000000000000000000b
		dd	00000000000000000000000000000000b
		dd	00000000000000000000000000000000b
		dd	00000000000000000000000000000000b

	ghostie	dd	00000000000000000000000000000000b	;Icon 32x32
		dd	00000000000000000000000000000000b
		dd	00000000000011111111000000000000b
		dd	00000000000011111111000000000000b
		dd	00000000111111111111111100000000b
		dd	00000000111111111111111100000000b ;because I can
		dd	00000011111111111111111111000000b
		dd	00000011111111111111111111000000b
		dd	00001111111111111111111111110000b
		dd	00001111111111111111111111110000b
		dd	00001111111111111111111111110000b
		dd	00001111111111111111111111110000b
		dd	00001111000011111111000011110000b
		dd	00001111000011111111000011110000b
		dd	00111100011000111100011000111100b
		dd	00111100111100111100111100111100b
		dd	00111100111100111100111100111100b
		dd	00111100011000111100011000111100b
		dd	00111111000011111111000011111100b
		dd	00111111000011111111000011111100b
		dd	00111111111111111111111111111100b
		dd	00111111111111111111111111111100b
		dd	00111111111111111111111111111100b
		dd	00111111111111111111111111111100b
		dd	00111111111111111111111111111100b
		dd	00111111111111111111111111111100b
		dd	00111100111111000011111100111100b
		dd	00111100111111000011111100111100b
		dd	00110000001111000011110000001100b
		dd	00110000001111000011110000001100b
		dd	00000000000000000000000000000000b
		dd	00000000000000000000000000000000b