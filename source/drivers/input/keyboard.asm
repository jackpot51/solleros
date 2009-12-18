specialkey db 0
charregion db 0
waitforinput:		;;this is basically the idle process
					;;this halts the cpu for a small amount of time and then sees if there was a keypress
					;;this lets the cpu stay at close to 0% instead of 100%
	xor ax, ax
	mov al, [threadson]
	mov [threadson], ah
	sti
	hlt
	mov [threadson], al
	cmp ah, [trans]
	je getkey
	ret
getkey:
		xor eax, eax
		mov [specialkey], al
		mov [lastkey], ax
		in al, 64h ; Status
%ifdef gui.included
		test al, 20h ; PS2-Mouse?
		jnz near moused
%endif
		test al, 1 
		jz waitforinput ; if output buffer full or no keypress, jump to idle process (only works when it is jz guistartin2, use jz guistartin to disable)
	calckey:
		in al, 60h
		mov ah, al
		xor al, al
		mov [lastkey + 1], ah
		mov al, ah
		mov edi, scancode
	searchscan: 
		cmp al, 3Ah
		jae scanother
		xor ah, ah
		shl al, 2
		add edi, eax
		shr al, 1
		add edi, eax
		shr al, 1
		mov ah, [edi]
		cmp ah, 0
		je scanother
		jmp scanfound
uppercase db 0
scanother:
		mov ah, al
		xor al, al
		mov [lastkey], ax
		cmp ah, 0E0h
		je near getkeyspecial
		cmp byte [specialkey], 0xE0
		jne nospecialkey
		cmp ah, 38h
		je near alton
		cmp ah, 0B8h
		je near altoff
		cmp ah, 1Dh
		je near ctron
		cmp ah, 9Dh
		je near ctroff
		mov [lastkey], ax
		ret
nospecialkey:
		cmp ah, 2Ah
		je near shifton
		cmp ah, 36h
		je near shifton
		cmp ah, 1Ch
		je near entdown
		cmp ah, 0AAh
		je near shiftoff
		cmp ah, 0B6h
		je near shiftoff
		cmp ah, 3Ah
		je near capslock
		cmp ah, 0x45
		je near numlock
		cmp ah, 0x46
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
		add edi, 4
		cmp byte [ctrkey], 1
		jae altin
		sub edi, 4
		add edi, 2
		cmp byte [altkey], 1
		jae altin
		sub edi, 2
altin:
		add edi, 1
		cmp byte [uppercase], 1
		jae uppercaseon
		sub edi, 1
uppercaseon:
		mov al,[edi]
		mov [lastkey], al
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
	db 0,0,0,0,0,0				;0h
	db 0,0,0,0,0,0				;1h
	db '1','!',0xAD,0,0,0		;2h
	db '2','@',0xFD,0xFB,0,0	;3h
	db '3','#',0,0,0,0			;4h
	db '4','$',0x9B,0x9C,0,0	;5h
	db '5','%',0xEE,0,0,0		;6h
	db '6','^',0xAC,0,0,0		;7h
	db '7','&',0xAB,0,0,0		;8h
	db '8','*',0xEC,0,0,0		;9h
	db '9','(',0,0,0,0			;0Ah
	db '0',')',0,0,0,0			;0Bh
	db '-','_',0x9D,0xF1,0,0	;0Ch
	db '=','+',0xF7,0xF6,0,0	;0Dh
	db 8,8,0,0,0,0				;0Eh
	db 0,0,0,0,0,0				;0Fh
	db 'q','Q',0x84,0x8E,0,0	;10h
	db 'w','W',0x86,0x8F,0,0	;11h
	db 'e','E',0x82,0x90,0xEE,'E'	;12h
	db 'r','R',0x89,0x8A,'p','P'	;13h
	db 't','T',0x81,0x9A,0xE7,'T'	;14h
	db 'y','Y',0x98,0,'u','Y'	;15h
	db 'u','U',0xA3,0x97,0,0		;16h
	db 'i','I',0xA1,0x8D,'i','I'	;17h
	db 'o','O',0xA2,0x95,'w',0xEA	;18h
	db 'p','P',0x94,0x99,0xE3,0xEF	;19h
	db '[','{',0xF4,0,0,0		;1Ah
	db ']','}',0xF5,0,0,0		;1Bh
	db 0,0,0,0,0,0				;1Ch
	db 0,0,0,0,0,0				;1Dh
	db 'a','A',0xA0,133,224,'A'	;1Eh
	db 's','S',21,0,229,228		;1Fh
	db 'd','D',0xF8,0,235,127	;20h
	db 'f','F',159,0,237,232	;21h
	db 'g','G',0,0,'y',226		;22h
	db 'h','H',0,0,'n','H'		;23h
	db 'j','J',0,0,0,0			;24h
	db 'k','K',0,0,'k','K'		;25h
	db 'l','L',0,0,233,233		;26h
	db ';',':',20,0,0,0			;27h
	db 27h,22h,0,0,0,0			;28h
	db '`','~',0,0,0,0			;29h
	db 0,0,0,0,0,0				;2Ah
	db 92,'|',170,179,0,0		;2Bh
	db 'z','Z',145,146,'z','Z'	;2Ch
	db 'x','X',0,0,0,240		;2Dh
	db 'c','C',135,128,0,0		;2Eh
	db 'v','V',0,0,0,0			;2Fh
	db 'b','B',0,0,225,'B'		;30h
	db 'n','N',0xA4,0xA5,'v','N'	;31h
	db 'm','M',0,0,230,'M'		;32h
	db ',','<',0xF3,174,0,0		;33h
	db '.','>',0xF2,175,0,0		;34h
	db '/','?',0xA8,0,0,0		;35h
	db 0,0,0,0,0,0				;36h
	db 0,0,0,0,0,0				;37h
	db 0,0,0,0,0,0				;38h
	db ' ',' ',0,0,0,0			;39h
noscan:

