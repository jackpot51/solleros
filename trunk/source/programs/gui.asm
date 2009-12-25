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
	mov word [termwindow], 640
	mov word [termwindow + 2], 480	;the previous lines of code make a large terminal window that is 4 characters smaller than the screen
	mov esi, termwindow
	mov dx, [resolutionx]
	mov cx, [resolutiony]
	sub dx, 640
	sub cx, 480
	shr dx, 1 ;x location-this centers the window
	shr cx, 1 ;y location-this centers the window	
	mov ebx, nwcmd
	xor ax, ax
	call showwindow
	call cursorgui
	call clear
	ret
	