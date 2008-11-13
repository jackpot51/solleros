guiclear:
	mov edi, [physbaseptr]
	mov dx, [resolutionx]
	mov cx, [resolutiony]
guiclearloop:
	mov ax, [background]
	mov [edi], ax
	add edi, 2
	dec dx
	cmp dx, 0
	ja guiclearloop
	dec cx
	mov dx, [resolutionx]
	cmp cx, 0
	ja guiclearloop
	ret
background dw 0111101111001111b



gui:	;Let's see what I can do
	;I am going to try to make this as freestanding as possible
	call indexfiles
	mov byte [guion], 1
	mov edi, [physbaseptr]
	mov dx, [resolutionx]
	mov cx, [resolutiony]
guiclearloop2:
	mov bx, [background]
	mov [edi], bx
	add edi, 2
	dec dx
	cmp dx, 0
	ja guiclearloop2
	dec cx
	mov dx, [resolutionx]
	cmp cx, 0
	ja guiclearloop2
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
	mov si, interneticon
	mov ax, 0
	mov bx, noie
	mov cx, 300
	mov dx, 100
	call showicon
	mov si, wordicon
	mov ax, 0
	mov bx, 0
	mov cx, 50
	mov dx, 50
	call showicon
	mov si, start
	mov cx, [resolutiony]
	sub cx, 16
	mov dx, 0
	mov ah, 0
	mov al, 00010000b
	mov bx, winblows
	call showstring
	call cursorgui
guistart:
	call guistartin
	jmp guistart
	guistartin:
		in al, 64h ; Status
		test al, 1 ; output buffer full?
		jz guistartin
		test al, 20h ; PS2-Mouse?
		jnz near maincall2
		in al, 60h
		dec al
		jz near guistartin
		inc al
		mov di, scancode
		add di, 2
	guisearchscan: cmp di, noscan
		jae guiscanother
		mov ah, [di]
		cmp al, ah
		je near guiscanfound
		add di, 3
		jmp guisearchscan
guiupper db 0
guiscanother:
		cmp al, 2Ah
		je near guishifton
		cmp al, 36h
		je near guishifton
		cmp al, 1Ch
		je near guientdown
		cmp al, 0AAh
		je near guishiftoff
		cmp al, 0B6h
		je near guishiftoff
		cmp al, 3Ah
		je near guishift
		jmp guistartin
	guishift:
		mov al, [guiupper]
		cmp al, 1
		jae guishiftoff
	guishifton:
		mov byte [guiupper], 1
		jmp guistartin
	guishiftoff:
		mov byte [guiupper], 0
		jmp guistartin
	guientdown:
		jmp guistartin
	guiscanfound:
		sub di, 1
		cmp byte [guiupper], 1
		jae uppercasegui
		sub di, 1
uppercasegui:
		mov al,[di]
		mov cx, 1
		mov dx, 1
		mov bx, 0xFFFF
		call showfontvesa
		jmp guistartin


guichar db 0
mousecursorposition dw 132,132	
guion db 0
lastmouseposition dw 132,132

	cursorgui:
		cmp byte [mouseon], 1
		je near maincall2
	  	call PS2SET
		call ACTMOUS
		call GETB 	;;Get the responce byte of the mouse (like: Hey i am active)
				;;If the bytes are mixed up,
				;;remove this line or add another of this line.
		call GETB
		mov byte [mouseon],1
	maincall2:  
		  xor  ax, ax
		  in   al, 0x60		; read ps/2 controller output port (mousebyte)
		  mov  bl, al
		  and  bl, 1
		  mov  BYTE [LBUTTON], bl
		  mov  bl, al
		  and  bl, 2
	          shr  bl, 1
		  mov  BYTE [RBUTTON], bl
		  mov  bl, al
		  and  bl, 4
		  shr  bl, 2
		  mov  BYTE [MBUTTON], bl
		  in   al, 0x60		; read ps/2 controller output port (mousebyte)
		  mov  BYTE [XCOORD], al
		  in   al, 0x60		; read ps/2 controller output port (mousebyte)
		  mov  BYTE [YCOORD], al

	showpixelcursor:
		mov dx, [mousecursorposition]
		mov cx, [mousecursorposition + 2]
		mov [lastmouseposition], dx
		mov [lastmouseposition + 2], cx
		mov al, [XCOORD]
		cmp al, 128
		jae subxcoord
		add al, al
		mov ah, 0
		add dx, ax
		jmp subxcoorddn
	subxcoord:
		add al, al
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
		cmp dx, 20000
		jbe nooriginx2
		mov dx, 0
	nooriginx2:
		cmp cx, 20000
		jbe nooriginy2
		mov cx, 0
	nooriginy2:
		cmp dx, 0
		je nofixxcolumn2
		cmp dx, [resolutionx2]
		jb nofixxcolumn2
		mov dx, [resolutionx2]
		sub dx, 2
	nofixxcolumn2:
		cmp cx, 0
		je nofixyrow2
		cmp cx, [resolutiony]
		jb nofixyrow2
		mov cx, [resolutiony]
		sub cx, 1
	nofixyrow2:
		mov [mousecursorposition], dx
		mov [mousecursorposition + 2], cx
		call switchmousepos
		cmp byte [LBUTTON], 1
		je clickicon
		cmp byte [RBUTTON], 1
		je clickicon
		mov al, [LBUTTON]
		mov [pLBUTTON], al
		mov al, [RBUTTON]
		mov [pRBUTTON], al
		mov word [dragging], 0
		mov ecx, 0
		mov edx, 0
		mov dx, [mousecursorposition]
		mov cx, [mousecursorposition + 2]
		mov bx, 1110011110011100b
		mov ah, 0
		mov al, 128
		mov byte [showcursorfonton], 1
		call showfontvesa
		mov byte [showcursorfonton], 0
		ret

