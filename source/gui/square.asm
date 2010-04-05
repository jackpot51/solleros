drawsquare:	;from (bx,ax) to (dx,cx), color in si
	cmp bx, dx
	jae .noxchgx
	xchg bx, dx
.noxchgx:
	cmp ax, cx
	jae .noxchgy
	xchg ax, cx
.noxchgy:
	push ax
	push bx
	push dx
	call getpixelmem	;get pointer to pixel in edi from (dx,cx)
	xor edx, edx
	pop dx
	xor ebx, ebx
	pop bx
	pop ax
.lp0:
	push dx
.lp:
	mov [edi], si
	add edi, 2
	inc dx
	cmp dx, bx
	jbe .lp
	pop dx
	sub edi, 2
	sub edi, ebx
	sub edi, ebx
	add edi, edx
	add edi, edx
	add edi, [resolutionx2]
	inc cx
	cmp cx, ax
	jb .lp2
	je .lp0
	ret
.lp2:
	push edi
	mov [edi], si
	sub edi, edx
	sub edi, edx
	add edi, ebx
	add edi, ebx
	mov [edi], si
	pop edi
	add edi, [resolutionx2]
	inc cx
	cmp cx, ax
	jb .lp2
	jmp .lp0

fillsquare:	;from (bx,ax) to (dx,cx), color in si
	cmp bx, dx
	jae .noxchgx
	xchg bx, dx
.noxchgx:
	cmp ax, cx
	jae .noxchgy
	xchg ax, cx
.noxchgy:
	push ax
	push bx
	push dx
	call getpixelmem	;get pointer to pixel in edi from (dx,cx)
	xor edx, edx
	pop dx
	xor ebx, ebx
	pop bx
	pop ax
.lp2
	push dx
.lp:
	mov [edi], si
	add edi, 2
	inc dx
	cmp dx, bx
	jbe .lp
	pop dx
	sub edi, 2
	sub edi, ebx
	sub edi, ebx
	add edi, edx
	add edi, edx
	add edi, [resolutionx2]
	inc cx
	cmp cx, ax
	jbe .lp2
	ret