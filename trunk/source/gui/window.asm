winvcopystx dw 0
winvcopysty dw 0
winvcopydx dw 0
winvcopycx dw 0
windowcolor dw 0xFFFF,0
windowbufloc: dd 0
windowvideobuf dd 0
windowvideobuf2 dd 0
windowinfobuf dd 0
termcol dw 0
wincopyendpos dd 0

	showwindow:	;windowstuff in esi, position in (dx, cx), nothing in ax, code in ebx
		mov byte [termguion], 1
		add cx, 16
		mov [winvcopystx], dx
		mov [winvcopysty], cx
		mov [windowinfobuf], esi
		mov dx, [esi]
		mov cx, [esi + 2]
		xor eax, eax
		xor ebx, ebx
		mov ax, dx
		mov bx, cx
		shr ax, 3
		shr bx, 4
		mov [termcol], ax
		mov [charxy], al
		mov [charxy + 1], bl
		mov edi, [esi + 4]
		mov [windowcolor], edi
		mov edi, [esi + 12]
		mov [windowvideobuf2], edi
		mov edi, [esi + 8]
		mov [windowvideobuf], edi
		cmp ebx, 0
		je near donewincopynow	;AAAAAAAAA!!!!!
	findendposwin:
		add edi, eax
		add edi, eax
		dec ebx
		cmp ebx, 0
		ja findendposwin
		mov [wincopyendpos], edi
		xor edi, edi
		xor ax, ax
		xor bx, bx
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
		xor edx, edx
		mov dx, [resolutionx2]
		shl edx, 4
		sub edi, edx
		cmp byte [termcopyon], 0
		jne nocleartitlebarpos
		mov edi, [physbaseptr]
		xor edx, edx
		mov dx, [winvcopystx]
		add edi, edx
		mov cx, [winvcopysty]
		sub cx, 16
		cmp cx, 0
		je nocleartitlebarpos
	cleartitlebarpos:
		xor edx, edx
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
		xor edx, edx
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
		xor ax, ax
		add esi, 16
		mov dx, [winvcopystx]
		mov cx, [winvcopysty]
		sub cx, 16
		mov bx, [windowcolor]
		mov byte [mouseselecton], 1
		call showstring2
		mov al, "X"
		xor ah, ah
		mov bx, [windowcolor]
		mov dx, [winvcopystx]
		mov cx, [winvcopysty]
		sub cx, 16
		sub dx, 20
		add dx, [winvcopydx]
		mov byte [mouseselecton], 1
		call showfontvesa
	winvcpst:
		cmp byte [windrag], 1
		je near forgetresetstuff
		mov edi, [windowbufloc]
		jmp windowvideocopyset

	windowvideocopy:
		mov esi, [windowinfobuf]
		mov dx, [esi]
		mov cx, [esi + 2]
		mov edi, [esi + 4]
		mov [windowcolor], edi
		mov edi, [esi + 8]
		mov ebx, [esi + 12]
		mov [windowvideobuf], edi
		mov [windowvideobuf2], ebx
		xor eax, eax
		xor ebx, ebx
		mov ax, dx
		mov bx, cx
		shr ax, 3
		shr bx, 4
		mov [termcol], ax
		mov [charxy], al
		mov [charxy + 1], bl
		mov edi, [windowbufloc]
		cmp edi, [physbaseptr]
		jae near windowvideocopyset
		xor ecx, ecx
		xor edx, edx
		mov dx, [winvcopystx]
		mov cx, [winvcopysty]
		mov edi, [physbaseptr]
		add edi, edx
		cmp ecx, 0
		je windowvideocopyset
	yrescopylp:
		xor eax, eax
		mov ax, [resolutionx2]
		mul ecx
		add edi, eax
		mov [windowbufloc], edi
	windowvideocopyset:
		xor cx, cx
		dec cx
		mov [charposline], cx
		mov esi, edi
		sub esi, 16
		xor edx, edx
		mov dx, [resolutionx2]
		shl edx, 4
		add esi, edx
		mov edi, [windowvideobuf]
		sub edi, 2
		mov [charposvbuf], edi
		jmp nextcharwin
	win.write:	;adjusted this to use alpha
				;5R, 6G, 5B
