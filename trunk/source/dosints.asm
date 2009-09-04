int21h:
dostosolleros:
	push ax
	mov ax, NEW_DATA_SEL
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov ax, SYS_DATA_SEL
	mov gs, ax
	pop ax
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
backtodos:
	push ax
	mov ax, PROG_DATA_SEL
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	pop ax
	iret

dosgchar:
	xor al, al
	call int302
	jmp backtodos
	
doswchar:
	mov bl, 7
	call int301
	jmp backtodos
	
dosprintstr:
	mov esi, 0x400000
	mov si, dx
	mov al, "$"
	mov bl, 7
	call int303
	jmp backtodos
	
dosgetstr:
	mov esi, 0x400000
	mov si, dx
	mov ecx, 0
	mov cl, [esi]
	add esi, 3
	mov edi, esi
	mov [stringstart], esi
	add edi, ecx
	mov al, 13
	mov bl, 7
	call int305
	mov ecx, esi
	sub ecx, [stringstart]
	mov esi, [stringstart]
	mov [esi - 1], cl
	mov [esi - 2], cl
	jmp backtodos
stringstart dd 0

dosgetdate:
	call time
	mov cl, [RTCtimeYear]
	mov ch, 0
	add cx, 2000
	mov dh, [RTCtimeMonth]
	mov dl, [RTCtimeDay]
	jmp backtodos

dosgettime:
	call time
	mov ch, [RTCtimeHour]
	mov cl, [RTCtimeMinute]
	mov dh, [RTCtimeSecond]
	mov dl, 0
	jmp backtodos
	
dosexit:
	jmp nwcmd
