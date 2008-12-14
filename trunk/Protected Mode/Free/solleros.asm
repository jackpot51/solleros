	;SOLLEROS.ASM
os:
	call clear
	mov dx, 0
	mov si, pwdask
	call print

passcheck:
	mov si, buftxt
	mov al, 13
	mov bl, 7

	mov cx, 200h
	call int30hah2
	jmp passenter
pwdrgt:	call clear
	mov cx, 200h
	mov si, buftxt
	mov al, 0
bufclr:	mov [si], al
	inc si
	loop bufclr
	jmp nwcmd

passenter:
	mov al,0
	mov [si], al
	mov si, line
	call print
	mov si, buftxt
	mov bx, pwd
	call tester
	cmp al, 1
	je pwdrgt
	jmp os
fullpass: jmp passenter

buftxtclear:
	mov al, 0
	mov si, buftxt
clearbuftxt: cmp si, buf2
	jae retbufclr
	mov [si], al
	inc si
	jmp clearbuftxt

clearitbuf: cmp si, bx
	jae retbufclr
	mov [si], al
	inc si
	jmp clearitbuf
retbufclr: ret

full:	jmp nwcmd


nwcmd:	mov al, 1
	cmp [BATCHISON], al
	jae near batchran
cancel:	mov al, 0
	mov [IFON], al
	mov [BATCHISON], al
	mov si, cmd
	call print
	call buftxtclear
	mov si, buftxt
	mov al, 13
	mov bl, 7
	call int30hah4
gotcmd:	mov bx, buf2
	mov si, buftxt
	jmp run

input:	call buftxtclear
	mov si, buftxt		;puts input into buftxt AND onto screen
stdin:	mov al, 13
	mov bl, 7
	call int30hah4
	ret

run:	mov si, line
	call print
	jmp progtest

progtest:
	mov si, buftxt
	mov bx, fileindex
prgnxt:	mov al, [bx]
	cmp al, 5
	je fndprg
	inc bx
	cmp bx, fileindexend
	jae prgnf
	jmp prgnxt
fndprg:	inc bx
	mov al, [bx]
	cmp al, 4
	je fndprg2
	inc bx
	cmp bx, fileindexend
	jae prgnf
	jmp prgnxt
fndprg2: add bx, 1
	mov si, buftxt

	mov cl, 0
	call cndtest
	cmp al, 1
	je prggood

	cmp al, 2

	je prggood

	jmp prgnxt
prggood: cmp bx, fileindexend
	jae prgdn
	add bx, 3
	jmp word [bx]
prgnf:	mov si, notfound1
	call print
	mov si, buftxt
	call print
	mov si, notfound2
	call print
prgdn:	jmp nwcmd


tester:			;si=user bx=prog returns 1 in al if true
	mov al, 0
retest:	mov al, [si]
	mov ah, [bx]
	cmp al, 0
	je testtrue
	cmp al, ah
	jne testfalse
	inc bx
	inc si
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
	mov al, [si]
	mov ah, [bx]
	cmp al, ah
	jne optestfalse
	cmp ah, 0
	je optesttrue
	inc bx
	inc si
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
cndretest:	mov al, [si]
	mov ah, [bx]
	cmp ah, cl
	je cndtesttrue
	cmp al, ah
	jne cndtestfalse
	inc bx
	inc si
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
dir:	mov si, fileindex
	dirnxt:	mov al, [si]
		mov ah, 0
		cmp al, 5
		je dirfnd
		cmp al, 7
		je dirfnd3
		cmp al, 6
		je dirfnd3
		inc si
		cmp si,  fileindexend
		jae dirdn
		jmp dirnxt
	typetable db 6,4,0,"batch",0,7,4,0,"document",0,10,4,0,"folder",0,5,4,0,"executable",0
	dirfnd3:
		inc si
		cmp si, fileindexend
		jbe dirnxt
		dec si
	dirfnd:	inc si
		mov al, [si]
		mov ah, 0
		cmp al, 4
		je dirfnd2
		inc si
		cmp si,  fileindexend
		jae dirdn
		jmp dirnxt
	dirfnd2: add si, 1
		call print
		mov di, si
		mov si, line
		call print
		mov si, di
		cmp si,  fileindexend
		jae dirdn
		jmp dirnxt
	dirdn:	jmp nwcmd

array:				;arraystart in si, arrayend in bx, arrayseperator in cx
		                ;ends if array seperator is found backwards after 0
	arnxt:	      
		mov al, ch
		mov ah, cl        
		cmp [si], ax
		je ardn
		cmp [si], cx
		je arfnd
		inc si
		cmp si, bx
		jae ardn
		jmp arnxt
	arfnd: add si, 2
		mov [arbx], bx
		mov [arcx], cx
		call print
		mov [arsi], si
		mov si, line
		call print
		mov bx, [arbx]
		mov cx, [arcx]
		mov si, [arsi]
		inc si
		cmp si, bx
		jae ardn
		jmp arnxt
	ardn:	ret
arbx:	db 0,0
arcx:	db 0,0
arsi:	db 0,0

clearbuffer:
	mov si, buf2
	mov al, '0'
clearbuf: cmp si, numbuf
	jae doneclearbuff
	mov [si], al
	inc si
	jmp clearbuf
doneclearbuff: 
		ret

convert:
	dec si
	mov bx, si		;place to convert into must be in si, number to convert must be in cx
cnvrt:
	mov si, bx
	sub si, 9
	cmp ecx, 1000000000
	jb ten8
	sub ecx, 1000000000
	inc byte [si]
	jmp cnvrt
ten8:	inc si
	cmp ecx, 100000000
	jb ten7
	sub ecx, 100000000
	inc byte [si]
	jmp cnvrt
ten7:	inc si
	cmp ecx, 10000000
	jb ten6
	sub ecx, 10000000
	inc byte [si]
	jmp cnvrt
ten6:	inc si
	cmp ecx, 1000000
	jb ten5
	sub ecx, 1000000
	inc byte [si]
	jmp cnvrt
ten5:	inc si
	cmp ecx, 100000
	jb ten4
	sub ecx, 100000
	inc byte [si]
	jmp cnvrt
ten4:	inc si
	cmp ecx, 10000
	jb ten3
	sub ecx, 10000
	inc byte [si]
	jmp cnvrt
ten3:	inc si
	cmp ecx, 1000
	jb ten2
	sub ecx, 1000
	inc byte [si]
	jmp cnvrt

ten2:	inc si

	cmp ecx, 100

	jb ten1

	sub ecx, 100

	inc byte [si]

	jmp cnvrt

ten1:	inc si

	cmp ecx, 10

	jb ten0

	sub ecx, 10

	inc byte [si]

	jmp cnvrt

ten0:	inc si

	cmp ecx, 1

	jb tendn

	sub ecx, 1

	inc byte [si]

	jmp cnvrt

tendn:
	ret

	

hexnumber times 8 db 0

hexnumberend db "  ",0


sibuf db 0,0

dibuf db 0,0

converthex:

clearbufferhex:
	mov al, '0'

	mov [sibuf], si

	mov [dibuf], di
clearbufhex: cmp si, di
	jae doneclearbuffhex
	mov [si], al
	inc si
	jmp clearbufhex

doneclearbuffhex:

	mov si, [dibuf]

	mov edx, ecx

	cmp edx, 0

	je donenxtephx

nxtexphx:	;0x10^x

	dec si

	mov di, si
		;;location of 0x10^x

	mov ecx, edx

	and ecx, 0xF		;;just this digit

	call cnvrtexphx		;;get this digit

	mov si, di

	shr edx, 4		;;next digit

	cmp edx, 0

	je donenxtephx

	jmp nxtexphx
donenxtephx:

	mov si, [sibuf]

	mov di, [dibuf]

	ret
cnvrtexphx:			;;convert this number
	mov bx, si		;place to convert to must be in si, number to convert must be in cx

	cmp ecx, 0

	je zerohx
cnvrthx:  mov al, [si]

	cmp al, '9'

	je lettershx
lttrhxdn: cmp al, 'F'
	je zerohx
	mov al, [si]
	inc al
	mov [si], al
	mov si, bx
cnvrtlphx: sub ecx, 1
	cmp ecx, 0
	jne cnvrthx
	ret

lettershx:

	mov al, 'A'

	sub al, 1

	mov [si], al

	jmp lttrhxdn
zerohx:	mov al, '0'
	mov [si], al
	dec si
	mov al, [si]
	cmp al, 'F'
	je zerohx
	inc ecx
	jmp cnvrtlphx


shxeax db 0,0,0,0

shxebx db 0,0,0,0

shxecx db 0,0,0,0

shxedx db 0,0,0,0

shxsi db 0,0

shxdi db 0,0

firsthexshown db 1

showhex:

	mov [shxeax], eax

	mov [shxebx], ebx

	mov [shxecx], ecx

	mov [shxedx], edx

	mov [shxsi], si

	mov [shxdi], di

	mov si, hexnumber

	mov di, hexnumberend

	call converthex

	cmp byte [shownumberstack], 0

	jne nopopahex

	popa

nopopahex:

	cmp byte [firsthexshown], 1

	jne showthathex

	mov dx, 0

showthathex:

	cmp byte [firsthexshown], 3

	jne nonewhexline

	mov si, line

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

	mov si, line

	call print

	jmp notabfixhex

nonewlinetabfixhex:

	add dl, 15

	shr dl, 4

	shl dl, 4

notabfixhex:

	mov si, hexnumber

	call print

	cmp byte [firsthexshown], 2

	jne hexshown

	mov si, line

	call print

hexshown:

	mov byte [firsthexshown], 0

	cmp byte [shownumberstack], 0

	jne nopushahex

	pusha

	mov edx, [shxedx]

nopushahex:

	mov eax, [shxeax]

	mov ebx, [shxebx]

	mov ecx, [shxecx]

	mov si, [shxsi]

	mov di, [shxdi]

	ret

sdceax db 0,0,0,0

sdcebx db 0,0,0,0

sdcecx db 0,0,0,0

sdcedx db 0,0,0,0

sdcsi db 0,0

sdcdi db 0,0


decnumber db "00000000000000"

decnumberend: db " ",0

shownumberstack db 0


showdec: ;;same as showhex, just uses decimal conversion

	mov [sdceax], eax

	mov [sdcebx], ebx

	mov [sdcecx], ecx

	mov [sdcedx], edx

	mov [sdcsi], si

	mov [sdcdi], di

	mov di, decnumber

	mov si, decnumberend

cleardecbuf:

	mov byte [di], '0'

	inc di
	cmp di, si

	jb cleardecbuf

	mov di, decnumber

	call convert

	cmp byte [shownumberstack], 0

	jne nopopadec

	popa

nopopadec:

	cmp byte [firsthexshown], 1

	jne showthatdec

	mov dx, 0

showthatdec:

	cmp byte [firsthexshown], 3

	jne nonewdecline

	mov si, line

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

	mov si, line

	call print

	jmp notabfixdec

nonewlinetabfixdec:

	add dl, 15

	shr dl, 4

	shl dl, 4

notabfixdec:

	mov si, decnumber

	dec si
sifind:
	inc si

	cmp byte [si], '0'

	je sifind

	call print

	cmp byte [firsthexshown], 2

	jne decshown

	mov si, line

	call print

decshown:

	mov byte [firsthexshown], 0

	cmp byte [shownumberstack], 0

	jne nopushadec

	pusha

	mov edx, [sdcedx]

nopushadec:

	mov eax, [sdceax]

	mov ebx, [sdcebx]

	mov ecx, [sdcecx]

	mov si, [sdcsi]

	mov di, [sdcdi]

	ret

edxcachecnvrt dw 0,0
cnvrttxt: 
	mov [edxcachecnvrt], edx
	mov ecx, 0
	mov eax, 0
	mov edx, 0
	mov ebx, 0
	dec si
cnvrtlptxt:
	inc si
	mov al, [si]
	cmp al, 0
	jne cnvrtlptxt
	dec si
	mov al, [si]
	cmp al, '0'
	je zerotest
	jmp txtlp
zerotest: cmp si, buftxt
	je donecnvrt
txtlp:	mov al, [si]
	cmp al, '='
	je donecnvrt
	cmp al, 48
	jb donecnvrt
	cmp al, '#'
	je donecnvrt
	cmp si, buftxt
	jb donecnvrt
	cmp ecx, 0
	ja exp
noexp:	sub al, 48
	add edx, eax
	dec si
	inc ecx
	jmp txtlp
exp:	cmp ecx, 0

	je noexp

	sub al, 48
	mov [ecxbufnum], ecx
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
	mov ecx, [ecxbufnum]
	dec si
	inc ecx
	jmp txtlp
donecnvrt: mov ecx, edx
	mov edx, [edxcachecnvrt]
	ret
ecxbufnum dw 0,0


IFON db 0
IFTRUE times 100 db 0
BATCHPOS db 0,0
LOOPON db 0
LOOPPOS	db 0,0
