%include "include.inc"
	;this program will at least try to load files from an unfs image file
	;eventually it will be rolled into the os
	push edi
	call load_fs
	call check_fs
	pop edi
	mov eax, [edi]
	cmp eax, "list"
	je near listfiles
	cmp eax, "show"
	je near showfiles
	mov esi, infomsg
	call print
	xor ebx, ebx
	jmp exit	;there are no other commands yet
infomsg db "list-list included files",10,"show-display a file",10,0
systemlocation db "_img.bin",0

read_super:
	mov esi, filesystem
	add esi, 12
	mov eax, [esi]
	mov [nodecollectionnode], eax
	mov eax, [esi + 4]
	mov [indexcollectionnode], eax
	mov ecx, filesystem
	mov edi, eax
	add edi, ecx
	mov eax, [edi + 6]
	mov ebx, [edi + 12]
	shl eax, 9
	add eax, ecx
	shl ebx, 9
	add ebx, ecx
	mov esi, eax
	mov [indexloc], esi
	mov edi, ebx
	mov ebx, [nodecollectionnode]
	add ebx, ecx
	mov eax, [ebx + 6]
	shl eax, 9
	add eax, ecx
	mov [nodeloc], eax
	ret
	
check_fs:
	mov esi, typelength
	mov eax, [esi]
	mov ebx, [esi + 4]
	mov esi, filesystem
	mov ecx, [esi]
	mov edx, [esi + 4]
	cmp eax, ecx
	je .noerr1
	jmp .error
.noerr1:
	cmp ebx, edx
	je .noerr2
	jmp .error
.noerr2:
	ret
.error:
	mov esi, fsnogood
	call print
	xor ebx, ebx
	jmp exit
fsnogood: db "The filesystem signature was invalid.",10,0

load_fs:
	mov esi, filesystem
	mov edi, systemlocation
	mov ah, 7
	int 0x30
	mov eax, edx
	xor ebx, ebx
	cmp edx, 0
	jne near exit
	ret
		
filenamelocation dd 0
showfiles:
	add edi, 5
	mov [filenamelocation], edi
	call read_super
	testfilesloop:
			mov [edibuf], edi
			mov ebx, [esi]
			mov [ebxbuf], ebx
			add esi, 4
			mov ebx, [filenamelocation]
			mov cl, 0
			call tester
			dec esi
		fixtestloop:
			inc esi
			cmp byte [esi], 0
			jne fixtestloop
			mov [esibuf], esi
			cmp al, 0
			je testfilenofind
			mov ebx, [ebxbuf]
			add ebx, [nodeloc]
			add ebx, 4
			mov al, [ebx]
			cmp al, 0
			je testfilefolderfound
			add ebx, 5
			mov eax, [ebx]
			add eax, [nodeloc]
			add eax, 6
			mov esi, [eax]
			shl esi, 9
			add esi, filesystem
			call print
			mov esi, line
			call print
			xor ebx, ebx
			jmp exit
	testfilefolderfound:
			mov esi, foldermsg
			call print
			xor ebx, ebx
			jmp exit
	testfilenofind:
			mov esi, [esibuf]
			mov edi, [edibuf]
			inc esi
			cmp byte [esi], 0
			je near nonodefound
			cmp esi, edi
			jb near testfilesloop
	nonodefound:
			mov esi, nonodemsg
			call print
			jmp exit
	
listfiles: ;this should list the files by parsing folder inodes
	call read_super
listfilesloop:
	push edi
	call listnode
	push esi
	mov esi, line
	call print
	pop esi
	pop edi
	inc esi
	xor ebx, ebx
	cmp byte [esi], 0
	je near exit
	cmp esi, edi
	jb near listfilesloop
	jmp exit
listnode:	;esi is the index location
	mov ebx, [esi]
	add esi, 4
	add ebx, [nodeloc]
	add ebx, 4
	push ebx
	push esi
	add ebx, 9 ;jump to the parent node pointer
	mov ebx, [ebx]
	cmp ebx, 0
	je noparentnodelist
	add ebx, [nodeloc]
	mov esi, [ebx]
	add esi, [indexloc]
	call listnode
noparentnodelist:
	pop esi
	call print
	pop ebx
	push esi
	mov al, [ebx]
	cmp al, 1
	je fileprint
	mov al, "/"
	mov ah, 6
	mov bx, 7
	int 30h
fileprint:
	pop esi
	ret

nonodemsg db "The requested node could not be found.",10,0
foldermsg db "The requested node is a folder.",10,0
nodeloc dd 0
indexloc dd 0
ebxbuf dd 0
edibuf dd 0
esibuf dd 0
;expected settings
typelength db 4
filesystemtype db "UnFS"
version 	dw 1
fsblockpoint 	db 6
fsmempoint	db 4
fsuidsize	db 2
fsblocksize	db 9
fschartype	db 0
nodecollectionnode  dd 0
indexcollectionnode dd 0

align 512, db 0
filesystem:
