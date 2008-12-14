ints:	;these are inits to be used in pmode or by 3rd party apps

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
	ret

int30hah0:	;shutdown application
	jmp nwcmd
	dxcache db 0,0
	enddh db 0
	scrolledlines db 0

	colorah1 db 0


	charcache db 0,0,0


    print:
		mov ax, 0
		mov bx, 7

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
		mov  byte [videobuf2 + bx], ah
		inc bx

		mov al, [colorah1]
		mov byte [videobuf2 + bx], al
		inc bx
		cmp byte [videobuf2 + bx], 0
		jne nobyteprnt
		mov byte [videobuf2 + bx], ' '
		inc bx
		mov byte [videobuf2 + bx], 7
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
		mov cx, [videobuf2 + bx]
		mov bx, 0
		mov [videobuf2 + bx], cx
	scrollloop:

		mov cx, videobufend

		sub cx, videobuf2
		cmp bx, cx
		ja near intprint
		add bx, 162
		mov cl, [videobuf2 + bx]
		mov ch, al
		sub bx, 160
		mov [videobuf2 + bx], cx
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
ret

enddl db 0
maxcx dw 0

printbackspaces db 0
int30hah2:	;read string to si, endkey in al, max in cx
		;if endkey is 0, only one char is read
		mov bl, al

		mov [maxcx], cx
		jmp startin
entupinput:
	loop intinput

	ret


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
	searchscan:
		mov di, scancode
		cmp al, 40h
		jae near intcheckkey
		mov ah, 0
		shl al, 1
		add di, ax
		shr al, 1
		mov ah, [di]
		cmp ah, 0
		je near intcheckkey
		jmp scanfound



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
		jmp startin
	scanfound:	
		cmp byte [lshift], 1
		je uppercasescan
		cmp byte [rshift], 1
		je uppercasescan
		cmp byte [caps], 1
		je uppercasescan
		mov al,[di]
		mov [si], al
		cmp byte [trans], 1
		je near intNOKEY
		inc si
		mov cx, [maxcx]
		jmp entupinput

	uppercasescan:
		add di, 1
		mov al,[di]
		mov [si], al
		cmp byte [trans], 1
		je near intNOKEY
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
		cmp al, 0Eh
		je near backspace
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
		mov ecx, 0
		mov cl, dh
		mov bh, 0
		mov ch, 0
		mov bl, dl
		cmp cx, 0
		je nobcklp
	bcklp:  add bx, 160
		loop bcklp
	nobcklp:
		mov byte [si], 0
		sub bx, 4
		mov [bxcache3], bx	
	backspaceprint:
		cmp dl, [startdl]
		jbe dhcheck
	bckprnt: add bx, 2
		mov byte [videobuf2 + bx], ' '
		inc bx
		mov byte [videobuf2 + bx], 7
		mov [enddl], dl
		sub dl, 2
	bcktobck: mov [enddh], dh
		cmp bx, [bxcache3]
		je nomoreback
		dec si
nomoreback:	mov bx, [bxcache]
		mov cx, [cxcache]
call videobuf2copy
		jmp startin

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

clear:

int30hah3:	;clear screen-pretty simple
		mov bx, 0
		mov dx, 0

		mov cx, videobufend

		sub cx, videobuf2
	clearint:
		cmp bx, cx
		ja doneclearint
		mov byte [videobuf2 + bx],0
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
	
scancode:
	db 0,0		;,0h
	db 0,0		;,1h
	db '1','!'	;,2h
	db '2','@'	;,3h
	db '3','#'	;,4h
	db '4','$'	;,5h
	db '5','%'	;,6h
	db '6','^'	;,7h
	db '7','&'	;,8h
	db '8','*'	;,9h
	db '9','('	;,0Ah
	db '0',')'	;,0Bh
	db '-','_'	;,0Ch
	db '=','+'	;,0Dh
	db 0,0		;,0Eh
	db 0,0		;,0Fh
	db 'q','Q'	;,10h
	db 'w','W'	;,11h
	db 'e','E'	;,12h
	db 'r','R'	;,13h
	db 't','T'	;,14h
	db 'y','Y'	;,15h
	db 'u','U'	;,16h
	db 'i','I'	;,17h
	db 'o','O'	;,18h
	db 'p','P'	;,19h
	db '[','{'	;,1Ah
	db ']','}'	;,1Bh
	db 0,0		;,1Ch
	db 0,0		;,1Dh
	db 'a','A'	;,1Eh
	db 's','S'	;,1Fh
	db 'd','D'	;,20h
	db 'f','F'	;,21h
	db 'g','G'	;,22h
	db 'h','H'	;,23h
	db 'j','J'	;,24h
	db 'k','K'	;,25h
	db 'l','L'	;,26h
	db ';',':'	;,27h
	db 27h,22h	;,28h
	db '`','~'	;,29h
	db 0,0		;,2Ah
	db '\','|'	;,2Bh
	db 'z','Z'	;,2Ch
	db 'x','X'	;,2Dh
	db 'c','C'	;,2Eh
	db 'v','V'	;,2Fh
	db 'b','B'	;,30h
	db 'n','N'	;,31h
	db 'm','M'	;,32h
	db ',','<'	;,33h
	db '.','>'	;,34h
	db '/','?'	;,35h
	db 0,0		;,36h
	db 0,0		;,37h
	db 0,0		;,38h
	db ' ',' '	;,39h
noscan:
