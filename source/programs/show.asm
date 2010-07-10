db 255,44,"show",0
showprog:
		mov edi, [currentcommandloc]
		add edi, 5
		mov esi, 0x400000
		cmp byte [edi], '&'
		je .nullfile
		mov esi, 0x800000
		call loadfile
		cmp edx, 404
		je near filenotfound
		mov esi, 0x800000
.nullfile:
%ifdef gui.included
		cmp word [esi], "BM"
		je bmpfound
%endif
		call print
		call printline
		ret
%ifdef gui.included
bmpfound:
		cmp byte [guion], 0
		je near noguibmp
		mov esi, 0x800000
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
		ret
noguibmp:
		mov esi, warnguimsg
		call print
		ret
warnguimsg db "This can not be done without the GUI.",10,0
%endif

filenotfound:
		mov esi, filenf
		call print
		mov esi, [currentcommandloc]
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
nofilenamenotfound:
		mov esi, filenf2
		call print
		ret
filenf db "The file ",34,0
filenf2 db 34," could not be found.",10,0
