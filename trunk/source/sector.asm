    ; SECTOR.ASM
    ; Load a program off the disk and jump to it

    ; Tell the compiler that this is offset 0.
    ; It isn't offset 0, but it will be after the jump.
[BITS 16]
	; Boot record is loaded at 0000:7C00
ORG 7c00h

;;0x000: EB 58 90 6D 6B 64 6F 73 66 73 00 00 02 08 20 00 EXAMPLE
;;0x010: 02 00 00 00 00 F8 00 00 3E 00 B9 00 00 00 00 00
;;0x020: 26 DE B2 00 A2 2C 00 00 00 00 00 00 02 00 00 00
;;0x030: 01 00 06 00 00 00 00 00 00 00 00 00 00 00 00 00
;;0x040: 00 00 29 52 D1 D2 48 20 20 20 20 20 20 20 20 20
;;0x050: 20 20 46 41 54 33 32 20 20 20 0E 1F BE 77 7C AC
;;0x060: 22 C0 74 0B 56 B4 0E BB 07 00 CD 10 5E EB F0 32
;;0x070: E4 CD 16 CD 19 EB FE 54 68 69 73 20 69 73 20 6E
;;0x080: 6F 74 20 61 20 62 6F 6F 74 61 62 6C 65 20 64 69
;;0x090: 73 6B 2E 20 20 50 6C 65 61 73 65 20 69 6E 73 65
;;0x0A0: 72 74 20 61 20 62 6F 6F 74 61 62 6C 65 20 66 6C
;;0x0B0: 6F 70 70 79 20 61 6E 64 0D 0A 70 72 65 73 73 20
;;0x0C0: 61 6E 79 20 6B 65 79 20 74 6F 20 74 72 79 20 61
;;0x0D0: 67 61 69 6E 20 2E 2E 2E 20 0D 0A 00 00 00 00 00
;;0x0E0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

;;fuck trying to set up FAT for now
;FATDRIVETABLE:
;	;jmp short 0x3C		;;0x00-0x02, jump over table
;	db "SOLLEROS"		;;0x03-0x0A, os name
;	db 0x02,0x08		;;0x0B-0x0C, number of bytes per sector
;	db 0x20			;;0x0D, sectors per cluster
;	db 0,0x02		;;0x0F-0x20, reserved sectors
;	db 0x00			;;0x21, number of FAT tables
;	db 0,0xB9		;;0x22-0x23, number of directory entries
;	db 0,0			;;0x24-0x25, total sectors, if zero, > 0xFFFF
;	db 0			;;0x26, media descriptor
;	db 0x26,0xDE		;;0x27-0x28, sectors per FAT table
;	db 0xB2,0		;;0x29-0x2A, sectors per track
;	db 0xA2,0x2C		;;0x2B-0x2C, heads on storage media
;	db 0x0,0x0,0x0,0x0	;;0x2D-0x31, LBA
;FAT32EXTENDEDTABLE:
;	db 0xA2,0x2C,0,0	;;4 bytes, size of FAT table in bytes
;	db 0,0			;;2 bytes, flags




	jmp start

	DriveNumber db 0
	sectormsg2 db "Loading OS...",10,13,0
	sectormsg3 db 13,10,"SollerOS loaded.",10,13,0
	continuemsg db "Press ", 0x22, "ANY", 0x22, " key to continue.",0
	
    start:                ; Update the segment registers
	mov [DriveNumber], dl
	xor ax,		ax		; XOR ax
	mov ds,		ax		; Mov AX into DS
	mov es, 	ax
	mov ss,		ax
	mov fs,		ax
	mov gs,		ax

Resetdrive:
	mov ax,		0x00		; Select Floppy Reset BIOS Function
        mov dl,		[DriveNumber]	; Select the floppy booted from
        int 13h				; Reset the floppy drive
        jc Resetdrive		; If there was a error, try again.

	mov si, sectormsg2
	call print2
	jmp ReadHardDisk
    print2:			; 'si' comes in with string address
	    mov bx,7		; write to display
	    mov ah,0Eh		; screen function
    prs2:    mov al,[si]         ; get next character
	    cmp al,0		; look for terminator 
            je finpr2		; zero byte at end of string
	    int 10h		; write character to screen.    
     	    inc si	     	; move to next character
	    jmp prs2		; loop
    finpr2: ret
ReadHardDisk:
	mov si, diskaddresspacket
	mov ax, 0
	mov ah, 0x42
	mov dl, [DriveNumber]
	int 0x13
	jc ReadHardDisk
	mov ecx, [lbaad]
	call printnum
	mov ax, 0x6000
	mov gs, ax
	mov bx, 4
	mov ecx, [gs:bx]
	mov bx, 0
	cmp ecx, 0x53524A00	;;My initials, JRS, in ascii
	je dumpconts
	mov eax, [lbaad]
	inc eax
	mov [lbaad], eax
	jmp ReadHardDisk
dumpconts:
	pusha
	mov si, sectormsg3
	call print2
	popa
dumpconts2:
	mov ecx, [gs:bx]
	push bx
	call printnum
	pop bx
	add bx, 4
	cmp bx, 700
	jbe dumpconts2
	mov si, continuemsg
	call print2
	mov ax, 0
	int 0x16
	mov cl, [DriveNumber]
	mov edx, [lbaad]
    jmp 0x6000:0

printnum:
	mov si, number
	mov di, numberend
	mov bx, 0
	mov ax, 0
	call converthex
chkzero:
	mov al, [si]
	cmp al, '0'
	jne donechkzero
	inc si
	cmp si, di
	jb donechkzero
donechkzero:
	call print2
	ret
	
sibuf db 0,0
dibuf db 0,0

converthex: 
clearbuffer:
	mov al, '0'
	mov [sibuf], si
	mov [dibuf], di
clearbuf: cmp si, di
	jae doneclearbuff
	mov [si], al
	inc si
	jmp clearbuf
doneclearbuff:
	mov si, [dibuf]
	mov edx, ecx
nxtexphx:			;0x10^x
	dec si
	mov di, si		;;location of 0x10^x
	mov ecx, edx
	and ecx, 0xF		;;just this digit
	call cnvrtexphx		;;get this digit
	mov si, di
	shr edx, 4		;;next digit
	cmp edx, 0
	je donenxtephx
	jmp nxtexphx 
donenxtephx:
	mov si, [sibuf]
	mov di, [dibuf]
	ret
cnvrtexphx:			;;convert this number
	mov bx, si		;place to convert to must be in si, number to convert must be in cx
	cmp ecx, 0
	je zerohx
cnvrthx:  mov al, [si]
	cmp al, '9'
	je lettershx
lttrhxdn: cmp al, 'F'
	je zerohx
	mov al, [si]
	inc al
	mov [si], al
	mov si, bx
cnvrtlphx: sub ecx, 1
	cmp ecx, 0
	jne cnvrthx
	ret
lettershx:
	mov al, 'A'
	sub al, 1
	mov [si], al
	jmp lttrhxdn
zerohx:	mov al, '0'
	mov [si], al
	dec si
	mov al, [si]
	cmp al, 'F'
	je zerohx
	inc ecx
	jmp cnvrtlphx

number times 9 db 0
numberend:
db '  ',0

diskaddresspacket:
len:	db 0x10 ;;size of packet
	db 0
readlen:	dw 0x80	;;blocks to read
address:	dw 0x0	;;address 0
segm:	dw 0x6000	;;segment
lbaad:	dd 0	;;lba address
	dd 0

    	times 510-($-$$) db 0
    dw 0AA55h	;;magic byte

;;partition table-does not matter
;;    times 446-($-$$) db 0	;;skip to partition table
;;ptable:
;;  	db 0x80			;;bootable
;;    	db 0x1			;;start head
;;    	db 0x1,0x0		;;start sector,cylinder
;;    	db 0x0B			;;system id, 0B = FAT 32
;;	db 0xB8			;;end head
;;	db 0xFE,0xFD		;;end sector,cylinder
;;	db 0x3E,0,0,0		;;relative sector
;;	db 0x26,0xDE,0xB2,0	;;total sectors
;;;00 00 00 00 00 00 00 00 00 00 00 00 00 00 80 01
;;;01 00 0B B8 FE FD 3E 00 00 00 26 DE B2 00 00 00
;;;00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
;;;00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
;;;00 00 00 00 00 00 00 00 00 00 00 00 00 00 55 AA
