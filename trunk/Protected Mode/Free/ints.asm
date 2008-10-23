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
db "INTS HERE",0

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
	cmp ah, 10
	je near int30hah10
	ret

int30hah0:	;shutdown application
	jmp nwcmd

	dxcache db 0,0
	enddh db 0
	scrolledlines db 0

	colorah1 db 0

int30hah1:	;write string in si to screen, endchar in al
		;location on screen in (dl, dh)
		;modifier in bl

		;if (dl,dh) is unchanged, current position is used
		shr dl, 1
		shl dl, 1
		mov [startdl], dl
		mov [startdh], dh
		mov [endchar], al
		mov byte [scrolledlines], 0
		mov [colorah1], bl
		mov bx, 0
	intprint: 
		mov ah, [si]
		cmp ah, [endchar]
		je near intpmprnt
		mov bh, 0
		mov bl, dl
		mov cl, dh
		mov ch, 0
		cmp cx, 0
		je nocxint
	intlnprntnm: 
		add bx, 160
		dec cx
		cmp cx, 0
		je intlnprnt2
		jmp intlnprntnm
	nocxint:
		mov bl, dl
		mov bh, 0
	intlnprnt2:
		cmp ah, 10
		je near intnewlineprnt
		cmp ah, 13
		je near intcarriagereturn
		mov  byte [fs:bx], ah
		inc bx
		mov al, [colorah1]
		mov byte [fs:bx], al
		inc bx
		cmp byte [fs:bx], 0
		jne nobyteprnt
		mov byte [fs:bx], ' '
		inc bx
		mov byte [fs:bx], 7
		dec bx
	nobyteprnt:
		add dl,2
		add si, 1
		cmp dl, 160
		jae nextlineint
forgetnextline:	jmp intprint
	
		endchar db 0
		startdl db 0
		startdh db 0
		loccache db 0,0
		

	nextlineint:
		inc dh
		mov al, dl
		mov ah, 0
		sub bx, ax
		add bx, 160
		mov dl, 0
		cmp dh, 24
		ja scrollscreen
		mov ah, [si]
		cmp ah, [endchar]
		je near intpmprnt
		jmp intlnprnt2	

	scrollscreen:
		dec dh
		mov bx, 160
		mov cx, [fs:bx]
		mov bx, 0
		mov [fs:bx], cx
	scrollloop:
		mov cx, videobufend
		sub cx, videobuf2
		cmp bx, cx
		ja near intprint
		add bx, 162
		mov cl, [fs:bx]
		mov ch, al
		sub bx, 160
		mov [fs:bx], cx
		jmp scrollloop

	intcarriagereturn:
		sub bl, dl
		mov dl, 0
		inc si
		jmp intprint

	intnewlineprnt:
		add dh, 1
		add bx, 160
		inc si
		cmp dh, 29
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

enddl db 0
maxcx dw 0
printbackspaces db 0
int30hah2:	;read string to si, endkey in al, max in cx
		;if endkey is 0, only one char is read
		mov bl, al
		mov [maxcx], cx
		jmp startin
	intinput:
		mov [maxcx], cx
		cmp bl, al
		je near doneintin
		cmp bl, 0
		je near doneintin
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
		jae near intcheckkey
		mov ah, [di]
		cmp al, ah
		je near scanfound
		add di, 3
		jmp searchscan
entupinput:
	loop intinput
	ret

Meax dd 0
Mebx dd 0
Mecx dd 0
Medx dd 0
Medi dd 0
Mesi dd 0

	ps2mouse:
		cmp byte [guion], 0
		je near intNOKEY
		mov [Meax], eax
		mov [Mebx], ebx
		mov [Mecx], ecx
		mov [Medx], edx
		mov [Medi], edi
		mov [Mesi], esi
		call maincall2
		mov eax, [Meax]
		mov ebx, [Mebx]
		mov ecx, [Mecx]
		mov edx, [Medx]
		mov edi, [Medi]
		mov esi, [Mesi]
