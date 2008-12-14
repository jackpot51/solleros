filetypes db 5,4,6,4,7,4
progstart:		;programs start here
db 5,4,"index",0
	call indexfiles
	jmp nwcmd
indexfiles:
	mov si, progstart
	mov bx, fileindex
	mov di, progstart
	sub di, 2
indexloop:
	mov cx, [si]
	indexloop2:
		cmp cx, [di]
		je indexloop2done
		sub di, 2
		cmp di, filetypes
		jae indexloop2
	mov di, progstart
	sub di, 2
	inc si
	cmp si, batchprogend
	jae indexloopdone
	jmp indexloop
indexloop2done:
	mov [bx], cx
	add bx, 2
	add si, 2
	nameindex:
		mov cl, [si]
		cmp cl, 0
		je nameindexdone
		mov [bx], cl
		inc si
		inc bx
		jmp nameindex
	nameindexdone:
		inc bx
		mov word [bx], 0
		add bx, 2
		inc si
		mov [bx], si
		add bx, 2
		mov word [bx], 0
		add bx, 2
		cmp bx, customprograms
		jae indexloopdone
		add si, 1
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
		mov si, datmsg
		mov bx, 7
		mov al, 0
		int 30h
		jmp nwcmd

db 5,4,"tely",0		
	tely:
		mov si, line
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
		mov si, chartely
		cmp byte [chartely], 10
		je telyline
		cmp byte [chartely], 13
		je telyline
		cmp byte [chartely], 0Eh
		je novalidchartely
		jmp notelyline
	telyline:
		mov si, line
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
		mov si, chartely2
		cmp byte [chartely2], 10
		je telyline2
		cmp byte [chartely2], 13
		je telyline2
		cmp byte [chartely2], 0Eh
		je novalidchartely2
		jmp notelyline2
	telyline2:
		mov si, line
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
		mov si, line
		call print
		jmp nwcmd 

BASEADDRSERIAL dw 03f8h

db 5,4,"showindex",0
	mov si, fileindex
	mov bx, fileindexend
	mov cl, 5
	mov ch, 4
	call array
	mov si, fileindex
	mov bx, fileindexend
	mov cl, 6
	mov ch, 4
	call array
	mov si, fileindex
	mov bx, fileindexend
	mov cl, 7
	mov ch, 4
	call array
	jmp nwcmd
	
db 5,4,"dir",0
	dircmd:	jmp dir
	
db 5,4,"ls",0
	lscmd:	mov si, progstart
		mov bx, progend
		jmp dir

db 5,4,"uname",0
	uname:	mov si, unamemsg
		call print
		jmp nwcmd

db 5,4,"help",0
	help:	mov si, helpmsg
		call print
		jmp nwcmd

db 5,4,"logout",0
	logout:	jmp os

db 5,4,"clear",0
	cls:	call clear
		jmp nwcmd

db 5,4,"echo",0
	echo:	mov si, buftxt
		add si, 5
		mov al, [si]
		cmp al, '$'
		je echovr
		call print
		mov si, line
		call print
		jmp nwcmd
	echovr:	mov bx, variables
		mov di, 6
		call nxtvrech
		jmp prntvr2
	echvar:	mov cl, '='
		inc bx
		mov al, [bx]
		cmp al, 0
		je nxtvrech
		cmp al, '='
		je nxtvrechb1
		mov si, buftxt
		add si, di
		call cndtest
		cmp al, 2
		je prntvr
		cmp al, 1
		je prntvr
		mov si, buftxt
		add si, di
		jmp nxtvrech
	nxtvrechb1:
		sub bx, 2
		jmp echvar
	nxtvrech: mov al, [bx]
		cmp al, 5
		je nxtvrec2
		inc bx
		cmp bx, varend
		jae nwcmd
		jmp nxtvrech
	nxtvrec2: inc bx
		mov al, [bx]
		cmp al, 4
		je echvar
		jmp nxtvrech
	prntvr: inc bx
		mov si, bx
		ret
	prntvr2: call print
		mov si, line
		call print
		jmp nwcmd
	
db 5,4,"runbatch",0
	runbatch2:
		mov si, buftxt
		mov bx, batch
		mov di, commandlst
	findbatchrunloop:
		mov cl, 6
		mov ch, 4
		cmp [bx], cx
		je foundabatchrun
		inc bx
		cmp bx, di
		jae nobatchfoundrun
		jmp findbatchrunloop
	foundabatchrun:
		add bx, 2
		mov si, buftxt
		add si, 9
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
		mov si, buftxt
	    testshowbatch:
		mov al, [si]
		cmp al, ' '
		je batchprogshow
		cmp al, 0
		je batchlistshow
		inc si
		jmp testshowbatch
	   batchlistshow:
		mov si, batch
		mov bx, commandlst
		mov cl, 6
		mov ch, 4
		call array
		jmp nwcmd
	   batchprogshow:
		inc si
		mov bx, batch
	namefound2: mov al, 0
		cmp [si], al
		je batchlistshow
		mov cl, 6
		mov ch, 4
	findbatchname2:
		cmp bx, commandlst
		je notfoundbatchname2
		cmp [bx],cx
		je checkbatchname2
		inc bx
		jmp findbatchname2
	checkbatchname2:
		add bx, 2
		mov di, si
		call tester
		mov si, di
		cmp al, 1
		je showfoundbatch
		jmp findbatchname2
	showfoundbatch:
		mov si, bx
		inc si
		mov bx, commandlst
		mov cl, 3
		mov ch, 4
		call array
		jmp nwcmd
	    notfoundbatchnamemsg db "The batch specified was not found.",13,10,0
	notfoundbatchname2:
		mov si, notfoundbatchnamemsg
		call print
		jmp nwcmd
	
db 5,4,"showword",0
		mov si, buftxt
	    testshowword:
		mov al, [si]
		cmp al, ' '
		je wordprogshow
		cmp al, 0
		je wordlistshow
		inc si
		jmp testshowword
	   wordlistshow:
		mov si, wordst
		mov bx, commandlst
		mov cl, 7
		mov ch, 4
		call array
		jmp nwcmd
	   wordprogshow:
		inc si
		mov bx, wordst
	namefound3: mov al, 0
		cmp [si], al
		je wordlistshow
		mov cl, 7
		mov ch, 4
	findwordname:
		cmp bx, commandlst
		je notfoundwordname
		cmp [bx],cx
		je checkwordname
		inc bx
		jmp findwordname
	checkwordname:
		add bx, 2
		mov di, si
		call tester
		mov si, di
		cmp al, 1
		je showfoundword
		jmp findwordname
	showfoundword:
		mov si, bx
		inc si
		mov bx, commandlst
		mov cl, 3
		mov ch, 4
		call array
		jmp nwcmd
	    notfoundwordnamemsg db "The document specified was not found.",13,10,0
	notfoundwordname:
		mov si, notfoundwordnamemsg
		call print
		jmp nwcmd
	
