db 255,44,"time",0	
timer:
	mov esi, [currentcommandloc]
	add esi, 4
	cmp byte [esi], 0
	je .norun
	inc esi
	mov ecx, [timeseconds]
	push ecx
	mov ecx, [timenanoseconds]
	push ecx
	mov edi, buftxt
.cpcmd:
	mov al, [esi]
	mov [edi], al
	inc esi
	inc edi
	cmp al, 0
	jne .cpcmd
	call run
	pop edx
	pop eax

	mov ecx, [timeseconds]
	sub ecx, eax
	mov ebx, [timenanoseconds]
	sub ebx, edx
	jae .nosign
	add ebx, 1000000000
	dec ecx
.nosign:
	call showdec
	
	mov ecx, ebx
	mov esi, timenscache
	mov dword [esi+ 2], "0000"
	mov dword [esi + 6], "0000"
	mov byte [esi + 10], "0"
	mov esi, timenscacheend
	call convert
	mov esi, timenscache
	call print
	mov byte [timenscache], 8
.norun:
	ret
	
