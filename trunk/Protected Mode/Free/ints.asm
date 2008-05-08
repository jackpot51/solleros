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

int30hah1:	;write string in si to screen, endchar in al
		;location on screen in (dl, dh)
		;modifier in bl

		;if (dl,dh) is unchanged, current position is used
		;screen must be in 3h mode!
		
		mov [startdl], dl
		mov [startdh], dh
		mov [endchar], al
		mov al, bl
		mov bx, 0
	intprint: 
		mov byte ah, [si]
		cmp ah, [endchar]
		je near intpmprnt
		cmp ah, 10
		je near intnewlineprnt
		cmp ah, 13
		je near intcarriagereturn
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
		cmp ah, 8
		je near backspaceprint
		call writecursor
		mov  byte [gs:bx], ah
		inc bx
		mov byte [gs:bx], al
		inc bx
		cmp byte [gs:bx], 0
		jne nobyteprnt
		mov byte [gs:bx], ' '
		inc bx
		mov byte [gs:bx], 7
		dec bx
	nobyteprnt:
		add dl,2
		add si, 1
		cmp dl, 160
		jae nextlineint
		ret
	
		endchar db 0
		startdl db 0
		startdh db 0
		loccache db 0,0
	writecursoron db 1

	writecursor:
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
		jmp writecursordn
		

	nextlineint:
		inc dh
		sub bl, dl
		add bx, 160
		mov dl, 0
		call writecursor
		cmp dh, 25
		jae scrollscreen
		jmp intprint
	
	scrollscreen:
		pusha
		call clearmousecursor
		mov dl, 160
		mov dh, 24
		mov al, 1
		call int30hah9dr
		dec dh
		sub bx, 160
		call writecursor
		mov bx, 0
		mov ax, 0
		mov [gs:bx], ax
		mov bx, 160
		mov ax, [gs:bx]
		mov bx, 0
		mov [gs:bx], ax
	scrollloop:
		cmp bx, 0FA0h
		jae near intprint
		add bx, 162
		mov ax, [gs:bx]
		mov word [gs:bx], 0
		sub bx, 160
		mov [gs:bx], ax
		jmp scrollloop

	intcarriagereturn:
		sub bl, dl
		mov dl, 0
		call writecursor
		inc si
		jmp intprint

	intnewlineprnt:
		add dh, 1
		add bx, 160
		call writecursor
		inc si
		cmp dh, 25
		jae scrollscreen
		jmp intprint

	intpmprnt:	
			;returns with last location in (dl,dh)
		mov bl, al
		mov al, [endchar]
		mov ah, 1
		ret

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
		jmp startin

	dlcheck:
		cmp dh, 0
		jbe near intprint
		sub dh, 1
		mov dl, 160
		jmp bckprnt

	dhcheck: cmp dh, [startdh]
		jbe intprint
		cmp dl, 0
		jbe dlcheck
		jmp bckprnt

	bxcache db 0,0
	cxcache db 0,0
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
		dec si
		mov byte [si], 0
nomoreback:	sub bx, 4
		call backspaceprint
		mov bx, [bxcache]
		mov cx, [cxcache]
		jmp startin

	backspaceprint:
		cmp dl, [startdl]
		jbe dhcheck
	bckprnt: call writecursor
		add bx, 2
		mov byte [gs:bx], ' '
		inc bx
		mov byte [gs:bx], 7
		sub dl, 2
		ret

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
		jae doneclearint
		mov byte [gs:bx],0
		inc bx
		jmp clearint
	doneclearint:
		mov cx, ax
		mov dx, 0
		mov word [dxcache], 0
		call cursorzero
		mov bx, 0
		mov ah, 3
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
	cmp cx, 8
	je nextrow
	cmp dx, 14
	je doneloadpixels
	mov ah, 0dh
	int 10h
	cmp al, 0
	je pixeloff
	cmp al, 1
	jae pixelon
	jmp pixelload
doneloadpixels:
	inc si
	cmp si, fontend
	jae donefontload
	jmp fontload
donefontload:
	ret
	
nextrow: mov cx, 0
	add dx, 1
	inc si
	jmp pixelload
pixeloff:
	mov al, 0
	add [si], al
	inc cx
	jmp pixelload
pixelon:
	mov al, 1
	push cx
pixelloop:
	cmp cx, 0
	je nopixelloop
	ror al, 1
	loop pixelloop
nopixelloop:
	add [si], al
	pop cx
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
	mov ax, [gs:bx]
	mov [cursorcache], ax
	mov al, 'X'	
	mov bl, 7
	mov byte [writecursoron], 0
	call int30hah6
	mov byte [writecursoron], 1
	cmp byte [cursorcache],0
	je near cursorspace
	call clearmouseselect
	mov bx, [bxcache2]
	cmp byte [LBUTTON], 1
	je near clickmouse
	mov word [endmousepos], 0fffh
	mov word [startmousepos], 0fffh
	ret
clickmouse:
	sub dl, 2
	call nocursor
	mov bx, [bxcache2]
	cmp word [endmousepos], 0FA0h
	jae near startclick
	cmp word [startmousepos], 0FA0h
	jae near startclick
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
	mov al, [gs:bx]
	cmp al, 0
	je zerotextselect
	mov [si], al
	cmp bx, cx
	jae donecopytext
	cmp bx, 0FA0h
	jae donecopytext
	mov ah, 0F8h
	inc bx
	mov [gs:bx], ah
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
	mov al, 10
	mov [si], al
	inc si
	mov al, 13
	mov [si], al
	inc si
findnext:
	cmp bx, 0FA0h
	jae donefind
	cmp bx, cx
	jae donefind
	inc bx
	mov byte [gs:bx], 0F8h
	inc bx
	cmp byte [gs:bx], 0
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
	jae doneclearmouse
	cmp word [endmousepos], 0FA0h
	jae doneclearmouse
	mov bx, [startmousepos]
	mov cx, [endmousepos]
	cmp cx, bx
	jb switchclearmouse
clearmouseloop:
	cmp bx, cx
	jae doneclearmouse
	cmp bx, 0FA0h
	jae doneclearmouse
	mov ah, 07h
	inc bx
	mov [gs:bx], ah
	inc bx
	jmp clearmouseloop
doneclearmouse:
	mov bx, [bxcache2]
	ret
cursorspace:
	mov byte [cursorcache],' '
	call clearmouseselect
	mov bx, [bxcache2]
	cmp byte [LBUTTON], 1
	je clickmouse
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

int30hah10:		;basicly, this will do everything. This will edit an array in si
			;using an array seperator in cx, endstring in bx, (dl,dh), and modifier in al
			;note that the mouse should be used to copy stuff
	
	
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

font:	
	db	'A',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'B',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'C',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'D',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'E',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'F',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'G',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'H',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'I',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'J',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'K',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'L',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'M',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'N',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'O',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'P',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'Q',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'R',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'S',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'T',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'U',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'V',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'W',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'X',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'Y',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'Z',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'a',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'b',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'c',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'd',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'e',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'f',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'g',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'h',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'i',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'j',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'k',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'l',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'm',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'n',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'o',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'p',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'q',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'r',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	's',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	't',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'v',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'w',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'x',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'y',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'z',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'1',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'2',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'3',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'4',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'5',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'6',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'7',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'8',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'9',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'0',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'`',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'~',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'!',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'@',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'#',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'$',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'%',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'^',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'&',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'*',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'(',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	')',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'_',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'-',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'+',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'=',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'[',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	']',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'{',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'}',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	';',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	':',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	27h,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	22h,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	',',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'.',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'/',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'<',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'>',0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	'?',0,0,0,0,0,0,0,0,0,0,0,0,0,0
fontend: