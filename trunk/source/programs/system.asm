	db 255,44,"system",0
getcpuspeed:
	mov eax, 0xFE
	out 0x21, al ;mask off all but timer interrupt
	mov al, 0x20
	out 0x20, al
	xor eax, eax
	hlt
	mov byte [testingcpuspeed], 1
cpuspeedloop:	;wait until next timer interrupt, then inc eax until the next
	inc eax
	jmp cpuspeedloop
cpuspeedloopend:
	xor eax, eax
	out 0x21, al
	mov al, 0x20
	out 0x20, al
	
	mov esi, systeminfomsg
	call printquiet
	mov ecx, osend
	shr ecx, 10
	call showdec
	mov esi, diskbytemsg
	call printquiet
	mov ecx, osend
	add ecx, commandbufend
	sub ecx, bssstart	;add the extra buffer space
	shr ecx, 10
	call showdec
	mov esi, membytemsg
	call printquiet
	xor edx, edx
	xor eax, eax
	mov eax, [cpuspeedperint]
	mov ebx, [timeinterval]
	shr ebx, 10 ;divide the interval by 1024
	div ebx	;quotient in eax, remainder in edx
	mov ecx, eax
	call showdec
	mov esi, cpuspeedmsg
	call printquiet
	mov ecx, [memoryspace]
	shr ecx, 20
	call showdec
	mov esi, memoryspacemsg
	call print
	jmp nwcmd

systeminfomsg db "Kernel Information:",10,0
diskbytemsg db "KB Disk Space Used",10,0
membytemsg db "KB Memory Space Used",10,"System Information:",10,0
cpuspeedmsg db "MHz",10,0
memoryspacemsg db "MB Memory Space Free",10,0