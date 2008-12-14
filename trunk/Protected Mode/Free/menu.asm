    ; MENU.ASM
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
	mov [DriveNumber], cl
	mov ax, 0xA000
	mov gs, ax
	mov ax, 12h
	mov bx, 0
	int 10h
	mov si, graphicstable
	mov di, rbuffstart
	mov eax, 0
initmemory:
	mov [si], eax
	add si, 4
	cmp si, di
	jbe initmemory
	mov si, mcursor
	mov di, fontend2
cursorcopyinit:
	mov ax, [si]
	mov [di], ax
	add di, 2
	add si, 2
	cmp di, fontend
	jb cursorcopyinit
	call fontload
	jmp guiload ;;strait to gui


DriveNumber db 0

currentfont db 0

fontload:
	mov ah, 09h
	mov bx, 7
	mov cx, 1
	mov al, [currentfont] 
	int 10h
	mov al, [currentfont]
	inc al
	mov [currentfont], al
	mov ah, 0
	dec al
	mov si, fonts
	shl ax, 4
	add si, ax
	shr ax, 4
	mov bx, 0
	mov cx, 0
	mov dx, 0
pixelload:
	cmp cx, 7
	ja nextrow
	cmp dx, 14
	ja doneloadpixels
	mov ah, 0dh
	mov bh, 0
	int 10h
	cmp al, 0
	je pixeloff
	cmp al, 1
	jae pixelon
	jmp pixelload
doneloadpixels:
	inc si
	cmp si, fontend2
	jae donefontload
	jmp fontload
donefontload:
	ret
	
nextrow: mov cx, 0
	add dx, 1
	inc si
	jmp pixelload
pixeloff:
	inc cx
	jmp pixelload
cxcache2 db 0,0
pixelon:
	mov al, 1
	mov [cxcache2], cx
pixelloop:
	cmp cx, 0
	je nopixelloop
	ror al, 1
	loop pixelloop
nopixelloop:
	add [si], al
	mov cx, [cxcache2]
	inc cx
	jmp pixelload

vesamode dw 0
videomodecache dw 0

guiload:
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
	jae near guiload	;;kill if no valid list is found
	jmp findvideomodes 	
;;debug,shows vmodes available
nextvmode:
	sub si, 2
	cmp si, reserved
	jb near guiload
	mov cx, [si]
	cmp cx, 0xFFFF
	je near guiload
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
	jne nextvmode
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
	mov edi, [physbaseptr]
	sub edi, 0x20000
	mov [physbaseptr], edi	;;fix lfb base, is over by 0x20000 or 0x2000:0 where OS starts
	xor eax, eax
	xor ebx, ebx
	xor ecx, ecx
	xor edx, edx
	xor esi, esi
	xor edi, edi	;;reset registers
jmp pmode

;;	jmp gui ;;test vesa


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
			call realmode	
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
			call realmode
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
