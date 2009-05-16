guiclear:
	mov edi, [physbaseptr]
	mov dx, [resolutionx]
	mov cx, [resolutiony]
	mov ax, [background]
guiclearloop:
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

gui:	;Let's see what I can do, I am going to try to make this as freestanding as possible
	mov eax, 0
	mov ebx, 0
	mov ecx, 0
	mov edx, 0
	mov edi, [physbaseptr]
	mov dx, [resolutionx]
	mov cx, [resolutiony]
	mov bx, [background]
guiclearloop2:
	mov [edi], bx
	add edi, 2
	dec dx
	cmp dx, 0
	jne near guiclearloop2
	dec cx
	mov dx, [resolutionx]
	cmp cx, 0
	jne near guiclearloop2
	mov byte [guion], 1
	mov byte [mouseselecton], 0
	mov eax, 0
	mov ebx, 0
	mov ecx, 0
	mov edx, 0
	
	mov esi, pacmsg
	mov ax, 0
	mov ebx, 0
	mov cx, 144
	mov dx, 4
	call showstring
	
	mov esi, interneticon
	mov ax, 0
	mov ebx, noie
	mov cx, 24
	mov dx, 4
	call showicon
	
	mov esi, wordicon
	mov ax, 0
	mov ebx, 0
	mov cx, 24
	mov dx, 48
	call showicon
	
	mov esi, pacmanpellet
	mov ax, 0
	mov ebx, 0
	mov cx, 64
	mov dx, 4
	call showicon
	
	mov esi, pacman
	mov ax, 0
	mov ebx, pacmannomnom
	mov cx, 64
	mov dx, 48
	call showicon
	
	mov esi, ghostie
	mov ax, 0
	mov ebx, boo
	mov cx, 108
	mov dx, 4
	call showicon

	mov esi, start
	mov cx, [resolutiony]
	sub cx, 16
	mov dx, 2
	mov ah, 0
	mov al, 00010000b
	mov ebx, winblows
	call showstring
	
	call cursorgui
guistart:
	call guistartin
	mov byte [copygui], 0
	jmp guistart
	
;guicopy:	;;for double buffering
;	mov byte [copygui], 1
;	mov edi, [offscreenmemoffset]
;	mov edx, 0
;	mov ecx, 0
;	mov dx, [mousecursorposition]
;	mov cx, [mousecursorposition + 2]
;	add edi, edx
;	mov dx, [resolutionx2]
;	inc cx
;guicp2:
;	add edi, edx
;	dec cx
;	cmp cx, 0
;	jne guicp2
;	sub edi, edx
;	mov [cursorloc], edi
;	mov ebx, cursorbmp
;	mov cx, [resolutiony]
;	rol ecx, 16
;	mov cx, [resolutionx]
;	mov esi, [physbaseptr]
;	mov edi, [offscreenmemoffset]
;guicp1:
;	mov ax, [esi]
;	mov [edi], ax
;	add esi, 2
;	add edi, 2
;	cmp edi, [cursorloc]
;	je copycursor
;dncopycursor:
;	dec cx
;	cmp cx, 0
;	jne guicp1
;	mov cx, [resolutionx]
;	rol ecx, 16
;	dec cx
;	cmp cx, 0
;	rol ecx, 16
;	jne guicp1
;	mov byte [copygui], 0
;	ret
;copycursor:
;	cmp ebx, cursorbmpend
;	jae dncopycursor
;	mov dx, [resolutionx2]
;	add edi, edx
;	mov [cursorloc], edi
;	sub edi, edx
;	dec ebx
;	sub edi, 2
;	sub esi, 2
;	mov dx, 9
;curscplp:
;	inc ebx
;	add esi, 2
;	add edi, 2
;	mov ax, [esi]
;	mov [edi], ax
;	mov al, [ebx]
;	cmp al, 0
;	je curscplp2
;	mov word [edi], 1110011110011100b
;curscplp2:
;	dec cx
;	cmp cx, 0
;	je dncopycursor
;	dec dx
;	cmp dx, 0
;	jne curscplp
;	jmp dncopycursor
	
	
;cursorloc: dd 0
		
