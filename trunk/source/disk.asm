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
	je nextfilename
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
	mov ecx, 0
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
	
segments dw 100

diskr:		;;sector count in cl, disk number in ch, 48 bit address with first 32 bits in ebx, buffer in esi, puts end buffer in edi and end lba in edx

	mov [bufferstartesi], esi
	mov [lbaadstartebx], ebx
	mov edx, 0
	mov dl, cl
	add edx, ebx
	mov [lbaadend], edx
	mov ax, 0
	mov dx, 0x1F1
	out dx, al	;;2 null bytes
	out dx, al
	mov al, 0
	mov dx, 0x1F2
	out dx, al	;;16 bit sector count-last byte now 0
	mov al, cl
	out dx, al
	mov dx, 0x1F3
	mov eax, ebx
	ror eax, 24
	out dx, al	;;4th byte of address
	rol eax, 24
	out dx, al	;;1st byte of address
	mov dx, 0x1F4
	mov al, 0
	out dx, al	;;5th byte of address-always 0 for now
	ror eax, 8
	out dx, al	;;2nd byte of address
	mov dx, 0x1F5
	rol eax, 8
	mov al, 0
	out dx, al	;;6th byte
	ror eax, 16
	out dx, al	;;3rd byte
	mov eax, 0x40
	mov dx, 0x1F6
	out dx, al	;;send magic bits-add drive indicator later
	mov al, 0x24
	mov dx, 0x1F7
	out dx, al	;;READ!!!
diskrwait:
	mov dx, 0x1F7
	in al, dx
	and al, 0x08
	cmp al, 0x08
	jne diskrwait
	mov ch, cl	;;move sector data into ch, multiplying it by 256
	mov cl, 0
diskdataread:
	mov dx, 0x1F0
	in ax, dx
	mov [esi], ax
	add esi, 2
	dec cx
	cmp cx, 0
	jne diskdataread		;;read all sectors
	mov edi, esi
	mov edx, [lbaadend]
	mov esi, [bufferstartesi]
	mov ebx, [lbaadstartebx]
	ret
	
	
diskold: ;;28 bits
	mov ax, 0
	mov dx, 0x1F1
	out dx, al	;;send null byte to port
	inc dx	;;0x1F2
	mov al, cl	;;get sector count
	out dx, al	;;send sector count
	inc dx	;;0x1F3
	mov al, bl	;;get first 8 bits of address
	out dx, al	;;send them
	inc dx	;;0x1F4
	ror ebx, 8	;;get next 8 bits
	mov al, bl
	out dx, al
	inc dx	;;0x1F5
	ror ebx, 8	;;again
	mov al, bl
	out dx, al
	inc dx	;;0x1F6
	ror ebx, 8
	mov al, bl
	and al, 00001111b	;;last 4 bits of address
	or al, 0xE0			;;majic number
	shl ch, 4
	or al, ch
	out dx, al			;;send drive indicator, magic bits, and highest 4 bits of address
	inc dx	;;0x1F7
	mov al, 0x20
	out dx, al			;;execute read command
	
lbaadend dd 0
lbaadstartebx dd 0
bufferstartesi dd 0