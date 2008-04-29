	;SOLLEROS.ASM
os:
	call clear
	mov si, pwdask
	call print
	mov cx, 0

passcheck:
	mov cx, 1
	mov si, buftxt
pass:	call getkey
	cmp al, 13
	je passenter
	cmp al, 8
	je bck4
	mov [si], al
	mov al, '*'
        mov bx,7		; write to display
	mov ah,0Eh		; screen function
	int 10h
	inc si
	inc cx
	cmp cx, 500
	jae fullpass
	jmp pass
bck4:	call bckspc
	jmp pass
pwdrgt:	call clear
	mov cx, 500
	mov si, buftxt
	mov al, 0
bufclr:	mov [si], al
	inc si
	loop bufclr
	jmp nwcmd
wrngpwd:
	call char
	mov si, line
	call print
	mov si, wrongpass
	call print
	jmp os

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
	jmp wrngpwd
fullpass: mov si, fullmsg
	call print
	mov si, line
	call print
	jmp os

buftxtclear:
	mov al, 0
	mov si, buftxt
	mov bx, buf2
clearitbuf: cmp si, bx
	jae retbufclr
	mov [si], al
	inc si
	jmp clearitbuf
retbufclr: ret

full:	mov si, fullmsg
	call print
	mov si, line
	call print
	jmp nwcmd
nwcmd:	mov al, 1
	cmp [BATCHISON], al
	je batchreturn
cancel:	mov al, 0
	mov [IFON], al
	mov [BATCHISON], al
	mov si, cmd
	call print
	call buftxtclear
	mov si, buftxt
	mov di, si
	mov cx, 1
cmdln:	call getkey
	cmp al,13
	je run2
        cmp   ah, 4Bh
	je lft
        cmp   ah, 4Dh
	je recall
gotcmd:	cmp al,8
	je bck2
	mov bx, buf2
	cmp al, 0
	je cmdln
	call insert
	call updateline
	inc si
	inc cx
	cmp cx, 500
	jae full
	jmp cmdln
batchreturn: jmp batchran
bck2:	call bckspc
	call updateline
	jmp cmdln
run2:	jmp run
lft:	cmp si, buftxt
	jbe cmdln
	mov al, 8
	mov bx, 7
	mov ah, 0Eh
	int 10h
	dec si
	jmp cmdln
lft2:	cmp si, buftxt
	jbe stdin
	mov al, 8
	mov bx, 7
	mov ah, 0Eh
	int 10h
	dec si
	jmp std2
recall:	mov al, [si]
	cmp al, 0
	je cmdln
	inc si
	mov ah, 0Eh
	mov bx, 7
	int 10h
	jmp cmdln
recall2: mov al, [si]
	cmp al, 0
	je std2
	inc si
	mov ah, 0Eh
	mov bx, 7
	int 10h
	jmp stdin
input:	call buftxtclear
	mov si, buftxt		;puts input into buftxt AND onto screen
	mov cx, 1
stdin:	mov di, si
std2:	call getkey
	cmp al, 13
	je itsin
	cmp al, 8
	je bck3
	cmp al, 3
	je NEAR cancel
        cmp   ah, 4Bh
	je lft2
        cmp   ah, 4Dh
	je recall2
	cmp al, 0
	je std2
	mov bx, buf2
	call insert
	call updateline
	inc si
	inc cx
	cmp cx, 500
	jae full
	jmp std2
bck3:	call bckspc
	call updateline
	jmp std2
itsin:	ret

doneupd: mov byte [BACKSPACE], 0
	ret
updateline: 		;start in di, current in si
	cmp byte [BACKSPACE], 3
	je doneupd
	mov dx, si
updtlp: cmp si, di
	je updtst
	dec si
	mov al, 8
	mov bx, 7
	mov ah, 0Eh
	int 10h
jmp updtlp
updbck: mov al, ' '
	mov bx, 7
	mov ah, 0Eh
	int 10h
	mov al, 8
	mov ah, 0Eh
	mov bx, 7
	int 10h
	cmp byte [BACKSPACE],2
	je up2
	mov al, 8
	mov ah, 0Eh
	mov bx, 7
	int 10h
up2:	mov byte [BACKSPACE], 0
	jmp updtlp2
updtst: call print
	cmp byte [BACKSPACE], 1
	jae updbck
	cmp si, dx
	je doneupdate
	dec si
updtlp2: cmp si, dx
	je doneupdate 
	dec si
	mov al, 8
	mov bx, 7
	mov ah, 0Eh
	int 10h
jmp updtlp2
doneupdate: ret
BACKSPACE db 0
bckspc: mov dx, si
	dec si
	cmp si, di
	jb  bckto2
	mov byte [BACKSPACE], 2
	mov al, 8
	mov ah, 0Eh
	mov bx, 7
	int 10h
	cmp si, di
	jbe bcklp
bcklp:  inc si
	mov al, [si]
	dec si
	mov [si], al
	cmp al, 0
	je bcklp2
	cmp si, buf2
	ja bck
	inc si
	jmp bcklp
bcklp2: mov al, 0
	mov [si], al
	jmp bck
bck:	mov si, dx
	dec si
	dec si
bckto:	inc si
	ret
bckto2: mov byte [BACKSPACE],3
	inc si
	ret

run:	mov si, line
	call print
	jmp progtest
	jmp nwcmd

progtest:
	mov si, buftxt
	mov bx, progstart
prgnxt:	mov al, [bx]
	cmp al, 5
	je fndprg
	inc bx
	cmp bx, batchprogend
	jae prgnf
	jmp prgnxt
fndprg:	inc bx
	mov al, [bx]
	cmp al, 4
	je fndprg2
	inc bx
	cmp bx, batchprogend
	jae prgnf
	jmp prgnxt
fndprg2: inc bx
	mov si, buftxt
	call tester
	cmp al, 1
	jne prgnxt
	cmp bx, batchprogend
	jae prgdn
	inc bx
	jmp bx
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
	cmp ah, 0
	je testtrue
	cmp al, ah
	jne testfalse
	inc bx
	inc si
	jmp retest
testtrue:
	mov al, 1
	ret
testfalse:
	mov al, 0
	ret

optest:			;si=user bx=prog returns 1 in al if true
	mov al, 0
opretest:	mov al, [bx]
	mov ah, [si]
	cmp al, ah
	jne optestfalse
	cmp ah, 0
	je optesttrue
	inc bx
	inc si
	jmp opretest
optesttrue:
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

dir:	mov si, progstart
	dirnxt:	mov al, [si]
		mov ah, 0
		add ah, 5
		cmp al, ah
		je dirfnd
		inc si
		cmp si, progend
		jae dirdn
		jmp dirnxt
	dirfnd:	inc si
		mov al, [si]
		mov ah, 0
		add ah, 4
		cmp al, ah
		je dirfnd2
		inc si
		cmp si, progend
		jae dirdn
		jmp dirnxt
	dirfnd2: inc si
		call print
		push si
		mov si, line
		call print
		pop si
		cmp si, progend
		jae dirdn
		jmp dirnxt
	dirdn:	jmp nwcmd

array:	
	arnxt:	mov al, [si]  ;arraystart in si, arrayend in bx
		mov ah, 5
		cmp al, ah
		je arfnd
		inc si
		cmp si, bx
		jae ardn
		jmp arnxt
	arfnd:	inc si
		mov al, [si]
		mov ah, 4
		cmp al, ah
		je arfnd2
		inc si
		cmp si, bx
		jae ardn
		jmp arnxt
	arfnd2: inc si
		push bx
		call print
		push si
		mov si, line
		call print
		pop si
		pop bx
		cmp si, bx
		jae ardn
		jmp arnxt
	ardn:	jmp nwcmd

clearbuffer:
	mov si, buf2
	mov al, '0'
clearbuf: cmp si, numbuf
	jae doneclearbuff
	mov [si], al
	inc si
	jmp clearbuf
doneclearbuff: ret

convert: dec si
	mov bx, si		;place to convert to must be in si, number to convert must be in cx
cnvrt:  mov al, [si]
	cmp al, '9'
	je zero
	mov ah, [si]
	inc ah
	mov [si], ah
	mov si, bx
cnvrtlp: dec ecx
	cmp ecx, 0
	jne cnvrt
	ret
zero:	mov al, '0'
	mov [si], al
	dec si
	mov al, [si]
	cmp al, '9'
	je zero
	inc ecx
	jmp cnvrtlp

cnvrttxt: 
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
	cmp al, 0
	je donecnvrt
	cmp al, '#'
	je donecnvrt
	cmp si, buftxt
	jb donecnvrt
	cmp ecx, 0
	je noexp
	jmp exp
noexp:	sub al, 48
	add edx, eax
	dec si
	inc ecx
	jmp txtlp
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
	loop expmul
	ret
exp:	sub al, 48
	mov ebx, ecx
	push ecx
	mov ecx, ebx
	call expmul
	add edx, eax
	pop ecx
	dec si
	inc ecx
	jmp txtlp
donecnvrt: mov ecx, edx
	ret

sector:
    reset:                      ; Reset the floppy drive
            mov ax, 0           ;
            mov dl, [DriveNumber]           ; Drive=0 (=A)
            int 13h             ;
            jc reset            ; ERROR => reset again


    read:
            mov ax, 1000h      ; ES:BX = 1000:0000
            mov es, ax         ;
            mov bx, 0	       ;
            mov ah, 2           ; Load disk data to ES:BX
            mov al, 30          ; Load 17 sectors
            mov ch, 0           ; Cylinder=0
            mov cl, 2           ; Sector=2
            mov dh, 0           ; Head=0
            mov dl, [DriveNumber]           ; Drive=0
            int 13h             ; Read!
            jc read             ; ERROR => Try again
	    call clear
            jmp nwcmd      ; Jump to the program

writesect:

    reset3:                      ; Reset the floppy drive
            mov ax, 0           ;
            mov dl, [DriveNumber]           ; Drive=0 (=A)
            int 13h             ;
            jc reset3            ; ERROR => reset again


    read3:
            mov ax, 1000h      ; ES:BX = 1000:0000
            mov es, ax         ;
            mov bx, 0	       ;

            mov ah, 3           ; Write disk data from ES:BX
            mov al, 30		; Write 24 sectors
            mov ch, 0           ; Cylinder=0
            mov cl, 2           ; Sector=2
            mov dh, 0           ; Head=0
            mov dl, [DriveNumber]           ; Drive=0
            int 13h             ; Read!

            jc read3             ; ERROR => Try again

            jmp nwcmd      ; Jump to the program
	

charnochange: 
	push bx
	push cx
            mov ah, 9
            mov bx, 7
            mov cx, 1
            int 10h
	pop bx
	pop cx
        ret	


insert: cmp al, 0
	je doneinsertnochng
	mov dx, di	;insert text without replacing anything
	mov di, bx
instlp:	dec bx		;si contains startpoint, bx contains endpoint, al contains letter/byte
	cmp di, si
	jbe doneinsert
	mov ah, [bx]
	mov [di], ah	;uses 8 bit letters
	dec di
	jmp instlp
doneinsert: mov [di], al
	mov di, dx
doneinsertnochng:	ret

	


IFON db 0
IFTRUE times 100 db 0
BATCHPOS db 0,0
LOOPON db 0
LOOPPOS	db 0,0
controlc db 1Dh,'c'
vga db 0