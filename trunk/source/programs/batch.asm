db 255,44,"batch",0
	batchst: 
		mov edi, [currentcommandloc]
		add edi, 6
		cmp byte [edi], 0
		je near nonamefound
		mov esi, 0x400000
		call loadfile
		mov eax, edx
		cmp eax, 404
		je goodbatchname
		mov esi, badbatchname
		call print
		jmp nwcmd
		badbatchname db "This file already exists!",10,0
		namenotfoundbatch db "You have to type a name after the command.",10,0
		esicache3 dd 0
		esicache2 dd 0
	nonamefound:
		mov esi, namenotfoundbatch
		call print
		jmp nwcmd
	goodbatchname:
		mov esi, 0x400000
	batchcreate:
		mov [esicache3], esi
		mov edi, 0x800000
		mov al, 10
		mov bl, 7
		mov ah, 4
		int 30h
		mov [esicache2], esi
		mov cl, [esi]
		mov esi, [esicache3]
		mov ebx, exitword
		call cndtest
		cmp al, 1
		je endbatchcreate
		cmp al, 2
		je endbatchcreate
		mov esi, line
		call print
		mov esi, [esicache2]
		mov al, 10
		mov [esi], al
		inc esi
		jmp batchcreate
	endbatchcreate:
		mov esi, [esicache3]
		xor eax, eax
		mov [esi], al
		mov esi, line
		call print
		mov esi, 0x400000
		call print
		jmp nwcmd
	
	exitword db "\x",0
	wordmsg db "Type \x to exit.",10,0