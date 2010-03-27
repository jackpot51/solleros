	showstring:
		mov [mouseselecton], al
		and byte [mouseselecton], 1
		mov ah, 2
		call graphicsadd
	showstring2:	;location in (dx,cx), color in [colorfont2] and [background]
		xor ah, ah
		mov al, [esi]
		cmp al, 0
		je doneshowstring
		inc esi
		cmp al, 255
		je showstring2
		push esi
		mov bx, [colorfont2]
		call showfontvesa
		cmp al, 10
		je noproceedshst
		add dx, 8
	noproceedshst:
		pop esi
		jmp showstring2
	doneshowstring:
		mov byte [mouseselecton], 0
		ret

colorfont2 dw 0xFFFF
colorcache db 0

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
	xor ecx, ecx
	mov cx, [resolutionx2]
	cmp dx, cx
	jbe goodvesafontx
	xor dx, dx
	mov cx, [posyvesa]
	add cx, 16
	mov [posyvesa], cx
goodvesafontx:
	mov cx, [posyvesa]
	mov [posxvesa], dx
	mov edi, [physbaseptr]
	mov [colorfont], bx
	xor ebx, ebx
	mov bl, al
	xor eax, eax
	mov al, bl
	mov bx, dx
	mov edx, ebx
	xor ebx, ebx
	cmp cx, 0
	je vesaposloopdn
	mov bx, [resolutionx2]
vesaposloop:
	push edx
	push eax
	xor eax, eax
	mov ax, cx
	mul ebx
	add edi, eax
	pop eax
	pop edx
vesaposloopdn:
	add edi, edx
	mov esi, fonts
findfontvesa:
	xor ah, ah
	cmp al, 10
	je near nwlinevesa
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
	xor cl, cl
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
	xor edx, edx
	mov dx, [resolutionx2]
	add edi, edx
	xor edx, edx
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
	xor bh, bh
	add dx, bx
	mov bx, [colorfont]
	mov cx, [posyvesa]
	mov byte [savefonton], 0
	ret
charwidth db 8
nwlinevesa:
	mov dx, [posxvesa]
	xor dx, dx
	mov [posxvesa], dx
	mov cx, [posyvesa]
	add cx, 16
	mov [posyvesa], cx
	jmp donefontvesa
vesafontsaver:
	xor al, al
	xor cl, cl
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
	xor edx, edx
	mov dx, [resolutionx2]
	add edi, edx
	sub edi, 16
	cmp ch, 16
	jb vesafontsaver
	jmp donefontvesa
colorfontmatch:
	add al, 1
	jmp donecolormatch
