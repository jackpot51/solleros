clearmousecursor:
		mov esi, background
		mov edi, [physbaseptr]
		xor edx, edx
		xor ecx, ecx
		mov dx, [lastmouseposition]
		mov cx, [lastmouseposition + 2]
		add edi, edx
		xor edx, edx
		mov dx, [resolutionx2]
		cmp ecx, 0
		je .nomul
		push edx
		mov eax, edx
		mul ecx
		add edi, eax
		pop edx
.nomul:
%ifdef 	gui.background
		cmp dword [backgroundimage], 0
		je .noyclr
		mov esi, [backgroundimage]
		sub edi, [physbaseptr]
		add esi, edi
		add edi, [physbaseptr]
.backlp:
		xor ebx, ebx
.noyback:
		mov eax, [esi + ebx]
		mov [edi + ebx], eax
		add ebx, 4
		cmp ebx, 16
		jne .noyback
		add edi, edx
		add esi, edx
		inc cx
		cmp cx, 16
		jb .backlp
		ret
%endif
.noyclr:
		mov ax, [esi]
		rol eax, 16
		mov ax, [esi]
		mov [edi], eax
		mov [edi + 4], eax
		mov [edi + 8], eax
		mov [edi + 12], eax
		add edi, edx
		inc cx
		cmp cx, 16
		jb .noyclr
		ret

switchmousepos:		;;switch were the mouse is located
		mov esi, mousecolorbuf
		mov edi, [physbaseptr]
		xor edx, edx
		xor ecx, ecx
		mov dx, [lastmouseposition]
		mov cx, [lastmouseposition + 2]
		add edi, edx
		xor edx, edx
		mov dx, [resolutionx2]
		cmp cx, 0
		je noswmsy
swmsy:		add edi, edx
		dec cx
		cmp cx, 0
		jne swmsy
noswmsy:	mov eax, [esi]
		mov ebx, [esi + 4]
		mov [edi], eax
		mov [edi + 4], ebx
		mov eax, [esi + 8]
		mov ebx, [esi + 12]
		mov [edi + 8], eax
		mov [edi + 12], ebx
		add edi, edx
		add esi, 16
		cmp esi, mcolorend
		jb noswmsy
		
switchmousepos2:
		mov esi, mousecolorbuf
		mov edi, [physbaseptr]
		xor edx, edx
		xor ecx, ecx
		mov dx, [mousecursorposition]
		mov cx, [mousecursorposition + 2]
		add edi, edx
		xor edx, edx
		mov dx, [resolutionx2]
		cmp cx, 0
		je noswmsy2
swmsy2:		add edi, edx
		dec cx
		cmp cx, 0
		jne swmsy2
noswmsy2:	mov eax, [edi]
		mov ebx, [edi + 4]
		mov [esi], eax
		mov [esi + 4], ebx
		mov eax, [edi + 8]
		mov ebx, [edi + 12]
		mov [esi + 8], eax
		mov [esi + 12], ebx
		add edi, edx
		add esi, 16
		cmp esi, mcolorend
		jb noswmsy2
		ret
		