db 5,4,"batch",0
	batchst: mov si, buftxt
		mov al, ' '
		mov bx, batch
	batchname: cmp [si], al
		   je namefound
		   cmp byte [si], 0
		   je nonamefound
		   inc si
		   jmp batchname
		nobatchname db "You have to type a name after the command.",10,13,0
	nonamefound:
		mov si, nobatchname
		call print
		jmp nwcmd
	namefound: mov al, 0
		inc si
		cmp [si], al
		je nonamefound
		mov cl, 6
		mov ch, 4
	findbatchname:
		cmp bx, commandlst
		jae goodbatchname
		cmp [bx],cx
		je checkbatchname
		inc bx
		jmp findbatchname
	checkbatchname:
		add bx, 2
		mov di, si
		call tester
		mov si, di
		cmp al, 1
		je badbatchname
		jmp findbatchname
		badbatchmsg db "This file already exists!",10,13,0
	badbatchname:
		mov si, badbatchmsg
		call print
		jmp nwcmd
	goodbatchname:
		mov bx, commandlst
		mov al, 0
	lastbatchfind:
		dec bx
		cmp [bx], al
		je lastbatchfind
		add bx, 2
	nameputbatch:
		mov byte [bx], 6
		inc bx
		mov byte [bx], 4
		inc bx
	nameputbatchlp:
		cmp byte [si], 0
		je nameputdone
		mov al, [si]
		mov [bx], al
		inc si
		inc bx
		jmp nameputbatchlp
	nameputdone:
		inc bx
		mov byte [bx], 0
		inc bx
	batchfile:
		push bx
		call input
		mov si, line
		call print
		mov si, buftxt
		mov bx, exitmsg
		call tester
		cmp al, 1
		je donebatch2
		pop bx
		mov si, buftxt
		mov al, 3
		mov [bx], al
		inc bx
		mov al, 4
		mov [bx], al
		inc bx
	startbatch: mov al, [si]
		mov [bx], al
		inc bx
		inc si
		cmp al, 0
		je batchfile
		jmp startbatch
	donebatch2:
		pop bx
		mov cl, 4
		mov [bx], cl
		inc bx
		mov ch, 3
		mov [bx], ch
		mov si, batchmsg
		call print
		jmp nwcmd
	donebatch:
		call buftxtclear
		mov si, buftxt
	batchfind: mov al, [bx]
		cmp al, 3
		je batchnext
		cmp al, 4
		je batchendtest
		cmp bx, commandlst
		jae backtonwcmd
		inc bx
		jmp batchfind
	batchendtest:
		inc bx
		mov al, [bx]
		cmp al, 3
		je backtonwcmdtest
		jmp batchfind
	backtonwcmdtest:
		inc bx
		mov al, [bx]
		cmp al, 0
		je backtonwcmd
		dec bx
		jmp batchfind
	batchnext:
		mov si, buftxt
		inc bx
		mov al, [bx]
		cmp al, 4
		je batchfound
		cmp bx, commandlst
		jae backtonwcmd
		jmp batchfind
	batchfound:
		inc bx
		mov al, [bx]
		mov [si], al
		inc si
		cmp al, 0
		je runbatch
		cmp bx, commandlst
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
		mov [BATCHPOS], bx
		mov si, buftxt
		mov ah, [IFON]
		cmp ah, 1
		jae ifit
	brun:	jmp progtest
	ifit:	mov al, [si]
		cmp al, 'f'
		je ifit2
		cmp al, 'e'
		je ifelse
	ifitst:	mov ah, 0
		mov al, [IFON]
		mov di, IFTRUE
		add di, ax 
		mov cl, 1
		cmp [di],cl
		je brun2
		jmp batchfind
	brun2:	mov [BATCHPOS], bx
		jmp brun
	ifit2:	inc si
		mov al, [si]
		cmp al, 'i'
		je ifit3
		dec si
		jmp ifitst
	ifelse:	inc si
		mov al, [si]
		cmp al, 'l'
		je ifelse2
		dec si
		jmp ifitst
	ifelse2:	inc si
		mov al, [si]
		cmp al, 's'
		je ifelse3
		dec si
		dec si
		jmp ifitst
	ifelse3:	inc si
		mov al, [si]
		cmp al, 'e'
		je ifelse4
		dec si
		dec si
		dec si
		jmp ifitst
	ifelse4: dec si
		dec si
		dec si
		jmp brun2
	ifit3:	dec si
		jmp brun2
		
	batchran: 
		call buftxtclear
		mov bx, [BATCHPOS]
		jmp batchfind

	exitword db "\x",0
	wordmsg db "Type \x to exit.",10,13,0

