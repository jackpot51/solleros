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

specialkey db 0

	guistartin:
		mov eax, 0
		mov [specialkey], al
		mov [lastkey], ax
		in al, 64h ; Status
		test al, 1 ; output buffer full?
		jz guistartin
		test al, 20h ; PS2-Mouse?
		jnz near maincall2
	guigetkey:
		in al, 60h
		mov ah, al
		mov al, 0
		mov [lastkey + 1], ah
		mov al, ah
		mov edi, scancode
	guisearchscan: 
		cmp al, 3Ah
		jae guiscanother
		mov ah, 0
		shl al, 1
		add edi, eax
		shr al, 1
		mov ah, [edi]
		cmp ah, 0
		je guiscanother
		jmp guiscanfound
guiupper db 0
guiscanother:
		mov ah, al
		mov al, 0
		mov [lastkey], ax
		cmp ah, 0E0h
		je near guigetkeyspecial
		mov al, 0xE0
		cmp [specialkey], al
		jne nospecialkey
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
		je near guishift
		ret
	guigetkeyspecial:
		mov al, 0xE0
		mov [specialkey], al
		jmp guigetkey
	guishift:
		mov al, [guiupper]
		cmp al, 1
		jae guishiftoff
	guishifton:
		mov byte [guiupper], 1
		jmp guistartin
	guishiftoff:
		mov byte [guiupper], 0
		jmp guistartin
	guientdown:
		ret
	guiscanfound:
		add edi, 1
		cmp byte [guiupper], 1
		jae uppercasegui
		sub edi, 1
uppercasegui:
		mov al,[edi]
		mov [lastkey], al
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
		ret
	maincall2:
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
		mov bx, 1110011110011100b
		mov ah, 0
		mov al, 128
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
	db 8,8		;,0Eh
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
