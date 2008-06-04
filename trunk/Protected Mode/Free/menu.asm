    ; MENU.ASM
	[BITS 16]
prog:	
	    mov ax, cs
	    jmp mainindexdn
mainindex:
	    dw 0405h,progstart,batchprogend,fileindex,fileindexend,variables,varend,nwcmd,int30h,physbaseptr,0
mainindexdn:
	    mov ds, ax
	    mov ax, 9000h
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
	mov ax, 12h
	mov bx, 0
	int 10h
	call pmode
pmoderet:    
	call indexfiles	
	mov dx, 0
	    call clear
            jmp welcome

svga:
	mov ax, 04F01h
	mov cx, 0000000100000000b
	mov di, VBEMODEINFOBLOCK
	int 10h
	mov ax, 04F02h	
	mov bx, 0000000100000000b
	int 10h
	ret

multitaskint:
	MOV EAX, 0
	MOV AX, CS

	SHL EAX, 16			; 16 bit left shif of EAX
	MOV AX, taskswitch		; AX points the the code of the Interrupt
	XOR BX, BX			; BX = 0
	MOV FS, BX			; FS = BX = 0

	CLI				; Interrupt Flag clear
	MOV [FS:70h*4], EAX		; Write the position of the Interrupt code into
					; the interrupt table (index 70h)
	STI				; Interrupt Flag set
	mov ax, 0B800h
	mov fs, ax
	ret

switchtask dw 0

taskswitch:
	cmp byte [multitaskon], 1
	je taskswitchon
	ret
taskswitchon:
	cmp word [switchtask], 50
	je switchtask1
	cmp word [switchtask], 100
	jae switchtask2
	add word [switchtask], 1
	ret
switchtask1:
	pusha
	push ds
	push es
	push fs
	push gs
	push cs
	mov ax, stack1
	mov sp, ax
	popa
	pop ds
	pop es
	pop fs
	pop gs
	pop cs
	ret
switchtask2:
	mov word [switchtask], 0
	pusha
	push ds
	push es
	push fs
	push gs
	push cs
	mov ax, stack2
	mov sp, ax
	popa
	pop ds
	pop es
	pop fs
	pop gs
	pop cs
	jmp awesome
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
		mov ax, 0
		mov bx, 7
		jmp int30hah1
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
	push si
	call showfont
	pop si
	add dx, 8
	inc si
	jmp titleshow
multitaskon db 0
doneshowtitle:
			
	jmp os	;don't even try to multitask
	mov ax, stack1
	mov sp, ax
	pusha
	push ds
	push es
	push fs
	push gs
	push cs
	cmp byte [multitaskon], 1
	je awesome
	mov ax, stack2
	mov sp, ax
	mov byte [multitaskon], 1
	jmp bx

awesome:
	mov si, windowmsg
	mov dl, 0
	mov dh, 2
	call print
	jmp awesome