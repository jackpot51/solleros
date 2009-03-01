	[BITS 32]
	[ORG 0x100000]
	db "EX"
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
	mov esi, timeshow
	mov bx, 7
	mov ah, 1
	mov al, 0
	int 30h
	mov eax, 0
	mov al, [RTCtimeYear]
	shr al, 2
	add eax, 6
	mov ebx, 0
	mov bl, [RTCtimeMonth]
	add ebx, month
	mov ecx, 0
	mov cl, [ebx]
	add eax, ecx
	mov cl, [RTCtimeDay]
	add eax, ecx
	mov bx, 7
	mov edx, 0
	div bx
	shl edx, 2
	add edx, day
	mov esi, [edx]
	mov bx, 7
	mov ah, 1
	mov al, 0
	int 30h
	mov ax, 0
	int 30h
	
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
	db "Sunday",0
monday:
	db "Monday"
tuesday:
	db "Tuesday",0
wednesday:
	db "Wednesday",0
thursday:
	db "Thursday",0
friday:
	db "Friday",0
saturday:
	db "Saturday",0

