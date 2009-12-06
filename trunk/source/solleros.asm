	;SOLLEROS.ASM
os:
	call clear
	mov esi, signature
	call print
	mov ecx, [signatureend - 4]
	call showdec
	mov esi, line
	call print
	mov esi, userask
	call print
usercheck:
	mov esi, buftxt
	mov edi, buftxtend
	mov al, 10
	call rdprint
	push esi
	mov esi, pwdask
	call print
	pop esi
	inc esi
	mov [esipass], esi
passcheck:
	call getchar
	cmp al, 10
	je near gotpass
	cmp al, 8
	je near backpass
	mov [esi], al
	inc esi
	mov al, '*'
	call prcharint
	jmp passcheck
backcursor2 db 8," ",8,0
backpass:
	cmp esi, [esipass]
	je near passcheck
	dec esi
	mov byte [esi], 0
	push esi
	mov esi, backcursor2
	call print
	pop esi
	jmp passcheck
gotpass:
	xor al, al
	xor ecx, ecx
	mov [esi], al
	mov ebx, userlst
userfind:
	mov esi, buftxt
	mov al, [esi]
	cmp al, 0
	je near os
	mov [usercache], ebx
	call tester
	cmp al, 1
	je pwdtest
	inc ecx
nxtuser:
	mov al, [ebx]
	inc ebx
	cmp al, 0
	jne nxtuser
	cmp ebx, userlstend
	jae near os
	jmp userfind
pwdtest:
	inc esi
	inc ebx
	call tester
	cmp al, 1
	je pwdrgt
	jmp nxtuser
pwdrgt:
	shr ecx, 1
	mov [uid], ecx
	call clear
	mov cx, 200h
	mov esi, buftxt
	mov [currentcommandloc], esi
	xor al, al
bufclr:	mov [esi], al
	inc esi
	loop bufclr
	jmp nwcmd

esipass dd 0
usercache dd userlst
	
buftxtclear:
	xor al, al
	mov esi, buftxt
clearbuftxt: cmp esi, buf2
	jae retbufclr
	mov [esi], al
	inc esi
	jmp clearbuftxt

clearitbuf: cmp esi, ebx
	jae retbufclr
	mov [esi], al
	inc esi
	jmp clearitbuf
retbufclr: ret

full:	jmp nwcmd

shush:	;SollerOS Hardly Unix-compatible Shell
nwcmd:
	sti
	xor eax, eax
	cmp [nextcommandloc], eax
	je nomultiplecommand
	mov esi, [nextcommandloc]
	mov [thiscommandloc], esi
	jmp fixvariables
nomultiplecommand:
	mov [thiscommandloc], eax
	cmp [threadson], al
	je noclinwcmd
	mov [threadson], al
noclinwcmd:
	mov al, 1
	cmp [BATCHISON], al
	jne cancel
	ret
cancel:	xor al, al
	mov [IFON], al
	mov [BATCHISON], al
	mov al, '['
	mov ah, 6
	mov bx, 7
	call prcharq
	mov esi, [usercache]
	call printquiet
	mov esi, computer
	call printquiet
	mov esi, location
	call printquiet
	mov esi, endprompt
	call print
	call buftxtclear
	mov esi, buftxt
	mov byte [commandedit], 1
	mov al, 10
	mov bx, 7
	mov edi, buftxtend
	call rdprint
	mov byte [commandedit], 0
	cmp byte [buftxt], 0
	je near nwcmd
gotcmd:	mov esi, [currentcommandpos]
	mov [lastcommandpos], esi
	mov edi, buftxt
	add esi, commandbuf
	cmp esi, commandbufend
	jbe copycommand
	mov esi, commandbuf
copycommand:
	mov al, [edi]
	mov [esi], al
	inc edi
	inc esi
	cmp al, 0
	je donecopy
	cmp esi, commandbufend
	jbe copycommand
	mov esi, commandbuf
	jmp copycommand
donecopy:
	sub esi, commandbuf
	mov [currentcommandpos], esi
	jmp run

input:	call buftxtclear
	mov esi, buftxt		;puts input into buftxt AND onto screen
	mov edi, buftxtend
stdin:	mov al, 10
	mov bl, 7
	call rdprint
	ret

replacevariable:
	push esi
	sub esi, buftxt
	mov edi, esi
	add esi, buftxt
	inc edi
	mov ebx, variables
	call nxtvrech
	mov edi, esi
	xor ebx, ebx
	dec esi
findvarname:
	dec esi
	mov al, [esi]
	inc ebx
	cmp al, 4
	jne findvarname
	pop esi
replacevarloop:
	mov al, [edi]
	cmp ebx, 0
	je near expandbuftxt
	cmp al, 0
	je near compressbuftxt
	mov [esi], al
	dec ebx
	inc esi
	inc edi
	jmp replacevarloop
compressbuftxt:	
	mov al, [esi + ebx]
	mov [esi], al
	inc esi
	cmp al, 0
	jne compressbuftxt
	jmp fixvariables
expandbuftxt:
	mov ecx, esi
	mov ah, [esi]
expandbuftxtlp:
	mov bl, [esi]
	inc esi
	mov bh, [esi]
	mov [esi], ah
	mov ah, bh
	cmp bl, 0
	jne expandbuftxtlp
	mov esi, ecx
	mov [esi], al
	inc edi
	mov al, [edi]
	cmp al, 0
	je near fixvariables
	inc esi
	jmp expandbuftxt
multipleprogline:
	xor ah, ah
	mov [esi], ah
	inc esi
	mov [nextcommandloc], esi
	jmp donefixvariables
	
nextcommandloc dd 0
thiscommandloc dd 0	
run:
	mov esi, buftxt
fixvariables:
	inc esi
	mov al, [esi]
	cmp al, '$'
	je near replacevariable
	cmp al, ';'
	je multipleprogline
	cmp al, 0
	jne fixvariables
	xor eax, eax
	mov [nextcommandloc], eax
donefixvariables:
	cmp byte [indexdone], 0
	jne progtest
	call indexfiles
progtest:
	xor eax, eax
	mov ebx, fileindex
prgnxt:	mov ax, [ebx]
	mov cl, 255
	mov ch, 44
	cmp ax, cx
	je fndprg
	inc ebx
	cmp ebx, fileindexend
	jae prgnf
	jmp prgnxt
fndprg: add ebx, 2
	xor ecx, ecx
	mov esi, buftxt
	cmp [thiscommandloc], ecx
	je noprgtstmultiple
	mov esi, [thiscommandloc]
noprgtstmultiple:
	call cndtest
	cmp al, 1
	jae prggood
	jmp prgnxt
prggood: cmp ebx, fileindexend
	jae prgdn
	xor eax, eax
	mov esi, buftxt
	cmp [thiscommandloc], eax
	je noprggoodmul
	mov esi, [thiscommandloc]
noprggoodmul:
	mov [currentcommandloc], esi
	add ebx, 3
	mov edi, [ebx]
	mov byte [threadson], 2
	call edi
	jmp nwcmd
prgnf:	
	mov esi, [currentcommandloc]
	mov al, [esi]
	cmp al, 0
	je prgdn
	mov esi, notfound1
	call print
	mov esi, [currentcommandloc]
	call print
	mov esi, notfound2
	call print
prgdn:	jmp nwcmd

currentcommandloc dd 0

tester:			;si=user bx=prog returns 1 in al if true
	xor ax, ax
retest:	mov al, [esi]
	mov ah, [ebx]
	cmp al, 0
	je testtrue
	cmp al, ah
	jne testfalse
	inc ebx
	inc esi
	jmp retest
testtrue:
	cmp ah, 0
	jne testfalse
	mov al, 1
	ret
testfalse:
	xor al, al
	ret

optest:			;si=user bx=prog returns 1 in al if true
	xor al, al
opretest:
	mov al, [esi]
	mov ah, [ebx]
	cmp al, ah
	jne optestfalse
	cmp ah, 0
	je optesttrue
	inc ebx
	inc esi
	jmp opretest
optesttrue:
	cmp al, 0
	jne optestfalse
	mov al, 1
	ret
optestfalse:
	xor al, al
	ret

cndtest:			;si=user bx=prog cl=endchar returns 1 in al if true
	xor al, al
cndretest:	mov al, [esi]
	mov ah, [ebx]
	cmp ah, cl
	je cndtesttrue
	cmp al, ah
	jne cndtestfalse
	inc ebx
	inc esi
	jmp cndretest
cndtesttrue:
	cmp al, cl
	jne cndtestalmost
	mov al, 1
	ret
cndtestfalse:
	xor al, al
	ret
cndtestalmost:
	mov al, 2
	ret
	
array:				;arraystart in si, arrayend in bx, arrayseperator in cx
		                ;ends if array seperator is found backwards after 0
	arnxt:	      
		mov al, ch
		mov ah, cl        
		cmp [esi], ax
		je ardn
		cmp [esi], cx
		je arfnd
		inc esi
		cmp esi, ebx
		jae ardn
		jmp arnxt
	arfnd: add esi, 2
		mov [arbx], ebx
		mov [arcx], ecx
		call print
		mov [arsi], esi
		mov esi, line
		call print
		mov ebx, [arbx]
		mov cx, [arcx]
		mov esi, [arsi]
		inc esi
		cmp esi, ebx
		jae ardn
		jmp arnxt
	ardn:	ret
arbx:	dw 0,0
arcx:	db 0,0
arsi:	dw 0,0

clearbuffer:
	mov esi, buf2
	mov al, '0'
clearbuf: cmp esi, numbuf
	jae doneclearbuff
	mov [esi], al
	inc esi
	jmp clearbuf
doneclearbuff: 
		ret

convert:
	dec esi
	mov ebx, esi		;place to convert into must be in esi, number to convert must be in ecx
cnvrt:
	mov esi, ebx
	sub esi, 9
	cmp ecx, 1000000000
	jb ten8
	sub ecx, 1000000000
	inc byte [esi]
	jmp cnvrt
ten8:	inc esi
	cmp ecx, 100000000
	jb ten7
	sub ecx, 100000000
	inc byte [esi]
	jmp cnvrt
ten7:	inc esi
	cmp ecx, 10000000
	jb ten6
	sub ecx, 10000000
	inc byte [esi]
	jmp cnvrt
ten6:	inc esi
	cmp ecx, 1000000
	jb ten5
	sub ecx, 1000000
	inc byte [esi]
	jmp cnvrt
ten5:	inc esi
	cmp ecx, 100000
	jb ten4
	sub ecx, 100000
	inc byte [esi]
	jmp cnvrt
ten4:	inc esi
	cmp ecx, 10000
	jb ten3
	sub ecx, 10000
	inc byte [esi]
	jmp cnvrt
ten3:	inc esi
	cmp ecx, 1000
	jb ten2
	sub ecx, 1000
	inc byte [esi]
	jmp cnvrt
ten2:	inc esi
	cmp ecx, 100
	jb ten1
	sub ecx, 100
	inc byte [esi]
	jmp cnvrt
ten1:	inc esi
	cmp ecx, 10
	jb ten0
	sub ecx, 10
	inc byte [esi]
	jmp cnvrt
ten0:	inc esi
	cmp ecx, 1
	jb tendn
	sub ecx, 1
	inc byte [esi]
	jmp cnvrt
tendn:
	ret

	

hexnumber times 8 db 0
hexnumberend db "  ",0


sibuf dw 0,0
dibuf dw 0,0

converthex:
clearbufferhex:
	mov al, '0'
	mov [sibuf], esi
	mov [dibuf], edi
clearbufhex: cmp esi, edi
	jae doneclearbuffhex
	mov [esi], al
	inc esi
	jmp clearbufhex
doneclearbuffhex:
	mov esi, [dibuf]
	mov edx, ecx
	cmp edx, 0
	je donenxtephx
nxtexphx:	;0x10^x
	dec esi
	mov edi, esi		;;location of 0x10^x
	mov ecx, edx
	and ecx, 0xF		;;just this digit
	call cnvrtexphx		;;get this digit
	mov esi, edi
	shr edx, 4		;;next digit
	cmp edx, 0
	je donenxtephx
	jmp nxtexphx
donenxtephx:
	mov esi, [sibuf]
	mov edi, [dibuf]
	ret
cnvrtexphx:			;;convert this number
	mov ebx, esi		;place to convert to must be in si, number to convert must be in cx
	cmp ecx, 0
	je zerohx
cnvrthx:  mov al, [esi]
	cmp al, '9'
	je lettershx
lttrhxdn: cmp al, 'F'
	je zerohx
	mov al, [esi]
	inc al
	mov [esi], al
	mov esi, ebx
cnvrtlphx: sub ecx, 1
	cmp ecx, 0
	jne cnvrthx
	ret
lettershx:
	mov al, 'A'
	sub al, 1
	mov [esi], al
	jmp lttrhxdn
zerohx:	mov al, '0'
	mov [esi], al
	dec esi
	mov al, [esi]
	cmp al, 'F'
	je zerohx
	inc ecx
	jmp cnvrtlphx
smallhex db 0
firsthexshown db 1
showhexsmall:
	mov byte [smallhex], 1
	call showhex
	mov byte [smallhex], 0
	ret
showhex:
	pusha
	mov esi, hexnumber
	mov edi, hexnumberend
	call converthex
	cmp byte [firsthexshown], 1
	jne showthathex
	xor dx, dx
showthathex:
	cmp byte [firsthexshown], 3
	jne nonewhexline
	mov esi, line
	call print
nonewhexline:
	cmp byte [firsthexshown], 4
	jne notabfixhex
	mov cl, 160
	sub cl, dl
	shr cl, 5
	shl cl, 5
	cmp cl, 0
	jne nonewlinetabfixhex
	mov esi, line
	call print
	jmp notabfixhex
nonewlinetabfixhex:
	add dl, 15
	shr dl, 4
	shl dl, 4
notabfixhex:
	mov esi, hexnumber
	cmp byte [smallhex],1
	jne printnosmallhex
	add esi, 6
printnosmallhex:
	cmp byte [firsthexshown], 5
	jne noquietprinthex
	call printquiet
	jmp donequiethex
noquietprinthex:
	call print
donequiethex:
	cmp byte [firsthexshown], 2
	jne hexshown
	mov esi, line
	call print
hexshown:
	mov byte [firsthexshown], 0
	popa
	ret


decnumber db "00000000000000"
decnumberend: db " ",0

showdec: ;;same as showhex, just uses decimal conversion
	pusha
	mov edi, decnumber
	mov esi, decnumberend
cleardecbuf:
	mov byte [edi], '0'
	inc edi
	cmp edi, esi
	jb cleardecbuf
	mov edi, decnumber
	call convert
	cmp byte [firsthexshown], 1
	jne showthatdec
	xor dx, dx
showthatdec:
	cmp byte [firsthexshown], 3
	jne nonewdecline
	mov esi, line
	call print
nonewdecline:
	cmp byte [firsthexshown], 4
	jne notabfixdec
	mov cl, 160
	sub cl, dl
	shr cl, 5
	shl cl, 5
	cmp cl, 0
	jne nonewlinetabfixdec
	mov esi, line
	call print
	jmp notabfixdec
nonewlinetabfixdec:
	add dl, 15
	shr dl, 4
	shl dl, 4
notabfixdec:
	mov esi, decnumber
	dec esi
sifind:
	inc esi
	cmp byte [esi], '0'
	je sifind
	call print
	cmp byte [firsthexshown], 2
	jne decshown
	mov esi, line
	call print
decshown:
	mov byte [firsthexshown], 0
	popa
	ret
	
cnvrthextxt:
	xor ecx, ecx
	xor eax, eax
	xor edx, edx
	xor ebx, ebx
	dec esi
cnvrthexendtxt:
	inc esi
	mov al, [esi]
	cmp al, 0
	jne cnvrthexendtxt
cnvrthextxtlp:
	dec esi
	mov al, [esi]
	sub al, 48
	cmp al, 16
	ja donecnvrthx
	cmp edx, 0
	je noshlhextxt
	mov ebx, edx
shlhextxt:
	shl eax, 4
	dec ebx
	cmp ebx, 0
	jne shlhextxt
noshlhextxt:
	inc edx
	add ecx, eax
	cmp edx, 8
	jb cnvrthextxtlp
donecnvrthx:
	ret
	
	
cnvrttxt: 
	xor ecx, ecx
	xor eax, eax
	xor edx, edx
	xor ebx, ebx
	dec esi
cnvrtlptxt:
	inc esi
	mov al, [esi]
	cmp al, 0
	jne cnvrtlptxt
	dec esi
	mov al, [esi]
	cmp al, '.'
	jne nocnvrtdot
	inc esi
	jmp cnvrtlptxt
nocnvrtdot:
	cmp al, ' '
	je zerotest
	cmp al, '0'
	jne txtlp
zerotest: 
		cmp esi, edi
		je donecnvrt
txtlp:	
	xor eax, eax
	mov al, [esi]
	cmp al, '='
	je donecnvrt
	cmp al, 48
	jb donecnvrt
	cmp al, '#'
	je donecnvrt
	cmp esi, edi
	jb donecnvrt
	cmp ecx, 0
	ja exp
noexp:	sub al, 48
	add edx, eax
	dec esi
	inc ecx
	jmp txtlp
exp:	cmp ecx, 0
	je noexp
	sub al, 48
	push ecx
expmul:	mov ebx, eax
	add eax, ebx
	add eax, ebx
	add eax, ebx
	add eax, ebx
	add eax, ebx
	add eax, ebx
	add eax, ebx
	add eax, ebx
	add eax, ebx
	sub ecx, 1
	cmp ecx, 0
	ja expmul
	add edx, eax
	pop ecx
	dec esi
	inc ecx
	jmp txtlp
donecnvrt: mov ecx, edx
	ret
