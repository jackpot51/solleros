specialkey db 0
;charregion db 0
waitforinput:		;this is basically the idle process
					;this halts the cpu for a small amount of time and then sees if there was a keypress
					;this lets the cpu stay at close to 0% instead of 100%
	xor ax, ax
	mov al, [threadson]
	mov [threadson], ah
	sti
	hlt
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
	dw '9','(',0,0,0,0,0,0
	dw '0',')',0,0,0,0,0,0
	dw '-','_',0x9D,0xF1,0,0,0,0
	dw '=','+',0xF7,0xF6,0,0,0,0
	dw 8,8,0,0,0,0,0,0
	dw 0,0,0,0,0,0,0,0
	dw 'q','Q',0x84,0x8E,0,0,0,0
	dw 'w','W',0x86,0x8F,0,0,0,0
	dw 'e','E',0x82,0x90,0xEE,'E',0,0
	dw 'r','R',0x89,0x8A,'p','P',0,0
	dw 't','T',0x81,0x9A,0xE7,'T',0,0
	dw 'y','Y',0x98,0,'u','Y',0,0
	dw 'u','U',0xA3,0x97,0,0,0,0
	dw 'i','I',0xA1,0x8D,'i','I',0,0
	dw 'o','O',0xA2,0x95,'w',0xEA,0,0
	dw 'p','P',0x94,0x99,0xE3,0xEF,0,0
	dw '[','{',0xF4,0,0,0,0,0
	dw ']','}',0xF5,0,0,0,0,0
	dw 0,0,0,0,0,0,0,0
	dw 0,0,0,0,0,0,0,0
	dw 'a','A',0xA0,133,224,'A',0,0
	dw 's','S',21,0,229,228,0,0
	dw 'd','D',0xF8,0,235,127,0,0
	dw 'f','F',159,0xC,237,232,0,0
	dw 'g','G',0,0,'y',226,0,0
	dw 'h','H',0,0,'n','H',0,0
	dw 'j','J',0,0,0,0,0,0
	dw 'k','K',0,0,'k','K',0,0
	dw 'l','L',0,0,233,233,0,0
	dw ';',':',20,0xDC,0,0,0,0
	dw 27h,22h,0,0,0,0,0,0
	dw '`','~',0,0,0,0,0,0
	dw 0,0,0,0,0,0,0,0
	dw 92,'|',170,179,0,0,0,0
	dw 'z','Z',145,146,'z','Z',0,0
	dw 'x','X',0,0,0,240,0,0
	dw 'c','C',135,128,0,0,0,0
	dw 'v','V',0,0,0,0,0,0
	dw 'b','B',0,0,225,'B',0,0
	dw 'n','N',0xA4,0xA5,'v','N',0,0
	dw 'm','M',0xE,0xB,230,'M',0,0
	dw ',','<',0xF3,174,0,0,0,0
	dw '.','>',0xF2,175,0,0,0,0
	dw '/','?',0xA8,0,0,0,0,0
	dw 0,0,0,0,0,0,0,0
	dw 0,0,0,0,0,0,0,0
	dw 0,0,0,0,0,0,0,0
	dw ' ',' ',0,0,0,0,0,0
noscan:

