db 255,44,"ls",0
		mov esi, diskfileindex
	diskindexdir:
		cmp byte [esi], '_'
		je nextdiskindexdir
		call printquiet
		push esi
		mov esi, disktab
		call printquiet
		pop esi
		mov ecx, [esi + 5]
		mov byte [firsthexshown], 5
		call showdec
		push esi
		mov esi, line
		call printquiet
		pop esi
		add esi, 9
		cmp esi, enddiskfileindex
		jb diskindexdir
		call termcopy
		ret
	nextdiskindexdir:
		inc esi
		cmp byte [esi], 0
		jne nextdiskindexdir
		add esi, 9
		cmp esi, enddiskfileindex
		jb diskindexdir
		call termcopy
		ret
		
		diskmsg db "Disk ",0
		disktab db 13,9,9,9,0