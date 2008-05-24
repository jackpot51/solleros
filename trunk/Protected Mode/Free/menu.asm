    ; MENU.ASM
prog:	
	    mov ax, cs
	    mov ds, ax
	    mov es, ax
	    mov byte [mouseon], 0
	    mov [DriveNumber], cl
	mov ax, videobuf2
	mov fs, ax
	mov ax, 0012h
	mov bx, 0
	int 10h
	call int30hah8
	mov ax, 0A000h
	mov gs, ax
	jmp pmode
pmoderet:    mov dx, 0
	    call clear
            jmp welcome

multitaskint:
	MOV EAX, 0
	MOV AX, CS

	SHL EAX, 16			; 16 bit left shif of EAX
	MOV AX, taskswitch		; AX points the the code of the Interrupt
	XOR BX, BX			; BX = 0
	MOV FS, BX			; FS = BX = 0

	CLI				; Interrupt Flag clear
	MOV [FS:70h*4], EAX		; Write the position of the Interrupt code into
					; the interrupt table (index 21h)
	STI				; Interrupt Flag set
	ret

switchtask db 0

taskswitch:
	cmp byte [multitaskon], 1
	je taskswitchon
	ret
taskswitchon:
	cmp byte [switchtask], 50
	je switchtask1
	cmp byte [switchtask], 100
	je switchtask2
	add byte [switchtask], 1
	ret
switchtask1:
	pusha
	mov eax, stack1
	mov esp, eax
	popa
	ret
switchtask2:
	pusha
	mov eax, stack2
	mov esp, eax
	popa
	ret

DriveNumber db 0

    welcome:
	    mov si, jeremymsg
	    call print
	    mov si, loadmsg
	    call print
	    call countdown
	    call clear
    begin:  mov si, msg
	    call print
	    mov si, jeremymsg2
	    call print
	    jmp menu

    char: 		    ;char must be in al
            mov [charcache], al
            mov bx, 7
	    mov si, charcache
	    mov al, 0
            call int30hah1
	    mov al, [charcache]
	    ret
	charcache db 0,0

    getkey:
            mov al, 0               ; wait for key
	    call int30hah5
            ret

    menu:
	    mov si, menumsg
	    call print
	    mov si, wrongmsg
    wrong:  call getkey
	    cmp al, 's'
            je shutdown
	    cmp al, 'c'
	    je coldboot
	    cmp al, 'w'
	    je warmboot
	    cmp al, 'b'
	    je near bootit
	    cmp al, 'h'
            je hangit
	    cmp al, '`'
	    je near batchfilerunit
	    call char
	    sub dl, 2
	    mov si, blankmsg
            jmp wrong
protectedinit:
	jmp pmode
batchfilerunit:
	call clear
	jmp donebatch
warmboot:
	jmp warmboot2

coldboot:
	jmp coldboot2
		shutdown:
			call realmode
			mov si, shutdownmsg
			call rebootit			
			MOV AX, 5300h	; Shuts down APM-Machines.
			XOR BX, BX	; Newer machines automatically
			INT 15h		; shut down
			MOV AX, 5304h
			XOR BX, BX
			INT 15h		; Interrupt 15h originally was
			MOV AX, 5301h	; used for Cartridges (cassettes)
			XOR BX, BX	; but is still in use for
			INT 15h		; diverse things
			MOV AX, 5307h
			MOV BX, 1
			MOV CX, 3
			INT 15h
			IRET

    hangit:
	    call clear
	    mov si, jeremymsg
            call print
	    mov si, hangmsg
	    call print
	    jmp hang
	
	mousemsg db "Move the mouse to start.",0
    bootit:
		call clear
		mov si, mousemsg
		call print
		call int30hah9
	    call clear
	    jmp windowterminal

	coldboot2:
			call realmode
		  	mov si, rebootmsg
			call rebootit
			MOV AX, 0040h	; Source: "coldboot.asm"
			MOV ES, AX	; ASM 1.0
			MOV WORD [ES:00072h], 0h
			JMP 0FFFFh:0000h
			IRET
		warmboot2:
			call realmode
			mov si, rebootmsg
			call rebootit
			MOV AX, 0040h	; Source: "warmboot.asm"
			MOV ES, AX	; ASM 1.0
			MOV WORD [ES:00072h], 01234h
			JMP 0FFFFh:0000h
			IRET
    hang:
            jmp hang

    rebootit:
	    push si
	    call clear
	    mov si, jeremymsg
	    call print
	    pop si
	    call print
	    call countdown
	    ret
	
	clear:
	call int30hah3
	ret

    countdown:
    	    mov al, '5'
	    call char
	    call delay
	    sub dl, 2
	    mov al, '4'
	    call char
	    call delay
	    sub dl, 2
	    mov al, '3'
	    call char
	    call delay
	    sub dl, 2
	    mov al, '2'
	    call char
	    call delay
	    sub dl, 2
	    mov al, '1'
	    call char
	    call delay
	    sub dl, 2
	    mov al, '0'
	    call char
            ret

	oldercx db 0,0

    delay:  mov cx, 010h
	delay1:
		mov [oldercx], cx
		mov cx, 0FFFFh
	delay2:
            loop delay2
		mov cx, [oldercx]
		loop delay1
 	    ret

    print:			; 'si' comes in with string address
	    mov bx, 7		; write to display
	    mov ax, 0
	    call int30hah1
    finpr:  ret			; finished this line 

    printbx:
	    push si
		mov ax, 0
	    mov si, bx
	    push bx			; 'bx' comes in with string address
	    mov bx,7	; write to display
		call int30hah1    
   	 	pop si
		pop bx
		ret			; finished this line 

