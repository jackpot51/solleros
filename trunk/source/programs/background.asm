db 255,44,"background",0
		mov edi, [currentcommandloc]
		add edi, 11
		mov esi, 0x800000
		call loadfile
		cmp edx, 404
		je near filenotfound
		mov esi, 0x800000
		cmp word [esi], "BM"
		je .bmpfound
		ret
.bmpfound:
		mov edi, [physbaseptr]
		push edi
		mov esi, backgroundbuffer
		mov [backgroundimage], esi
		mov [physbaseptr], esi
		xor eax, eax
.clearlp:
		mov [esi], eax
		add esi, 4
		cmp esi, backgroundbufferend
		jb .clearlp
		mov esi, 0x800000
		xor ecx, ecx
		xor edx, edx
		xor ebx, ebx
		call showbmp
		pop edi
		mov [physbaseptr], edi
		cmp byte [guion], 0
		je .noclear
		call guiclear
		call clearmousecursor
		call reloadallgraphics
.noclear:
		ret
