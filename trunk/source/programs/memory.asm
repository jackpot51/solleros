db 255,44,"memory",0
	mov esi, memlistbuf
	xor edi, edi
	mov di, [memlistend]
	add edi, esi
printmemmap:
	mov ecx, [esi]
	call showhex
	add esi, 8
	mov ecx, [esi]
	call showhex
	add esi, 8
	mov ecx, [esi]
	call showhex
	add esi, 8
	push edi
	push esi
	mov esi, line
	call print
	pop esi
	pop edi
	cmp esi, edi
	jb printmemmap
	jmp nwcmd
	