db 255,44,"gui",0
guiswitcher:
	call clear
	mov bx, guiswitch
	mov [realmodeptr], bx
	mov ebx, guiswitchret
	mov [realmodereturn], ebx
	jmp realmode
guiswitchret:
	mov edi, VBEMODEBLOCK
.loop
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
.clear
	mov [esi], al
	inc esi
	cmp esi, graphicstableend
	jb .clear
	jmp gui