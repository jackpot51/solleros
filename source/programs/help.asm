db 255,44,"help",0
lscmd:	
		mov al, 13
		call prcharq
		mov esi, progstart
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
	dirfnd2: inc esi
		call printquiet
		push esi
		mov al, 9
		call prcharq
		pop esi
		cmp esi,  fileindexend
		jae dirdn
		jmp dirnxt
	dirdn:	mov esi, line
			call print
			ret
currentdir db 0
