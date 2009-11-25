db 255,44,"play",0
	call playsync
	jmp nwcmd
playsync:
	mov edi, [currentcommandloc]
	add edi, 5
	mov esi, 0x400000
	call loadfile
	cmp edx, 404
	je nosoundfound
	mov ebx, 0x400000
	cmp dword [ebx + 8], "WAVE"
	je near wave_player
	cmp word [ebx], "SN"
	jne nosoundfound
	add ebx, 6
	mov [soundpos], ebx
	add ebx, [ebx - 4]
	mov [soundendpos], ebx
	mov word [soundrepititions], 0
	mov byte [soundon], 1
waitforsoundendplay:
	mov al, [soundon]
	cmp al, 0
	jne waitforsoundendplay
	ret
nosoundfound:
	mov esi, notfoundsound
	call print
	mov esi, [currentcommandloc]
	add esi, 5
	call print
	mov esi, notfound2
	call print
	ret
notfoundsound db "Sound ",34,0

sbplay:
		mov esi, 0x400000
		mov ebx, esi
		add esi, 44
		sub edi, esi
		mov [Length1], di
		shr edi, 16
		mov [Length0], di
		mov ecx, [ebx + 24]
		mov [Freq], ecx
		xor eax, eax
		mov	edx, 0x400000 ;location of sound
		add edx, 2048
		add	eax,edx
		xor ebx, ebx
		mov bx, [Length1]
		add ebx, eax
		mov [NextMemLoc], ebx
		mov	[MemLoc],eax
		call DMAPlay
		ret

wave_player:
	cmp byte [SoundBlaster], 1
	je near sbplay
	mov esi, 0x400000
	mov ecx, [esi + 24]
	mov [WAVSamplingRate], cx
	sub edi, esi
	sub edi, 44
	mov [WAVFileSize], edi
	;MASK ALL INTS EXCEPT IRQ 0
	mov al, 0xFE
	out 0x21, al
	inc al
	out 0xA1, al
	mov al, 0x20
	out 0xA0, al
	out 0x20, al
	;SET PIT DIVISOR
	xor edx, edx
	mov ecx, [esi + 24]
	mov eax, 1193182
	div ecx ;al should be the proper sample divisor
	out 0x40, al
	rol ax, 8
	out 0x40, al
	;GET WAVEDIV
	mov bx, [WAVSamplingRate]
	mov ax,0x34dd	; The sound lasts until NoSound is called
	mov dx,0x0012             
	div bx               
	mov [WAVEDIV],ax
	;PLAY WAVE
	add esi, 44
	call PlayWAV
	;UNMASK ALL INTS
	xor al, al
	out 0x21, al
	xor al, al
	out 0xA1, al
	mov al, 0x20
	out 0xA0, al
	out 0x20, al
	;RESET PIT DIVISOR
	mov ax, [pitdiv]
	out 0x40, al
	rol ax, 8
	out 0x40, al
	ret
	
PlayWAV:
   mov ecx,[WAVFileSize]                         ;Sets the loop point
   mov byte [EnableDigitized],1	;Tells the irq0 handler to process the routines
Play_Repeat:
   mov al, [esi]	;Loads a byte from ESI to AL
   hlt	;Wait for IRQ to fire
   loop Play_Repeat	;and the whole procedure is looped ECX times
   mov byte [EnableDigitized],0	;Tells the irq0 handler to disable the digitized functions
   call Sound_Off	;Turn the speaker off just in case
   ret
   