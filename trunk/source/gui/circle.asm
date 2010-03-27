drawcircle:	;center in (dx,cx), color in si, radius in ax
	push ebp
	cmp ax, 0
	ja .nozerocircle
	call putpixel	;the easiest circle ever
	jmp .done
.nozerocircle:
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
	jmp .lp
.lpb:
	shr edx, 1
	shr ecx, 1
.lp:	;it starts this with the center in edi
		;color in bp
		;ddF_x in memory
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
	mov [edi], bp	;(cx+x,cy+y)
	shl edx, 1
	sub edi, edx
	mov [edi], bp	;(cx-x,cy+y)
	shl eax, 1
	sub edi, eax
	mov [edi], bp	;(cx-x,cy-y)
	add edi, edx
	mov [edi], bp	;(cx+x,cy-y)
	shr eax, 1
	shr edx, 1
	add edi, eax
	sub edi, edx

	cmp ecx, edx
	je .lpb

	add edi, ebx
	add edi, ecx
	mov [edi], bp	;(cx+y,cy+x)
	shl ecx, 1
	sub edi, ecx
	mov [edi], bp	;(cx-y,cy+x)
	shl ebx, 1
	sub edi, ebx
	mov [edi], bp	;(cx-y,cy-x)
	add edi, ecx
	mov [edi], bp	;(cx+y,cy-x)
	shr ebx, 1
	shr ecx, 1
	add edi, ebx
	sub edi, ecx
	cmp edx, ecx
	jb .lpb
.done:
	pop ebp
	ret
	
.ddF_x dd 0
.ddF_y dd 0

fillcircle:	;center in (dx,cx), color in si, radius in ax
	push ebp
	cmp ax, 0
	ja .nozerocircle
	call putpixel	;the easiest circle ever
	jmp .done
.nozerocircle:
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
	push ecx
.s0:
	mov [edi], bp
	sub edi, 2
	dec ecx
	cmp ecx, 0
	jne .s0
	mov [edi], bp
	pop ecx
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
	jmp .lp
.lpb:
	shr edx, 1
	shr ecx, 1
.lp:	;it starts this with the center in edi
		;color in bp
		;ddF_x in memory
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
	push edx
	sub edi, edx
	add edi, eax
	cmp edx, 0
	je .nos1
.s1:
	mov [edi], bp	;(cx-x,cy+y)
	add edi, 2
	dec edx
	cmp edx, 0
	jne .s1
.nos1:
	mov [edi], bp
	pop edx
	push edx
	sub edi, eax
	sub edi, eax
	cmp edx, 0
	je .nos2
.s2:
	mov [edi], bp	;(cx+x,cy-y)
	sub edi, 2
	dec edx
	cmp edx, 0
	jne .s2
.nos2:
	mov [edi], bp
	pop edx
	add edi, eax	;(cx-x,cy-y)
	add edi, edx

	cmp ecx, edx
	je .lpb

	push ecx
	add edi, ebx
	sub edi, ecx
	cmp ecx, 0
	je .nos3
.s3:
	mov [edi], bp	;(cx-y,cy+x)
	add edi, 2
	dec ecx
	cmp ecx, 0
	jne .s3
.nos3:
	mov [edi], bp
	pop ecx
	push ecx
	sub edi, ebx
	sub edi, ebx
	cmp ecx, 0
	je .nos4
.s4:
	mov [edi], bp	;(cx+y,cy-x)
	sub edi, 2
	dec ecx
	cmp ecx, 0
	jne .s4
.nos4:
	mov [edi], bp
	pop ecx
	add edi, ebx	;(cx-y,cy-x)
	add edi, ecx

	shr edx, 1
	shr ecx, 1
	cmp edx, ecx
	jb .lp
.done:
	pop ebp
	ret
	
.ddF_x dd 0
.ddF_y dd 0