;		cmp byte [trans], 1
;		je near intNOKEY
;		pusha
;	    	call int30hah9
;		popa
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
		mov cx, [maxcx]
		jmp entupinput

	uppercasescan:
		sub di, 1
		mov al,[di]
		mov [si], al
		inc si
		mov cx, [maxcx]
		jmp entupinput
		
	intcheckkey:	;i actually mean down when i say up
		cmp al, 2Ah
		je near lshiftup
		cmp al, 36h
		je near rshiftup
		cmp al, 1Ch
		je near entup
		cmp al, 0AAh
		je near lshiftdown
		cmp al, 0B6h
		je near rshiftdown
		cmp al, 3Ah
		je near capslock
		cmp byte [trans], 1
		je near intNOKEY
		cmp byte [printbackspaces], 0
		je near intNOKEY
		cmp al, 0Fh
		je near tabdown
		cmp al, 0Eh
		je near backspace
		jmp startin
	tabdown:
		cmp byte [commandline], 1
		jne near startin
		jmp startin
	dlcheck:
		cmp dh, 0
		jbe near bcktobck
		sub dh, 1
		mov dl, 160
		jmp bckprnt

	dhcheck: cmp dh, [startdh]
		jbe near bcktobck
		cmp dl, 0
		jbe dlcheck
		jmp bckprnt

	bxcache db 0,0
	cxcache db 0,0
	bxcache3 db 0,0
	backspace:
		mov [bxcache], bx
		mov [cxcache], cx
		cmp byte [trans], 1
		je nomoreback
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
		add bx, 2
		mov byte [fs:bx], ' '
		inc bx
		mov byte [fs:bx], 7
	mov [enddl], dl
		sub dl, 2
bcktobck: 
	mov [enddh], dh
	jmp videobuf2copy

	entup:	
		mov al, 13
		mov byte [si], 13
		cmp byte [trans], 1
		je near intNOKEY
		mov byte [si], 0
		cmp bl, al
		je near doneintin
		cmp bl, 0
		je near doneintin
		mov byte [si], 13
		inc si
		mov byte [si], 10
		inc si
		mov cx, [maxcx]
		jmp entupinput

	lshiftup:
		mov byte [lshift], 1
		cmp byte [trans], 1
		je near intNOKEY
		jmp startin
	rshiftup:
		mov byte [rshift], 1
		cmp byte [trans], 1
		je near intNOKEY
		jmp startin
	lshiftdown:
		mov byte [lshift], 0
		cmp byte [trans], 1
		je near intNOKEY
		jmp startin
	rshiftdown:
		mov byte [rshift], 0
		cmp byte [trans], 1
		je near intNOKEY	
		jmp startin
	capslock:
		cmp byte [caps], 0
		je capslockon
		mov byte [caps], 0
		cmp byte [trans], 1
		je near intNOKEY
		jmp startin
	capslockon:
		mov byte [caps], 1
		cmp byte [trans], 1
		je near intNOKEY
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
		mov cx, [maxcx]
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
		mov cx, videobufend
		sub cx, videobuf2
	clearint:
		cmp bx, cx
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
commandline db 0
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
		mov byte [printbackspaces], 1
		call int30hah2
		mov byte [printbackspaces], 0
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
		mov byte [commandline], 0
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
	mov [si], bl
	inc si
	mov [si], bl
	dec si
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

currentfont db 0

int30hah8:	;load character set, bios must still be alive-i.e. no protected mode
	mov ax, 12h
	mov bx, 0
	int 10h
	mov si, fonts
fontload:
	mov ah, 09h
	mov bx, 7
	mov cx, 1
	mov al, [currentfont] 
	int 10h
	mov al, [currentfont] 
	mov [si], al
	inc al
	mov [currentfont], al
	inc si
	mov bx, 0
	mov cx, 0
	mov dx, 0
pixelload:
	cmp cx, 7
	ja nextrow
	cmp dx, 14
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
	mov al, 128
	mov bl, 7
	call int30hah6
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
	cmp bx, 0x12C0
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
	call int30hah6
	ret	

endstring db 0,0
arraystring db 0,0

int30hah10:		;basicaly, this will do everything. This will edit an array in si
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
doneint30hah10: ret

int30hah11:		;This will retrieve the position of a file with the name in si 
			;and put its position in bx and file separator in cx

	
	
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
