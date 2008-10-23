    ; SECTOR.ASM
    ; Load a program off the disk and jump to it

    ; Tell the compiler that this is offset 0.
    ; It isn't offset 0, but it will be after the jump.
[BITS 16]
	; Boot record is loaded at 0000:7C00
ORG 7c00h
	xor ax, ax
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
	mov ds,		ax		; Mov AX into DS

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

setupfloppyloop:
	mov bx, 2200h		;;start at 2000h:2200h
	mov ch, 0		;;cylinder 0
	mov dh, 1		;;head 1
	mov byte [track], 1	;;this is track 1

Readfloppyloop:
save:			        ;;SAVE VALUES
	mov [bxcache], bx	
	mov [cylinder], ch	
	mov [head], dh	

error:
	mov bx, [bxcache]
	mov ch, [cylinder]
	mov dh, [head]
	mov ah, 2		;;load disk data at ES:BX
	mov al, 18		;;read one track
	mov cl, 1		;;start at first sector
	mov dl, [DriveNumber] 	;;use found drive
	int 13h			;;read!!
	jc error
	
restorevalues:
	mov bx, [bxcache]
	mov ch, [cylinder]
	mov dh, [head]

	cmp dh, 1		;;if head is not 1
	jne incdh		;;switch head
	mov dh, 0		;;head = 0			
	add ch, 1		;;switch cylinder
	jmp noincdh		
incdh:	mov dh, 1		;;switch head
noincdh:
	cmp bx, 0DC00h		;;If bx is the correct size
	jb nextbx		;;increment bx
	mov ax, es		;;otherwise,			
	add ax, 1000h		;;add 1000h to es		
	mov es, ax		;;and rollover bx		
nextbx:	add bx, 2400h		;;increment bx
	inc byte [track]	;;next track
	mov ax, [maxtrack]	;;get max track
	cmp [track], ax		;;too many tracks?
	jbe Readfloppyloop	;;if not, read next track
	

        mov dl,		[DriveNumber]	; Select which motor to stop 
	mov cl,		[DriveNumber]
	; Select Stop Floppy Motor function:
	mov edx, 0x3f2
	mov al, 0x0c

	; Stop floppy motor:
	out dx, al      ; Floppy Motor stopped!
        jmp 2000h:0000

track db 0
maxtrack db 5	;;use dd to figure this out
cylinder db 0
head	db 0
bxcache db 0,0
    times 510-($-$$) db 0
    dw 0AA55h

;	ch	dh		  es:bx
;track	cyl	head	sector	startmem	endmem
;0	0	0	18	2000:0000	2000:2200
;1	0	1	36	2000:2200	2000:4600
;2	1	0	54	2000:4600	2000:6A00
;3	1	1	72	2000:6A00	2000:8E00
;4	2	0	90	2000:8E00	2000:B200
;5	2	1	108	2000:B200	2000:D600
;6	3	0	126	2000:D600	2000:FA00
;7	3	1	144	2000:FA00	3000:1E00
;8	4	0	162	3000:1E00	3000:4200
;9	4	1	180	3000:4200	3000:6600
;10	5	0	198	3000:6600	3000:8A00
;11	5	1	216	3000:8A00	3000:AE00
;12	6	0	234	3000:AE00	3000:D200
;13	6	1	252	3000:D200	3000:F600
;14	7	0	270	3000:F600	4000:1A00
;15	7	1	288	4000:1A00	4000:3E00