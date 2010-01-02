	;SOLLEROS.ASM
os:
setdefenv:
	mov al, '/'
	mov [currentfolder], al
	mov eax, 1
	mov [currentfolderloc], eax
	call clear
	
bootfilecheck:
	cmp byte [ranboot], 1
	je near nobootfile
	%ifdef hardware.automatic
		call initializelater ;Initialize components that have debug messages
	%endif
	mov edi, bootfilename
	mov esi, 0x400000
	call loadfile
	cmp edx, 404
	je near nobootfile
	call progbatchfound
nobootfile:	
	mov byte [ranboot], 1

	mov esi, signature
.sigcopyloop:	;this prevents an odd error
	mov al, [gs:esi]
	mov [esi], al
	inc esi
	cmp esi, signatureend
	jb .sigcopyloop
	
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
	mov al, 10
	call prcharint
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
	xor ecx, ecx
	inc ecx
	mov [commandbufpos], ecx
returnfromexp:
	mov cx, 200h
	mov esi, buftxt
	mov [currentcommandloc], esi
	call bufclr
clearolddata:
	xor eax, eax
	mov [IFON], al
	mov [IFTRUE], al
	mov [BATCHISON], al
	mov [BATCHPOS], eax
	mov [LOOPON], al
	mov [LOOPPOS], eax
	jmp nwcmd
bufclr:	
	xor al, al
	mov [esi], al
	inc esi
	loop bufclr
	ret

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
	call fixvariables
	jmp nwcmd
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
	mov bx, 7
	call prcharq
	mov esi, [usercache]
	call printquiet
	mov esi, computer
	call printquiet
	mov esi, currentfolder
	add esi, [lastfolderloc]
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
gotcmd:	mov esi, [commandbufpos]
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
	mov [commandbufpos], esi
	call run
	jmp nwcmd

input:	call buftxtclear
	mov esi, buftxt		;puts input into buftxt AND onto screen
	mov edi, buftxtend
stdin:	mov al, 10
	mov bl, 7
	call rdprint
	ret

replacevariable:
	mov al, [esi + 1]
	mov byte [esi + 1], 255
	cmp al, "$"
	je near fixvariables
	mov [esi + 1], al
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
inlinecomment:	;if the following char is #, include a #, otherwise end the line
	inc esi
	mov al, [esi]
	mov byte [esi], 255
	cmp al, '#'
	je fixvariables
	dec esi
	mov byte [esi], 0
	jmp fixvariables
	
nextcommandloc dd 0
thiscommandloc dd 0	
run:
	mov esi, buftxt
fixvariables:
	inc esi
	mov al, [esi]
	cmp al, '#'	;inline comment
	je inlinecomment
	cmp al, '$' ;variable
	je near replacevariable
	cmp al, ';' ;program list
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
	ret
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
prgdn:	ret

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
.lp:
	mov esi, ebx
	sub esi, 9
	cmp ecx, 1000000000
	jb .8
	sub ecx, 1000000000
	inc byte [esi]
	jmp .lp
.8:	inc esi
	cmp ecx, 100000000
	jb .7
	sub ecx, 100000000
	inc byte [esi]
	jmp .lp
.7:	inc esi
	cmp ecx, 10000000
	jb .6
	sub ecx, 10000000
	inc byte [esi]
	jmp .lp
.6:	inc esi
	cmp ecx, 1000000
	jb .5
	sub ecx, 1000000
	inc byte [esi]
	jmp .lp
.5:	inc esi
	cmp ecx, 100000
	jb .4
	sub ecx, 100000
	inc byte [esi]
	jmp .lp
.4:	inc esi
	cmp ecx, 10000
	jb .3
	sub ecx, 10000
	inc byte [esi]
	jmp .lp
.3:	inc esi
	cmp ecx, 1000
	jb .2
	sub ecx, 1000
	inc byte [esi]
	jmp .lp
.2:	inc esi
	cmp ecx, 100
	jb .1
	sub ecx, 100
	inc byte [esi]
	jmp .lp
.1:	inc esi
	cmp ecx, 10
	jb .0
	sub ecx, 10
	inc byte [esi]
	jmp .lp
.0:	inc esi
	cmp ecx, 1
	jb .dn
	sub ecx, 1
	inc byte [esi]
	jmp .lp
.dn:
	ret

	

hexnumber times 8 db 0
hexnumberend db "  ",0

converthex:
.clear:	;place to convert to in esi, end of buffer in edi number in ecx
	push esi
	mov al, "0"
.clearlp: cmp esi, edi
	jae .doneclear
	mov [esi], al
	inc esi
	jmp .clearlp
.doneclear:
	sub esi, 2
	mov eax, ecx
.loop:
	xor bh, bh
	mov bl, al
	shl bx, 4
	shr bl, 4
	xchg bl, bh ;they are backwards
	add bl, 48
	cmp bl, "9"
	jbe .goodbl
	sub bl, 48
	sub bl, 0xA
	add bl, "A"
.goodbl:
	add bh, 48
	cmp bh, "9"
	jbe .goodbh
	sub bh, 48
	sub bh, 0xA
	add bh, "A"
.goodbh:
	shr eax, 8
	mov [esi], bx
	sub esi, 2
	cmp esi, [esp]
	jb .done
	cmp eax, 0
	jne .loop
.done:
	pop esi
	ret
	
	
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
	jne .show
	xor dx, dx
.show:
	cmp byte [firsthexshown], 3
	jne .nonewhexline
	mov esi, line
	call print
.nonewhexline:
	cmp byte [firsthexshown], 4
	jne .notab
	mov cl, 160
	sub cl, dl
	shr cl, 5
	shl cl, 5
	cmp cl, 0
	jne .nonewline
	mov esi, line
	call print
	jmp .notab
.nonewline:
	add dl, 15
	shr dl, 4
	shl dl, 4
.notab:
	mov esi, hexnumber
	cmp byte [smallhex],1
	jne .nosmall
	add esi, 6
.nosmall:
	cmp byte [firsthexshown], 5
	jne .noquiet
	call printquiet
	jmp .donequiet
.noquiet:
	cmp byte [firsthexshown], 6
	jne .normal
	call printhighlight
	jmp .donequiet
.normal:
	call print
.donequiet:
	cmp byte [firsthexshown], 2
	jne .shown
	mov esi, line
	call print
.shown:
	mov byte [firsthexshown], 0
	popa
	ret


decnumber db "00000000000000"
decnumberend: db " ",0

showdec: ;;same as showhex, just uses decimal conversion
	pusha
	mov edi, decnumber
	mov esi, decnumberend
.clear:
	mov byte [edi], '0'
	inc edi
	cmp edi, esi
	jb .clear
	mov edi, decnumber
	call convert
	cmp byte [firsthexshown], 1
	jne .show
	xor dx, dx
.show:
	cmp byte [firsthexshown], 3
	jne .nonewdecline
	mov esi, line
	call print
.nonewdecline:
	cmp byte [firsthexshown], 4
	jne .notab
	mov cl, 160
	sub cl, dl
	shr cl, 5
	shl cl, 5
	cmp cl, 0
	jne .nonewline
	mov esi, line
	call print
	jmp .notab
.nonewline:
	add dl, 15
	shr dl, 4
	shl dl, 4
.notab:
	mov esi, decnumber
	dec esi
.sifind:
	inc esi
	cmp byte [esi], '0'
	je .sifind
	call print
	cmp byte [firsthexshown], 2
	jne .shown
	mov esi, line
	call print
.shown:
	mov byte [firsthexshown], 0
	popa
	ret
	
cnvrthextxt:
	xor ecx, ecx
	xor eax, eax
	xor edx, edx
	xor ebx, ebx
	dec esi
.end:
	inc esi
	mov al, [esi]
	cmp al, 0
	jne .end
.loop:
	dec esi
	mov al, [esi]
	cmp al, "A"
	jae .char
	sub al, 48
	cmp al, 16
	ja .done
.donechar:
	cmp edx, 0
	je .noshl
	mov ebx, edx
.shl:
	shl eax, 4
	dec ebx
	cmp ebx, 0
	jne .shl
.noshl:
	inc edx
	add ecx, eax
	cmp edx, 8
	jb .loop
.done:
	ret
.char:
	cmp al, "F"
	ja .done
	sub al, "A"
	add al, 0xA
	jmp .donechar
	
	
cnvrttxt: ;text to convert in esi, first part or 0 in edi
	xor ecx, ecx
	xor eax, eax
	xor edx, edx
	xor ebx, ebx
	dec esi
.lp:
	inc esi
	mov al, [esi]
	cmp al, 0
	jne .lp
	dec esi
	mov al, [esi]
	cmp al, '.'
	jne .dot
	inc esi
	jmp .lp
.dot:
	cmp al, ' '
	je .zero
	cmp al, '0'
	jne .txtlp
.zero: 
		cmp esi, edi
		je .done
.txtlp:
	xor eax, eax
	mov al, [esi]
	cmp al, '='
	je .done
	cmp al, 48
	jb .done
	cmp al, '#'
	je .done
	cmp esi, edi
	jb .done
	cmp ecx, 0
	ja .exp
.noexp:	sub al, 48
	add edx, eax
	dec esi
	inc ecx
	jmp .txtlp
.exp:	cmp ecx, 0
	je .noexp
	sub al, 48
	push ecx
.expmul:	mov ebx, eax
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
	ja .expmul
	add edx, eax
	pop ecx
	dec esi
	inc ecx
	jmp .txtlp
.done: mov ecx, edx
	ret
