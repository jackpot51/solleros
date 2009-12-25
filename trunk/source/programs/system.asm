	db 255,44,"system",0
	mov esi, systeminfomsg
	call printquiet
	mov ecx, osend
	call showdec
	mov esi, diskbytemsg
	call printquiet
	mov ecx, osend
	add ecx, commandbufend
	sub ecx, bssstart	;add the extra buffer space
	call showdec
	mov esi, membytemsg
	call printquiet
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
	xor edx, edx
	xor eax, eax
	mov eax, [cpuspeedperint]
	shl eax, 1	;the cpu speed loop actually contains 2 commands so multiply the
				;result by 2
	mov ebx, [timeinterval]
	shr ebx, 10 ;divide the interval by 1024
	div ebx	;quotient in eax, remainder in edx
	mov ecx, eax
	call showdec
	mov esi, cpuspeedmsg
	call printquiet
	mov ecx, [memoryspace]
	shr ecx, 20
	inc ecx	;the reading is one MB behind
	call showdec
	mov esi, memoryspacemsg
	call print
%ifdef sound.included
	cmp byte [SoundBlaster], 0
	je .nosb
	mov esi, soundblastermsg
	call print
.nosb:
%endif
	ret

systeminfomsg db "Kernel Information:",10,0
diskbytemsg db "Bytes Disk Space Used",10,0
membytemsg db "Bytes Memory Space Used",10,"System Information:",10,0
%ifdef sound.included
	soundblastermsg db "Soundblaster Detected.",10,0
%endif
cpuspeedmsg db "MIPS",10,0
memoryspacemsg db "MB Memory Space Free",10,0
