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
	mov byte [.yreversed], 1
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
	xor eax, eax
	mov ax, di
	shr ax, 1
.lp:
	pusha
	xchg cx, dx
	cmp byte [.steep], 1
	je .xchg
	xchg dx, cx
.xchg:
	mov si, [.color]
	call putpixel
	popa
	cmp ax, si
	jae .noaddx
	cmp byte [.yreversed], 1
	jne .nodecy
	sub cx, 2
.nodecy:
	inc cx
	add ax, di
.noaddx:
	sub ax, si
	
	inc dx
	cmp dx, bx
	jb .lp
	
.done:
	ret
	
.color dw 0
.steep db 0
.yreversed db 0