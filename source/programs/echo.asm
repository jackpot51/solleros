
db 255,44,"echo",0
	echo:	mov esi, buftxt
		add esi, 5
		mov al, [esi]
		call print
		mov esi, line
		call print
		jmp nwcmd
	echovr:	mov ebx, variables
		mov edi, 6
		call nxtvrech
		jmp prntvr2
	echvar:	mov cl, '='
		inc ebx
		mov al, [ebx]
		cmp al, 0
		je nxtvrech
		cmp al, '='
		je nxtvrechb1
		mov esi, buftxt
		add esi, edi
		call cndtest
		cmp al, 2
		je prntvr
		cmp al, 1
		je prntvr
		mov esi, buftxt
		add esi, edi
		jmp nxtvrech
	nxtvrechb1:
		sub ebx, 2
		jmp echvar
	nxtvrech: mov al, [ebx]
		cmp al, 5
		je nxtvrec2
		inc ebx
		cmp ebx, varend
		jb nxtvrech
		ret
	nxtvrec2: inc ebx
		mov al, [ebx]
		cmp al, 4
		je echvar
		jmp nxtvrech
	prntvr: inc ebx
		mov esi, ebx
		ret
	prntvr2: call print
		mov esi, line
		call print
		jmp nwcmd