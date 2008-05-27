ints:	;these are inits to be used in pmode or by 3rd party apps
	MOV EAX, 0
	MOV AX, CS

	SHL EAX, 16			; 16 bit left shif of EAX
	MOV AX, int30h			; AX points the the code of the Interrupt
	XOR BX, BX			; BX = 0
	MOV FS, BX			; FS = BX = 0

	CLI				; Interrupt Flag clear
	MOV [FS:30h*4], EAX		; Write the position of the Interrupt code into
					; the interrupt table (index 30h)
	STI				; Interrupt Flag set
	ret

int30h:
	cmp ah, 0
	je near int30hah0
	cmp ah, 1
	je near int30hah1
	cmp ah, 2
	je near int30hah2
	cmp ah, 3
	je near int30hah3
	cmp ah, 4
	je near int30hah4
	cmp ah, 5
	je near int30hah5
	cmp ah, 6
	je near int30hah6
	cmp ah, 7
	je near int30hah7
	cmp ah, 8
	je near int30hah8
	cmp ah, 9
	je near int30hah9
	ret

int30hah0:	;shutdown application
	jmp nwcmd

	dxcache db 0,0
	enddh db 0
	scrolledlines db 0

int30hah1:	;write string in si to screen, endchar in al
		;location on screen in (dl, dh)
		;modifier in bl

		;if (dl,dh) is unchanged, current position is used
		;screen must be in 3h mode!
		
		mov [startdl], dl
		mov [startdh], dh
		mov [endchar], al
		mov byte [scrolledlines], 0
		mov al, bl
		mov bx, 0
	intprint: 
		mov byte ah, [si]
		cmp ah, [endchar]
		je near intpmprnt
		mov bh, 0
		mov bl, dl
		mov cl, dh
		mov ch, 0
		cmp cx, 0
		je nocxint
		call intlnprntnm
		jmp intprint
	nocxint:
		mov bl, dl
		mov bh, 0
		call intlnprnt2
		jmp intprint
	intlnprntnm: 
		add bx, 160
		loop intlnprntnm
	intlnprnt2:
		cmp ah, 10
		je near intnewlineprnt
		cmp ah, 13
		je near intcarriagereturn
		cmp ah, 8
		je near backspaceprint
		call writecursor
		mov  byte [fs:bx], ah
		inc bx
		mov byte [fs:bx], al
		inc bx
		cmp byte [fs:bx], 0
		jne nobyteprnt
		cmp byte [writecursoron], 0
		je nobyteprnt
		mov byte [fs:bx], ' '
		inc bx
		mov byte [fs:bx], 7
		dec bx
	nobyteprnt:
		add dl,2
		add si, 1
		cmp byte [writecursoron], 0
		je forgetnextline
		cmp dl, 160
		jae nextlineint
forgetnextline:		ret
	
		endchar db 0
		startdl db 0
		startdh db 0
		loccache db 0,0
	writecursoron db 1

	writecursor:
		;ret		;no more cursor!!!
		cmp byte [writecursoron], 1
		jne backnowritecursor
		mov cx, ax
		mov [loccache], bx
		mov ax, 0
	writecursorloop:
		cmp bx, 0
		jbe writecursordn
		sub bx, 2
		inc ax
		jmp writecursorloop
	writecursordn:
		;ret
		mov [dxcache], dx
		add al, 1
		mov bx, ax
		mov dx, 03d4h
		mov al, 0Fh
		mov ah, 0Eh
		out dx, al
		mov dx, 03d5h
		mov al, bl
		out dx, al
		mov dx, 03d4h
		mov al, ah
		out dx, al
		mov dx, 03d5h
		mov al, bh
		out dx, al
		mov ax, cx
		mov bx, [loccache]
		mov dx, [dxcache]
	backnowritecursor:	ret

	cursorzero:
		mov cx, ax
		mov bx, 0
		mov ax, 0
		mov [loccache], bx
		ret
		

	nextlineint:
		inc dh
		sub bl, dl
		add bx, 160
		mov dl, 0
		cmp dh, 24
		ja scrollscreen
		jmp intprint
	
	scrollscreen:
		pusha
		mov byte [cursorcache], 0
		call clearmousecursor
		popa
		dec dh
		mov bx, 160
		mov cx, [fs:bx]
		mov bx, 0
		mov [fs:bx], cx
	scrollloop:
		cmp bx, 0FA0h
		ja near scrollloopdn
		add bx, 162
		mov cl, [fs:bx]
		mov ch, al
		sub bx, 160
		mov [fs:bx], cx
		jmp scrollloop
	scrollloopdn:
		add byte [scrolledlines], 1
		jmp intprint

	intcarriagereturn:
		sub bl, dl
		mov dl, 0
		inc si
		jmp intprint

	intnewlineprnt:
		add dh, 1
		add bx, 160
		inc si
		cmp dh, 24
		ja scrollscreen
		jmp intprint

	intpmprnt:	
			;returns with last location in (dl,dh)
		mov bl, al
		mov al, [endchar]
		mov ah, 1
		mov [enddh], dh
		mov [enddl], dl
	jmp videobuf2copy
	ret