;nextimage:	
;	call guiclear
;	mov esi, [bmpend]
;	mov eax, 0
;	mov ebx, 0
;	mov ecx, 0
;	mov edx, 0
;	call showbmp
;	jmp guistartin
		
copygui db 0
graphicsset db 0
graphicspos db 0,0
showcursorfonton db 0
savefonton db 0
mouseselecton db 0
guion db 0

		
clearmousecursor:
		mov esi, background
		mov edi, [physbaseptr]
		mov edx, 0
		mov ecx, 0
		mov dx, [lastmouseposition]
		mov cx, [lastmouseposition + 2]
		add edi, edx
		mov edx, 0
		mov dx, [resolutionx2]
		cmp cx, 0
		je noyclr
yclr:	add edi, edx
		dec cx
		cmp cx, 0
		jne yclr
noyclr:	mov ax, [esi]
		rol eax, 16
		mov ax, [esi]
		mov [edi], eax
		mov [edi + 4], eax
		mov [edi + 8], eax
		mov [edi + 12], eax
		add edi, edx
		inc cx
		cmp cx, 16
		jb noyclr
		ret

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
		dec cx
		cmp cx, 0
		jne swmsy
noswmsy:	mov eax, [esi]
		mov ebx, [esi + 4]
		mov [edi], eax
		mov [edi + 4], ebx
		mov eax, [esi + 8]
		mov ebx, [esi + 12]
		mov [edi + 8], eax
		mov [edi + 12], ebx
		add edi, edx
		add esi, 16
		cmp esi, mcolorend
		jb noswmsy
		
switchmousepos2:
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
		dec cx
		cmp cx, 0
		jne swmsy2
noswmsy2:	mov eax, [edi]
		mov ebx, [edi + 4]
		mov [esi], eax
		mov [esi + 4], ebx
		mov eax, [edi + 8]
		mov ebx, [edi + 12]
		mov [esi + 8], eax
		mov [esi + 12], ebx
		add edi, edx
		add esi, 16
		cmp esi, mcolorend
		jb noswmsy2
		ret

pbutton db 0
pLBUTTON db 0
pRBUTTON db 0
dragging dw 0,0
lastpos dw 0,0,0,0
colorbuf dw 0,0
	
	clickicon:
		mov al, 1
		mov [pbutton], al
		mov al, [pLBUTTON]
		and al, [LBUTTON]
		mov ah, [pRBUTTON]
		and ah, [RBUTTON]
		or al, ah
		cmp al, 0
		je nodragclick
		cmp dword [dragging], 1
		jae dragclick
		mov dword [dragging], 1
		jmp dragclick
	nodragclick:
		mov dword [dragging], 0
		mov al, [LBUTTON]
		mov [pLBUTTON], al
		mov al, [RBUTTON]
		mov [pRBUTTON], al
	dragclick:
		mov ax, 0
		mov esi, graphicstable
		mov dword [codepointer], 0
	clicon2:
		mov edx, 0
		mov ecx, 0
		cmp word [esi], 1
		je near iconselect
		cmp word [esi], 2
		je near textselected
		cmp word [esi], 3
		je near windowselect
		jmp nexticonsel
	iconselect:
		mov dx, [esi + 6]
		mov ax, dx
		mov cx, [esi + 8]
		mov bx, cx
		add bx, 32
		add ax, dx
		cmp dword [dragging], 1
		je dragicon
		cmp dword [dragging], 0
		je nodragiconcheck
		cmp dword [dragging], esi
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
		mov ax, [esi + 10]
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
		mov ax, [esi + 10]
		and al, 00010000b
		cmp al, 00010000b
		je nodragicon
		mov [dragging], esi
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
		or word [esi + 10], 1
		mov ebx, [esi + 12]
		mov ax, [esi + 10]
		mov esi, [esi + 2]
		mov dword [codepointer], 0
		call showicon
		jmp doneiconsel
	unselecticon:
		and word [esi + 10], 0xFFFE
		mov ebx, [esi + 12]
		mov ax, [esi + 10]
		mov esi, [esi + 2]
		mov [codepointer], ebx
		call showicon
		jmp doneiconsel
	textselected:
		mov ebx, [esi + 2]
		mov dx, [esi + 6]
		mov ax, dx
		mov cx, [esi + 8]
	lengthtesttext:
		cmp byte [ebx], 0
		je donetesttextlength
		inc ebx
		add ax, 16
		jmp lengthtesttext
	donetesttextlength:
		mov bx, cx
		add bx, 15
		cmp dword [dragging], 1
		je dragtext
		cmp dword [dragging], 0
		je nodragtextcheck
		cmp dword [dragging], esi
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
		mov ax, [esi + 10]
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
		mov ax, [esi + 10]
		and al, 00010000b
		cmp ax, 00010000b
		je near nodragtext
		mov [dragging], esi
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
		or word [esi + 10], 1
		mov ebx, [esi + 12]
		mov [codepointer], ebx
		mov ax, [esi + 10]
		mov esi, [esi + 2]
		call showstring
		jmp doneiconsel
	unselecttext:
		and word [esi + 10], 0xFFFE
		mov ebx, [esi + 12]
		mov ax, [esi + 10]
		mov esi, [esi + 2]
		mov dword [codepointer], 0
		call showstring
		jmp doneiconsel
