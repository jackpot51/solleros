diskr:
			;read from disk using real mode-it does not work with large files
			;sector count in cl
			;disk number in ch
			;48 bit address with last 32 bits in ebx
			;buffer in esi
			;puts end of buffer in edi and end lba address in edx
	mov [sdlength], cl
	mov [sdaddress], ebx
	mov [oldesireal], esi
	mov si, readdiskreal
	mov [realmodeptr], si
	mov esi, backfromrealread
	mov [realmodereturn], esi
	jmp realmode
sdlength db 0
sdaddress dd 0

[BITS 16]
readdiskreal:
	mov word [dlen], 0x10
	mov word [daddress], 0
	mov word [dsegm], 0x100
	mov [dlbaad], ebx
	mov [dreadlen], cl
ReadHardDisk:
	mov si, diskaddresspacket
	xor ax, ax
	mov ah, 0x42
	mov dl, [dnumber]
	int 0x13
	jc ReadHardDisk
	ret

dnumber db 0x80
diskaddresspacket:
dlen:	db 0x10 ;size of packet
		db 0
dreadlen:	dw 0x7F	;blocks to read=maximum
daddress:	dw 0x0	;address 0
dsegm:		dw 0x100	;segment
		;start with known value for hd
dlbaad:
	dd 0	;lba address
	dd 0
[BITS 32]
backfromrealread:
	mov esi, [oldesireal]
	mov ebx, [sdaddress]
	xor ecx, ecx
	mov cl, [sdlength]
	add ebx, ecx
	mov ax, LINEAR_SEL
	mov fs, ax
	mov edi, 0x1000
	mov dl, 0
	shl cl, 1
copyfromrmodedisk:
	mov al, [fs:edi]
	mov [esi], al
	inc edi
	inc esi
	dec dl
	cmp dl, 0
	jne copyfromrmodedisk
	dec cl
	mov dl, 0
	cmp cl, 0
	jne copyfromrmodedisk
	mov ax, NEW_DATA_SEL
	mov fs, ax
	mov edi, esi
	mov esi, [oldesireal]
	mov edx, ebx
	mov ebx, [sdaddress]
	ret
	