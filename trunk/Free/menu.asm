    ; PROG.ASM
[BITS 16]
prog:
[ORG 0]
	    mov ax, cs
	    mov ds, ax
	    mov es, ax
	    mov [DriveNumber], cl
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
    begin:  mov si, clearmsg
	    call print
	    mov si, jeremymsg2
	    call print
	    call cursor
            mov si, msg     ; Print msg
	    call print
	    ret

    char: 		    ;char must be in al
            mov ah, 9
            mov bx, 7
            mov cx, 1
            int 10h
	    ret

    getkey:
            mov ah, 0               ; wait for key
            int 016h
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
	cmp BYTE [vga], 1
	je NEAR clearvga
	push    ax      ; store registers... 
        push    ds       
        push    bx       
        push    cx 
	push	di         

        mov     ax, 40h
        mov     ds, ax 
        mov     ah, 06h
        mov     al, 0
	mov	bh, 00001111b
        mov     ch, 0
        mov     cl, 0
        mov     di, 84h
        mov     dh, [di]
        mov     di, 4Ah
        mov     dl, [di]
        dec     dl     
        int     10h  
 
        pop     di      
        pop     cx       
        pop     bx       
        pop     ds       
        pop     ax  
	jmp cursor	

    clearvga:
	push    ax      ; store registers... 
        push    ds       
        push    bx       
        push    cx 
	push	di         

        mov     ax, 40h
        mov     ds, ax 
        mov     ah, 06h
        mov     al, 0
	mov	bx, 7
        mov     ch, 0
        mov     cl, 0
        mov     di, 84h
        mov     dh, [di]
        mov     di, 4Ah
        mov     dl, [di]
        dec     dl     
        int     10h  
 
        pop     di      
        pop     cx       
        pop     bx       
        pop     ds       
        pop     ax  

    
        ; set cursor position to top 
        ; of the screen: 
    cursor:  
	push    ax      ; store registers... 
        push    ds       
        push    bx       
        push    cx 
	push	di
        mov     bh, 0   
        mov     dl, 0    
        mov     dh, 0   
        mov     ah, 02
        int     10h
        pop     di      
        pop     cx       
        pop     bx       
        pop     ds       
        pop     ax  
        ret

    countdown:
    	    mov al, '5'
	    call char
	    call delay
	    mov al, '4'
	    call char
	    call delay
	    mov al, '3'
	    call char
	    call delay
	    mov al, '2'
	    call char
	    call delay
	    mov al, '1'
	    call char
	    call delay
	    mov al, '0'
	    call char
            ret

    delay:
            push cx
	    push dx
	    push ax
	    xor  ax, ax
	    mov  ah, 0x11
	    int  0x16
	    jnz donedelay
	    mov     cx, 5
            mov     dx, 200h
            mov     ah, 86h
	    int     15h
	donedelay:
	    pop cx
	    pop dx
	    pop ax
 	    ret

    print:			; 'si' comes in with string address
	    mov bx,7		; write to display
	    mov ah,0Eh		; screen function
    prs:    mov al,[si]         ; get next character
	    cmp al,0		; look for terminator 
            je finpr		; zero byte at end of string
	    int 10h		; write character to screen.    
            inc si	     	; move to next character
	    jmp prs		; loop
    finpr:  ret			; finished this line 

    printbx:
	    push si
	    mov si, bx
	    push bx			; 'bx' comes in with string address
	    mov bx,7		; write to display
	    mov ah,0Eh		; screen function
    prsbx:   mov al,[si]         ; get next character
	    cmp al,0		; look for terminator 
            je finprbx		; zero byte at end of string
	    int 10h		; write character to screen.    
     	    inc si	     	; move to next character
	    jmp prsbx		; loop
    finprbx: 	pop si
		pop bx
		ret			; finished this line 