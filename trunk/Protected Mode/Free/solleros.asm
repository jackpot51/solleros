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
	call int30hah4
	jmp passenter
pwdrgt:	call clear
	mov cx, 200h
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
fndprg2: add bx, 2
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
currentdir db 0
dir:	mov si, progstart
	dirnxt:	mov al, [si]
		mov ah, 0
		cmp al, 5
		je dirfnd
		cmp al, 7
		je dirfnd3
		cmp al, 6
		je dirfnd3
		;cmp al, 10
		;je currentdirup
		;cmp al, [currentdir]
		;je currentdirdown
		inc si
		cmp si,  commandlst
		jae dirdn
		jmp dirnxt
	typetable db 6,4,0,"batch",0,7,4,0,"document",0,10,4,0,"folder",0,5,4,0,"executable",0
	currentdirup:
		inc si
		mov al, [si]
		mov [currentdir], al
		jmp dirfnd2
	currentdirdown:
	dirfnd3:
		inc si
		cmp si, progend
		jbe dirnxt
		dec si
		jmp dirfnd
	dirfnd:	inc si
		mov al, [si]
		mov ah, 0
		cmp al, 4
		je dirfnd2
		inc si
		cmp si,  commandlst
		jae dirdn
		jmp dirnxt
	dirfnd2: add si, 2
		call print
		mov di, si
		mov si, line
		call print
		mov si, di
		cmp si,  commandlst
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
	push dx
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
	pop dx
	ret

realmode:
   and al,0xFE     ; back to realmode
   mov  cr0, eax   ; by toggling bit again
   sti
   ret

sector:
	call realmode
    reset:                      ; Reset the floppy drive
            mov ax, 0           ;
            mov dl, [DriveNumber]           ; Drive=0 (=A)
            int 13h             ;
            jc reset            ; ERROR => reset again


    read:
            mov ax, 2000h      ; ES:BX = 2000:0000
            mov es, ax         ;
            mov bx, 0	       ;
            mov ah, 2           ; Load disk data to ES:BX
            mov al, 17          ; 
            mov ch, 0           ; Cylinder=0
            mov cl, 2           ; Sector=2
            mov dh, 0           ; Head=0
            mov dl, [DriveNumber]           ; Drive=0
            int 13h             ; Read!
            jc read             ; ERROR => Try again
		; Stop the floppy motor from spinning 
ReadFloppy3:
	mov bx, 2200h
	mov ah, 2
	mov al,		18 		; The Second Head Full
	mov ch, 0
	mov cl, 	1
	mov dh, 	1	; Set it to the second head
	mov dl, [DriveNumber]
	int 13h			; Read the floppy disk.

	jc ReadFloppy3		; If there was a error, try again.

ReadFloppy4:
	mov bx, 4600h
	mov ah, 2
	mov al,		18 		; The Third Head Full
	mov ch, 	1
	mov cl, 	1
	mov dh, 	0	; Set it to the third head
	mov dl, [DriveNumber]
	int 13h			; Read the floppy disk.

	jc ReadFloppy4		; If there was a error, try again.

ReadFloppy5:
	mov bx, 6A00h
	mov ah, 2
	mov al,		18 		; The Third Head Full
	mov ch, 	1
	mov cl, 	1
	mov dh, 	1	; Set it to the third head
	mov dl, [DriveNumber]
	int 13h			; Read the floppy disk.

	jc ReadFloppy5		; If there was a error, try again.
 
        mov dl,		[DriveNumber]	; Select which motor to stop 

	; Select Stop Floppy Motor function:
	mov edx, 0x3f2
	mov al, 0x0c

	; Stop floppy motor:
	out dx, al      ; Floppy Motor stopped!
	    call pmode
	call clear
		jmp nwcmd

writesect:
	 call realmode
    reset3:                      ; Reset the floppy drive
            mov ax, 0           ;
            mov dl, [DriveNumber]           ; Drive=0 (=A)
            int 13h             ;
            jc reset3            ; ERROR => reset again


    read3:
            mov ax, 2000h      ; ES:BX = 2000:0000
            mov es, ax         ;
            mov bx, 0	       ;

            mov ah, 3           ; Write disk data from ES:BX
            mov al, 17		; 
            mov ch, 0           ; Cylinder=0
            mov cl, 2           ; Sector=2
            mov dh, 0           ; Head=0
            mov dl, [DriveNumber]           ; Drive=0
            int 13h             

            jc read3             ; ERROR => Try again
		; Stop the floppy motor from spinning
writeFloppy2:
	mov bx, 2200h
	mov ah, 3
	mov al,		18 		; The Second Head Full
	mov ch, 0
	mov cl, 	1
	mov dh, 	1	; Set it to the second head
	mov dl, [DriveNumber]
	int 13h			; Read the floppy disk.

	jc writeFloppy2		; If there was a error, try again. 

writeFloppy3:
	mov bx, 4600h
	mov ah, 3
	mov al,		18 		; The Third Head Full
	mov ch, 1
	mov cl, 	1
	mov dh, 	0	; Set it to the third head
	mov dl, [DriveNumber]
	int 13h			; Read the floppy disk.

	jc writeFloppy3		; If there was a error, try again.

writeFloppy4:
	mov bx, 6A00h
	mov ah, 2
	mov al,		18 		; The Third Head Full
	mov ch, 1
	mov cl, 	1
	mov dh, 	1	; Set it to the third head
	mov dl, [DriveNumber]
	int 13h			; Read the floppy disk.

	jc writeFloppy4		; If there was a error, try again.
 
        mov dl,		[DriveNumber]	; Select which motor to stop 

	; Select Stop Floppy Motor function:
	mov edx, 0x3f2
	mov al, 0x0c

	; Stop floppy motor:
	out dx, al      ; Floppy Motor stopped!
	call pmode
	call clear
            jmp nwcmd      ; Jump to the program

	


IFON db 0
IFTRUE times 100 db 0
BATCHPOS db 0,0
LOOPON db 0
LOOPPOS	db 0,0