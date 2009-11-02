db 255,44,"ls",0
	lscmd:	mov esi, progstart
			mov ebx, progend
dir:	mov esi, fileindex
	dirnxt:	mov al, [esi]
		xor ah, ah
		cmp al, 255
		je dirfnd
		inc esi
		cmp esi,  fileindexend
		jae dirdn
		jmp dirnxt
	dirfnd3:
		inc esi
		cmp esi, fileindexend
		jbe dirnxt
		dec esi
	dirfnd:	inc esi
		mov al, [esi]
		xor ah, ah
		cmp al, 44
		je dirfnd2
		inc esi
		cmp esi,  fileindexend
		jae dirdn
		jmp dirnxt
	dirfnd2: add esi, 1
		call printquiet
		push esi
		mov esi, dirtab
		call printquiet
		pop esi
		cmp esi,  fileindexend
		jae dirdn
		jmp dirnxt
	dirdn:	mov esi, line
			call print
			jmp nwcmd
currentdir db 0