windowselect:
		mov edi, [esi + 2]
		mov dx, [esi + 6]
		mov ax, dx
		mov cx, [esi + 8]
		mov bx, cx
		add bx, 16
		cmp dword [dragging], 1
		je dragwin
		cmp dword [dragging], 0
		je nodragwincheck
		cmp dword [dragging], esi
		jne near nexticonsel
		jmp dragwin
	nodragwincheck:
		cmp [mousecursorposition], ax
		jb near nexticonsel
		add ax, [edi]
		add ax, [edi]
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
		add ax, [edi]
		add ax, [edi]
		cmp [lastmouseposition], ax
		ja near nexticonsel
		cmp [lastmouseposition + 2], cx
		jb near nexticonsel
		cmp [lastmouseposition + 2], bx
		ja near nexticonsel
		mov [dragging], esi
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
		mov ebx, [esi + 12]
		mov ax, [esi + 10]
		mov esi, [esi + 2]
		call showwindow
		jmp doneiconsel
	killwin:
		mov word [esi], 0
		mov dword [user2codepoint], 0
		mov byte [termguion], 0
		call guiclear
		call reloadallgraphics
		jmp guistart
		jmp doneiconsel2
	nexticonsel:
		and word [esi + 10], 0xFFFE
		add esi, 16
		cmp esi, graphicstableend
		jae doneiconsel
		jmp clicon2
	doneiconsel:
		cmp dword [dragging], 1
		jae doneiconsel2
		cmp dword [codepointer], 0
		je doneiconsel2
		mov ebx, [codepointer]
		call ebx 
		ret
	doneiconsel2:
		mov al, [LBUTTON]
		mov [pLBUTTON], al
		mov al, [RBUTTON]
		mov [pRBUTTON], al
		cmp word [dragging], 1
		jbe near noreloadgraphicsclick
call clearmousecursor
call reloadallgraphics
noreloadgraphicsclick:
		mov ecx, 0
		mov edx, 0
		mov ah, 0
		mov al, 254
		mov dx, [mousecursorposition]
		mov cx, [mousecursorposition + 2]
		mov bx, 0011100011100111b
		mov byte [showcursorfonton], 1
		call showfontvesa
		mov byte [showcursorfonton], 0
		ret
lastdrag dw 0,0
grpctblpos dw 0,0

reloadallgraphics:
		mov edi, graphicstable
reloadgraphicsloop:
		mov esi, [edi + 2]
		mov dx, [edi + 6]
		mov cx, [edi + 8]
		mov ax, [edi]
		mov bx, [edi + 10]
		mov [grpctblpos], edi
		cmp edi, [dragging]
		je loadedgraphic
		cmp ax, 1
		je near icongraphic
		cmp ax, 2
		je near stringgraphic
		cmp ax, 3
		je near windowgraphic
