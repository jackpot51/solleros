	db 255,44,"if",0
ifcmd:	xor al, al
	cmp [BATCHISON], al
	je near notbatch
	mov esi, buftxt
	mov ebx, buftxt
	add ebx, 3
chkeqsn: mov al, [esi]
	cmp al, 0
	je near notbatch
	cmp al, '='
	je near chkeqdn
	inc esi
	jmp chkeqsn
chkeqdn: mov al, 0 
	mov [esi], al
	inc esi
	mov al, [esi]
	cmp al, '$'
	je near ifvar1
ifvar2: mov al, [ebx]
	cmp al, '$'
	je near ifvar3
ifvar4:	call tester
	cmp al, 1
	je near trueif
	jmp falseif
trueif:	xor eax, eax
	mov al, [IFON]
	inc al
	mov [IFON], al
	xor ah, ah
	mov esi, IFTRUE
	add esi, eax
	mov ah, 1
	mov [esi], ah
	jmp nwcmd
falseif: xor eax, eax
	mov al, [IFON]
	inc al
	mov [IFON], al
	xor ah, ah
	mov esi, IFTRUE
	add esi, eax
	xor ah, ah
	mov [esi], ah
	jmp nwcmd
ifvar1: mov edi, esi
	sub edi, buftxt
	inc edi
	mov ebx, variables
	call nxtvrech
	mov ebx, buftxt
	add ebx, 3
	jmp ifvar2
ifvar3: mov [esiif], esi
	mov edi, 4
	mov ebx, variables
	call nxtvrech
	mov esi, [esiif]
	jmp ifvar4

esiif dd 0