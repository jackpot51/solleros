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