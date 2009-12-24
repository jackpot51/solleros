db 255,44,"dos",0
dosrunner:
	mov [previousstack], esp
	mov edi, [currentcommandloc]
	add edi, 4
	mov esi,  0x100 + dosprogloc	;this should be the beginning of memory
	call loadfile
	mov edi, [currentcommandloc]
	add edi, 4
	cmp edx, 404
	je near .noprogfound
	mov ebx, 0x81 + dosprogloc
	xor ecx, ecx
.findparams:
	inc edi
	mov al, [edi]
	cmp al, " "
	jne .findparams
.copyparams:
	mov al, [edi]
	mov [ebx], al
	inc ebx
	inc edi
	inc ecx
	cmp ebx, 0x100 + dosprogloc
	jae .nomoreparams
	cmp al, 0
	jne .copyparams
.nomoreparams:
	mov [0x80 + dosprogloc], cl
	mov ax, DOS_DATA_SEL
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	xor eax, eax
	xor ebx, ebx
	xor ecx, ecx
	xor edx, edx
	xor edi, edi
	xor esi, esi
	call DOS_CODE_SEL:0x100
	mov bx, NEW_DATA_SEL
	mov dx, bx
	mov es, bx
	mov fs, bx
	mov bx, SYS_DATA_SEL
	mov gs, bx
	mov esp, [previousstack]
	ret
.noprogfound:
	mov esi, notfound1
	call print
	mov esi, [currentcommandloc]
	add esi, 4
	call print
	mov esi, notfound2
	call print
	ret
	
