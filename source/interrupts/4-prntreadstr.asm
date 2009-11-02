call int305
jmp timerinterrupt

readline:
  mov al, 10
  mov bl, 7
	int305:	;;print and get line, al=last key, bl=modifier, esi=buffer, edi=bufferend
		mov [buftxtloc], esi
		mov [endkey305], al
		mov [modkey305], bl
		mov [firstesi305], esi
		mov [endbuffer305], edi
	int305b:
		push esi
		mov al, 1
		call int302	;then get it
		pop esi
		cmp ah, 0x48
		je near int305up
		cmp ah, 0x50
		je near int305down
		cmp ah, 0x4D
		je near int305right
		cmp ah, 0x4B
		je near int305left
		cmp al, 8
		je near int305bscheck
		cmp al, 0
		je int305b
		cmp ah, 0
		je int305b
		mov [esi], al
		inc esi
	bscheckequal:
		mov bl, [modkey305]
		mov bh, [txtmask]
		cmp bh, 0
		je nomasktxt
		mov al, bh
	nomasktxt:
		call int301
		push esi
		mov [int305axcache], ax
		mov ah, [endkey305]
		cmp al, ah
		je nobackprintbuftxt2
		mov esi, buftxt2
		call printquiet
		mov al, " "
		call int301prnt
		mov al, 8
		cmp esi, buftxt2
		je nobackprintbuftxt2
	backprintbuftxt2:
		call int301prnt
		dec esi
		cmp esi, buftxt2
		ja backprintbuftxt2
	nobackprintbuftxt2:
		cmp al, 10
		je nonobackprint
		call int301
	nonobackprint:
		pop esi
		cmp esi, [endbuffer305]
		jae near doneint305inc
		mov ax, [int305axcache]
		mov ah, [endkey305]
		cmp al, ah
		jne int305b
		jmp doneint305
	doneint305inc:
		inc esi
	doneint305:
		dec esi
		mov edi, buftxt2
	copylaterstuff:
		mov al, [edi]
		cmp al, 0
		je nocopylaterstuff
		mov [esi], al
		inc edi
		inc esi
		jmp copylaterstuff
	nocopylaterstuff:
		mov byte [esi], 0
		call clearbuftxt2
		mov ecx, esi
		mov edi, [firstesi305]
		sub ecx, edi
		ret
	
	clearbuftxt2:
		xor al, al
		mov edi, buftxt2
	clearbuftxt2lp:
		mov [edi], al
		inc edi
		cmp edi, buftxt
		jne clearbuftxt2lp
		ret
	
	int305b2:
		call termcopy
		jmp int305b
	
	int305axcache dw 0
		
	int305left:
		cmp esi, [buftxtloc]
		je near int305b
		mov edi, buftxt2
		mov al, [edi]
	shiftbuftxt2:
		cmp al, 0
		je noshiftbuftxt2
		inc edi
		mov ah, [edi]
		mov [edi], al
		mov al, ah
		jmp shiftbuftxt2
	noshiftbuftxt2:
		mov edi, buftxt2
		dec esi
		mov al, [esi]
		mov [edi], al
		mov byte [esi], 0
		mov al, 8
		call int301
		jmp int305b
		
	int305right:
		mov edi, buftxt2
		mov al, [edi]
		cmp al, 0
		je near int305b
		mov [esi], al
	shiftbuftxt2lft:
		cmp al, 0
		je noshiftbuftxt2lft
		inc edi
		mov al, [edi]
		mov [edi - 1], al
		jmp shiftbuftxt2lft
	noshiftbuftxt2lft:
		mov al, [esi]
		inc esi
		mov bl, [modkey305]
		call int301
		jmp int305b
		
	int305downbck:
		dec ah
		mov [commandedit], ah
		call int305bckspc
		jmp int305b
	
	int305down:
		mov ah, [commandedit]
		cmp ah, 1
		jbe near int305b
		cmp ah, 2
		je int305downbck
		sub ah, 2
		mov [commandedit], ah
		
	int305up:
		xor al, al
		cmp [commandedit], al
		je near int305b
		call int305bckspc
		jmp getcurrentcommandstr
	int305bckspc:
		cmp esi, [buftxtloc]
		je noint305upbck
	int305upbckspclp:
		mov al, 8
		mov bl, [modkey305]
		call int301prnt
		mov al, " "
		call int301prnt
		mov al, 8
		call int301prnt
		dec esi
		cmp esi, [buftxtloc]
		je noint305upbck2
		jmp int305upbckspclp
	noint305upbck2:
		call termcopy
	noint305upbck:
		mov edi, [currentcommandpos]
		add edi, commandbuf
		dec edi
		ret
	getcurrentcommandstr:
		mov ah, [commandedit]
		inc byte [commandedit]
	getccmdlp:
		dec edi
		mov al, [edi]
		cmp edi, commandbuf
		jb getcmdresetcommandbuf
		sub edi, commandbuf
		cmp edi, [currentcommandpos]
		je near int305b
		add edi, commandbuf
		cmp al, 0
		jne getccmdlp
		dec ah
		cmp ah, 0
		ja getccmdlp
		inc edi
		cmp edi, commandbufend
		ja fixcmdbufb4moreint305
		jmp moreint305up
	getcmdresetcommandbuf:
		mov edi, commandbufend
		inc edi
		jmp getccmdlp
	fixcmdbufb4moreint305:
		dec edi
		sub edi, commandbufend
		add edi, commandbuf
	moreint305up:
		mov al, [edi]
		inc edi
		sub edi, commandbuf
		cmp al, 0
		je near int305b2
		cmp edi, [currentcommandpos]
		jae near int305b2
		add edi, commandbuf
		mov [esi], al
		inc esi
		push edi
		mov bl, [modkey305]
		call int301prnt
		pop edi
		cmp edi, commandbufend
		jbe moreint305up
		mov edi, commandbuf
		jmp moreint305up
	int305bscheck:
		cmp esi, [firstesi305]
		ja goodbscheck
		jmp int305b
	goodbscheck:
		dec esi
		mov byte [esi], 0
		mov bl, [modkey305]
		mov al, 8
		jmp bscheckequal
		
endkey305 db 0
modkey305 db 0
firstesi305 dd 0
commandedit db 0
txtmask db 0
buftxtloc dd 0
endbuffer305 dd 0
backcursor db 8," ",0
