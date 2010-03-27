guiint:
	cmp al, 253
	je .getinfo
	cmp byte [guion], 1
	jne .nogui
	cmp al, 0
	je near .clear
	cmp al, 1
	je near .putpixel
	cmp al, 2
	je near .drawtext
	cmp al, 3
	je near .drawline
	cmp al, 4
	je near .drawcircle
	cmp al, 5
	je near .fillcircle
	cmp al, 254
	je near .setinfo
	cmp al, 255
	je near .reset
.nogui:
	jmp timerinterrupt

.clear:		;color in bx
	mov [background], bx
%ifdef gui.background
	mov ebx, [backgroundimage]
	cmp ebx, 0
	je .clearit
	mov dword [backgroundimage], 0
	mov [.bgi], ebx
.clearit:
%endif
	call guiclear
	jmp timerinterrupt
	
.getinfo:		;puts screen size in (dx, cx), background color in bx, and will put other stuff in other places
	xor bx, bx
	xor cx, cx
	xor dx, dx
	cmp [guion], bl
	je .nogui
	mov bx, [background]
	mov dx, [resolutionx]
	mov cx, [resolutiony]
	jmp timerinterrupt
	
.setinfo:
	
.reset:		;resets the screen to the original settings
	mov bx, background.original
	mov [background], bx
	mov bx, 0xFFFF
	mov [colorfont2], bx
%ifdef gui.background
	mov ebx, [backgroundimage]
	cmp ebx, 0
	jne .resetit
	mov ebx, [.bgi]
	mov [backgroundimage], ebx
.resetit:
%endif
	call guiclear
	call reloadallgraphics
	jmp timerinterrupt

%ifdef gui.background
	.bgi dd 0
%endif
	
.putpixel:	;pixel location in (dx, cx), color in bx
	mov si, bx
	call putpixel
	jmp timerinterrupt

.drawtext:	;background in di, foreground in bx, location in (dx,cx), string in esi
	shl dx, 1
	mov [colorfont2], bx
	mov [background], di
	call showstring2
	jmp timerinterrupt

.drawline:	;color in bx, start in (dx,cx), end in (di,si)
	mov ax, si
	mov si, bx
	mov bx, di
	call drawline
	jmp timerinterrupt

.drawcircle: ;color in bx, radius in si, center in (dx,cx)
	mov ax, si
	mov si, bx
	call drawcircle
	jmp timerinterrupt

.fillcircle: ;color in bx, radius in si, center in (dx,cx)
	mov ax, si
	mov si, bx
	call fillcircle
	jmp timerinterrupt
	
