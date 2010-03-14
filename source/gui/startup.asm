guisetup:
	%ifdef gui.background
	xor ebx, ebx
	mov [backgroundimage], ebx
	%endif
	call guiclear
	mov byte [guion], 1
	mov byte [mouseselecton], 0
	xor eax, eax
	xor ebx, ebx
	xor ecx, ecx
	xor edx, edx
	
	mov esi, pacmsg
	xor ah, ah
	mov al, 00010000b
	xor ebx, ebx
	mov cx, 144
	mov dx, 4
	call showstring
	
	mov esi, interneticon
	xor ah, ah
	mov al, 00010000b
	mov ebx, noie
	mov cx, 24
	mov dx, 4
	call showicon
	
	mov esi, wordicon
	xor ah, ah
	mov al, 00010000b
	xor ebx, ebx
	mov cx, 24
	mov dx, 48
	call showicon
	
	mov esi, pacmanpellet
	xor ah, ah
	mov al, 00010000b
	xor ebx, ebx
	mov cx, 64
	mov dx, 4
	call showicon
	
	mov esi, pacman
	xor ah, ah
	mov al, 00010000b
	mov ebx, pacmannomnom
	mov cx, 64
	mov dx, 48
	call showicon
	
	mov esi, ghostie
	xor ah, ah
	mov al, 00010000b
	mov ebx, boo
	mov cx, 108
	mov dx, 4
	call showicon
	
	mov esi, start
	mov cx, [resolutiony]
	sub cx, 16
	mov dx, 2
	xor ah, ah
	mov al, 00010000b
	mov ebx, winblows
	call showstring

%ifdef gui.time	
	call guitime	;load time into timeshow/dateshow and show it
%endif
	ret

	boo:
		mov esi, boomsg
		mov dx, 100
		mov cx, 320
		xor ebx, ebx
		xor ax, ax
		jmp showstring

	pacmannomnom:
		mov esi, pacnom
		mov dx, 130
		mov cx, 60
		xor ebx, ebx
		xor ax, ax
		jmp showstring	
	
	noie:
		mov word [termwindow], 640
		mov word [termwindow + 2], 480	;the previous lines of code make a large terminal window that is 4 characters smaller than the screen
		mov esi, termwindow
		mov dx, 16
		mov cx, 16
		xor ebx, ebx
		xor ax, ax
		call showwindow
		jmp os

	gotomenuboot:
		xor edx, edx
		xor ecx, ecx
		mov dx, [resolutionx]
		mov cx, [resolutiony]
		shr cx, 4
		sub cx, 1
		shl cx, 4
		mov [termwindow], dx
		mov [termwindow + 2], cx	;the previous lines of code make a large terminal window that is fullscreen
		mov esi, termwindow
		xor dx, dx
		xor cx, cx
		xor ebx, ebx
		xor ax, ax
		call showwindow
		jmp os

	winblows:
		mov esi, turnoffmsg
		mov ebx, turnoff
		mov cx, [resolutiony]
		sub cx, 32
		xor dx, dx
		xor ah, ah
		mov al, 00010000b
		call showstring
		mov esi, gotomenu
		mov cx, [resolutiony]
		sub cx, 48
		xor dx, dx
		xor ah, ah
		mov al, 00010000b
		mov ebx, gotomenuboot
		jmp showstring
		

	start	db "start",0
	gotomenu db "SollerOS",0
	turnoffmsg db "Power Off",0
	boomsg db "Boo!",0
	pacmsg	db "Pacman was easy to draw.",0
	pacnom  db "Om nom nom nom",0

	termwindow:	dw 800,600	;window size
				dw 0xFFFF,0	;colors(FG,BG)
				dd videobuf,videobuf2 ;location of buffers
	termmsg:	db "SHUSh",0	;;window title
	
interneticon: 	incbin 'source/gui/icons/internet'
wordicon: 	incbin 'source/gui/icons/word'
pacmanpellet: incbin 'source/gui/icons/pellet'
ghostie	incbin 'source/gui/icons/ghostie'
pacman	incbin 'source/gui/icons/pacman'

%ifdef gui.time
guitime:
		call time	;get rtc in timeshow & dateshow
		xor ebx, ebx
		mov dx, [resolutionx2]
		xor cx, cx
		sub dx, 304
		mov esi, dateshow
		mov al, 00010001b
		call showstring
		mov esi, timeshow
		xor ebx, ebx
		mov al, 00010001b
		call showstring
		ret
%endif
