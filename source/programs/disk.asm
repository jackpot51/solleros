db 255,44,"disk",0
		mov esi, diskmsg
		call printquiet
		xor ecx, ecx
		mov cl, [DriveNumber]
		mov byte [firsthexshown], 5
		call showhexsmall
		mov esi, line
		call printquiet
		mov esi, diskfileindex
	diskindexdir:
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
		jmp nwcmd
		
		diskmsg db "Disk ",0
		disktab db 13,9,9,9,0