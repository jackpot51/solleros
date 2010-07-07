db 255,44,"while ",0
whilecmd:  xor al, al
	cmp [BATCHISON], al
	je near notbatch
	mov esi, [BATCHPOS]
	sub esi, 2
whilefnd: dec esi
	mov al, [esi]
	cmp al, 10
	je near whilefnd2
	cmp al, 0
	je near whilefnd2
	jmp whilefnd
whilefnd2:
	inc esi
	mov [LOOPPOS], esi
	mov BYTE [LOOPON], 1
	mov esi, buftxt
	mov ebx, buftxt
	add ebx, 6
	jmp chkeqsn