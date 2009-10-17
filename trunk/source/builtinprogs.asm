filetypes db 255,44
progstart:		;programs start here
indexfiles:
	mov esi, progstart
	mov ebx, fileindex
	mov edi, progstart
	sub edi, 2
indexloop:
	mov cx, [esi]
	indexloop2:
		cmp cx, [edi]
		je indexloop2done
		sub edi, 2
		cmp edi, filetypes
		jae indexloop2
	mov edi, progstart
	sub edi, 2
	inc esi
	cmp esi, batchprogend
	jae indexloopdone
	jmp indexloop
indexloop2done:
	mov [ebx], cx
	add ebx, 2
	add esi, 2
	nameindex:
		mov cl, [esi]
		cmp cl, 0
		je nameindexdone
		mov [ebx], cl
		inc esi
		inc ebx
		jmp nameindex
	nameindexdone:
		inc ebx
		mov word [ebx], 0
		add ebx, 2
		inc esi
		mov [ebx], esi
		add ebx, 4
		mov word [ebx], 0
		add ebx, 2
		cmp ebx, fileindexend
		jae indexloopdone
		add esi, 1
		jmp indexloop
indexloopdone: 	mov byte [indexdone], 1
		ret

indexdone db 0

db 255,44,"shush",0
	mov esi, shushmsg
	call print
	jmp shush

db 255,44,"ls",0
	lscmd:	mov esi, progstart
		mov ebx, progend
		jmp dir
		
db 255,44,"disk",0
		mov esi, diskmsg
		call printquiet
		xor ecx, ecx
		mov cl, [DriveNumber]
		mov byte [firsthexshown], 5
		call showhexsmall
		mov esi, line
		call printquiet
		mov esi, diskfileindex
	diskindexdir:
		call printquiet
		push esi
		mov esi, disktab
		call printquiet
		pop esi
		mov ecx, [esi + 5]
		mov byte [firsthexshown], 5
		call showdec
		push esi
		mov esi, line
		call printquiet
		pop esi
		add esi, 9
		cmp esi, enddiskfileindex
		jb diskindexdir
		call termcopy
		jmp nwcmd
		
		diskmsg db "Disk ",0
		disktab db 13,9,9,9,0

db 255,44,"clear",0
	cls:	call clear
		jmp nwcmd
		
db 255,44,"wait",0
		xor al, al
		call int302
		jmp nwcmd

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
		
db 255,44,"#",0
	num:	
		call clearbuffer
		mov byte [decimal], 0
		mov byte [decimal2], 0
		mov esi, buftxt
		xor eax, eax
		xor ecx, ecx
		xor ebx, ebx
	num2:	mov al, [esi]
		cmp al, '+'
		je operatorfound
		cmp al, '-'
		je operatorfound
		cmp al, '*'
		je operatorfound
		cmp al, '/'
		je operatorfound
		cmp al, '^'
		je operatorfound
		inc esi
		cmp al, 0
		je near nwcmd
		jmp num2
	operatorfound: push eax
		xor ah, ah
		mov [esi], ah
		mov edi, esi
		inc esi
		mov al, [esi]
		;cmp al, '$'
		;je near varnum1	;;unnecessary
		cmp al, '%'
		je near resultnum1
	varnum2: 
		push edi
		call checkdecimal
		pop edi
		call cnvrttxt
	vrnm2:
		mov ebx, ecx
		push ebx
		call clearbuffer
		mov esi, buftxt
		mov edi, esi
		inc esi
		mov al, [esi]
		cmp al, '%'
		je near resultnum2
	varnum4: 
		push edi
		call checkdecimal2
		pop edi
		call cnvrttxt
	vrnm4:
		pop ebx
		pop eax
		cmp al, '+'
		je near plusnum
		cmp al, '-'
		je near subnum
		cmp al, '*'
		je near mulnum
		cmp al, '/'
		je near divnum
		cmp al, '^'
		je near expnum
		jmp nwcmd
	resultnum1:
		mov cl, [decimalresult]
		mov [decimal], cl
		mov ecx, [result]
		jmp vrnm2
	resultnum2:
		mov cl, [decimal]
		mov [decimal2], cl
		mov cl, [decimalresult]
		mov [decimal], cl
		mov ecx, [result]
		jmp vrnm4
	checkdecimal2:
		mov ah, [decimal]
		mov [decimal2], ah
		xor ah, ah
		mov [decimal], ah
	checkdecimal:
		mov edi, esi
	chkdec1:
		mov al, [edi]
		cmp al, '.'
		je near fnddec
		cmp al, 0
		je near nodecimal
		inc edi
		jmp chkdec1
	fnddec:
		mov al, [edi + 1]
		mov [edi], al
		cmp al, 0
		je near nodecimal
		inc byte [decimal]
		inc edi
		jmp fnddec
	nodecimal:
		ret
	plusnum:
		call decaddfix
		add ecx, ebx
		jmp retnum
	subnum:
		call decaddfix
		sub ecx, ebx
		jmp retnum
	mulnum:
		mov al, [decimal2]
		add [decimal], al
		mov eax, ecx
		mul ebx
		mov ecx, eax
		jmp retnum
	divnum:
		call decaddfix
		xor al, al
		mov [decimal], al
		mov ax, cx
		cmp bl, 0
		je near retnum
		div bl
		xor ecx, ecx
		mov cl, al
		jmp retnum
	expnum:
		mov dl, [decimal]
		mov [decimal2], dl
		xor edx, edx
		mov eax, ecx
		mov ecx, ebx
		mov ebx, eax
		cmp ecx, 0
		je noexpnum
		dec ecx
		cmp ecx, 0
		je noexpnumlp
	expnumlp: mul ebx
		mov dl, [decimal2]
		add [decimal], dl
		xor edx, edx
		loop expnumlp
	noexpnumlp:
		mov ecx, eax
		jmp retnum
	noexpnum:
		mov ecx, 1
	retnum: 
		mov esi, numbuf
		mov [result], ecx
		call convert
		mov esi, numbuf
		mov ah, [decimal]
		mov [decimalresult], ah
		cmp ah, 0
		je near noputdecimal
	putdecimal:
		dec esi
		dec ah
		cmp ah, 0
		ja near putdecimal
		dec esi
		mov al, [esi]
		mov byte [esi], '.'
	decputloop:
		dec esi
		mov ah, [esi]
		mov [esi], al
		mov al, ah
		cmp esi, buf2
		ja near decputloop
	noputdecimal:
		mov esi, buf2
		call chkadd
		jmp nwcmd
edxnumbuf dw 0,0
	chkadd: mov al, [esi]
		cmp al, '0'
		jne dnadd
		inc esi
		cmp esi, numbuf
		je dnaddm1
		jmp chkadd
	dnaddm1: dec esi
	dnadd:	call print
		mov esi, line
		call print
		ret
		
	decaddfix:
		mov al, [decimal2]
		mov ah, [decimal]
		cmp al, ah
		je gooddecadd
		cmp al, ah
		jb lowdecadd
	highdecadd:
		inc ah
		mov edx, ecx
		shl ecx, 3
		add ecx, edx
		add ecx, edx
		cmp al, ah
		ja highdecadd
		mov [decimal], ah
		jmp gooddecadd
	lowdecadd:
		inc al
		mov edx, ebx
		shl ebx, 3
		add ebx, edx
		add ebx, edx
		cmp al, ah
		jb lowdecadd
		mov [decimal], al
	gooddecadd:
		ret
		
decimal db 0
decimal2 db 0
decimalresult db 0
result db 0,0,0,0
	
db 255,44,"%",0
	ans:	call clearbuffer
		mov ecx, [result]
		mov esi, buf2
		call convert
		mov esi, buf2
		call chkadd
		jmp nwcmd

db 255,44,"$",0
var: mov esi, buftxt
	mov ebx, variables
lkeq:	mov al, [esi]
	cmp al, '='
	je eqfnd	;is there an '=' sign?
	cmp al, 0
	je echovars
	inc esi
	jmp lkeq
echovars: mov esi, variables
	mov ebx, varend
	mov cl, 5
	mov ch, 4
	call array
	jmp nwcmd
eqfnd:	inc esi
	mov al, [esi]
	cmp al, 0
	je readvar
	mov esi, buftxt
	mov ebx, variables
	jmp seek
readvar:
	mov al, 10
	mov bx, 7
	mov byte [commandedit], 0
	mov edi, buftxtend
	call int305
	jmp var
seek:	mov ax, [ebx]
	mov cl, 5
	mov ch, 4
	cmp ax, 0
	je near save
	cmp ax, cx
	je skfnd
	inc ebx
	jmp seek
skfnd:	mov esi, buftxt
	inc esi
	add ebx, 2
	mov edi, ebx
	mov cl, '='
	call cndtest
	cmp al, 1	
	je varfnd
	mov ebx, edi
	mov esi, buftxt
	mov ax, [ebx]
	cmp ax, 0
	je near save
	inc ebx
	jmp seek
varfnd:	mov al, [ebx]
	cmp al, 4
	je save2
	dec ebx
	dec esi
	jmp varfnd
save2:	dec ebx
	dec esi
	mov al, [ebx]
	cmp al, 5
	je remove
	jmp varfnd
remove: mov al, [ebx]
	cmp al, 0
	je seek
	xor al, al
	mov [ebx], al
	inc ebx
	jmp remove	;do not need for now-need defragmentation
save:	mov esi, buftxt
	inc ebx
	mov al, 5
	mov ah, 4
	mov [ebx], ax
	inc ebx
svhere:	inc ebx
	inc esi
	mov al, [esi]
	cmp al, 0
	je near svdone
	cmp al, '%'
	je ans2
	mov [ebx], al	
	jmp svhere
ans2:	push esi
	mov esi, buf2
	call ansfnd
	call anscp
	pop esi
	jmp svhere
anscp:	mov al, [esi]
	mov [ebx], al
	cmp esi, numbuf
	je svhere
	cmp al, 0
	je svhere
	inc ebx
	inc esi
	jmp anscp
ansnf:	pop esi
	mov al, [esi]
	mov [ebx], al
	jmp svhere
ansfnd:	inc esi
	mov al, [esi]
	cmp al, 0
	je ansnf
	cmp al, '0'
	je ansfnd
	ret
svdone:	xor al, al
	mov [ebx], al
	jmp nwcmd
	
	db 255,44,"logout",0
logout:
	jmp os
	
	db 255,44,"reboot",0
rebootcomp:
	jmp coldboot

	db 255,44,"off",0
shutdowncomp:
	jmp shutdown

	db 255,44,"dos",0
rundosprog:
	mov edi, buftxt
	add edi, 4
	mov esi,  0x100 + dosprogloc	;this should be the beginning of memory
	call loadfile
	mov edi, buftxt
	add edi, 4
	cmp edx, 404
	je near dosnoprogfound
	mov ebx, 0x81 + dosprogloc
	xor ecx, ecx
finddosparams:
	mov al, [edi]
	inc edi
	cmp al, " "
	jne finddosparams
copydosparams:
	mov al, [edi]
	mov [ebx], al
	inc ebx
	inc edi
	inc ecx
	cmp ebx, 0x100 + dosprogloc
	jae nomoredosparams
	cmp al, 0
	jne copydosparams
nomoredosparams:
	mov [0x80 + dosprogloc], cl
	mov ax, DOS_DATA_SEL
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	xor eax, eax
	xor ebx, ebx
	xor ecx, ecx
	xor edx, edx
	xor edi, edi
	xor esi, esi
	jmp DOS_CODE_SEL:0x100
dosnoprogfound:
	mov esi, notfound1
	call print
	mov esi, buftxt
	add esi, 4
	call print
	mov esi, notfound2
	call print
	jmp nwcmd
	
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

	db 255,44,"rem",0	;this lets you rem stuff
	jmp nwcmd

	db 255,44,"system",0
	mov esi, systeminfomsg
	call printquiet
	mov ecx, osend
	shr ecx, 10
	call showdec
	mov esi, diskbytemsg
	call printquiet
	mov ecx, osend
	add ecx, commandbufend
	sub ecx, bssstart	;add the extra buffer space
	shr ecx, 10
	call showdec
	mov esi, membytemsg
	call print
	jmp nwcmd

systeminfomsg db "Kernel Information:",10,0
diskbytemsg db "KB Disk Space",10,0
membytemsg db "KB Memory",10,0
	
	db 255,44,"beep",0
	mov eax, beepstart
	mov [soundpos], eax
	mov eax, beepend
	mov [soundendpos], eax
	mov byte [soundon], 1
	jmp nwcmd
	
beepstart:
	dw 15, 4561
beepend:

	db 255,44,"while",0
whilecmd:  xor al, al
	cmp [BATCHISON], al
	je near notbatch
	mov esi, [BATCHPOS]
	sub esi, 2
whilefnd: dec esi
	mov al, [esi]
	cmp al, 10
	je near whilefnd2
	cmp al, 0
	je near whilefnd2
	jmp whilefnd
whilefnd2:
	inc esi
	mov [LOOPPOS], esi
	mov BYTE [LOOPON], 1
	mov esi, buftxt
	mov ebx, buftxt
	add ebx, 6
	jmp chkeqsn


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
	
	db 255,44,"else",0
elsecmd:	xor eax, eax
	mov al, [IFON]
	mov esi, IFTRUE
	add esi, eax
	mov al, [esi]
	xor al, 1
	mov [esi], al
	jmp nwcmd

	db 255,44,"loop",0
	cmp byte [LOOPON], 0
	jne near filoop
	jmp nwcmd
filoop: mov esi, [LOOPPOS]
	dec byte [IFON]
	mov byte [LOOPON], 0
	mov [BATCHPOS], esi
	mov [batchedi], esi
	jmp nwcmd
	

	db 255,44,"fi",0
	xor al, al
	cmp [BATCHISON], al
	je near notbatch
fi:	mov al, 1
	sub [IFON],al
	jmp nwcmd

	db 255,44,"stop",0
stop:	xor al, al
	mov [BATCHISON], al
	mov [IFON], al
	mov [IFTRUE], al
	mov [LOOPON], al
	jmp nwcmd
