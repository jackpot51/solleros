filetypes db 5,4,6,4,7,4
progstart:		;programs start here
db 5,4,"index",0
	call indexfiles
	jmp nwcmd
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
		add ebx, 2
		mov word [ebx], 0
		add ebx, 2
		cmp ebx, customprograms
		jae indexloopdone
		add esi, 1
		jmp indexloop
indexloopdone: 	ret
com dw 0

;db 5,4,"internet",0
datmsg: db "Internet has not been implemented yet.",10,13,0
	internettest: 			;;initialize network card, lets hope this is right
					;;^^used to^^, now tests int30h functions
;		jmp packettest
		mov ah, 3
		int 30h
		mov ah, 1
		mov esi, datmsg
		mov bx, 7
		mov al, 0
		int 30h
		jmp nwcmd

db 5,4,"tely",0		
	tely:
		mov esi, line
		call print
		mov [olddx], dx
		mov ecx, 0
		mov edx, 0
		mov eax, 0
	      	mov dx, [BASEADDRSERIAL]		;;initialize serial
		mov al, 0
		add dx, 1
		out dx, al
	      	mov dx, [BASEADDRSERIAL]
		mov al, 80h
		add dx, 3
		out dx, al
	      	mov dx, [BASEADDRSERIAL]
		mov al, 3
		out dx, al
		add dx, 1
		mov al, 0
		out dx, al
	      	mov dx, [BASEADDRSERIAL]
		mov al, 3
		add dx, 3
		out dx, al
	      	mov dx, [BASEADDRSERIAL]
		mov al, 0c7h
		add dx, 2
		out dx, al
	      	mov dx, [BASEADDRSERIAL]
		mov al, 0Bh
		add dx, 4
		out dx, al
		mov cx, 1000
	telyreceive:
		mov ax, 0
		mov dx, [BASEADDRSERIAL]		;;wait until char received or keyboard pressed
		add dx, 5
		in al, dx
		cmp al, 1
		je telyreceive2
		loop telyreceive
		mov al, 23
		call int30hah5
		mov ah, [charcache]
		mov al, 0
		mov cx, 100
		cmp ah, 13
		jne telysend
		mov ah, 10
		jmp telysend
	nullchar db 0,0

	telyreceive2:
		mov dx, [BASEADDRSERIAL]
		in al, dx
		mov [chartely], al
		mov dx, [olddx]
		mov esi, chartely
		cmp byte [chartely], 10
		je telyline
		cmp byte [chartely], 13
		je telyline
		cmp byte [chartely], 0Eh
		je novalidchartely
		jmp notelyline
	telyline:
		mov esi, line
	notelyline:
		mov bx, 7
		mov ax, 0
		call int30hah1
	novalidchartely:
		mov [olddx], dx
		mov cx, 1000
		jmp telyreceive
		
		chartely db 0,0,0
		chartely2 db 0,0,0

	telysend:
		mov dx, [BASEADDRSERIAL]		;;wait until transmit is empty
		add dx, 5
		in al, dx
		cmp al, 20h
		jne telysend2
		loop telysend
	telysend2:	
		mov [chartely2], ah				;;send ASCII
		mov al, ah
		mov dx, [BASEADDRSERIAL]
		out dx, al
		mov cx, 1000
		cmp al, 0
		je telyreceive
		mov dx, [olddx]
		mov esi, chartely2
		cmp byte [chartely2], 10
		je telyline2
		cmp byte [chartely2], 13
		je telyline2
		cmp byte [chartely2], 0Eh
		je novalidchartely2
		jmp notelyline2
	telyline2:
		mov esi, line
	notelyline2:
		mov ax, 0
		mov bx, 0f8h
		call int30hah1
	novalidchartely2:
		mov [olddx], dx
		mov cx, 1000
		jmp telyreceive
	donetely:
		mov dx, [olddx]
		mov esi, line
		call print
		jmp nwcmd 

BASEADDRSERIAL dw 03f8h

db 5,4,"showindex",0
	mov esi, fileindex
	mov ebx, fileindexend
	mov cl, 5
	mov ch, 4
	call array
	mov esi, fileindex
	mov ebx, fileindexend
	mov cl, 6
	mov ch, 4
	call array
	mov esi, fileindex
	mov ebx, fileindexend
	mov cl, 7
	mov ch, 4
	call array
	jmp nwcmd
	
