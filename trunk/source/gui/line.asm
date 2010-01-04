drawline:	;from (bx,ax) to (dx,cx), color in si
	mov [.color], si
	mov byte [.steep], 0
	mov byte [.yreversed], 0
	jmp .notsteep
.steeploop:
	mov byte [.steep], 1
.notsteep:
	xor edi, edi
	xor esi, esi
	cmp dx, bx
	ja .noreversex
	xchg dx, bx
	xchg cx, ax
.noreversex:
	mov di, dx
	sub di, bx
	
	cmp cx, ax
	jb .reversey
	mov si, cx
	sub si, ax
	jmp .normal
.reversey:
	mov byte [.yreversed], 2
	mov si, ax
	sub si, cx	
.normal:
	xchg cx, dx
	xchg ax, bx
	cmp si, di
	ja .steeploop
	xchg cx, dx
	xchg ax, bx
	
	xchg ax, cx
	xchg bx, dx
	mov [.xdelta], di
	mov [.ydelta], si
	mov si, [.color]
	mov [.endline], bx
	push dx
	push cx
	xchg cx, dx
	cmp byte [.steep], 1
	je .xchg
	xchg dx, cx
.xchg:
	call getpixelmem	;get pointer to pixel in edi from (dx,cx)
	pop cx
	pop dx
	xor eax, eax
	mov ax, [.xdelta]
	shr ax, 1
	mov cl, [.steep]
	or cl, [.yreversed]
	push ebp
	mov bp, [.endline]
	sub bp, dx
	mov dx, [.ydelta]
.lp:
	mov [edi], si
	cmp ax, dx
	jae .noaddx
	test cl, 2
	jz .nodecy
	test cl, 1
	jnz .steepy
	sub edi, ebx
	sub edi, ebx
	jmp .nodecy
.steepy:
	sub edi, 4
.nodecy:
	add ax, [.xdelta]
	test cl, 1
	jnz .steepx
	add edi, ebx
	jmp .noaddx
.steepx:
	add edi, 2
.noaddx:
	sub ax, dx
	dec bp
	add edi, 2
	test cl, 1
	jz .nosteepx
	sub edi, 2
	add edi, ebx
.nosteepx:
	cmp bp, 0
	jne .lp
.done:
	pop ebp
	ret
	
.color dw 0
.steep db 0
.yreversed db 0
.endline dw 0
.xdelta dw 0
.ydelta dw 0