db 255,44,"play",0
	mov edi, buftxt
	add edi, 5
	mov esi, 0x400000
	call loadfile
	cmp edx, 404
	je nosoundfound
	mov ebx, 0x400000
	cmp word [ebx], "SN"
	jne nosoundfound
	add ebx, 6
	mov [soundpos], ebx
	add ebx, [ebx - 4]
	mov [soundendpos], ebx
	mov word [soundrepititions], 0
	mov byte [soundon], 1
	jmp nwcmd
nosoundfound:
	mov esi, notfoundsound
	call print
	mov esi, buftxt
	add esi, 5
	call print
	mov esi, notfound2
	call print
	jmp nwcmd
notfoundsound db "Sound ",34,0