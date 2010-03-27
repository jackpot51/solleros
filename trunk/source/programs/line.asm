db 255,44,"line",0
linetester:
	cmp byte [guion], 0
	je near .done
	mov si, [timenanoseconds + 2];essentially load a random value
	mov ebx, 28*2;the line test draws ~28/6 times more lines in a 4:3 display mode than circles
	call .circletest
	mov ebx, 6*2 ;this makes them draw the same amount of lines as circles
	call .linetest
.done:
	ret

.linetest:
	push ebx
	call .stime
	pop ebx
	xor edi, edi
.ltlp:
	push ebx
	call .st
	not si
	call .st
	pop ebx
	not si
	add si, [timenanoseconds]
	dec ebx
	cmp ebx, 0
	ja .ltlp
	call .etime
	push ebx	
	push edi
	call guiclear
	call reloadallgraphics
	pop ecx
	call showdec
	mov esi, .msg
	call print
	pop ecx
	call showdec
	mov esi, .msgtime
	call print
	ret
	
.circletest:
	push ebx
	call .stime
	pop ebx
	xor edi, edi
.ctlp:
	push ebx
	mov cx, [resolutiony]
	shr cx, 1
	mov dx, [resolutionx]
	shr dx, 1
	mov ax, cx
.circle:
	pusha
	call drawcircle
	popa
	dec ax
	inc edi
	cmp ax, 1
	ja .circle
	not si
.circle2:
	pusha
	call drawcircle
	popa
	inc edi
	inc ax
	cmp ax, cx
	jbe .circle2
	pop ebx
	not si
	add si, [timenanoseconds]
	dec ebx
	cmp ebx, 0
	ja .ctlp
	call .etime
	push ebx
	push edi
	pop ecx
	call showdec
	mov esi, .msgcircle
	call print
	pop ecx
	call showdec
	mov esi, .msgtime
	call print
	ret
	
.stime:
	hlt
	mov eax, [timeseconds]
	mov ebx, [timenanoseconds]
	mov [.time], eax
	mov [.time + 4], ebx
	ret
	
.etime:
	mov eax, [timeseconds]
	mov ebx, [timenanoseconds]
	mov ecx, [.time]
	mov edx, [.time + 4]
	shr edx, 10
	shr ebx, 10
	sub eax, ecx
	cmp eax, 0
	je .notclp
.tclp:
	add ebx, 1000000
	dec eax
	cmp eax, 0
	jne .tclp
.notclp:
	sub ebx, edx
	ret
	
.st:
	xor ax, ax
	xor bx, bx
	mov cx, [resolutiony]
	mov dx, [resolutionx]
.lp:
	pusha
	call drawline
	popa
.noswitch:
	inc edi
	inc bx
	dec dx
	cmp bx, 0
	je .lp
	cmp dx, 0
	jne .lp
.lp2:
	pusha
	call drawline
	popa
	inc edi
	inc ax
	dec cx
	cmp cx, 0
	jne .lp2
	ret
	
.msg db "lines were drawn in ",0
.msgcircle db "circles were drawn in ",0
.msgtime db "microseconds.",10,0
.time dd 0,0	