enddl db 0

int30hah2:	;read string to si, endkey in al, max in cx
		;if endkey is 0, only one char is read
		mov bl, al
		call startin
	intinput:
		cmp bl, al
		je near doneintin
		cmp bl, 0
		je near doneintin
		call startin
		loop intinput
	startin:
		in al, 64h ; Status
		test al, 1 ; output buffer full?
		jz near intNOKEY
		test al, 20h ; PS2-Mouse?
		jnz near ps2mouse
		in al, 60h
		dec al
		jz near intNOKEY
		inc al
		mov di, scancode
		add di, 2
	searchscan: cmp di, noscan
		jae intcheckkey
		mov ah, [di]
		cmp al, ah
		je scanfound
		add di, 3
		jmp searchscan
	ps2mouse:
		pusha
	    	call int30hah9
		popa
		jmp startin
	scanfound:	
		cmp byte [lshift], 1
		je uppercasescan
		cmp byte [rshift], 1
		je uppercasescan
		cmp byte [caps], 1
		je uppercasescan
		sub di, 2
		mov al,[di]
		mov [si], al
		cmp byte [trans], 1
		je near intNOKEY
		inc si
		ret
	uppercasescan:
		sub di, 1
		mov al,[di]
		mov [si], al
		inc si
		ret
		
	intcheckkey:	;i actually mean down when i say up
		cmp byte [trans], 1
		je near intNOKEY
		cmp al, 1Ch
		je near entup
		cmp al, 0Eh
		je near backspace
		cmp al, 2Ah
		je near lshiftup
		cmp al, 36h
		je near rshiftup
		cmp al, 0AAh
		je near lshiftdown
		cmp al, 0B6h
		je near rshiftdown
		cmp al, 3Ah
		je near capslock
		cmp al, 48h
		je near upkeydown
		cmp al, 50h
		je near downkeydown
		jmp startin

	dlcheck:
		cmp dh, 0
		jbe bcktobck
		sub dh, 1
		mov dl, 160
		jmp bckprnt

	dhcheck: cmp dh, [startdh]
		jbe bcktobck
		cmp dl, 0
		jbe dlcheck
		jmp bckprnt

	bxcache db 0,0
	cxcache db 0,0
	bxcache3 db 0,0
	backspace:
		mov [bxcache], bx
		mov [cxcache], cx
		mov cl, dh
		mov bh, 0
		mov ch, 0
		mov bl, dl
	bcklp:  add bx, 160
		loop bcklp
		mov byte [si], 0
		sub bx, 4
		mov [bxcache3], bx
		call backspaceprint
		cmp bx, [bxcache3]
		je nomoreback
		dec si
		mov byte [si], 0
nomoreback:	mov bx, [bxcache]
		mov cx, [cxcache]
		jmp startin

	backspaceprint:
		cmp dl, [startdl]
		jbe dhcheck
	bckprnt: 
	call writecursor
		add bx, 2
		mov byte [fs:bx], ' '
		inc bx
		mov byte [fs:bx], 7
	mov [enddl], dl
		sub dl, 2
bcktobck: 
	mov [enddh], dh
	jmp videobuf2copy
	ret


downkeydown:
		cmp byte [lshift], 1
		je near screendownscroll
		cmp byte [rshift], 1
		je near screendownscroll
		jmp startin
upkeydown:
		cmp byte [lshift], 1
		je screenupscroll
		cmp byte [rshift], 1
		je screenupscroll
		jmp startin

screenupscroll:


screendownscroll:
		

	entup:	
		mov al, 13
		cmp bl, al
		je near doneintin
		cmp bl, 0
		je near doneintin
		mov byte [si], 13
		inc si
		mov byte [si], 10
		inc si
		ret

	lshiftup:
		mov byte [lshift], 1
		jmp startin
	rshiftup:
		mov byte [rshift], 1
		jmp startin
	lshiftdown:
		mov byte [lshift], 0
		jmp startin
	rshiftdown:
		mov byte [rshift], 0	
		jmp startin
	capslock:
		cmp byte [caps], 0
		je capslockon
		mov byte [caps], 0
		jmp startin
	capslockon:
		mov byte [caps], 1
		jmp startin
	trans db 0
	intNOKEY:
		cmp byte [si], 0
		jne NOKEYCHECK
		mov al, [si]
		jmp NOKEYDONE
	NOKEYCHECK:
		mov al, 0
	NOKEYDONE:
		cmp byte [trans], 1
		jne startin
	doneintin:
		mov ah, 2
		ret

	lshift 	db 0
	lctrl  	db 0
	lalt	db 0
	rshift 	db 0
	rctrl	db 0
	ralt	db 0
	caps	db 0

