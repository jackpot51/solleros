    ; MENU.ASM
db "JSOS"
dd 1
menustart:	
	mov ax, cs
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov [DriveNumber], cl
	mov [lbaad], edx
	mov ax, 0xA000
	mov gs, ax
	mov ax, 12h
	mov bx, 0
	int 10h
	jmp guiload

DriveNumber db 0
lbaad dd 0
	
vesamode dw 0
videomodecache dw 0

guiload:
	mov si, bootmsg
	call printrm
	mov ax, 0
	int 16h
	cmp al, "y"
	jne near guiload2
guiloadagain:
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
	cmp si, oemdata
	jae near guiload2	;;kill if no valid list is found
	jmp findvideomodes 	
;;debug,shows vmodes available
nextvmode:
	sub si, 2
	cmp si, reserved
	jb near guiloadagain
	mov cx, [si]
	cmp cx, 0xFFFF
	je near nextvmode
	add cx, 0x4000 		;;Linear Frame Buffer
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
isthisvideook db 10,13,"Is this video mode OK?(y/n)",13,10,0
setvesamode:
	mov cx, [xresolution]
	call decshow
	mov al, "x"
	call char
	mov cx, [yresolution]
	call decshow
	mov al, "@"
	call char
	mov cl, [bitsperpixel]
	call decshow
	mov si, isthisvideook
	call printrm
	mov ax, 0
	int 16h
	mov si, [videomodecache]
	cmp al, "y"
	jne near nextvmode
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
	mov byte [guinodo], 0
	xor eax, eax
	xor ebx, ebx
	xor ecx, ecx
	xor edx, edx
	xor esi, esi
	xor edi, edi	;;reset registers
	jmp pmode
guiload2:
	mov cx, 480
	mov dx, 640
	mov [resolutionx], dx
	add dx, dx
	mov [resolutionx2], dx
	mov [resolutiony], cx
	mov ax, 12h
	mov bx, 0
	int 10h
	mov byte [guinodo], 1
	xor ebx, ebx
	xor ecx, ecx
	xor edx, edx
	xor esi, esi
	xor edi, edi
	jmp pmode
;;	jmp gui ;;test vesa

guinodo db 0

    printrm:			; 'si' comes in with string address
	    mov bx,07		; write to display
	    mov ah,0Eh		; screen function
    prs2:    mov al,[si]         ; get next character
	    cmp al,0		; look for terminator 
            je finpr2		; zero byte at end of string
	    int 10h		; write character to screen.    
     	    inc si	     	; move to next character
	    jmp prs2		; loop
    finpr2: ret

dcnm db 0,0,0,0,0
dcnmend db 0,0


decshow:
	mov si, dcnm
decclear:
	mov al, "0"
	mov [si], al
	inc si
	cmp si, dcnmend
	jbe decclear
	dec si
	call convertrm
	mov si, dcnm
dectst:
	mov al, [si]
	inc si
	cmp si, dcnmend
	ja dectstend
	cmp al, "0"
	jbe dectst
dectstend:
	dec si
	call printrm
	ret
	
	
convertrm:
	dec si
	mov bx, si		;place to convert into must be in si, number to convert must be in cx
cnvrtrm:
	mov si, bx
	sub si, 3
ten3rm:	inc si
	cmp cx, 1000
	jb ten2rm
	sub cx, 1000
	inc byte [si]
	jmp cnvrtrm
ten2rm:	inc si
	cmp cx, 100
	jb ten1rm
	sub cx, 100
	inc byte [si]
	jmp cnvrtrm
ten1rm:	inc si
	cmp cx, 10
	jb ten0rm
	sub cx, 10
	inc byte [si]
	jmp cnvrtrm
ten0rm:	inc si
	cmp cx, 1
	jb tendnrm
	sub cx, 1
	inc byte [si]
	jmp cnvrtrm
tendnrm:
	ret




    char: 		    ;char must be in al
           mov bx, 07
	   mov ah, 0Eh
	   int 10h
	    ret

		shutdown:
			   mov eax, cr0
			   and al,0xFE     ; back to realmode
			   mov  cr0, eax   ; by toggling bit again
			   sti
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

	coldboot:
			   mov eax, cr0
			   and al,0xFE     ; back to realmode
			   mov  cr0, eax   ; by toggling bit again
			   sti
			MOV AX, 0040h
			MOV ES, AX
			MOV WORD [ES:00072h], 0h
			JMP 0FFFFh:0000h
			IRET

		warmboot:
			call realmode
			MOV AX, 0040h
			MOV ES, AX
			MOV WORD [ES:00072h], 01234h
			JMP 0FFFFh:0000h
			IRET


realmode:
   mov eax, cr0
   and al,0xFE     ; back to realmode
   mov  cr0, eax   ; by toggling bit again
   sti
   mov eax, 0
   ret
   
bootmsg:	db "Boot into the GUI?(y/n)",10,13,0