loadedgraphic:  mov edi, [grpctblpos]
		add edi, 16
		cmp edi, graphicstableend
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
		mov edi, [dragging]
		cmp edi, graphicstable
		jb notcorrectdrag
		mov ax, [edi]
		mov esi, [edi + 2]
		mov dx, [edi + 6]
		mov cx, [edi + 8]
		mov bx, [edi + 10]
		cmp ax, 1
		jne noticondragging
		and bl, 1
		mov [iconselected], bl
		call showicon2
notcorrectdrag:
		ret

	noticondragging:
		cmp ax, 2
		jne notcorrectdrag
		and bl, 1
		mov [mouseselecton], bl
		call showstring2
		jmp notcorrectdrag

grphbuf times 16 db 0
	graphicsadd:
		mov edi, graphicstable
	shwgrph1:
		cmp dword [edi + 2], esi
		je showgraphicsreplace2
		add edi, 16
		cmp edi, graphicstableend
		jae near showgraphicsnew
		jmp shwgrph1
	showgraphicsreplace2:
		mov [grphbuf + 2], esi
		mov [grphbuf + 6], dx
		mov [grphbuf + 8], cx
		mov [grphbuf + 12], ebx
		mov bh, 0
		mov bl, ah
		mov ah, 0
		mov [grphbuf + 10], ax	
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
		mov [lastpos], edi
		mov [lastpos + 4], esi
		mov esi, [edi + 2]
		mov bx, [edi + 12]
		mov dx, [edi + 6]
		mov cx, [edi + 8]
		mov ax, [esi]
		mov [colorbuf], ax
		mov ax, [background]
		mov [esi], ax
		mov ebx, [edi + 12]
		mov ax, [edi + 10]
		and al, 1
		mov [iconselected], al
		mov ax, [edi + 10]
		call showicon2
		mov edi, [lastpos]
		mov esi, [edi + 2]
		mov ax, [colorbuf]
		mov [esi], ax
		mov esi, [lastpos + 4]
		mov dx, [grphbuf + 6]
		mov cx, [grphbuf + 8]
		mov bx, [grphbuf]
		mov ax, [grphbuf + 10]
		mov ah, bl
		mov ebx, [grphbuf + 12]
		jmp showgraphicsreplace
	replacestring:
		mov [lastpos], edi
		mov [lastpos + 4], esi
		mov ebx, [edi + 12]
		mov esi, [edi + 2]
		mov dx, [edi + 6]
		mov cx, [edi + 8]
		mov ax, [colorfont2]
		mov [colorbuf], ax
		mov ax, [background]
		mov [colorfont2], ax		
		mov ebx, [edi + 12]
		mov ax, [edi + 10]
		and al, 1
		mov [mouseselecton], al
		mov ax, [edi + 10]
		call showstring2
		mov ax, [colorbuf]
		mov [colorfont2], ax
		mov edi, [lastpos]
		mov esi, [edi + 2]
		mov dx, [grphbuf + 6]
		mov cx, [grphbuf + 8]
		mov bx, [grphbuf]
		mov ax, [grphbuf + 10]
		mov ah, bl
		mov ebx, [grphbuf + 12]
		jmp showgraphicsreplace
	replacewindow:
		mov [lastpos], edi
		mov [lastpos + 4], esi
		mov esi, [edi + 2]
		mov edi, [windowbufloc]
		mov edx, 0
		mov dx, [resolutionx2]
		shl edx, 4
		sub edi, edx
		mov edx, 0
		mov dx, [esi]
		add dx, [esi]
		mov cx, [esi + 2]
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
		sub dx, [esi]
		sub dx, [esi]
		add edi, edx
		mov dx, [esi]
		add dx, [esi]
		cmp cx, 0
		jne clearwindow
		mov byte [termcopyon], 0
		mov edi, [lastpos]
		mov esi, [grphbuf + 2]
		mov dx, [grphbuf + 6]
		mov cx, [grphbuf + 8]
		mov bx, [grphbuf]
		mov ax, [grphbuf + 10]
		mov ah, bl
		mov ebx, [grphbuf + 12]
		jmp showgraphicsreplace
	showgraphicsreplace:
		mov [edi + 2], esi
		mov [edi + 6], dx
		mov [edi + 8], cx
		mov [edi + 12], ebx
		mov bh, 0
		mov bl, ah
		mov ah, 0
		mov [edi + 10], ax
		mov [edi], bx
		mov ebx, [edi + 12]
		mov ax, [edi + 10]
		ret
	showgraphicsnew:
		mov edi, graphicstable
	shwgrph2:
		cmp word [edi], 0
		je showgraphicsreplace
		add edi, 16
		cmp edi, graphicstableend
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
		mov al, [esi]
		cmp al, 0
		je doneshowstring
		inc esi
		cmp al, 255
		je showstring2
		mov [showstringesi], esi
		mov bx, [colorfont2]
		call showfontvesa
		cmp al, 13
		je noproceedshst
		cmp al, 10
		je noproceedshst
		add dx, 8
		noproceedshst
		mov esi, [showstringesi]
		jmp showstring2
	doneshowstring:
		mov byte [mouseselecton], 0
		ret

colorfont2 dw 0xFFFF
colorcache db 0
winvcopystx dw 0
winvcopysty dw 0
winvcopydx dw 0
winvcopycx dw 0
windowcolor dw 0xFFFF,0x0
windowbufloc: dw 0,0

	showwindow:	;;windowstuff in si, position in (dx, cx), nothing in ax, code in bx
		mov byte [termguion], 1
		add cx, 16
		mov [winvcopystx], dx
		mov [winvcopysty], cx
		mov dx, [esi]
		mov cx, [esi + 2]
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
		mov dx, [esi]
		mov cx, [esi + 2]
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
		add esi, 4
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
		mov esi, videobuf2
		mov [charposvbuf], esi
		mov bl, [esi + 1]
		mov [colorcache], bl
		mov bl, [esi]
		mov bh, 0
		shl bx, 4
		mov dh, [fonts + bx]
		ror dh, 1
		mov esi, edi
	copywindow:
		mov dl, 1
		rol dh, 1
		and dl, dh
		cmp byte [colorcache], 0x10
		jae switchwincolors
		mov ax, [windowcolor + 2]
		mov [edi], ax
		cmp dl, 0
		je nowritewin
		mov ax, [windowcolor]
		mov [edi], ax
		jmp nowritewin
	switchwincolors:
		mov ax, [windowcolor]
		mov [edi], ax
		cmp dl, 0
		je nowritewin
		mov ax, [windowcolor + 2]
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
		mov edi, [charposvbuf]
		add edi, 2
		cmp edi, videobufend
		jae donewincopynow
		mov bl, [edi + 1]
		mov [colorcache], bl
		mov bl, [edi]
		mov bh, 0
		shl bx, 4
		mov [charposvbuf], edi
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
		call switchtermcursor
		cmp byte [termcopyon], 1
		jne forgetresetstuff
		popa
forgetresetstuff:
		mov byte [termcopyon], 0
		ret

charposline dw 0
charposvbuf dw 0,0
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
		mov ax, [esi]
		add esi, 2
		mov [iconcolor], ax
	writeicon:
		mov eax, [esi]
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
		add esi, 4
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
	cmp al, 255
	jne nostopshowfont
	ret
nostopshowfont:
	mov [posyvesa], cx
	cmp al, 10
	je near goodvesafontx
	cmp al, 13
	je near goodvesafontx
	mov ecx, 0
	mov cx, [resolutionx2]
	sub cx, 16
	cmp dx, cx
	jbe goodvesafontx
	mov dx, 0
	mov cx, [posyvesa]
	add cx, 16
	mov [posyvesa], cx
goodvesafontx:
	mov cx, [posyvesa]
	mov [posxvesa], dx
	mov edi, [physbaseptr]
	mov [colorfont], bx
	mov ebx, 0
	mov bl, al
	mov eax, 0
	mov al, bl
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
	mov esi, fonts
findfontvesa:
	mov ah, 0
	cmp al, 10
	je near nwlinevesa
	cmp al, 13
	je near cretvesa
	shl eax, 4
	add esi, eax
	shr eax, 4
	cmp esi, fontend
	jae near donefontvesa
	dec esi
foundfontvesa:
	inc esi
	cmp byte [savefonton], 1
	je near vesafontsaver
	mov cl, 0
	mov al, [esi]
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
nwlinevesa:
	mov cx, [posyvesa]
	add cx, 16
	mov [posyvesa], cx
	jmp donefontvesa
cretvesa:
	mov dx, [posxvesa]
	mov dx, 0
	mov [posxvesa], dx
	jmp donefontvesa
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
	mov [esi], al
	inc esi
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
	
showbmp:
	mov ax, [esi]
	cmp ax, "BM"
	jne near endedbmp
	mov edi, [physbaseptr]
	mov ax, dx
	mov bx, cx
	mov ecx, 0
	mov edx, 0
	mov cx, bx
	mov dx, ax
	add edi, edx
	add edi, edx
	mov edx, 0
	mov dx, [resolutionx2]
	inc ecx
	add ecx, [esi + 22]
bmplocloop:
	add edi, edx
	loop bmplocloop
	sub edi, edx
	mov edx, [esi + 18]
	mov ecx, [esi + 22]
	mov eax, [esi + 10]
	mov ebx, [esi + 2]
	add ebx, esi
	mov [bmpend], ebx
	mov ebx, edx
	add esi, eax
ldxbmp:
	mov ax, [esi]
	mov [edi], ax
	add edi, 2
	add esi, 2
	cmp esi, [bmpend]
	ja endedbmp
	dec edx
	cmp edx, 0
	ja ldxbmp
	mov edx, 0
	mov dx, [resolutionx2]
	sub edi, ebx
	sub edi, ebx
	sub edi, edx
	dec ecx
	mov edx, ebx
	cmp ecx, 0
	ja ldxbmp
endedbmp:
	call switchmousepos2
	ret
	
	bmpend dd 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Here are some vars;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	showstringesi dw 0,0
	mouseon db 0
	start	db "start",0
	gotomenu db "SollerOS",0
	boomsg db "Boo!",0
	pacmsg	db "Pacman was easy to draw.",0
	pacnom  db "Om nom nom nom",0
	winmsg	db "windows sucks",0
	xmsg db "X",0
	icon dw 0	;pointer to icon
	codepointer dw 0,0 ;pointer to code
	iconselected db 0
	
	boo:
		mov esi, boomsg
		mov dx, 100
		mov cx, 320
		mov ebx, 0
		mov ax, 0
		jmp showstring

	pacmannomnom:
		mov esi, pacnom
		mov dx, 130
		mov cx, 60
		mov ebx, 0
		mov ax, 0
		jmp showstring	
	
	noie:
		mov esi, termwindow
		mov dx, 0
		mov cx, 0
		mov ebx, os
;;		mov ebx, internettest
		mov [user2codepoint], ebx
		mov ax, 0
		call showwindow
;;		jmp internettest
		jmp os
		ret

	gotomenuboot:
		mov esi, termwindow
		mov dx, 0
		mov cx, 0
		mov ebx, os
		mov [user2codepoint], ebx
		mov ax, 0
		call showwindow
		jmp os
		ret

	winblows:
		mov esi, winmsg
		mov dx, 0
		mov cx, [resolutiony]
		sub cx, 32
		mov ebx, 0
		mov ah, 0
		mov al, 00010001b
		call showstring
		mov esi, gotomenu
		mov cx, [resolutiony]
		sub cx, 48
		mov dx, 0
		mov ah, 0
		mov al, 00010000b
		mov ebx, gotomenuboot
		jmp showstring

	termwindow:	dw 640,480	;;window size
	termmsg:	db "Terminal",0	;;window title
	
interneticon: 	incbin 'source/precompiled/interneticon.pak'
wordicon: 	incbin 'source/precompiled/wordicon.pak'
pacmanpellet: incbin 'source/precompiled/pacmanpellet.pak'
ghostie	incbin 'source/precompiled/ghostie.pak'
pacman	incbin 'source/precompiled/pacman.pak'
