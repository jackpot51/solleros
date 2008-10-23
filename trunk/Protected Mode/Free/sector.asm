    ; SECTOR.ASM
    ; Load a program off the disk and jump to it

    ; Tell the compiler that this is offset 0.
    ; It isn't offset 0, but it will be after the jump.
[BITS 16]
	; Boot record is loaded at 0000:7C00
ORG 7c00h
	jmp start

	DriveNumber db 0
	modifier db 0,7

	sectormsg2 db "Loading OS...",10,13,0
	sectormsg3 db "Roses are 0xFF",10,13,0
	sectormsg4 db "Violets are 0x01",10,13,0
	sectormsg5 db "All of my base",10,13,0
	sectormsg6 db "Are belong to you",10,13,0
	
    start:                ; Update the segment registers
	mov [DriveNumber], dl
	xor ax,		ax		; XOR ax
	mov ds,		ax		; Mov AX into DS
	mov ax, 12h
	mov bx, 0
	int 10h

ResetFloppy:
	mov ax,		0x00		; Select Floppy Reset BIOS Function
        mov dl,		[DriveNumber]	; Select the floppy booted from

        int 13h				; Reset the floppy drive
        jc ResetFloppy		; If there was a error, try again.

	mov si, sectormsg2
	call print2
	mov byte [modifier + 1], 0FFh
	mov si, sectormsg3
	call print2
	mov byte [modifier + 1], 1
	mov si, sectormsg4
	call print2
	mov byte [modifier + 1], 7
	mov si, sectormsg5
	call print2
	mov byte [modifier + 1], 7
	mov si, sectormsg6
	call print2
	jmp ReadFloppy
    print2:			; 'si' comes in with string address
	    mov bx,[modifier]		; write to display
	    mov ah,0Eh		; screen function
    prs2:    mov al,[si]         ; get next character
	    cmp al,0		; look for terminator 
            je finpr2		; zero byte at end of string
	    int 10h		; write character to screen.    
     	    inc si	     	; move to next character
	    jmp prs2		; loop
    finpr2: ret

ReadFloppy:
	mov ax, 2000h
	mov es, ax
         mov bx,	0h		; Load at 2000h:0000h.
         mov ah,	0x02		; Load disk data to ES:BX
         mov al,	17		; Load two floppy head full's worth of data.

         mov ch,	0		; First Cylinder
         mov cl,	2		; Start at the 2nd Sector, so you don't load the bootsector
					
         mov dh,	0		; Use first floppy head
         mov dl,	[DriveNumber]	

         int 13h			; Read the floppy disk.

	 jc ReadFloppy			; Error, try again.

ReadFloppy2:
	mov bx, 2200h
	mov ah, 2
	mov al,		18 		; The Second Head Full
	mov ch, 	0
	mov cl, 	1
	mov dh, 	1	; Set it to the second head
	mov dl, [DriveNumber]
	int 13h			; Read the floppy disk.

	jc ReadFloppy2		; If there was a error, try again.

ReadFloppy3:
	mov bx, 4600h
	mov ah, 2
	mov al,		18 		; The Third Head Full
	mov ch, 	1
	mov cl, 	1
	mov dh, 	0	; Set it to the third head
	mov dl, [DriveNumber]
	int 13h			; Read the floppy disk.

	jc ReadFloppy3		; If there was a error, try again.

ReadFloppy4:
	mov bx, 6A00h
	mov ah, 2
	mov al,		18 		
	mov ch, 	1
	mov cl, 	1
	mov dh, 	1	
	mov dl, [DriveNumber]
	int 13h			; Read the floppy disk.

	jc ReadFloppy4	; If there was a error, try again.

ReadFloppy5:
	mov bx, 8E00h
	mov ah, 2
	mov al,		18 		
	mov ch, 	2
	mov cl, 	1
	mov dh, 	0	
	mov dl, [DriveNumber]
	int 13h			; Read the floppy disk.

	jc ReadFloppy5	; If there was a error, try again.

	mov cl, [DriveNumber]
		; Stop the floppy motor from spinning 
 
        mov dl,		[DriveNumber]	; Select which motor to stop 

	; Select Stop Floppy Motor function:
	mov edx, 0x3f2
	mov al, 0x0c

	; Stop floppy motor:
	out dx, al      ; Floppy Motor stopped!
        jmp 2000h:0000

    times 510-($-$$) db 0
    dw 0AA55h