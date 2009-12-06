db 255,44,"cpuid",0
	xor eax, eax
	cpuid
	mov [cpuidbuf], ebx
	mov [cpuidbuf + 4], edx
	mov [cpuidbuf + 8], ecx
	mov esi, cpuidbuf
	call print
	mov esi, line
	call print
	mov eax, 1
	cpuid
	mov ecx, eax
	mov byte [firsthexshown], 2
	call showhex
	mov eax, 0x80000008
	cpuid
	mov ecx, eax
	mov byte [firsthexshown], 2
	call showhex
	ret
	
cpuidbuf times 13 db 0
cpuidvendorend: