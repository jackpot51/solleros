	db 255,44,"loop",0
	cmp byte [LOOPON], 0
	jne near filoop
	jmp nwcmd
filoop: mov esi, [LOOPPOS]
	dec byte [IFON]
	mov byte [LOOPON], 0
	mov [BATCHPOS], esi
	mov [batchedi], esi
	jmp nwcmd