db 5,4,"dir",0
	dircmd:	jmp dir
	
db 5,4,"ls",0
	lscmd:	mov esi, progstart
		mov ebx, progend
		jmp dir

db 5,4,"disk",0
		mov esi, diskfileindex
	diskindexdir:
		call print
		mov edi, esi
		mov esi, line
		call print
		mov esi, edi
		add esi, 9
		cmp esi, enddiskfileindex
		jb diskindexdir
		jmp nwcmd
		
db 5,4,"uname",0
	uname:	mov esi, unamemsg
		call print
		jmp nwcmd

db 5,4,"help",0
	help:	mov esi, helpmsg
		call print
		jmp nwcmd

db 5,4,"logout",0
	logout:	jmp os

db 5,4,"clear",0
	cls:	call clear
		jmp nwcmd

db 5,4,"echo",0
	echo:	mov esi, buftxt
		add esi, 5
		mov al, [esi]
		cmp al, '$'
		je echovr
		call print
		mov esi, line
		call print
		jmp nwcmd
	echovr:	mov bx, variables
		mov edi, 6
		call nxtvrech
		jmp prntvr2
	echvar:	mov cl, '='
		inc bx
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
		jae nwcmd
		jmp nxtvrech
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
	
db 5,4,"runbatch",0
	runbatch2:
		mov esi, buftxt
		mov ebx, batch
		mov edi, commandlst
	findbatchrunloop:
		mov cl, 6
		mov ch, 4
		cmp [ebx], cx
		je foundabatchrun
		inc ebx
		cmp ebx, edi
		jae nobatchfoundrun
		jmp findbatchrunloop
	foundabatchrun:
		add ebx, 2
		mov esi, buftxt
		add esi, 9
		call tester
		cmp al, 1
		je foundgoodbatchrun
		jmp findbatchrunloop
	foundgoodbatchrun:
		mov byte [BATCHISON], 1
		jmp donebatch
	nobatchfoundrun:
		jmp nwcmd
	
db 5,4,"showbatch",0
	showbatch:
		mov esi, buftxt
	    testshowbatch:
		mov al, [esi]
		cmp al, ' '
		je batchprogshow
		cmp al, 0
		je batchlistshow
		inc esi
		jmp testshowbatch
	   batchlistshow:
		mov esi, batch
		mov bx, commandlst
		mov cl, 6
		mov ch, 4
		call array
		jmp nwcmd
	   batchprogshow:
		inc esi
		mov ebx, batch
	namefound2: mov al, 0
		cmp [esi], al
		je batchlistshow
		mov cl, 6
		mov ch, 4
	findbatchname2:
		cmp ebx, commandlst
		je notfoundbatchname2
		cmp [ebx],cx
		je checkbatchname2
		inc ebx
		jmp findbatchname2
	checkbatchname2:
		add ebx, 2
		mov edi, esi
		call tester
		mov esi, edi
		cmp al, 1
		je showfoundbatch
		jmp findbatchname2
	showfoundbatch:
		mov esi, ebx
		inc esi
		mov bx, commandlst
		mov cl, 3
		mov ch, 4
		call array
		jmp nwcmd
	    notfoundbatchnamemsg db "The batch specified was not found.",13,10,0
	notfoundbatchname2:
		mov esi, notfoundbatchnamemsg
		call print
		jmp nwcmd
	
db 5,4,"showword",0
		mov esi, buftxt
	    testshowword:
		mov al, [esi]
		cmp al, ' '
		je wordprogshow
		cmp al, 0
		je wordlistshow
		inc esi
		jmp testshowword
	   wordlistshow:
		mov esi, wordst
		mov bx, commandlst
		mov cl, 7
		mov ch, 4
		call array
		jmp nwcmd
	   wordprogshow:
		inc esi
		mov ebx, wordst
	namefound3: mov al, 0
		cmp [esi], al
		je wordlistshow
		mov cl, 7
		mov ch, 4
	findwordname:
		cmp ebx, commandlst
		je notfoundwordname
		cmp [ebx],cx
		je checkwordname
		inc ebx
		jmp findwordname
	checkwordname:
		add ebx, 2
		mov edi, esi
		call tester
		mov esi, edi
		cmp al, 1
		je showfoundword
		jmp findwordname
	showfoundword:
		mov esi, ebx
		inc esi
		mov ebx, commandlst
		mov cl, 3
		mov ch, 4
		call array
		jmp nwcmd
	    notfoundwordnamemsg db "The document specified was not found.",13,10,0
	notfoundwordname:
		mov esi, notfoundwordnamemsg
		call print
		jmp nwcmd
	
