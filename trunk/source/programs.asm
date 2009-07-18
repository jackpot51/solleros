;db 5,4,"internet",0
	internettest: 			;;initialize network card, lets hope this is right
							;;^^used to^^, now tests int 30h functions		
		mov ah, 3
		int 30h
		mov ah, 1
		;mov esi, datmsg
		mov bx, 7
		xor al, al
		int 30h
	    ;jmp packettest
		jmp nwcmd
;datmsg: db "Internet has not been implemented yet.",10,13,0
	
db 5,4,"threads",0
	jmp threadstarttest
	
db 5,4,"reg",0
	int 3
	jmp nwcmd
	
db 5,4,"charmap",0
	xor al, al
	mov bx, 7
charmapcopy:
	inc al
	cmp al, 8
	je charmapnocopy
	cmp al, 9
	je charmapnocopy
	cmp al, 10
	je charmapnocopy
	cmp al, 13
	je charmapnocopy
	cmp al, 0
	je nomorecharmap
	call int301prnt
	jmp charmapcopy
nomorecharmap:
	mov esi, line
	call print
	jmp nwcmd
charmapnocopy:
	push ax
	mov al, " "
	call int301prnt
	pop ax
	jmp charmapcopy
	
db 5,4,"keycode",0
keycode:
	mov byte [trans], 0
	call guistartin
	xor eax, eax
	xor ecx, ecx
	mov cl, [specialkey]
	cmp cl, 0
	je near nospecialkeycode
	call showhexsmall
nospecialkeycode:
	mov ax, [lastkey]
	mov cl, ah
	call showhexsmall
	jmp keycode

db 5,4,"pci",0
	pcishow:
	call pcidump
	jmp nwcmd
	
db 5,4,"arp",0
	call arptest
	jmp nwcmd

db 5,4,"batch",0
	batchst: 
		mov edi, buftxt
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
		badbatchname db "This file already exists!",10,13,0
		namenotfoundbatch db "You have to type a name after the command.",10,13,0
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
		xor eax, eax
		mov [esi], al
		mov esi, line
		call print
		mov esi, 0x400000
		call print
		jmp nwcmd
	
	exitword db "\x",0
	wordmsg db "Type \x to exit.",10,13,0
		
db 5,4,"show",0
		mov edi, buftxt
		add edi, 5
		mov esi, 0x400000
		call loadfile
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
	xor ecx, ecx
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
	jmp findday
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
;	mov ah, 0			;;fix day
;	mov ah, al
;	shr ah, 4
;	shl al, 4
;	shr al, 4
;	cmp al, 0
;	jne nodecahday
;	mov al, 10
;	dec ah
;nodecahday:
;	dec al
;	shl ah, 4
;	or al, ah
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
	mov esi, timeshow
	mov bx, 7
	mov ah, 1
	xor al, al
	int 30h
;;get day of week
;;add these:
;;century value
;;last 2 digits of year
;;last 2 digits of year right shifted twice
;;month table value
;;day of the month
;;divide these by 7
;;the remainder is the day
findday:
	xor eax, eax
;;first convert the values from BCD to hex
	mov al, [RTCtimeDay]
	call converttohex
	mov [dayhex], ah
	mov al, [RTCtimeMonth]
	call converttohex
	mov [monthhex], ah
	mov al, [RTCtimeYear]
	call converttohex
	mov [yearhex], ah
	xor eax, eax
	mov al, [yearhex]
	shr al, 2
	add al, [yearhex]
	add eax, 6
	xor ebx, ebx
	mov bl, [monthhex]
	dec bl
	add ebx, month
	xor ecx, ecx
	mov cl, [ebx]
	add eax, ecx
	mov cl, [dayhex]
	add eax, ecx
	mov bx, 7
	xor edx, edx
	div bx
	shl edx, 2
	add edx, day
	mov esi, [edx]
	mov bx, 7
	mov ah, 1
	xor al, al
	int 30h
	xor ax, ax
	int 30h
	hlt
	
converttohex:
	mov ah, al
	shr al, 4
	shl ah, 4
	shr ah, 4
	cmp al, 0
	je noconverttohex
converttohexlp:
	add ah, 10
	dec al
	cmp al, 0
	jne converttohexlp
noconverttohex:
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
	dayhex db 0
	monthhex db 0
	yearhex db 0
	timeshow db "00:00:00",13,10
	dateshow db "00-00-0000",13,10,0
	oldcentury:	;;from 1700 to 1900
	db 4,2,0
	century:	;;from 2000 to 2500
	db 6,4,2,0,6,4
	month:
	db 0,3,3,6,1,4,6,2,5,0,3,5
	day:
	dd sunday
	dd monday
	dd tuesday
	dd wednesday
	dd thursday
	dd friday
	dd saturday
sunday:
	db "Sunday",13,10,0
monday:
	db "Monday",13,10,0
tuesday:
	db "Tuesday",13,10,0
wednesday:
	db "Wednesday",13,10,0
thursday:
	db "Thursday",13,10,0
friday:
	db "Friday",13,10,0
saturday:
	db "Saturday",13,10,0

db 5,4,"cpuid",0
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
	jmp nwcmd
	
cpuidbuf times 13 db 0
cpuidvendorend:
	
progend:		;programs end here	
batchprogend:
