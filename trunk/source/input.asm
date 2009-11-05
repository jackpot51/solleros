PS2SET:
  mov  al, 0xa8		; enable mouse port
  out  0x64, al		; write to keyboardcontroller
  call CHKPRT		; check if command is progressed (demand!)
ret

CHKPRT:
  mov  cx, 100
 .again:
  in   al, 0x64		; read from keyboardcontroller
  test al, 2		; Check if input buffer is empty
  je .go
  loop .again
 .go:
ret

WMOUS:
  mov  al, 0xd4		; write to mouse device instead of to keyboard
  out  0x64, al		; write to keyboardcontroller
  call CHKPRT		; check if command is progressed (demand!)
ret

MBUFFUL:
  mov cx, 100
 .mn:
  in   al, 0x64		; read from keyboardcontroller
  test al, 0x20		; check if mouse output buffer is full
  jz  .mnn
  loop .mn
 .mnn:
ret


ACTMOUS:
  call WMOUS
  mov  al, 0xf4 	; Command to activate mouse itselve (Stream mode)
  out  0x60, al		; write ps/2 controller output port (activate mouse)
  call CHKPRT		; check if command is progressed (demand!)
  call CHKMOUS		; check if a byte is available
ret

CHKMOUS:
  mov  bl, 0
  mov cx, 100
 .vrd:
  in   al, 0x64		; read from keyboardcontroller
  test al, 1		; check if controller buffer (60h) has data
  jnz .yy
  loop .vrd
  mov  bl, 1
 .yy:
ret

GETB:
 .cagain:
  call CHKMOUS		; check if a byte is available
  or bl, bl
  jnz .cagain
  mov  al, 0xad		; Disable Keyboard
  out  0x64, al		; write to keyboardcontroller
  call CHKPRT		; check if command is progressed (demand!)
  xor  ax, ax
  in   al, 0x60		; read ps/2 controller output port (mousebyte)
  mov  dl, al
  mov  al, 0xae		; Enable Keyboard
  out  0x64, al		; write to keyboardcontroller
  call CHKPRT		; check if command is progressed (demand!)
  mov  al, dl
ret

LBUTTON db 0x00	;	Left   button status 1=PRESSED 0=RELEASED
RBUTTON db 0x00	;	Right  button status 1=PRESSED 0=RELEASED
MBUTTON db 0x00	;	Middle button status 1=PRESSED 0=RELEASED
XCOORD  db 0x00	;	the moved distance  (horizontal)
YCOORD  db 0x00	;	the moved distance  (vertical)
mousedisabled db 0
specialkey db 0
charregion db 0
waitforinput:		;;this is basically the idle process
					;;this halts the cpu for a small amount of time and then sees if there was a keypress
					;;this lets the cpu stay at close to 0% instead of 100%
	;mov ax, 0xA000	;;this is the divider for the PIT
	;out 0x40, al
	;rol ax, 8
	;out 0x40, al
	mov al, [threadson]
	mov byte [threadson], 0
	sti
	hlt
	mov [threadson], al
;	cmp al, 2
;	je guistartin
getkey:
		xor eax, eax
		mov [specialkey], al
		mov [lastkey], ax
		in al, 64h ; Status
		test al, 20h ; PS2-Mouse?
		jnz near moused
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
	
	cursorgui:
		cmp byte [mouseon], 1
		je near moused
		cmp byte [guion], 0
		je entdown
	initmouse:
		cmp byte [guion], 0
		je noswmsposinit
		call switchmousepos2
	noswmsposinit:
	  	call PS2SET
		call ACTMOUS
		mov byte [mouseon],1
		call GETB 	;;Get the responce byte of the mouse (like: Hey i am active)
				;;If the bytes are mixed up,
				;;remove this line or add another of this line.
	nomouse:
		ret
	moused:
		cmp byte [mousedisabled], 1
		je nomouse
		  cmp byte [mouseon], 1
		  jne initmouse
		  call GETB
		  mov  bl, al
		  and  bl, 1
		  mov  BYTE [LBUTTON], bl
		  mov  bl, al
		  and  bl, 2
		  shr  bl, 1
		  mov  BYTE [RBUTTON], bl
		  mov  bl, al
		  and  bl, 4
		  shr  bl, 2
		  mov  BYTE [MBUTTON], bl
		  call GETB
		  mov  BYTE [XCOORD], al
		  call GETB
		  mov  BYTE [YCOORD], al

	showpixelcursor:
		mov dx, [mousecursorposition]
		mov cx, [mousecursorposition + 2]
		mov [lastmouseposition], dx
		mov [lastmouseposition + 2], cx
		mov al, [XCOORD]
		cmp al, 128
		jae subxcoord
		add al, al
		xor ah, ah
		add dx, ax
		jmp subxcoorddn
	subxcoord:
		add al, al
		xor bl, bl
		sub bl, al
		xor bh, bh
		sub dx, bx
	subxcoorddn:
		mov bl, [YCOORD]
		xor al, al
		sub al, bl
		cmp al, 128
		jae subycoord
		xor ah, ah
		add cx, ax
		jmp subycoorddn
	subycoord:
		xor bl, bl
		sub bl, al
		xor bh, bh
		sub cx, bx
	subycoorddn:
		cmp dx, 20000
		jbe nooriginx2
		xor dx, dx
	nooriginx2:
		cmp cx, 20000
		jbe nooriginy2
		xor cx, cx
	nooriginy2:
		cmp dx, 0
		je nofixxcolumn2
		cmp dx, [resolutionx2]
		jb nofixxcolumn2
		mov dx, [resolutionx2]
		sub dx, 2
	nofixxcolumn2:
		cmp cx, 0
		je nofixyrow2
		cmp cx, [resolutiony]
		jb nofixyrow2
		mov cx, [resolutiony]
		sub cx, 1
	nofixyrow2:
		mov [mousecursorposition], dx
		mov [mousecursorposition + 2], cx
		cmp byte [guion], 0
		je near termmouse
		call switchmousepos ;;use dragging code to ensure proper icon drag
		cmp byte [LBUTTON], 1
		je near clickicon
		cmp byte [RBUTTON], 1
		je near clickicon
		mov al, [pbutton]
		mov dword [dragging], 0
		cmp al, 0
		je nopreviousbutton
		call clearmousecursor
		call reloadallgraphics
	windowtermcopyend:
		call switchmousepos2
	nopreviousbutton:
		xor al, al
		mov [pbutton], al
		mov al, [LBUTTON]
		mov [pLBUTTON], al
		mov al, [RBUTTON]
		mov [pRBUTTON], al
		xor ecx, ecx
		xor edx, edx
		mov dx, [mousecursorposition]
		mov cx, [mousecursorposition + 2]
		mov bx, 1100011100011000b
		xor ah, ah
		mov al, 254
		mov byte [showcursorfonton], 1
		call showfontvesa
		mov byte [showcursorfonton], 0
		ret

lastmouseposition dw 132,132
mousecursorposition dw 132,132	

termmouse:
		mov esi, videobuf
		xor edx, edx
		mov dx, [lastmouseposition]
		mov cx, [lastmouseposition + 2]
		mov ax, [cursorcache]
		cmp ax, 0
		je nocopycursorcache
		shl cx, 4
		shl dx, 3
		add esi, edx
		xor dx, dx
		mov dl, [charxy]
		inc cx
termmousecplp1:
		add esi, edx
		dec cx
		cmp cx, 0
		jne termmousecplp1
		sub esi, edx
		mov [esi], ax
nocopycursorcache:
		mov esi, videobuf
		xor edx, edx
		mov dx, [mousecursorposition]
		mov cx, [mousecursorposition + 2]
		shl cx, 4
		shl dx, 3
		add esi, edx
		xor dx, dx
		mov dl, [charxy]
		inc cx
termmousecplp2:
		add esi, edx
		dec cx
		cmp cx, 0
		jne termmousecplp2
		sub esi, edx
		mov ax, [esi]
		mov [cursorcache], ax
		mov al, 128
		mov ah, 7
		mov [esi], ax
		call termcopy
		ret
cursorcache db 0,0
	
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
