guiboot:	;Let's see what I can do, I am going to try to make this as freestanding as possible
	xor eax, eax
	xor ebx, ebx
	xor ecx, ecx
	xor edx, edx
	call guisetup
guiloop:
	call cursorgui
guistart:
	call getkey
	mov byte [copygui], 0
	jmp guistart

%include "source/gui/bmp.asm"
%include "source/gui/circle.asm"
%include "source/gui/cursor.asm"
%include "source/gui/icon.asm"
%include "source/gui/line.asm"
%include "source/gui/refresh.asm"
%include "source/gui/startup.asm"
%include "source/gui/text.asm"
%include "source/gui/window.asm"
				
copygui db 0
graphicsset db 0
graphicspos db 0,0
showcursorfonton db 0
savefonton db 0
mouseselecton db 0

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
		xor ax, ax
		mov esi, graphicstable
		mov dword [codepointer], 0
	clicon2:
		xor edx, edx
		xor ecx, ecx
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
		cmp byte [windrag], 1
		ja .nochangewindrag
		inc byte [windrag]
	.nochangewindrag:
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
		mov byte [termguion], 0
		call guiclear
		call reloadallgraphics
		call switchmousepos2 ;Copy what is now under the mouse
		jmp guistart
	nexticonsel:
		and word [esi + 10], 0xFFFE
		add esi, 16
		cmp esi, graphicstableend
		jae doneiconsel
		jmp clicon2
	doneiconsel:
		cmp dword [dragging], 1
		jae doneiconsel2
		xor al, al
		mov [windrag], al
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
		cmp dword [dragging], 1
		jbe near noreloadgraphicsclick
		call switchmousepos2
		cmp byte [windrag], 1
		jae noclearcursorcl
		call clearmousecursor
noclearcursorcl:
		call reloadallgraphics
noreloadgraphicsclick:
		xor ah, ah
		xor ecx, ecx
		xor edx, edx
		mov al, 254
		mov dx, [mousecursorposition]
		mov cx, [mousecursorposition + 2]
		mov bx, 0011100011100111b
		mov byte [showcursorfonton], 1
		call showfontvesa
		mov byte [showcursorfonton], 0
		ret
windrag db 0
lastdrag dw 0,0
grpctblpos dw 0,0



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
		xor bh, bh
		mov bl, ah
		xor ah, ah
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
		xor edx, edx
		mov dx, [resolutionx2]
		shl edx, 4
		sub edi, edx
		xor edx, edx
		mov dx, [esi]
		add dx, [esi]
		mov cx, [esi + 2]
		add cx, 16
		mov ax, [background]
		cmp byte [windrag], 1
		jbe clearwindow
		sub cx, [esi + 2]
	clearwindow:
		%ifdef gui.background
			cmp dword [backgroundimage], 0
			je .noback
			push esi
			mov esi, [backgroundimage]
			sub edi, [physbaseptr]
			add esi, edi
			add edi, [physbaseptr]
			mov ax, [esi]
			pop esi
		.noback:
		%endif
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
	endwindowclear:
		mov byte [termcopyon], 0
		mov edi, [lastpos]
		mov esi, [grphbuf + 2]
		mov dx, [grphbuf + 6]
		mov cx, [grphbuf + 8]
		mov bx, [grphbuf]
		mov ax, [grphbuf + 10]
		mov ah, bl
		mov ebx, [grphbuf + 12]
	showgraphicsreplace:
		mov [edi + 2], esi
		mov [edi + 6], dx
		mov [edi + 8], cx
		mov [edi + 12], ebx
		xor bh, bh
		mov bl, ah
		xor ah, ah
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
	
putpixel: ;color in si, point is (dx,cx)
		;destroys edi, ebx, eax
	push ax
	push bx
	xor eax, eax
	xor ebx, ebx
	xor edi, edi
	mov bx, [resolutiony]
	mov ax, [resolutionx]
	cmp dx, ax
	ja .doneput
	shl ax, 1
	cmp cx, bx
	ja .doneput
	mov bx, cx
	push edx
	mul ebx
	pop edx
	add di, dx
	add di, dx
	add edi, eax
	add edi, [physbaseptr]
	mov [edi], si
.doneput:
	pop bx
	pop ax
	ret
	
getpixelmem:	;pixel in (dx, cx), outputs memory location in edi
	xor edi, edi
	xor eax, eax
	xor ebx, ebx
	mov bx, [resolutionx2]
	mov di, dx
	add di, dx
	mov ax, cx
	mul ebx
	add edi, eax
	add edi, [physbaseptr]
	ret

	mouseon db 0
	icon dw 0	;pointer to icon
	codepointer dd 0 ;pointer to code
	iconselected db 0