int30hah3:	;clear screen-pretty simple
		mov bx, 0
		mov dx, 0
	clearint:
		cmp bx, 0FA0h
		ja doneclearint
		mov byte [fs:bx],0
		inc bx
		jmp clearint
	doneclearint:
		mov cx, ax
		mov word [dxcache], 0
		mov ah, 3
		mov byte [enddh], 24
		mov byte [enddl], 160
		mov byte [startdh], 0
		mov byte [scrolledlines], 0
	jmp videobuf2copy
	ret

int30hah4:	;print string and read input into si
		;(dl,dh) and al apply

		mov [alcache], al
		mov [blcache], bl
		mov [sicache], si
		mov [startdl], dl
		mov [startdh], dh
	int30hah4lp:	mov si, [sicache]
		mov al, 0
		mov bl, 0
		call int30hah2
		mov [sicache], si
		cmp al, [alcache]
		je doneint30hah4
		dec si
		mov al, [si]
		mov [pmodechar], al
		mov si, pmodechar
		mov al, [blcache]
		mov bx, 0
		call intprint
		mov al, [alcache]
		mov bl, [blcache]
		jmp int30hah4lp
	doneint30hah4:
		ret
	sicache	db 0,0
	alcache db 0
	blcache db 0
	pmodechar db 0,0

int30hah5:	;get char transparent
		;puts char in al
		;waits if al is zero
	mov bl, 0
	mov si, charcache
	mov byte [trans], 1
	cmp al, 0
	jne int30hah5st
	mov byte [trans], 0
int30hah5st: 	call startin
	mov byte [trans], 0
	mov al, [charcache]
	ret

int30hah6:	;print char
		;same rules as int30hah1, except that char is in al
		;no startdl, startdh
	mov si, charcache
	mov [charcache], al
	mov byte [endchar], 0
	mov al, bl
	call intprint
	mov ah, 6
	mov al, [charcache]
	ret

int30hah7:	;play sound
		;bx is the length, cx is the inverse of the frequency
	in al, 61h
	and al, 0fch
	xor al, 2
	out 61h, al
	mov ax, cx
	loop $
	mov cx, ax
	dec bx
	cmp bx, 0
	jne int30hah7
	ret

int30hah8:	;load character set, bios must still be alive-i.e. no protected mode
	mov ax, 12h
	mov bx, 0
	int 10h
	mov si, font
fontload:
	mov ah, 09h
	mov bx, 7
	mov cx, 1
	mov al, [si]
	int 10h
	inc si
	mov bx, 0
	mov cx, 0
	mov dx, 0
pixelload:
	cmp cx, 7
	ja nextrow
	cmp dx, 13
	ja doneloadpixels
	mov ah, 0dh
	mov bh, 0
	int 10h
	cmp al, 0
	je pixeloff
	cmp al, 1
	jae pixelon
	jmp pixelload
doneloadpixels:
	inc si
	cmp si, fontend2
	jae donefontload
	cmp byte [si], 0
	je doneloadpixels
	jmp fontload
donefontload:
	ret
	
nextrow: mov cx, 0
	add dx, 1
	inc si
	jmp pixelload
pixeloff:
	inc cx
	jmp pixelload
cxcache2 db 0,0
pixelon:
	mov al, 1
	mov [cxcache2], cx
pixelloop:
	cmp cx, 0
	je nopixelloop
	ror al, 1
	loop pixelloop
nopixelloop:
	add [si], al
	mov cx, [cxcache2]
	inc cx
	jmp pixelload

cursorcache db 0,0
mouseon	db 0

int30hah9:		;get mouse info
	cmp byte [mouseon],1
	je .maincall
	call MAINP
	mov byte [mouseon],1
	.maincall:
	call mousemain
	ret

startmousepos dw 0FFFh
endmousepos dw 0FFFh	

int30hah9dr:		;draw cursor (dl,dh) al=1=on al=0=off
	cmp al, 0
	je near nocursor
	mov bh, 0
	mov bl, dl
	mov cl, dh
	mov ch, 0
	cmp cx, 0
	je near nolinecursorfnd
cursorfnd:
	add bx, 160
	loop cursorfnd
nolinecursorfnd:
	mov [bxcache2], bx
	mov ax, [fs:bx]
	mov [cursorcache], ax
	mov al, 'X'
	mov bl, 7
	mov byte [writecursoron], 0
	call int30hah6
	mov byte [writecursoron], 1
	cmp byte [cursorcache],0
	je near cursorspace
	mov bx, [bxcache2]
	cmp byte [LBUTTON], 1
	je near clickmouse
	call clearmouseselect
	mov word [endmousepos], 0fffh
	mov word [startmousepos], 0fffh
	ret