windowmsg db "Terminal:",0

windowterminal:
	mov dx, 0			;origin
	mov si, windowmsg		;title
	jmp window

window:
titleshow:
	mov al, [si]
	cmp al, 0
	je doneshowtitle
	pusha
	call showfont
	popa
	inc dl
	inc si
	jmp titleshow
multitaskon db 0
doneshowtitle:
	jmp os
			;don't even try to multitask
	mov eax, stack1
	mov esp, eax
	pusha
	mov eax, stack2
	mov esp, eax
	jmp ebx
	mov byte [multitaskon], 1
oldbx2 db 0,0
olddi db 0,0
oldax db 0,0
oldbx db 0,0
oldcx db 0,0
olddx db 0,0
oldsi db 0,0
endscan dw 0FA1h
nooverscroll:
	mov dh, [enddh]
	mov dl, 0
	mov bx, 0
	add dh, 1
	mov cl, dh
	mov ch, 0
noverscrolloop2:
	add bx, 160
	loop noverscrolloop
	inc bx
	mov [endscan], bx
	mov dl, 0
	mov dh, [startdh]
	sub dh, [scrolledlines]
	mov bx, 0
	mov cl, dh
	mov ch, 0
noverscrolloop:
	add bx, 160
	loop noverscrolloop
	inc dh
	jmp videobuf2copy1
checkcursorselect:
	mov byte [mouseselecton], 1
	jmp checkcursorselectdone
videobuf2copy:
	mov [oldax], ax
	mov [oldbx], bx
	mov [oldcx], cx
	mov [olddx], dx
	mov [oldsi], si
	mov [olddi], di
	;mov ah, [startdh]
	;cmp [scrolledlines], ah		;Does not quite work yet--should only update necessary lines
	;jb nooverscroll
	mov dh, 1
	mov dl, 0
	mov bx, 0
videobuf2copy1:
	mov ax, [fs:bx]
	mov byte [mouseselecton], 0
	cmp ah, 0F8h
	je checkcursorselect
checkcursorselectdone:
	mov [oldbx2], bx
	mov bx, 0
	mov cx, 0
	mov ah, 0
	call showfont
	inc dx
	mov bx, [oldbx2]
	add bx, 2
	mov ax, 0
	cmp bx, [endscan]
	jb videobuf2copy1
donebuf2copy:
	mov ax, [oldax]
	mov bx, [oldbx]
	mov cx, [oldcx]
	mov dx, [olddx]
	mov si, [oldsi]
	mov di, [olddi]
	ret
	

    showfont:
	mov byte [modifier], 1		;modifier should be bl, only 1 works properly
	mov si, font	
	cmp al, 0
	je spacefound
    findfontloop:
	cmp [si], al
	je foundfontdone
	cmp si, fontend
	jae nofontfound
	add si, 16
	jmp findfontloop
   spacefound:
	mov al, ' '
	jmp findfontloop
   nofontfound:
	ret


	donecharputfixcolumn:
		inc dh	
		mov bx, 0
		mov bl, dl
		sub bl, 80
		mov ch, 0
		mov cl, dh
		cmp dh, 26
		jae near donecharput2
	columnfixit:
		add bx, 1120
		cmp bx, 09600h
		ja near donecharput2
		loop columnfixit
		mov dl, 0
;;;;;;		jmp donethefixcol
	columnfixitskip:
		mov dl, 0
		mov word [oldbx2], 0FA1h
		add word [markedchars], 1
		ret

charmask	db 00000001b
		db 10000000b
		db 01000000b
		db 00100000b
		db 00010000b
		db 00001000b
		db 00000100b
		db 00000010b

donewiththisshit:
	ret

fixtherow:
	mov bl, dl
	sub bl, 80
	mov dl, 0
	inc dh
	jmp donefixingtehrow

   foundfontdone:
	inc si
	cmp dh, 26
	jae donewiththisshit
	cmp dl, 80
	jae fixtherow
donefixingtehrow:
	mov bl, dl
	mov bh, 0
	mov cl, dh
	mov ch, 0
	mov ah, 0
	cmp cx, 0
	je doneloadcolumn
loadcolumn:
	add bx, 1120
	cmp bx, 09600h
	ja donewiththisshit
	loop loadcolumn
doneloadcolumn:
	mov al, [si]
	ror al, 1
	cmp byte [mouseselecton], 1
	je notcheck
notcheckdone:
	mov [gs:bx], al
	add bx, 80
	cmp bx, 09600h
	ja donewiththisshit
	inc ah
	inc si
	cmp ah, 14
	jbe doneloadcolumn
	ret
	
notcheck:
	not al
	jmp notcheckdone

mouseselecton db 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;THIS IS THE OLD FONT LOADER--HAD PROBLEMS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	mov di, charmask
	inc si
	mov ax, 0
	mov cx, 0
	mov bx, charbitmap
   fontcharloadloop:
	fontcharfindloadloop:
		mov cl, [si]
		mov ch, [di]
		and ch, cl
		cmp ch, 0
		jne fontcharfoundload
	loadedcharfont:
		inc di
		cmp di, foundfontdone
		jb fontcharfindloadloop
		jmp donefontloadchar
	fontcharfoundload:
		sub di, charmask
		add bx, di
		mov cl, [modifier]	
		mov [bx], cl
		sub bx, di
		add di, charmask
		jmp loadedcharfont
	donefontloadchar:
		add bx, 16
		mov cx, 8
	clearfontcache:
		mov byte [bx], 0
		dec bx
		loop clearfontcache
		inc si
		inc ah
		mov di, charmask
		cmp ah, 14
		jbe fontcharloadloop
	doneloadingcharfont:
		mov ax, 0
		mov si, charbitmap
		mov cl, dh
		mov ch, 0
		mov bl, dl
		mov bh, 0
	columncharloadloop:
		cmp cx, 0
		je charput
		add bx, 1120		;uses char system, not pixel system
		cmp bx, 09601h
		jae donecharput2
		loop columncharloadloop
	charput:
		add si, 7
		mov al, [si]
		rol al, 0
		mov [gs:bx], al
		dec si
		mov al, [si]
		rol al, 1
		add [gs:bx], al
		dec si
		mov al, [si]
		rol al, 2
		add [gs:bx], al
		dec si
		mov al, [si]
		rol al, 3
		add [gs:bx], al
		dec si
		mov al, [si]
		rol al, 4
		add [gs:bx], al
		dec si
		mov al, [si]
		rol al, 5
		add [gs:bx], al
		dec si
		mov al, [si]
		rol al, 6
		add [gs:bx], al
		dec si
		mov al, [si]
		rol al, 7
		add [gs:bx], al
		add si, 8
		add bx, 80
		cmp bx, 09601h
		jae donecharput2
		inc ah
		cmp ah, 14
		jbe charput
	donecharput:
		cmp word [markedchars], 0FA0h
		jae donecharput2
		ret
	donecharput2:
		mov word [oldbx2], 0FA1h
		ret

markedchars db 0
	modifier db 0