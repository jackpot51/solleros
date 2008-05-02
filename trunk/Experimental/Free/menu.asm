    ; MENU.ASM
[BITS 16]
prog:
[ORG 0]
	    mov ax, cs
	    mov ds, ax
	    push ds
	    mov ds, ax
	    mov es, ax
	    mov [DriveNumber], cl
		mov ax, 0B800h
		mov gs, ax
	    call pmode
	    call clear
            call welcome
	    jmp menu

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
	    ret

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
	    je bootit
	    cmp al, 'h'
            je hangit
	    cmp al, '`'
	    je near batchfilerunit
	    cmp al, 'p'
	    je near protectedinit
	    push ax
	    call print
	    pop ax
	    call char
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
		
    bootit:
	    call clear
	    jmp os

	coldboot2:
		  	mov si, rebootmsg
			call rebootit
			MOV AX, 0040h	; Source: "coldboot.asm"
			MOV ES, AX	; ASM 1.0
			MOV WORD [ES:00072h], 0h
			JMP 0FFFFh:0000h
			IRET
		warmboot2:
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

    delay:  mov cx, 0100h
	delay1:
		push cx
		mov cx, 0FFFFh
	delay2:
            loop delay2
		pop cx
		loop delay1
 	    ret

    print:			; 'si' comes in with string address
	    mov bx,7		; write to display
	    mov ax, 0
	    call int30hah1
    finpr:  ret			; finished this line 

    printbx:
	    push si
		mov ax, 0
	    mov si, bx
	    push bx			; 'bx' comes in with string address
	    mov bx,7		; write to display
		call int30hah1    
   	 	pop si
		pop bx
		ret			; finished this line 