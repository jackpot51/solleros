sendpacket: ;packet start in edi, end in esi
	%ifdef rtl8139.included
		call rtl8139.sendpacket
	%endif
	%ifdef ne2000.included
		call ne2000.sendpacket
	%endif
	ret

getchecksum: ;start in edi, end in esi, checksum put in ecx
	xor eax, eax
	xor ebx, ebx
	xor ecx, ecx
.lp:
	mov al, [edi]
	mov ah, [edi + 1]
	add ebx, eax
	add edi, 2
	cmp edi, esi
	jb .lp
	mov cx, 0xFFFF
	mov ax, bx
	shr ebx, 16
	add ax, bx
	sub cx, ax
	ret
	
strtoip:	;string in esi with format X.X.X.X converted to number in ecx
	xor ebx, ebx
	xor ecx, ecx
	xor edx, edx
.mlp:
	mov edi, esi
	dec edi
.lp:
	inc edi
	mov al, [edi]
	cmp al, " "
	je .dnlp
	cmp al, 0
	je .dnlp
	cmp al, "."
	jne .lp
.dnlp:
	xor al, al
	mov [edi], al
	push ebx
	push esi
	push edi
	xor edi, edi
	call cnvrttxt
	pop esi
	pop edi ;i intentionally switch them
	pop ebx
	inc esi
	mov edi, ipstr
	mov [edi + ebx], cl
	inc ebx
	cmp ebx, 4
	jb .mlp
	mov ecx, [ipstr]
	ret
ipstr dd 0
showip: 	;put the ip address in ecx
	mov eax, ecx
	xor bl, bl
.lp
	cmp al, 0
	jne .nozeroprint
	mov al, "0"
	push eax
	call prcharq
	pop eax
	xor al, al
.nozeroprint:
	xor ecx, ecx
	mov cl, al
	call showdec
	shr eax, 8
	inc bl
	cmp bl, 4
	jae .done
	push eax
	push bx
	mov esi, .dot
	call print
	pop bx
	pop eax
	jmp .lp
.done:
	ret
.dot db 8,".",0
showmac:	;mac begins in [ecx]
	mov esi, macprint
	mov edi, ecx
	add ecx, 6
showmacloop:
	mov al, [edi]
	mov ah, [edi]
	shr al, 4
	shl ah, 4
	shr ah, 4
	add al, 48
	cmp al, "9"
	jbe .goodal
	sub al, 48
	sub al, 0xA
	add al, "A"
.goodal:
	add ah, 48
	cmp ah, "9"
	jbe .goodah
	sub ah, 48
	sub ah, 0xA
	add ah, "A"
.goodah:
	mov [esi], ax
	add esi, 3
	inc edi
	cmp edi, ecx
	jb showmacloop
	mov esi, macprint
	call print
	ret
	
macprint db "00:00:00:00:00:00 ",0
ethernetend dw 0,0
nicconfig db 0
basenicaddr	dd 0
sysip db 192,168,0,2
sysmac	db 0,0,0,0,0,0		;my mac address