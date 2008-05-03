db 5,4,"&",0
	multitask:
	jmp nwcmd
		
progend:		;programs end here
	
	db 5,4,"BATCHES ONLY!!!",0
notbatch: jmp nwcmd

	db 5,4,"while",0
while:  mov al, 1
	cmp [BATCHISON], al
	jne notbatch
	MOV si, [BATCHPOS]
whilefnd: dec si
	mov al, [si]
	cmp al, 5
	jne whilefnd
	mov [LOOPPOS], si
	mov BYTE [LOOPON], 1
	add [IFON], al
	 mov si, buftxt
	mov bx, buftxt
	add bx, 6
	jmp chkeqsn


	db 5,4,"if",0
if:	mov al, 1
	cmp [BATCHISON], al
	jne notbatch
	add [IFON], al
	 mov si, buftxt
	mov bx, buftxt
	add bx, 3
chkeqsn: mov al, [si]
	cmp al, 0
	je notbatch
	cmp al, '='
	je chkeqdn
	inc si
	jmp chkeqsn
chkeqdn: mov al, 0 
	mov [si], al
	inc si
	mov al, [si]
	cmp al, '$'
	je ifvar1
ifvar2: mov al, [bx]
	cmp al, '$'
	je ifvar3
ifvar4:	mov cl, 0
	call cndtest
	cmp al, 1
	je trueif
	jmp falseif
trueif:	mov al, [IFON]
	mov ah, 0
	mov si, IFTRUE
	add si, ax
	mov ah, 1
	mov [si], ah
	jmp nwcmd
falseif: mov al, [IFON]
	mov ah, 0
	mov si, IFTRUE
	add si, ax
	mov [si], ah
	jmp nwcmd
ifvar1: push si
	sub si, buftxt
	mov di, si
	pop si
	inc di
	mov bx, variables
	call nxtvrech
	jmp ifvar2
ifvar3: push si
	mov si, bx
	sub si, buftxt
	mov di, si
	inc di
	mov bx, variables
	call nxtvrech
	mov bx, si
	pop si
	jmp ifvar4

	db 5,4,"else",0
else:	mov ah, 0
	mov al, [IFON]
	mov si, IFTRUE
	add si, ax
	mov al, [si]
	cmp al, 0		
	je else1
	cmp al, 1
	je else2
	jmp nwcmd
else1:  mov al, 1
	mov [si], al
	jmp nwcmd
else2:	mov al, 0
	mov [si], al
	jmp nwcmd

	db 5,4,"loop",0
	cmp [LOOPON], al
	je filoop
	jmp nwcmd
filoop: mov si, [LOOPPOS]
	mov [BATCHPOS], si
	jmp nwcmd
	

	db 5,4,"fi",0
	mov al, 1
	cmp [BATCHISON], al
	jne NEAR nwcmd
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
	
	db 5,4,"easter",0
easter:	mov si, easteregg
	call print
	jmp nwcmd

batchprogend: