vga db 0
realmodeprogs:
	db 5,4,"vga",0
	mov BYTE [vga], 1
	mov ax, 12h
	int 10h
	jmp nwcmd

	db 5,4,"cga",0
cga:	mov BYTE [vga], 0
	mov ax, 3h
	int 10h
	jmp nwcmd

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
	jmp nwcmd

progstart:		;programs start here

	db 5,4,"mouse",0
	jmp mouse
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
	mov dx, 6
	call nxtvrech
	jmp prntvr2
echvar:	mov cl, '='
	inc bx
	mov si, buftxt
	add si, dx
	call cndtest
	cmp al, 2
	je prntvr
	cmp al, 1
	je prntvr
	mov si, buftxt
	add si, dx
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
varadd1: mov dx, 1
	mov bx, variables
	call nxtvrech
	jmp vraddn1
varadd2: mov dx, 1
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

	db 5,4,"etch-a-sketch",0
eas:	jmp etch
	jmp nwcmd

	db 5,4,"protected",0	;cannot do this, causes reset
protect: jmp pmode
	jmp nwcmd

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
	
	db 5,4,"dos",0
	mov si, dosmode
	call print
	call dos
	jmp nwcmd

	db 5,4,"reload",0
reload:	call clear
	mov si, sectormsg
	call print
	jmp sector
	
;	db 5,4,"restore",0
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
	mov si, batch
	mov bx, variables
	jmp array

	db 5,4,"showword",0
showword:
	mov si, wordst
	mov bx, commandlst
	jmp array

	db 5,4,"batch",0
batchst: mov si, batch
	mov al, 0
	mov bx, batch
clearbuf2: cmp si, variables
	jae batchfile
	mov [si], al
	inc si
	jmp clearbuf2
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
	mov al, 5
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
	mov si, batchmsg
	call print
	jmp nwcmd
donebatch:
	mov si, buftxt
	mov bx, batch
batchfind: mov al, [bx]
	cmp al, 5
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
	mov al, 0
	mov [BATCHISON], al
	jmp nwcmd
runbatch:
	mov al, 1
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
	mov bx, [BATCHPOS]
	jmp batchfind


	db 5,4,"word",0
wordit:	mov si, wordst
wordlp: mov byte [si], 5
	inc si
	mov byte [si], 4
	inc si
	push si
	call input
	mov si, line
	call print
	mov di, buftxt
	pop si
wordlp2: mov al, [di]
	mov [si], al
	inc si
	cmp al, 0
	je wordlp
	inc di
	jmp wordlp2
	cmp si, commandlst
	jae doneword
	jmp wordlp
doneword: jmp nwcmd

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
	mov dx, si
	pop si
	inc dx
	mov bx, variables
	call nxtvrech
	jmp varnum2
varnum3: push si
	sub si, buftxt
	mov dx, si
	pop si
	inc dx
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
	jmp array
eqfnd:	inc si
	mov al, [si]
	cmp al, 0
	je readvar
	mov si, buftxt
	mov bx, variables
	jmp seek

readvar: mov cx, 1
	call stdin
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

progend:		;programs end here
	
	db 5,4,"BATCHES ONLY!!!",0
notbatch: jmp nwcmd

	db 5,4,"while",0
while:  mov al, 1
	cmp [BATCHISON], al
	jne notbatch
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
if:	mov al, 1
	cmp [BATCHISON], al
	jne notbatch
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
ifvar4:	mov cl, 0
	call cndtest
	cmp al, 1
	je trueif
	jmp falseif
trueif:	mov al, [IFON]
	mov ah, 0
	mov si, IFTRUE
	add si, ax
	mov ah, 1
	mov [si], ah
	jmp nwcmd
falseif: mov al, [IFON]
	mov ah, 0
	mov si, IFTRUE
	add si, ax
	mov [si], ah
	jmp nwcmd
ifvar1: push si
	sub si, buftxt
	mov dx, si
	pop si
	inc dx
	mov bx, variables
	call nxtvrech
	jmp ifvar2
ifvar3: push si
	mov si, bx
	sub si, buftxt
	mov dx, si
	inc dx
	mov bx, variables
	call nxtvrech
	mov bx, si
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
	mov al, 1
	cmp [BATCHISON], al
	jne NEAR nwcmd
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
	
	db 5,4,"easter",0
easter:	mov si, easteregg
	call print
	jmp nwcmd

batchprogend: