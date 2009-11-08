	db 255,44,"if",0
ifcmd:	xor al, al
	cmp [BATCHISON], al
	je near notbatch
	mov ebx, [currentcommandloc]
	add ebx, 3
	mov esi, ebx
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
	call tester
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