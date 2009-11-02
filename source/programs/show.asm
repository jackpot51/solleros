db 255,44,"show",0
		mov edi, buftxt
		add edi, 5
		mov esi, 0x400000
		call loadfile
		cmp edx, 404
		je near filenotfound
		mov esi, 0x400000
		cmp word [esi], "BM"
		je bmpfound
		call print
		mov esi, line
		call print
		jmp nwcmd
bmpfound:
		cmp byte [guion], 0
		je near noguibmp
		mov esi, 0x400000
		xor ecx, ecx
		xor edx, edx
		xor eax, eax
		xor ebx, ebx
		call showbmp
		xor al, al
		mov ah, 5
		int 30h
		call guiclear
		call clearmousecursor
		call reloadallgraphics
		mov esi, buftxt
		add esi, 5
		call print
		mov esi, loadedbmpmsg
		call print
		jmp nwcmd
noguibmp:
		mov esi, warnguibmp
		call print
		jmp nwcmd
warnguibmp db "This can not be done without the gui.",10,0

filenotfound:
		mov esi, filenf
		call print
		mov esi, buftxt
findfilenotfoundzero:
		mov al, [esi]
		inc esi
		cmp al, 0
		je nofilenamenotfound
		cmp esi, buftxtend
		jae nofilenamenotfound
		cmp al, " "
		jne findfilenotfoundzero
		call print
		mov esi, filenf2
		call print
nofilenamenotfound:
		jmp nwcmd
filenf db "The file ",34,0
filenf2 db 34," could not be found.",10,0
		
loadedbmpmsg db " loaded.",10,0