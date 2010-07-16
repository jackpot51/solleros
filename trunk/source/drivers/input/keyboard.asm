specialkey db 0
;charregion db 0
waitforinput:		;this is basically the idle process
					;this halts the cpu for a small amount of time and then sees if there was a keypress
					;this lets the cpu stay at close to 0% instead of 100%
	xor ax, ax
	mov al, [threadson]
	mov [threadson], ah
	pushf
	sti
	hlt
	popf
	mov [threadson], al
	cmp word [trans], 0
	je getkey
	ret
getkey:
		xor eax, eax
		mov [specialkey], al
		mov [lastkey], eax
		in al, 64h ; Status
	%ifdef gui.included
		test al, 20h ; PS2-Mouse?
		jnz near moused
	%endif
		test al, 1 
		jz waitforinput ; if output buffer full or no keypress, jump to idle process
	calckey:
		in al, 60h
		xor ah, ah
		mov bx, ax
		mov [lastkey + 2], ax
		mov edi, scancode
	searchscan: 
		cmp bl, 3Ah
		jae scanother
		shl eax, 4
		add edi, eax
		mov ax, [edi]
		cmp ax, 0
		je scanother
		jmp scanfound
uppercase db 0
scanother:
		xor ax, ax
		mov [lastkey], ax
		cmp bl, 0E0h
		je near getkeyspecial
		cmp byte [specialkey], 0xE0
		jne nospecialkey
		cmp bl, 38h
		je near alton
		cmp bl, 0B8h
		je near altoff
		cmp bl, 1Dh
		je near ctron
		cmp bl, 9Dh
		je near ctroff
		ret
nospecialkey:
		cmp bl, 2Ah
		je near shifton
		cmp bl, 36h
		je near shifton
		cmp bl, 1Ch
		je near entdown
		cmp bl, 0AAh
		je near shiftoff
		cmp bl, 0B6h
		je near shiftoff
		cmp bl, 3Ah
		je near capslock
		cmp bl, 0x45
		je near numlock
		cmp bl, 0x46
		je near scrolllock
		ret
	getkeyspecial:
		mov byte [specialkey], 0xE0
		jmp calckey
	shift:
		mov al, [uppercase]
		cmp al, 1
		jae shiftoff
	shifton:
		mov byte [uppercase], 1
		ret
	shiftoff:
		mov byte [uppercase], 0
		ret
	ctron:
		mov byte [ctrkey], 1
		ret
	ctroff:
		mov byte [ctrkey], 0
		ret
	alton:
		mov byte [altkey], 1
		ret
	altoff:
		mov byte [altkey], 0
		ret
	entdown:
		ret
scanfound:
		add edi, 8
		cmp byte [ctrkey], 1
		jae ctrlin
		sub edi, 8
	ctrlin:
		add edi, 4
		cmp byte [altkey], 1
		jae altin
		sub edi, 4
	altin:
		add edi, 2
		cmp byte [uppercase], 1
		jae uppercaseon
		sub edi, 2
	uppercaseon:
		mov ax,[edi]
		mov [lastkey], ax
		ret
		
keyboardstatus db 0
numlockstatus db 0
scrolllockstatus db 0
altkey db 0
ctrkey db 0
	capslock:
		xor byte [keyboardstatus], 00000100b
		call updatekblights
		jmp shift
		
	numlock:
		xor byte [keyboardstatus], 00000010b
		xor byte [numlockstatus], 1
		call updatekblights
		jmp getkey
	
	scrolllock:
		xor byte [keyboardstatus], 00000001b
		xor byte [scrolllockstatus], 1
		call updatekblights
		jmp getkey
		
	updatekblights:
		mov al, 0xED
		mov dx, 0x60
		out dx, al
	chkkbdack:
		in al, dx
		cmp al, 0xFA
		jne chkkbdack
		mov al, [keyboardstatus]
		out dx, al
		ret
		
scancode:
	;key, KEY, alt key, ALT KEY, ctrl key, CTRL KEY, ctrl-alt, CTRL-ALT
	dw 0,0,0,0,0,0,0,0
	dw 0,0,0,0,0,0,0,0
	dw '1','!',0xA1,0x203C,0,0,0,0
	dw '2','@',0xB2,0x221A,0,0,0,0
	dw '3','#',0xB3,0x222B,0,0,0,0
	dw '4','$',0xA3,0xA2,0,0,0,0
	dw '5','%',0x20AC,0,0,0,0,0
	dw '6','^',0xBC,0x207F,0,0,0,0
	dw '7','&',0xBD,0,0,0,0,0
	dw '8','*',0x221E,0x95,0,0,0,0
	dw '9','(',0xAE,0x99,0,0,0,0
	dw '0',')',0xA9,0,0,0,0,0
	dw '-','_',0xA5,0xB1,0,0,0,0
	dw '=','+',0xF7,0x2248,0,0,0,0
	dw 8,8,0,0,0,0,0,0
	dw 0,0,0,0,0,0,0,0
	dw 'q','Q',0xE4,0xC4,';',':',0x439,0x419
	dw 'w','W',0xE5,0xC5,0x3C2,0,0x446,0x426
	dw 'e','E',0xE9,0xC9,0x3B5,0x395,0x443,0x423
	dw 'r','R',0xEB,0xE8,0x3C1,0x3A1,0x43A,0x41A
	dw 't','T',0xFC,0xDC,0x3C4,0x3A4,0x435,0x415
	dw 'y','Y',0xFF,0x9F,0x3C5,0x3A5,0x43D,0x41D
	dw 'u','U',0xFA,0xF9,0x3B8,0x398,0x433,0x413
	dw 'i','I',0xED,0xEC,0x3B9,0x399,0x448,0x428
	dw 'o','O',0xF3,0xF2,0x3BF,0x39F,0x449,0x429
	dw 'p','P',0xF6,0xD6,0x3C0,0x3A0,0x437,0x417
	dw '[','{',0xAB,0,0,0,0x445,0x425
	dw ']','}',0xBB,0,0,0,0x44A,0x42A
	dw 0,0,0,0,0,0,0,0
	dw 0,0,0,0,0,0,0,0
	dw 'a','A',0xE1,0xE0,0x3B1,0x391,0x444,0x424
	dw 's','S',0xA7,0,0x3C3,0x3A3,0x44B,0x42B
	dw 'd','D',0xB0,0,0x3B4,0x394,0x432,0x412
	dw 'f','F',0x83,0x2640,0x3C6,0x3A6,0x430,0x410
	dw 'g','G',0,0,0x3B3,0x393,0x43F,0x41F
	dw 'h','H',0,0,0x3B7,0x397,0x440,0x420
	dw 'j','J',0,0,0x3BE,0x39E,0x43E,0x41E
	dw 'k','K',0,0,0x3BA,0x39A,0x43B,0x41B
	dw 'l','L',0,0,0x3BB,0x39B,0x434,0x414
	dw ';',':',0xB6,0x220E,0,0,0x436,0x416
	dw "'",'"',0,0,0,0,0x44D,0x42D
	dw '`','~',0,0,0,0,0x451,0x401
	dw 0,0,0,0,0,0,0,0
	dw "\",'|',0xAC,0xA6,0,0,"/","\"
	dw 'z','Z',0xE6,0xC6,0x3B6,0x396,0x44F,0x42F
	dw 'x','X',0,0,0x3C7,0x3A7,0x447,0x427
	dw 'c','C',0xE7,0xC7,0x3C8,0x3A8,0x441,0x421
	dw 'v','V',0,0,0x3C9,0x3A9,0x43C,0x41C
	dw 'b','B',0,0,0x3B2,0x392,0x438,0x418
	dw 'n','N',0xF1,0xD1,0x3BD,0x39D,0x442,0x422
	dw 'm','M',0x266C,0x2642,0x3BC,0x39C,0x44C,0x42C
	dw ',','<',0x2264,0,0,0,0x431,0x411
	dw '.','>',0x2265,0,0,0,0x44E,0x42E
	dw '/','?',0xBF,0,0,0,'.',','
	dw 0,0,0,0,0,0,0,0
	dw 0,0,0,0,0,0,0,0
	dw 0,0,0,0,0,0,0,0
	dw ' ',' ',0,0,0,0,0,0
noscan:

