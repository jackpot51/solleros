db 255,44,"play",0
	call playsync
	ret
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

%ifdef sound.included
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
	mov esi, nosoundblaster
	call print
	ret
%else
	wave_player:
		mov esi, nosoundblaster
		call print
		ret
%endif
nosoundblaster db "No Sound Blaster detected.",10,0
