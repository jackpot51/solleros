vga db 0
realmodeprogs:
db 5,4,"vga",0
	mov BYTE [vga], 1
	mov ax, 12h
	int 10h
	jmp nwcmd

db 5,4,"etch-a-sketch",0
	eas:	jmp etch
		iret

db 5,4,"cga",0
	cga:	mov BYTE [vga], 0
		mov ax, 3h
		int 10h
		iret

	
;db 5,4,"time",0
	time:	call clearbuffer
		mov ah, 2
		int 1Ah
		mov cl, ch
		mov ch, 0
		mov si, numbuf
		call convert	
		mov si, buf2
		call chkadd
		mov si, line
		call print
		call clearbuffer
		mov ah, 2
		int 1Ah
		mov ch, 0
		mov si, numbuf
		call convert	
		mov si, buf2
		call chkadd
		mov si, line
		call print
		iret

db 5,4,"dos",0
		mov si, dosmode
		call print
		call dos
		iret

db 5,4,"mouse",0
		jmp mouse
		iret

progstart:		;programs start here

db 5,4,"showcopy",0
	mov si, copybuffer
	call print
	mov si, line
	call print
	jmp nwcmd
	
db 5,4,"dir",0
	dircmd:	jmp dir
	
db 5,4,"ls",0
	lscmd:	mov si, progstart
		mov bx, progend
		jmp dir	
	
db 5,4,"menu",0
	bckmnu: call clear
		call begin
		jmp menu

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

db 5,4,"universe",0
	universe: mov si, universe1
		call print
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
	
db 5,4,"math",0
		mov si, mathmsg
		call print
	math:	mov si, mathmsg2
		call print
		call input
		mov si, line
		call print
		mov si, buftxt
		mov bx, exitmsg
		call tester
		cmp al, 1
		je nwcmd
		jmp adder
		jmp math
	adder:	mov si, number1
		call print
		call clearbuffer
		call input
		mov si, buftxt
		mov al, [si]
		cmp al, '$'
		je varadd1
	vraddn1: call cnvrttxt
		mov ebx, ecx
		push ebx
		mov si, line
		call print
		mov si, number2
		call print
		call clearbuffer
		call input
		mov si, buftxt
		mov al, [si]
		cmp al, '$'
		je varadd2
	vraddn2: call cnvrttxt
		push ecx
		mov si, operandmsg
		call print
		call input
		mov si, buftxt
		mov al, [si]
		cmp al, '+'
		je addit
		cmp al, '-'
		je subit
		cmp al, '*'
		je mulit2
		cmp al, '/'
		je divit2
		cmp al, '^'
		je expit2
		mov si, line
		call print
		jmp math
	expit2: jmp expit
	divit2: jmp divit
	mulit2:	jmp mulit
	varadd1: mov di, 1
		mov bx, variables
		call nxtvrech
		jmp vraddn1
	varadd2: mov di, 1
		mov bx, variables
		call nxtvrech
		jmp vraddn2
	addit:	pop ebx
		pop ecx
		add ecx, ebx
		cmp ecx, 0
		je zerocx
		mov si, numbuf
		call convert
		mov si, line
		call print
		mov si, buf2
		call chkadd
		jmp math
	subit:	pop ebx
		pop ecx
		sub ecx, ebx
		cmp ecx, 0
		je zerocx
		mov si, numbuf
		call convert
		mov si, line
		call print
		mov si, buf2
		call chkadd
		jmp math
	zerocx: mov si, line
		call print
		call clearbuf
		mov si, zeromsg
		call print
		jmp math
	mulit:	pop ebx
		pop ecx
		mov eax, ecx
		mul bx
		mov ecx, eax
		cmp ecx, 0
		je zerocx
		mov si, numbuf
		call convert
		mov si, line
		call print
		mov si, buf2
		call chkadd
		jmp math
	expit:	pop ebx
		pop ecx
		mov eax, ecx
		mov ecx, ebx
		mov ebx, eax
		dec ecx
	expitlp: mul bx
		loop expitlp
		mov ecx, eax
		cmp ecx, 0
		je zerocx
		mov si, numbuf
		call convert
		mov si, line
		call print
		mov si, buf2
		call chkadd
		jmp math
	divit:	pop ebx
		pop ecx
		mov eax, ecx
		div bl
		mov ecx, 0
		mov cx, ax
		mov si, numbuf
		call convert
		mov si, line
		call print
		mov si, buf2
		call chkadd
		jmp math
	chkadd:	mov al, [si]
		cmp al, '0'
		jne dnadd
		inc si
		jmp chkadd
	dnadd:	call print
		mov si, line
		call print
		ret

db 5,4,"space",0
	space:	call clearbuffer
		mov si, variables
		dec si
	spcchk:	inc si
		cmp si, varend
		jae donechk
		mov al, [si]
		cmp al, 0
		je spcchk2
		jmp spcchk
	spcchk2: inc si
		mov al, [si]
		cmp al, 0
		je spcchk3
		jmp spcchk
	spcchk3: inc si
		mov al, [si]
		cmp al, 0
		je donechk
		jmp spcchk
	donechk: mov cx, varend
		sub cx, si
		add cx, 2
		mov si, numbuf
		call convert
		mov si, buf2
		call chkadd
		mov si, dskmsg
		call print
		jmp nwcmd

db 5,4,"reload",0
	reload:	call clear
		mov si, sectormsg
		call print
		jmp sector
		
;db 5,4,"restore",0
	;restore:	
	;	jmp restoresect
	
db 5,4,"save",0
	savesect:	
		mov si, si
		mov bx, bx
		jmp writesect
	
db 5,4,"runbatch",0
	runbatch2:	
		mov si, si
		mov bx, bx
		jmp donebatch
	
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
		mov bx, variables
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
		cmp bx, variables
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
		mov bx, variables
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
		cmp bx, variables
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
		mov bx, variables
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
		mov ch, 3
		mov [bx], cx 
		mov si, batchmsg
		call print
		jmp nwcmd
	donebatch:
		call buftxtclear
		mov si, buftxt
		mov bx, batch
	batchfind: mov al, [bx]
		cmp al, 3
		je batchnext
		cmp bx, variables
		jae backtonwcmd
		inc bx
		jmp batchfind
	batchnext:
		mov si, buftxt
		inc bx
		mov al, [bx]
		cmp al, 4
		je batchfound
		cmp bx, variables
		jae backtonwcmd
		jmp batchfind
	batchfound:
		inc bx
		mov al, [bx]
		mov [si], al
		inc si
		cmp al, 0
		je runbatch
		cmp bx, variables
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
		cmp ah, al
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
		jmp ifitst
	ifelse3:	inc si
		mov al, [si]
		cmp al, 'e'
		je ifelse4
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
	num:	call clearbuffer
		mov si, buftxt
		mov eax, 0
		mov ecx, 0
		mov ebx, 0
		call num2
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
	operatorfound: push ax
		mov ah, 0
		mov [si], ah
		inc si
		mov al, [si]
		cmp al, '$'
		je varnum1
	varnum2: 
		call cnvrttxt
		mov ebx, ecx
		push ebx
		call clearbuffer
		mov si, buftxt
		inc si
		mov al, [si]
		cmp al, '$'
		je varnum3
	varnum4: 
		call cnvrttxt
		pop ebx
		pop ax
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
	varnum1: push si
		sub si, buftxt
		mov di, si
		pop si
		inc di
		mov bx, variables
		call nxtvrech
		jmp varnum2
	varnum3: push si
		sub si, buftxt
		mov di, si
		pop si
		inc di
		mov bx, variables
		call nxtvrech
		jmp varnum4
	plusnum:
		add ecx, ebx
		mov si, numbuf
		call convert
		mov si, buf2
		call chkadd
		jmp retnum
	subnum:
		sub ecx, ebx
		mov si, numbuf
		call convert
		mov si, buf2
		call chkadd
		jmp retnum
	mulnum:
		mov eax, ecx
		mul ebx
		mov ecx, eax
		mov si, numbuf
		call convert
		mov si, buf2
		call chkadd
		jmp retnum
	divnum:
		mov ax, cx
		cmp bl, 0
		je retnum
		div bl
		mov ecx, 0
		mov cl, al
		mov si, numbuf
		call convert
		mov si, buf2
		call chkadd	
		jmp retnum
	expnum:
		mov eax, ecx
		mov ecx, ebx
		mov ebx, eax
		dec ecx
	expnumlp: mul ebx
		loop expnumlp
		mov ecx, eax
		mov si, numbuf
		call convert
		mov si, buf2
		call chkadd
		jmp retnum
	retnum: jmp nwcmd
	
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
	jmp array
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