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
;guistartin2:		;;this is basically the idle process
					;;this halts the cpu for a small amount of time and then sees if there was a keypress
					;;this lets the cpu stay at close to 0% instead of 100%			
	;mov ax, 0x2000	;;this is the divider for the PIT
	;out 0x40, al
	;rol ax, 8
	;out 0x40, al
	;nop
	;mov al, 0x20
	;out 0x20, al
	;nop
	;sti
	;hlt	
	;cmp byte [trans], 1
	;jne nofixinput
	;mov ax, 0
	;mov [lastkey], ax
	;mov [specialkey], al
	;ret
nofixinput:
	noinput:
		cmp byte [trans], 0
		je guistartinhalt
		mov eax, 0
		ret
	guistartinhalt:
		hlt
		cmp byte [irqkey], 0
		je guistartinhalt
guistartin:
		mov eax, 0
		mov [specialkey], al
		mov [lastkey], ax
		;in al, 64h ; Status
		;test al, 20h ; PS2-Mouse?
		;jnz near maincall2
		;mov cl, al
		;call showhexsmall
		;test al, 1
		;jz guistartin2 ; if output buffer full or no keypress, jump to idle process (only works when it is jz guistartin2, use jz guistartin to disable)
	guigetkey:
		mov esi, irqkey
		mov ebx, [irqkeypos]
		mov al, [esi]
		mov byte [irqkey], 0
		cmp ebx, 0
		jne near rollbackirqkey
	donerollbackirqkey:
		cmp al, 0
		je noinput
		mov ah, al
		mov [lastkey + 1], ah
		mov edi, scancode
	guisearchscan: 
		cmp al, 3Ah
		jae guiscanother
		mov ah, 0
		shl al, 2
		add edi, eax
		shr al, 1
		add edi, eax
		shr al, 1
		mov ah, [edi]
		cmp ah, 0
		je guiscanother
		jmp guiscanfound
rollbackirqkey:
		inc esi
		mov al, [esi]
		mov [esi - 1], al
		cmp esi, irqkeyend
		jb rollbackirqkey
		mov esi, irqkey
		mov al, [esi]
		mov byte [esi], 0
		dec ebx
		mov [irqkeypos], ebx
		jmp donerollbackirqkey
		
		
guiupper db 0
guiscanother:
		mov ah, al
		mov al, 0
		mov [lastkey], ax
		cmp ah, 0E0h
		je near guigetkeyspecial
		cmp byte [specialkey], 0xE0
		jne nospecialkey
		cmp ah, 38h
		je near guialton
		cmp ah, 0B8h
		je near guialtoff
		cmp ah, 1Dh
		je near guictron
		cmp ah, 9Dh
		je near guictroff
		mov [lastkey], ax
		ret
nospecialkey:
		;cmp ah, 4Dh
		;je near nextimage
		cmp ah, 2Ah
		je near guishifton
		cmp ah, 36h
		je near guishifton
		cmp ah, 1Ch
		je near guientdown
		cmp ah, 0AAh
		je near guishiftoff
		cmp ah, 0B6h
		je near guishiftoff
		cmp ah, 3Ah
		je near guicaps
		cmp ah, 0x45
		je near guinumlock
		cmp ah, 0x46
		je near guiscrolllock
		ret
	guigetkeyspecial:
		mov byte [specialkey], 0xE0
		jmp guigetkey
	guishift:
		mov al, [guiupper]
		cmp al, 1
		jae guishiftoff
	guishifton:
		mov byte [guiupper], 1
		ret
		;jmp guistartin
	guishiftoff:
		mov byte [guiupper], 0
		ret
		;jmp guistartin
	guictron:
		mov byte [guictr], 1
		ret
	guictroff:
		mov byte [guictr], 0
		ret
	guialton:
		mov byte [guialt], 1
		ret
		;jmp guistartin
	guialtoff:
		mov byte [guialt], 0
		ret
		;jmp guistartin
	guientdown:
		ret
	guiscanfound:
		add edi, 4
		cmp byte [guictr], 1
		jae altguiin
		sub edi, 4
		add edi, 2
		cmp byte [guialt], 1
		jae altguiin
		sub edi, 2
altguiin:
		add edi, 1
		cmp byte [guiupper], 1
		jae uppercasegui
		sub edi, 1
uppercasegui:
		mov al,[edi]
		mov [lastkey], al
		ret
		
