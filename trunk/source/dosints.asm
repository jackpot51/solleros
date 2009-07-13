int21h:
	cmp ah, 1
	je near dosgchar
	cmp ah, 2
	je near doswchar
	cmp ah, 9
	je near dosprintstr
	cmp ah, 0xA
	je near dosgetstr
	cmp ah, 0x2B
	je near dosgetdate
	cmp ah, 0x2C
	je near dosgettime
	cmp ah, 0x4C
	je near dosexit
	ret

dosgchar:
	mov ah, 5
	xor al, al
	int 30h
	ret
	
doswchar:
	mov bl, 7
	mov ah, 6
	int 30h
	ret
	
dosprintstr:
	mov esi, [esp]
	mov si, dx
	mov al, "$"
	mov ah, 1
	mov bl, 7
	int 30h
	ret
	
dosgetstr:
	mov esi, [esp]
	mov si, dx
	mov ecx, 0
	mov cl, [esi]
	add esi, 3
	mov edi, esi
	mov [stringstart], esi
	add edi, ecx
	mov al, 13
	mov ah, 4
	mov bl, 7
	int 30h
	mov ecx, esi
	sub ecx, [stringstart]
	mov esi, [stringstart]
	mov [esi - 1], cl
	mov [esi - 2], cl
	ret
stringstart dd 0

dosgetdate:
	call time
	mov cl, [RTCtimeYear]
	mov ch, 0
	add cx, 2000
	mov dh, [RTCtimeMonth]
	mov dl, [RTCtimeDay]
	ret

dosgettime:
	call time
	mov ch, [RTCtimeHour]
	mov cl, [RTCtimeMinute]
	mov dh, [RTCtimeSecond]
	mov dl, 0
	ret
	
dosexit:
	xor ax, ax
	int 30h
