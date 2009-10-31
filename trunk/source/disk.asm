;;disk.asm - new - using lba
loadfile:	;;loads a file with the name buffer's location in edi into location in esi
	cmp byte [edi], 0
	je near nofileload
	mov edx, edi
	mov ebx, diskfileindex
nextnamechar:
	mov al, [edi]
	mov ah, [ebx]
	inc edi
	inc ebx
	mov cl, al
	or cl, ah
	cmp cl, 0
	je equalfilenames
	cmp cl, ' '
	je equalfilenames
	cmp al, '*'
	je equalfilenames2
	cmp ah, 0
	je nextfilename
	cmp al, 0
	je getebxzero
	cmp al, ah
	je nextnamechar
getebxzero:
	mov ah, [ebx]
	inc ebx
	cmp ah, 0
	jne getebxzero
nextfilename:
	add ebx, 8		;;next descriptor
	mov edi, edx
	cmp ebx, enddiskfileindex
	jb nextnamechar
nofileload:
	mov edx, 404	;;indicate not found error
	ret
equalfilenames2:
	sub ebx, 2
eqfilefind:
	inc ebx
	cmp ebx, enddiskfileindex
	jae near nofileload
	mov al, [ebx]
	cmp al, 0
	jne eqfilefind
	inc ebx
equalfilenames:
	mov eax, [ebx + 4] 	;;put file size in eax
	mov ebx, [ebx]		;;put file beginning in ebx
	add ebx, [lbaad]	;;add offset to solleros
	xor ecx, ecx
	mov cl, al			;;get excess number of sectors
	shl cl, 1
	shr cl, 1			;;cut off at 128
	sub eax, ecx		;;get rid of excess sectors
	mov ch, 0			;;drive 0
	shr eax, 7			;;get number of 128 sector tracks
loaddiskfile:		;;tracks in eax, excess sectors in cl, drive in ch, buffer in esi, address in ebx
	mov [filetracks], eax
	mov edi, esi		;;just in case cl is 0
	mov edx, ebx
	cmp cl, 0
	je copytracksforfile
	call diskr		;;take care of excess sectors
copytracksforfile:
	mov eax, [filetracks]
	cmp eax, 0
	je donecopyfile
	dec eax
	mov [filetracks], eax
	mov ebx, edx	;;get end lba
	mov cl, 0x80
	mov ch, [DriveNumber]
	mov esi, edi	;;reset buffer
	call diskr
	jmp copytracksforfile
donecopyfile:
	mov edx, 0	;;no error
	ret
	
filetracks dd 0
lbad1 db 0
lbad2 db 0
lbad3 db 0
lbad4 db 0
lbad5 db 0
lbad6 db 0
segments dw 100

diskr:		;read from disk
			;sector count in cl
			;disk number in ch
			;48 bit address with last 32 bits in ebx
			;buffer in esi
			;puts end of buffer in edi and end lba address in edx
	call diskaddresssetup
	mov al, 0x24
	mov dx, 0x1F7
	out dx, al	;;READ!!!
	mov bx, 0xFFF
diskrwait:
	dec bx
	cmp bx, 0xFFFF
	jne diskrwait	;wait more than 400ns-wait until it loops back to 0xFFFF
diskrwait2:
	mov dx, 0x1F7
	in al, dx
	mov ah, al
	and ah, 0x80
	and al, 8
	dec bx
	cmp bx, 0
	je nomorediskrwait
	cmp al, 0x08
	jne diskrwait2
	cmp ah, 0x80
	je diskrwait2
nomorediskrwait:
	mov bx, 256
diskdataread:
	mov dx, 0x1F0
	in ax, dx
	mov [esi], ax
	add esi, 2
	dec bx
	cmp bx, 0
	jne diskdataread		;;read a sector
	dec cl
	cmp cl, 0
	jne diskrwait
	mov edi, esi
	mov edx, [lbaadend]
	mov esi, [bufferstartesi]
	mov ebx, [lbaadstartebx]
	ret
	
lbaadend dd 0
lbaadstartebx dd 0
bufferstartesi dd 0

diskw:		;write disk
			;sector count in cl
			;disk number in ch
			;48 bit address with last 32 bits in ebx
			;buffer in esi
			;puts end of buffer in edi and end lba address in edx
	call diskaddresssetup
	mov al, 0x34
	mov dx, 0x1F7
	out dx, al	;;WRITE!!!
	mov bx, 0xFFF		;;try 65536 times before forcing
diskwwait:
	dec bx
	cmp bx, 0xFFFF
	jne diskwwait	;wait more than 400ns-wait until it loops back to 0xFFFF
diskwwait2:
	mov dx, 0x1F7
	in al, dx
	mov ah, al
	and ah, 0x80
	and al, 8
	dec bx
	cmp bx, 0
	je nomorediskwwait
	cmp al, 0x08
	jne diskwwait2
	cmp ah, 0x80
	je diskwwait2
nomorediskwwait:
	mov bx, 256
diskdatawrite:
	mov dx, 0x1F0
	mov ax, [esi]
	out dx, ax
	add esi, 2
	dec bx
	cmp bx, 0
	jne diskdatawrite		;;write a sector
	dec cl
	cmp cl, 0
	jne diskwwait
	mov edi, esi
	mov edx, [lbaadend]
	mov esi, [bufferstartesi]
	mov ebx, [lbaadstartebx]
	ret

diskaddresssetup:
	mov [bufferstartesi], esi
	mov [lbaadstartebx], ebx
	xor edx, edx
	mov dl, cl
	add edx, ebx
	mov [lbaadend], edx
	mov [lbad1], bl
	mov [lbad2], bh
	rol ebx, 16
	mov [lbad3], bl
	mov [lbad4], bh
	ror ebx, 16

	mov eax, 0x40
	mov dx, 0x1F6
	out dx, al	;;send magic bits-add drive indicator later
	
	xor al, al
	mov dx, 0x1F2
	out dx, al	;;16 bit sector count-last byte now 0
	
	mov al, [lbad4]
	inc dx
	out dx, al
	
	mov al, [lbad5]
	inc dx
	out dx, al
	
	mov al, [lbad6]
	inc dx
	out dx, al
	
	mov al, cl
	mov dx, 0x1F2
	out dx, al	;;low byte of 16 bit sector count
	
	mov al, [lbad1]
	inc dx
	out dx, al
	
	mov al, [lbad2]
	inc dx
	out dx, al
	
	mov al, [lbad3]
	inc dx
	out dx, al
	ret
	