db 5,4,"batch",0
	batchst: mov esi, buftxt
		mov al, ' '
		mov ebx, batch
	batchname: cmp [esi], al
		   je namefound
		   cmp byte [esi], 0
		   je nonamefound
		   inc esi
		   jmp batchname
		nobatchname db "You have to type a name after the command.",10,13,0
	nonamefound:
		mov esi, nobatchname
		call print
		jmp nwcmd
	namefound: mov al, 0
		inc esi
		cmp [esi], al
		je nonamefound
		mov cl, 6
		mov ch, 4
	findbatchname:
		cmp ebx, commandlst
		jae goodbatchname
		cmp [ebx],cx
		je checkbatchname
		inc ebx
		jmp findbatchname
	checkbatchname:
		add ebx, 2
		mov edi, esi
		call tester
		mov esi, edi
		cmp al, 1
		je badbatchname
		jmp findbatchname
		badbatchmsg db "This file already exists!",10,13,0
	badbatchname:
		mov esi, badbatchmsg
		call print
		jmp nwcmd
	goodbatchname:
		mov ebx, commandlst
		mov al, 0
	lastbatchfind:
		dec ebx
		cmp [ebx], al
		je lastbatchfind
		add ebx, 2
	nameputbatch:
		mov byte [ebx], 6
		inc ebx
		mov byte [ebx], 4
		inc ebx
	nameputbatchlp:
		cmp byte [esi], 0
		je nameputdone
		mov al, [esi]
		mov [ebx], al
		inc esi
		inc ebx
		jmp nameputbatchlp
	nameputdone:
		inc ebx
		mov byte [ebx], 0
		inc ebx
	batchfile:
		push ebx
		call input
		mov esi, line
		call print
		mov esi, buftxt
		mov ebx, exitmsg
		call tester
		cmp al, 1
		je donebatch2
		pop ebx
		mov esi, buftxt
		mov al, 3
		mov [ebx], al
		inc ebx
		mov al, 4
		mov [ebx], al
		inc ebx
	startbatch: mov al, [esi]
		mov [ebx], al
		inc ebx
		inc esi
		cmp al, 0
		je batchfile
		jmp startbatch
	donebatch2:
		pop ebx
		mov cl, 4
		mov [ebx], cl
		inc ebx
		mov ch, 3
		mov [ebx], ch
		mov esi, batchmsg
		call print
		jmp nwcmd
	donebatch:
		call buftxtclear
		mov esi, buftxt
	batchfind: mov al, [ebx]
		cmp al, 3
		je batchnext
		cmp al, 4
		je batchendtest
		cmp ebx, commandlst
		jae backtonwcmd
		inc ebx
		jmp batchfind
	batchendtest:
		inc ebx
		mov al, [ebx]
		cmp al, 3
		je backtonwcmdtest
		jmp batchfind
	backtonwcmdtest:
		inc ebx
		mov al, [ebx]
		cmp al, 0
		je backtonwcmd
		dec ebx
		jmp batchfind
	batchnext:
		mov esi, buftxt
		inc ebx
		mov al, [ebx]
		cmp al, 4
		je batchfound
		cmp ebx, commandlst
		jae backtonwcmd
		jmp batchfind
	batchfound:
		inc ebx
		mov al, [ebx]
		mov [esi], al
		inc esi
		cmp al, 0
		je runbatch
		cmp ebx, commandlst
		jae backtonwcmd
		jmp batchfound
	backtonwcmd:
		mov al, [BATCHISON]
		dec al
		mov [BATCHISON], al
		call buftxtclear
		jmp nwcmd
	runbatch:
		mov al, [BATCHISON]
		inc al
		mov [BATCHISON], al
		mov [BATCHPOS], ebx
		mov esi, buftxt
		mov ah, [IFON]
		cmp ah, 1
		jae ifit
	brun:	jmp progtest
	ifit:	mov al, [esi]
		cmp al, 'f'
		je ifit2
		cmp al, 'e'
		je ifelse
	ifitst:	mov eax, 0
		mov al, [IFON]
		mov edi, IFTRUE
		add edi, eax 
		mov cl, 1
		cmp [edi],cl
		je brun2
		jmp batchfind
	brun2:	mov [BATCHPOS], ebx
		jmp brun
	ifit2:	inc esi
		mov al, [esi]
		cmp al, 'i'
		je ifit3
		dec esi
		jmp ifitst
	ifelse:	inc esi
		mov al, [esi]
		cmp al, 'l'
		je ifelse2
		dec esi
		jmp ifitst
	ifelse2:	inc esi
		mov al, [esi]
		cmp al, 's'
		je ifelse3
		dec esi
		dec esi
		jmp ifitst
	ifelse3:	inc esi
		mov al, [esi]
		cmp al, 'e'
		je ifelse4
		dec esi
		dec esi
		dec esi
		jmp ifitst
	ifelse4: dec esi
		dec esi
		dec esi
		jmp brun2
	ifit3:	dec esi
		jmp brun2
		
	batchran: 
		call buftxtclear
		mov ebx, [BATCHPOS]
		jmp batchfind

	exitword db "\x",0
	wordmsg db "Type \x to exit.",10,13,0

db 5,4,"word",0
		mov esi, wordmsg
		call print
	        mov esi, buftxt
		mov al, ' '
		mov ebx, wordst
	wordname: cmp [esi], al
		   je namefound4
		   cmp byte [esi], 0
		   je nonamefound4
		   inc esi
		   jmp wordname
		nowordname db "You have to type a name after the command.",10,13,0
	nonamefound4:
		mov esi, nowordname
		call print
		jmp nwcmd
	namefound4: mov al, 0
		inc esi
		cmp [esi], al
		je nonamefound4
		mov cl, 7
		mov ch, 4
	findwordname3:
		cmp ebx, commandlst
		jae goodwordname
		cmp [ebx],cx
		je checkwordname3
		inc ebx
		jmp findwordname3
	checkwordname3:
		add ebx, 2
		mov edi, esi
		call tester
		mov esi, edi
		cmp al, 1
		je badwordname
		jmp findwordname3
		badwordmsg db "This file already exists!",10,13,0
	badwordname:
		mov esi, badwordmsg
		call print
		jmp nwcmd
	goodwordname:
		mov ebx, commandlst
		mov al, 0
	lastwordfind:
		dec ebx
		cmp [ebx], al
		je lastwordfind
		add ebx, 2
	nameputword:
		mov byte [ebx], 7
		inc ebx
		mov byte [ebx], 4
		inc ebx
	nameputwordlp:
		cmp byte [esi], 0
		je nameputworddone
		mov al, [esi]
		mov [ebx], al
		inc esi
		inc ebx
		jmp nameputwordlp
	nameputworddone:
		inc ebx
		mov byte [ebx], 0
		inc ebx
		mov esi, ebx
	wordlp: mov byte [esi], 3
		inc esi
		mov byte [esi], 4
		inc esi
		push esi
		call input
		mov esi, exitword
		mov ebx, buftxt
		call tester
		cmp al, 1
		je doneword2
		mov esi, line
		call print
		mov edi, buftxt
		pop esi
	wordlp2: cmp esi, commandlst
		jae doneword 
		mov al, [edi]
		mov [esi], al
		inc esi
		cmp al, 0
		je wordlp
		inc edi
		jmp wordlp2
	doneword2: 
		mov esi, line
		call print
		pop esi
		inc esi
		mov cl, 4
		mov ch, 3
		mov [esi], cx
		jmp nwcmd 
		
	doneword: sub esi, 3
		mov cl, 4
		mov ch, 3
		mov [esi], cx
		add esi, 2
		mov byte [esi], 0 
		jmp nwcmd
		
db 5,4,"showbmp",0
		mov [cxbmpch], cx
		mov [dxbmpch], dx
		mov edi, buftxt
		add edi, 8
		mov esi, 0x100000
		call loadfile
		mov esi, 0x100000
		mov ecx, 0
		mov edx, 0
		mov eax, 0
		mov ebx, 0
		call showbmp
		mov cx, [cxbmpch]
		mov dx, [dxbmpch]
		mov al, 0
		call int30hah5
		mov esi, buftxt
		add esi, 8
		call print
		mov esi, loadedbmpmsg
		call print
		jmp nwcmd

db 5,4,"showtxt",0
		mov [cxbmpch], cx
		mov [dxbmpch], dx
		mov edi, buftxt
		add edi, 8
		mov esi, 0x100000
		call loadfile
		mov cx, [cxbmpch]
		mov dx, [dxbmpch]
		mov esi, 0x100000
		call print
		mov esi, line
		call print
		jmp nwcmd
		
cxbmpch dw 0
dxbmpch dw 0
loadedbmpmsg db " loaded.",13,10,0

db 5,4,"#",0
	num:	
		mov [edxnumbuf], edx
		call clearbuffer
		mov byte [decimal], 0
		mov byte [decimal2], 0
		mov esi, buftxt
		mov eax, 0
		mov ecx, 0
		mov ebx, 0
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
	operatorfound: mov [eaxcachenum], eax
		mov ah, 0
		mov [esi], ah
		inc esi
		mov al, [esi]
		cmp al, '$'
		je near varnum1
		cmp al, '%'
		je near resultnum1
		jmp varnum2
	ebxcachenum dw 0,0
	eaxcachenum dw 0,0
	varnum2: 
		call checkdecimal
		call cnvrttxt
	vrnm2:
		mov ebx, ecx
		mov [ebxcachenum], ebx
		call clearbuffer
		mov esi, buftxt
		inc esi
		mov al, [esi]
		cmp al, '$'
		je near varnum3
		cmp al, '%'
		je near resultnum2
	varnum4: 
		call checkdecimal2
		call cnvrttxt
	vrnm4:
		mov ebx, [ebxcachenum]
		mov eax, [eaxcachenum]
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
		mov ecx, [result]
		jmp vrnm2
	resultnum2:
		mov ecx, [result]
		jmp vrnm4
	varnum1: sub esi, buftxt
		mov edi, esi
		add esi, buftxt
		inc edi
		mov ebx, variables
		call nxtvrech
		jmp varnum2
	varnum3: sub esi, buftxt
		mov edi, esi
		add esi, buftxt
		inc edi
		mov ebx, variables
		call nxtvrech
		jmp varnum4
	checkdecimal2:
		mov ah, [decimal]
		mov [decimal2], ah
		mov ah, 0
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
		mov al, 0
		mov [decimal], al
		mov ax, cx
		cmp bl, 0
		je near retnum
		div bl
		mov ecx, 0
		mov cl, al
		jmp retnum
	expnum:
		mov dl, [decimal]
		mov [decimal2], dl
		mov edx, 0
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
		mov edx, 0
		loop expnumlp
	noexpnumlp:
		mov ecx, eax
		jmp retnum
	noexpnum:
		mov ecx, 1
	retnum: 
		mov edx, [edxnumbuf]
		mov esi, numbuf
		mov [result], ecx
		call convert
		mov esi, numbuf
		mov ah, [decimal]
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
result db 0,0,0,0
	
db 5,4,"%",0
	ans:	call clearbuffer
		mov ecx, [result]
		mov esi, buf2
		call convert
		mov esi, buf2
		call chkadd
		jmp nwcmd

db 5,4,"$",0
var:	mov esi, buftxt
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
readvar: call stdin
	mov esi, line
	call print
	jmp var
seek:	mov al, [ebx]
	cmp al, 0
	je save1
	cmp al, 5
	je skfnd
	inc ebx
	jmp seek
skfnd:	inc ebx
	mov al, [ebx]
	cmp al, 0
	je save1
	cmp al, 4
	je skfnd2
	inc ebx
	jmp skfnd
skfnd2:	mov esi, buftxt
	inc esi
	inc ebx
	mov cl, '='
	call cndtest
	cmp al, 1	
	je varfnd
	mov esi, buftxt
	inc ebx
	mov al, [ebx]
	cmp al, 0
	je save
	jmp seek
save1:	inc ebx
	mov al, [ebx]
	cmp al, 0
	je save
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
	mov al, 0
	mov [ebx], al
	inc ebx
	jmp remove	;do not need for now-need defragmentation
save:	mov esi, buftxt
	mov al, 5
	mov [ebx], al
	inc ebx
	mov al, 4
	mov [ebx], al
	jmp svhere
svhere:	inc ebx
	inc esi
	mov al, [esi]
	cmp al, 0
	je svdone
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
svdone:	mov al, 0
	mov [ebx], al
	jmp nwcmd