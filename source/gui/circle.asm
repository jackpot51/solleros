drawcircle:	;center in (dx,cx), color in si, radius in ax
	cmp ax, 0
	ja .nozerocircle
	call putpixel	;the easiest circle ever
	jmp .done
.nozerocircle
	push ebp
	mov bp, si
	push ax
	call getpixelmem
	xor eax, eax
	pop ax
	mov esi, 1
	sub esi, eax
	mov ecx, eax
	xor eax, eax
	mov ax, [resolutionx2]
	mul ecx
	push eax
	xor edx, edx
	add edi, eax
	mov [edi], bp
	sub edi, eax
	sub edi, eax
	mov [edi], bp
	add edi, eax
	shl ecx, 1
	add edi, ecx
	mov [edi], bp
	shl ecx, 1
	sub edi, ecx
	mov [edi], bp
	shr ecx, 1
	add edi, ecx
	shr ecx, 1
	mov eax, 2
	mul ecx
	dec eax
	not eax ;make it negative
	mov [.ddF_y], eax
	pop eax
	mov ebx, 1
	mov [.ddF_x], ebx
	dec ebx
	xor edx, edx
.lp:	;it starts this with the center in edi
		;color in bp
		;ddF_x in memor
		;x*resolutionx2 in ebx
		;x in edx
		;ddF_y in memory
		;y*resolutionx2 in eax
		;f in esi
		;y in ecx
	cmp esi, 0x80000000 ;this means it is not negative
	ja	.noddF_y
	dec ecx
	sub eax, [resolutionx2]
	add dword [.ddF_y], 2
	add esi, [.ddF_y]
.noddF_y:
	inc edx
	add ebx, [resolutionx2]
	add dword [.ddF_x], 2
	add esi, [.ddF_x]

	shl edx, 1
	shl ecx, 1
	add edi, edx
	add edi, eax
	mov [edi], bp
	shl edx, 1
	sub edi, edx
	mov [edi], bp
	add edi, edx
	shl eax, 1
	sub edi, eax
	mov [edi], bp
	sub edi, edx
	mov [edi], bp
	shr edx, 1
	shr eax, 1
	add edi, eax
	add edi, edx
	
	add edi, ebx
	add edi, ecx
	mov [edi], bp
	shl ecx, 1
	sub edi, ecx
	mov [edi], bp
	shl ebx, 1
	sub edi, ebx
	add edi, ecx
	mov [edi], bp
	sub edi, ecx
	mov [edi], bp
	shr ebx, 1
	shr ecx, 1
	add edi, ebx
	add edi, ecx
	shr edx, 1
	shr ecx, 1
	cmp edx, ecx
	jb .lp
	pop ebp
.done:
	ret
	
.ddF_x dd 0
.ddF_y dd 0