keyboardstatus db 0
numlockstatus db 0
scrolllockstatus db 0
guialt db 0
guictr db 0
	guicaps:
		xor byte [keyboardstatus], 00000100b
		call updatekblights
		jmp guishift
		
	guinumlock:
		xor byte [keyboardstatus], 00000010b
		xor byte [numlockstatus], 1
		call updatekblights
		jmp guistartin
	
	guiscrolllock:
		xor byte [keyboardstatus], 00000001b
		xor byte [scrolllockstatus], 1
		call updatekblights
		jmp guistartin
		
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
		je near maincall2
		cmp byte [guion], 0
		je guientdown
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
		;call GETB
	nomouse:
		ret
	maincall2:
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
		mov ah, 0
		add dx, ax
		jmp subxcoorddn
	subxcoord:
		add al, al
		mov bl, 0
		sub bl, al
		mov bh, 0
		sub dx, bx
	subxcoorddn:
		mov bl, [YCOORD]
		mov al, 0
		sub al, bl
		cmp al, 128
		jae subycoord
		mov ah, 0
		add cx, ax
		jmp subycoorddn
	subycoord:
		mov bl, 0
		sub bl, al
		mov bh, 0
		sub cx, bx
	subycoorddn:
		cmp dx, 20000
		jbe nooriginx2
		mov dx, 0
	nooriginx2:
		cmp cx, 20000
		jbe nooriginy2
		mov cx, 0
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
		mov al, 0
		mov [pbutton], al
		mov al, [LBUTTON]
		mov [pLBUTTON], al
		mov al, [RBUTTON]
		mov [pRBUTTON], al
		mov ecx, 0
		mov edx, 0
		mov dx, [mousecursorposition]
		mov cx, [mousecursorposition + 2]
		mov bx, 1100011100011000b
		mov ah, 0
		mov al, 254
		mov byte [showcursorfonton], 1
		call showfontvesa
		mov byte [showcursorfonton], 0
		ret

lastmouseposition dw 132,132
mousecursorposition dw 132,132	

termmouse:
		mov esi, videobuf2
		mov edx, 0
		mov dx, [lastmouseposition]
		mov cx, [lastmouseposition + 2]
		mov ax, [cursorcache]
		cmp ax, 0
		je nocopycursorcache
		shl cx, 4
		shl dx, 3
		add esi, edx
		mov dx, 0
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
		mov esi, videobuf2
		mov edx, 0
		mov dx, [mousecursorposition]
		mov cx, [mousecursorposition + 2]
		shl cx, 4
		shl dx, 3
		add esi, edx
		mov dx, 0
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
	db 0,0,0,0,0,0			;,0h
	db 0,0,0,0,0,0			;,1h
	db '1','!',173,0,0,0	;,2h
	db '2','@',253,251,0,0	;,3h
	db '3','#',0,0,0,0		;,4h
	db '4','$',155,156,0,0	;,5h
	db '5','%',238,0,0,0	;,6h
	db '6','^',172,0,0,0	;,7h
	db '7','&',171,0,0,0	;,8h
	db '8','*',236,0,0,0	;,9h
	db '9','(',0,0,0,0		;,0Ah
	db '0',')',0,0,0,0		;,0Bh
	db '-','_',157,241,0,0	;,0Ch
	db '=','+',247,246,0,0	;,0Dh
	db 8,8,0,0,0,0			;,0Eh
	db 0,0,0,0,0,0			;,0Fh
	db 'q','Q',132,142,0,0	;,10h
	db 'w','W',134,143,0,0	;,11h
	db 'e','E',130,144,238,'E'	;,12h
	db 'r','R',137,138,'p','P'		;,13h
	db 't','T',129,154,231,'T'		;,14h
	db 'y','Y',152,0,'u','Y'	;,15h
	db 'u','U',163,151,0,0	;,16h
	db 'i','I',161,141,'i','I'	;,17h
	db 'o','O',162,149,'w',234	;,18h
	db 'p','P',148,153,227,239	;,19h
	db '[','{',244,0,0,0		;,1Ah
	db ']','}',245,0,0,0		;,1Bh
	db 0,0,0,0,0,0			;,1Ch
	db 0,0,0,0,0,0			;,1Dh
	db 'a','A',160,133,224,'A'	;,1Eh
	db 's','S',21,0,229,228		;,1Fh
	db 'd','D',248,0,235,127	;,20h
	db 'f','F',159,0,237,232	;,21h
	db 'g','G',0,0,'y',226		;,22h
	db 'h','H',0,0,'n','H'		;,23h
	db 'j','J',0,0,0,0		;,24h
	db 'k','K',0,0,'k','K'		;,25h
	db 'l','L',0,0,233,233		;,26h
	db ';',':',20,0,0,0		;,27h
	db 27h,22h,0,0,0,0		;,28h
	db '`','~',0,0,0,0		;,29h
	db 0,0,0,0,0,0			;,2Ah
	db '\','|',170,179,0,0	;,2Bh
	db 'z','Z',145,146,'z','Z'	;,2Ch
	db 'x','X',0,0,0,240		;,2Dh
	db 'c','C',135,128,0,0	;,2Eh
	db 'v','V',0,0,0,0		;,2Fh
	db 'b','B',0,0,225,'B'	;,30h
	db 'n','N',164,165,'v','N'	;,31h
	db 'm','M',0,0,230,'M'		;,32h
	db ',','<',243,174,0,0	;,33h
	db '.','>',242,175,0,0	;,34h
	db '/','?',168,0,0,0	;,35h
	db 0,0,0,0,0,0			;,36h
	db 0,0,0,0,0,0			;,37h
	db 0,0,0,0,0,0			;,38h
	db ' ',' ',0,0,0,0		;,39h
noscan:
