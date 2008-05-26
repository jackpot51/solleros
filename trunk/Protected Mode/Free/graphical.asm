startupbmp:
	dw 1000000000000010b,0000000001000000b, 0000000000000000b,0010000000000000b
	dw 0100000000000010b,0000000000100000b, 0000000000000000b,0001000000000000b
	dw 0010000000000010b,0000000000010000b, 0000000000000000b,0000100000000000b
	dw 0001000000000010b,0000000000001000b, 0000000000000000b,0000010000000000b
	dw 0000100000000010b,0000000000000100b, 0000000000000000b,0000001000000000b
	dw 0000010000000010b,0000000000000010b, 0000000000000000b,0000000100000000b
	dw 0000001000000010b,0000000000000001b, 0000000000000000b,0000000010000000b
	dw 0000000100000010b,0000000000000000b, 1000000000000000b,0000000001000000b
	dw 0000000010000010b,0000000000000000b, 0100000000000000b,0000000000100000b
	dw 0000000001000010b,0000000000000000b, 0010000000000000b,0000000000010000b
	dw 0000000000100010b,0000000000000000b, 0001000000000000b,0000000000001000b
	dw 0000000000010010b,0000000000000000b, 0000100000000000b,0000000000000100b
	dw 0000000000001010b,0000000000000000b, 0000010000000000b,0000000000000010b
	dw 0000000000000110b,0000000000000000b, 0000001000000000b,0000000000000001b
	dw 0000000000000010b,0000000000000000b, 0000000100000000b,0000000000000000b
	dw 0000000000000011b,0000000000000000b, 0000000010000000b,0000000000000000b
	dw 0000000000000010b,1000000000000000b, 0000000001000000b,0000000000000000b
	dw 0000000000000010b,0100000000000000b, 0000000000100000b,0000000000000000b
	dw 0000000000000010b,0010000000000000b, 0000000000010000b,0000000000000000b
	dw 0000000000000010b,0001000000000000b, 0000000000001000b,0000000000000000b
	dw 0000000000000010b,0000100000000000b, 0000000000000100b,0000000000000000b
	dw 0000000000000010b,0000010000000000b, 0000000000000010b,0000000000000000b
	dw 0000000000000010b,0000001000000000b, 0000000000000001b,0000000000000000b
	dw 0000000000000010b,0000000100000000b, 0000000000000000b,1000000000000000b
	dw 0000000000000010b,0000000010000000b, 0000000000000000b,0100000000000000b

graphical:
	mov si, startupbmp
	mov dx, 8
	mov cx, 8
	mov ax, 64
	mov bx, 25
	;call showbmp
	mov bx, 0
	mov dx, 100
	mov cx, 1
	mov ax, 'S'
	call showfont
	mov     dl,1
	mov     ax,0
	mov     bx,0
	mov     si,100
	mov     di,100
	call    DRAWLINE
	jmp graphical
	


widthoffset db 0,0
width db 0,0
height db 0,0
dxolder db 0,0
widthdived db 0,0
endwidth db 0,0
showbmp:				;bmp location in si
					;location in (dx, cx)
					;dimensions in (ax, bx)		
dec si
mov [dxolder], dx
mov [endwidth], dx
add [endwidth], ax
mov dx, 0
mov [width], ax
mov [height], bx
mov word [widthoffset], 80
mov bx, 8
div bx
mov dx, [dxolder]
sub [widthoffset], ax
mov [widthdived], ax
mov bx, 0
jmp foundfontdone

showfont:
	mov [cxcache3], cx
	mov byte [modifier], 1		;modifier should be bl, only 1 works properly
	mov si, font	
	mov word [width], 8
	mov [endwidth], dx
	add word [endwidth], 8
	mov word [height], 14
	mov word [widthoffset], 80
	sub word [widthoffset], 1
	mov word [widthdived], 1
    findfontloop:
	cmp [si], al
	je foundfontdone
	cmp si, fontend
	jae nofontfound
	add si, 16
	jmp findfontloop
   nofontfound:
	mov cx, [cxcache3]
	ret

fixtherow:
	sub dx, 640
	add bx, 80
	add cx, 14
	mov [cxcache3], cx
	jmp donefixingtehrow

cxcache3 db 0,0
remainder db 0,0
dxcache4 db 0,0
foundfontdone:
	inc si
	cmp cx, 480
	jae nofontfound
	cmp dx, 640
	jae fixtherow
donefixingtehrow:
	mov ax, dx
	mov [cxcache3], cx
	mov cx, dx
	mov dx, 0
	mov bx, 8
	div bx
	mov bl, al
	mov bh, 0
	mov [remainder], dx
	mov dx, cx
	mov cx, [cxcache3]
	mov di, 0
	cmp cx, 0
	je doneloadcolumn
loadcolumn:
	mov ax, 80
	mov [dxcache4], dx
	mov dx, 0
	mul cx
	add bx, ax
	mov dx, [dxcache4]
doneloadcolumn:
	mov cx, [cxcache3]
	mov ah, 0
	mov al, [si]
	ror al, 1
	cmp byte [mouseselecton], 1
	je notcheck
notcheckdone:
	mov cx, [remainder]
	mov ah, 0
	cmp cx, 0
	jne loadcharpos
loadcharposdone:
	mov cx, [cxcache3]
	mov [gs:bx], al
	inc bx
	or [gs:bx], ah
	;	inc si
	;	add dx, 8
	;	cmp dx, [endwidth]
	;	jb doneloadcolumn
	;	sub dx, 8
	;	dec si
	add bx, [widthoffset]
	inc di
	inc si
	cmp di, [height]
	jbe doneloadcolumn
	mov cx, [cxcache3]
	ret

loadcharpos:
	ror ax, 1
	loop loadcharpos
	jmp loadcharposdone

notcheck:
	not al
	jmp notcheckdone
		

mouseselecton db 0