;This loads files using the methods in the loaded driver
%include "source/drivers/disk/realmode.asm"
loadfile:	;loads a file with the name buffer's location in edi into location in esi
			;returns with err code in edx and file end in edi
	cmp byte [edi], 0
	je near nofileload
	mov edx, edi
	mov ebx, diskfileindex
nextnamechar:
	mov al, [edi]
	cmp al, '&'
	je nullfile
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
	add ebx, 8		;next descriptor
	mov edi, edx
	cmp ebx, enddiskfileindex
	jb nextnamechar
nofileload:
	mov edx, 404	;indicate not found error
nullfile:
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
	mov eax, [ebx + 4] 	;put file size in eax
	mov ebx, [ebx]		;put file beginning in ebx
	add ebx, [lbaad]	;add offset to solleros
	xor ecx, ecx
	mov cl, al			;get excess number of sectors
	shl cl, 2
	shr cl, 2			;cut off at 64
	sub eax, ecx		;get rid of excess sectors
	mov ch, 0			;drive 0
	shr eax, 6			;get number of 64 sector tracks
loaddiskfile:			;tracks in eax, excess sectors in cl, drive in ch, buffer in esi, address in ebx
	mov [filetracks], eax
	mov edi, esi		;just in case cl is 0
	mov edx, ebx
	cmp cl, 0
	je copytracksforfile
	call diskrreal	;take care of excess sectors
copytracksforfile:
	mov eax, [filetracks]
	cmp eax, 0
	je donecopyfile
	dec eax
	mov [filetracks], eax
	mov ebx, edx	;get end lba
	mov cl, 0x40 ;for compatability with BIOS it uses 64 instead of 128
	mov ch, [DriveNumber]
	mov esi, edi	;reset buffer
	call diskrreal
	jmp copytracksforfile
donecopyfile:
	mov edx, 0	;no error
	ret

oldesireal dd 0
filetracks dd 0
lbad1 db 0
lbad2 db 0
lbad3 db 0
lbad4 db 0
lbad5 db 0
lbad6 db 0
segments dw 100


	