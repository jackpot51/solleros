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
	db 3,4,"echo universe-this shows a famous quote from einstein",0
	db 3,4,"echo echo-this prints text and variables to the screen",0
	db 3,4,"echo math-this is the obsolete math program",0
	db 3,4,"echo etch-a-sketch-this is a 3rd party app",0
	db 3,4,"echo space-this shows the amount of available space for variables",0
	db 3,4,"echo reload-this reloads the operating system from the floppy",0
	db 3,4,"echo runbatch-this runs batch files",0
	db 3,4,"echo showbatch-this shows the currently loaded batch file",0
	db 3,4,"echo batch-this creates a new batchfile",0
	db 3,4,"echo time-this reads the system time in an unfamiliar format",0
	db 3,4,"echo #-this evaluates expresions",0
	db 3,4,"echo %-this gives back the last answer",0
	db 3,4,"echo the $ sign is used for variables",0
	db 3,4,"echo the BATCHES ONLY!!! programs are for batches only",0
	db 3,4,"fi",0
	db 4,3,0
	db 7,4,"SollerOS",0
	db 3,4,"Is freaking awesome!",0
	db 4,3,0
	times 1000 db 0
commandlst:
	
notbatch: jmp nwcmd

	db 5,4,"while",0
while:  mov al, 0
	cmp [BATCHISON], al
	je notbatch
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
if:	mov al, 0
	cmp [BATCHISON], al
	je notbatch
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
ifvar4:	call tester
	cmp al, 1
	je trueif
	jmp falseif
trueif:	mov al, [IFON]
	inc al
	mov [IFON], al
	mov ah, 0
	mov si, IFTRUE
	add si, ax
	mov ah, 1
	mov [si], ah
	jmp nwcmd
falseif: mov al, [IFON]
	inc al
	mov [IFON], al
	mov ah, 0
	mov si, IFTRUE
	add si, ax
	mov ah, 0
	mov [si], ah
	jmp nwcmd
ifvar1: mov di, si
	sub di, buftxt
	inc di
	mov bx, variables
	call nxtvrech
	mov bx, buftxt
	add bx, 3
	jmp ifvar2
ifvar3: push si
	mov di, 4
	mov bx, variables
	call nxtvrech
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