%ifdef gui.alphablending
		push esi
		push bx
		push cx
		push dx
%ifdef gui.background
		mov esi, edi
		sub esi, [physbaseptr]
		add esi, [backgroundimage]
		cmp dword [backgroundimage], 0
		jne .red
%endif
		mov esi, background
	.red:
		mov cx, [esi]
		shr cx, 11
		mov bx, ax
		shr bx, 11
		add cx, bx
		add cx, bx
		add cx, bx
		shr cx, 2
		shl cx, 11
		mov dx, cx
	.green:
		mov cx, [esi]
		shl cx, 5
		shr cx, 10
		mov bx, ax
		shl bx, 5
		shr bx, 10
		add cx, bx
		add cx, bx
		add cx, bx
		shr cx, 2
		shl cx, 5
		add dx, cx
	.blue:
		mov cx, [esi]
		shl cx, 11
		shr cx, 11
		mov bx, ax
		shl bx, 11
		shr bx, 11
		add cx, bx
		add cx, bx
		add cx, bx
		shr cx, 2
		add dx, cx
		mov [edi], dx
		pop dx
		pop cx
		pop bx
		pop esi
%else
		mov [edi], ax
%endif
		ret
	copywindow:
		mov dl, 1
		rol dh, 1
		and dl, dh
		cmp byte [colorcache], 0x10
		jae switchwincolors
		mov ax, [windowcolor + 2]
		call win.write
		cmp dl, 0
		je nowritewin
		mov ax, [windowcolor]
		call win.write
		jmp nowritewin
	switchwincolors:
		mov ax, [windowcolor]
		call win.write
		cmp dl, 0
		je nowritewin
		mov ax, [windowcolor + 2]
		call win.write
	nowritewin:
		add edi, 2
		inc cl
		cmp cl, 8
		jne copywindow
		inc bx
		xor cl, cl
		xor edx, edx
		mov dx, [resolutionx2]
		add esi, edx
		mov edi, esi
		mov dh, [fonts + bx]
		ror dh, 1
		inc ch
		cmp ch, 16
		jne copywindow
	nextcharwin:
		xor cx, cx
		mov edi, [charposvbuf]
		add edi, 2
		cmp edi, [wincopyendpos]
		jae near donewincopynow
		mov bh, [edi + 1]
		cmp bh, 0
		jne nofixcolorwin
		mov bh, 7
		mov [edi + 1], bh
	nofixcolorwin:
		mov [colorcache], bh
		mov bl, [edi]
		mov [charposvbuf], edi
		cmp dword [windowvideobuf2], 0
		je noskipcharcopy
		sub edi, [windowvideobuf]
		add edi, [windowvideobuf2]
		mov ah, [edi + 1]
		mov al, [edi]
		cmp ax, bx
		jne noskipcharcopy
	skipcharcopy:
		add esi, 16
		mov cx, [charposline]
		inc cx
		mov [charposline], cx
		cmp cx, [termcol]
		jb nextcharwin
		xor cx, cx
		mov [charposline], cx
		xor edx, edx
		mov dx, [resolutionx2]
		shl edx, 4
		sub dx, [winvcopydx]
		add esi, edx
		jmp nextcharwin
	noskipcharcopy:
		mov [edi], bl
		mov [edi + 1], bh
		mov edi, [charposvbuf]
		xor bh, bh
		shl bx, 4
		xor edx, edx
		mov dx, [resolutionx2]
		shl edx, 4
		sub esi, edx
		add esi, 16
		mov edi, esi
		mov cx, [charposline]
		inc cx
		cmp cx, [termcol]
		jae fixwindowcopy
		mov [charposline], cx
		xor cx, cx
		mov dh, [fonts + bx]
		ror dh, 1
		jmp copywindow
fixwindowcopy:
		xor cx, cx
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
		call switchtermcursor
		popa
forgetresetstuff:
		mov byte [termcopyon], 0
		ret
		
charposline dw 0
charposvbuf dw 0,0