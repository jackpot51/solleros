db 255,44,"playa",0
	mov edi, [currentcommandloc]
	add edi, 6
	call playasync
	ret
db 255,44,"play",0
play:
	mov edi, [currentcommandloc]
	add edi, 5
	call playasync
.waitforsound:
	hlt
%ifdef sound.included
	mov eax, [Length0]
	or ax, [Length1]
%endif
	or al, [soundon]
	cmp eax, 0
	jne .waitforsound
	ret
playasync:
	mov esi, 0xC00000
	call loadfile
	cmp edx, 404
	je nosoundfound
	mov ebx, 0xC00000
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
notfoundsound db "play: ",0

%ifdef sound.included
sbplay:
		mov esi, 0xC00000
		mov ebx, esi
		add esi, WAVSTART
		sub edi, esi
		mov [Length1], di
		shr edi, 15
		mov [Length0], edi
		mov ecx, [ebx + 24]
		mov [Freq], ecx
		xor eax, eax
		mov	edx, 0xC00000 ;physical location of sound
		add edx, WAVSTART
		add	eax, edx
		mov esi, eax
		xor ecx, ecx
		xor ebx, ebx
		mov [SegLoc], bx
		add ebx, 0x80000
		mov cx, 0xFFFF
		cmp di, 0
		jne .autoinit
		mov cx, [Length1]
		mov byte [OddLength], 1
		cmp cx, 32768
		jae .autoinit
		mov byte [OddLength], 0
		shl cx, 1
		inc edi
.autoinit:
		dec edi
		mov [Length0], edi
		mov [Length1], cx
		shr cx, 1
		inc cx
		add eax, ecx
		mov [NextMemLoc], eax
		mov	[MemLoc], esi
		call DMACopy
		xor ebx, ebx
		mov bx, [SegLoc]
		xor ecx, ecx
		mov cx, [Length1]
		shr cx, 1
		inc cx
		add ebx, ecx
		mov [SegLoc], bx
		add ebx, 0x80000
		mov esi, [NextMemLoc]
		mov eax, esi
		add eax, ecx
		mov [NextMemLoc], eax
		mov	[MemLoc], esi
		call DMACopy
		call DMAPlay
		call PlayDSP
		ret
WAVSTART equ 44
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