db 5,4,"word",0
		mov si, wordmsg
		call print
	        mov si, buftxt
		mov al, ' '
		mov bx, wordst
	wordname: cmp [si], al
		   je namefound4
		   cmp byte [si], 0
		   je nonamefound4
		   inc si
		   jmp wordname
		nowordname db "You have to type a name after the command.",10,13,0
	nonamefound4:
		mov si, nowordname
		call print
		jmp nwcmd
	namefound4: mov al, 0
		inc si
		cmp [si], al
		je nonamefound4
		mov cl, 7
		mov ch, 4
	findwordname3:
		cmp bx, commandlst
		jae goodwordname
		cmp [bx],cx
		je checkwordname3
		inc bx
		jmp findwordname3
	checkwordname3:
		add bx, 2
		mov di, si
		call tester
		mov si, di
		cmp al, 1
		je badwordname
		jmp findwordname3
		badwordmsg db "This file already exists!",10,13,0
	badwordname:
		mov si, badwordmsg
		call print
		jmp nwcmd
	goodwordname:
		mov bx, commandlst
		mov al, 0
	lastwordfind:
		dec bx
		cmp [bx], al
		je lastwordfind
		add bx, 2
	nameputword:
		mov byte [bx], 7
		inc bx
		mov byte [bx], 4
		inc bx
	nameputwordlp:
		cmp byte [si], 0
		je nameputworddone
		mov al, [si]
		mov [bx], al
		inc si
		inc bx
		jmp nameputwordlp
	nameputworddone:
		inc bx
		mov byte [bx], 0
		inc bx
		mov si, bx
	wordlp: mov byte [si], 3
		inc si
		mov byte [si], 4
		inc si
		push si
		call input
		mov si, exitword
		mov bx, buftxt
		call tester
		cmp al, 1
		je doneword2
		mov si, line
		call print
		mov di, buftxt
		pop si
	wordlp2: cmp si, commandlst
		jae doneword 
		mov al, [di]
		mov [si], al
		inc si
		cmp al, 0
		je wordlp
		inc di
		jmp wordlp2
	doneword2: 
		mov si, line
		call print
		pop si
		inc si
		mov cl, 4
		mov ch, 3
		mov [si], cx
		jmp nwcmd 
		
	doneword: sub si, 3
		mov cl, 4
		mov ch, 3
		mov [si], cx
		add si, 2
		mov byte [si], 0 
		jmp nwcmd

db 5,4,"#",0
	num:	
		mov [edxnumbuf], edx
		call clearbuffer
		mov si, buftxt
		mov eax, 0
		mov ecx, 0
		mov ebx, 0
	num2:	mov al, [si]
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
		inc si
		cmp al, 0
		je nwcmd
		jmp num2
	operatorfound: mov [eaxcachenum], eax
		mov ah, 0
		mov [si], ah
		inc si
		mov al, [si]
		cmp al, '$'
		je varnum1
		jmp varnum2
	ebxcachenum dw 0,0
	eaxcachenum dw 0,0
	varnum2: 
		call cnvrttxt
		mov ebx, ecx
		mov [ebxcachenum], ebx
		call clearbuffer
		mov si, buftxt
		inc si
		mov al, [si]
		cmp al, '$'
		je varnum3
	varnum4: 
		call cnvrttxt
		mov ebx, [ebxcachenum]
		mov eax, [eaxcachenum]
		cmp al, '+'
		je plusnum
		cmp al, '-'
		je subnum
		cmp al, '*'
		je mulnum
		cmp al, '/'
		je divnum2
		cmp al, '^'
		je expnum2
	expnum2: jmp expnum
	divnum2: jmp divnum
	varnum1: sub si, buftxt
		mov di, si
		add si, buftxt
		inc di
		mov bx, variables
		call nxtvrech
		jmp varnum2
	varnum3: sub si, buftxt
		mov di, si
		add si, buftxt
		inc di
		mov bx, variables
		call nxtvrech
		jmp varnum4
	plusnum:
		add ecx, ebx
		jmp retnum
	subnum:
		sub ecx, ebx
		jmp retnum
	mulnum:
		mov eax, ecx
		mul ebx
		mov ecx, eax
		jmp retnum
	divnum:
		mov ax, cx
		cmp bl, 0
		je retnum
		div bl
		mov ecx, 0
		mov cl, al
		jmp retnum
	expnum:
		mov eax, ecx
		mov ecx, ebx
		mov ebx, eax
		dec ecx
	expnumlp: mul ebx
		loop expnumlp
		mov ecx, eax
		jmp retnum
	retnum: 
		mov edx, [edxnumbuf]
		mov si, numbuf
		call convert
		mov si, buf2
		call chkadd
		jmp nwcmd
