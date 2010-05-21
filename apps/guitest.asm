%include "start.inc"
guitest:
	mov esi, .quit
	mov ah, 16
	xor al,al
	int 0x30	;set ESC (signal zero) hook
	xor ebp, ebp
	mov ah, 17
	mov al, 253
	int 0x30	;get info
	cmp cx, 0
	je .quit
	mov [.resy], cx
	mov [.resx], dx
	call .setup
	call .clear
	call .legend
	call .escape
.lp:
	call .drawcircle
	call .freebody
	add ebp, .BALLSIZE
	cmp ebp, [.balls]
	jb .lp
	mov cx, [.dt]
	xor ebp, ebp
.wait:
	hlt
	dec cx
	jnz .wait
	jmp .lp
.quit:
	mov ah, 17
	mov al, 255
	int 0x30	;reset GUI
	xor esi, esi
	mov ah, 16
	xor al,al
	int 0x30	;remove ESC (signal zero) hook
	xor ebx, ebx
	xor eax, eax
	int 0x30

.drawcircle:
	mov ah, 17
	mov al, 5
	mov si, [ebp + .size]
.xswitched:
	xor ebx, ebx
	mov dx, [ebp + .x]
	add dx, [ebp + .dx]
	cmp dx, si
	jb near .switchx
	add dx, si
	cmp dx, [.resx]
	jae near .switchx
	sub dx, si
	
	mov cx, [ebp + .y]
	add cx, [ebp + .dy]
	inc word [ebp + .t2]
	mov di, [ebp + .dt2]
	cmp [ebp + .t2], di
	jb .noddy
	xor di, di
	mov [ebp + .t2], di
	mov di, [ebp + .dy]
	add di, [ebp + .ddy]
	mov [ebp + .dy], di
.noddy:
	cmp cx, si
	jb .switchy
	add cx, si
	cmp cx, [.resy]
	jae .switchy
	sub cx, si
	
	pusha
	mov dx, [ebp + .x]
	mov cx, [ebp + .y]
	int 0x30	;clear previous circle
	popa
	
	mov [ebp + .x], dx
	mov [ebp + .y], cx
	mov bx, [ebp + .color]
	int 0x30	;show current circle
	ret

.switchx:
	sub bx, [ebp + .dx]
	mov [ebp + .dx], bx
	jmp .xswitched
	
.switchy:
	mov [ebp + .t2], bx
	sub bx, [ebp + .dy]
	add bx, [.ddy]
	mov [ebp + .dy], bx
	ret
	
.escape:
	mov di, 0xFFFF
	xor cx, cx
	xor dx, dx
	xor bx, bx
	mov ah, 17
	mov al, 2
	mov esi, .title
	pusha
	int 0x30
	popa
	xchg bx, di
	mov dx, [.resx]
	shr dx, 1
	sub dx, 100
	mov esi, .extmsg
	int 0x30
	ret
	
.legend:
	mov dx, [.resx]
	sub dx, 176
	xor cx, cx
	mov bx, 0000000000011111b
	xor di, di
	mov ah, 17
	mov al, 2
	mov esi, .fbstr
	pusha
	int 0x30	;show legend strings
	popa
	add dx, 80
	mov esi, .fbstr2
	mov bx, 1111100000000000b
	pusha
	int 0x30
	popa
	add dx, 48
	mov esi, .fbstr3
	mov bx, 0000011111100000b
	int 0x30
	ret
	
.freebody:	
	mov dx, [ebp + .fbx]
	mov cx, [ebp + .fby]
	xor bx, bx
	mov ah, 17
	mov al, 3
	cmp word [ebp + .fbdy], 0
	jne .dofbclear
	cmp word [ebp + .fbdy], 0
	je .nofbclear
.dofbclear:
	mov di, [ebp + .fbdx]
	mov si, [ebp + .fbdy]
	pusha
	int 0x30	;clear velocity vector
	popa
.nofbclear:
	mov si, [ebp + .ddy]
	shl si, 3
	add si, [ebp + .fby]
	mov di, dx
	int 0x30	;clear acceleration vector	
	mov dx, [ebp + .fbx]
	mov cx, [ebp + .fby]
	mov bx, [ebp + .color]
	mov si, 16
	mov ah, 17
	mov al, 4
	int 0x30	;show circle with the same color
	
	mov dx, [ebp + .fbx]
	mov cx, [ebp + .fby]
	mov di, [ebp + .dx]
	mov si, [ebp + .dy]
	add di, dx
	add si, cx
	mov [ebp + .fbdx], di
	mov [ebp + .fbdy], si
	mov bx, 1111100000000000b
	mov ah, 17
	mov al, 3
	int 0x30	;show velocity vector in red
	
	mov dx, [ebp + .fbx]
	mov cx, [ebp + .fby]
	mov di, dx
	mov si, [ebp + .ddy]
	shl esi, 3
	add si, cx
	mov bx, 0000011111100000b
	mov ah, 17
	mov al, 3
	int 0x30	;show acceleration vector in green
	
	mov dx, [ebp + .fbx]
	mov cx, [ebp + .fby]
	mov bx, [ebp + .color]
	mov ah, 17
	mov al, 1
	int 0x30	;place a dot on the center
	ret
	
.setup:	;setup balls using new information
	mov bx, 64
	mov [ebp + .fby], bx
	sub dx, bx
	mov [ebp + .fbx], dx
	add ebp, .BALLSIZE
	cmp ebp, [.balls]
	jb .setup
	xor ebp, ebp
	ret
	
.clear:
	mov ah, 17
	mov al, 0
	xor bx,bx
	int 0x30	;clear screen
	ret 
	
.extmsg db 	"Press the ESC key to exit",0
.title db "GUI Test",0
.fbstr	db 	"Freebody:",0
.fbstr2 db  "dr/dt",0
.fbstr3 db 	"dv/dt",0
.resx dw 0	;maximum x
.resy dw 0	;maximum y
.dt dw 5	;time between refreshes in terms of the PIT's interrupt rate
.balls dd 	.end - .b1
;Balls start here
.b1:
.color dw 0xFFFF
.size dw 16
.x dw 160	;initial x
.y dw 160	;initial y
.dx dw 4	;change in x after dt periods
.dy dw 1	;change in y after dt periods
.ddy dw 1	;change in dy after dt2*dt periods
.dt2 dw 4	;time between calculations of accelration
.t2 dw 0	;counter to next acceleration calculation
.fbx dw 0	;freebody x
.fby dw 0	;freebody y
.fbdx dw 0	;previous dx
.fbdy dw 0	;previous dy
.b1end:
.BALLSIZE equ .b1end - .b1
dw 0000000000011111b	;color
dw 6					;size
dw 440					;x
dw 340					;y
dw 0xFFFE				;dx
dw 0xFFFE				;dy
dw 1					;ddy
dw 4					;dt2
dw 0					;t2
times 4 dw 0

dw 0000011111100000b	;color
dw 22					;size
dw 140					;x
dw 200					;y
dw 0xFFFE				;dx
dw 0xFFFF				;dy
dw 1					;ddy
dw 4					;dt2
dw 0					;t2
times 4 dw 0

dw 1111100000000000b	;color
dw 18					;size
dw 500					;x
dw 140					;y
dw 3					;dx
dw 1					;dy
dw 1					;ddy
dw 4					;dt2
dw 0					;t2
times 4 dw 0

dw 1111100000011111b	;color
dw 12					;size
dw 340					;x
dw 240					;y
dw 3					;dx
dw 0xFFFF				;dy
dw 1					;ddy
dw 4					;dt2
dw 0					;t2
times 4 dw 0

dw 0000011111111111b	;color
dw 4					;size
dw 10					;x
dw 300					;y
dw 0xFFFD				;dx
dw 0					;dy
dw 1					;ddy
dw 4					;dt2
dw 0					;t2
times 4 dw 0

dw 1111111111100000b	;color
dw 20					;size
dw 600					;x
dw 400					;y
dw 0xFFFC				;dx
dw 0xFFF8				;dy
dw 1					;ddy
dw 4					;dt2
dw 0					;t2
times 4 dw 0

dw 1010101010101010b	;color
dw 8					;size
dw 100					;x
dw 160					;y
dw 3					;dx
dw 3					;dy
dw 1					;ddy
dw 4					;dt2
dw 0					;t2
times 4 dw 0

dw 0101010101010101b	;color
dw 10					;size
dw 500					;x
dw 160					;y
dw 5					;dx
dw 0					;dy
dw 1					;ddy
dw 4					;dt2
dw 0					;t2
times 4 dw 0
.end:
