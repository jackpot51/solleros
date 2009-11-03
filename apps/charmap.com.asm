[BITS 16]
[ORG 0x100]
	mov dl, 0
	mov cx, 100h
nextchar:
	mov ah, 2
	int 21h
	inc dl
	loopnz nextchar
	int 20h