mousedisabled db 0
	
	cursorgui:
		cmp byte [mouseon], 1
		je near mousedaemon
		cmp byte [guion], 0
		je near entdown
	initmouse:
		cmp byte [guion], 0
		je noswmsposinit
		call switchmousepos2
	noswmsposinit:
	  	call PS2SET
		call ACTMOUS
		mov byte [mouseon],1
		call GETB 	;;Get the responce byte of the mouse (like: Hey i am active)
		;call GETB
				;;If the bytes are mixed up,
				;;remove this line or add another of this line.
	nomouse:
		ret
		
	mousedaemon:
		cmp byte [mouseon], 1
		jne initmouse
		in al, 64h ; Status
		test al, 20h ; PS2-Mouse?
		jnz near moused
		hlt
		ret
	moused:
		cmp byte [mousedisabled], 1
		je nomouse
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