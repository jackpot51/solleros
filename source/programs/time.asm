timenscache db 8,".000000000"
timenscacheend: db " ",10,0
istimeset db 0
settimemsg db "Enter the current UNIX time:",10,0
timeinputbuffer times 12 db 0
timeinputbend: db 0

db 255,44,"time",0
	cmp byte [istimeset], 0
	jne timeisset
	mov esi, settimemsg
	call print
	mov esi, timeinputbuffer
	mov edi, timeinputbend
	call readline
	mov esi, timeinputbuffer
	xor edi, edi
	call cnvrttxt
	mov [timeseconds], ecx
	xor ecx, ecx
	mov [timenanoseconds], ecx
	mov byte [istimeset], 1
timeisset:
	mov ecx, [timeseconds]
	call showdec
	
	mov ecx, [timenanoseconds]
	mov esi, timenscache
	mov dword [esi+ 2], "0000"
	mov dword [esi + 6], "0000"
	mov byte [esi + 10], "0"
	mov esi, timenscacheend
	call convert
	mov esi, timenscache
	call print
	
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
	call print
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
	call print
	ret
	
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
	timeshow db "00:00:00",10
	dateshow db "00-00-0000",10,0
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
	db "Sunday",10,0
monday:
	db "Monday",10,0
tuesday:
	db "Tuesday",10,0
wednesday:
	db "Wednesday",10,0
thursday:
	db "Thursday",10,0
friday:
	db "Friday",10,0
saturday:
	db "Saturday",10,0