pLBUTTON db 0

pRBUTTON db 0

dragging dw 0

lastpos dw 0,0

colorbuf dw 0,0
	
	clickicon:
		mov al, [pLBUTTON]
		and al, [LBUTTON]
		mov ah, [pRBUTTON]
		and ah, [RBUTTON]
		or al, ah
		cmp al, 0
		je nodragclick
		cmp word [dragging], 1
		jae dragclick
		mov word [dragging], 1
		jmp dragclick
	nodragclick:
		mov word [dragging], 0
		mov al, [LBUTTON]
		mov [pLBUTTON], al
		mov al, [RBUTTON]
		mov [pRBUTTON], al
	dragclick:
		mov ax, 0
		mov si, graphicstable
		mov word [codepointer], 0
	clicon2:
		mov edx, 0
		mov ecx, 0
		cmp word [si], 1
		je near iconselect
		cmp word [si], 2
		je near textselected
		cmp word [si], 3
		je near windowselect
		jmp nexticonsel
	iconselect:
		mov dx, [si + 4]
		mov ax, dx
		mov cx, [si + 6]
		mov bx, cx
		add bx, 32
		add ax, dx
		cmp word [dragging], 1
		je dragicon
		cmp word [dragging], 0
		je nodragiconcheck
		cmp word [dragging], si
		jne near nexticonsel
		jmp dragicon
	nodragiconcheck:
		cmp [mousecursorposition], ax
		jb near nexticonsel
		add ax, 64
		cmp [mousecursorposition], ax
		ja near nexticonsel
		sub ax, dx
		cmp [mousecursorposition + 2], cx
		jb near nexticonsel
		cmp [mousecursorposition + 2], bx
		ja near nexticonsel
		mov ax, [si + 8]
		and ax, 1
		cmp ax, 1
		je near unselecticon
		jmp nodragicon
	dragicon:
		cmp [lastmouseposition], ax
		jb near nexticonsel
		add ax, 64
		cmp [lastmouseposition], ax
		ja near nexticonsel
		sub ax, dx
		cmp [lastmouseposition + 2], cx
		jb near nexticonsel
		cmp [lastmouseposition + 2], bx
		ja near nexticonsel
		mov ax, [si + 8]
		and al, 00010000b
		cmp al, 00010000b
		je nodragicon
		mov [dragging], si
		shl dx, 1
		sub dx, [lastmouseposition]
		add dx, [mousecursorposition]
		shr dx, 1
		add cx, [mousecursorposition + 2]
		sub cx, [lastmouseposition + 2]
		cmp dx, [resolutionx2]
		jbe chkyresdrgicn
		mov dx, [mousecursorposition]
	chkyresdrgicn:
		cmp cx, [resolutiony]
		jbe nodragicon
		mov cx, [mousecursorposition + 2]
	nodragicon:
		or word [si + 8], 1
		mov bx, [si + 10]
		mov ax, [si + 8]
		mov si, [si + 2]
		mov word [codepointer], 0
		call showicon
		jmp doneiconsel
	unselecticon:
		and word [si + 8], 0xFFFE
		mov bx, [si + 10]
		mov ax, [si + 8]
		mov si, [si + 2]
		mov [codepointer], bx
		call showicon
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
		add ax, 16
		jmp lengthtesttext
	donetesttextlength:
		mov bx, cx
		add bx, 15
		cmp word [dragging], 1
		je dragtext
		cmp word [dragging], 0
		je nodragtextcheck
		cmp word [dragging], si
		jne near nexticonsel
		jmp dragtext
	nodragtextcheck:
		cmp [mousecursorposition], dx
		jb near nexticonsel
		cmp [mousecursorposition], ax
		ja near nexticonsel
		cmp [mousecursorposition + 2], cx
		jb near nexticonsel
		cmp [mousecursorposition + 2], bx
		ja near nexticonsel
		mov ax, [si + 8]
		and ax, 1
		cmp ax, 1
		je near unselecttext
		jmp nodragtext
	dragtext:
		cmp [lastmouseposition], dx
		jb near nexticonsel
		cmp [lastmouseposition], ax
		ja near nexticonsel
		cmp [lastmouseposition + 2], cx
		jb near nexticonsel
		cmp [lastmouseposition + 2], bx
		ja near nexticonsel
		mov ax, [si + 8]
		and al, 00010000b
		cmp ax, 00010000b
		je near nodragtext
		mov [dragging], si
		sub dx, [lastmouseposition]
		add dx, [mousecursorposition]
		add cx, [mousecursorposition + 2]
		sub cx, [lastmouseposition + 2]
		cmp dx, [resolutionx2]
		jbe chkyresdrgtxt
		mov dx, [mousecursorposition]
	chkyresdrgtxt:
		cmp cx, [resolutiony]
		jbe nodragtext
		mov cx, [mousecursorposition + 2]
	nodragtext:
		or word [si + 8], 1
		mov bx, [si + 10]
		mov [codepointer], bx
		mov ax, [si + 8]
		mov si, [si + 2]
		call showstring
		jmp doneiconsel
	unselecttext:
		and word [si + 8], 0xFFFE
		mov bx, [si + 10]
		mov ax, [si + 8]
		mov si, [si + 2]
		mov word [codepointer], 0
		call showstring
		jmp doneiconsel
windowselect:
		mov di, [si + 2]
		mov dx, [si + 4]
		mov ax, dx
		mov cx, [si + 6]
		mov bx, cx
		add bx, 16
		cmp word [dragging], 1
		je dragwin
		cmp word [dragging], 0
		je nodragwincheck
		cmp word [dragging], si
		jne near nexticonsel
		jmp dragwin
	nodragwincheck:
		cmp [mousecursorposition], ax
		jb near nexticonsel
		add ax, [di]
		add ax, [di]
		cmp [mousecursorposition], ax
		ja near nexticonsel
		cmp [mousecursorposition + 2], cx
		jb near nexticonsel
		cmp [mousecursorposition + 2], bx
		ja near nexticonsel
		sub ax, 20
		cmp [mousecursorposition], ax
		ja near killwin
		jmp nodragwin
	dragwin:
		cmp [lastmouseposition], ax
		jb near nexticonsel
		add ax, [di]
		add ax, [di]
		cmp [lastmouseposition], ax
		ja near nexticonsel
		cmp [lastmouseposition + 2], cx
		jb near nexticonsel
		cmp [lastmouseposition + 2], bx
		ja near nexticonsel
		mov [dragging], si
		sub dx, [lastmouseposition]
		add dx, [mousecursorposition]
		add cx, [mousecursorposition + 2]
		sub cx, [lastmouseposition + 2]
		cmp dx, [resolutionx2]
		jbe chkyresdrgwin
		mov dx, [mousecursorposition]
	chkyresdrgwin:
		cmp cx, [resolutiony]
		jbe nodragwin
		mov cx, [mousecursorposition + 2]
	nodragwin:
		mov bx, [si + 10]
		mov ax, [si + 8]
		mov si, [si + 2]
		call showwindow
		jmp doneiconsel
	killwin:
		mov word [si], 0
		call guiclear
		jmp doneiconsel2
	nexticonsel:
		and word [si + 8], 0xFFFE
		add si, 12
		cmp si, graphicstableend
		jae doneiconsel
		jmp clicon2
	doneiconsel:
		cmp word [dragging], 1
		jae doneiconsel2
		cmp word [codepointer], 0
		je doneiconsel2
		mov bx, [codepointer]
		jmp bx
	doneiconsel2:
		mov al, [LBUTTON]
		mov [pLBUTTON], al
		mov al, [RBUTTON]
		mov [pRBUTTON], al
	call reloadallgraphics
		mov ecx, 0
		mov edx, 0
		mov ah, 0
		mov al, 128
		mov dx, [mousecursorposition]
		mov cx, [mousecursorposition + 2]
		mov bx, 0011100011100111b
		mov byte [showcursorfonton], 1
		call showfontvesa
		mov byte [showcursorfonton], 0
		ret

lastdrag dw 0

grpctblpos dw 0


reloadallgraphics:

		mov di, graphicstable

reloadgraphicsloop:

		mov si, [di + 2]

		mov dx, [di + 4]

		mov cx, [di + 6]

		mov ax, [di]

		mov bx, [di + 8]

		mov [grpctblpos], di

		cmp di, [dragging]

		je loadedgraphic

		cmp ax, 1

		je near icongraphic

		cmp ax, 2

		je near stringgraphic

		cmp ax, 3

		je near windowgraphic

