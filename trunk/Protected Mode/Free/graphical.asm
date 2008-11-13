oldbx2 db 0,0
olddi db 0,0
oldax db 0,0
oldbx db 0,0
oldcx db 0,0
olddx db 0,0
oldsi db 0,0
videobuf2copy:
	mov [oldax], ax
	mov [oldbx], bx
	mov [oldcx], cx
	mov [olddx], dx
	mov [oldsi], si
	mov [olddi], di
	mov byte [mouseselecton], 0
	mov byte [termcopyon], 1
	cmp byte [guion], 1
	je near windowvideocopy
	mov ax, [oldax]
	mov bx, [oldbx]
	mov cx, [oldcx]
	mov dx, [olddx]
	mov si, [oldsi]
	mov di, [olddi]
	ret



termcopyon db 0
graphicsset db 0
graphicspos db 0,0
showcursorfonton db 0
savefonton db 0
mouseselecton db 0
