%include "include.asm"
	;this program will at least try to load files from unfs-eventually it will be rolled into the os
	mov eax, [edi]
	cmp eax, "list"
	je near listfiles
	mov eax, [edi]
	cmp eax, "load"
	je near loadfiles
	jmp exit	;there are no other commands yet

loadfiles:
		jmp exit

listfiles:
	mov esi, versionsize
	mov eax, [esi]
	mov ebx, [esi + 4]
	mov esi, filesystem
	mov ecx, [esi]
	mov edx, [esi + 4]
	cmp eax, ecx
	je noerr1
	int 3
noerr1:
	cmp ebx, edx
	je noerr2
	int 3
noerr2:
	add esi, 8
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
	mov edi, ebx
	mov ebx, [nodecollectionnode]
	add ebx, ecx
	mov eax, [ebx + 6]
	shl eax, 9
	add eax, ecx
	mov [nodeloc], eax
listfilesloop:
mov [edibuf], edi
mov ebx, [esi]
mov [ebxbuf], ebx
	add esi, 4
	call print
	
mov [esibuf], esi

	mov ebx, [ebxbuf]
	add ebx, [nodeloc]
	add ebx, 4
	mov al, [ebx]
	cmp al, 1
	je fileprint
	mov al, "/"
	mov ah, 6
	mov bx, 7
	int 30h
fileprint:

	mov esi, line
	call print
	mov esi, [esibuf]
	mov edi, [edibuf]
	inc esi
	cmp byte [esi], 0
	je near exit
	cmp esi, edi
	jb near listfilesloop
	jmp exit

line db 10,13,0
nodeloc dd 0
ebxbuf dd 0
edibuf dd 0
esibuf dd 0
;expected settings
versionsize 	db 2
version 	dw 1
fsblockpoint 	db 6
fsmempoint	db 4
fsuidsize	db 2
fsblocksize	db 9
fschartype	db 0
nodecollectionnode  dd 0
indexcollectionnode dd 0

align 512,db 0
filesystem:
incbin "unfs"
