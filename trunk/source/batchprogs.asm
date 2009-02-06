	
notbatch: jmp nwcmd

	db 5,4,"while",0
while:  mov al, 0
	cmp [BATCHISON], al
	je near notbatch
	MOV esi, [BATCHPOS]
whilefnd: dec esi
	mov al, [esi]
	cmp al, 5
	jne near whilefnd
	mov [LOOPPOS], esi
	mov BYTE [LOOPON], 1
	add [IFON], al
	mov esi, buftxt
	mov ebx, buftxt
	add ebx, 6
	jmp chkeqsn


	db 5,4,"if",0
if:	mov al, 0
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
trueif:	mov eax, 0
	mov al, [IFON]
	inc al
	mov [IFON], al
	mov ah, 0
	mov esi, IFTRUE
	add esi, eax
	mov ah, 1
	mov [esi], ah
	jmp nwcmd
falseif: mov eax, 0
	mov al, [IFON]
	inc al
	mov [IFON], al
	mov ah, 0
	mov esi, IFTRUE
	add esi, eax
	mov ah, 0
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
	
	db 5,4,"else",0
else:	mov eax, 0
	mov al, [IFON]
	mov esi, IFTRUE
	add esi, eax
	mov al, [esi]
	cmp al, 0		
	je else1
	cmp al, 1
	je else2
	jmp nwcmd
else1:  mov al, 1
	mov [esi], al
	jmp nwcmd
else2:	mov al, 0
	mov [esi], al
	jmp nwcmd

	db 5,4,"loop",0
	cmp [LOOPON], al
	je near filoop
	jmp nwcmd
filoop: mov esi, [LOOPPOS]
	mov [BATCHPOS], esi
	jmp nwcmd
	

	db 5,4,"fi",0
	mov al, 0
	cmp [BATCHISON], al
	je near notbatch
fi:	mov al, 1
	sub [IFON],al
	jmp nwcmd

	db 5,4,"stop",0
stop:	mov al, 0
	mov [BATCHISON], al
	mov [IFON], al
	mov [IFTRUE], al
	mov [LOOPON], al
	jmp nwcmd

progend:		;programs end here	
batchprogend:
