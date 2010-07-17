db 255,44,"cd",0
cd:
	mov esi, [currentcommandloc]
	add esi, 3
	mov edi, [currentfolderloc]
	mov [lastfolderloc], edi
	add edi, currentfolder
	dec edi
	cmp byte [esi], '/'
	jne .noroot
	xor edi, edi
	mov [currentfolderloc], edi
	mov [lastfolderloc], edi
	add edi, currentfolder
	dec edi
	inc esi
	cmp byte [esi], 0
	je .noroot
	dec esi
.noroot:
	cmp word [esi], ".."
	je .moveup
	inc edi
.movedown:
	mov al, [esi]
	mov [edi], al
	inc edi
	inc esi
	cmp al, 0
	je .donecd
	cmp edi, currentfolderend
	jb .movedown
	xor al, al
.donecd:
	dec edi
	mov byte [edi], '/'
	inc edi
	mov byte [edi], 0
	sub edi, currentfolder
	mov [currentfolderloc], edi
	ret
.moveup:
	xor eax, eax
	mov [lastfolderloc], eax
.moveuploop:
	dec edi
	mov al, [edi]
	cmp edi, currentfolder
	jbe .moveupover
	cmp al, '/'
	jne .moveuploop
	mov byte [edi], '/'
	inc edi
	mov byte [edi], 0
	sub edi, currentfolder
	mov [currentfolderloc], edi
	add edi, currentfolder
	dec edi
.lastfolder:
	dec edi
	mov al, [edi]
	cmp edi, currentfolder
	jbe .donemoveup
	cmp al, '/'
	jne .lastfolder
.donemoveup:
	inc edi
	sub edi, currentfolder
	mov [lastfolderloc], edi
	ret
.moveupover:
	mov edi, currentfolder
	mov byte [edi], '/'
	inc edi
	mov byte [edi], 0
	xor eax, eax
	mov [lastfolderloc], eax
	inc eax
	mov [currentfolderloc], eax
	ret
