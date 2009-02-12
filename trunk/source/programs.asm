
;db 5,4,"internet",0
	internettest: 			;;initialize network card, lets hope this is right
							;;^^used to^^, now tests int 30h functions		
		mov ah, 3
		int 30h
		mov ah, 1
		mov esi, datmsg
		mov bx, 7
		mov al, 0
		int 30h
	;jmp packettest
		jmp nwcmd
datmsg: db "Internet has not been implemented yet.",10,13,0
		
db 5,4,"pci",0
	pcishow:
	call pcidump
	jmp nwcmd
;db 5,4,"runbat",0
;	runbatch2:
;		mov esi, line
;		call print
;		mov edi, buftxt
;		add edi, 7
;		mov esi, 0x100000
;		call loadfile


db 5,4,"batch",0
	batchst: 
		mov edi, buftxt
		add edi, 6
		cmp byte [edi], 0
		je near nonamefound
		mov esi, 0x100000
		call loadfile
		mov eax, edx
		cmp eax, 404
		je goodbatchname
		mov esi, badbatchname
		call print
		jmp nwcmd
		badbatchname db "This file already exists!",10,13,0
		namenotfoundbatch db "You have to type a name after the command.",10,13,0
		esicache3 dd 0
		esicache2 dd 0
	nonamefound:
		mov esi, namenotfoundbatch
		call print
		jmp nwcmd
	goodbatchname:
		mov esi, 0x100000
	batchcreate:
		mov [esicache3], esi
		mov al, 13
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
		mov al, 13
		mov ah, 10
		mov [esi], ax
		add esi, 2
		jmp batchcreate
	endbatchcreate:
		mov esi, [esicache3]
		mov eax, 0
		mov [esi], al
		mov esi, line
		call print
		mov esi, 0x100000
		call print
		jmp nwcmd
	
	exitword db "\x",0
	wordmsg db "Type \x to exit.",10,13,0
		
db 5,4,"show",0
		mov edi, buftxt
		add edi, 5
		mov esi, 0x100000
		call loadfile
		mov esi, 0x100000
		cmp word [esi], "BM"
		je bmpfound
		call print
		mov esi, line
		call print
		jmp nwcmd
bmpfound:
		cmp byte [guion], 0
		je near noguibmp
		mov esi, 0x100000
		mov ecx, 0
		mov edx, 0
		mov eax, 0
		mov ebx, 0
		call showbmp
		mov al, 0
		mov ah, 5
		int 30h
		mov esi, buftxt
		add esi, 8
		call print
		mov esi, loadedbmpmsg
		call print
		jmp nwcmd
noguibmp:
		mov esi, warnguibmp
		call print
		jmp nwcmd
warnguibmp db "This can not be done without the gui.",10,13,0

		
filenotfound:
		mov esi, filenf
		call print
		mov esi, buftxt
		add esi, 8
		call print
		mov esi, filenf2
		call print
		jmp nwcmd
filenf db "The file ",34,0
filenf2 db 34," could not be found.",13,10,0
		
loadedbmpmsg db " loaded.",13,10,0

	db 5,4,"dump",0
	mov esi, buftxt
	add esi, 5
	mov ecx, 0
	call cnvrttxt
	mov edi, ecx
	mov esi, edi
	add esi, 896
	mov byte [firsthexshown],0
dumphexloop:
	mov ecx, [edi]
	call showhex
	add edi, 4
	cmp edi, esi
	jb dumphexloop
	jmp nwcmd

db 5,4,"time",0
	call time
	mov esi, timeshow
	call print
	mov esi, line
	call print
	mov esi, dateshow
	call print
	jmp nwcmd
time:
	call tstackput1
	mov al,10			;Get RTC register A
	call tget1
	test al,0x80			;Is update in progress?
	jne time				; yes, wait

	mov al,0			;Get seconds (00 to 59)
	call tget1
	mov [RTCtimeSecond],al

	mov al,0x02			;Get minutes (00 to 59)
	call tget1
	mov [RTCtimeMinute],al

	mov al,0x04			;Get hours (see notes)
	call tget1
	mov [RTCtimeHour],al

	mov al,0x07			;Get day of month (01 to 31)
	call tget1
	mov [RTCtimeDay],al

	mov al,0x08			;Get month (01 to 12)
	call tget1
	mov [RTCtimeMonth],al

	mov al,0x09			;Get year (00 to 99)
	call tget1
	mov [RTCtimeYear],al
	
	mov esi, timeshow
	mov ch, [RTCtimeHour]
	call tput1
	mov ch, [RTCtimeMinute]
	call tput1
	mov ch, [RTCtimeSecond]
	call tput1
	mov esi, dateshow
	mov ch, [RTCtimeMonth]
	call tput1
	mov ch, [RTCtimeDay]
	call tput1
	mov ch, 0x20
	call tput1
	dec esi
	mov ch, [RTCtimeYear]
	call tput1
	call tstackget1
	ret
	
tstackput1:
	mov [tstack + 20], esi
	mov esi, tstack
	mov [esi], eax
	mov [esi + 4], ebx
	mov [esi + 8], ecx
	mov [esi + 12], edx
	mov [esi + 16], edi
	ret
	
tstackget1:
	mov esi, tstack
	mov eax, [esi]
	mov ebx, [esi + 4]
	mov ecx, [esi + 8]
	mov edx, [esi + 12]
	mov edi, [esi + 16]
	mov esi, [esi + 20]
	ret
	
tget1:
	mov dx, 0x70
	out dx, al
	inc dx
	in al, dx
	dec dx
	ret
	
tput1:
	shr cx, 4
	mov al, 48
	add al, ch
	mov [esi], al
	inc esi
	mov al, 48
	shr cl, 4
	add al, cl
	mov [esi], al
	add esi, 2
	ret
		
	tstack dd 0,0,0,0,0,0
	RTCtimeSecond db 0
	RTCtimeMinute db 0
	RTCtimeHour db 0
	RTCtimeDay db 0
	RTCtimeMonth db 0
	RTCtimeYear db 0
	timeshow db "00:00:00",0,0
	dateshow db "00-00-0000",13,10,0

db 5,4,"cpuid",0
	mov eax, 0
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
	jmp nwcmd
	
cpuidbuf times 13 db 0
cpuidvendorend:
progend:		;programs end here	
batchprogend:
