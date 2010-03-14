db 255,44,"gui",0
guiswitcher:
	mov esi, [currentcommandloc]
	add esi, 4
	xor ecx, ecx
	cmp byte [esi], 0
	je .nomodepref
	call cnvrthextxt ;switches arg on cline to vesa mode in ecx
	jmp .modepref
.nomodepref:
	push ecx
	call clear
	pop ecx
.modepref:
	mov bx, guiswitch
	mov [realmodeptr], bx
	mov ebx, guiswitchret
	mov [realmodereturn], ebx
	jmp realmode
guiswitchret:
	cmp byte [gs:guion], 1
	je .cont
	ret
.cont:
	mov edi, VBEMODEBLOCK
.loop:
	mov eax, [gs:edi]
	mov [edi], eax
	inc edi
	cmp edi, VBEEND
	jb .loop
	mov eax, [physbaseptr]
	sub eax, 0x100000
	mov [physbaseptr], eax
	mov byte [termguion], 0
	mov esi, graphicstable
	xor al, al
.clear:
	mov [esi], al
	inc esi
	cmp esi, graphicstableend
	jb .clear
	call guisetup
	;The next few lines center a window that is 3/4ths of the full screen
	mov dx, [resolutionx]
	mov cx, [resolutiony]
	mov bx, dx
	mov ax, cx
	shr bx, 1
	shr ax, 1
	mov dx, bx
	shr dx, 1
	mov cx, ax
	shr cx, 1
	add bx, dx
	add ax, cx
	shr cx, 1
	shr bx, 3
	shl bx, 3
	shr ax, 4
	shl ax, 4
	mov [termwindow], bx
	mov [termwindow + 2], ax	;the previous lines of code make a large terminal window that is 4 characters smaller than the screen
	mov esi, termwindow
	xor ebx, ebx
	xor ax, ax
	call showwindow
	call cursorgui
	call clear
	ret
	
