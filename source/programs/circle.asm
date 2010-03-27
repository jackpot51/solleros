db 255,44,"circle",0
circle:
	mov esi, [currentcommandloc]
	add esi, 7
	mov cx, 16
	xor al, al
	cmp [esi], al
	je .nocmdline
	call cnvrttxt
.nocmdline:
	call linetester.stime
	call fcircle.nocmdline
	call linetester.etime
	push ebx
	push edi
	call getchar
	pop ecx
	call showdec
	mov esi, linetester.msgcircle
	call printquiet
	pop ecx
	call showdec
	mov esi, linetester.msgtime
	call printquiet
	call reloadallgraphics
	ret
	
db 255,44,"fcircle",0	;attempts to draw many circles without refreshing screen or showing time
fcircle:	
	mov esi, [currentcommandloc]
	add esi, 8
	mov cx, 16
	xor al, al
	cmp [esi], al
	je .nocmdline
	call cnvrttxt
.nocmdline:
	mov ax, cx
	shl cx, 1
	mov dx, cx
	cmp dx, [resolutionx]
	jae .done
	cmp cx, [resolutiony]
	jae .done
	mov si, [timenanoseconds + 2]
	xor edi, edi
	cmp byte [guion], 1
	je .lp
.done ret
.lp:
	sub dx, ax
	sub cx, ax
	pusha
	call fillcircle
	popa
	inc edi
	add si, [timenanoseconds]
	add dx, ax
	add dx, ax
	add dx, ax
	add cx, ax
	cmp dx, [resolutionx]
	jb .lp
	mov dx, ax
	add dx, ax
	add cx, ax
	add cx, ax
	cmp cx, [resolutiony]
	jb .lp
	ret