edxnumbuf dw 0,0
	chkadd: mov al, [si]
		cmp al, '0'
		jne dnadd
		inc si
		cmp si, numbuf
		je dnaddm1
		jmp chkadd
	dnaddm1: dec si
	dnadd:	call print
		mov si, line
		call print
		ret
	
db 5,4,"%",0
	ans:	mov si, buf2
		call chkadd
		jmp nwcmd

db 5,4,"$",0
var:	mov si, buftxt
	mov bx, variables
lkeq:	mov al, [si]
	cmp al, '='
	je eqfnd	;is there an '=' sign?
	cmp al, 0
	je echovars
	inc si
	jmp lkeq
echovars: mov si, variables
	mov bx, varend
	mov cl, 5
	mov ch, 4
	call array
	jmp nwcmd
eqfnd:	inc si
	mov al, [si]
	cmp al, 0
	je readvar
	mov si, buftxt
	mov bx, variables
	jmp seek
readvar: call stdin
	mov si, line
	call print
	jmp var
seek:	mov al, [bx]
	cmp al, 0
	je save1
	cmp al, 5
	je skfnd
	inc bx
	jmp seek
skfnd:	inc bx
	mov al, [bx]
	cmp al, 0
	je save1
	cmp al, 4
	je skfnd2
	inc bx
	jmp skfnd
skfnd2:	mov si, buftxt
	inc si
	inc bx
	mov cl, '='
	call cndtest
	cmp al, 1	
	je varfnd
	mov si, buftxt
	inc bx
	mov al, [bx]
	cmp al, 0
	je save
	jmp seek
save1:	inc bx
	mov al, [bx]
	cmp al, 0
	je save
	jmp seek
varfnd:	mov al, [bx]
	cmp al, 4
	je save2
	dec bx
	dec si
	jmp varfnd
save2:	dec bx
	dec si
	mov al, [bx]
	cmp al, 5
	je remove
	jmp varfnd
remove: mov al, [bx]
	cmp al, 0
	je seek
	mov al, 0
	mov [bx], al
	inc bx
	jmp remove	;do not need for now-need defragmentation
save:	mov si, buftxt
	mov al, 5
	mov [bx], al
	inc bx
	mov al, 4
	mov [bx], al
	jmp svhere
svhere:	inc bx
	inc si
	mov al, [si]
	cmp al, 0
	je svdone
	cmp al, '%'
	je ans2
	 mov [bx], al	
	jmp svhere
ans2:	push si
	mov si, buf2
	call ansfnd
	call anscp
	pop si
	jmp svhere
anscp:	mov al, [si]
	mov [bx], al
	cmp si, numbuf
	je svhere
	cmp al, 0
	je svhere
	inc bx
	inc si
	jmp anscp
ansnf:	pop si
	mov al, [si]
	mov [bx], al
	jmp svhere
ansfnd:	inc si
	mov al, [si]
	cmp al, 0
	je ansnf
	cmp al, '0'
	je ansfnd
	ret
svdone:	mov al, 0
	mov [bx], al
	jmp nwcmd
