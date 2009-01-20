progend:		;programs end here	

wordst:
batch:	db 6,4,"tutorial",0
	db 3,4,"clear",0
	db 3,4,"echo The batch program can run all commands featured in SollerOS.",0
	db 3,4,"echo It can also run the extra ",34,"if",34," command.",0
	db 3,4,"echo Would you like a tour of the SollerOS system?",0
	db 3,4,"echo If so, you can type yes and press enter.",0
	db 3,4,"$a=",0
	db 3,4,"if $a=no",0
	db 3,4,"echo Fine then.",0
	db 3,4,"stop",0
	db 3,4,"fi",0
	db 3,4,"if $a=yes",0
	db 3,4,"clear",0
	db 3,4,"dir",0
	db 3,4,"$b=",0
	db 3,4,"clear",0
	db 3,4,"echo ls and dir-these show all available programs",0
	db 3,4,"echo menu-this returns to the boot menu",0
	db 3,4,"echo uname-this shows the system build",0
	db 3,4,"echo help-this shows the nonexistant help file",0
	db 3,4,"echo logout-this logs the user out",0
	db 3,4,"echo clear-this clears the screen",0
	db 3,4,"echo echo-this prints text and variables to the screen",0
	db 3,4,"echo runbatch-this runs batch files",0
	db 3,4,"echo showbatch-this shows the currently loaded batch file",0
	db 3,4,"echo batch-this creates a new batchfile",0
	db 3,4,"echo #-this evaluates expresions",0
	db 3,4,"echo %-this gives back the last answer",0
	db 3,4,"echo the $ sign is used for variables",0
	db 3,4,"fi",0
	db 4,3,0
	db 7,4,"SollerOS",0
	db 3,4,"Is freaking awesome!",0
	db 4,3,0
	times 500 db 0
commandlst:
	
notbatch: jmp nwcmd

	db 5,4,"while",0
while:  mov al, 0
	cmp [BATCHISON], al
	je notbatch
	MOV esi, [BATCHPOS]
whilefnd: dec esi
	mov al, [esi]
	cmp al, 5
	jne whilefnd
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
	je notbatch
	add [IFON], al
	mov esi, buftxt
	mov ebx, buftxt
	add ebx, 3
chkeqsn: mov al, [esi]
	cmp al, 0
	je notbatch
	cmp al, '='
	je chkeqdn
	inc esi
	jmp chkeqsn
chkeqdn: mov al, 0 
	mov [esi], al
	inc esi
	mov al, [esi]
	cmp al, '$'
	je ifvar1
ifvar2: mov al, [ebx]
	cmp al, '$'
	je ifvar3
ifvar4:	call tester
	cmp al, 1
	je trueif
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
ifvar3: push esi
	mov edi, 4
	mov ebx, variables
	call nxtvrech
	pop esi
	jmp ifvar4

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
	je filoop
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

batchprogend: