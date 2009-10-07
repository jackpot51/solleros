[BITS 16]
	; Boot record is loaded at 0000:7C00
[ORG 7c00h]
	mov [DriveNumber], dl	;save the original drive number
	xor ax,		ax
	mov ds,		ax		;Update the segment registers
	mov es, 	ax
	mov ss,		ax
	mov fs,		ax
	mov gs,		ax
	jmp ReadHardDisk

	DriveNumber db 0
	line db 10,13,0
	
    print:			; 'si' comes in with string address
	    mov bx,7		; write to display
	    mov ah,0Eh		; screen function
    prs:    mov al,[si]         ; get next character
	    cmp al,0		; look for terminator 
            je finpr		; zero byte at end of string
	    int 10h		; write character to screen.    
     	    inc si	     	; move to next character
	    jmp prs		; loop
    finpr: ret
ReadHardDisk:
	mov si, diskaddresspacket
	xor ax, ax
	mov ah, 0x42
	mov dl, [DriveNumber]
	int 0x13
	jc ReadHardDisk
	mov ecx, [lbaad]
	call printnum
	mov ax, [segm]
	mov gs, ax
	mov bx, 4
	mov ecx, [gs:bx]
dumpconts1:
	mov si, signature
	xor bx, bx
dumpconts1lp:
	mov cl, [gs:bx]
	cmp cl, [si]
	jne nodumpconts
	inc bx
	inc si
	cmp si, signatureend
	jae dumpconts
	jmp dumpconts1lp
nodumpconts:
	xor bx, bx
	mov eax, [lbaad]
	inc eax
	mov [lbaad], eax
	jmp ReadHardDisk
dumpconts:
	mov esi, line
	call print
	xor bx, bx
dumpconts2:
	mov ecx, [gs:bx]
	push bx
	call printnum
	pop bx
	add bx, 4
	cmp bx, 700
	jbe dumpconts2
	mov cx, [DriveNumber]
	mov edx, [lbaad]
    jmp 0x1000:(signatureend - signature)

printnum:
	mov si, number
	mov di, numberend
	xor bx, bx
	xor ax, ax
	call converthex
chkzero:
	mov al, [si]
	cmp al, '0'
	jne donechkzero
	inc si
	cmp si, di
	jb donechkzero
donechkzero:
	call print
	ret

converthex: 
clearbuffer:
	mov al, '0'
	push si
	push di
clearbuf: cmp si, di
	jae doneclearbuff
	mov [si], al
	inc si
	jmp clearbuf
doneclearbuff:
	pop si	;pop pushed di into si
	push si ;then repush the value
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
	pop di
	pop si
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
readlen:	dw 0x7F	;;blocks to read=maximum
address:	dw 0x0	;;address 0
segm:	dw 0x1000	;;segment
;;start with known value for hd
lbaad:
	dd 0	;;lba address
	dd 0

%include 'source/signature.asm'
    	times 510-($-$$) db 0
    dw 0AA55h	;;magic byte
