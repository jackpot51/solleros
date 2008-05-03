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

	intlnprntnm: 
		add bx, 160
		loop intlnprntnm
		cmp ah, 8
		je near backspaceprint
		mov  byte [gs:bx], ah
		inc bx
		mov byte [gs:bx], al
		add dl,2
		call writecursor
		add si, 1
		cmp dl, 160
		jae nextlineint
		jmp intprint
	
		endchar db 0
		startdl db 0
		startdh db 0
		loccache db 0,0


	writecursor:
		mov cx, ax
		mov [dxcache], dx
		mov ax, 0
	clmfnd:	cmp dl, 0
		je rowfnd
		sub dl, 2
		inc ax
		jmp clmfnd
	rowfnd: cmp dh, 0
		je crsbck
		sub dh, 1
		add ax, 80
		jmp rowfnd
	crsbck: mov [loccache], ax
		mov dx, 03d4h
		mov al, 0fh
		out dx, al
		mov dx, 03d5h
		mov ax, [loccache]
		out dx, al
		mov dx, 03d4h
		mov al, 0eh
		out dx, al
		mov dx, 03d5h
		mov al, ah
		out dx, al
		mov ax, cx
		mov dx, [dxcache]
		ret

	cursorzero:
		mov ax, 0
		jmp crsbck

	nextlineint:
		inc dh
		mov dl, 0
		jmp intprint
	
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

	backspaceprint:
		inc si
		cmp dl, [startdl]
		jbe dhcheck
	bckprnt: sub dl, 2
		call writecursor
		sub bx, 2
		mov byte [gs:bx], ' '
		inc bx
		mov byte [gs:bx], al
		jmp intprint

	intcarriagereturn:
		mov byte dl, 0
		inc si
		jmp intprint

	intnewlineprnt:
		add byte dh, 1
		inc si
		jmp intprint

	intpmprnt:	
			;returns with last location in (dl,dh)
		mov bl, al
		mov al, [endchar]
		mov ah, 1
		ret

int30hah2:	;read string to si, endkey in al
		;if endkey is 0, only a char is read
		mov bl, al
		jmp startin
	intinput:
		cmp bl, al
		je near doneintin
		cmp bl, 0
		je near doneintin
	startin:
		in al, 64h ; Status
		test al, 1 ; output buffer full?
		jz near intNOKEY
		test al, 20h ; PS2-Mouse?
		jnz near intNOKEY
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
		inc si
		jmp intinput
	uppercasescan:
		sub di, 1
		mov al,[di]
		mov [si], al
		inc si
		jmp intinput
		
	intcheckkey:
		cmp al, 2Ah
		je lshiftup
		cmp al, 36h
		je rshiftup
		cmp al, 0AAh
		je lshiftdown
		cmp al, 0B6h
		je rshiftdown
		cmp al, 3Ah
		je capslock
		jmp startin

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
	intNOKEY:
		jmp startin
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
	clearint:
		cmp bx, 0FFh
		je doneclearint
		mov byte [gs:bx],0
		inc bx
		jmp clearint
	doneclearint
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
	int30hah4lp:	call int30hah2
		mov si, [sicache]
		mov al, [blcache]
		mov bx, 0
		call intprint
		mov si, [sicache]
		mov al, [alcache]
		mov bl, [blcache]
		jmp int30hah4lp
	sicache	db 0,0
	alcache db 0
	blcache db 0

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
	db 8,8,0Eh
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
noscan: