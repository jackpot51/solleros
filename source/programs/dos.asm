db 255,44,"dos",0
rundosprog:
	mov edi, buftxt
	add edi, 4
	mov esi,  0x100 + dosprogloc	;this should be the beginning of memory
	call loadfile
	mov edi, buftxt
	add edi, 4
	cmp edx, 404
	je near dosnoprogfound
	mov ebx, 0x81 + dosprogloc
	xor ecx, ecx
finddosparams:
	inc edi
	mov al, [edi]
	cmp al, " "
	jne finddosparams
copydosparams:
	mov al, [edi]
	mov [ebx], al
	inc ebx
	inc edi
	inc ecx
	cmp ebx, 0x100 + dosprogloc
	jae nomoredosparams
	cmp al, 0
	jne copydosparams
nomoredosparams:
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
	jmp DOS_CODE_SEL:0x100
dosnoprogfound:
	mov esi, notfound1
	call print
	mov esi, buftxt
	add esi, 4
	call print
	mov esi, notfound2
	call print
	jmp nwcmd