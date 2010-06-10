%include "config.asm"
[BITS 16]
	; Boot record is loaded at 0000:7C00
[ORG 7c00h]
	mov [DriveNumber], dl	;save the original drive number
	xor eax, eax
	mov ds, ax		;Update the segment registers
	mov es, ax
	mov ss, ax
	mov fs, ax
	mov gs, ax
	mov [lbaad], eax
	mov [lbaad + 4], eax
	mov [address], ax
	mov word [readlen], 2
	mov word [len], 0x10
	mov word [segm], 0x1010
findsector:
	call ReadHardDisk
	mov ecx, [lbaad]
%ifdef sector.debug
	call printnum
%endif
	mov ax, [segm]
	mov gs, ax
dumpconts1:
	mov si, signature
	mov bx, signature-header
dumpconts1lp:
	mov cl, [gs:bx]
	cmp cl, [si]
	jne nodumpconts
	inc bx
	inc si
	cmp si, signatureend
%ifdef sector.debug
	jae near dumpconts
%else
	jae skipcontsdump
%endif
	jmp dumpconts1lp
nodumpconts:
	xor bx, bx
	mov eax, [lbaad]
	inc eax
	mov [lbaad], eax
	jmp findsector
skipcontsdump:
	mov eax, [lbaad]
	mov [lbaadorig], eax
lp:
	mov ecx, [gs:(signatureend - header)]
	xor eax, eax
	mov ax, [readlen]
	shl eax, 5
	add [segm], ax
	shl eax, 4
	sub ecx, eax
	jbe nomultitrack
	mov [gs:(signatureend - header)], ecx
	shr eax, 9
	add [lbaad], eax
	shr ecx, 9
	cmp ecx, 0x7F
	jbe notfull
	mov cx, 0x7F
notfull:
	mov [readlen], cx
	call ReadHardDisk
	jmp lp
nomultitrack:
	mov cx, [DriveNumber]
	mov ebx, [lbaadorig]
	jmp 0x1000:0x100
	
ReadHardDisk:
	mov si, diskaddresspacket
	xor ax, ax
	mov ah, 0x42
	mov dl, [DriveNumber]
	int 0x13
	jc ReadHardDisk
	ret
	
%ifdef sector.debug
dumpconts:
	mov si, line
	call print
	xor bx, bx
dumpconts2:
	mov ecx, [gs:bx]
	push bx
	call printnum
	pop bx
	add bx, 4
	cmp bx, 732
	jbe dumpconts2
	call keywait
	jmp skipcontsdump
	
keywait:
	mov si, bootmsg
	call print
	xor ax, ax
	int 16h
	ret
	
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
	mov di, si		;location of 0x10^x
	mov ecx, edx
	and ecx, 0xF		;just this digit
	call cnvrtexphx		;get this digit
	mov si, di
	shr edx, 4		;next digit
	jz donenxtephx
	jmp nxtexphx 
donenxtephx:
	pop di
	pop si
	ret
cnvrtexphx:			;convert this number
	mov bx, si		;place to convert to must be in si, number to convert must be in cx
	test ecx, ecx
	jz zerohx
cnvrthx:  mov al, [si]
	cmp al, '9'
	je lettershx
lttrhxdn: cmp al, 'F'
	je zerohx
	mov al, [si]
	inc al
	mov [si], al
	mov si, bx
cnvrtlphx: 
	dec ecx
	jnz cnvrthx
	ret
lettershx:
	mov al, 'A'
	dec al
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
	
number times 9 db 0
numberend:
db '  ',0
bootmsg db "Press any key to continue.",0
line db 10,13,0
%endif

%include 'source/signature.asm'
boot: ;to make sure this signature has an jump point, however useless
    times 510-($-$$) db 0
    dw 0AA55h	;magic byte
lbaadorig equ boot
DriveNumber equ lbaadorig + 4
diskaddresspacket equ DriveNumber + 1
len: equ diskaddresspacket ;size of packet
readlen:	equ len + 2	;blocks to read=maximum
address:	equ readlen + 2	;address to load kernel
segm:	equ address + 2	;segment
;start with known value for hd
lbaad: equ segm + 2	;lba address
incbin 'build/kernel.com' ;include the kernel file