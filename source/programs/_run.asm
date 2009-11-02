
	elfstart db 0x7F,"ELF"
	db 255,44,"./",0
rundiskprog:
	mov edi, buftxt
	add edi, 2
	mov esi, 0x400000
	call loadfile
	cmp edx, 404
	je noprogfound
	mov ebx, 0x400000
	mov eax, [elfstart]
	cmp [ebx], eax
	je near runelf
	cmp word [ebx], "EX"
	jne progbatchfound
	add ebx, 2
	mov edi, buftxt
	add edi, 2
findspaceprog:
	mov al, [edi]
	inc edi
	cmp al, " "
	jne findspaceprog
findnonspaceprog:
	mov al, [edi]
	inc edi
	cmp al, " "
	je findnonspaceprog
	dec edi
	jmp ebx
runelf:
	mov edi, buftxt
	add edi, 2
	add ebx, 0x80
	jmp ebx
noprogfound:
	mov esi, notfound1
	call print
	mov esi, buftxt
	add esi, 2
	call print
	mov esi, notfound2
	call print
	jmp nwcmd
progbatchfound:
		mov edi, 0x400000
		mov byte [BATCHISON], 1
	batchrunloop:
		call buftxtclear
		mov esi, buftxt
	batchrunloop2:
		mov cl, 10
		mov ch, 13
		cmp [edi], cl
		je near nxtbatchrunline
		cmp [edi], ch
		je near nxtbatchrunline
		cmp byte [edi], 0
		je near nxtbatchrunline
		mov al, [edi]
		mov [esi], al
		inc esi
		inc edi
		jmp batchrunloop2
	nxtbatchrunline:
		inc edi
		cmp [edi], cl
		je nxtbatchrunline
		cmp [edi], ch
		je nxtbatchrunline
		mov [batchedi], edi
		mov [BATCHPOS], edi
		mov byte [esi], 0
		mov esi, buftxt
		cmp byte [esi], 0
		je near nobatchfoundrun
		xor ebx, ebx
		mov bl, [IFON]
		cmp bl, 0
		jne near iftestbatch
	doneiftest:
		cmp byte [runnextline], 0
		je near noruniftest
		call progtest2
	noruniftest:
		mov byte [runnextline], 1
		mov edi, [batchedi]
		cmp byte [edi], 0
		jne near batchrunloop
	nobatchfoundrun:
		mov byte [BATCHISON], 0
		jmp nwcmd
	
batchedi dd 0	
	
	iftestbatch:
		mov esi, IFTRUE
		add esi, ebx
		cmp byte [esi], 0
		jne near doneiftest
		mov [iffalsebuf], bl
		cmp byte [LOOPON], 1
		jne near fifindbatch
		jmp batchrunloop
	elsetestbatch:
		mov byte [esi], 1
		add edi, 6
		jmp batchrunloop
	fifindbatch:
		mov cx, "if"
		mov ax, "fi"
		cmp [edi], ax
		je near fifoundbatch
		cmp [edi], cx
		je near iffoundbatch
		cmp byte [edi], 0
		je near fifoundbatch
		mov eax, "else"
		cmp [edi], eax
		je near elsetestbatch
		add edi, 2
		jmp fifindbatch
	fifoundbatch:
		inc edi
		mov al, 10
		cmp [edi], al
		je near goodfibatch
		cmp byte [edi], 0
		je near nobatchfoundrun
		jmp fifindbatch
	goodfibatch:
		mov al, 1
		sub [IFON], al 
		mov al, [IFON]
		mov bl, [iffalsebuf]
		cmp al, bl
		ja fifindbatch
		mov esi, buftxt
		sub edi, 2
		mov byte [runnextline], 0
		jmp batchrunloop
	iffoundbatch:
		mov al, ' '
		add edi, 2
		cmp [edi], al
		jne near fifindbatch
		mov al, 1
		add [IFON], al
		jmp fifindbatch
		
		
runnextline db 1
iffalsebuf db 0

notbatch: jmp nwcmd