loadedgraphic:  mov di, [grpctblpos]

		add di, 12

		cmp di, graphicstableend

		jae donereloadgraphics

		jmp reloadgraphicsloop

windowgraphic:	call showwindow2

		jmp loadedgraphic

icongraphic:	and bl, 1

		mov [iconselected], bl

		call showicon2

		jmp loadedgraphic

stringgraphic:  and bl, 1

		mov [mouseselecton], bl

		call showstring2

		jmp loadedgraphic

donereloadgraphics:

		mov di, [dragging]

		cmp di, graphicstable

		jb notcorrectdrag

		mov ax, [di]

		mov si, [di + 2]

		mov dx, [di + 4]

		mov cx, [di + 6]

		mov bx, [di + 8]

		cmp ax, 1

		jne noticondragging

		and bl, 1

		mov [iconselected], bl

		call showicon2

		ret

	noticondragging:

		cmp ax, 2

		jne notcorrectdrag

		and bl, 1

		mov [mouseselecton], bl

		call showstring2

	notcorrectdrag:

		ret


grphbuf times 12 db 0

	graphicsadd:
		mov di, graphicstable
	shwgrph1:
		cmp word [di + 2], si
		je showgraphicsreplace2
		add di, 12
		cmp di, graphicstableend
		jae near showgraphicsnew
		jmp shwgrph1

	showgraphicsreplace2:
		mov [grphbuf + 2], si
		mov [grphbuf + 4], dx
		mov [grphbuf + 6], cx
		mov [grphbuf + 10], bx
		mov bh, 0
		mov bl, ah
		mov ah, 0
		mov [grphbuf + 8], ax	
		mov [grphbuf], bx

		mov ax, [grphbuf]

		cmp ax, 1

		je near replaceicon

		cmp ax, 2

		je near replacestring

		cmp ax, 3

		je near replacewindow

		jmp showgraphicsreplace

	replaceicon:

		mov [lastpos], di

		mov [lastpos + 2], si
		mov si, [di + 2]
		mov bx, [di + 10]

		mov dx, [di + 4]

		mov cx, [di + 6]

		mov ax, [si]

		mov [colorbuf], ax

		mov ax, [background]

		mov [si], ax
		mov bx, [di + 10]
		mov ax, [di + 8]

		and al, 1

		mov [iconselected], al

		mov ax, [di + 8]
		call showicon2

		mov di, [lastpos]

		mov si, [di + 2]

		mov ax, [colorbuf]

		mov [si], ax

		mov si, [lastpos + 2]

		mov dx, [grphbuf + 4]

		mov cx, [grphbuf + 6]

		mov bx, [grphbuf]

		mov ax, [grphbuf + 8]

		mov ah, bl

		mov bx, [grphbuf + 10]

		jmp showgraphicsreplace

	replacestring:

		mov [lastpos], di

		mov [lastpos + 2], si
		mov bx, [di + 10]
		mov si, [di + 2]

		mov dx, [di + 4]

		mov cx, [di + 6]

		mov ax, [colorfont2]

		mov [colorbuf], ax

		mov ax, [background]

		mov [colorfont2], ax		
		mov bx, [di + 10]
		mov ax, [di + 8]

		and al, 1

		mov [mouseselecton], al
		mov ax, [di + 8]
		call showstring2

		mov ax, [colorbuf]

		mov [colorfont2], ax

		mov di, [lastpos]

		mov si, [di + 2]

		mov dx, [grphbuf + 4]

		mov cx, [grphbuf + 6]

		mov bx, [grphbuf]

		mov ax, [grphbuf + 8]

		mov ah, bl

		mov bx, [grphbuf + 10]

		jmp showgraphicsreplace

	replacewindow:

		mov [lastpos], di

		mov [lastpos + 2], si
		mov si, [di + 2]

		mov edi, [windowbufloc]

		mov edx, 0

		mov dx, [resolutionx2]

		shl edx, 4

		sub edi, edx

		mov edx, 0

		mov dx, [si]

		add dx, [si]

		mov cx, [si + 2]

		add cx, 16

		mov ax, [background]

	clearwindow:

		mov [edi], ax

		add edi, 2

		sub edx, 2

		cmp edx, 0

		jne clearwindow

		dec cx

		mov dx, [resolutionx2]

		sub dx, [si]

		sub dx, [si]

		add edi, edx

		mov dx, [si]

		add dx, [si]

		cmp cx, 0

		jne clearwindow

		mov byte [termcopyon], 0

		mov di, [lastpos]

		mov si, [grphbuf + 2]

		mov dx, [grphbuf + 4]

		mov cx, [grphbuf + 6]

		mov bx, [grphbuf]

		mov ax, [grphbuf + 8]

		mov ah, bl

		mov bx, [grphbuf + 10]

		jmp showgraphicsreplace
	showgraphicsreplace:
		mov [di + 2], si
		mov [di + 4], dx
		mov [di + 6], cx
		mov [di + 10], bx
		mov bh, 0
		mov bl, ah
		mov ah, 0
		mov [di + 8], ax		
		mov [di], bx
		mov bx, [di + 10]
		mov ax, [di + 8]

		ret
	showgraphicsnew:
		mov di, graphicstable
	shwgrph2:
		cmp word [di], 0
		je showgraphicsreplace
		add di, 12
		cmp di, graphicstableend
		jb shwgrph2

	showgraphicsdone:
		ret

	showstring:
		mov [mouseselecton], al

		and byte [mouseselecton], 1

		mov ah, 2
		call graphicsadd
	showstring2:
		mov ah, 0
		mov al, [si]
		cmp al, 0
		je doneshowstring
		inc si
		mov [showstringsi], si

		mov bx, [colorfont2]
		call showfontvesa
		add dx, 8
		mov si, [showstringsi]
		jmp showstring2
	doneshowstring:
		mov byte [mouseselecton], 0
		ret


colorfont2 dw 0xFFFF


winvcopystx dw 0

winvcopysty dw 0

winvcopydx dw 0

winvcopycx dw 0

windowcolor dw 0xFFFF,0x0

windowbufloc: dw 0,0


	showwindow:	;;windowstuff in si, position in (dx, cx), nothing in ax, code in bx

		add cx, 16
		mov [winvcopystx], dx

		mov [winvcopysty], cx

		mov dx, [si]

		mov cx, [si + 2]

		add dx, dx

		mov [winvcopydx], dx

		mov [winvcopycx], cx

		mov cx, [winvcopysty]

		sub cx, 16

		mov dx, [winvcopystx]

		mov byte [termcopyon], 0

		mov ah, 3

		call graphicsadd

	showwindow2:

		add cx, 16

		mov [winvcopystx], dx

		mov [winvcopysty], cx

		mov dx, [si]

		mov cx, [si + 2]

		add dx, dx

		mov [winvcopydx], dx

		mov [winvcopycx], cx

		mov edi, [windowbufloc]

		mov edx, 0

		mov dx, [resolutionx2]

		shl edx, 4

		sub edi, edx

		cmp byte [termcopyon], 0

		jne nocleartitlebarpos

		mov edi, [physbaseptr]

		mov edx, 0

		mov dx, [winvcopystx]

		add edi, edx

		mov cx, [winvcopysty]

		sub cx, 16

		cmp cx, 0

		je nocleartitlebarpos

	cleartitlebarpos:

		mov edx, 0

		mov dx, [resolutionx2]

		add edi, edx

		dec cx

		cmp cx, 0

		jne cleartitlebarpos

	nocleartitlebarpos:

		mov cx, 16

		mov dx, [winvcopydx]

		cmp cx, 0

		je near canceltitlebarput

		cmp dx, 0

		je near canceltitlebarput

	titlebarput:

		mov ax, [windowcolor]

		mov [edi], ax

		sub dx, 2

		add edi, 2

		cmp dx, 0

		jne titlebarput

		mov edx, 0

		mov dx, [resolutionx2]

		dec cx

		sub dx, [winvcopydx]

		add edi, edx

		mov dx, [winvcopydx]

		cmp cx, 0

		jne titlebarput

	canceltitlebarput:

		mov [windowbufloc], edi

		cmp byte [termcopyon], 2

		je near winvcpst

		mov ax, 0

		add si, 4

		mov dx, [winvcopystx]

		mov cx, [winvcopysty]

		sub cx, 16

		mov bx, 0

		mov byte [mouseselecton], 1

		call showstring2

		mov al, "X"

		mov ah, 0

		mov bx, [colorfont2]

		mov dx, [winvcopystx]

		mov cx, [winvcopysty]

		sub cx, 16

		sub dx, 20

		add dx, [winvcopydx]

		mov byte [mouseselecton], 1

		call showfontvesa

	winvcpst:

		mov edi, [windowbufloc]

		jmp windowvideocopyset


	windowvideocopy:

		mov edi, [windowbufloc]
		cmp edi, [physbaseptr]

		jae near windowvideocopyset

		mov ecx, 0

		mov edx, 0

		mov dx, [winvcopystx]

		mov cx, [winvcopysty]

		mov edi, [physbaseptr]

		add edi, edx

		cmp ecx, 0

		je windowvideocopyset

	yrescopylp:

		mov edx, 0

		mov dx, [resolutionx2]

		add edi, edx

		dec cx

		cmp cx, 0

		jne yrescopylp

		mov [windowbufloc], edi

	windowvideocopyset:

		mov cx, 0
		mov [charposline], cx
		mov si, videobuf2
		mov [charposvbuf], si
		mov bl, [si]
		mov bh, 0
		shl bx, 4
		mov dh, [fonts + bx]

		ror dh, 1
		mov esi, edi

	copywindow:

		mov dl, 1
		rol dh, 1

		and dl, dh

		mov ax, [windowcolor + 2]

		mov [edi], ax

		cmp dl, 0

		je nowritewin

		mov ax, [windowcolor]

		mov [edi], ax

	nowritewin:

		add edi, 2

		inc cl

		cmp cl, 8

		jne copywindow

		inc bx

		mov cl, 0

		mov edx, 0

		mov dx, [resolutionx2]

		add esi, edx

		mov edi, esi

		mov dh, [fonts + bx]

		ror dh, 1
		inc ch
		cmp ch, 16
		jne copywindow

		mov cx, 0
		mov di, [charposvbuf]
		add di, 2
		cmp di, videobufend
		jae donewincopynow
		mov bl, [di]
		mov bh, 0
		shl bx, 4
		mov [charposvbuf], di
		mov edx, 0
		mov dx, [resolutionx2]
		shl edx, 4
		sub esi, edx
		add esi, 16
		mov edi, esi
		mov cx, [charposline]
		inc cx
		cmp cx, 80
		jae fixwindowcopy
		mov [charposline], cx
		mov cx, 0
		mov dh, [fonts + bx]

		ror dh, 1
		jmp copywindow

fixwindowcopy:
		mov cx, 0
		mov [charposline], cx
		sub dx, [winvcopydx]
		add esi, edx
		mov edi, esi
		mov dh, [fonts + bx]

		ror dh, 1
		jmp copywindow
donewincopynow:
		cmp byte [termcopyon], 1

		jne forgetresetstuff
		mov ax, [oldax]
		mov bx, [oldbx]
		mov cx, [oldcx]
		mov dx, [olddx]
		mov si, [oldsi]
		mov di, [olddi]

forgetresetstuff:

		mov byte [termcopyon], 0
		ret


charposline dw 0
charposvbuf dw 0
iconcolor dw 0
	showicon:	;;icon in si, position in (dx,cx), selected in ax, code in bx
		mov [iconselected], al
		and byte [iconselected], 1

		mov ah, 1
		call graphicsadd

	showicon2:

		mov edi, [physbaseptr]

		add dx, dx
		cmp dx, [resolutionx2]
		jb screenxgood
		mov dx, [resolutionx2]
		sub dx, 64
	screenxgood:

		cmp cx, 0

		je noscreenygoodchk
		cmp cx, [resolutiony]
		jb screenygood
		mov cx, [resolutiony]
		sub cx, 32
	screenygood:

		mov ebx, 0

		mov bx, [resolutionx2]
		add edi, ebx
		loop screenygood

	noscreenygoodchk:

		mov ebx, 0

		mov bx, dx

		add edi, ebx
		mov cx, 0

		mov ax, [si]

		add si, 2

		mov [iconcolor], ax
	writeicon:

		mov eax, [si]

		rol eax, 1

		mov cl, 0

	writeiconline:
		mov dl, 1

		and dl, al

		xor dl, [iconselected]

		mov bx, [background]

		mov [edi], bx

		cmp dl, 0

		je noiconline

		mov dx, [iconcolor]

		mov [edi], dx

	noiconline:

		add edi, 2

		rol eax, 1

		inc cl

		cmp cl, 32

		jb writeiconline

		add si, 4

		inc ch

		mov edx, 0

		mov dx, [resolutionx2]

		add edi, edx

		sub edi, 64

		cmp ch, 32

		jb writeicon

		mov eax, 0

		ret


resolutiony dw 0

resolutionx dw 0

resolutionx2 dw 0

resolutionbytes db 2

posxvesa dw 0

posyvesa dw 0

colorfont dw 0xFFFF

savefontvesa:		;;same rules as showfontvesa

	mov byte [savefonton], 1
showfontvesa:		;;position in (dx,cx), color in bx, char in al

	mov [posyvesa], cx

	mov [posxvesa], dx

	mov edi, [physbaseptr]

	mov [colorfont], bx

	mov ebx, 0

	mov bx, dx

	mov edx, ebx

	mov ebx, 0

	cmp cx, 0

	je vesaposloopdn

	mov bx, [resolutionx2]

vesaposloop:

	add edx, ebx

	sub cx, 1

	cmp cx, 0

	jne vesaposloop

vesaposloopdn:

	add edi, edx

	mov si, fonts

findfontvesa:

	mov ah, 0
	shl ax, 4
	add si, ax
	shr ax, 4
	cmp si, fontend

	jae near donefontvesa

	dec si
foundfontvesa:

	inc si
	cmp byte [savefonton], 1

	je near vesafontsaver

	mov cl, 0

	mov al, [si]

	mov dx, [resolutionx2]

	sub dx, [posxvesa]

	cmp dx, 16
	ja paintfontvesa

	shr dl, 1

	mov [charwidth], dl

paintfontvesa:
	
	mov dl, 1

	and dl, al

	cmp byte [showcursorfonton], 1

	je near nodelpaintedfont

	cmp byte [showcursorfonton], 2

	jne near noswitchcursorfonton

	cmp dl, 0

	je near nopixelset

	mov bx, [colorfont]

	mov [edi], bx

	jmp nopixelset

noswitchcursorfonton:

	xor dl, [mouseselecton]

	mov bx, [background]

	mov [edi], bx

nodelpaintedfont:

	cmp dl, 0

	je nopixelset

	mov dx, [colorfont]

	mov [edi], dx

nopixelset:

	add edi, 2

	rol al, 1

	inc cl

	cmp cl, [charwidth]

	jb paintfontvesa

	inc ch

	mov edx, 0

	mov dx, [resolutionx2]

	add edi, edx

	mov edx, 0

	mov dl, [charwidth]

	add dl, dl

	sub edi, edx

	cmp ch, 16

	jb foundfontvesa

donefontvesa:

	mov dl, 8

	mov [charwidth], dl

	mov dx, [posxvesa]

	mov bl, [charwidth]

	mov bh, 0

	add dx, bx

	mov bx, [colorfont]

	mov cx, [posyvesa]

	mov byte [savefonton], 0

	ret

charwidth db 8

vesafontsaver:
	
	mov al, 0

	mov cl, 0

vesafontsaver2:

	mov dx, [edi]

	cmp dx, [colorfont]

	je colorfontmatch

donecolormatch:
	
	add edi, 2

	rol al, 1

	inc cl

	cmp cl, 8

	jb vesafontsaver2

	mov [si], al

	inc si
	inc ch

	mov edx, 0

	mov dx, [resolutionx2]

	add edi, edx

	sub edi, 16

	cmp ch, 16

	jb vesafontsaver

	jmp donefontvesa

colorfontmatch:
	add al, 1

	jmp donecolormatch
		

switchmousepos:		;;switch were the mouse is located
		mov esi, mousecolorbuf
		mov edi, [physbaseptr]
		mov edx, 0
		mov ecx, 0
		mov dx, [lastmouseposition]
		mov cx, [lastmouseposition + 2]
		add edi, edx
		mov edx, 0
		mov dx, [resolutionx2]
		cmp cx, 0
		je noswmsy
swmsy:		add edi, edx
		loop swmsy
noswmsy:	mov eax, [esi]
		mov ebx, [esi + 4]
		mov [edi], eax
		mov [edi + 4], ebx
		mov eax, [esi + 8]
		mov ebx, [esi + 12]
		mov [edi + 8], eax
		mov [edi + 12], ebx
		add edi, edx
		add si, 16
		inc cx
		cmp cx, 16
		jbe noswmsy

		mov esi, mousecolorbuf
		mov edi, [physbaseptr]
		mov edx, 0
		mov ecx, 0
		mov dx, [mousecursorposition]
		mov cx, [mousecursorposition + 2]
		add edi, edx
		mov edx, 0
		mov dx, [resolutionx2]
		cmp cx, 0
		je noswmsy2
swmsy2:		add edi, edx
		loop swmsy2
noswmsy2:	mov eax, [edi]
		mov ebx, [edi + 4]
		mov [esi], eax
		mov [esi + 4], ebx
		mov eax, [edi + 8]
		mov ebx, [edi + 12]
		mov [esi + 8], eax
		mov [esi + 12], ebx
		add edi, edx
		add si, 16
		inc cx
		cmp cx, 16
		jbe noswmsy2
		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Here are some vars;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	showstringsi db 0,0
	mouseon db 0
	pacmsg	db "Pacman was easy to draw.",0
	pacnom  db "Om nom nom nom",0
	start	db "start",0
	gotomenu db "SollerOS",0
	winmsg	db "windows sucks",0

	boomsg db "Boo!",0

	xmsg db "X",0
	icon dw 0	;pointer to icon
	codepointer dw 0 ;pointer to code
	iconselected db 0
	
	noie:

		mov si, termwindow

		mov dx, 0

		mov cx, 0

		mov ebx, internettest

		mov [user2codepoint], ebx
		mov ebx, 0
		mov bx, internettest
		mov ax, 0

		call showwindow

		;;ret
	jmp internettest

	gotomenuboot:

		mov si, termwindow

		mov dx, 0

		mov cx, 0

		mov ebx, os
		mov [user2codepoint], ebx
		mov ebx, 0
		mov bx, os
		mov ax, 0

		call showwindow

		;;ret
	jmp os

	winblows:
		mov si, winmsg
		mov dx, 0
		mov cx, [resolutiony]

		sub cx, 32
		mov bx, 0

		mov ah, 0
		mov al, 00010001b
		call showstring

		mov si, gotomenu
		mov cx, [resolutiony]

		sub cx, 48
		mov dx, 0

		mov ah, 0
		mov al, 00010000b
		mov bx, gotomenuboot
		jmp showstring

	boo:
		mov si, boomsg
		mov dx, 100
		mov cx, 320
		mov bx, 0
		mov ax, 0
		jmp showstring

	pacmannomnom:
		mov si, pacnom
		mov dx, 130
		mov cx, 60

		mov bx, 0

		mov ax, 0

		call showstring

		ret		
	graphicstable: ;w type, w datalocation, w locationx, w locationy, w selected, w code
	times 200h dw 0
	graphicstableend:
	termwindow:	dw 640,480	;;window size

	termmsg:	db "TERMINAL",0	;;window title

mousecolorbuf: ;where the gui under the mouse is stored
times 256 dw 0

	pacmanpellet: dw 0xFFE0
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

	ghostie	dw 0xF00F

		dd	00000000000000000000000000000000b	;Icon 32x32
		dd	00000000000000000000000000000000b

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


	pacman	dw 0xFFE0

		dd	00000000000000000000000000000000b	;Icon 32x32
		dd	00000000000000000000000000000000b
		dd	00000000000000000000000000000000b
		dd	00000000000000000000000000000000b
		dd	00000000000000000000000000000000b

		dd	00000000000011111111000000000000b
		dd	00000000000011111111000000000000b ;because I can
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

interneticon: 	dw 0x000F
		dd	00000001111111111111111110000000b
		dd	00000011111111111111111111000000b
		dd	00000111100000000000000111100000b
		dd	00001111000000000000000011110000b
		dd	00001111000000111100000011110000b
		dd	00011110000111111111100001111000b
		dd	00111111001111100111110000111100b
		dd	01111011111111000011111000011110b
		dd	01111000111110000001111100011110b
		dd	11110000111111000001111100001111b
		dd	11110001111111110000111110001111b
		dd	11100011111000111100011111000111b
		dd	11100011111111111111111111000111b
		dd	11100011111111111111111111000111b
		dd	11100011111000000001110000000111b
		dd	11110001111100000001111100001111b
		dd	11110000111110000000111111001111b
		dd	01111000111110000001111111111110b
		dd	01111000011111000011111000111110b
		dd	00111100001111100111110000111100b
		dd	00011110000111111111100001111000b
		dd	00001111000000111100000011110000b
		dd	00001111000000000000000011110000b
		dd	00000111100000000000000111100000b
		dd	00000011111111111111111111000000b
		dd	00000001111111111111111110000000b
		dd	00000000000000000000000000000000b
		dd	01110001100111110011111101111110b
		dd	01111001101100011000110001100000b
		dd	01101101101101011000110001111100b
		dd	01100111101100011000110001100000b
		dd	01100011100111110011111101111110b


wordicon: 	dw 0xFFFF
		dd	00000000000000000000000000000000b
		dd	01111110000000000000000001111110b
		dd	01111110000000000000000001111110b
		dd	00111100000000000000000000111100b
		dd	00111100000000000000000000111100b
		dd	00111110000000000000000001111100b
		dd	00111110000000000000000001111100b
		dd	00011110000000000000000001111000b
		dd	00011110000000000000000001111000b
		dd	00011111000000000000000011111000b
		dd	00011111000000000000000011111000b
		dd	00001111000001111110000011110000b
		dd	00001111000001111110000011110000b
		dd	00001111100000111100000111110000b
		dd	00001111100000111100000111110000b
		dd	00000111100001111110000111100000b
		dd	00000111100001111110000111100000b
		dd	00000111110011111111001111100000b
		dd	00000111110011111111001111100000b
		dd	00000011110111100111101111000000b
		dd	00000011110111100111101111000000b
		dd	00000011111111000011111111000000b
		dd	00000011111111000011111111000000b
		dd	00000001111110000001111110000000b
		dd	00000001111110000001111110000000b
		dd	00000000000000000000000000000000b
		dd	11000011001111100111111001111110b
		dd	11000011011000110110001101100011b
		dd	11011011011010110111111001101011b
		dd	11011011011000110110011001100011b
		dd	01111110001111100110001101111110b
		dd	00000000000000000000000000000000b
