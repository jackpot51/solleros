    ; MENU.ASM
	[BITS 16]
prog:	
	    mov ax, cs
	    jmp mainindex	;;this command gives the solleros user the location of mainindex
	    db "JRS",0	;;this gives the bootloader a key to look for
mainindex:
	    jmp mainindexdn	;;this gives the size of the index
	    dw 0405h,progstart,batchprogend,fileindex,fileindexend,variables,varend,nwcmd,int30h,physbaseptr,0
mainindexdn:
	    mov ds, ax
	    mov es, ax
	    mov ss, ax
	    call realmode	;;make sure we are in realmode
	    mov byte [mouseon], 0
	    mov [DriveNumber], cl
	mov ax, videobuf2
	mov fs, ax
	call int30hah8
	mov ax, 0xA000
	mov gs, ax
	mov ax, 12h
	mov bx, 0
	int 10h
	call indexfiles	
	mov dx, 0
	jmp guiload ;;strait to gui
	iret

DriveNumber db 0

    welcome:
	xor eax, eax
	xor ebx, ebx
	xor ecx, ecx
	xor edx, edx
	xor esi, esi
	xor edi, edi	;;reset registers
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
	    call pmode
	    jmp menu

    char: 		    ;char must be in al
            mov [charcache], al
            mov bx, 7
	    mov si, charcache
	    mov al, 0
            call int30hah1
	    mov al, [charcache]
	    ret
	charcache db 0,0,0

    getkey:
            mov al, 0               ; wait for key
	    call int30hah5
            ret

    menu:
	    mov si, menumsg
	    call print
	    mov si, wrongmsg
    wrong:  call getkey
    	    cmp al, 'g'
	    je near guiload
	    cmp al, 's'
            je near shutdown
	    cmp al, 'c'
	    je near coldboot
	    cmp al, 'w'
	    je near warmboot
	    cmp al, 'b'
	    je near bootit
	    cmp al, '`'
	    je near batchfilerunit
	    call char
	    sub dl, 2
	    mov si, line
	    add si, 2
            jmp wrong


vesamode dw 0
videomodecache dw 0
guiload:
	call realmode
	mov ax, 04F00h
	mov di, VBEMODEBLOCK
	int 10h
	mov si, reserved
	sub si, 2
findvideomodes:
	add si, 2
	mov cx, [si]
	cmp cx, 0xFFFF
	je near nextvmode
	cmp di, oemdata
	jae near welcome ;;kill if no valid list is found
	jmp findvideomodes
;;debug,shows vmodes available
	mov [vesamode], cx
	mov [videomodecache], si
	mov ax, 04F01h
	mov di, VBEMODEINFOBLOCK
	int 10h
	mov si, [videomodecache]
	mov cl, [bitsperpixel]
	cmp cl, 16
	jne findvideomodes
	mov ecx, 0
	mov cx, [xresolution]
	call showdec
	mov ecx, 0
	mov cx, [yresolution]
	call showdec
	mov ecx, 0
	mov cl, [bitsperpixel]
	call showdec
	mov cx, [vesamode]
	call showhex
	mov byte [firsthexshown], 4
	cmp si, oemdata
	jb findvideomodes
	jmp welcome

nextvmode:
	sub si, 2
	cmp si, reserved
	jb near welcome
	mov cx, [si]
	cmp cx, 0xFFFF
	je near welcome
	add cx, 0x4000 ;;Linear Frame Buffer
	mov ax, 04F01h
	mov di, VBEMODEINFOBLOCK
	mov [vesamode], cx
	int 10h
	mov al, [bitsperpixel]
	cmp al, 16
	jne nextvmode
	mov [videomodecache], si
	cmp ah, 0
	je near setvesamode
	jmp nextvmode
modes:
	dw 0x4161	;;1280*800*16 bits
	dw 0x411A	;;1280*1024*16 bits
	dw 0x4117	;;1024*768*16 bits
	dw 0x4114	;;800*600*16 bits
	dw 0x4111	;;640*480*16 bits

isthisvideook db 10,13,"Is this video mode OK?(y/n)",0

setvesamode:
	call clear
	mov byte [shownumberstack], 1
	mov ecx, 0
	mov cx, [xresolution]
	call showdec
	sub dl, 2
	mov al, "x"
	call char
	mov ecx, 0
	mov cx, [yresolution]
	call showdec
	sub dl, 2
	mov al, "@"
	call char
	mov ecx, 0
	mov cl, [bitsperpixel]
	call showdec
	mov si, isthisvideook
	call print
	mov ax, 0
	int 16h
	mov di, [videomodecache]
	cmp al, "y"
	jne nextvmode
	mov byte [shownumberstack], 0
	mov dx, [xresolution]
	mov cx, [yresolution]
	mov [resolutionx], dx
	mov [resolutiony], cx
	add dx, dx
	mov [resolutionx2], dx
	mov dx, 0
	mov cx, 0
	mov ax, 04F02h
	mov bx, [vesamode]
	int 10h		;;enter VESA mode
	mov ax, 0x9000
	mov gs, ax
	mov edi, [physbaseptr]
	sub edi, 0x20000
	mov [physbaseptr], edi	;;fix lfb base, is over by 0x20000 or 0x2000:0 where OS starts
	xor eax, eax
	xor ebx, ebx
	xor ecx, ecx
	xor edx, edx
	xor esi, esi
	xor edi, edi	;;reset registers
	call pmode
	jmp gui ;;test vesa
batchfilerunit:
	call clear
	jmp runbatch2 ;;batch is in buftxt2, change buftxt2 to the batch you want
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
    bootit:
		call clear
	    jmp os

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