clickmouse:
	sub dl, 2
	call nocursor
	mov bx, [bxcache2]
	call clearmouseselect
	cmp word [endmousepos], 0FA0h
	ja near startclick
	cmp word [startmousepos], 0FA0h
	ja near startclick
	mov [endmousepos], bx
	jmp textselect
startclick:
	mov [startmousepos], bx
	mov [endmousepos], bx
	jmp textselect
switchtextselect:
	mov bx, [endmousepos]
	mov cx, [startmousepos]
	jmp textselectloop
textselect:
	mov bx, [startmousepos]
	mov cx, [endmousepos]
	mov si, copybuffer
	cmp cx, bx
	jb switchtextselect
textselectloop:
	cmp bx, cx
	ja donecopytext
	cmp bx, 0FA0h
	ja donecopytext
	mov al, [fs:bx]
	cmp al, 0
	je zerotextselect
	mov [si], al
	mov ah, 0F8h
	inc bx
	mov [fs:bx], ah
	inc bx
	inc si
	jmp textselectloop
donecopytext:
	inc si
	mov byte [si], 0
	mov bx, [bxcache2]
	ret
bxcache2 db 0,0
zerotextselect:
	mov al, 13
	mov [si], al
	inc si
	mov al, 10
	mov [si], al
	inc si
findnext:
	cmp bx, 0FA0h
	ja donefind
	cmp bx, cx
	ja donefind
	inc bx
	mov byte [fs:bx], 0F8h
	inc bx
	cmp byte [fs:bx], 0
	je findnext
copyloop: 
	jmp textselectloop
	
donefind: jmp textselectloop

switchclearmouse:
	mov bx, [endmousepos]
	mov cx, [startmousepos]
	jmp clearmouseloop
clearmouseselect:
	mov bx, [bxcache2]
	cmp word [startmousepos], 0FA0h
	ja doneclearmouse
	cmp word [endmousepos], 0FA0h
	ja doneclearmouse
	mov bx, [startmousepos]
	mov cx, [endmousepos]
	cmp cx, bx
	jb switchclearmouse
clearmouseloop:
	cmp bx, cx
	ja doneclearmouse
	cmp bx, 0FA0h
	ja doneclearmouse
	mov ah, 07h
	inc bx
	mov [fs:bx], ah
	inc bx
	jmp clearmouseloop
doneclearmouse:
	mov bx, [bxcache2]
	ret
cursorspace:
	mov byte [cursorcache],' '
	cmp byte [LBUTTON], 1
	je clickmouse
	mov bx, [bxcache2]
	call clearmouseselect
	mov word [endmousepos], 0fffh
	mov word [startmousepos], 0fffh
	ret
nocursor:	
	mov al, [cursorcache]
	mov bl, [cursorcache + 1]
	mov byte [writecursoron], 0
	call int30hah6
	mov byte [writecursoron], 1
	ret	

endstring db 0,0
arraystring db 0,0

int30hah10:		;basicly, this will do everything. This will edit an array in si
			;using an array seperator in cx, endstring in bx, (dl,dh), and modifier in al
			;note that the mouse should be used to copy stuff
	mov [si], cx
	add si, 2
	mov [endstring], bx
	mov [arraystring], si
	call input
	mov bx, [endstring]
	mov si, buftxt
	call tester
	cmp al, 1
	je doneint30hah10
doneint30hah10:
	
	
scancode:
	db '1','!',2h
	db '2','@',3h
	db '3','#',4h
	db '4','$',5h
	db '5','%',6h
	db '6','^',7h
	db '7','&',8h
	db '8','*',9h
	db '9','(',0Ah
	db '0',')',0Bh
	db '-','_',0Ch
	db '=','+',0Dh
	db 'q','Q',10h
	db 'w','W',11h
	db 'e','E',12h
	db 'r','R',13h
	db 't','T',14h
	db 'y','Y',15h
	db 'u','U',16h
	db 'i','I',17h
	db 'o','O',18h
	db 'p','P',19h
	db '[','{',1Ah
	db ']','}',1Bh
	db 'a','A',1Eh
	db 's','S',1Fh
	db 'd','D',20h
	db 'f','F',21h
	db 'g','G',22h
	db 'h','H',23h
	db 'j','J',24h
	db 'k','K',25h
	db 'l','L',26h
	db ';',':',27h
	db 27h,22h,28h
	db '`','~',29h
	db '\','|',2Bh
	db 'z','Z',2Ch
	db 'x','X',2Dh
	db 'c','C',2Eh
	db 'v','V',2Fh
	db 'b','B',30h
	db 'n','N',31h
	db 'm','M',32h
	db ',','<',33h
	db '.','>',34h
	db '/','?',35h
	db ' ',' ',39h
noscan: