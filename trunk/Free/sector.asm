    ; SECTOR.ASM
    ; Load a program off the disk and jump to it

    ; Tell the compiler that this is offset 0.
    ; It isn't offset 0, but it will be after the jump.

	; Boot record is loaded at 0000:7C00
ORG 7c00h
	jmp start

	DriveNumber db 0

	sectormsg2 db "Loading OS...",0
	
    start:                ; Update the segment registers
	
	mov si, sectormsg2
    print2:			; 'si' comes in with string address
	    mov bx,7		; write to display
	    mov ah,0Eh		; screen function
    prs2:    mov al,[si]         ; get next character
	    cmp al,0		; look for terminator 
            je finpr2		; zero byte at end of string
	    int 10h		; write character to screen.    
     	    inc si	     	; move to next character
	    jmp prs2		; loop
    finpr2:

ResetFloppy:
	mov ax,		0x00		; Select Floppy Reset BIOS Function
        mov dl,		[DriveNumber]	; Select the floppy FritzOS booted from

        int 13h				; Reset the floppy drive

        jc ResetFloppy		; If there was a error, try again.

; Read the floppy drive for loading the FritzOS C+ Kernel
ReadFloppy:
	mov ax, 1000h
	mov es, ax
         mov bx,	0h		; Load FritzOS at 100000h.
         mov ah,	0x02		; Load disk data to ES:BX
         mov al,	40		; Load two floppy head full's worth of data.

         mov ch,	0		; First Cylinder
         mov cl,	2		; Start at the 2nd Sector, so you don't load the bootsector, you load
					;  the C++ Kernel/Second Stage Loader ( they are linked together ).
         mov dh,	0		; Use first floppy head
         mov dl,	[DriveNumber]	; Load from the drive FritzOS booted from.

         int 13h			; Read the floppy disk.

	 jc ReadFloppy			; Error, try again.

	mov cl, [DriveNumber]

        jmp 1000h:0000


    times 510-($-$$) db 0
    dw 0AA55h