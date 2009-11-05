call rdprint
jmp timerinterrupt

readline:
  mov al, 10
  mov bl, 7
	rdprint:	;;print and get line, al=last key, bl=modifier, esi=buffer, edi=bufferend
		mov [buftxtloc], esi
		mov [endkeyrdpr], al
		mov [modkeyrdpr], bl
		mov [firstesirdpr], esi
		mov [endbufferrdpr], edi
	rdprintb:
		push esi
		mov al, 1
		call rdcharint
		pop esi
		cmp ah, 0x48
		je near rdprup
		cmp ah, 0x50
		je near rdprdown
		cmp ah, 0x4D
		je near rdprright
		cmp ah, 0x4B
		je near rdprleft
		cmp al, 8
		je near rdprbscheck
		cmp al, 0
		je rdprintb
		cmp ah, 0
		je rdprintb
		mov [esi], al
		inc esi
	bscheckequal:
		mov bl, [modkeyrdpr]
		mov bh, [txtmask]
		cmp bh, 0
		je nomasktxt
		mov al, bh
		xor bh, bh
	nomasktxt:
		call prcharint
		push esi
		mov [axcache], ax
		mov ah, [endkeyrdpr]
		cmp al, ah
		je nobackprintbuftxt2
		mov esi, buftxt2
		call printquiet
		mov al, " "
		call prcharq
		mov al, 8
		cmp esi, buftxt2
		je nobackprintbuftxt2
	backprintbuftxt2:
		call prcharq
		dec esi
		cmp esi, buftxt2
		ja backprintbuftxt2
	nobackprintbuftxt2:
		cmp al, 10
		je nonobackprint
		call prcharint
	nonobackprint:
		pop esi
		cmp esi, [endbufferrdpr]
		jae near donerdprinc
		mov ax, [axcache]
		mov ah, [endkeyrdpr]
		cmp al, ah
		jne rdprintb
		jmp donerdprint
	donerdprinc:
		inc esi
	donerdprint:
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
		mov edi, [firstesirdpr]
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
	
	rdprintb2:
		call termcopy
		jmp rdprintb
		
	rdprleft:
		cmp esi, [buftxtloc]
		je near rdprintb
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
		call prcharint
		jmp rdprintb
		
	rdprright:
		mov edi, buftxt2
		mov al, [edi]
		cmp al, 0
		je near rdprintb
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
		mov bl, [modkeyrdpr]
		call prcharint
		jmp rdprintb
		
	rdprdownbck:
		dec ah
		mov [commandedit], ah
		call rdprbckspc
		jmp rdprintb
	
	rdprdown:
		mov ah, [commandedit]
		cmp ah, 1
		jbe near rdprintb
		cmp ah, 2
		je rdprdownbck
		sub ah, 2
		mov [commandedit], ah
		
	rdprup:
		xor al, al
		cmp [commandedit], al
		je near rdprintb
		call rdprbckspc
		jmp getcurrentcommandstr
	rdprbckspc:
		cmp esi, [buftxtloc]
		je nordprupbck
	rdprupbckspclp:
		mov al, 8
		mov bl, [modkeyrdpr]
		call prcharq
		mov al, " "
		call prcharq
		mov al, 8
		call prcharq
		dec esi
		cmp esi, [buftxtloc]
		je nordprupbck2
		jmp rdprupbckspclp
	nordprupbck2:
		call termcopy
	nordprupbck:
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
		je near rdprintb
		add edi, commandbuf
		cmp al, 0
		jne getccmdlp
		dec ah
		cmp ah, 0
		ja getccmdlp
		inc edi
		cmp edi, commandbufend
		ja fixcmdbufb4morerdpr
		jmp morerdprup
	getcmdresetcommandbuf:
		mov edi, commandbufend
		inc edi
		jmp getccmdlp
	fixcmdbufb4morerdpr:
		dec edi
		sub edi, commandbufend
		add edi, commandbuf
	morerdprup:
		mov al, [edi]
		inc edi
		sub edi, commandbuf
		cmp al, 0
		je near rdprintb2
		cmp edi, [currentcommandpos]
		jae near rdprintb2
		add edi, commandbuf
		mov [esi], al
		inc esi
		push edi
		mov bl, [modkeyrdpr]
		call prcharq
		pop edi
		cmp edi, commandbufend
		jbe morerdprup
		mov edi, commandbuf
		jmp morerdprup
	rdprbscheck:
		cmp esi, [firstesirdpr]
		ja goodbscheck
		jmp rdprintb
	goodbscheck:
		dec esi
		mov byte [esi], 0
		mov bl, [modkeyrdpr]
		mov al, 8
		jmp bscheckequal
		
axcache dw 0
endkeyrdpr db 0
modkeyrdpr db 0
firstesirdpr dd 0
commandedit db 0
txtmask db 0
buftxtloc dd 0
endbufferrdpr dd 0
backcursor db 8," ",0
