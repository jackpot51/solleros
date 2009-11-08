db 255,44,"dump",0
	mov esi, [currentcommandloc]
	add esi, 5
	xor ecx, ecx
	mov ax, "0x"
	cmp [esi], ax
	je dumphexin
	call cnvrttxt
	jmp dumphexnow
dumphexin:
	add esi, 2
	call cnvrthextxt
	jmp dumphexnow
dumphexnow:
	mov edi, ecx
	mov esi, edi
	add esi, 896
dumphexloop:
	mov ecx, [edi]
	mov byte [firsthexshown],5
	call showhex
	add edi, 4
	cmp edi, esi
	jb dumphexloop
	call termcopy
	jmp nwcmd