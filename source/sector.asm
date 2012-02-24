%include "config.asm"
[BITS 16]
	; Boot record is loaded at 0000:7C00
[ORG 0]
	jmp 0x7C0:loader
loader:
	mov ax, cs
	mov ds, ax		;Update the segment registers
	mov es, ax
	mov ss, ax
	mov fs, ax
	mov gs, ax
	mov [DriveNumber], dl	;save the original drive number
	mov dword [lbaad], 0
	mov dword [lbaad + 4], 0
.findsector:
	mov word [len], 0x10
	mov word [readlen], 1
	mov word [address], 0
	mov word [segm], 0x1000
	call ReadHardDisk
	mov ax, [segm]
%ifdef dos.compatible
	add ax, 0x10
%endif
	mov gs, ax
.check:
	mov si, signature
	mov bx, (signature - header)
.lp:
	mov cl, [gs:bx]
	cmp cl, [si]
	jne .fail
	inc bx
	inc si
%ifdef sector.debugall
	pusha
	call dumpconts
	popa
%endif
	cmp si, signatureend
	jae .good
	jmp .lp
.fail:
	xor bx, bx
	mov eax, [lbaad]
	inc eax
	mov [lbaad], eax
	jmp .findsector
.good:
	mov eax, [lbaad]
	mov [lbaadorig], eax
.load:
	mov ecx, [gs:(signatureend - header)]
	xor eax, eax
	mov ax, [readlen]
	shl eax, 5
	add [segm], ax
	shl eax, 4
	sub ecx, eax
	jbe .nomultitrack
	mov [gs:(signatureend - header)], ecx
	shr eax, 9
	add [lbaad], eax
	jno .noover
	inc dword [lbaad+4]
.noover:
	shr ecx, 9
	cmp cx, 0x7F
	jbe .notfull
	mov cx, 0x7F
.notfull:
	mov [readlen], cx
	call ReadHardDisk
	jmp .load
.nomultitrack:
%ifdef sector.debug
	call keywait
%endif
	mov cx, [DriveNumber]
	mov ebx, [lbaadorig]
%ifdef dos.compatible
	jmp 0x1000:0x100
%else
	jmp 0x1000:0
%endif
	
ReadHardDisk:
%ifdef sector.debug
	pusha
	mov ecx, [lbaad]
	call printnum
	mov ecx, [len]
	call printnum
	mov ecx, [address]
	call printnum
	mov si, line
	call print
	popa
%endif
	mov si, diskaddresspacket
	xor ax, ax
	mov ah, 0x42
	mov dl, [DriveNumber]
	int 0x13
	jc ReadHardDisk
	ret
	
%ifdef sector.debug
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
.lp:
	mov al,[si]         ; get next character
	cmp al,0		; look for terminator 
	je .ret		; zero byte at end of string
	int 10h		; write character to screen.    
	inc si	     	; move to next character
	jmp .lp		; loop
.ret:	ret

keywait:
	mov si, bootmsg
	call print
	xor ax, ax
	int 16h
	ret

bootmsg db "Press any key to continue.",0
line db 10,13,0
	
number times 9 db 0
numberend:
db '  ',0
%endif
	
%ifdef sector.debugall
dumpconts:
	mov si, line
	call print
	xor bx, bx
.lp:
	mov ecx, [gs:bx]
	push bx
	call printnum
	pop bx
	add bx, 4
	cmp bx, 732
	jbe .lp
	ret
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