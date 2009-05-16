	;SOLLEROS.ASM
os:
	call clear
	mov esi, userask
	call print
usercheck:
	mov esi, buftxt
	mov al, 13
	mov ah, 4
	int 30h
	push esi
	mov esi, line
	call print
	mov esi, pwdask
	call print
	pop esi
	inc esi
	mov [esipass], esi
passcheck:
	mov al, 0
	mov ah, 5
	int 30h
	cmp al, 13
	je near gotpass
	cmp al, 8
	je near backpass
	mov [esi], al
	inc esi
	mov al, '*'
	mov ah, 6
	int 30h
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
	mov al,0
	mov [esi], al
	mov esi, line
	call print
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
nxtuser:
	inc ebx
	mov al, [ebx]
	cmp al, 0
	je userfind
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
pwdrgt:	call clear
	mov cx, 200h
	mov esi, buftxt
	mov al, 0
bufclr:	mov [esi], al
	inc esi
	loop bufclr
;;;;;;;;;;;;;;;;
	jmp nwcmd

esipass dd 0
usercache dd userlst
	
buftxtclear:
	mov al, 0
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

nwcmd2:
	mov esi, line
	call print

nwcmd:	mov al, 1
	cmp [BATCHISON], al
	jae near batchran
cancel:	mov al, 0
	mov [IFON], al
	mov [BATCHISON], al
	mov al, '['
	mov ah, 6
	mov bx, 7
	call int301prnt
	mov esi, [usercache]
	call print
	mov esi, location
	call print
	;call time
	;mov esi, timeshow
	;call print
	;mov esi, cmd
	;call print
	call buftxtclear
	mov esi, buftxt
	mov byte [commandedit], 1
	mov al, 13
	mov bx, 7
	call int305
	mov byte [commandedit], 0
	cmp byte [buftxt], 0
	je near nwcmd2
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
	
batchran:
	ret

input:	call buftxtclear
	mov esi, buftxt		;puts input into buftxt AND onto screen
stdin:	mov al, 13
	mov bl, 7
	mov ah, 4
	int 30h
	ret

run:	mov esi, line
	call print
	cmp byte [indexdone], 0
	jne progtest
	call indexfiles
progtest:
	mov esi, buftxt
	mov ebx, fileindex
prgnxt:	mov ax, [ebx]
	mov cl, 5
	mov ch, 4
	cmp ax, cx
	je fndprg
	inc ebx
	cmp ebx, fileindexend
	jae prgnf
	jmp prgnxt
fndprg: add ebx, 2
	mov esi, buftxt
	mov cx, 0
	call cndtest
	cmp al, 1
	jae prggood
	jmp prgnxt
prggood: cmp ebx, fileindexend
	jae prgdn
	add ebx, 3
	mov edi, [ebx]
	jmp edi
prgnf:	
	mov al, [buftxt]
	cmp al, 0
	je prgdn
	mov esi, notfound1
	call print
	mov esi, buftxt
	call print
	mov esi, notfound2
	call print
prgdn:	jmp nwcmd


tester:			;si=user bx=prog returns 1 in al if true
	mov al, 0
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
	mov al, 0
	ret

optest:			;si=user bx=prog returns 1 in al if true
	mov al, 0
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
	mov al, 0
	ret

cndtest:			;si=user bx=prog cl=endchar returns 1 in al if true
	mov al, 0
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
	mov al, 0
	ret
cndtestalmost:
	mov al, 2
	ret
currentdir db 0
dir:	mov esi, fileindex
	dirnxt:	mov al, [esi]
		mov ah, 0
		cmp al, 5
		je dirfnd
		cmp al, 7
		je dirfnd3
		cmp al, 6
		je dirfnd3
		inc esi
		cmp esi,  fileindexend
		jae dirdn
		jmp dirnxt
	typetable db 6,4,0,"batch",0,7,4,0,"document",0,10,4,0,"folder",0,5,4,0,"executable",0
	dirfnd3:
		inc esi
		cmp esi, fileindexend
		jbe dirnxt
		dec esi
	dirfnd:	inc esi
		mov al, [esi]
		mov ah, 0
		cmp al, 4
		je dirfnd2
		inc esi
		cmp esi,  fileindexend
		jae dirdn
		jmp dirnxt
	dirfnd2: add esi, 1
		call print
		mov [esidir], esi
		mov esi, dirtab
		call print
		mov esi, [esidir]
		cmp esi,  fileindexend
		jae dirdn
		jmp dirnxt
	dirdn:	mov esi, line
			call print
			jmp nwcmd
esidir dd 0

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
	mov ebx, esi		;place to convert into must be in si, number to convert must be in cx
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
	mov dx, 0
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
	call print
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
	mov dx, 0
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
	
cnvrttxt: 
	mov ecx, 0
	mov eax, 0
	mov edx, 0
	mov ebx, 0
	dec esi
cnvrtlptxt:
	inc esi
	mov al, [esi]
	cmp al, 0
	jne cnvrtlptxt
	dec esi
	mov al, [esi]
	cmp al, '0'
	jne txtlp
zerotest: cmp esi, edi
	je donecnvrt
txtlp:	
	mov eax, 0
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
