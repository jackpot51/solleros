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
			;;o snap its unreal now!!!
			mov eax, cr0
			and al, 0xFE
			mov cr0, eax
			sti
diskr2:
			mov [readlen2 + 1], cl
			mov [lbaad2], ebx
			mov [bufferstartesi], esi
			mov [lbaadstartebx], ebx
			mov esi, 0
			mov eax, 0
			mov edx, 0
		ReadHardDisk:
			mov si, diskaddresspacket
			mov ax, 0
			mov ah, 0x42
			mov dl, ch
			int 0x13
			jc ReadHardDisk
			
			mov esi, [bufferstartesi]
			mov ebx, [lbaadstartebx]
			
			cli
			mov eax, cr0
			or al, 1
			mov cr0, eax
			jmp SYS_CODE_SEL:diskr3
diskr3:
			mov ax, LINEAR_SEL
			mov fs, ax	
			mov al, cl
			mov ecx, 0
			mov cl, al
			add ebx, ecx
			mov edx, ebx
			shl ecx, 9
			add esi, ecx
			mov edi, ecx
			sub esi, ecx
			shr ecx, 9
			mov ebx, 0x8000
			shl ebx, 4
		copydiskbufferloop:
			mov eax, [fs:ebx]
			mov [esi], eax
			add bx, 4
			add esi, 4
			cmp esi, edi
			jbe copydiskbufferloop
			ret
			
			
			
			
			
diskaddresspacket:
len2:	db 0x10 ;;size of packet
	db 0
readlen2:	dw 0x0	;;blocks to read
address2:	dw 0x0	;;address 0
segm2:	dw 0x8000	;;location of my disk buffer, must be one free segment
;;start with known value for hd
lbaad2:
	dd 0	;;lba address
	dd 0
			
			
lbaadstartebx dd 0
bufferstartesi dd 0